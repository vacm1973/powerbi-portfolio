/*
===============================================================================
Database Analytics & T-SQL ETL Pipeline - Operational Variance Audit
Description: Automated variance analysis script utilizing CTEs and Window Functions 
             (AVG, SUM OVER) to audit trip costs and margins per client channel 
             against historical baseline averages.
Author: Victor Andres Costa Molina
===============================================================================
*/

USE [DataWarehouse_Analytics];
GO

WITH OperationalBaselines AS (
    SELECT 
        t.IdOperacion,
        t.FechaOperacion,
        c.NombreCliente,
        c.CanalVenta,
        t.IngresoBruto,
        t.CostoFlete,
        (t.IngresoBruto - t.CostoFlete) AS MargenBruto,
        AVG(t.CostoFlete) OVER(PARTITION BY c.CanalVenta) AS AverageChannelFreightCost,
        SUM(t.IngresoBruto) OVER(PARTITION BY t.IdCliente) AS TotalClientGrossRevenue
    FROM dbo.FactOperacionesTrafico AS t WITH (NOLOCK)
    INNER JOIN dbo.DM_CLIENTE AS c WITH (NOLOCK) 
        ON t.IdCliente = c.IdCliente
    WHERE t.EstadoOperacion = 'COMPLETADO'
)
SELECT 
    b.IdOperacion,
    b.FechaOperacion,
    b.NombreCliente,
    b.CanalVenta,
    b.IngresoBruto,
    b.CostoFlete,
    b.MargenBruto,
    ROUND(b.AverageChannelFreightCost, 2) AS CostoPromedioCanal,
    ROUND(b.CostoFlete - b.AverageChannelFreightCost, 2) AS DesviacionFleteVsPromedio,
    ROUND((b.MargenBruto / NULLIF(b.TotalClientGrossRevenue, 0)) * 100, 2) AS ContribucionMargenSobreClientePct
FROM OperationalBaselines b
ORDER BY DesviacionFleteVsPromedio DESC;
GO