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


-- Eliminar el tipo compuesto si ya existe
DROP TYPE IF EXISTS tipo_lectura;

-- Crear el tipo compuesto tipo_lectura con las nuevas columnas
CREATE TYPE tipo_lectura AS (
    numcuenta VARCHAR(255),
    no_medidor VARCHAR(255),
    clave VARCHAR(255),
    lectura VARCHAR(10),
    observacion TEXT,
    coordenadasXYZ TEXT,
    motivo TEXT,   -- Nueva columna para motivo
    imagen BYTEA   -- Nueva columna para imagen
);

-- Modificar el procedimiento almacenado SincronizarLecturasMasivas
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
                coordenadasXYZ = v_lectura.coordenadasXYZ,
                motivo = COALESCE(v_lectura.motivo, motivo),
                imagen = COALESCE(v_lectura.imagen, imagen)
            WHERE cuenta = v_lectura.numcuenta
              AND EXTRACT(YEAR FROM CURRENT_DATE) = v_anio
              AND EXTRACT(MONTH FROM CURRENT_DATE) = v_mes;
        ELSE
            -- Insertar una nueva lectura (manteniendo la dirección y abonado)
            INSERT INTO aapMovilLectura (cuenta, medidor, clave, abonado, lectura, observacion, coordenadasXYZ, direccion, motivo, imagen)
            VALUES (v_lectura.numcuenta, v_lectura.no_medidor, v_lectura.clave, v_abonado, v_lectura.lectura, v_lectura.observacion, v_lectura.coordenadasXYZ, v_direccion, v_lectura.motivo, v_lectura.imagen);
        END IF;
    END LOOP;
END;
$$;


-- Procedimiento para actualizar los datos de un lector-ruta
CREATE OR REPLACE FUNCTION ActualizarLectorRuta(
    p_id INTEGER, -- ID del registro en la tabla aapplectorruta
    p_user_id INTEGER, -- Nuevo ID de usuario
    p_route_id INTEGER -- Nuevo ID de ruta
) RETURNS TEXT AS $$
DECLARE
    existing_record_id INTEGER;
    user_name VARCHAR(255);
    route_name VARCHAR(255);
    mensaje TEXT;
BEGIN
    -- Verificar si el registro con el ID proporcionado existe
    IF NOT EXISTS (SELECT 1 FROM aapplectorruta WHERE id = p_id) THEN
        mensaje := format('El registro con ID %s no existe', p_id);
        RETURN mensaje;
    END IF;

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

    -- Verificar si la misma combinación de usuario y ruta ya existe en otro registro
    IF EXISTS (SELECT 1 FROM aapplectorruta WHERE idusuario = p_user_id AND idruta = p_route_id AND id <> p_id) THEN
        mensaje := format('La combinación de usuario %s y ruta %s ya existe en otro registro.', user_name, route_name);
        RETURN mensaje;
    END IF;

    -- Verificar si la nueva ruta ya está asignada a otro usuario
    IF EXISTS (SELECT 1 FROM aapplectorruta WHERE idruta = p_route_id AND idusuario <> p_user_id) THEN
        mensaje := format('La ruta con nombre %s ya está asignada a otro usuario.', route_name);
        RETURN mensaje;
    END IF;

    -- Actualizar el registro en la tabla aapplectorruta
    UPDATE aapplectorruta
    SET idusuario = p_user_id, idruta = p_route_id
    WHERE id = p_id;

    mensaje := format('Registro con ID %s actualizado correctamente. Nueva ruta %s asignada al usuario %s.', p_id, route_name, user_name);
    RETURN mensaje;
END;
$$ LANGUAGE plpgsql;

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

CREATE OR REPLACE FUNCTION eliminar_lectorruta(id_lectorruta INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM aapplectorruta
    WHERE id = id_lectorruta;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la ruta con ID %', id_lectorruta;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obtener_lectorruta(id_lectorruta INT)
RETURNS TABLE (
    id INT,
    idusuario INT,
    idruta INT,
    nombre_usuario VARCHAR,
    nombre_ruta VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id, 
        a.idusuario, 
        a.idruta, 
        u.nombre_usuario, 
        r.nombreruta
    FROM 
        aapplectorruta a
        JOIN usuarios u ON a.idusuario = u.id
        JOIN aappruta r ON a.idruta = r.id
    WHERE 
        a.id = id_lectorruta;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró el Lector-Ruta con ID %', id_lectorruta;
    END IF;
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
        COALESCE(
            (SELECT ciud.nombrecompleto 
             FROM aapplectura aplect
             INNER JOIN ciudadano ciud ON aplect.ciu = ciud.id AND aplect.numcuenta = a.numcuenta
             LIMIT 1),
            (SELECT appmov.abonado 
             FROM public.aapmovillectura appmov
             WHERE appmov.cuenta = a.numcuenta
             LIMIT 1)
        ) AS abonado
    FROM acometidas a
    INNER JOIN aapplectorruta apl ON a.ruta = (SELECT nombreruta FROM aappruta WHERE id = apl.idruta)
    WHERE apl.idusuario = p_idusuario; 
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION obtener_datos_lectorruta()
RETURNS TABLE(
    id_lectorruta INT,
    id_usuario INT,
    nombre_usuario VARCHAR,
    id_ruta INT,
    nombre_ruta VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        alr.id AS id_lectorruta,
        u.id AS id_usuario,
        u.nombre_usuario,
        ar.id AS id_ruta,
        ar.nombreruta AS nombre_ruta
    FROM 
        aapplectorruta alr
    JOIN 
        usuarios u ON alr.idusuario = u.id
    JOIN 
        aappruta ar ON alr.idruta = ar.id;
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

CREATE OR REPLACE FUNCTION copiar_registros_a_evidencia()
RETURNS VOID AS $$
BEGIN
    INSERT INTO aapEvidencia (cuenta, medidor, clave, abonado, lectura, observacion, coordenadasXYZ, direccion, motivo, imagen)
    SELECT cuenta, medidor, clave, abonado, lectura, observacion, coordenadasXYZ, direccion, motivo, imagen
    FROM aapMovilLectura
    WHERE motivo IS NOT NULL OR imagen IS NOT NULL
    ON CONFLICT (cuenta, medidor)
    DO UPDATE SET
        clave = EXCLUDED.clave,
        abonado = EXCLUDED.abonado,
        lectura = EXCLUDED.lectura,
        observacion = EXCLUDED.observacion,
        coordenadasXYZ = EXCLUDED.coordenadasXYZ,
        direccion = EXCLUDED.direccion,
        motivo = EXCLUDED.motivo,
        imagen = EXCLUDED.imagen;
END;
$$ LANGUAGE plpgsql;
