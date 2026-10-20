-- Uso de CTEs y funciones de ventana para conciliación de facturas logísticas
WITH RankedInvoices AS (
    SELECT 
        InvoiceID,
        CarrierID,
        ShipmentDate,
        BilledAmount,
        ContractRate,
        ROW_NUMBER() OVER (PARTITION BY CarrierID ORDER BY ShipmentDate DESC) as rn
    FROM LogisticsTransactions
    WHERE Status = 'Processed'
)
SELECT 
    InvoiceID,
    CarrierID,
    BilledAmount,
    ContractRate,
    (BilledAmount - ContractRate) AS Variance
FROM RankedInvoices
WHERE rn = 1 AND BilledAmount <> ContractRate;
