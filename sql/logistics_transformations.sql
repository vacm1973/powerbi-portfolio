-- =====================================================================
-- Project: Logistics Data Transformation and Cleaning Pipeline
-- Engine: T-SQL / SQL Server
-- Description: ETL script to normalize shipment traffic, freight, 
--              and delivery performance metrics prior to Power BI consumption.
-- =====================================================================

-- 1. Drop staging table if it already exists
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

-- 2. Insert data with transformations, null handling, and text standardization
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

-- 3. Validate and query processed data quality summary
SELECT 
    DataQualityFlag,
    COUNT(*) AS TotalShipments,
    ROUND(AVG(WeightKg), 2) AS AvgWeightKg,
    SUM(IsOnTimeDelivery) AS TotalOnTimeDeliveries
FROM dbo.Stg_LogisticsCleanedData
GROUP BY DataQualityFlag;
