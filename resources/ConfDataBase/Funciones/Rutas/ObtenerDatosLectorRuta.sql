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
