SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ParseAndSaveJsonData]
    @pJsonData NVARCHAR(MAX)
AS
BEGIN
	DECLARE @vErrorID INT = 51000, @vErrorDesc VARCHAR(MAX) = ''

	IF(LEN(@pJsonData) <= 0)
	BEGIN
		SET @vErrorDesc = 'Empty Json body'
		GOTO Failure
	END

	DECLARE @Index INT = 0;
	DECLARE @TotalRecords INT = JSON_QUERY(@pJsonData, '$.value') -- Assuming the JSON array is in the 'value' key.

	WHILE @Index < @TotalRecords
	BEGIN
		DECLARE @No nvarchar(100) = JSON_VALUE(@pJsonData, CONCAT('$.value[', @Index, '].no')); 
		IF EXISTS (SELECT 1 FROM PurchaseOrder WHERE [No] = JSON_VALUE(@pJsonData, CONCAT('$.value[', @Index, '].no')))
		BEGIN
			SET @vErrorDesc = 'Record already exists for vNo: ' + @No
			GOTO Failure
			RETURN;
		END;

		SET @Index = @Index + 1;
	END;


    INSERT INTO PurchaseOrder
		([No], BuyFromVendorNo, BuyFromVendorName, BuyFromAddress, BuyFromAddress2, BuyFromCity, BuyFromPostCode, BuyFromCountryRegionCode, BuyFromContact, YourReference,
		OrderDate, PostingDate, DocumentDate, ExpectedRecieptDate, DueDate, ShipmentMethodCode, LocationCode, PurchaseCode, VendorOrderNo, QuoteNo, SystemID)
    SELECT
        JSON_VALUE(value, '$.no'),
        JSON_VALUE(value, '$.buyFromVendorNo'),
        JSON_VALUE(value, '$.buyFromVendorName'),
		JSON_VALUE(value, '$.buyFromAddress'),
		JSON_VALUE(value, '$.buyFromAddress2'),
		JSON_VALUE(value, '$.buyFromCity'),
		JSON_VALUE(value, '$.buyFromPostCode'),
		JSON_VALUE(value, '$.buyFromCountryRegionCode'),
		JSON_VALUE(value, '$.buyFromContact'),
		JSON_VALUE(value, '$.yourReference'),
        CONVERT(DATE, JSON_VALUE(value, '$.orderDate'), 23),
        CONVERT(DATE, JSON_VALUE(value, '$.postingDate'), 23),
		CONVERT(DATE, JSON_VALUE(value, '$.documentDate'), 23),
		CONVERT(DATE, JSON_VALUE(value, '$.expectedReceiptDate'), 23),
		CONVERT(DATE, JSON_VALUE(value, '$.dueDate'), 23),
		JSON_VALUE(value, '$.shipmentMethodCode'),
        JSON_VALUE(value, '$.locationCode'),
		JSON_VALUE(value, '$.purchaserCode'),
		JSON_VALUE(value, '$.vendorOrderNo'),
		JSON_VALUE(value, '$.quoteNo'),
        JSON_VALUE(value, '$.systemId')
    FROM OPENJSON(@pJsonData, '$.value');

    INSERT INTO PurchaseOrderLine(DocumentNo, [LineNo], DocumentType, ItemNo, [Description], UnitOfMeasureCode, LocationCode, Quantity, OutstandingQuantity, DirectUnitCost, OutstandingAmount, SystemID)
    SELECT       
        JSON_VALUE(line.value, '$.documentNo'),
        JSON_VALUE(line.value, '$.lineNo'),
		JSON_VALUE(line.value, '$.documentType'),
        JSON_VALUE(line.value, '$.itemNo'),
        JSON_VALUE(line.value, '$.description'),
        JSON_VALUE(line.value, '$.unitOfMeasureCode'),
		JSON_VALUE(line.value, '$.locationCode'),
        JSON_VALUE(line.value, '$.quantity'),
        JSON_VALUE(line.value, '$.outstandingQuantity'),
        JSON_VALUE(line.value, '$.directUnitCost'),
        JSON_VALUE(line.value, '$.outstandingAmount'),
        JSON_VALUE(line.value, '$.systemId')
    FROM OPENJSON(@pJsonData, '$.value')
    CROSS APPLY OPENJSON(value, '$.wmspurchaseLines') AS line;

	IF @@Error <> 0
	BEGIN
		SET @vErrorDesc = ERROR_MESSAGE() 
		GOTO Failure
	END

	RETURN 1 

	Failure:
		THROW @vErrorID, @vErrorDesc, 1;
END;
GO
