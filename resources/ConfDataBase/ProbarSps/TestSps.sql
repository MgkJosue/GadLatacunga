--Probar sp Validar_usuario
SELECT validar_usuario('usuario1', 'contrasena1');

--Probar sp UsuarioRutaSp
-- Obtener la ruta asignada a ese id del usuario 
SELECT * FROM UsuarioRuta(1); 

--Probar SpRutaLecturaMovilz
-- Obtener informacion de acometidas relacionadas con id del usuario
SELECT * FROM RutaLecturaMovil(1);

--Probar spSincronizarLecturas
CALL SincronizarLecturas(
  '12345', 'MEDIDOR123', 'CLAVE123', 'RUTA1', '500', 'Observación de prueba', 'usuario1', '-78.5243, -0.2293, 1234' 
);
