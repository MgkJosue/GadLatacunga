CREATE OR REPLACE FUNCTION UsuarioRuta(p_idusuario INTEGER)
RETURNS TABLE (
    idruta INTEGER,
    nombreruta VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ar.idruta, r.nombreruta
    FROM aapplectorruta ar
    JOIN aappruta r ON ar.idruta = r.id
    WHERE ar.idusuario = p_idusuario;
END;
$$ LANGUAGE plpgsql;
