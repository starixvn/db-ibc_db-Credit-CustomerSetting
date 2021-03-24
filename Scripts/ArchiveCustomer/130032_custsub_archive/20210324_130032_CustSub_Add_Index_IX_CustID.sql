/*<info serverAlias="DBAGE-bodb02,DBEXT-bodb02,DBONUSER-bodb02,DBBOF-bodb02,DBACC-bodb02,DBTP-bodb02,DBWH-bodb02" executers="" isFunction="0"></info>*/
/*
Created: 20210324@Tina
Task:
DBs: all replicated server of publication name CustDB_Customer_Info

Notes: Please deploy all replicated servers for pub CustDB_Customer_Info
db05
db052
db053
db055
db061
db05bk1
DB06C2\DB06
DBTP
DB04Admin1
DB04Admin2
*/
USE bodb02
GO
CREATE NONCLUSTERED INDEX [IX_CustID] ON [dbo].[custSub]
(
[custid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [table_customer]
GO