/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [Acc_ExecRep_Cust_00]
	@AgentID	INT,
	@Type		SMALLINT
AS 
/*
	Created by: Daniel
	Date: 2015-01-12
	Task: For archive Acc (New) - update/delete part in stage 1,2,3 
	DB: DBCUST/CustDB
	Original: Acc_ExecRep_Cust_01
	Revision:
		20180126@Daniel: add pre-stage - close agents and downnlines (@Type = -1)
		20180822@Daniel: Remove table custVirtuaRate
		20190917@Daniel: Remove unused tables P2PGameSetting, P2PGroupComm for clean up inactive product (#117439 - P2)
		20190925@Daniel: Remove SP Recompile & involve more setting tables
		20191217@Daniel: Remove delete custsearch due to perf issue

	Param's Explanation:
		@Type: 
			+ -1-Stage 1: update closed = 1 for whole agent line
			+ 0 -Stage 2: update enable = 0 & credit = 0 for whole agent line
			+ 1 -Stage 3: Delete cust setting for members under agent
			+ 2 -Stage 4: Delete cust info for members under agent
			
 --test rep---
*/
BEGIN
	IF @Type = -1 --1st stage (1)
	BEGIN 
		IF dbo.f_CheckRepTable('Custinfo') = 0
			RETURN
		ELSE 
		BEGIN
			WHILE (1=1)
			BEGIN 
				UPDATE TOP(10000) dbo.Custinfo WITH (UPDLOCK,ROWLOCK)
				SET		closed = 1
				WHERE	recommend = @AgentID AND closed = 0 
				IF @@ROWCOUNT < 10000
					BREAK
			END 
		END 
	END	
	ELSE 
	IF @Type = 0 
	BEGIN 
		IF dbo.f_CheckRepTable('Custinfo') = 0
			RETURN
		ELSE 
		BEGIN
			WHILE (1=1)
			BEGIN 
				UPDATE TOP(10000) dbo.Custinfo WITH (UPDLOCK,ROWLOCK)
				SET		[enabled] = 0, closed = 1, credit = 0
				WHERE	recommend = @AgentID AND [enabled] = 1 
				IF @@ROWCOUNT < 10000
					BREAK
			END 
		END 
	END	
	ELSE IF @Type = 1
	BEGIN
		IF dbo.f_CheckRepTable('CustVirtualSetting') = 1
		BEGIN
			WHILE 1=1
			BEGIN
				DELETE TOP(10000)
				FROM dbo.CustVirtualSetting WITH(ROWLOCK,UPDLOCK)
				WHERE custid IN (SELECT custid 
								 FROM custinfo WITH(NOLOCK) 
								 WHERE roleid = 1 AND recommend = @AgentID
								)
				IF @@ROWCOUNT < 10000
					BREAK
			END
		END


	     IF (dbo.f_CheckRepTable('CustSetting') = 1 
		  AND dbo.f_CheckRepTable('CustSetting3rd') = 1 
	     )
		BEGIN
			WHILE(1=1)
			BEGIN
				DELETE TOP(10000) dbo.CustSetting WITH (UPDLOCK,ROWLOCK)
				WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) WHERE roleid = 1 AND recommend = @AgentID)
						
				IF @@ROWCOUNT < 10000 
					BREAK
			END
			
			WHILE(1=1)
			BEGIN
				DELETE TOP(10000) dbo.CustSetting3rd WITH (UPDLOCK,ROWLOCK)
				WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) WHERE roleid = 1 AND recommend = @AgentID)
							
				IF @@ROWCOUNT < 10000
					BREAK			
			END
		END
	
	     IF (dbo.f_CheckRepTable('CustSettingGame') = 1 
		  AND dbo.f_CheckRepTable('CustGameType') = 1 
	     )
		BEGIN			
			WHILE(1=1)
			BEGIN
				DELETE TOP(10000) dbo.[CustSettingGame] WITH (UPDLOCK,ROWLOCK)
				WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)
				IF @@ROWCOUNT < 10000 
					BREAK
			END			
			
			WHILE(1=1)
			BEGIN
				DELETE TOP(10000) dbo.[CustGameType] WITH (UPDLOCK,ROWLOCK)
				WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
										WHERE roleid = 1 
											AND recommend = @AgentID
											)
				IF @@ROWCOUNT < 10000 
					BREAK
			END				
		END


		--------- Archive more settings data (new tables/DCS)

		IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(10000) dbo.CustBetSetting3rd_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 10000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustCommRate') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(10000) dbo.CustCommRate WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 10000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustDiscount3rd_Member') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(10000) dbo.CustDiscount3rd_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 10000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustProductStatus') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(10000) dbo.CustProductStatus WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 10000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(10000) dbo.CustPTSetting3rd_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 10000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustSettingMode3rd') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(10000) dbo.CustSettingMode3rd WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 10000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustStakeLevel_Member') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(10000) dbo.CustStakeLevel_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 10000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustWinLossLimit_Member') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(10000) dbo.CustWinLossLimit_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 10000 
				BREAK
		END

	END 
	ELSE IF @Type = 2
	BEGIN
		IF @@SERVERNAME = 'DBTRANS' -- @DBTRANS => delete balance tables
		BEGIN

			WHILE (1=1)
			BEGIN
				DELETE TOP(10000) bodb02.dbo.BalCreditSports WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 10000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(10000) bodb02.dbo.BalDebitSports WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 10000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(10000) bodb02.dbo.BalCreditCasino WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 10000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(10000) bodb02.dbo.BalDebitCasino WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 10000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(10000) bodb02.dbo.BalCreditOthers WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 10000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(10000) bodb02.dbo.BalDebitOthers WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 10000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(10000) bodb02.dbo.BalCreditTransfer WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 10000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(10000) bodb02.dbo.BalDebitTransfer WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 10000
					BREAK
			END

		END -- END of DBTRANS - delete balance tables

		----- add more tables----------------------------
		IF dbo.f_CheckRepTable('CustLoginInfo_Member') = 1 
		WHILE(1=1)
		BEGIN
			DELETE TOP(5000) dbo.CustLoginInfo_Member WITH (ROWLOCK)
			WHERE custid IN(SELECT custid from custinfo WITH (NOLOCK) WHERE roleid = 1 AND recommend = @AgentID) 
			IF @@ROWCOUNT < 5000
				BREAK
		END 
		--------------------------------------------------
				
	    IF (dbo.f_CheckRepTable('Custinfo') = 1 
		  AND dbo.f_CheckRepTable('Customer') = 1 
	    )
		BEGIN
			WHILE(1=1)
			BEGIN
				DELETE TOP(10000) dbo.Custinfo WITH (UPDLOCK,ROWLOCK)
				WHERE	roleid = 1 AND recommend = @AgentID 
				IF @@ROWCOUNT < 10000
					BREAK

			END 
			WHILE(1=1)
			BEGIN
				DELETE TOP(10000) dbo.Customer WITH (UPDLOCK,ROWLOCK)
				WHERE	roleid = 1 AND recommend = @AgentID 
				IF @@ROWCOUNT < 10000
					BREAK			
			END
		END

	END 
END