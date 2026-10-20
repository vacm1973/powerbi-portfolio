-- =====================================================================
-- Project: Automated Freight Invoice Reconciliation
-- Engine: T-SQL / SQL Server
-- Description: Uses CTEs and window functions to compare billed freight 
--              invoices against pre-established carrier contracts.
-- =====================================================================

WITH LatestContractRates AS (
    SELECT 
        CarrierID,
        RouteID,
        AgreedRate,
        EffectiveDate,
        ROW_NUMBER() OVER (PARTITION BY CarrierID, RouteID ORDER BY EffectiveDate DESC) as rn
    FROM ContractsMaster
)
SELECT 
    t.InvoiceID,
    t.CarrierID,
    t.RouteID,
    t.ShipmentDate,
    t.BilledAmount,
    c.AgreedRate,
    (t.BilledAmount - c.AgreedRate) AS CostVariance,
    CASE 
        WHEN t.BilledAmount > c.AgreedRate THEN 'Overbilled'
        WHEN t.BilledAmount < c.AgreedRate THEN 'Underbilled'
        ELSE 'Matched'
    END AS ReconciliationStatus
FROM LogisticsTransactions t
INNER JOIN LatestContractRates c 
    ON t.CarrierID = c.CarrierID 
    AND t.RouteID = c.RouteID 
    AND c.rn = 1
WHERE t.Status = 'Processed';
