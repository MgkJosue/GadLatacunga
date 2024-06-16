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
