from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy import text, bindparam
from sqlalchemy.exc import SQLAlchemyError
from database import database
from models import RutaLecturaMovilResult
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


#SEGURIDAD AUN NO IMPLEMENTADA
@router.get("/obtenerRutas/")
async def obtener_rutas():
    try:
        query = text("SELECT * FROM ObtenerRutas()")
        result = await database.fetch_all(query)
        return result
    except SQLAlchemyError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error en la base de datos"
        ) from e

@router.post("/asignarRuta/")
async def asignar_ruta_a_usuario(ruta_id: int, usuario_id: int):
    try:
        query = text("CALL AsignarRutaAUsuario(:ruta_id, :usuario_id)").bindparams(
            bindparam("ruta_id", ruta_id),
            bindparam("usuario_id", usuario_id)
        )
        await database.execute(query)
        return {"mensaje": "Ruta asignada exitosamente"}
    except SQLAlchemyError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error en la base de datos"
        ) from e

@router.delete("/eliminarAsignacion/")
async def eliminar_asignacion_de_ruta(ruta_id: int, usuario_id: int):
    try:
        query = text("CALL EliminarAsignacionDeRuta(:ruta_id, :usuario_id)").bindparams(
            bindparam("ruta_id", ruta_id),
            bindparam("usuario_id", usuario_id)
        )
        await database.execute(query)
        return {"mensaje": "Asignación eliminada exitosamente"}
    except SQLAlchemyError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error en la base de datos"
        ) from e
