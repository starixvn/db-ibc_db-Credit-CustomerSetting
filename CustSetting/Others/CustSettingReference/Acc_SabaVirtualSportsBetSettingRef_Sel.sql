/*<info serverAlias="DBTXN-bodb02" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE  [dbo].[Acc_SabaVirtualSportsBetSettingRef_Sel]
	@Site VARCHAR(10) = ''
AS 
/*
    Created by: 20231121@Johnson
    Task: Retrieve Customer Setting Reference for Saba Virtual Sports
    DB: DBTXN-bodb02

    Revision: 
		- 20231121@Johnson: initial sp [redmine:#196252]
		- 20240319@Johnson: Add Ice Hockey [redmine: #201129]
*/
BEGIN
	SET NOCOUNT ON
	
	/*
		SELECT * FROM RefResource WITH(NOLOCK) 
		WHERE RefID IN ('BetSettingRef','BetSettingRef_Saba')
	*/
	
	--'BetSettingRef_Saba'
	IF @site = '777777'
	BEGIN
		;WITH T AS (
			SELECT  '1_42' SettingID, '1_42' SettingID_Followed--Virtual Soccer	
			UNION ALL SELECT  '1_108', '1_42'--Virtual Futsal	
			UNION ALL SELECT  '2_42', '2_42'--Virtual Basketball					
			UNION ALL SELECT  '5_42', '5'--Virtual Tennis	
			UNION ALL SELECT  '50_42', '99'--Virtual Cricket
			UNION ALL SELECT  '4_42', '99'--Virtual Ice Hockey
		)
		SELECT * FROM T
	END
	ELSE --'BetSettingRef'
	BEGIN		
		;WITH T AS (
			SELECT  '1_42' SettingID, '1_42' SettingID_Followed--Saba Soccer	
			UNION ALL SELECT  '1_108', '1_42'--Saba Futsal	
			UNION ALL SELECT  '2_42', '2_42'--Saba Basketball
			UNION ALL SELECT  '1_113', '1'--Saba Soccer PinGoal	
			UNION ALL SELECT  '2_122', '2'--Saba Basketball PinGoal	
			UNION ALL SELECT  '43_151', '43'--Saba E-Sports PinGoal				
			UNION ALL SELECT  '5_42', '5'--Saba Tennis	
			UNION ALL SELECT  '50_42', '99'--Saba Cricket
			UNION ALL SELECT  '4_42', '99'--Saba Ice Hockey
		)
		SELECT * FROM T
	END
END
	