from pydantic import BaseModel

class LoginCredentials(BaseModel):
    nombre_usuario: str
    contrasena: str

class UsuarioRutaResult(BaseModel):
    nombre_ruta: str
    nombre_usuario: str
    id_usuario: int
    id_ruta: int

class RutaLecturaMovilResult(BaseModel):
    id_usuario: int
    id_ruta: int
    numcuenta: str
    no_medidor: str
    clave: str
    ruta: str
    direccion: str
    abonado: str
