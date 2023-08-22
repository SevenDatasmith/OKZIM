SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PopulatePurchaseOrderLine]
    @pJsonData NVARCHAR(MAX)
AS
BEGIN
	DECLARE @vErrorID INT = 51000, @vErrorDesc VARCHAR(MAX) = ''

	DECLARE @vEtag NVARCHAR(50) = '',
	@vDocumentNo  NVARCHAR(50) = '',
	@vLineNo INT = 0,
	@vDocumentType  VARCHAR(10) = '',
	@vSystemID NVARCHAR(50) = '',
	@vItemNo  NVARCHAR(15) = '',
	@vDescription  NVARCHAR(50) = '',
	@vUnitOfMeasureCode  VARCHAR(10) = '',
	@vLocationCode INT = 0,
	@vQuantity INT = 0,
	@vOutstandingQuantity INT = 0,
	@vDirectUnitCost  DECIMAL(18,0) = 0.0,
	@vOutstandingAmount DECIMAL(18,0) = 0.0	

	DECLARE @vSampleObject NVARCHAR(max) 
	DECLARE @vSampleJson NVARCHAR(MAX);

	IF(LEN(@pJsonData) <= 0)
	BEGIN
		SET @vErrorDesc = 'Empty Json body'
		GOTO Failure
	END
	
	DECLARE _Cursorr CURSOR FOR  Select value From OPENJSON(@pJsonData) 
	OPEN _Cursorr 
	FETCH NEXT FROM _Cursorr INTO @vSampleObject		
		WHILE @@FETCH_STATUS = 0 
		BEGIN
			SELECT 
				@vDocumentType = JSON_VALUE(@vSampleObject, '$.documentType'),
				@vDocumentNo = JSON_VALUE(@vSampleObject, '$.documentNo'),
				@vLineNo = JSON_VALUE(@vSampleObject, '$.lineNo'),
				@vSystemID = JSON_VALUE(@vSampleObject, '$.systemId'),
				@vItemNo = JSON_VALUE(@vSampleObject, '$.itemNo'),
				@vDescription = JSON_VALUE(@vSampleObject, '$.description'),
				@vUnitOfMeasureCode = JSON_VALUE(@vSampleObject, '$.unitOfMeasureCode'),
				@vLocationCode = JSON_VALUE(@vSampleObject, '$.locationCode'),
				@vQuantity = JSON_VALUE(@vSampleObject, '$.quantity'),
				@vOutstandingQuantity = JSON_VALUE(@vSampleObject, '$.outstandingQuantity'),
				@vDirectUnitCost = JSON_VALUE(@vSampleObject, '$.directUnitCost'),
				@vOutstandingAmount = JSON_VALUE(@vSampleObject, '$.outstandingAmount')				
				
				IF (SELECT COUNT(*) FROM PurchaseOrderLine WHERE DocumentNo  = @vDocumentNo AND [LineNo] = @vLineNo ) > 0
				BEGIN
					UPDATE PurchaseOrderLine SET
					DocumentType = @vDocumentType,
					SystemID = @vSystemID,
					ItemNo = @vItemNo,
					[Description] = @vDescription,
					UnitOfMeasureCode = @vUnitOfMeasureCode,
					LocationCode = @vLocationCode,
					Quantity = @vQuantity,
					OutstandingQuantity = @vOutstandingQuantity,
					DirectUnitCost = @vDirectUnitCost,
					OutstandingAmount = @vOutstandingAmount					
				WHERE DocumentNo = @vDocumentNo AND [LineNo] = @vLineNo
				END
				ELSE
				BEGIN
					INSERT INTO PurchaseOrderLine(DocumentNo, [LineNo],  DocumentType, SystemID, ItemNo, [Description], UnitOfMeasureCode, LocationCode, Quantity, OutstandingQuantity, 
						DirectUnitCost, OutstandingAmount)
					VALUES (
						@vDocumentNo, @vLineNo,  @vDocumentType, @vSystemID, @vItemNo, @vDescription, @vUnitOfMeasureCode, @vLocationCode, @vQuantity, @vOutstandingQuantity, @vDirectUnitCost, 
						@vOutstandingAmount)        
				END

		FETCH NEXT FROM _Cursorr INTO @vSampleObject			
		END
	CLOSE _Cursorr
	DEALLOCATE _Cursorr
	

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
