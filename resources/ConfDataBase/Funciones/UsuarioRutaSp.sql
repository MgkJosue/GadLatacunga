CREATE OR REPLACE FUNCTION UsuarioRuta(p_idusuario INTEGER)
RETURNS TABLE (
  nombre_ruta VARCHAR(255),
  nombre_usuario VARCHAR(255),
  id_usuario INTEGER,
  id_ruta INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ap.nombreruta AS nombre_ruta, 
    usu.nombre_usuario AS nombre_usuario, 
    apl.idusuario AS id_usuario, 
    apl.idruta AS id_ruta
  FROM aapplectorruta apl 
  INNER JOIN aappruta ap ON apl.idruta = ap.id
  INNER JOIN usuarios usu ON apl.idusuario = usu.id
  WHERE apl.idusuario = p_idusuario;
END;
$$ LANGUAGE plpgsql;
