# 📂 DAX Measures & Security Logic

This directory contains advanced Data Analysis Expressions (DAX) scripts designed for high-performance semantic models and dynamic context control in Power BI.

## 📄 Included Files & Technical Rationale:

* **[`advanced_time_intelligence.dax`](./advanced_time_intelligence.dax)**: Enterprise DAX measures implementing YTD calculations with date-context guards, YoY Growth %, 90-day rolling averages, and dynamic revenue contribution ratios (`ALLSELECTED`).
* **[`time_intelligence_logistics.dax`](./time_intelligence_logistics.dax)**: Optimized year-over-year (YoY) calculations using variables (`VAR`) to prevent context evaluation overhead.
* **[`row_level_security.dax`](./row_level_security.dax)**: Dynamic Row-Level Security (RLS) script filtering multi-tenant data securely via user principal mapping (`USERPRINCIPALNAME`).

---

[← Back to Main Repository](../README.md)
