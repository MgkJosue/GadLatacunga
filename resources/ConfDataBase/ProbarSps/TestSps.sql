--Probar sp Validar_usuario
SELECT validar_usuario('usuario1', 'contrasena1');

--Probar sp UsuarioRutaSp
-- Obtener la ruta asignada a ese id del usuario 
SELECT * FROM UsuarioRuta(1); 

--Probar SpRutaLecturaMovilz
-- Obtener informacion de acometidas relacionadas con id del usuario
SELECT * FROM RutaLecturaMovil(1);

--Probar spSincronizarLecturas
-- Probar SincronizarLecturasMasivas
DO $$
DECLARE
    lecturas tipo_lectura[];
BEGIN
    lecturas := ARRAY[
        ROW('12345', 'M12345', 'CLAVE123', '500', 'Observación de prueba 1', '-78.5243, -0.2293, 1234')::tipo_lectura,
        ROW('67890', 'M67890', 'CLAVE678', '600', 'Observación de prueba 2', '-78.5243, -0.2293, 1234')::tipo_lectura,
        ROW('54321', 'M54321', 'CLAVE543', '700', 'Observación de prueba 3', '-78.5243, -0.2293, 1234')::tipo_lectura
    ];

    CALL SincronizarLecturasMasivas(1, lecturas);
END $$;

--Funcion para obtenerUsuarios
SELECT * FROM ObtenerUsuarios();

--Funcion para obtenerRutas
SELECT * FROM ObtenerRutas();

-- Asignar la ruta con ID 1 al usuario con ID 5
SELECT AsignarRutaAUsuario(1, 4);

-- Eliminar la asignación de la ruta con ID 1 al usuario con ID 2
CALL  EliminarAsignacionDeRuta(1, 2);