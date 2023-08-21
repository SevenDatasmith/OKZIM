SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ConvertDataToJson]
AS
BEGIN
    DECLARE @jsonResult NVARCHAR(MAX);

    SELECT
        @jsonResult = (
            SELECT
                Id,
                SystemVersion,
                Name,
                DisplayName,
                BusinessProfileId,
                SystemCreatedAt,
                SystemCreatedBy,
                SystemModifiedAt,
                SystemModifiedBy
            FROM Company
            FOR JSON AUTO
        );

    SELECT @jsonResult AS JsonResult;
END;
GO
