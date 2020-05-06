/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE Acc_ExecRep_Cust_01
	@CustIDs VARCHAR(MAX) 	= ''
AS
/*
	Created:	Daniel
	Date:		20191205
	Task:		Archive Credit Account - Delete data
	DB:			DBCUST/CustDB
	Original:	

	Revisions:
		- 20191205@Daniel: Initialize
	
	Param's Explanation:
		@CustIDs: input list of CustIDs to clean data
*/

	DECLARE @tmpCust TABLE(CustID INT)
			    
	INSERT INTO @tmpCust(custid)	
	SELECT val
	FROM dbo.strSplit(@CustIDs,',')

	IF dbo.f_CheckRepTable('AgentCommRate') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.AgentCommRate WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END
	
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustBetSetting3rd_Agent WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustDiscount3rd_Agent WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustGameType') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustGameType WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END


	IF dbo.f_CheckRepTable('custOverride') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.custOverride WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END


	IF dbo.f_CheckRepTable('custOverride3rd') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.custOverride3rd WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END


	IF dbo.f_CheckRepTable('CustOverrideGame') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustOverrideGame WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustProductStatus') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustProductStatus WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustPTGroupSetting3rd_Member WITH (ROWLOCK)
		WHERE	agentid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustPTSetting3rd_Agent WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('custsetting') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.custsetting WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustSetting3rd') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustSetting3rd WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustSettingGame') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustSettingGame WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustStakeLevel_Agent') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustStakeLevel_Agent WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustVirtualSetting') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustVirtualSetting WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustWinLimit') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustWinLimit WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustWinLossLimit_Agent WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END


	-----------------------------------

	IF dbo.f_CheckRepTable('CustAgent') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustAgent WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('custinfo') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.custinfo WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('customer') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.customer WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustLoginInfo') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustLoginInfo WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('custSub') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.custSub WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('CustLoginInfoSub') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustLoginInfoSub WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END





