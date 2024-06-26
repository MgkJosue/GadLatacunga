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

class Lectura(BaseModel):
    numcuenta: str
    no_medidor: str
    clave: str
    lectura: str
    observacion: str
    coordenadas: str

class Token(BaseModel):
    access_token: str
    token_type: str
    user_id: int


class AsignarRuta(BaseModel):
    ruta_id: int
    usuario_id: int