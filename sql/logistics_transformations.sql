-- =====================================================================
-- Proyecto: Pipeline de Transformación y Limpieza de Datos Logísticos
-- Motor: T-SQL / SQL Server
-- Descripción: Script ETL para normalizar registros de tráfico, fletes 
--              y métricas de entrega antes de consumirlas en Power BI.
-- =====================================================================

-- 1. Crear tabla intermedia limpia para reportes analíticos
IF OBJECT_ID('dbo.Stg_LogisticsCleanedData', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_LogisticsCleanedData;

CREATE TABLE dbo.Stg_LogisticsCleanedData (
    TrackingNumber VARCHAR(50) PRIMARY KEY,
    OriginHub VARCHAR(100),
    DestinationHub VARCHAR(100),
    WeightKg DECIMAL(10,2),
    VolumeCBM DECIMAL(10,4),
    DispatchDate DATE,
    DeliveryDate DATE,
    TotalTransitHours INT,
    IsOnTimeDelivery INT,
    DataQualityFlag VARCHAR(20)
);

-- 2. Inserción con transformaciones, limpieza de nulos y estandarización de texto
INSERT INTO dbo.Stg_LogisticsCleanedData
SELECT 
    TRIM(ShipmentTrackingNumber) AS TrackingNumber,
    UPPER(TRIM(OriginHub)) AS OriginHub,
    UPPER(TRIM(DestinationHub)) AS DestinationHub,
    COALESCE(PackageWeightKg, 0.00) AS WeightKg,
    COALESCE(VolumeCBM, 0.0000) AS VolumeCBM,
    CAST(DispatchTimestamp AS DATE) AS DispatchDate,
    CAST(DeliveryTimestamp AS DATE) AS DeliveryDate,
    DATEDIFF(hour, DispatchTimestamp, DeliveryTimestamp) AS TotalTransitHours,
    CASE 
        WHEN DeliveryStatus = 'Delivered On Time' THEN 1 
        ELSE 0 
    END AS IsOnTimeDelivery,
    CASE 
        WHEN PackageWeightKg IS NULL OR VolumeCBM IS NULL THEN 'Warning: Missing Metrics'
        ELSE 'Valid'
    END AS DataQualityFlag
FROM RawShipmentLogs
WHERE ShipmentTrackingNumber IS NOT NULL 
  AND DispatchTimestamp >= '2025-01-01';

-- 3. Validación y consulta de resumen de calidad de datos procesados
SELECT 
    DataQualityFlag,
    COUNT(*) AS TotalShipments,
    ROUND(AVG(WeightKg), 2) AS AvgWeightKg,
    SUM(IsOnTimeDelivery) AS TotalOnTimeDeliveries
FROM dbo.Stg_LogisticsCleanedData
GROUP BY DataQualityFlag;
