--Funcion para Validar Usuario
CREATE OR REPLACE FUNCTION validar_usuario(
    p_nombre_usuario VARCHAR(255),
    p_contrasena VARCHAR(255)
)
RETURNS RECORD AS $$  -- Cambiamos a RECORD para devolver varios valores
DECLARE
    v_contrasena_almacenada VARCHAR(255);
    v_usuario_id INT;             -- Variable para almacenar el ID del usuario
BEGIN
    -- Obtener la contraseña y el ID del usuario
    SELECT contrasena, id INTO v_contrasena_almacenada, v_usuario_id
    FROM usuarios
    WHERE nombre_usuario = p_nombre_usuario;

    IF v_contrasena_almacenada IS NULL THEN
        RETURN (FALSE, NULL);    -- Devolvemos FALSE y un ID nulo si no se encuentra el usuario
    ELSIF v_contrasena_almacenada = p_contrasena THEN
        RETURN (TRUE, v_usuario_id); -- Devolvemos TRUE y el ID si la contraseña es correcta
    ELSE
        RETURN (FALSE, NULL);    -- Devolvemos FALSE y un ID nulo si la contraseña es incorrecta
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE TYPE tipo_lectura AS (
    numcuenta VARCHAR(255),
    no_medidor VARCHAR(255),
    clave VARCHAR(255),
    lectura VARCHAR(10),
    observacion TEXT,
    coordenadasXYZ TEXT
);

CREATE OR REPLACE PROCEDURE SincronizarLecturasMasivas(
    p_idusuario INTEGER,
    p_lecturas tipo_lectura[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_lectura tipo_lectura;
    v_anio INTEGER;
    v_mes INTEGER;
    v_lectura_anterior VARCHAR(10);
    v_consumo INTEGER;
    v_abonado VARCHAR(255);
    v_direccion VARCHAR(255);
    v_ruta VARCHAR(255);
BEGIN
    -- Obtener año y mes actuales
    SELECT EXTRACT(YEAR FROM NOW()), EXTRACT(MONTH FROM NOW())
    INTO v_anio, v_mes;

    -- Loop a través del array de lecturas
    FOREACH v_lectura IN ARRAY p_lecturas
    LOOP
        -- Obtener la ruta de la cuenta y verificar si está asignada al usuario
        SELECT a.ruta
        INTO v_ruta
        FROM acometidas a
        INNER JOIN aapplectorruta apl ON a.ruta = (SELECT nombreruta FROM aappruta WHERE id = apl.idruta)
        WHERE apl.idusuario = p_idusuario AND a.numcuenta = v_lectura.numcuenta
        LIMIT 1;
        
        -- Si no se encuentra la ruta o no está asignada al usuario, saltar a la siguiente iteración
        IF v_ruta IS NULL THEN
            CONTINUE;
        END IF;

        -- Obtener la lectura anterior y otros datos (con manejo de nulos) desde aapMovilLectura
        SELECT lectura, abonado, direccion
        INTO v_lectura_anterior, v_abonado, v_direccion
        FROM aapMovilLectura
        WHERE cuenta = v_lectura.numcuenta
        ORDER BY id DESC
        LIMIT 1;

        -- Calcular consumo SOLO si hay lectura anterior y es un valor numérico
        IF v_lectura_anterior IS NOT NULL AND v_lectura_anterior ~ '^[0-9]+$' THEN
            v_consumo := v_lectura.lectura::INTEGER - v_lectura_anterior::INTEGER;
        ELSE
            v_consumo := 0;
        END IF;

        -- Verificar si ya existe una lectura para el mes y año actual
        IF EXISTS (
            SELECT 1
            FROM aapMovilLectura
            WHERE cuenta = v_lectura.numcuenta
              AND EXTRACT(YEAR FROM CURRENT_DATE) = v_anio
              AND EXTRACT(MONTH FROM CURRENT_DATE) = v_mes
        ) THEN
            -- Actualizar la lectura existente (sin cambiar la dirección)
            UPDATE aapMovilLectura
            SET lectura = v_lectura.lectura,
                observacion = v_lectura.observacion,
                coordenadasXYZ = v_lectura.coordenadasXYZ
            WHERE cuenta = v_lectura.numcuenta
              AND EXTRACT(YEAR FROM CURRENT_DATE) = v_anio
              AND EXTRACT(MONTH FROM CURRENT_DATE) = v_mes;
        ELSE
            -- Insertar una nueva lectura (manteniendo la dirección y abonado)
            INSERT INTO aapMovilLectura (cuenta, medidor, clave, abonado, lectura, observacion, coordenadasXYZ, direccion)
            VALUES (v_lectura.numcuenta, v_lectura.no_medidor, v_lectura.clave, v_abonado, v_lectura.lectura, v_lectura.observacion, v_lectura.coordenadasXYZ, v_direccion);
        END IF;
    END LOOP;
END;
$$;


-- Procedimiento para asignar o actualizar una ruta a un usuario
CREATE OR REPLACE FUNCTION AsignarRutaAUsuario(
    p_user_id INTEGER,
    p_route_id INTEGER
) RETURNS TEXT AS $$
DECLARE
    existing_record_id INTEGER;
    user_name VARCHAR(255);
    route_name VARCHAR(255);
    mensaje TEXT;
BEGIN
    -- Verificar si el usuario y la ruta existen
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_user_id) THEN
        mensaje := format('El usuario con ID %s no existe', p_user_id);
        RETURN mensaje;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM aappruta WHERE id = p_route_id) THEN
        mensaje := format('La ruta con ID %s no existe', p_route_id);
        RETURN mensaje;
    END IF;

    -- Obtener el nombre del usuario
    SELECT nombre_usuario INTO user_name FROM usuarios WHERE id = p_user_id;

    -- Obtener el nombre de la ruta
    SELECT nombreruta INTO route_name FROM aappruta WHERE id = p_route_id;

    -- Verificar si la ruta ya está asignada a otro usuario
    IF EXISTS (SELECT 1 FROM aapplectorruta WHERE idruta = p_route_id AND idusuario <> p_user_id) THEN
        mensaje := format('La ruta con nombre %s ya está asignada a otro usuario.', route_name);
        RETURN mensaje;
    END IF;

    -- Verificar si el usuario ya tiene una ruta asignada
    SELECT id INTO existing_record_id
    FROM aapplectorruta
    WHERE idusuario = p_user_id
    AND idruta = p_route_id;

    IF existing_record_id IS NOT NULL THEN
        mensaje := format('La ruta %s ya está asignada al usuario %s.', route_name, user_name);
    ELSE
        -- Asignar la ruta al usuario
        INSERT INTO aapplectorruta (idusuario, idruta)
        VALUES (p_user_id, p_route_id);
        mensaje := format('Ruta %s asignada correctamente al usuario %s.', route_name, user_name);
    END IF;

    RETURN mensaje;
END;
$$ LANGUAGE plpgsql;


-- Procedimiento para eliminar la asignación de ruta a un usuario
CREATE OR REPLACE PROCEDURE EliminarAsignacionDeRuta(
    p_user_id INTEGER,
    p_route_id INTEGER
) AS $$
BEGIN
    -- Verificar si la asignación existe
    IF NOT EXISTS (SELECT 1 FROM aapplectorruta WHERE idusuario = p_user_id AND idruta = p_route_id) THEN
        RAISE EXCEPTION 'La asignación entre el usuario con ID % y la ruta con ID % no existe', p_user_id, p_route_id;
    END IF;

    -- Eliminar la asignación de ruta para el usuario
    DELETE FROM aapplectorruta
    WHERE idusuario = p_user_id AND idruta = p_route_id;

    RAISE NOTICE 'Asignación de ruta eliminada correctamente para el usuario.';
END;
$$ LANGUAGE plpgsql;

-- Funcion para obtener informacion de acometidas relacionadas con id del usuario
CREATE OR REPLACE FUNCTION RutaLecturaMovil(p_idusuario INTEGER)
RETURNS TABLE (
    id_usuario INTEGER,
    id_ruta INTEGER,
    numcuenta VARCHAR(255),
    no_medidor VARCHAR(255),
    clave VARCHAR(255),
    ruta VARCHAR(255),
    direccion VARCHAR(255),
    abonado VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        apl.idusuario AS id_usuario,
        apl.idruta AS id_ruta,
        a.numcuenta,
        a.no_medidor,
        a.clave,
        a.ruta,
        a.direccion,
        (SELECT ciud.nombrecompleto 
         FROM aapplectura aplect
         INNER JOIN ciudadano ciud ON aplect.ciu = ciud.id AND aplect.numcuenta = a.numcuenta
         LIMIT 1) AS abonado
    FROM acometidas a
    INNER JOIN aapplectorruta apl ON a.ruta = (SELECT nombreruta FROM aappruta WHERE id = apl.idruta)
    WHERE apl.idusuario = p_idusuario; 
END;
$$ LANGUAGE plpgsql;


-- Función para obtener todas las rutas
CREATE OR REPLACE FUNCTION ObtenerRutas()
RETURNS TABLE (
    id INTEGER,
    nombreruta VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.nombreruta 
    FROM aappruta r;
END;
$$ LANGUAGE plpgsql;

-- Función para obtener todos los usuarios
CREATE OR REPLACE FUNCTION ObtenerUsuarios()
RETURNS TABLE (
    id INTEGER,
    nombre_usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.nombre_usuario
    FROM usuarios u;
END;
$$ LANGUAGE plpgsql;

--Funcion para obtener la ruta de acuerdo a un id usuario 
CREATE OR REPLACE FUNCTION UsuarioRuta(p_idusuario INTEGER)
RETURNS TABLE (
  nombre_ruta VARCHAR(255),
  nombre_usuario VARCHAR(255),
  id_usuario INTEGER,
  id_ruta INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ap.nombreruta AS nombre_ruta, 
    usu.nombre_usuario AS nombre_usuario, 
    apl.idusuario AS id_usuario, 
    apl.idruta AS id_ruta
  FROM aapplectorruta apl 
  INNER JOIN aappruta ap ON apl.idruta = ap.id
  INNER JOIN usuarios usu ON apl.idusuario = usu.id
  WHERE apl.idusuario = p_idusuario;
END;
$$ LANGUAGE plpgsql;