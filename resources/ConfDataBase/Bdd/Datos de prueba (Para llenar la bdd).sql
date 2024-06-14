--Datos quemados de prueba

INSERT INTO usuarios (nombre_usuario, contrasena) VALUES
('usuario1', 'contrasena1'),
('usuario2', 'contrasena2');

INSERT INTO aappruta (nombreruta) VALUES
('Ruta Norte'),
('Ruta Sur'),
('Ruta Este'),
('Ruta Oeste'),
('Ruta Centro'),
('Ruta Periférica');

INSERT INTO ciudadano (nombreCompleto) VALUES
('Juan Pérez'),
('María Gómez'),
('Carlos Rodríguez'),
('Ana López'),
('Luis Martínez'),
('Laura Sánchez');

INSERT INTO acometidas (numcuenta, no_medidor, clave, ruta, direccion) VALUES
('12345', 'M12345', 'CLAVE123', 'Ruta Norte', 'Calle Principal 123'),
('67890', 'M67890', 'CLAVE678', 'Ruta Sur', 'Avenida Central 456'),
('54321', 'M54321', 'CLAVE543', 'Ruta Este', 'Calle Secundaria 789'),
('98765', 'M98765', 'CLAVE987', 'Ruta Oeste', 'Avenida Libertad 101'),
('24680', 'M24680', 'CLAVE246', 'Ruta Centro', 'Plaza Mayor 222'),
('13579', 'M13579', 'CLAVE135', 'Ruta Periférica', 'Calle Rural 333');

INSERT INTO aapplectorruta (idusuario, idruta) VALUES
(1, 1), -- Lector 1 asignado a Ruta Norte
(1, 3), -- Lector 1 asignado a Ruta Este
(2, 2), -- Lector 2 asignado a Ruta Sur
(2, 4), -- Lector 2 asignado a Ruta Oeste
(1, 5),
(2, 6);


INSERT INTO aapMovilLectura (cuenta, medidor, clave, abonado, lectura, observacion, coordenadasXYZ) VALUES
('12345', 'M12345', 'CLAVE123', 'Juan Pérez', '1234', 'Sin novedad', '-0.945758,-78.619934,2850'),
('67890', 'M67890', 'CLAVE678', 'María Gómez', '5678', 'Fuga detectada', '-0.945758,-78.619934,2850'),
('54321', 'M54321', 'CLAVE543', 'Carlos Rodríguez', '9012', 'Sin novedad', '-0.945758,-78.619934,2850'),
('98765', 'M98765', 'CLAVE987', 'Ana López', '3456', 'Medidor dañado', '-0.945758,-78.619934,2850'),
('24680', 'M24680', 'CLAVE246', 'Luis Martínez', '7890', 'Sin novedad', '-0.945758,-78.619934,2850'),
('13579', 'M13579', 'CLAVE135', 'Laura Sánchez', '2345', 'Sin novedad', '-0.945758,-78.619934,2850');



