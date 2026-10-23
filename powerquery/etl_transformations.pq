/*
===============================================================================
Power Query (M) ETL Pipeline - Data Transformation & Cleansing
Description: Advanced M script for unpivoting, dynamic column transformation,
             and merging logistics/sales data for Power BI models.
===============================================================================
*/

let
    // 1. Fetching raw dataset from SQL Database
    Source = Sql.Database("ServerInstance", "DataWarehouse_BI"),
    Logistics_Raw = Source{[Schema="dbo", Item="FactLogistics"]}[Data],

    // 2. Data Cleansing & Type Casting
    FilterActiveRecords = Table.SelectRows(Logistics_Raw, each ([IsActive] = true or [IsActive] = null)),
    ReplaceNullValues = Table.ReplaceValue(FilterActiveRecords, null, 0, Replacer.ReplaceValue, {"Margin", "Revenue", "TransportCost"}),
    SetDataTypes = Table.TransformColumnTypes(ReplaceNullValues, {
        {"TransactionDate", type date},
        {"CustomerID", Int64.Type},
        {"ChannelID", Int64.Type},
        {"RouteID", Int64.Type},
        {"Margin", type number},
        {"Revenue", type number},
        {"TransportCost", type number}
    }),

    // 3. Conditional Custom Logic
    AddProfitCategory = Table.AddColumn(SetDataTypes, "MarginCategory", each 
        if [Margin] >= 50000 then "High Profit"
        else if [Margin] >= 10000 then "Medium Profit"
        else "Low Margin", 
        type text
    ),

    // 4. Data Aggregation & Dynamic Unpivoting
    GroupMetrics = Table.Group(AddProfitCategory, {"CustomerID", "ChannelID", "MarginCategory"}, {
        {"TotalRevenue", each List.Sum([Revenue]), type nullable number},
        {"TotalMargin", each List.Sum([Margin]), type nullable number},
        {"TotalCost", each List.Sum([TransportCost]), type nullable number},
        {"TotalShipments", each Table.RowCount(_), type number}
    }),

    UnpivotFinancialMetrics = Table.UnpivotOtherColumns(
        GroupMetrics, 
        {"CustomerID", "ChannelID", "MarginCategory"}, 
        "MetricName", 
        "MetricValue"
    ),

    // 5. Normalization and Custom Function Invocation
    CapitalizeMetrics = Table.TransformColumns(UnpivotFinancialMetrics, {{"MetricName", Text.Upper, type text}}),
    
    // Final Output Table
    #"Final_Transformed_Table" = CapitalizeMetrics
in
    #"Final_Transformed_Table"
