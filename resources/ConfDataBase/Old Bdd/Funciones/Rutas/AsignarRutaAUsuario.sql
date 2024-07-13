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
