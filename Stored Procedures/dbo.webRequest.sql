SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[webRequest]
AS
BEGIN
	DECLARE @BaseUrl VARCHAR(250)= 'ls-preprod.okzim.co.zw:7148/DevNUP-Svc/api/datasmith/wms/v1.0/companies(4b38fcb4-487d-ed11-a38f-005056ba507f)/wmspurchaseOrders?$expand=wmspurchaseLines'
	PRINT @BaseUrl
	DECLARE @Token INT;
	DECLARE @ret INT;

	DECLARE @contentType NVARCHAR(64) = 'application/json'

	DECLARE @json AS TABLE (JsonVal NVARCHAR(max))

	DECLARE @responseText NVARCHAR(2000);
	DECLARE @status NVARCHAR(32);
	DECLARE @statusText NVARCHAR(32);

	EXEC @ret = SP_OACreate 'MSXML2.ServerXMLHTTP', @Token OUT
	IF @ret <> 0 RAISERROR('Unable to open HTTP Connection.', 10, 1)

	EXEC @ret = sp_OAMethod @Token, 'open', NULL, 'GET', @BaseUrl, 'false';
	EXEC @ret = sp_OAMethod @Token, 'SETRequestHeader', NULL, 'Content-type', @contentType;

	EXEC @ret = sp_OAMethod @Token, 'Send', NULL, NULL;

	DECLARE @resultJson NVARCHAR(MAX)
	DECLARE @SessionID VARCHAR(100)

	insert into @json (JsonVal) EXEC SP_OAGetProperty @Token, 'ResponseText'

	SET @resultJson = (select JsonVal from @Json)

	PRINT @resultJson

END
GO
