CREATE TABLE [dbo].[PurchaseOrderLine]
(
[CompanyID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DocumentNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LineNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DocumentType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SystemID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ItemNo] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UnitOfMeasureCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LocationCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Quantity] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OutstandingQuantity] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DirectUnitCost] [decimal] (18, 0) NOT NULL,
[OutstandingAmount] [decimal] (18, 0) NOT NULL,
[ReceivedQuantity] [int] NOT NULL CONSTRAINT [DF_PurchaseOrderLine_ReceiveQuantity] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PurchaseOrderLine] ADD CONSTRAINT [PK_PurchaseLine] PRIMARY KEY CLUSTERED ([DocumentNo], [LineNo]) ON [PRIMARY]
GO
