CREATE OR REPLACE FUNCTION eliminar_lectorruta(id_lectorruta INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM aapplectorruta
    WHERE id = id_lectorruta;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la ruta con ID %', id_lectorruta;
    END IF;
END;
$$ LANGUAGE plpgsql;
