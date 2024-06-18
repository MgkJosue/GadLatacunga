from fastapi import APIRouter, HTTPException, status
from sqlalchemy import text, bindparam
from sqlalchemy.exc import SQLAlchemyError
from database import database
from models import LoginCredentials

router = APIRouter()

@router.post("/login/")
async def login(credentials: LoginCredentials):
    try:
        query = text("SELECT validar_usuario(:nombre_usuario, :contrasena)").bindparams(
            bindparam("nombre_usuario", credentials.nombre_usuario),
            bindparam("contrasena", credentials.contrasena)
        )
        result = await database.fetch_one(query)

        if result is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Credenciales incorrectas"
            )

        is_valid, user_id = result[0]

        if is_valid:
            return {"mensaje": "Inicio de sesión exitoso", "usuario_id": user_id}
        else:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Credenciales incorrectas"
            )
    except SQLAlchemyError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error en la base de datos"
        ) from e
