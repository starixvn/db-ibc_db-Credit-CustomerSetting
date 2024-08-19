/*<info serverAlias="DBHIS-bodb_CustHistory" executers="" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240723@Louisa
	 Task: Add column [Redmine:#207025]
	 DB: DBTP-bodb_CustHistory
*/

USE bodb_CustHistory
GO

ALTER TABLE Dest_ServiceTransform ADD GroupID TINYINT
GO

UPDATE Dest_ServiceTransform WITH(ROWLOCK, UPDLOCK)
SET GroupID = 1
WHERE TableName IN 
	(
		'BetSetting_Member_History'		
		 ,'BetSetting_Agent_History'		
		 ,'BetSetting3rd_Member_History'	
		 ,'BetSetting3rd_Agent_History'	
	)

UPDATE Dest_ServiceTransform WITH(ROWLOCK, UPDLOCK)
SET GroupID = 2
WHERE TableName IN 
	(
	'Dep_CustBetSetting_Agent_History'			
	,'Dep_CustBetSetting_Member_History'			
	
	,'Dep_CustBetSettingGame_Agent_History'		
	,'Dep_CustBetSettingGame_Member_History'		
	,'Dep_CustBetSettingGameGroup_Member_History' 
	
	,'Dep_CustDiscountSetting_Agent_History'		
	,'Dep_CustDiscountSetting_Member_History'		
	,'Dep_CustDiscountGroupSetting_Member_History'
	
	,'Dep_CustProductStatus_History'				
	
	,'Dep_CustPTGroupSetting_Member_History'		
	,'Dep_CustPTSetting_Member_History'			
	,'Dep_CustPTSetting_Agent_History'			
	
	,'Dep_CustSettingGame_History'				
	,'Dep_CustSettingMode_History'				
	
	,'Dep_CustStakeLevel_Agent_History'			
	,'Dep_CustStakeLevel_Member_History'			
	)
