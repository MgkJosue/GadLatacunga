CREATE OR REPLACE FUNCTION validar_usuario(
    p_nombre_usuario VARCHAR(255),
    p_contrasena VARCHAR(255)
)
RETURNS BOOLEAN AS $$
DECLARE
    v_contrasena_almacenada VARCHAR(255);
BEGIN
    -- Obtener la contraseña almacenada para el usuario
    SELECT contrasena INTO v_contrasena_almacenada
    FROM usuarios
    WHERE nombre_usuario = p_nombre_usuario;

    -- Verificar si el usuario existe y la contraseña coincide
    IF v_contrasena_almacenada IS NULL THEN
        -- Usuario no encontrado
        RETURN FALSE;
    ELSIF v_contrasena_almacenada = p_contrasena THEN
        -- Contraseña correcta
        RETURN TRUE;
    ELSE
        -- Contraseña incorrecta
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;
