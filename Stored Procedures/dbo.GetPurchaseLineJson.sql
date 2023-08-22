SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetPurchaseLineJson]
AS
BEGIN
	DECLARE @pCompanyID NVARCHAR(50) = '4b38fcb4-487d-ed11-a38f-005056ba507f'
	DECLARE @vOrderNo NVARCHAR(50) = ''
	DECLARE @vJSONData NVARCHAR(MAX)

	DECLARE @VExpectedReceiptDate DATE

	SELECT @VExpectedReceiptDate = ExpectedRecieptDate
	FROM dbo.PurchaseOrder
	WHERE CompanyID = @pCompanyID;	
	PRINT @VExpectedReceiptDate

	DECLARE Cursor_PurchaseOrder CURSOR FOR
		SELECT
			PO.OrderNo
		FROM dbo.PurchaseOrder PO
		WHERE PO.CompanyID = @pCompanyID;

		OPEN Cursor_PurchaseOrder;

		FETCH NEXT FROM Cursor_PurchaseOrder INTO @vOrderNo;
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @vJSONData = (
				SELECT
					PO.SystemID AS id,
					PO.OrderNo AS orderNo,
					PO.BuyFromVendorNo AS buyFromVendorNo,
					PO.BuyFromVendorName AS buyFromVendorName,
					PO.VendorShipmentNo AS vendorShipmentNo,
					PO.VendorInvoiceNo AS vendorInvoiceNo,
					PO.PostingDate AS postingDate,
					(
						SELECT
							POL.DocumentType AS documentType,
							POL.DocumentNo AS orderNo,
							POL.[LineNo] AS [lineNo],
							POL.SystemID AS id,
							POL.ItemNo AS itemNo,
							POL.[Description] AS [description],
							POL.UnitOfMeasureCode AS unitOfMeasureCode,
							POL.LocationCode AS locationCode,
							PO.ExpectedRecieptDate AS expectedReceiptDate,
							POL.ReceivedQuantity AS rcveQty
						FROM dbo.PurchaseOrderLine POL
						WHERE POL.DocumentNo = PO.OrderNo
						FOR JSON PATH
					) AS wmspurchOrdRcptLines
					FROM dbo.PurchaseOrder PO
					WHERE PO.OrderNo = @vOrderNo
					FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			);
			--SELECT @vJSONData AS JSONDATA
			FETCH NEXT FROM Cursor_PurchaseOrder INTO @vOrderNo;
		END
		CLOSE Cursor_PurchaseOrder;
		DEALLOCATE Cursor_PurchaseOrder;

END
GO
