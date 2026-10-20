-- =====================================================================
-- Script T-SQL para Creación e Inserción de Datos Dummy
-- Compatible con los scripts SQL y medidas DAX del portfolio logístico
-- =====================================================================

-- 1. Limpieza previa de objetos si ya existen
IF OBJECT_ID('dbo.LogisticsTransactions', 'U') IS NOT NULL DROP TABLE dbo.LogisticsTransactions;
IF OBJECT_ID('dbo.ContractsMaster', 'U') IS NOT NULL DROP TABLE dbo.ContractsMaster;
IF OBJECT_ID('dbo.RawShipmentLogs', 'U') IS NOT NULL DROP TABLE dbo.RawShipmentLogs;
IF OBJECT_ID('dbo.Calendar', 'U') IS NOT NULL DROP TABLE dbo.Calendar;

-- 2. Creación de Tabla de Dimensiones de Tiempo (Calendar) para DAX Time Intelligence
CREATE TABLE dbo.Calendar (
    [Date] DATE PRIMARY KEY,
    [Year] INT,
    [Month] INT,
    [MonthName] VARCHAR(20),
    [Quarter] INT
);

-- Poblar calendario dummy (años 2024 a 2026)
DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate DATE = '2026-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO dbo.Calendar ([Date], [Year], [Month], [MonthName], [Quarter])
    VALUES (
        @StartDate,
        YEAR(@StartDate),
        MONTH(@StartDate),
        DATENAME(month, @StartDate),
        DATEPART(quarter, @StartDate)
    );
    SET @StartDate = DATEADD(day, 1, @StartDate);
END

-- 3. Creación de Tabla RawShipmentLogs (Para script de transformaciones)
CREATE TABLE dbo.RawShipmentLogs (
    ShipmentTrackingNumber VARCHAR(50),
    OriginHub VARCHAR(100),
    DestinationHub VARCHAR(100),
    PackageWeightKg DECIMAL(10,2),
    VolumeCBM DECIMAL(10,4),
    DispatchTimestamp DATETIME,
    DeliveryTimestamp DATETIME,
    DeliveryStatus VARCHAR(50),
    RecordStatus VARCHAR(20)
);

-- Inserción de datos dummy en RawShipmentLogs (incluyendo casos con nulos para probar calidad de datos)
INSERT INTO dbo.RawShipmentLogs VALUES 
('TRK-1001', 'Buenos Aires Hub', 'Cordoba Hub', 45.50, 0.2500, '2025-01-10 08:30:00', '2025-01-11 14:00:00', 'Delivered On Time', 'Active'),
('TRK-1002', 'Rosario Hub', 'Mendoza Hub', 120.00, 1.1500, '2025-01-12 09:00:00', '2025-01-14 18:30:00', 'Delayed', 'Active'),
('TRK-1003', 'Buenos Aires Hub', 'Mar del Plata Hub', 12.30, 0.0500, '2025-01-15 10:15:00', '2025-01-15 19:00:00', 'Delivered On Time', 'Active'),
('TRK-1004', 'Cordoba Hub', 'Salta Hub', NULL, NULL, '2025-02-01 07:00:00', '2025-02-03 12:00:00', 'Delivered On Time', 'Active');

-- 4. Creación de Tablas para Conciliación de Fletes (ContractsMaster y LogisticsTransactions)
CREATE TABLE dbo.ContractsMaster (
    CarrierID VARCHAR(20),
    RouteID VARCHAR(20),
    AgreedRate DECIMAL(10,2),
    EffectiveDate DATE
);

INSERT INTO dbo.ContractsMaster VALUES
('CARRIER_A', 'ROUTE_01', 1500.00, '2024-01-01'),
('CARRIER_B', 'ROUTE_02', 2200.50, '2024-01-01'),
('CARRIER_A', 'ROUTE_01', 1600.00, '2025-01-01'); -- Tarifa actualizada para el año 2025

CREATE TABLE dbo.LogisticsTransactions (
    InvoiceID VARCHAR(50),
    CarrierID VARCHAR(20),
    RouteID VARCHAR(20),
    ShipmentDate DATE,
    BilledAmount DECIMAL(10,2),
    ContractRate DECIMAL(10,2),
    Status VARCHAR(20)
);

INSERT INTO dbo.LogisticsTransactions VALUES
('INV-9001', 'CARRIER_A', 'ROUTE_01', '2025-01-10', 1600.00, 1600.00, 'Processed'),
('INV-9002', 'CARRIER_B', 'ROUTE_02', '2025-01-12', 2350.00, 2200.50, 'Processed'), -- Caso con sobrecosto (Overbilled)
('INV-9003', 'CARRIER_A', 'ROUTE_01', '2025-01-15', 1500.00, 1600.00, 'Processed'); -- Caso con subfacturación (Underbilled)
