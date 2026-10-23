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
        t.OperationID,
        t.OperationDate,
        c.CustomerName,
        c.SalesChannel,
        t.GrossRevenue,
        t.FreightCost,
        (t.GrossRevenue - t.FreightCost) AS GrossMargin,
        AVG(t.FreightCost) OVER(PARTITION BY c.SalesChannel) AS AvgChannelFreightCost,
        SUM(t.GrossRevenue) OVER(PARTITION BY t.CustomerID) AS TotalCustomerGrossRevenue
    FROM dbo.FactTransportOperations AS t WITH (NOLOCK)
    INNER JOIN dbo.DimCustomer AS c WITH (NOLOCK) 
        ON t.CustomerID = c.CustomerID
    WHERE t.OperationStatus = 'COMPLETED'
)
SELECT 
    b.OperationID,
    b.OperationDate,
    b.CustomerName,
    b.SalesChannel,
    b.GrossRevenue,
    b.FreightCost,
    b.GrossMargin,
    ROUND(b.AvgChannelFreightCost, 2) AS AvgChannelFreightCost,
    ROUND(b.FreightCost - b.AvgChannelFreightCost, 2) AS FreightVarianceVsAvg,
    ROUND((b.GrossMargin / NULLIF(b.TotalCustomerGrossRevenue, 0)) * 100, 2) AS CustomerMarginContributionPct
FROM OperationalBaselines b
ORDER BY FreightVarianceVsAvg DESC;
GO