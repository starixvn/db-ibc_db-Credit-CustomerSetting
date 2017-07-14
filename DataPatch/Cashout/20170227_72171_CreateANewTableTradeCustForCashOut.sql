
  /*
	Created: 20170227Winnie
	Task : Create a new table [TradeCust] for CashOut
	DB: DBCust/CustDB.	Add TradeCust to the Publication CustDB_Customer_Info replicate to DB04x, DB05x, DB06, DBTP
*/


CREATE TABLE [dbo].[TradeCust](
	[custid] [int] NOT NULL,
	VendorID SMALLINT NOT NULL
 CONSTRAINT [PK_TradeCust] PRIMARY KEY CLUSTERED 
(
	[custid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [Dep_CustSetting3rd_table]
) ON [Dep_CustSetting3rd_table]

GO

