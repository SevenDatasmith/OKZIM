SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PopulatePurchaseOrder]
    @pJsonData NVARCHAR(MAX)
AS
BEGIN
	DECLARE @vErrorID INT = 51000, @vErrorDesc VARCHAR(MAX) = ''

	DECLARE 
	@vOrderNo  NVARCHAR(50) = '',
	@vEtag NVARCHAR(100) = '',
	@vSystemID NVARCHAR(50) = '',
	@vBuyFromVendorNo  NVARCHAR(20) = '',
	@vBuyFromVendorName  NVARCHAR(50) = '',
	@vBuyFromAddress  NVARCHAR(50) = '',
	@vBuyFromAddress2  NVARCHAR(50) = '',
	@vBuyFromCity  NVARCHAR(15) = '',
	@vBuyFromPostCode  NVARCHAR(15) = '',
	@vBuyFromCountryRegionCode  NVARCHAR(15) = '',
	@vBuyFromContact NVARCHAR(15) = '',
	@vYourReference NVARCHAR(15) = '',
	@vOrderDate Date,
	@vPostingDate Date,
	@vDocumentDate Date,
	@vExpectedRecieptDate Date,
	@vDueDate Date,
	@vShipmentMethodCode NVARCHAR(15) = '',
	@vLocationCode INT = 0,
	@vPurchaserCode NVARCHAR(15) = '',
	@vVendorOrderNo NVARCHAR(15) = '',
	@vQuoteNo NVARCHAR(15) = ''
	

	DECLARE @vSampleObject NVARCHAR(max) 
	DECLARE @vSampleJson NVARCHAR(MAX);
	DECLARE @vPurchaseLinesArray NVARCHAR(MAX);

	SELECT @vSampleJson = JSON_QUERY(@pJsonData, '$.value') FROM OPENJSON(@pJsonData, '$');

	IF(LEN(@pJsonData) <= 0)
	BEGIN
		SET @vErrorDesc = 'Empty Json body'
		GOTO Failure
	END
	
	DECLARE _Cursor CURSOR FOR Select value From OPENJSON(@vSampleJson) 
	OPEN _Cursor 
	FETCH NEXT FROM _Cursor INTO @vSampleObject		
		WHILE @@FETCH_STATUS = 0 
		BEGIN
			SELECT 
				@vSystemID = JSON_VALUE(@vSampleObject, '$.systemId'),
				@vOrderNo = JSON_VALUE(@vSampleObject, '$.orderNo'),
				@vBuyFromVendorNo = JSON_VALUE(@vSampleObject, '$.buyFromVendorNo'),
				@vBuyFromVendorName = JSON_VALUE(@vSampleObject, '$.buyFromVendorName'),
				@vBuyFromAddress = JSON_VALUE(@vSampleObject, '$.buyFromAddress'),
				@vBuyFromAddress2 = JSON_VALUE(@vSampleObject, '$.buyFromAddress2'),
				@vBuyFromCity = JSON_VALUE(@vSampleObject, '$.buyFromCity'),
				@vBuyFromPostCode = JSON_VALUE(@vSampleObject, '$.buyFromPostCode'),
				@vBuyFromCountryRegionCode = JSON_VALUE(@vSampleObject, '$.buyFromCountryRegionCode'),
				@vBuyFromContact = JSON_VALUE(@vSampleObject, '$.buyFromContact'),
				@vYourReference = JSON_VALUE(@vSampleObject, '$.yourReference'),
				@vOrderDate = CONVERT(DATE, JSON_VALUE(@vSampleObject, '$.orderDate'), 23),
				@vPostingDate = CONVERT(DATE, JSON_VALUE(@vSampleObject, '$.postingDate'), 23),
				@vDocumentDate = CONVERT(DATE, JSON_VALUE(@vSampleObject, '$.documentDate'), 23),
				@vExpectedRecieptDate = CONVERT(DATE, JSON_VALUE(@vSampleObject, '$.expectedReceiptDate'), 23),
				@vDueDate = CONVERT(DATE, JSON_VALUE(@vSampleObject, '$.dueDate'), 23),
				@vShipmentMethodCode = JSON_VALUE(@vSampleObject, '$.shipmentMethodCode'),
				@vLocationCode = JSON_VALUE(@vSampleObject, '$.locationCode'),
				@vPurchaserCode = JSON_VALUE(@vSampleObject, '$.purchaserCode'),
				@vVendorOrderNo = JSON_VALUE(@vSampleObject, '$.vendorOrderNo'),
				@vQuoteNo = JSON_VALUE(@vSampleObject, '$.quoteNo')
				
				
				IF (SELECT COUNT(OrderNo) FROM PurchaseOrder WHERE OrderNo = @vOrderNo ) > 0
					BEGIN
						UPDATE PurchaseOrder SET
								SystemID = @vSystemID,
								BuyFromVendorNo = @vBuyFromVendorNo,
								BuyFromVendorName = @vBuyFromVendorName,
								BuyFromAddress = @vBuyFromAddress,
								BuyFromAddress2 = @vBuyFromAddress2,
								BuyFromCity = @vBuyFromCity,
								BuyFromPostCode = @vBuyFromPostCode,
								BuyFromCountryRegionCode = @vBuyFromCountryRegionCode,
								BuyFromContact = @vBuyFromContact,
								YourReference = @vYourReference,
								OrderDate = @vOrderDate,
								PostingDate = @vPostingDate,
								DocumentDate = @vDocumentDate,
								ExpectedRecieptDate = @vExpectedRecieptDate,
								DueDate = @vDueDate,
								ShipmentMethodCode = @vShipmentMethodCode,
								LocationCode = @vLocationCode,
								PurchaserCode = @vPurchaserCode,
								VendorOrderNo = @vVendorOrderNo,
								QuoteNo = @vQuoteNo								
						WHERE OrderNo = @vOrderNo
					END
				ELSE
					BEGIN
						INSERT INTO PurchaseOrder (OrderNo, SystemID, BuyFromVendorNo, BuyFromVendorName, BuyFromAddress, BuyFromAddress2, BuyFromCity, BuyFromPostCode, BuyFromCountryRegionCode, BuyFromContact, 
							YourReference, OrderDate, PostingDate, DocumentDate, ExpectedRecieptDate, DueDate, ShipmentMethodCode, LocationCode, PurchaserCode, VendorOrderNo, QuoteNo)
						VALUES (
							@vOrderNo, @vSystemID, @vBuyFromVendorNo, @vBuyFromVendorName, @vBuyFromAddress, @vBuyFromAddress2, @vBuyFromCity, @vBuyFromPostCode, @vBuyFromCountryRegionCode, @vBuyFromContact, @vYourReference, 
							@vOrderDate, @vPostingDate, @vDocumentDate, @vExpectedRecieptDate, @vDueDate, @vShipmentMethodCode, @vLocationCode, @vPurchaserCode, @vVendorOrderNo, @vQuoteNo)
        
					END

				SELECT @vPurchaseLinesArray = JSON_QUERY(@vSampleObject, '$.wmspurchaseLines') FROM OPENJSON(@vSampleObject, '$');
				EXEC PopulatePurchaseOrderLine @vPurchaseLinesArray

			FETCH NEXT FROM _Cursor INTO @vSampleObject			
		END
	CLOSE _Cursor
	DEALLOCATE _Cursor	

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
