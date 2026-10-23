# 📊 Business Intelligence, Data Engineering & Analytics Repository

Welcome to this repository. This space consolidates advanced solutions for **Business Intelligence, Data Modeling, and ETL Pipelines**, developed using industry best practices.

---

### 👨‍💻 About Me
With over **32 years of overall experience in IT/Systems** and **17 years specialized in Business Intelligence & Data Analytics**, I have designed, architected, and deployed robust data solutions, ETL processes, and strategic dashboards for corporate decision-making.

* **Core Stack:** Power BI (Power Query / M, Advanced DAX), SQL Server (T-SQL, Stored Procedures, Performance Tuning), and MicroStrategy.
* **Key Focus:** Dimensional Modeling (Star Schema / Snowflake), Query Optimization, Process Automation, and Data Governance.

---

## 📂 Repository Structure & Key Components

Each directory and file in this repository serves a specific architectural purpose in the data pipeline. Below is the detailed breakdown, technical rationale, and direct paths to the code artifacts:

---

### 1. Power Query / M Transformations (`/power_query`)

* **Directory:** [`/power_query`](./power_query/README.md)
* **Technical Rationale & Purpose:**
  Contains Power Query (M) scripts used to extract, clean, normalize, and dynamic-unpivot heterogeneous raw sources before loading them into the Power BI semantic model.
* **Included Artifacts:**
  * [`logistics_transformations.pq`](./power_query/logistics_transformations.pq): ETL script designed to filter active records, remove billing nulls, capitalize text fields, and calculate key logistics metrics.
  * [`etl_transformations.pq`](./power_query/etl_transformations.pq): Advanced M pipeline performing group-by aggregations, dynamic unpivoting, and profit categorization logic.

---

### 2. DAX Calculations & Business Logic (`/dax`)

* **Directory:** [`/dax`](./dax)
* **Technical Rationale & Purpose:**
  Centralizes complex DAX measures, custom Time Intelligence calculations, and KPIs designed to optimize data model performance and provide deep analytical insights.
* **Included Artifacts:**
  * *(In progress - will include Time Intelligence metrics, calculated columns, and performance-tuned DAX measures)*

---

### 3. T-SQL & Database Layer (`/sql`)

* **Directory:** [`/sql`](./sql)
* **Technical Rationale & Purpose:**
  Houses database-level transformations, analytical views, and high-performance T-SQL Stored Procedures for backend data preparation.
* **Included Artifacts:**
  * *(In progress - includes Stored Procedures and analytical query scripts)*

---

## 🛠️ How to Navigate
Click on any of the folder or file links above to inspect the specific code artifacts, documentation, and technical implementation details.
[← Back to Main Repository](../README.md)
