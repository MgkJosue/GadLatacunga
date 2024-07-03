from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from database import database
from typing import List
from models import Lectura
from routers.auth import get_current_user
import base64

router = APIRouter()

@router.post("/sincronizar_lecturas/{usuario_id}")
async def sincronizar_lecturas(usuario_id: int, lecturas: List[Lectura], current_user: dict = Depends(get_current_user)):
    try:
        formatted_lecturas = []
        for lectura in lecturas:
            motivo = f"'{lectura.motivo}'" if lectura.motivo is not None else 'NULL'
            imagen = f"decode('{base64.b64encode(lectura.imagen).decode('utf-8')}', 'base64')" if lectura.imagen is not None else 'NULL'
            
            formatted_lecturas.append(
                f"ROW('{lectura.numcuenta}', '{lectura.no_medidor}', '{lectura.clave}', '{lectura.lectura}', "
                f"'{lectura.observacion}', '{lectura.coordenadas}', {motivo}, {imagen})::tipo_lectura"
            )
        
        query = text(f"""
        DO $$
        DECLARE
            lecturas tipo_lectura[];
        BEGIN
            lecturas := ARRAY[{", ".join(formatted_lecturas)}];
            CALL SincronizarLecturasMasivas({usuario_id}, lecturas);
        END $$;
        """)

        await database.execute(query)
        return {"mensaje": "Lecturas sincronizadas exitosamente"}
    except SQLAlchemyError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error en la base de datos"
        ) from e