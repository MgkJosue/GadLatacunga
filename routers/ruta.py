from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy import text, bindparam
from sqlalchemy.exc import SQLAlchemyError
from database import database
from models import RutaLecturaMovilResult, AsignarRuta
from routers.auth import get_current_user

router = APIRouter()

@router.get("/ruta_lectura/{usuario_id}", response_model=list[RutaLecturaMovilResult])
async def obtener_ruta_lectura(usuario_id: int, current_user: dict = Depends(get_current_user)):
    try:
        query = text("SELECT * FROM RutaLecturaMovil(:usuario_id)").bindparams(
            bindparam("usuario_id", usuario_id)
        )
        result = await database.fetch_all(query)
        if not result:
            raise HTTPException(status_code=404, detail="No se encontraron lecturas para este usuario")
        return result
    except SQLAlchemyError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error en la base de datos"
        ) from e 


@router.get("/obtenerRutas/")
async def obtener_rutas(current_user: dict = Depends(get_current_user)):
    try:
        query = text("SELECT * FROM ObtenerRutas()")
        result = await database.fetch_all(query)
        return result
    except SQLAlchemyError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error en la base de datos"
        ) from e

@router.post("/asignarRuta/")
async def asignar_ruta_a_usuario(asignacion: AsignarRuta, current_user: dict = Depends(get_current_user)):
    try:
        query = text("""
            SELECT AsignarRutaAUsuario(:usuario_id, :ruta_id) AS mensaje;
        """).bindparams(
            bindparam("ruta_id", asignacion.ruta_id),
            bindparam("usuario_id", asignacion.usuario_id)
        )
        
        result = await database.fetch_one(query)
        
        if result:
            return {"mensaje": result["mensaje"]}
        else:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error al asignar la ruta"
            )

    except SQLAlchemyError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error en la base de datos"
        ) from e
    
@router.get("/lectorruta")
async def obtener_lectorruta(current_user: dict = Depends(get_current_user)):
    query = "SELECT * FROM obtener_datos_lectorruta();"
    results = await database.fetch_all(query)
    return results

@router.delete("/lectorruta/{id}")
async def eliminar_lectorruta(id: int, current_user: dict = Depends(get_current_user)):
    try:
        query = f"SELECT eliminar_lectorruta({id});"
        await database.execute(query)
        return {"message": f"Lectorruta con ID {id} eliminada"}
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))