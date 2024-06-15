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


