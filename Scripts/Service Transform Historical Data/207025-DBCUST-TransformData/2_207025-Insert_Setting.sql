/*<info serverAlias="DBHIS-bodb_CustHistory" executers="" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240723@Louisa
	 Task: Deposit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#207025]
	 DB: DBTP-bodb_CustHistory
*/

USE bodb_CustHistory
GO

INSERT INTO  Dest_ServiceTransform 
(	
	TableName, GroupID, Interval
	, rID, BatchSize
	, SPSelect, SPInsert, StatusID ,SiteDBGroupID ,UpdateTime	
)	
VALUES('Dep_CustBetSetting_Agent_History'			, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustBetSetting_Agent_Select'	, 'ServiceTransform_Dep_CustBetSetting_Agent_Insert' , 0, 0, SYSDATETIME() )	
	 ,('Dep_CustBetSetting_Member_History'			, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustBetSetting_Member_Select', 'ServiceTransform_Dep_CustBetSetting_Member_Insert', 0, 0, SYSDATETIME() )
	
	 ,('Dep_CustBetSettingGame_Agent_History'		, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustBetSettingGame_Agent_Select'	, 'ServiceTransform_Dep_CustBetSettingGame_Agent_Insert' , 0, 0, SYSDATETIME() )
	 ,('Dep_CustBetSettingGame_Member_History'		, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustBetSettingGame_Member_Select'	, 'ServiceTransform_Dep_CustBetSettingGame_Member_Insert', 0, 0, SYSDATETIME() )
	 ,('Dep_CustBetSettingGameGroup_Member_History' , 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustBetSettingGameGroup_Member_Select'	, 'ServiceTransform_Dep_CustBetSettingGameGroup_Member_Insert'	, 0, 0, SYSDATETIME() )
	 
	 ,('Dep_CustDiscountSetting_Agent_History'		, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustDiscountSetting_Agent_Select'	, 'ServiceTransform_Dep_CustDiscountSetting_Agent_Insert'	, 0, 0, SYSDATETIME() )
	 ,('Dep_CustDiscountSetting_Member_History'		, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustDiscountSetting_Member_Select', 'ServiceTransform_Dep_CustDiscountSetting_Member_Insert'	, 0, 0, SYSDATETIME() )
	 ,('Dep_CustDiscountGroupSetting_Member_History', 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustDiscountGroupSetting_Member_Select'	, 'ServiceTransform_Dep_CustDiscountGroupSetting_Member_Insert'	, 0, 0, SYSDATETIME() )

	 ,('Dep_CustProductStatus_History'				, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustProductStatus_Select'	, 'ServiceTransform_Dep_CustProductStatus_Insert'	, 0, 0, SYSDATETIME() )
	
	 ,('Dep_CustPTGroupSetting_Member_History'		, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustPTGroupSetting_Member_Select', 'ServiceTransform_Dep_CustPTGroupSetting_Member_Insert'	, 0, 0, SYSDATETIME() )
	 ,('Dep_CustPTSetting_Member_History'			, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustPTSetting_Member_Select'		, 'ServiceTransform_Dep_CustPTSetting_Member_Insert'	, 0, 0, SYSDATETIME() )
	 ,('Dep_CustPTSetting_Agent_History'			, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustPTSetting_Agent_Select'		, 'ServiceTransform_Dep_CustPTSetting_Agent_Insert'	, 0, 0, SYSDATETIME() )

	 ,('Dep_CustSettingGame_History'				, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustSettingGame_Select'	, 'ServiceTransform_Dep_CustSettingGame_Insert'	, 0, 0, SYSDATETIME() )	 
	 ,('Dep_CustSettingMode_History'				, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustSettingMode_Select'	, 'ServiceTransform_Dep_CustSettingMode_Insert'	, 0, 0, SYSDATETIME() )
	
	 ,('Dep_CustStakeLevel_Agent_History'			, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustStakeLevel_Agent_Select'	, 'ServiceTransform_Dep_CustStakeLevel_Agent_Insert'	, 0, 0, SYSDATETIME() )	 
	 ,('Dep_CustStakeLevel_Member_History'			, 2 ,1000, 0, 1000, 'ServiceTransform_Dep_CustStakeLevel_Member_Select', 'ServiceTransform_Dep_CustStakeLevel_Member_Insert'	, 0, 0, SYSDATETIME() )
	 
GO


 




