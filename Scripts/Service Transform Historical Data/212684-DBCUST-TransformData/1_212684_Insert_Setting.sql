/*<info serverAlias="DBHIS-bodb_CustHistory" executers="" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20241119@Louisa
	 Task: Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBTP-bodb_CustHistory
*/

USE bodb_CustHistory
GO

--15 tables
;WITH cte_Tables (TableName) AS
(	SELECT 'CustDiscount3rd_Agent_History'			UNION ALL
	SELECT 'CustDiscount3rd_Member_History'			UNION ALL
	SELECT 'CustInfo_History'						UNION ALL
	SELECT 'Customer_History'						UNION ALL
	SELECT 'CustMaxPayoutSetting_Agent_History'		UNION ALL
	SELECT 'CustMaxPayoutSetting_Member_History'	UNION ALL
	SELECT 'CustProductStatus_History'				UNION ALL
	SELECT 'CustPTGroupSetting3rd_Member_History'	UNION ALL
	SELECT 'CustPTSetting3rd_Agent_History'			UNION ALL
	SELECT 'CustPTSetting3rd_Member_History'		UNION ALL
	SELECT 'CustSettingMode3rd_History'				UNION ALL
	SELECT 'CustStakeLevel_Agent_History'			UNION ALL
	SELECT 'CustStakeLevel_Member_History'			UNION ALL
	SELECT 'CustWinLossLimit_Agent_History'			UNION ALL
	SELECT 'CustWinLossLimit_Member_History'		 
)

INSERT INTO  Dest_ServiceTransform 
(	
	TableName, GroupID, Interval
	, rID
	, BatchSize
	, SPSelect, SPInsert
	, StatusID ,SiteDBGroupID ,UpdateTime	
)
 SELECT t.TableName, setting.GroupID, setting.Interval
	, setting.rID
	, setting.BatchSize
	, t.TableName + '_Select' AS SPSelect, t.TableName + '_Insert' AS SPInsert
	, setting.StatusID, setting.SiteDBGroupID, setting.UpdateTime	
FROM cte_Tables t
INNER JOIN sys.objects o WITH(NOLOCK) ON t.TableName = o.name
CROSS APPLY(SELECT 4 AS GroupID, 1000 AS Interval
					, 0 AS rID, 1000 AS BatchSize
					, 0 AS StatusID ,0 AS SiteDBGroupID ,SYSDATETIME() AS UpdateTime
			) AS setting

