CREATE OR REPLACE FUNCTION crear_tablas_temporales()
RETURNS void AS $$
BEGIN
    -- Crear la tabla temporal para registros que necesitan actualización
    CREATE TEMP TABLE temp_actualizar AS
    SELECT aml.*
    FROM aapMovilLectura aml
    INNER JOIN aapplectura al ON aml.cuenta = al.numcuenta;

    -- Crear la tabla temporal para registros que necesitan inserción
    CREATE TEMP TABLE temp_insertar AS
    SELECT aml.*
    FROM aapMovilLectura aml
    LEFT JOIN aapplectura al ON aml.cuenta = al.numcuenta
    WHERE al.numcuenta IS NULL;

END;
$$ LANGUAGE plpgsql;
