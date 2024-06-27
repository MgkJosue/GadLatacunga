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