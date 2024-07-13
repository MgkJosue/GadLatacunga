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
