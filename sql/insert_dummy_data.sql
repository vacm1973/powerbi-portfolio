/*
===============================================================================
Database Analytics & T-SQL ETL Pipeline - Mock Data Setup
Description: Generates robust relational mock data for DimCustomer and 
             FactTransportOperations to enable local testing of SQL procedures 
             and Power BI / DAX measures.
Author: Victor Andres Costa Molina
===============================================================================
*/

USE [DataWarehouse_Analytics];
GO

DELETE FROM dbo.FactTransportOperations;
DELETE FROM dbo.DimCustomer;
GO

INSERT INTO dbo.DimCustomer (CustomerID, CustomerName, SalesChannel, CreatedDate) VALUES
(101, 'Logistics Distribution Corp', 'Retail', '2024-01-15'),
(102, 'Northern Transport LLC', 'Wholesale', '2024-03-20'),
(103, 'Global Trading Co', 'Direct-to-Consumer', '2024-06-10'),
(104, 'Central Logistics Operator', 'Retail', '2025-01-05');

INSERT INTO dbo.FactTransportOperations 
(OperationDate, CustomerID, RouteID, StopsCount, GrossRevenue, FreightCost, OperationStatus, IsActive) 
VALUES
('2026-10-01', 101, 501, 3, 150000.00, 95000.00, 'COMPLETED', 1),
('2026-10-02', 101, 502, 1, 80000.00, 50000.00, 'COMPLETED', 1),
('2026-10-03', 102, 503, 4, 320000.00, 210000.00, 'COMPLETED', 1),
('2026-10-04', 103, 504, 2, 45000.00, 48000.00, 'COMPLETED', 1),
('2026-10-05', 104, 505, 5, 210000.00, 130000.00, 'COMPLETED', 1),
('2026-10-06', 102, 506, 2, 110000.00, 70000.00, 'CANCELLED', 0),
('2026-10-07', 101, 507, 2, 190000.00, 115000.00, 'COMPLETED', 1),
('2026-10-08', 103, 508, 1, 65000.00, 40000.00, 'COMPLETED', 1);
GO