# Fabric-Saturday

## Incremental Refresh in Microsoft Fabric
### Ingest Data from On-Prem Data using a data pipeline
  To demonstrate Incremental refresh, we will be using  SalesOrderDetail table from the publicly available AdventureWorks2019 On-Prem database which will be ingested into a lakehouse using copy activity. 
  A fraction of the SalesOrderDetail will be used: 

    1. Within a Fabric-enabled workspace, create a lakehouse named LH1
    2. Create a pipeline named InitialDataLoad 
    3. Create a copy activity, and connect to SQL Server (Make sure to configure your On-Prem Data data gateway)
    4. Connect to your data source using this query:  SELECT * FROM [AdventureWorks2019].[Sales].[SalesOrderDetail] WHERE ModifiedDate <= '2011-12-31' (Fraction of dataset so we can demo incremental load later)
    5. Pick LH1 as you destination
    6. Choose load new table and specify the name of your table as SalesOrderTable
    7. uncheck enable partitions
    8. Uncheck transfer immediately and click OK. 

### Creating Warehouse and database objects
  Fabric items will be created within the warehouse for incremental loading:
    1. a watermarktable (this table within incremental loading context keep metadata of SaleOrderTable which will be used to track the freshness of data ingested into the warehouse)
    2. a store procedure to update the watermarktable:
        1. On the explorer, click the + icon to add your LH1 to the warehouse.
        2. Create a new SQL query
        3. Use the SQL query in the repository named WarehouseObjects
### Create a pipeline for incremental refresh 
  
