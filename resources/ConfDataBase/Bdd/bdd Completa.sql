-- Crear la tabla de usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(255) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL
);

-- Crear la tabla de rutas
CREATE TABLE aappruta (
    id SERIAL PRIMARY KEY,
    nombreruta VARCHAR(255) NOT NULL
);

-- Crear la tabla de ciudadanos
CREATE TABLE ciudadano (
    id SERIAL PRIMARY KEY,
    nombreCompleto VARCHAR(255) UNIQUE NOT NULL
);

-- Crear la tabla de acometidas
CREATE TABLE acometidas (
    id SERIAL PRIMARY KEY,
    numcuenta VARCHAR(255) UNIQUE NOT NULL,
    no_medidor VARCHAR(255) UNIQUE NOT NULL,
    clave VARCHAR(255) UNIQUE NOT NULL,
    ruta VARCHAR(255) NOT NULL,
    direccion VARCHAR(255) UNIQUE NOT NULL
);

-- Crear la tabla de asignación de lector a ruta
CREATE TABLE aapplectorruta (
    id SERIAL PRIMARY KEY,
    idusuario INTEGER REFERENCES usuarios(id),
    idruta INTEGER REFERENCES aappruta(id)
);

-- Crear la tabla de lecturas
CREATE TABLE aapplectura (
    id SERIAL PRIMARY KEY,
    numcuenta VARCHAR(255) NOT NULL,
    anio INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    lectura INTEGER NOT NULL,
    observacion TEXT,
    lecturaanterior INTEGER NOT NULL,
    consumo INTEGER NOT NULL,
    nromedidor VARCHAR(255),
    ciu INTEGER NOT NULL
);

-- Crear la tabla aapMovilLectura con las nuevas columnas
CREATE TABLE aapMovilLectura (
    id SERIAL PRIMARY KEY,
    cuenta VARCHAR(20),
    medidor VARCHAR(20),
    clave VARCHAR(20),
    abonado VARCHAR(100),
    lectura VARCHAR(10),
    observacion TEXT,
    coordenadasXYZ VARCHAR(50),
    direccion VARCHAR(255),
    motivo TEXT,
    imagen BYTEA
);

-- Crear la tabla aapEvidencia para la actualización de los datos de la tabla aapMovilLectura
CREATE TABLE aapEvidencia (
    id SERIAL PRIMARY KEY,
    cuenta VARCHAR(20),
    medidor VARCHAR(20),
    clave VARCHAR(20),
    abonado VARCHAR(100),
    lectura VARCHAR(10),
    observacion TEXT,
    coordenadasXYZ VARCHAR(50),
    direccion VARCHAR(255),
    motivo TEXT,
    imagen BYTEA,
    CONSTRAINT unique_cuenta_medidor UNIQUE (cuenta, medidor)
);
