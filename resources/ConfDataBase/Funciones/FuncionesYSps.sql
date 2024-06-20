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



-- Funcion para obtener informacion de acometidas relacionadas con id del usuario
CREATE OR REPLACE FUNCTION RutaLecturaMovil(p_idusuario INTEGER)
RETURNS TABLE (
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


-- Procedimiento para asignar una ruta a un usuario
CREATE OR REPLACE PROCEDURE AsignarRutaAUsuario(
    p_user_id INTEGER,
    p_route_id INTEGER
) AS $$
DECLARE
    existing_user_id INTEGER;
BEGIN
    -- Verificar si el usuario y la ruta existen
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_user_id) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe', p_user_id;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM aappruta WHERE id = p_route_id) THEN
        RAISE EXCEPTION 'La ruta con ID % no existe', p_route_id;
    END IF;

    -- Verificar si la ruta ya está asignada a otro usuario
    SELECT idusuario INTO existing_user_id
    FROM aapplectorruta
    WHERE idruta = p_route_id;

    IF existing_user_id IS NOT NULL THEN
        RAISE EXCEPTION 'La ruta con ID % ya está asignada al usuario con ID %', p_route_id, existing_user_id;
    END IF;

    -- Verificar si el usuario ya tiene asignada esta ruta (aunque debería ser innecesario si la ruta ya está asignada a otro usuario)
    IF EXISTS (SELECT 1 FROM aapplectorruta WHERE idusuario = p_user_id AND idruta = p_route_id) THEN
        RAISE NOTICE 'El usuario ya tiene asignada esta ruta.';
        RETURN;
    END IF;

    -- Asignar la ruta al usuario
    INSERT INTO aapplectorruta (idusuario, idruta)
    VALUES (p_user_id, p_route_id);

    RAISE NOTICE 'Ruta asignada correctamente al usuario.';
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