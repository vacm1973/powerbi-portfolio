// =====================================================================
// Project: Power Query (M Language) Logistics Data Cleaning ETL
// Description: Transformation script executed in Power BI to standardize 
//              freight data and filter out invalid records.
// =====================================================================

let
    // 1. Connect to source database (SQL Server / Data Warehouse)
    Source = Sql.Database("logistics_server", "LogisticsDW"),
    
    // 2. Select transactional shipments table
    SchemaTransacciones = Source{[Schema="dbo",Item="FactShipments"]}[Data],
    
    // 3. Filter active records only
    FiltrarActivos = Table.SelectRows(SchemaTransacciones, each ([RecordStatus] = "Active")),
    
    // 4. Remove rows with null or invalid billing amounts
    RemoverNulos = Table.SelectRows(FiltrarActivos, each ([BilledAmount] <> null and [BilledAmount] > 0)),
    
    // 5. Normalize carrier names to uppercase for visual consistency
    NormalizarTexto = Table.TransformColumns(RemoverNulos,{{"CarrierName", Text.Upper, type text}}),
    
    // 6. Select and reorder key columns for the final Power BI report
    ReorderedColumns = Table.SelectColumns(NormalizarTexto, {
        "ShipmentTrackingNumber", 
        "CarrierName", 
        "OriginHub", 
        "DestinationHub", 
        "PackageWeightKg", 
        "BilledAmount", 
        "DispatchDate"
    })
in
    ReorderedColumns
