/*
===============================================================================
Database Analytics & T-SQL ETL Pipeline - Staging Transformations
Description: Staging transformation script that normalizes operational status, 
             imputes missing cost metrics, and flags operational quality issues 
             on FactTransportOperations before reporting ingestion.
Author: Victor Andres Costa Molina
===============================================================================
*/

USE [DataWarehouse_Analytics];
GO

UPDATE dbo.FactTransportOperations
SET FreightCost = 0.00
WHERE FreightCost IS NULL;

UPDATE dbo.FactTransportOperations
SET OperationStatus = UPPER(TRIM(OperationStatus));

WITH LossMakingOperations AS (
    SELECT 
        OperationID,
        GrossRevenue,
        FreightCost,
        (GrossRevenue - FreightCost) AS Margin
    FROM dbo.FactTransportOperations
    WHERE (GrossRevenue - FreightCost) < 0
)
SELECT 
    l.OperationID,
    l.GrossRevenue,
    l.FreightCost,
    l.Margin,
    'WARNING: Operational Freight Cost exceeds Gross Revenue' AS DataQualityFlag
FROM LossMakingOperations l;
GO