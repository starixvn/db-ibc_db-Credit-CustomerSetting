/*<info serverAlias="DBHIS-bodb_CustHistory" executers="" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240628@Louisa
	 Task: init structure [Redmine:#204370]
	 DB: DBTP-bodb02
*/

USE bodb_CustHistory
GO

DROP TABLE IF EXISTS Dest_ServiceTransform
GO

CREATE TABLE Dest_ServiceTransform
(
	TableName		VARCHAR(200) NOT NULL
	,Interval		INT			 NOT NULL
	,rID			BIGINT		 NOT NULL
	,BatchSize		INT			 NOT NULL
	,SPSelect		VARCHAR(200) NOT NULL
	,SPInsert		VARCHAR(200) NOT NULL
	,StatusID		TINYINT		 NOT NULL
	,SiteDBGroupID	SMALLINT	 NOT NULL		
	,UpdateTime		DATETIME2
)
GO

ALTER TABLE [dbo].[Dest_ServiceTransform] ADD  CONSTRAINT [PK_Dest_ServiceTransform] PRIMARY KEY CLUSTERED 
(
	TableName, SiteDBGroupID
)
GO
CREATE NONCLUSTERED INDEX [IX_Dest_ServiceTransform_StatusID] ON [dbo].[Dest_ServiceTransform]
(
	[StatusID] ASC
)
GO

---------------INIT DATA--------------------------------------------

---CLEAN UP DATA ON SIT:

IF @@SERVERNAME = 'SITDBCUST'
BEGIN
	TRUNCATE TABLE BetSetting_Member_History

	TRUNCATE TABLE BetSetting_Agent_History

	TRUNCATE TABLE BetSetting3rd_Member_History

	TRUNCATE TABLE BetSetting3rd_Agent_History

END


INSERT INTO  Dest_ServiceTransform 
(	
	TableName, Interval
	, rID, BatchSize
	, SPSelect, SPInsert, StatusID ,SiteDBGroupID ,UpdateTime	
)	
VALUES('BetSetting_Member_History'		, 1000, 0, 1000, 'ServiceTransform_BetSetting_Member_Select'	, 'ServiceTransform_BetSetting_Member_Insert'	, 1, 0, SYSDATETIME() )
	 ,( 'BetSetting_Agent_History'		, 1000, 0, 1000, 'ServiceTransform_BetSetting_Agent_Select'		, 'ServiceTransform_BetSetting_Agent_Insert'	, 1, 0, SYSDATETIME() )
	 ,( 'BetSetting3rd_Member_History'	, 1000, 0, 1000, 'ServiceTransform_BetSetting3rd_Member_Select'	, 'ServiceTransform_BetSetting3rd_Member_Insert', 0, 0, SYSDATETIME() )
	 ,( 'BetSetting3rd_Agent_History'	, 1000, 0, 1000, 'ServiceTransform_BetSetting3rd_Agent_Select'	, 'ServiceTransform_BetSetting3rd_Agent_Insert'	, 0, 0, SYSDATETIME() )

GO
