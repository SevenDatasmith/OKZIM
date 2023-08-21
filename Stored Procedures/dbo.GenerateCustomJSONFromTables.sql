SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GenerateCustomJSONFromTables]
AS
BEGIN
    DECLARE @vJSONData NVARCHAR(MAX);
	DECLARE @vResultJSON NVARCHAR(MAX);
    
    SELECT @vJSONData = (
        SELECT
            PO.SystemID AS id,
            PO.OrderNo AS orderNo,
            PO.BuyFromVendorNo AS buyFromVendorNo,
            PO.BuyFromVendorName AS buyFromVendorName,
            PO.ShipmentMethodCode AS vendorShipmentNo,
            PO.VendorOrderNo AS vendorInvoiceNo,
            PO.PostingDate AS postingDate,
            (
                SELECT
                    POL.DocumentType AS documentType,
                    POL.DocumentNo AS orderNo,
                    POL.[LineNo] AS [lineNo],
                    POL.SystemID AS id,
                    POL.ItemNo AS itemNo,
                    POL.Description AS description,
                    POL.UnitOfMeasureCode AS unitOfMeasureCode,
                    POL.LocationCode AS locationCode,
                    PO.ExpectedRecieptDate AS expectedReceiptDate,
                    POL.Quantity AS rcveQty
                FROM PurchaseOrderLine POL
                WHERE POL.DocumentNo = PO.OrderNo
                FOR JSON PATH
            ) AS wmspurchOrdRcptLines
        FROM PurchaseOrder PO
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    SET @vResultJSON = '{"value": [' + @vJSONData + ']}';
	SELECT @vResultJSON AS JsonData
END;
GO
