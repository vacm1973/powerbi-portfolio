/*
===============================================================================
Database Analytics & T-SQL ETL Pipeline - Mock Data Setup
Description: Generates robust relational mock data for DM_CLIENTE and 
             FactOperacionesTrafico to enable local testing of SQL procedures 
             and Power BI / DAX measures.
Author: Victor Andres Costa Molina
===============================================================================
*/

USE [DataWarehouse_Analytics];
GO

-- Clean up existing mock records
DELETE FROM dbo.FactOperacionesTrafico;
DELETE FROM dbo.DM_CLIENTE;
GO

-- Populate Dimension Table: DM_CLIENTE
INSERT INTO dbo.DM_CLIENTE (IdCliente, NombreCliente, CanalVenta, FechaAlta) VALUES
(101, 'Logística Distribución SA', 'Retail', '2024-01-15'),
(102, 'Transportes del Norte SRL', 'Wholesale', '2024-03-20'),
(103, 'Comercializadora Global', 'Direct-to-Consumer', '2024-06-10'),
(104, 'Operador Logístico Central', 'Retail', '2025-01-05');

-- Populate Fact Table: FactOperacionesTrafico
INSERT INTO dbo.FactOperacionesTrafico 
(FechaOperacion, IdCliente, IdRuta, CantidadParadas, IngresoBruto, CostoFlete, EstadoOperacion, IsActive) 
VALUES
('2026-10-01', 101, 501, 3, 150000.00, 95000.00, 'COMPLETADO', 1),
('2026-10-02', 101, 502, 1, 80000.00, 50000.00, 'COMPLETADO', 1),
('2026-10-03', 102, 503, 4, 320000.00, 210000.00, 'COMPLETADO', 1),
('2026-10-04', 103, 504, 2, 45000.00, 48000.00, 'COMPLETADO', 1),
('2026-10-05', 104, 505, 5, 210000.00, 130000.00, 'COMPLETADO', 1),
('2026-10-06', 102, 506, 2, 110000.00, 70000.00, 'CANCELADO', 0),
('2026-10-07', 101, 507, 2, 190000.00, 115000.00, 'COMPLETADO', 1),
('2026-10-08', 103, 508, 1, 65000.00, 40000.00, 'COMPLETADO', 1);
GO