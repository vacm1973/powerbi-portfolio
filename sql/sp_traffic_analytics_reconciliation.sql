/*
===============================================================================
Database Analytics & T-SQL ETL Pipeline
Description: Enterprise T-SQL script containing Schema Creation (DDL), Mock Data 
             Insertion (DML), Analytical View definition, and Stored Procedure 
             for multi-stop logistics aggregation. Fully executable standalone.
Author: Victor Andres Costa Molina
===============================================================================
*/

USE [DataWarehouse_Analytics];
GO

-- 1. DATABASE SCHEMA CREATION (DDL)
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.FactTransportOperations', 'U') IS NOT NULL DROP TABLE dbo.FactTransportOperations;
IF OBJECT_ID('dbo.DimCustomer', 'U') IS NOT NULL DROP TABLE dbo.DimCustomer;
GO

CREATE TABLE dbo.DimCustomer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(255) NOT NULL,
    SalesChannel VARCHAR(100) NOT NULL,
    CreatedDate DATE DEFAULT GETDATE()
);

CREATE TABLE dbo.FactTransportOperations (
    OperationID INT PRIMARY KEY IDENTITY(1,1),
    OperationDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    RouteID INT NOT NULL,
    StopsCount INT DEFAULT 1,
    GrossRevenue DECIMAL(18,2) NOT NULL,
    FreightCost DECIMAL(18,2) NOT NULL,
    OperationStatus VARCHAR(50) NOT NULL,
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_FactTransportOperations_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.DimCustomer(CustomerID)
);
GO

-- 2. MOCK DATA INSERTION (DML)
-------------------------------------------------------------------------------
INSERT INTO dbo.DimCustomer (CustomerID, CustomerName, SalesChannel) VALUES
(101, 'Logistics Distribution Corp', 'Retail'),
(102, 'Northern Transport LLC', 'Wholesale'),
(103, 'Global Trading Co', 'Direct-to-Consumer'),
(104, 'Central Logistics Operator', 'Retail');

INSERT INTO dbo.FactTransportOperations 
(OperationDate, CustomerID, RouteID, StopsCount, GrossRevenue, FreightCost, OperationStatus) 
VALUES
('2026-10-01', 101, 501, 3, 150000.00, 95000.00, 'COMPLETED'),
('2026-10-02', 101, 502, 1, 80000.00, 50000.00, 'COMPLETED'),
('2026-10-03', 102, 503, 4, 320000.00, 210000.00, 'COMPLETED'),
('2026-10-04', 103, 504, 2, 45000.00, 48000.00, 'COMPLETED'),
('2026-10-05', 104, 505, 5, 210000.00, 130000.00, 'COMPLETED'),
('2026-10-06', 102, 506, 2, 110000.00, 70000.00, 'CANCELLED');
GO

-- 3. ANALYTICAL VIEW CREATION
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.VW_FACT_TRAFFIC_PRESENTATION', 'V') IS NOT NULL 
    DROP VIEW dbo.VW_FACT_TRAFFIC_PRESENTATION;
GO

CREATE VIEW dbo.VW_FACT_TRAFFIC_PRESENTATION
AS
SELECT 
    t.OperationID,
    t.OperationDate,
    t.CustomerID,
    c.CustomerName,
    c.SalesChannel,
    t.RouteID,
    t.StopsCount,
    t.GrossRevenue,
    t.FreightCost,
    (t.GrossRevenue - t.FreightCost) AS GrossMargin,
    CASE 
        WHEN t.GrossRevenue > 0 THEN ROUND(((t.GrossRevenue - t.FreightCost) / t.GrossRevenue) * 100, 2)
        ELSE 0 
    END AS MarginPercentage
FROM dbo.FactTransportOperations AS t WITH (NOLOCK)
INNER JOIN dbo.DimCustomer AS c WITH (NOLOCK) 
    ON t.CustomerID = c.CustomerID
WHERE t.OperationStatus = 'COMPLETED';
GO

-- 4. STORED PROCEDURE CREATION
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.SP_TRAFFIC_PRESENTATION', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.SP_TRAFFIC_PRESENTATION;
GO

CREATE PROCEDURE dbo.SP_TRAFFIC_PRESENTATION
    @StartDate DATE,
    @EndDate DATE,
    @SalesChannel VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #TempTrafficSummary (
        CustomerID INT,
        CustomerName VARCHAR(255),
        SalesChannel VARCHAR(100),
        TotalOperations INT,
        TotalRevenue DECIMAL(18, 2),
        TotalCost DECIMAL(18, 2),
        TotalMargin DECIMAL(18, 2)
    );

    INSERT INTO #TempTrafficSummary (CustomerID, CustomerName, SalesChannel, TotalOperations, TotalRevenue, TotalCost, TotalMargin)
    SELECT 
        v.CustomerID,
        v.CustomerName,
        v.SalesChannel,
        COUNT(DISTINCT v.OperationID) AS TotalOperations,
        SUM(v.GrossRevenue) AS TotalRevenue,
        SUM(v.FreightCost) AS TotalCost,
        SUM(v.GrossMargin) AS TotalMargin
    FROM dbo.VW_FACT_TRAFFIC_PRESENTATION AS v
    WHERE v.OperationDate BETWEEN @StartDate AND @EndDate
      AND (@SalesChannel IS NULL OR v.SalesChannel = @SalesChannel)
    GROUP BY 
        v.CustomerID,
        v.CustomerName,
        v.SalesChannel;

    SELECT 
        r.CustomerID,
        r.CustomerName,
        r.SalesChannel,
        r.TotalOperations,
        r.TotalRevenue,
        r.TotalCost,
        r.TotalMargin,
        CASE 
            WHEN r.TotalRevenue > 0 THEN ROUND((r.TotalMargin / r.TotalRevenue) * 100, 2)
            ELSE 0 
        END AS ConsolidatedMarginPct
    FROM #TempTrafficSummary AS r
    ORDER BY r.TotalMargin DESC;

    DROP TABLE #TempTrafficSummary;
END;
GO

-- 5. TEST EXECUTION SCRIPT
-------------------------------------------------------------------------------
-- EXEC dbo.SP_TRAFFIC_PRESENTATION @StartDate = '2026-10-01', @EndDate = '2026-10-31';