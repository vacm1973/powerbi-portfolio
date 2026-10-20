// =====================================================================
// Power Query (M Language) - Limpieza y Transformación de Datos Logísticos
// Descripción: Script ETL ejecutado en Power BI para estandarizar 
//              la información de fletes y eliminar registros nulos.
// =====================================================================

let
    // 1. Conexión a la base de datos origen (SQL Server / Data Warehouse)
    Source = Sql.Database("logistics_server", "LogisticsDW"),
    
    // 2. Selección de la tabla transaccional de envíos
    SchemaTransacciones = Source{[Schema="dbo",Item="FactShipments"]}[Data],
    
    // 3. Filtrar únicamente los registros activos
    FiltrarActivos = Table.SelectRows(SchemaTransacciones, each ([RecordStatus] = "Active")),
    
    // 4. Remover filas con montos de facturación nulos o inválidos
    RemoverNulos = Table.SelectRows(FiltrarActivos, each ([BilledAmount] <> null and [BilledAmount] > 0)),
    
    // 5. Normalizar nombres de transportistas a mayúsculas para mantener consistencia visual
    NormalizarTexto = Table.TransformColumns(RemoverNulos,{{"CarrierName", Text.Upper, type text}}),
    
    // 6. Seleccionar y renombrar las columnas clave para el reporte final de Power BI
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
