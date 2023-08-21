CREATE TABLE [erp].[Log]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Date] [datetime] NOT NULL,
[ApiUrl] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Response] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [erp].[Log] ADD CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and Time when API is called', 'SCHEMA', N'erp', 'TABLE', N'Log', 'COLUMN', N'Date'
GO
