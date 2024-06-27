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