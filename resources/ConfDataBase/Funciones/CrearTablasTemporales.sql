-- Crear tablas temporales
CREATE OR REPLACE FUNCTION crear_tablas_temporales()
RETURNS void AS $$
BEGIN
    -- Crear la tabla temporal para registros que necesitan actualización
    CREATE TEMP TABLE temp_actualizar AS
    SELECT DISTINCT aml.*
    FROM aapMovilLectura aml
    INNER JOIN aapplectura al ON aml.cuenta = al.numcuenta
    WHERE EXTRACT(MONTH FROM CURRENT_DATE) = al.mes;

    -- Crear la tabla temporal para registros que necesitan inserción
    CREATE TEMP TABLE temp_insertar AS
    SELECT DISTINCT aml.*
    FROM aapMovilLectura aml
    LEFT JOIN aapplectura al ON aml.cuenta = al.numcuenta
    WHERE al.numcuenta IS NULL
       OR EXTRACT(MONTH FROM CURRENT_DATE) <> al.mes;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION actualizar_insertar_lecturas()
RETURNS void AS $$
DECLARE
    max_id INTEGER;
BEGIN
    -- Actualizar registros existentes en aapplectura usando la tabla temporal temp_actualizar
    UPDATE aapplectura al
    SET
        lectura = tmp.lectura::INTEGER,
        observacion = tmp.observacion,
        nromedidor = tmp.medidor,
        lecturaanterior = COALESCE(
            (SELECT al2.lectura
             FROM aapplectura al2
             WHERE al2.numcuenta = al.numcuenta
               AND al2.anio = al.anio
               AND al2.mes = (
                   SELECT MAX(al3.mes)
                   FROM aapplectura al3
                   WHERE al3.numcuenta = al.numcuenta
                     AND al3.anio = al.anio
                     AND al3.mes < al.mes
               )), al.lecturaanterior
        ),
        consumo = tmp.lectura::INTEGER - COALESCE(
            (SELECT al2.lectura
             FROM aapplectura al2
             WHERE al2.numcuenta = al.numcuenta
               AND al2.anio = al.anio
               AND al2.mes = (
                   SELECT MAX(al3.mes)
                   FROM aapplectura al3
                   WHERE al3.numcuenta = al.numcuenta
                     AND al3.anio = al.anio
                     AND al3.mes < al.mes
               )), 0
        )
    FROM temp_actualizar tmp
    WHERE al.numcuenta = tmp.cuenta 
      AND EXTRACT(YEAR FROM CURRENT_DATE) = al.anio
      AND EXTRACT(MONTH FROM CURRENT_DATE) = al.mes;

    -- Ajustar la secuencia del id para evitar duplicados
    SELECT MAX(id) INTO max_id FROM aapplectura;
    IF max_id IS NOT NULL THEN
        PERFORM setval('aapplectura_id_seq', max_id + 1);
    END IF;

    -- Insertar nuevos registros en aapplectura desde la tabla temporal temp_insertar
    INSERT INTO aapplectura (numcuenta, anio, mes, lectura, observacion, lecturaanterior, consumo, nromedidor, ciu)
    SELECT
        tmp.cuenta,
        EXTRACT(YEAR FROM CURRENT_DATE) AS anio,
        EXTRACT(MONTH FROM CURRENT_DATE) AS mes,
        tmp.lectura::INTEGER,
        tmp.observacion,
        COALESCE(
            (SELECT al.lectura
             FROM aapplectura al 
             WHERE al.numcuenta = tmp.cuenta 
               AND al.anio = EXTRACT(YEAR FROM CURRENT_DATE)
               AND al.mes = (
                   SELECT MAX(al2.mes)
                   FROM aapplectura al2
                   WHERE al2.numcuenta = tmp.cuenta
                     AND al2.anio = EXTRACT(YEAR FROM CURRENT_DATE)
                     AND al2.mes < EXTRACT(MONTH FROM CURRENT_DATE)
               )), 0
        ) AS lecturaanterior,
        tmp.lectura::INTEGER - COALESCE(
            (SELECT al.lectura
             FROM aapplectura al 
             WHERE al.numcuenta = tmp.cuenta 
               AND al.anio = EXTRACT(YEAR FROM CURRENT_DATE)
               AND al.mes = (
                   SELECT MAX(al2.mes)
                   FROM aapplectura al2
                   WHERE al2.numcuenta = tmp.cuenta
                     AND al2.anio = EXTRACT(YEAR FROM CURRENT_DATE)
                     AND al2.mes < EXTRACT(MONTH FROM CURRENT_DATE)
               )), 0
        ) AS consumo,
        tmp.medidor,
        (SELECT ci.id FROM ciudadano ci WHERE ci.nombreCompleto = tmp.abonado) -- Obtener el id del ciudadano
    FROM temp_insertar tmp;

    -- Eliminar las tablas temporales
    DROP TABLE IF EXISTS temp_actualizar;
    DROP TABLE IF EXISTS temp_insertar;
END;
$$ LANGUAGE plpgsql;
