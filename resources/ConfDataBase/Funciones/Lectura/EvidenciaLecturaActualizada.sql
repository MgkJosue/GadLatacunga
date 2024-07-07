CREATE OR REPLACE FUNCTION copiar_registros_a_evidencia()
RETURNS VOID AS $$
BEGIN
    INSERT INTO aapEvidencia (cuenta, medidor, clave, abonado, lectura, observacion, coordenadasXYZ, direccion, motivo, imagen)
    SELECT cuenta, medidor, clave, abonado, lectura, observacion, coordenadasXYZ, direccion, motivo, imagen
    FROM aapMovilLectura
    WHERE motivo IS NOT NULL OR imagen IS NOT NULL
    ON CONFLICT (cuenta, medidor)
    DO UPDATE SET
        clave = EXCLUDED.clave,
        abonado = EXCLUDED.abonado,
        lectura = EXCLUDED.lectura,
        observacion = EXCLUDED.observacion,
        coordenadasXYZ = EXCLUDED.coordenadasXYZ,
        direccion = EXCLUDED.direccion,
        motivo = EXCLUDED.motivo,
        imagen = EXCLUDED.imagen;
END;
$$ LANGUAGE plpgsql;
