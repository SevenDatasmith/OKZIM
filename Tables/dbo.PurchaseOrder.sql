CREATE TABLE [dbo].[PurchaseOrder]
(
[CompanyID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SystemID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BuyFromVendorNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BuyFromVendorName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BuyFromAddress] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BuyFromAddress2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BuyFromCity] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BuyFromPostCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyFromCountryRegionCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyFromContact] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YourReference] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderDate] [date] NOT NULL,
[PostingDate] [date] NOT NULL,
[DocumentDate] [date] NOT NULL,
[ExpectedRecieptDate] [date] NOT NULL,
[DueDate] [date] NOT NULL,
[ShipmentMethodCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PurchaserCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorOrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuoteNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorShipmentNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PurchaseOrder_VendorShipmentNo] DEFAULT ((0)),
[VendorInvoiceNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PurchaseOrder_VendorInvoiceNo] DEFAULT ((0)),
[Status] [int] NULL CONSTRAINT [DF_PurchaseOrder_Status] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PurchaseOrder] ADD CONSTRAINT [PK_PurchaseOrder] PRIMARY KEY CLUSTERED ([OrderNo]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'0 = New, 1 = In Progress, 2 = Updated, 3 = Uploaded', 'SCHEMA', N'dbo', 'TABLE', N'PurchaseOrder', 'COLUMN', N'Status'
GO
