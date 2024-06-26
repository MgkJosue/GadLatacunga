from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy import text, bindparam
from sqlalchemy.exc import SQLAlchemyError
from database import database
from typing import List
from models import Lectura
from routers.auth import get_current_user


router = APIRouter()


@router.post("/sincronizar_lecturas/{usuario_id}")
async def sincronizar_lecturas(usuario_id: int, lecturas: List[Lectura], current_user: dict = Depends(get_current_user)):
    try:
        # Formatea las lecturas en un formato adecuado para la llamada SQL
        formatted_lecturas = ", ".join(
            f"ROW('{lectura.numcuenta}', '{lectura.no_medidor}', '{lectura.clave}', '{lectura.lectura}', '{lectura.observacion}', '{lectura.coordenadas}')::tipo_lectura"
            for lectura in lecturas
        )
        
        query = text(f"""
        DO $$
        DECLARE
            lecturas tipo_lectura[];
        BEGIN
            lecturas := ARRAY[{formatted_lecturas}];
            CALL SincronizarLecturasMasivas({usuario_id}, lecturas);
        END $$;
        """)
        
        await database.execute(query)
        return {"mensaje": "Lecturas sincronizadas exitosamente"}
    except SQLAlchemyError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error en la base de datos"
        ) from e