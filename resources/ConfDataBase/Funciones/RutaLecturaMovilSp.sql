CREATE OR REPLACE FUNCTION RutaLecturaMovil(p_idusuario INTEGER)
RETURNS TABLE (
    numcuenta VARCHAR(255),
    no_medidor VARCHAR(255),
    clave VARCHAR(255),
    ruta VARCHAR(255),
    direccion VARCHAR(255),
	abonado VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.numcuenta,
        a.no_medidor,
        a.clave,
        a.ruta,
        a.direccion,
		(SELECT ciud.nombrecompleto 
         FROM aapplectura aplect
         INNER JOIN ciudadano ciud ON aplect.ciu = ciud.id AND aplect.numcuenta = a.numcuenta
         LIMIT 1) AS abonado
    FROM acometidas a
    INNER JOIN aapplectorruta apl ON a.ruta = (SELECT nombreruta FROM aappruta WHERE id = apl.idruta)
    WHERE apl.idusuario = p_idusuario; 
END;
$$ LANGUAGE plpgsql;
