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


CREATE OR REPLACE FUNCTION actualizar_insertar_lecturas()
RETURNS void AS $$
BEGIN
    -- Actualizar registros existentes en aapplectura usando la tabla temporal temp_actualizar
    UPDATE aapplectura al
    SET
        lectura = tmp.lectura::INTEGER,
        observacion = tmp.observacion,
        nromedidor = tmp.medidor,
        lecturaanterior = CASE
            WHEN al.lecturaanterior IS NULL THEN tmp.lectura::INTEGER
            ELSE al.lecturaanterior
        END,
        consumo = CASE
            WHEN al.lecturaanterior IS NULL THEN tmp.lectura::INTEGER
            ELSE tmp.lectura::INTEGER - al.lecturaanterior
        END
    FROM temp_actualizar tmp
    WHERE al.numcuenta = tmp.cuenta;

    -- Insertar nuevos registros en aapplectura desde la tabla temporal temp_insertar
    INSERT INTO aapplectura (numcuenta, anio, mes, lectura, observacion, lecturaanterior, consumo, nromedidor, ciu)
    SELECT
        tmp.cuenta,
        EXTRACT(YEAR FROM CURRENT_DATE) AS anio,
        EXTRACT(MONTH FROM CURRENT_DATE) AS mes,
        tmp.lectura::INTEGER,
        tmp.observacion,
        tmp.lectura::INTEGER, -- Asignar la lectura actual como lecturaanterior
        tmp.lectura::INTEGER, -- Asignar la lectura actual como consumo inicial
        tmp.medidor,
        (SELECT ci.id FROM ciudadano ci WHERE ci.nombrecompleto = tmp.abonado) -- Obtener el id del ciudadano
    FROM temp_insertar tmp;

END;
$$ LANGUAGE plpgsql;
