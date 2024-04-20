# Fabric-Saturday 20th April 2024

## Incremental Refresh in Microsoft Fabric
### Ingest Data from On-Prem Data using a data pipeline
  To demonstrate Incremental refresh, we will be using  SalesOrderDetail table from the publicly available AdventureWorks2019 On-Prem database which will be ingested into a lakehouse using copy activity. 
  A fraction of the SalesOrderDetail will be used: 
  
  1. Within a Fabric-enabled workspace, create a lakehouse named LH1
  2. Create a pipeline named InitialDataLoad 
  3. Create a copy activity, and connect to SQL Server (Make sure to configure your On-Prem Data data gateway)
  4. Connect to your data source using this query: 

    SELECT * FROM [AdventureWorks2019].[Sales].[SalesOrderDetail] WHERE ModifiedDate <= '2011-12-31' (Fraction of dataset so we can demo incremental load later) 
      
  6. Pick LH1 as you destination
  7. Choose load new table and specify the name of your table as SalesOrderTable
  8. uncheck enable partitions
  9. Uncheck transfer immediately and click OK. 

### Creating Warehouse and database objects
  Fabric items will be created within the warehouse for incremental loading:
  
  1. A watermarktable (this table within incremental loading context keep metadata of SaleOrderTable which will be used to track the freshness of data ingested into the warehouse)
  2. A store procedure to update the watermarktable:

     1. On the explorer, click the + icon to add your LH1 to the warehouse.
     2. Create a new SQL query
     3. Use the SQL query file in this repository named WarehouseObjects
          
### Create a pipeline for incremental refresh 
  In your pipeline: 

  1. Add a lookup activity and name it LookupOldWaterMarkActivity
  2. Under the settings tab, pick your warehouse WH1 and select the watermarktable.
  3. Keep the first row checked.
  4. Add a second lookup activity and name it LookUpNewWaterMarkActivity
  5. Under the setting tab, pick your warehouse WH1 and select query 
  6. Paste this query in the space provided:
     
             select MAX(ModifiedDate) as NewWatermarkvalue from SalesOrderTable
     
  9. Add a copy activity to your Canva and connect it to the two look up activities on the "On success"
  10. Under the source tab, select warehouse,  pick WH1, and use query
  11. In the space provided, paste the following query:

     select * from SalesOrderTable where ModifiedDate > '@{activity('LookupOldWaterMarkActivity').output.firstRow.WatermarkValue}' and ModifiedDate <= '@{activity('LookupNewWaterMarkActivity').output.firstRow.NewWatermarkvalue}'

  12. Under Destination, Pick lakehouse and Select LH1
  13. Select tables, click on new and name the table IncrementingSaleOrder
  14. Expand advanced and pick append as table action
  15. Add stored procedure activity to the pipeline and link the copy activity to it.
  16. Under the settings tab, pick warehouse and select WH1
  17. Select the procedure [dbo].[usp_write_watermark]
  18. Under stored procedure parameter, click on import and provided the following parameters for modifieddate and table name :
      
              @{activity('LookupNewWaterMarkActivity').output.firstRow.NewWatermarkvalue}
      
              @{activity('LookupOldWaterMarkActivity').output.firstRow.TableName}
  19. Go to your LH1 and check for the incrementingSaleOrder

### Test the Incrementation

  1. Open the InitialDataLoad pipeline
  2. Under the source tab of the copy activity, replace the query with this (this new query updates the SalesOrderTable with data from the On-Prem Source):
     
             SELECT * FROM [AdventureWorks2019].[Sales].[SalesOrderDetail]
     
  4. Add a script activity to your pipeline, on the general tab, name the activity KeepWarehouseSync
  5. Link the script activity to the copy activity "On Success"
  6. Under the settings tab, select warehouse and pick WH1
  7. In the Query space provided, paste the following query:

         DROP TABLE [WH1].[dbo].[SalesOrderTable];
         --keep SALES ORDER TABLE up to date
          CREATE TABLE [WH1].[dbo].[SalesOrderTable]
         AS
          SELECT * FROM [LH1].[dbo].[SalesOrderTable];
<img width="884" alt="image" src="https://github.com/DonFrancis1/Fabric-Saturday/assets/88105784/72522293-b716-49db-b050-010ac40c815e">

  8. Save and run the Pipeline.
  9. Go to IncrementalLoad Pipeline and trigger another.
  10. Go back to your WH1 and confirm the value in the watermark table to be the maximum ModifiedDate
<img width="891" alt="image" src="https://github.com/DonFrancis1/Fabric-Saturday/assets/88105784/1972a568-4ab6-40e9-b18d-26a6fc430fdb">

We have been able to load data from an on Prem Data source using Incremental Data Load method. 
