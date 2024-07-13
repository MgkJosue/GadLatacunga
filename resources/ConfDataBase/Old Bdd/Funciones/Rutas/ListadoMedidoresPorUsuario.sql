-- Funcion para obtener informacion de acometidas relacionadas con id del usuario
CREATE OR REPLACE FUNCTION RutaLecturaMovil(p_idusuario INTEGER)
RETURNS TABLE (
    id_usuario INTEGER,
    id_ruta INTEGER,
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
        apl.idusuario AS id_usuario,
        apl.idruta AS id_ruta,
        a.numcuenta,
        a.no_medidor,
        a.clave,
        a.ruta,
        a.direccion,
        COALESCE(
            (SELECT ciud.nombrecompleto 
             FROM aapplectura aplect
             INNER JOIN ciudadano ciud ON aplect.ciu = ciud.id AND aplect.numcuenta = a.numcuenta
             LIMIT 1),
            (SELECT appmov.abonado 
             FROM public.aapmovillectura appmov
             WHERE appmov.cuenta = a.numcuenta
             LIMIT 1)
        ) AS abonado
    FROM acometidas a
    INNER JOIN aapplectorruta apl ON a.ruta = (SELECT nombreruta FROM aappruta WHERE id = apl.idruta)
    WHERE apl.idusuario = p_idusuario; 
END;
$$ LANGUAGE plpgsql;
