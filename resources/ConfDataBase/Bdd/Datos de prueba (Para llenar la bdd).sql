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
('67890', 'M67890', 'CLAVE678', 'Ruta Norte', 'Avenida Central 456'),
('54321', 'M54321', 'CLAVE543', 'Ruta Sur', 'Calle Secundaria 789'),
('98765', 'M98765', 'CLAVE987', 'Ruta Sur', 'Avenida Libertad 101'),
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


INSERT INTO aapplectura (id, numcuenta, anio, mes, lectura, observacion, lecturaanterior, consumo, nromedidor, ciu) VALUES
(1, '12345', 2024, 1, 200, 'Sin observaciones', 190, 10, 'M12345', 1),
(2, '12345', 2024, 2, 210, 'Sin observaciones', 200, 10, 'M12345', 1),
(3, '12345', 2024, 3, 220, 'Sin observaciones', 210, 10, 'M12345', 1),
(4, '67890', 2024, 1, 500, 'Sin observaciones', 490, 10, 'M67890', 2),
(5, '67890', 2024, 2, 510, 'Sin observaciones', 500, 10, 'M67890', 2),
(6, '24680', 2024, 1, 400, 'Sin observaciones', 390, 10, 'M24680', 3),
(7, '24680', 2024, 2, 410, 'Sin observaciones', 400, 10, 'M24680', 3);
(8, '54321', 2024, 1, 150, 'Sin observaciones', 140, 10, 'M54321', 3),
(9, '54321', 2024, 2, 160, 'Sin observaciones', 150, 10, 'M54321', 3),
(10, '98765', 2024, 1, 300, 'Sin observaciones', 290, 10, 'M98765', 4),
(11, '98765', 2024, 2, 310, 'Sin observaciones', 300, 10, 'M98765', 4),
(12, '13579', 2024, 1, 250, 'Sin observaciones', 240, 10, 'M13579', 6),
(13, '13579', 2024, 2, 260, 'Sin observaciones', 250, 10, 'M13579', 6);