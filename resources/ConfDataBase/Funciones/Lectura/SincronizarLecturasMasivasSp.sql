-- Eliminar el tipo compuesto si ya existe
DROP TYPE IF EXISTS tipo_lectura;

-- Crear el tipo compuesto tipo_lectura con las nuevas columnas
CREATE TYPE tipo_lectura AS (
    numcuenta VARCHAR(255),
    no_medidor VARCHAR(255),
    clave VARCHAR(255),
    lectura VARCHAR(10),
    observacion TEXT,
    coordenadasXYZ TEXT,
    motivo TEXT,   -- Nueva columna para motivo
    imagen BYTEA   -- Nueva columna para imagen
);

-- Modificar el procedimiento almacenado SincronizarLecturasMasivas
CREATE OR REPLACE PROCEDURE SincronizarLecturasMasivas(
    p_idusuario INTEGER,
    p_lecturas tipo_lectura[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_lectura tipo_lectura;
    v_anio INTEGER;
    v_mes INTEGER;
    v_lectura_anterior VARCHAR(10);
    v_consumo INTEGER;
    v_abonado VARCHAR(255);
    v_direccion VARCHAR(255);
    v_ruta VARCHAR(255);
BEGIN
    -- Obtener año y mes actuales
    SELECT EXTRACT(YEAR FROM NOW()), EXTRACT(MONTH FROM NOW())
    INTO v_anio, v_mes;

    -- Loop a través del array de lecturas
    FOREACH v_lectura IN ARRAY p_lecturas
    LOOP
        -- Obtener la ruta de la cuenta y verificar si está asignada al usuario
        SELECT a.ruta
        INTO v_ruta
        FROM acometidas a
        INNER JOIN aapplectorruta apl ON a.ruta = (SELECT nombreruta FROM aappruta WHERE id = apl.idruta)
        WHERE apl.idusuario = p_idusuario AND a.numcuenta = v_lectura.numcuenta
        LIMIT 1;
        
        -- Si no se encuentra la ruta o no está asignada al usuario, saltar a la siguiente iteración
        IF v_ruta IS NULL THEN
            CONTINUE;
        END IF;

        -- Obtener la lectura anterior y otros datos (con manejo de nulos) desde aapMovilLectura
        SELECT lectura, abonado, direccion
        INTO v_lectura_anterior, v_abonado, v_direccion
        FROM aapMovilLectura
        WHERE cuenta = v_lectura.numcuenta
        ORDER BY id DESC
        LIMIT 1;

        -- Calcular consumo SOLO si hay lectura anterior y es un valor numérico
        IF v_lectura_anterior IS NOT NULL AND v_lectura_anterior ~ '^[0-9]+$' THEN
            v_consumo := v_lectura.lectura::INTEGER - v_lectura_anterior::INTEGER;
        ELSE
            v_consumo := 0;
        END IF;

        -- Verificar si ya existe una lectura para el mes y año actual
        IF EXISTS (
            SELECT 1
            FROM aapMovilLectura
            WHERE cuenta = v_lectura.numcuenta
              AND EXTRACT(YEAR FROM CURRENT_DATE) = v_anio
              AND EXTRACT(MONTH FROM CURRENT_DATE) = v_mes
        ) THEN
            -- Actualizar la lectura existente (sin cambiar la dirección)
            UPDATE aapMovilLectura
            SET lectura = v_lectura.lectura,
                observacion = v_lectura.observacion,
                coordenadasXYZ = v_lectura.coordenadasXYZ,
                motivo = COALESCE(v_lectura.motivo, motivo),
                imagen = COALESCE(v_lectura.imagen, imagen)
            WHERE cuenta = v_lectura.numcuenta
              AND EXTRACT(YEAR FROM CURRENT_DATE) = v_anio
              AND EXTRACT(MONTH FROM CURRENT_DATE) = v_mes;
        ELSE
            -- Insertar una nueva lectura (manteniendo la dirección y abonado)
            INSERT INTO aapMovilLectura (cuenta, medidor, clave, abonado, lectura, observacion, coordenadasXYZ, direccion, motivo, imagen)
            VALUES (v_lectura.numcuenta, v_lectura.no_medidor, v_lectura.clave, v_abonado, v_lectura.lectura, v_lectura.observacion, v_lectura.coordenadasXYZ, v_direccion, v_lectura.motivo, v_lectura.imagen);
        END IF;
    END LOOP;
END;
$$;
