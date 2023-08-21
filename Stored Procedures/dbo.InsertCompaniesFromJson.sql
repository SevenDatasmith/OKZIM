SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[InsertCompaniesFromJson]
    @jsonData NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO Company(
        Id, SystemVersion, Name, DisplayName, BusinessProfileId, SystemCreatedAt, SystemCreatedBy, SystemModifiedAt, SystemModifiedBy
    )
    SELECT
        JSON_VALUE(value, '$.id'),
        JSON_VALUE(value, '$.systemVersion'),
        JSON_VALUE(value, '$.name'),
        JSON_VALUE(value, '$.displayName'),
        JSON_VALUE(value, '$.businessProfileId'),
        CONVERT(DATETIME, JSON_VALUE(value, '$.systemCreatedAt'), 127),
        JSON_VALUE(value, '$.systemCreatedBy'),
        CONVERT(DATETIME, JSON_VALUE(value, '$.systemModifiedAt'), 127),
        JSON_VALUE(value, '$.systemModifiedBy')
    FROM OPENJSON(@jsonData, '$.value');
END;
GO
