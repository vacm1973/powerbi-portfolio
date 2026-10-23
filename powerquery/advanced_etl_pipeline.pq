/*
===============================================================================
Power Query (M) Advanced ETL Pipeline
Description: Enterprise-grade M script for custom data cleansing, dynamic unpivoting,
             null imputation, and parameter-driven transformations for Power BI models.
Author: Victor Andres Costa Molina
===============================================================================
*/

let
    // 1. Data Ingestion & SQL Database Connection
    Source = Sql.Database("DatabaseServer_PROD", "DataWarehouse_Analytics"),
    Logistics_Raw = Source{[Schema="dbo", Item="FactTransportOperations"]}[Data],

    // 2. Data Cleansing, Filtering & Type Standardization
    FilterActiveRecords = Table.SelectRows(Logistics_Raw, each ([IsActive] = true or [IsActive] = null)),
    ImputeNullMetrics = Table.ReplaceValue(
        FilterActiveRecords, 
        null, 
        0, 
        Replacer.ReplaceValue, 
        {"Margin", "GrossRevenue", "FreightCost", "TaxAmount"}
    ),
    
    SetStrictDataTypes = Table.TransformColumnTypes(ImputeNullMetrics, {
        {"OperationDate", type date},
        {"CustomerID", Int64.Type},
        {"ChannelID", Int64.Type},
        {"TransportRouteID", Int64.Type},
        {"Margin", type number},
        {"GrossRevenue", type number},
        {"FreightCost", type number},
        {"TaxAmount", type number}
    }),

    // 3. Advanced Custom Column Logic (KPI Categorization)
    AddProfitabilityTier = Table.AddColumn(
        SetStrictDataTypes, 
        "ProfitabilityTier", 
        each if [Margin] >= 50000 then "Tier 1 - High Profit"
             else if [Margin] >= 15000 then "Tier 2 - Medium Profit"
             else "Tier 3 - Low Margin", 
        type text
    ),

    // 4. Data Aggregation & Dynamic Unpivoting for Dimensional Modeling
    GroupOperationalMetrics = Table.Group(
        AddProfitabilityTier, 
        {"CustomerID", "ChannelID", "ProfitabilityTier"}, 
        {
            {"TotalRevenue", each List.Sum([GrossRevenue]), type nullable number},
            {"TotalMargin", each List.Sum([Margin]), type nullable number},
            {"TotalFreightCost", each List.Sum([FreightCost]), type nullable number},
            {"TotalOperationsCount", each Table.RowCount(_), type number}
        }
    ),

    UnpivotFinancialMetrics = Table.UnpivotOtherColumns(
        GroupOperationalMetrics, 
        {"CustomerID", "ChannelID", "ProfitabilityTier"}, 
        "MetricName", 
        "MetricValue"
    ),

    // 5. String Normalization and Final Schema Formatting
    UppercaseMetricLabels = Table.TransformColumns(
        UnpivotFinancialMetrics, 
        {{"MetricName", Text.Upper, type text}}
    ),
    
    // Final Output Table for Power BI Semantic Model
    #"Final_ETL_Transformed_Table" = UppercaseMetricLabels
in
    #"Final_ETL_Transformed_Table"