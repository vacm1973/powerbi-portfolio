/*
===============================================================================
Database Analytics & T-SQL ETL Pipeline - Staging Transformations
Description: Staging transformation script that normalizes operational status, 
             imputes missing cost metrics, and flags operational quality issues 
             on FactOperacionesTrafico before reporting ingestion.
Author: Victor Andres Costa Molina
===============================================================================
*/

USE [DataWarehouse_Analytics];
GO

-- Staging Update: Impute null costs and flag non-profitable operations
UPDATE dbo.FactOperacionesTrafico
SET CostoFlete = 0.00
WHERE CostoFlete IS NULL;

-- Staging Transformation: Standardize text casing for EstadoOperacion
UPDATE dbo.FactOperacionesTrafico
SET EstadoOperacion = UPPER(TRIM(EstadoOperacion));

-- Analytical Staging CTE: Identify operations running at a net loss
WITH LossMakingOperations AS (
    SELECT 
        IdOperacion,
        IngresoBruto,
        CostoFlete,
        (IngresoBruto - CostoFlete) AS Margen
    FROM dbo.FactOperacionesTrafico
    WHERE (IngresoBruto - CostoFlete) < 0
)
SELECT 
    l.IdOperacion,
    l.IngresoBruto,
    l.CostoFlete,
    l.Margen,
    'WARNING: Operational Freight Cost exceeds Gross Revenue' AS DataQualityFlag
FROM LossMakingOperations l;
GO