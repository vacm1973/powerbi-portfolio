# 📊 Power BI & Advanced Business Intelligence Portfolio

> **`Power BI` | `DAX` | `Dimensional Modeling` | `Row-Level Security (RLS)` | `T-SQL`**

A comprehensive Business Intelligence solution featuring advanced DAX time intelligence, star-schema dimensional modeling, dynamic Row-Level Security (RLS), and automated ETL pipelines with SQL and Power Query.

---

## 👨‍💻 Professional Summary

With over **32 years of overall experience in IT/Systems** and **17 years specialized in Business Intelligence & Data Analytics**, I have designed, architected, and deployed robust data solutions, ETL processes, and strategic dashboards for corporate decision-making.

* **Core Stack:** Power BI (Power Query / M, Advanced DAX), SQL Server (T-SQL, Stored Procedures, Performance Tuning), and MicroStrategy.
* **Key Focus:** Dimensional Modeling (Star Schema / Snowflake), Query Optimization, Process Automation, and Data Governance.

---

## 🏗️ Architecture & Technical Stack

- **BI & Visualization:** Power BI Service, Power BI Desktop, Advanced DAX, Power Query (M Query).
- **Data Modeling:** Star Schema Design, Cardinality Optimization, Dynamic Row-Level Security (RLS).
- **Data Engineering & SQL:** T-SQL, Stored Procedures, CTEs, Window Functions, Performance Tuning.
- **Tools & Governance:** Git, GitHub, SQL Server Management Studio (SSMS), Azure Data Studio.

---

## 🗂️ Repository Structure & Technical Breakdown

Each directory and code artifact in this repository serves a specific architectural purpose in the data pipeline:

| Directory | Technical Purpose | Quick Access |
| :--- | :--- | :--- |
| 📁 **`powerquery/`** | ETL data cleansing, unpivoting, and transformation workflows (M Language). | [View Power Query](./powerquery/README.md) |
| 📁 **`dax/`** | Advanced DAX measures, Time Intelligence patterns, and dynamic RLS logic. | [View DAX Code](./dax/README.md) |
| 📁 **`sql/`** | T-SQL stored procedures, analytical views, and database tuning scripts. | [View SQL Scripts](./sql/README.md) |
| 📁 **`assets/`** | Visual aids, dashboard previews, and architecture diagrams. | [Explore Assets](./assets/) |

---

### 📄 Documented Artifacts & Rationale

#### 1. Power Query / M Transformations (`/powerquery`)
* [`advanced_etl_pipeline.pq`](./powerquery/advanced_etl_pipeline.pq): Advanced M pipeline implementing dynamic unpivoting, null imputation, custom profitability tiers, and string normalization for star-schema modeling.
* [`logistics_transformations.pq`](./powerquery/logistics_transformations.pq): ETL script filtering active records, removing billing nulls, and normalizing text case for operational reporting.

#### 2. DAX Measures & Business Logic (`/dax`)
* [`advanced_time_intelligence.dax`](./dax/advanced_time_intelligence.dax): Production-ready DAX calculations covering YTD with date-context guards, YoY Growth %, 90-day rolling averages, and dynamic contribution analysis (`ALLSELECTED`).
* [`time_intelligence_logistics.dax`](./dax/time_intelligence_logistics.dax): Optimized YoY calculations using variables (`VAR`) to minimize context evaluation overhead.
* [`row_level_security.dax`](./dax/row_level_security.dax): Dynamic RLS script filtering multi-tenant data via `USERPRINCIPALNAME`.

#### 3. T-SQL & Database Layer (`/sql`)
* [`sp_traffic_analytics_reconciliation.sql`](./sql/sp_traffic_analytics_reconciliation.sql): Self-contained script with DDL, mock inserts, view (`VW_FACT_TRAFICO_PRESENTACION`), and procedure (`SP_TRAFICO_PRESENTACION`) for multi-stop traffic aggregation.
* [`logistics_transformations.sql`](./sql/logistics_transformations.sql): Staging transformation script normalizing hub entities and data quality flags.
* [`logistics_reconciliation.sql`](./sql/logistics_reconciliation.sql): Automated audit script using CTEs and window functions for invoice variance analysis.
* [`insert_dummy_data.sql`](./sql/insert_dummy_data.sql): Relational mock dataset setup for local Query and DAX testing.

---

**Victor Andres Costa Molina**  
Senior Data Engineer | BI & Data Architecture  
[GitHub Profile](https://github.com/vacm1973)
