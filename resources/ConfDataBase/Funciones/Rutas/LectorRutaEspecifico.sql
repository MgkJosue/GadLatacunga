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
