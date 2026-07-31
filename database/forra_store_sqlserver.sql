-- ============================================================
--  FORRA STORE — Script de Base de Datos
--  Motor: SQL Server 2016+
--  Codificación: NVARCHAR para soporte de acentos y ñ
-- ============================================================

USE master;
GO

-- Crear base de datos si no existe
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ForraStore')
BEGIN
    CREATE DATABASE ForraStore
        COLLATE Modern_Spanish_CI_AI;
END
GO

USE ForraStore;
GO

-- ============================================================
--  0. ELIMINAR OBJETOS EXISTENTES (para re-ejecución limpia)
-- ============================================================

-- Eliminar foreign keys antes de las tablas
IF OBJECT_ID('dbo.detalle_ventas',     'U') IS NOT NULL DROP TABLE dbo.detalle_ventas;
IF OBJECT_ID('dbo.ventas',             'U') IS NOT NULL DROP TABLE dbo.ventas;
IF OBJECT_ID('dbo.precios_especiales', 'U') IS NOT NULL DROP TABLE dbo.precios_especiales;
IF OBJECT_ID('dbo.presentaciones',     'U') IS NOT NULL DROP TABLE dbo.presentaciones;
IF OBJECT_ID('dbo.productos',          'U') IS NOT NULL DROP TABLE dbo.productos;
IF OBJECT_ID('dbo.clientes',           'U') IS NOT NULL DROP TABLE dbo.clientes;
IF OBJECT_ID('dbo.usuarios',           'U') IS NOT NULL DROP TABLE dbo.usuarios;
GO


-- ============================================================
--  1. USUARIOS
--  Trabajadores y administradores del sistema.
-- ============================================================
CREATE TABLE dbo.usuarios (
    id            INT           IDENTITY(1,1)  PRIMARY KEY,
    nombre        NVARCHAR(100) NOT NULL,
    username      NVARCHAR(50)  NOT NULL,
    password_hash NVARCHAR(255) NOT NULL,       -- bcrypt / argon2 hash
    rol           NVARCHAR(20)  NOT NULL        -- 'admin' | 'trabajador'
        CONSTRAINT chk_usuarios_rol CHECK (rol IN ('admin', 'trabajador')),
    activo        BIT           NOT NULL        DEFAULT 1,
    created_at    DATETIME2     NOT NULL        DEFAULT GETDATE(),

    CONSTRAINT uq_usuarios_username UNIQUE (username)
);
GO


-- ============================================================
--  2. PRODUCTOS
--  Catálogo principal. Un producto puede tener N presentaciones.
-- ============================================================
CREATE TABLE dbo.productos (
    id           INT           IDENTITY(1,1)  PRIMARY KEY,
    nombre       NVARCHAR(150) NOT NULL,
    descripcion  NVARCHAR(MAX),
    categoria    NVARCHAR(80),                 -- 'Alimento', 'Accesorios', 'Maquinaria'
    subcategoria NVARCHAR(80),                 -- 'Bovino', 'Aves', 'Equino'
    uso          NVARCHAR(80),                 -- 'Engorda', 'Equipamiento', 'Ordeña'
    imagen_url   NVARCHAR(500),
    activo       BIT           NOT NULL        DEFAULT 1,
    created_at   DATETIME2     NOT NULL        DEFAULT GETDATE()
);
GO


-- ============================================================
--  3. PRESENTACIONES
--  Cada combinación unidad+tamaño tiene su propio precio y stock.
--  Ej: "Maíz" tiene presentaciones "Bulto 50kg a $420" y "Kg suelto a $9".
-- ============================================================
CREATE TABLE dbo.presentaciones (
    id           INT             IDENTITY(1,1)  PRIMARY KEY,
    id_producto  INT             NOT NULL,
    unidad       NVARCHAR(50)    NOT NULL,       -- 'Kg', 'Bulto', 'Pieza ch', 'Litro'
    tamano       DECIMAL(10,2)   NOT NULL,       -- cantidad de la unidad (25, 50, 1...)
    precio       DECIMAL(10,2)   NOT NULL,
    stock        INT             NOT NULL        DEFAULT 0,
    stock_minimo INT             NOT NULL        DEFAULT 5,  -- umbral de alerta
    activo       BIT             NOT NULL        DEFAULT 1,

    CONSTRAINT fk_presentaciones_producto
        FOREIGN KEY (id_producto) REFERENCES dbo.productos(id),

    CONSTRAINT chk_presentaciones_precio
        CHECK (precio >= 0),

    CONSTRAINT chk_presentaciones_stock
        CHECK (stock >= 0),

    CONSTRAINT chk_presentaciones_stock_minimo
        CHECK (stock_minimo >= 0)
);
GO


-- ============================================================
--  4. CLIENTES
--  Compradores recurrentes que pueden tener precios especiales.
-- ============================================================
CREATE TABLE dbo.clientes (
    id         INT           IDENTITY(1,1)  PRIMARY KEY,
    nombre     NVARCHAR(150) NOT NULL,
    telefono   NVARCHAR(20),
    activo     BIT           NOT NULL        DEFAULT 1,
    created_at DATETIME2     NOT NULL        DEFAULT GETDATE()
);
GO


-- ============================================================
--  5. PRECIOS ESPECIALES
--  Precio acordado entre un cliente y una presentación específica.
--  Si no existe registro aquí, se usa el precio de lista de presentaciones.
-- ============================================================
CREATE TABLE dbo.precios_especiales (
    id               INT           IDENTITY(1,1)  PRIMARY KEY,
    id_cliente       INT           NOT NULL,
    id_presentacion  INT           NOT NULL,
    precio_especial  DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_precios_especiales_cliente
        FOREIGN KEY (id_cliente) REFERENCES dbo.clientes(id),

    CONSTRAINT fk_precios_especiales_presentacion
        FOREIGN KEY (id_presentacion) REFERENCES dbo.presentaciones(id),

    -- Un cliente tiene un solo precio especial por presentación
    CONSTRAINT uq_precios_especiales UNIQUE (id_cliente, id_presentacion),

    CONSTRAINT chk_precios_especiales_precio
        CHECK (precio_especial >= 0)
);
GO


-- ============================================================
--  6. VENTAS
--  Cabecera de cada venta. El total se desglosa en original y final
--  para poder calcular el descuento total aplicado.
-- ============================================================
CREATE TABLE dbo.ventas (
    id             INT           IDENTITY(1,1)  PRIMARY KEY,
    id_usuario     INT           NOT NULL,       -- trabajador que realizó la venta
    id_cliente     INT,                          -- NULL = venta al público general
    fecha          DATETIME2     NOT NULL        DEFAULT GETDATE(),
    total_original DECIMAL(10,2) NOT NULL,       -- suma a precios de lista
    descuento      DECIMAL(10,2) NOT NULL        DEFAULT 0,
    total_final    DECIMAL(10,2) NOT NULL,       -- lo que realmente se cobró

    CONSTRAINT fk_ventas_usuario
        FOREIGN KEY (id_usuario) REFERENCES dbo.usuarios(id),

    CONSTRAINT fk_ventas_cliente
        FOREIGN KEY (id_cliente) REFERENCES dbo.clientes(id),

    CONSTRAINT chk_ventas_descuento
        CHECK (descuento >= 0),

    CONSTRAINT chk_ventas_total_final
        CHECK (total_final >= 0)
);
GO


-- ============================================================
--  7. DETALLE_VENTAS
--  Una línea por cada presentación vendida en una venta.
--  Se guarda precio_unitario (lista) y precio_efectivo (cobrado)
--  para mantener trazabilidad histórica aunque los precios cambien.
-- ============================================================
CREATE TABLE dbo.detalle_ventas (
    id               INT           IDENTITY(1,1)  PRIMARY KEY,
    id_venta         INT           NOT NULL,
    id_presentacion  INT           NOT NULL,
    cantidad         INT           NOT NULL,
    precio_unitario  DECIMAL(10,2) NOT NULL,      -- precio de lista al momento de la venta
    precio_efectivo  DECIMAL(10,2) NOT NULL,      -- precio real cobrado (puede ser especial)
    subtotal         DECIMAL(10,2) NOT NULL,      -- precio_efectivo * cantidad

    CONSTRAINT fk_detalle_ventas_venta
        FOREIGN KEY (id_venta) REFERENCES dbo.ventas(id),

    CONSTRAINT fk_detalle_ventas_presentacion
        FOREIGN KEY (id_presentacion) REFERENCES dbo.presentaciones(id),

    CONSTRAINT chk_detalle_ventas_cantidad
        CHECK (cantidad > 0)
);
GO


-- ============================================================
--  8. ÍNDICES DE RENDIMIENTO
-- ============================================================

-- Búsqueda de ventas por fecha (reportes)
CREATE INDEX ix_ventas_fecha
    ON dbo.ventas (fecha DESC);

-- Ventas por trabajador
CREATE INDEX ix_ventas_usuario
    ON dbo.ventas (id_usuario);

-- Ventas por cliente
CREATE INDEX ix_ventas_cliente
    ON dbo.ventas (id_cliente);

-- Detalle por venta
CREATE INDEX ix_detalle_ventas_venta
    ON dbo.detalle_ventas (id_venta);

-- Presentaciones por producto
CREATE INDEX ix_presentaciones_producto
    ON dbo.presentaciones (id_producto);

-- Stock bajo (admin dashboard)
CREATE INDEX ix_presentaciones_stock
    ON dbo.presentaciones (stock, stock_minimo)
    WHERE activo = 1;
GO


-- ============================================================
--  9. VISTAS ÚTILES
-- ============================================================

-- Vista: catálogo completo con presentaciones
CREATE OR ALTER VIEW dbo.vw_catalogo AS
SELECT
    p.id            AS id_producto,
    p.nombre        AS producto,
    p.descripcion,
    p.categoria,
    p.subcategoria,
    p.uso,
    p.imagen_url,
    pr.id           AS id_presentacion,
    pr.unidad,
    pr.tamano,
    pr.precio,
    pr.stock,
    pr.stock_minimo,
    CASE WHEN pr.stock <= pr.stock_minimo THEN 1 ELSE 0 END AS stock_bajo
FROM dbo.productos p
JOIN dbo.presentaciones pr ON p.id = pr.id_producto
WHERE p.activo = 1 AND pr.activo = 1;
GO

-- Vista: ventas con nombre de cliente y trabajador
CREATE OR ALTER VIEW dbo.vw_ventas_detalle AS
SELECT
    v.id,
    v.fecha,
    u.nombre        AS trabajador,
    ISNULL(c.nombre, 'Venta al Público') AS cliente,
    v.total_original,
    v.descuento,
    v.total_final
FROM dbo.ventas v
JOIN dbo.usuarios u ON v.id_usuario = u.id
LEFT JOIN dbo.clientes c ON v.id_cliente = c.id;
GO

-- Vista: productos con stock bajo
CREATE OR ALTER VIEW dbo.vw_stock_bajo AS
SELECT
    p.nombre        AS producto,
    pr.unidad,
    pr.tamano,
    pr.stock        AS stock_actual,
    pr.stock_minimo,
    pr.stock_minimo - pr.stock AS unidades_faltantes
FROM dbo.presentaciones pr
JOIN dbo.productos p ON pr.id_producto = p.id
WHERE pr.activo = 1
  AND p.activo  = 1
  AND pr.stock <= pr.stock_minimo;
GO


-- ============================================================
--  10. FUNCIONES Y PROCEDIMIENTOS ALMACENADOS
-- ============================================================

-- Precio efectivo: devuelve precio especial del cliente o precio de lista
CREATE OR ALTER FUNCTION dbo.fn_precio_efectivo (
    @id_presentacion INT,
    @id_cliente      INT   -- NULL = sin cliente
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @precio DECIMAL(10,2);

    IF @id_cliente IS NOT NULL
    BEGIN
        SELECT @precio = pe.precio_especial
        FROM dbo.precios_especiales pe
        WHERE pe.id_presentacion = @id_presentacion
          AND pe.id_cliente      = @id_cliente;
    END

    IF @precio IS NULL
        SELECT @precio = precio FROM dbo.presentaciones WHERE id = @id_presentacion;

    RETURN @precio;
END;
GO

-- Registrar venta completa (cabecera + detalles + descuento stock)
CREATE OR ALTER PROCEDURE dbo.sp_registrar_venta
    @id_usuario     INT,
    @id_cliente     INT = NULL,
    @items          NVARCHAR(MAX)   -- JSON: [{id_presentacion, cantidad}]
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Parsear items del JSON
        SELECT
            CAST(j.id_presentacion AS INT)  AS id_presentacion,
            CAST(j.cantidad        AS INT)  AS cantidad
        INTO #items_venta
        FROM OPENJSON(@items)
        WITH (
            id_presentacion INT '$.id_presentacion',
            cantidad        INT '$.cantidad'
        ) j;

        -- Validar stock suficiente para todos los items
        IF EXISTS (
            SELECT 1
            FROM #items_venta iv
            JOIN dbo.presentaciones pr ON iv.id_presentacion = pr.id
            WHERE pr.stock < iv.cantidad
        )
        BEGIN
            ROLLBACK;
            RAISERROR('Stock insuficiente para uno o más productos.', 16, 1);
            RETURN;
        END

        -- Calcular totales
        DECLARE @total_original DECIMAL(10,2);
        DECLARE @total_final    DECIMAL(10,2);

        SELECT
            @total_original = SUM(pr.precio                                            * iv.cantidad),
            @total_final    = SUM(dbo.fn_precio_efectivo(iv.id_presentacion, @id_cliente) * iv.cantidad)
        FROM #items_venta iv
        JOIN dbo.presentaciones pr ON iv.id_presentacion = pr.id;

        -- Insertar cabecera
        DECLARE @id_venta INT;
        INSERT INTO dbo.ventas (id_usuario, id_cliente, total_original, descuento, total_final)
        VALUES (
            @id_usuario,
            @id_cliente,
            @total_original,
            @total_original - @total_final,
            @total_final
        );
        SET @id_venta = SCOPE_IDENTITY();

        -- Insertar detalle y descontar stock
        INSERT INTO dbo.detalle_ventas
            (id_venta, id_presentacion, cantidad, precio_unitario, precio_efectivo, subtotal)
        SELECT
            @id_venta,
            iv.id_presentacion,
            iv.cantidad,
            pr.precio,
            dbo.fn_precio_efectivo(iv.id_presentacion, @id_cliente),
            dbo.fn_precio_efectivo(iv.id_presentacion, @id_cliente) * iv.cantidad
        FROM #items_venta iv
        JOIN dbo.presentaciones pr ON iv.id_presentacion = pr.id;

        -- Descontar stock
        UPDATE pr
        SET pr.stock = pr.stock - iv.cantidad
        FROM dbo.presentaciones pr
        JOIN #items_venta iv ON pr.id = iv.id_presentacion;

        DROP TABLE #items_venta;
        COMMIT;

        -- Devolver id de la venta creada
        SELECT @id_venta AS id_venta;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- Resumen de ventas por período
CREATE OR ALTER PROCEDURE dbo.sp_reporte_ventas
    @periodo  NVARCHAR(10) = 'dia',   -- 'dia' | 'semana' | 'mes'
    @fecha    DATE         = NULL     -- NULL = hoy
AS
BEGIN
    SET NOCOUNT ON;

    IF @fecha IS NULL SET @fecha = CAST(GETDATE() AS DATE);

    IF @periodo = 'dia'
    BEGIN
        SELECT
            CAST(v.fecha AS DATE)   AS fecha,
            COUNT(*)                AS num_ventas,
            SUM(v.total_final)      AS total_recaudado,
            SUM(v.descuento)        AS total_descuentos,
            AVG(v.total_final)      AS ticket_promedio
        FROM dbo.ventas v
        WHERE CAST(v.fecha AS DATE) = @fecha
        GROUP BY CAST(v.fecha AS DATE);
    END
    ELSE IF @periodo = 'semana'
    BEGIN
        SELECT
            CAST(v.fecha AS DATE)   AS fecha,
            COUNT(*)                AS num_ventas,
            SUM(v.total_final)      AS total_recaudado,
            SUM(v.descuento)        AS total_descuentos
        FROM dbo.ventas v
        WHERE v.fecha >= DATEADD(DAY, -6, @fecha)
          AND v.fecha <  DATEADD(DAY, 1,  @fecha)
        GROUP BY CAST(v.fecha AS DATE)
        ORDER BY fecha DESC;
    END
    ELSE IF @periodo = 'mes'
    BEGIN
        SELECT
            YEAR(v.fecha)           AS anio,
            MONTH(v.fecha)          AS mes,
            COUNT(*)                AS num_ventas,
            SUM(v.total_final)      AS total_recaudado,
            SUM(v.descuento)        AS total_descuentos
        FROM dbo.ventas v
        WHERE YEAR(v.fecha)  = YEAR(@fecha)
          AND MONTH(v.fecha) = MONTH(@fecha)
        GROUP BY YEAR(v.fecha), MONTH(v.fecha);
    END
END;
GO

-- Top productos más vendidos
CREATE OR ALTER PROCEDURE dbo.sp_top_productos
    @top       INT  = 10,
    @dias      INT  = 30        -- últimos N días
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@top)
        p.nombre        AS producto,
        pr.unidad,
        pr.tamano,
        SUM(dv.cantidad)        AS unidades_vendidas,
        SUM(dv.subtotal)        AS ingresos_generados
    FROM dbo.detalle_ventas dv
    JOIN dbo.presentaciones pr ON dv.id_presentacion = pr.id
    JOIN dbo.productos       p  ON pr.id_producto    = p.id
    JOIN dbo.ventas          v  ON dv.id_venta       = v.id
    WHERE v.fecha >= DATEADD(DAY, -@dias, GETDATE())
    GROUP BY p.nombre, pr.unidad, pr.tamano
    ORDER BY unidades_vendidas DESC;
END;
GO


-- ============================================================
--  11. DATOS DE PRUEBA (SEED)
-- ============================================================

-- Usuarios
INSERT INTO dbo.usuarios (nombre, username, password_hash, rol) VALUES
    ('Administrador',       'admin',    '$2b$10$PLACEHOLDER_ADMIN_HASH',     'admin'),
    ('Juan Trabajador',     'usuario',  '$2b$10$PLACEHOLDER_USUARIO_HASH',   'trabajador'),
    ('María Trabajadora',   'maria',    '$2b$10$PLACEHOLDER_MARIA_HASH',     'trabajador');
GO

-- Productos
INSERT INTO dbo.productos (nombre, descripcion, categoria, subcategoria, uso, imagen_url) VALUES
    ('Maíz Amarillo',
     'Maíz amarillo de alta calidad para engorda de ganado bovino y porcino.',
     'Alimento', 'Bovino', 'Engorda',
     'https://example.com/maiz.jpg'),

    ('Sorgo Rojo',
     'Sorgo rojo en grano, ideal como complemento energético en dietas ganaderas.',
     'Alimento', 'Bovino', 'Engorda',
     'https://example.com/sorgo.jpg'),

    ('Alfalfa Achicalada',
     'Paca de alfalfa deshidratada de alta proteína para equinos y bovinos.',
     'Alimento', 'Equino', 'Mantenimiento',
     'https://example.com/alfalfa.jpg'),

    ('Alpiste Nacional',
     'Alpiste de primera calidad para aves canoras y de ornato.',
     'Alimento', 'Aves', 'Engorda',
     'https://example.com/alpiste.jpg'),

    ('Comedero de Pollo',
     'Comedero plástico resistente para pollos en diferentes tamaños.',
     'Accesorios', 'Aves', 'Equipamiento',
     'https://delagarzamateriasprimas.com/wp-content/uploads/2024/07/comedero_pollo.jpg'),

    ('Semilla de Pasto Bermuda',
     'Semilla certificada para establecimiento de praderas de bovinos.',
     'Semillas', 'Bovino', 'Praderas',
     'https://example.com/bermuda.jpg');
GO

-- Presentaciones
INSERT INTO dbo.presentaciones (id_producto, unidad, tamano, precio, stock, stock_minimo) VALUES
    -- Maíz Amarillo (id=1)
    (1, 'Bulto',    50,   420.00,  120,  10),
    (1, 'Bulto',    25,   220.00,   80,   5),
    (1, 'Kg',        1,    9.50,   500,  50),

    -- Sorgo Rojo (id=2)
    (2, 'Bulto',    50,   380.00,   90,  10),
    (2, 'Kg',        1,    8.00,   400,  50),

    -- Alfalfa Achicalada (id=3)
    (3, 'Paca',      1,   150.00,   60,   5),
    (3, 'Tonelada',  1, 12000.00,    3,   1),

    -- Alpiste Nacional (id=4)
    (4, 'Kg',        1,    35.00,  200,  20),
    (4, 'Bolsa',     5,   160.00,   80,  10),

    -- Comedero de Pollo (id=5)
    (5, 'Pieza ch',  1,   120.00,  100,  10),
    (5, 'Pieza med', 1,   180.00,   80,   8),
    (5, 'Pieza gra', 1,   250.00,   60,   5),

    -- Semilla Bermuda (id=6)
    (6, 'Kg',        1,    95.00,  150,  15),
    (6, 'Bolsa',    10,   880.00,   40,   5);
GO

-- Clientes concurrentes
INSERT INTO dbo.clientes (nombre, telefono) VALUES
    ('Juan García (Rancho El Nogal)', '867-100-0001'),
    ('Pedro Martínez (Granja Avícola)', '867-100-0002'),
    ('Silvia Torres (Establo Las Palmas)', '867-100-0003');
GO

-- Precios especiales
-- Juan tiene precio especial en Maíz Bulto 50kg
INSERT INTO dbo.precios_especiales (id_cliente, id_presentacion, precio_especial) VALUES
    (1, 1, 390.00),   -- Juan: Maíz Bulto 50kg a $390 (lista $420)
    (1, 2, 200.00),   -- Juan: Maíz Bulto 25kg a $200 (lista $220)
    (2, 8,  30.00),   -- Pedro: Alpiste Kg a $30 (lista $35)
    (3, 6, 130.00);   -- Silvia: Alfalfa Paca a $130 (lista $150)
GO

PRINT '✔ Base de datos ForraStore creada exitosamente.';
PRINT '  Tablas: 7 | Vistas: 3 | Procedimientos: 3 | Función: 1';
GO
