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