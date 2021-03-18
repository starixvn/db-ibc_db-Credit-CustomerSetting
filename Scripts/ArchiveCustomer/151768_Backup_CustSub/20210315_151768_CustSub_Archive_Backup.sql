/*<info serverAlias="DBARCCUST-bodb_Customer" executers="" isFunction="0"></info>*/
/*
    Created: 20210303@Helen
	Task: Database - Archive sub Accounts data when SMA accounts are deleted at Stage 4 - [151768]
	DB: DBARCCUST-bodb_Customer 
*/
USE bodb_Customer
GO

SELECT subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted 
INTO #custsub_tmp
FROM DBCUST.CUSTDB.dbo.custsub cs WITH (NOLOCK)

CREATE TABLE #custSub(
	[subaccid] [int] ,
	[custid] [int] NOT NULL,
	[username] [varchar](30) NULL,
	[userpwd] [varchar](40) NULL,
	[PageAccess] [varchar](50) NULL,
	[createdate] [datetime] NULL,
	[firstname] [nvarchar](50) NULL ,
	[lastname] [nvarchar](50) NULL ,
	[closed] [bit] NULL ,
	[LoginCount] [tinyint] ,
	[UserName2] [varchar](50) NULL,
	[NicknameLoginOnly] [bit] NULL,
	[IsAllDownline] [bit] NULL,
	[IsDeleted] [bit] NULL,
	Isfinished BIT
)

CREATE TABLE #custSub_batch(
	[subaccid] [int] ,
	[custid] [int] NOT NULL,
	[username] [varchar](30) NULL,
	[userpwd] [varchar](40) NULL,
	[PageAccess] [varchar](50) NULL,
	[createdate] [datetime] NULL,
	[firstname] [nvarchar](50) NULL ,
	[lastname] [nvarchar](50) NULL ,
	[closed] [bit] NULL ,
	[LoginCount] [tinyint] ,
	[UserName2] [varchar](50) NULL,
	[NicknameLoginOnly] [bit] NULL,
	[IsAllDownline] [bit] NULL,
	[IsDeleted] [bit] NULL
)

INSERT INTO #custSub (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)
SELECT cs.subaccid, cs.custid, cs.username, cs.userpwd, cs.PageAccess, cs.createdate, cs.firstname, cs.lastname, cs.closed, cs.LoginCount, cs.UserName2, cs.NicknameLoginOnly, cs.IsAllDownline, cs.IsDeleted
FROM #custsub_tmp cs 
	LEFT JOIN dbo.custsub_old cs_old WITH (NOLOCK) ON cs.subaccid = cs_old.subaccid
	CROSS APPLY (SELECT custid 
				 FROM bodb02.dbo.custinfo ci WITH (NOLOCK)
				 WHERE ci.custid = cs.custid and ci.enabled = 0 ) AS c
WHERE cs_old.subaccid IS NULL 

DECLARE @debug_message VARCHAR(500)
SET @debug_message = CONVERT(VARCHAR(50), GETDATE(), 121)

WHILE (1 = 1)
BEGIN
	
	UPDATE TOP (2000) cs
		SET Isfinished = 1	
	OUTPUT DELETED.subaccid, DELETED.custid, DELETED.username, DELETED.userpwd, DELETED.PageAccess, DELETED.createdate, DELETED.firstname, DELETED.lastname, DELETED.closed, DELETED.LoginCount, DELETED.UserName2, DELETED.NicknameLoginOnly, DELETED.IsAllDownline, DELETED.IsDeleted 
	INTO #custSub_batch (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)		
	FROM #custSub cs
	WHERE Isfinished IS NULL
	
	IF @@ROWCOUNT = 0
		BREAK
		
	RAISERROR (@debug_message, 0, 1) WITH NOWAIT
	
	INSERT INTO custsub_old (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)
	SELECT subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
	FROM #custSub_batch
	
	TRUNCATE TABLE #custSub_batch
		
END

DROP TABLE #custSub
DROP TABLE #custSub_batch
DROP TABLE #custsub_tmp
