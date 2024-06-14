from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.responses import JSONResponse
import sqlalchemy
from sqlalchemy import text, exc
from sqlalchemy.orm import Session
from typing import List
from database import database, engine
from models import Lectura, Usuario, UsuarioRutaOutput, RutaLecturaMovilOutput

app = FastAPI()

# Dependencia para conectar a la base de datos
async def get_db():
    async with database:
        yield database

# Endpoint para validar_usuario
@app.post("/usuarios/validar/")
async def validar_usuario(usuario: Usuario, db: Session = Depends(get_db)):
    # Consulta SQL con parámetros
    query = sqlalchemy.text("SELECT validar_usuario(:p_nombre_usuario, :p_contrasena)")

    # Parametros en un diccionario
    values = {"p_nombre_usuario": usuario.nombre_usuario, "p_contrasena": usuario.contrasena}

    # Usar bindparam para pasar los parámetros de forma segura
    result = await db.fetch_val(query.bindparams(**values))

    if result:
        return {"message": "Usuario válido"}
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Credenciales inválidas")


# Endpoint para UsuarioRuta (modificado a GET)
@app.get("/usuarios/{idusuario}/rutas/", response_model=List[UsuarioRutaOutput])
async def usuario_ruta(idusuario: int, db: Session = Depends(get_db)):
    rows = await db.fetch_all(
        text("SELECT * FROM UsuarioRuta(:idusuario)").bindparams(idusuario=idusuario)  # Usar bindparams() aquí
    )
    return [UsuarioRutaOutput(**row) for row in rows]

# Endpoint para RutaLecturaMovil (modificado a GET)
@app.get("/rutas/{idruta}/lecturas/", response_model=List[RutaLecturaMovilOutput])
async def ruta_lectura_movil(idruta: int, db: Session = Depends(get_db)):
    rows = await db.fetch_all(
        text("SELECT * FROM RutaLecturaMovil(:idruta)").bindparams(idruta=idruta)   # Usar bindparams() aquí
    )
    return [RutaLecturaMovilOutput(**row) for row in rows]


#Endpoint para SincronizarLecturas (modificado a PUT)
@app.put("/sincronizarLecturas/", status_code=status.HTTP_200_OK)
async def sincronizar_lectura(lectura: Lectura, db: Session = Depends(get_db)):
    try:
        await db.execute(
            text(
                """CALL SincronizarLecturas(:numcuenta, :no_medidor, :clave, :ruta, :lectura, :observacion, :login, :coordenadasxyz)"""
            ).bindparams(  # Usar bindparams() aquí
                numcuenta=lectura.numcuenta,
                no_medidor=lectura.no_medidor,
                clave=lectura.clave,
                ruta=lectura.ruta,
                lectura=str(lectura.lectura),  
                observacion=lectura.observacion,
                login=lectura.login,
                coordenadasxyz= lectura.coordenadasxyz
            )
        )
        return {"message": "Lectura sincronizada"}
    except exc.DatabaseError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error en la base de datos: {e}",
        )
