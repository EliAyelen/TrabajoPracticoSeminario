IF DB_ID('sakila') IS NOT NULL
BEGIN
    ALTER DATABASE sakila SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE sakila;
END
GO

CREATE DATABASE sakila;
GO

USE sakila;
GO

CREATE TABLE pais (
    id_pais             SMALLINT        NOT NULL IDENTITY(1,1),
    pais                NVARCHAR(50)    NOT NULL,
    ultima_actualizacion DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_pais PRIMARY KEY (id_pais)
);
GO

CREATE TABLE ciudad (
    id_ciudad           INT             NOT NULL IDENTITY(1,1),
    ciudad              NVARCHAR(50)    NOT NULL,
    id_pais             SMALLINT        NOT NULL,
    ultima_actualizacion DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_ciudad PRIMARY KEY (id_ciudad),
    CONSTRAINT fk_ciudad_pais FOREIGN KEY (id_pais)
        REFERENCES pais (id_pais) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_ciudad_pais ON ciudad (id_pais);
GO

CREATE TABLE direccion (
    id_direccion        INT             NOT NULL IDENTITY(1,1),
    direccion           NVARCHAR(50)    NOT NULL,
    direccion2          NVARCHAR(50)    NULL,
    distrito            NVARCHAR(20)    NOT NULL,
    id_ciudad           INT             NOT NULL,
    codigo_postal       NVARCHAR(10)    NULL,
    telefono            NVARCHAR(20)    NOT NULL,
    ultima_actualizacion DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_direccion PRIMARY KEY (id_direccion),
    CONSTRAINT fk_direccion_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES ciudad (id_ciudad) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_direccion_ciudad ON direccion (id_ciudad);
GO

CREATE TABLE categoria (
    id_categoria        TINYINT         NOT NULL IDENTITY(1,1),
    nombre              NVARCHAR(25)    NOT NULL,
    ultima_actualizacion DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria)
);
GO

CREATE TABLE idioma (
    id_idioma           TINYINT         NOT NULL IDENTITY(1,1),
    nombre              NCHAR(20)       NOT NULL,
    ultima_actualizacion DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_idioma PRIMARY KEY (id_idioma)
);
GO

CREATE TABLE actor (
    id_actor            INT             NOT NULL IDENTITY(1,1),
    nombre              NVARCHAR(45)    NOT NULL,
    apellido            NVARCHAR(45)    NOT NULL,
    ultima_actualizacion DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_actor PRIMARY KEY (id_actor)
);
GO
CREATE INDEX idx_actor_apellido ON actor (apellido);
GO

CREATE TABLE tienda (
    id_tienda               TINYINT     NOT NULL IDENTITY(1,1),
    id_empleado_gerente     INT         NOT NULL,
    id_direccion            INT         NOT NULL,
    ultima_actualizacion    DATETIME    NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_tienda PRIMARY KEY (id_tienda),
    CONSTRAINT uq_tienda_gerente UNIQUE (id_empleado_gerente),
    CONSTRAINT fk_tienda_direccion FOREIGN KEY (id_direccion)
        REFERENCES direccion (id_direccion) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_tienda_direccion ON tienda (id_direccion);
GO

CREATE TABLE empleado (
    id_empleado         INT             NOT NULL IDENTITY(1,1),
    nombre              NVARCHAR(45)    NOT NULL,
    apellido            NVARCHAR(45)    NOT NULL,
    id_direccion        INT             NOT NULL,
    foto                VARBINARY(MAX)  NULL,
    email               NVARCHAR(50)    NULL,
    id_tienda           TINYINT         NOT NULL,
    activo              BIT             NOT NULL DEFAULT 1,
    usuario             NVARCHAR(16)    NOT NULL,
    contrasena          NVARCHAR(40)    NULL,
    ultima_actualizacion DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_empleado PRIMARY KEY (id_empleado),
    CONSTRAINT fk_empleado_direccion FOREIGN KEY (id_direccion)
        REFERENCES direccion (id_direccion) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_empleado_tienda FOREIGN KEY (id_tienda)
        REFERENCES tienda (id_tienda) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_empleado_direccion ON empleado (id_direccion);
CREATE INDEX idx_fk_empleado_tienda ON empleado (id_tienda);
GO

ALTER TABLE tienda
    ADD CONSTRAINT fk_tienda_empleado FOREIGN KEY (id_empleado_gerente)
        REFERENCES empleado (id_empleado) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO

CREATE TABLE cliente (
    id_cliente          INT             NOT NULL IDENTITY(1,1),
    id_tienda           TINYINT         NOT NULL,
    nombre              NVARCHAR(45)    NOT NULL,
    apellido            NVARCHAR(45)    NOT NULL,
    email               NVARCHAR(50)    NULL,
    id_direccion        INT             NOT NULL,
    activo              BIT             NOT NULL DEFAULT 1,
    fecha_alta          DATETIME        NOT NULL,
    ultima_actualizacion DATETIME       NULL DEFAULT GETDATE(),
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT fk_cliente_direccion FOREIGN KEY (id_direccion)
        REFERENCES direccion (id_direccion) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_cliente_tienda FOREIGN KEY (id_tienda)
        REFERENCES tienda (id_tienda) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_cliente_direccion ON cliente (id_direccion);
CREATE INDEX idx_fk_cliente_tienda ON cliente (id_tienda);
CREATE INDEX idx_cliente_apellido ON cliente (apellido);
GO

CREATE TABLE pelicula (
    id_pelicula             INT             NOT NULL IDENTITY(1,1),
    titulo                  NVARCHAR(128)   NOT NULL,
    descripcion             NVARCHAR(MAX)   NULL,
    anio_estreno            SMALLINT        NULL,
    id_idioma               TINYINT         NOT NULL,
    id_idioma_original      TINYINT         NULL,
    duracion_alquiler       TINYINT         NOT NULL DEFAULT 3,
    tarifa_alquiler         DECIMAL(4,2)    NOT NULL DEFAULT 4.99,
    duracion_minutos        SMALLINT        NULL,
    costo_reposicion        DECIMAL(5,2)    NOT NULL DEFAULT 19.99,
    clasificacion           NVARCHAR(10)    NULL DEFAULT 'G',
    caracteristicas_especiales NVARCHAR(200) NULL,
    ultima_actualizacion    DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_pelicula PRIMARY KEY (id_pelicula),
    CONSTRAINT ck_pelicula_clasificacion CHECK (clasificacion IN ('G','PG','PG-13','R','NC-17')),
    CONSTRAINT fk_pelicula_idioma FOREIGN KEY (id_idioma)
        REFERENCES idioma (id_idioma) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_pelicula_idioma_original FOREIGN KEY (id_idioma_original)
        REFERENCES idioma (id_idioma) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_pelicula_titulo ON pelicula (titulo);
CREATE INDEX idx_fk_pelicula_idioma ON pelicula (id_idioma);
CREATE INDEX idx_fk_pelicula_idioma_original ON pelicula (id_idioma_original);
GO

CREATE TABLE pelicula_actor (
    id_actor            INT         NOT NULL,
    id_pelicula         INT         NOT NULL,
    ultima_actualizacion DATETIME   NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_pelicula_actor PRIMARY KEY (id_actor, id_pelicula),
    CONSTRAINT fk_pelicula_actor_actor FOREIGN KEY (id_actor)
        REFERENCES actor (id_actor) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_pelicula_actor_pelicula FOREIGN KEY (id_pelicula)
        REFERENCES pelicula (id_pelicula) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_pelicula_actor_pelicula ON pelicula_actor (id_pelicula);
GO

CREATE TABLE pelicula_categoria (
    id_pelicula         INT         NOT NULL,
    id_categoria        TINYINT     NOT NULL,
    ultima_actualizacion DATETIME   NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_pelicula_categoria PRIMARY KEY (id_pelicula, id_categoria),
    CONSTRAINT fk_pelicula_categoria_pelicula FOREIGN KEY (id_pelicula)
        REFERENCES pelicula (id_pelicula) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_pelicula_categoria_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

CREATE TABLE inventario (
    id_inventario       INT         NOT NULL IDENTITY(1,1),
    id_pelicula         INT         NOT NULL,
    id_tienda           TINYINT     NOT NULL,
    ultima_actualizacion DATETIME   NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_inventario PRIMARY KEY (id_inventario),
    CONSTRAINT fk_inventario_tienda FOREIGN KEY (id_tienda)
        REFERENCES tienda (id_tienda) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_inventario_pelicula FOREIGN KEY (id_pelicula)
        REFERENCES pelicula (id_pelicula) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_inventario_pelicula ON inventario (id_pelicula);
CREATE INDEX idx_inventario_tienda_pelicula ON inventario (id_tienda, id_pelicula);
GO

CREATE TABLE alquiler (
    id_alquiler         INT         NOT NULL IDENTITY(1,1),
    fecha_alquiler      DATETIME    NOT NULL,
    id_inventario       INT         NOT NULL,
    id_cliente          INT         NOT NULL,
    fecha_devolucion    DATETIME    NULL,
    id_empleado         INT         NOT NULL,
    ultima_actualizacion DATETIME   NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_alquiler PRIMARY KEY (id_alquiler),
    CONSTRAINT uq_alquiler UNIQUE (fecha_alquiler, id_inventario, id_cliente),
    CONSTRAINT fk_alquiler_empleado FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_empleado) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_alquiler_inventario FOREIGN KEY (id_inventario)
        REFERENCES inventario (id_inventario) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_alquiler_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_alquiler_inventario ON alquiler (id_inventario);
CREATE INDEX idx_fk_alquiler_cliente ON alquiler (id_cliente);
CREATE INDEX idx_fk_alquiler_empleado ON alquiler (id_empleado);
GO

CREATE TABLE pago (
    id_pago             INT             NOT NULL IDENTITY(1,1),
    id_cliente          INT             NOT NULL,
    id_empleado         INT             NOT NULL,
    id_alquiler         INT             NULL,
    monto               DECIMAL(5,2)    NOT NULL,
    fecha_pago          DATETIME        NOT NULL,
    ultima_actualizacion DATETIME       NULL DEFAULT GETDATE(),
    CONSTRAINT pk_pago PRIMARY KEY (id_pago),
    CONSTRAINT fk_pago_alquiler FOREIGN KEY (id_alquiler)
        REFERENCES alquiler (id_alquiler) ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_pago_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_pago_empleado FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_empleado) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_pago_empleado ON pago (id_empleado);
CREATE INDEX idx_fk_pago_cliente ON pago (id_cliente);
GO
