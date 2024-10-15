/*<info serverAlias="DBGLOB-GLOBCUSTDB" executers="" viewers="" isFunction="0"></info>*/
USE [GlobCustDB]
GO

CREATE VIEW [dbo].[CustinfoMini]
AS
SELECT [CustID], [username], [username2], [recommend], [mrecommend], [srecommend], [roleid], [SiteDBGroupID], [RepUpdateTime], [Site], [Currency]
FROM CUSTDB.dbo.CustInfoMini

GO

CREATE VIEW [dbo].[CustSubMini]
AS
SELECT [subaccid], [CustID], [username], [username2], [SiteDBGroupID], [RepUpdateTime]
FROM CUSTDB.dbo.CustSubMini
GO

