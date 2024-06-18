--Validar
SELECT * FROM usuarios WHERE nombre_usuario='usuario1' AND contrasena = 'contrasena1'

--Entregar rutas por el nombre id
SELECT ap.nombreruta as nombre_ruta, usu.nombre_usuario as nombre_usuario, apl.idusuario as id_usuario, apl.idruta as id_ruta  
FROM aapplectorruta apl Inner join aappruta ap on apl.idruta = ap.id  
inner join usuarios usu on apl.idusuario = usu.id
WHERE idusuario = 1 

--Entregar acometidas como en el listado de lecturas
SELECT aco.numcuenta numero_cuenta, aco.no_medidor numero_medidor, aco.clave clave, aco.ruta ruta, aco.direccion direccion,
(SELECT ciud.nombrecompleto FROM aapplectura aplect 
INNER JOIN ciudadano ciud ON  aplect.ciu = ciud.id and aplect.numcuenta = aco.numcuenta 
limit 1
)
as abonado
FROM aapplectorruta apl Inner join aappruta ap on apl.idruta = ap.id  
inner join usuarios usu on apl.idusuario = usu.id
inner join acometidas aco on aco.ruta = ap.nombreruta
WHERE idusuario = 1 

--Sincronizar una lista de lecturas para aapmovillectura PROPUIESTA 
DO $$
DECLARE
    v_anio INTEGER;
    v_mes INTEGER;
BEGIN
    -- Obtener el año y mes actuales
    SELECT EXTRACT(YEAR FROM NOW()), EXTRACT(MONTH FROM NOW())
    INTO v_anio, v_mes;

    -- Actualizar las lecturas existentes para el año y mes actuales
    UPDATE aapMovilLectura ml
    SET lectura = lu.lectura,
        observacion = lu.observacion,
        coordenadasXYZ = lu.coordenadasXYZ
    FROM (
        SELECT 
            l.numcuenta,
            l.no_medidor,
            l.clave,
            l.lectura,
            l.observacion,
            l.coordenadasXYZ,
            r.nombreruta AS ruta
        FROM unnest(ARRAY[
            ROW('12345', 'M12345', 'CLAVE123', '400', 'Observación de prueba 1', '-78.5243, -0.2293, 122334')::tipo_lectura,
            ROW('67890', 'M67890', 'CLAVE678', '300', 'Observación de prueba 2', '-78.5243, -0.2293, 122334')::tipo_lectura,
            ROW('54321', 'M54321', 'CLAVE543', '200', 'Observación de prueba 3', '-78.5243, -0.2293, 123234')::tipo_lectura
        ]) AS l(numcuenta, no_medidor, clave, lectura, observacion, coordenadasXYZ)
        JOIN acometidas a ON a.numcuenta = l.numcuenta
        JOIN aapplectorruta apl ON apl.idusuario = 1 AND apl.idruta = (SELECT id FROM aappruta WHERE nombreruta = a.ruta)
        JOIN aappruta r ON r.id = apl.idruta
    ) AS lu
    WHERE ml.cuenta = lu.numcuenta
      AND EXTRACT(YEAR FROM CURRENT_DATE) = v_anio
      AND EXTRACT(MONTH FROM CURRENT_DATE) = v_mes;

    -- Insertar nuevas lecturas para el año y mes actuales si no existen
    INSERT INTO aapMovilLectura (cuenta, medidor, clave, abonado, lectura, observacion, coordenadasXYZ, direccion)
    SELECT 
        lu.numcuenta,
        lu.no_medidor,
        lu.clave,
        (SELECT ciud.nombrecompleto FROM aapplectura aplect 
         INNER JOIN ciudadano ciud ON aplect.ciu = ciud.id 
         WHERE aplect.numcuenta = lu.numcuenta 
         LIMIT 1) AS abonado,
        lu.lectura,
        lu.observacion,
        lu.coordenadasXYZ,
        a.direccion
    FROM (
        SELECT 
            l.numcuenta,
            l.no_medidor,
            l.clave,
            l.lectura,
            l.observacion,
            l.coordenadasXYZ,
            r.nombreruta AS ruta
        FROM unnest(ARRAY[
            ROW('12345', 'M12345', 'CLAVE123', '500', 'Observación de prueba 1', '-78.5243, -0.2293, 1234')::tipo_lectura,
            ROW('67890', 'M67890', 'CLAVE678', '600', 'Observación de prueba 2', '-78.5243, -0.2293, 1234')::tipo_lectura,
            ROW('54321', 'M54321', 'CLAVE543', '700', 'Observación de prueba 3', '-78.5243, -0.2293, 1234')::tipo_lectura
        ]) AS l(numcuenta, no_medidor, clave, lectura, observacion, coordenadasXYZ)
        JOIN acometidas a ON a.numcuenta = l.numcuenta
        JOIN aapplectorruta apl ON apl.idusuario = 1 AND apl.idruta = (SELECT id FROM aappruta WHERE nombreruta = a.ruta)
        JOIN aappruta r ON r.id = apl.idruta
    ) AS lu
    LEFT JOIN aapMovilLectura ml ON ml.cuenta = lu.numcuenta 
        AND EXTRACT(YEAR FROM CURRENT_DATE) = v_anio
        AND EXTRACT(MONTH FROM CURRENT_DATE) = v_mes
    LEFT JOIN acometidas a ON a.numcuenta = lu.numcuenta
    WHERE ml.cuenta IS NULL;
END $$;
