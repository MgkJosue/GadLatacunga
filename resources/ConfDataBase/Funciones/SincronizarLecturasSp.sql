CREATE OR REPLACE PROCEDURE SincronizarLecturas(
  p_numcuenta VARCHAR(255),
  p_no_medidor VARCHAR(255),  -- Asegúrate de que los nombres de los parámetros coincidan con los de la tabla
  p_clave VARCHAR(255),
  p_ruta VARCHAR(255),
  p_lectura VARCHAR(10),
  p_observacion TEXT,
  p_login VARCHAR(255),
  p_coordenadasXYZ TEXT  -- Nuevo parámetro para las coordenadas XYZ
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_anio INTEGER;
    v_mes INTEGER;
    v_lectura_anterior VARCHAR(10);
    v_consumo INTEGER := 0; -- Inicializado en 0
BEGIN
    -- Obtener año y mes actuales
    SELECT EXTRACT(YEAR FROM NOW()), EXTRACT(MONTH FROM NOW())
    INTO v_anio, v_mes;

    -- Obtener la lectura anterior (con manejo de nulos) desde aapMovilLectura
    SELECT lectura
    INTO v_lectura_anterior
    FROM aapMovilLectura
    WHERE cuenta = p_numcuenta
    ORDER BY id DESC
    LIMIT 1;

    -- Calcular consumo SOLO si hay lectura anterior y es un valor numérico
    IF v_lectura_anterior IS NOT NULL AND v_lectura_anterior ~ '^[0-9]+$' THEN
        v_consumo := p_lectura::INTEGER - v_lectura_anterior::INTEGER;
    END IF;

   -- Verificar si ya existe una lectura para el mes y año actual
  IF EXISTS (
    SELECT 1
    FROM aapMovilLectura
    WHERE cuenta = p_numcuenta
      AND EXTRACT(YEAR FROM CURRENT_DATE) = v_anio
      AND EXTRACT(MONTH FROM CURRENT_DATE) = v_mes
  ) THEN
    -- Actualizar la lectura existente (incluyendo coordenadasXYZ)
    UPDATE aapMovilLectura
    SET lectura = p_lectura,
        observacion = p_observacion,
        coordenadasXYZ = p_coordenadasXYZ  -- Actualizar las coordenadas
    WHERE cuenta = p_numcuenta
      AND EXTRACT(YEAR FROM CURRENT_DATE) = v_anio
      AND EXTRACT(MONTH FROM CURRENT_DATE) = v_mes;
  ELSE
    -- Insertar una nueva lectura (incluyendo coordenadasXYZ)
    INSERT INTO aapMovilLectura (cuenta, medidor, clave, abonado, lectura, observacion, coordenadasXYZ)
    SELECT p_numcuenta, p_no_medidor, p_clave, abonado, p_lectura, p_observacion, p_coordenadasXYZ 
    FROM aapMovilLectura
    WHERE cuenta = p_numcuenta
    ORDER BY id DESC
    LIMIT 1;
  END IF;
END;
$$;