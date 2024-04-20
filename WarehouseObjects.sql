--Creating warehouse table using CTAS statatement.
CREATE TABLE [WH1].[dbo].[SalesOrderTable] 
AS 
SELECT * FROM [LH1].[dbo].[SalesOrderTable]; 

--Create watermark table
create table [WH1].[dbo].[watermarktable]
(
TableName varchar(255),
WatermarkValue DATETIME2(6),
);

--INSPECT your table 
SELECT * FROM [WH1].[dbo].[watermarktable];

--INSERT DEFAULT RECORD IN WATERMARK TABLE
INSERT INTO watermarktable
VALUES ('SalesOrderDetail','1/1/2010 12:00:00 AM')

--INSPECT your table 
SELECT * FROM [WH1].[dbo].[watermarktable];


--CREATE STORE PROCEDURE TO UPDATE WATERMARK TABLE

CREATE PROCEDURE usp_write_watermark @ModifiedDate datetime, @TableName varchar(50)
AS
BEGIN
UPDATE watermarktable
SET [WatermarkValue] = @ModifiedDate
WHERE [TableName] = @TableName
END;

