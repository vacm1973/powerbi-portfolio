# 📂 T-SQL Scripts & Data Engineering Pipelines

This directory contains production-grade T-SQL scripts for SQL Server, focusing on DDL schema definitions, sample data generation (DML), staging transformations, and automated business reconciliations.

## 📄 Included Files & Technical Rationale:

* **[`sp_traffic_analytics_reconciliation.sql`](./sp_traffic_analytics_reconciliation.sql)**: Fully self-contained T-SQL script containing schema DDL (`DM_CLIENTE`, `FactOperacionesTrafico`), mock data inserts, analytical view (`VW_FACT_TRAFICO_PRESENTACION`), and reporting stored procedure (`SP_TRAFICO_PRESENTACION`) for multi-stop logistics aggregation and margin calculations.
* **[`logistics_transformations.sql`](./logistics_transformations.sql)**: Staging pipeline script that normalizes hub names, standardizes weights, and handles data quality flags.
* **[`logistics_reconciliation.sql`](./logistics_reconciliation.sql)**: Automated variance analysis script utilizing Common Table Expressions (CTEs) and window functions to audit carrier invoices against contract rates.
* **[`insert_dummy_data.sql`](./insert_dummy_data.sql)**: Initialization script generating robust mock relational data to test the queries and DAX time intelligence measures locally.

---

[← Back to Main Repository](../README.md)