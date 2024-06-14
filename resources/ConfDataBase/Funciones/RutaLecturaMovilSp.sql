CREATE OR REPLACE FUNCTION RutaLecturaMovil(p_idruta INTEGER)
RETURNS TABLE (
    numcuenta VARCHAR(255),
    no_medidor VARCHAR(255),
    clave VARCHAR(255),
    ruta VARCHAR(255),
    abonado VARCHAR(255),
    direccion VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.numcuenta,
        a.no_medidor,
        a.clave,
        a.ruta,
        c.nombreCompleto AS abonado,
        a.direccion
    FROM acometidas a
    JOIN aapMovilLectura m ON a.numcuenta = m.cuenta
    JOIN ciudadano c ON m.abonado = c.nombreCompleto
    WHERE a.ruta = (
        SELECT nombreruta
        FROM aappruta
        WHERE id = p_idruta
    );
END;
$$ LANGUAGE plpgsql;
