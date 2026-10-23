/*
===============================================================================
Database Analytics & T-SQL ETL Pipeline
Description: Enterprise T-SQL script containing Schema Creation (DDL), Mock Data 
             Insertion (DML), Analytical View definition, and Stored Procedure 
             for multi-stop logistics aggregation. Fully executable standalone.
Author: Victor Andres Costa Molina
===============================================================================
*/

-- 1. DATABASE SCHEMA CREATION (DDL)
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.FactOperacionesTrafico', 'U') IS NOT NULL DROP TABLE dbo.FactOperacionesTrafico;
IF OBJECT_ID('dbo.DM_CLIENTE', 'U') IS NOT NULL DROP TABLE dbo.DM_CLIENTE;
GO

CREATE TABLE dbo.DM_CLIENTE (
    IdCliente INT PRIMARY KEY,
    NombreCliente VARCHAR(255) NOT NULL,
    CanalVenta VARCHAR(100) NOT NULL,
    FechaAlta DATE DEFAULT GETDATE()
);

CREATE TABLE dbo.FactOperacionesTrafico (
    IdOperacion INT PRIMARY KEY IDENTITY(1,1),
    FechaOperacion DATE NOT NULL,
    IdCliente INT NOT NULL,
    IdRuta INT NOT NULL,
    CantidadParadas INT DEFAULT 1,
    IngresoBruto DECIMAL(18,2) NOT NULL,
    CostoFlete DECIMAL(18,2) NOT NULL,
    EstadoOperacion VARCHAR(50) NOT NULL,
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_FactOperaciones_Cliente FOREIGN KEY (IdCliente) REFERENCES dbo.DM_CLIENTE(IdCliente)
);
GO

-- 2. MOCK DATA INSERTION (DML)
-------------------------------------------------------------------------------
INSERT INTO dbo.DM_CLIENTE (IdCliente, NombreCliente, CanalVenta) VALUES
(101, 'Logística Distribución SA', 'Retail'),
(102, 'Transportes del Norte SRL', 'Wholesale'),
(103, 'Comercializadora Global', 'Direct-to-Consumer'),
(104, 'Operador Logístico Central', 'Retail');

INSERT INTO dbo.FactOperacionesTrafico 
(FechaOperacion, IdCliente, IdRuta, CantidadParadas, IngresoBruto, CostoFlete, EstadoOperacion) 
VALUES
('2026-10-01', 101, 501, 3, 150000.00, 95000.00, 'COMPLETADO'),
('2026-10-02', 101, 502, 1, 80000.00, 50000.00, 'COMPLETADO'),
('2026-10-03', 102, 503, 4, 320000.00, 210000.00, 'COMPLETADO'),
('2026-10-04', 103, 504, 2, 45000.00, 48000.00, 'COMPLETADO'),
('2026-10-05', 104, 505, 5, 210000.00, 130000.00, 'COMPLETADO'),
('2026-10-06', 102, 506, 2, 110000.00, 70000.00, 'CANCELADO');
GO

-- 3. ANALYTICAL VIEW CREATION
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.VW_FACT_TRAFICO_PRESENTACION', 'V') IS NOT NULL 
    DROP VIEW dbo.VW_FACT_TRAFICO_PRESENTACION;
GO

CREATE VIEW dbo.VW_FACT_TRAFICO_PRESENTACION
AS
SELECT 
    t.IdOperacion,
    t.FechaOperacion,
    t.IdCliente,
    c.NombreCliente,
    c.CanalVenta,
    t.IdRuta,
    t.CantidadParadas,
    t.IngresoBruto,
    t.CostoFlete,
    (t.IngresoBruto - t.CostoFlete) AS MargenBruto,
    CASE 
        WHEN t.IngresoBruto > 0 THEN ROUND(((t.IngresoBruto - t.CostoFlete) / t.IngresoBruto) * 100, 2)
        ELSE 0 
    END AS PorcentajeMargen
FROM dbo.FactOperacionesTrafico AS t WITH (NOLOCK)
INNER JOIN dbo.DM_CLIENTE AS c WITH (NOLOCK) 
    ON t.IdCliente = c.IdCliente
WHERE t.EstadoOperacion = 'COMPLETADO';
GO

-- 4. STORED PROCEDURE CREATION
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.SP_TRAFICO_PRESENTACION', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.SP_TRAFICO_PRESENTACION;
GO

CREATE PROCEDURE dbo.SP_TRAFICO_PRESENTACION
    @FechaInicio DATE,
    @FechaFin DATE,
    @CanalVenta VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #TempTraficoResumen (
        IdCliente INT,
        NombreCliente VARCHAR(255),
        CanalVenta VARCHAR(100),
        TotalOperaciones INT,
        TotalIngreso DECIMAL(18, 2),
        TotalCosto DECIMAL(18, 2),
        TotalMargen DECIMAL(18, 2)
    );

    INSERT INTO #TempTraficoResumen (IdCliente, NombreCliente, CanalVenta, TotalOperaciones, TotalIngreso, TotalCosto, TotalMargen)
    SELECT 
        v.IdCliente,
        v.NombreCliente,
        v.CanalVenta,
        COUNT(DISTINCT v.IdOperacion) AS TotalOperaciones,
        SUM(v.IngresoBruto) AS TotalIngreso,
        SUM(v.CostoFlete) AS TotalCosto,
        SUM(v.MargenBruto) AS TotalMargen
    FROM dbo.VW_FACT_TRAFICO_PRESENTACION AS v
    WHERE v.FechaOperacion BETWEEN @FechaInicio AND @FechaFin
      AND (@CanalVenta IS NULL OR v.CanalVenta = @CanalVenta)
    GROUP BY 
        v.IdCliente,
        v.NombreCliente,
        v.CanalVenta;

    SELECT 
        r.IdCliente,
        r.NombreCliente,
        r.CanalVenta,
        r.TotalOperaciones,
        r.TotalIngreso,
        r.TotalCosto,
        r.TotalMargen,
        CASE 
            WHEN r.TotalIngreso > 0 THEN ROUND((r.TotalMargen / r.TotalIngreso) * 100, 2)
            ELSE 0 
        END AS PorcentajeMargenConsolidado
    FROM #TempTraficoResumen AS r
    ORDER BY r.TotalMargen DESC;

    DROP TABLE #TempTraficoResumen;
END;
GO

-- 5. TEST EXECUTION SCRIPT
-------------------------------------------------------------------------------
-- EXEC dbo.SP_TRAFICO_PRESENTACION @FechaInicio = '2026-10-01', @FechaFin = '2026-10-31';