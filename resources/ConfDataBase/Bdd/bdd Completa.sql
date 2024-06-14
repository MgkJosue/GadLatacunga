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
    ruta VARCHAR(255) UNIQUE NOT NULL,
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
    login VARCHAR(255) NOT NULL,
    estado VARCHAR(1) NOT NULL,
    valor FLOAT8 NOT NULL,
    fechalectura TIMESTAMP NOT NULL,
    num_emi INTEGER NOT NULL,
    fecha_emi TIMESTAMP NOT NULL,
    fecha_valor TIMESTAMP NOT NULL,
    cam_med INTEGER NOT NULL,
    pago_anterior FLOAT8 NOT NULL,
    consumocalculo INTEGER NOT NULL,
    consumo_cabildo INTEGER NOT NULL,
    consumomedidor INTEGER NOT NULL,
    consumo_0 INTEGER NOT NULL,
    lect_0 FLOAT8,
    nromedidor VARCHAR(255),
    ciu INTEGER NOT NULL, 
    tarifa INTEGER NOT NULL,
    alcant_lect VARCHAR(255) NOT NULL,
    ruta_lect INTEGER NOT NULL,
    novedad INTEGER NOT NULL,
    valor_alcant FLOAT8 NOT NULL,
    valor_msap FLOAT8 NOT NULL,
    valor_sta FLOAT8 NOT NULL
);

CREATE TABLE aapMovilLectura (
    id SERIAL PRIMARY KEY,
    cuenta VARCHAR(20),
    medidor VARCHAR(20),
    clave VARCHAR(20),
    abonado VARCHAR(100),
    lectura VARCHAR(10),
    observacion TEXT,
    coordenadasXYZ VARCHAR(50)  -- Almacenamos las coordenadas XYZ en un solo campo
);
