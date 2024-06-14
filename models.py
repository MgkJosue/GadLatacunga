from pydantic import BaseModel

# Modelo para los parámetros del procedimiento SincronizarLecturas
class Lectura(BaseModel):
    numcuenta: str
    no_medidor: str
    clave: str
    ruta: str
    lectura: int
    observacion: str
    login: str
    coordenadasxyz:str

# Modelo para los parámetros de la función validar_usuario
class Usuario(BaseModel):
    nombre_usuario: str
    contrasena: str


# Modelo para el resultado de la función UsuarioRuta
class UsuarioRutaOutput(BaseModel):
    idruta: int
    nombreruta: str

# Modelo para el resultado de la función RutaLecturaMovil
class RutaLecturaMovilOutput(BaseModel):
    numcuenta: str
    no_medidor: str
    clave: str
    ruta: str
    abonado: str
