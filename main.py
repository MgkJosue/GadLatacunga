from fastapi import FastAPI, HTTPException, status,Request
from database import  database
from models import LoginCredentials, UsuarioRutaResult, RutaLecturaMovilResult
from sqlalchemy import text, bindparam
from sqlalchemy.exc import SQLAlchemyError
from fastapi.responses import JSONResponse

app = FastAPI()

@app.on_event("startup")
async def startup():
    await database.connect()


@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()

@app.exception_handler(SQLAlchemyError)
async def sqlalchemy_exception_handler(request: Request, exc: SQLAlchemyError):
    # Manejar excepciones relacionadas con la base de datos (SQLAlchemy)
    error_message = "Error en la base de datos"  
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": error_message},
    )


@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    # Manejar excepciones HTTP estándar de FastAPI (404, 401, etc.)
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail},
    )


@app.post("/login/")
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
        # Captura cualquier error de SQLAlchemy
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error en la base de datos"
        ) from e  # Reenviamos la excepción original para debugging



@app.get("/usuario_ruta/{usuario_id}", response_model=list[UsuarioRutaResult])
async def obtener_ruta_usuario(usuario_id: int):
    try:
        query = text("SELECT * FROM UsuarioRuta(:usuario_id)").bindparams(
            bindparam("usuario_id", usuario_id)
        )
        result = await database.fetch_all(query)
        if not result:
            raise HTTPException(status_code=404, detail="No se encontraron rutas para este usuario")
        return result
    except SQLAlchemyError as e:
        # Captura cualquier error de SQLAlchemy
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error en la base de datos"
        ) from e



@app.get("/ruta_lectura/{usuario_id}", response_model=list[RutaLecturaMovilResult])
async def obtener_ruta_lectura(usuario_id: int):
    try:
        query = text("SELECT * FROM RutaLecturaMovil(:usuario_id)").bindparams(
            bindparam("usuario_id", usuario_id)
        )
        result = await database.fetch_all(query)
        if not result:
            raise HTTPException(status_code=404, detail="No se encontraron lecturas para este usuario")
        return result
    except SQLAlchemyError as e:
        # Captura cualquier error de SQLAlchemy
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error en la base de datos"
        ) from e 
