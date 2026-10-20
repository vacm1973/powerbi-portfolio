# 📂 T-SQL Scripts & Data Engineering Pipelines

This directory contains production-grade T-SQL scripts for SQL Server, focusing on data cleansing, staging preparation, and automated business reconciliations.

## 📄 Included Files:
- **`logistics_transformations.sql`**: Staging pipeline script that normalizes hub names, standardizes weights, and handles data quality flags.
- **`logistics_reconciliation.sql`**: Automated variance analysis script utilizing Common Table Expressions (CTEs) and window functions to audit carrier invoices against contract rates.
- **`insert_dummy_data.sql`**: Initialization script generating robust mock relational data to test the queries and DAX time intelligence measures locally.

[← Back to Main Repository](../README.md)
