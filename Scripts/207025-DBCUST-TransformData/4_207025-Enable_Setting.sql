/*<info serverAlias="DBHIS-bodb_CustHistory" executers="" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240723@Louisa
	 Task: Deposit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#207025]
	 DB: DBTP-bodb_CustHistory
*/

USE bodb_CustHistory
GO

UPDATE Dest_ServiceTransform WITH(ROWLOCK, UPDLOCK)
SET StatusID = 1
WHERE StatusID = 0
	AND TableName IN  	
	(	'Dep_CustBetSetting_Agent_History'				
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
GO


 





