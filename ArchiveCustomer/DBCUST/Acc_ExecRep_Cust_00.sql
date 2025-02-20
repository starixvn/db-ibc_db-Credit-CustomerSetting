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
		- 20180126@Daniel: add pre-stage - close agents and downnlines (@Type = -1)
		- 20180822@Daniel: Remove table custVirtuaRate
		- 20190917@Daniel: Remove unused tables P2PGameSetting, P2PGroupComm for clean up inactive product (#117439 - P2)
		- 20190925@Daniel: Remove SP Recompile & involve more setting tables
		- 20191217@Daniel: Remove delete custsearch due to perf issue
		- 20200922@Helen: Remove old table [Redmine:130032]
		- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
		- 20201201@Eden: NAP/Alpha & EXT - Apply color for archived accounts [Redmine:145018]
		- 20210316@Helen: backup CustSub and delete for stage 4 [RedmineID: #130032]
		- 20210203@Eden: NAP/Alpha & EXT - Mark ClosedReason = 4 for satisfied archiving accounts of stage 1 [RedmineID: #149450]
		- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
		- 20210923@Eden: Include newly created tables into Archive Credit Dormant Account process [redmine: #162050]
		- 20220907@Eden: Scale out DBTrans [RedmineID: #158293]
		- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20230524@Eden: Change batch update delete data to 5000 [Redmine: #181595]
		- 20230529@Eden: Archiving credit accounts for additional tables [Redmine: #188850]
		- 20230529@Eden: Check permission of KL Environment [Redmine: #199968]
		- 20240724@Elodie: Replace SiteDB [RedmineID: #207738]
		- 20241230@Aries: Scale Out DBCUST - Apply Inhouse replication for the remaning tables [Redmine: #215627]
	Param's Explanation:
		@Type: 
			+ -1-Stage 1: update closed = 1 for whole agent line
			+ 0 -Stage 2: update enable = 0 & credit = 0 for whole agent line
			+ 1 -Stage 3: Delete cust setting for members under agent
			+ 2 -Stage 4: Delete cust info for members under agent
			
 --test rep---
*/
BEGIN
	DECLARE @RoleID INT
	CREATE TABLE #tmp_UpdateBatch (CustID INT, RoleID INT)
	IF @Type = -1 --1st stage (1)
	BEGIN 
		--CLosed Agent and downlines
		IF dbo.f_CheckRepTable('Custinfo') = 0
		   OR dbo.f_CheckRepTable('CustProductStatus') = 0
			RETURN
		ELSE 
		BEGIN
			SET @RoleID = 2

			UPDATE cps
				SET CloseInfo = CloseInfo|POWER(2,@RoleID - 1) -- turn on agent's bit = 1. It means this agent is closed.
			FROM dbo.custInfo ci WITH (NOLOCK)
				INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
			WHERE ci.custid = @AgentID 
				AND CloseInfo&POWER(2,@RoleID - 1) = 0 --check agent's bit = 0. It means this agent opens.

			WHILE (1=1)
			BEGIN 
				UPDATE TOP(5000) cps
					SET CloseInfo = CloseInfo|3 -- turn on member's bit = 1 and agent's bit = 1
				FROM dbo.custInfo ci WITH (NOLOCK)
					INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
				WHERE ci.recommend = @AgentID 
					AND (CloseInfo&POWER(2,0) = 0 OR CloseInfo&POWER(2,@RoleID - 1) = 0) --check member's bit = 0 or agent's bit = 0. It means this direct agent opens or this member still opens.
					AND ci.roleid = 1

				IF @@ROWCOUNT < 5000
					BREAK
			END 
		END 

		--Update ClosedReason for agent and downlines
		--Insert Update for Agent
		--> Insert Update ClosedReason
		IF dbo.f_CheckServerName() = 1 AND dbo.f_CheckEnvironment() = 'Active'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM dbo.CustLoginInfo WITH(NOLOCK) WHERE custid = @AgentID)
				INSERT INTO CustLoginInfo(CustID, ClosedReason,RepUpdateTime) 
				SELECT @AgentID, 4,dbo.f_GetDateTime2()
			ELSE
				UPDATE m
				SET  ClosedReason = 4
					,RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustLoginInfo m WITH (ROWLOCK, UPDLOCK)
				WHERE m.CustID = @AgentID
		END

		
		--Insert Update for Members
		IF dbo.f_CheckRepTable('CustLoginInfo_Member') = 1
		BEGIN
			WHILE (1=1)
			BEGIN 
				INSERT INTO [CustLoginInfo_Member](CustID,ClosedReason,RepUpdateTime)
				SELECT TOP (5000) 
					c.custid,
					4 as ClosedReason,
					dbo.f_GetDateTime2()
				FROM  custinfo c WITH(NOLOCK) 
				WHERE c.recommend = @AgentID 
					AND c.roleid = 1
					AND NOT EXISTS ( SELECT 1 FROM CustLoginInfo_Member m WITH (NOLOCK) WHERE m.CustID = c.custid)

				IF @@ROWCOUNT < 5000
					BREAK
			END 

			WHILE (1=1)
			BEGIN 
				UPDATE TOP (5000) m
				SET  ClosedReason = 4
					,RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustLoginInfo_Member m WITH (ROWLOCK, UPDLOCK)
					INNER JOIN custinfo c WITH(NOLOCK) ON m.CustID = c.custid
					INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = m.CustID
				WHERE ISNULL(ClosedReason,0) <> 4
					AND c.recommend = @AgentID
					AND cps.CloseInfo > 0

				IF @@ROWCOUNT < 5000
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
				DELETE #tmp_UpdateBatch

				UPDATE TOP(5000) dbo.Custinfo WITH (UPDLOCK,ROWLOCK)
				SET		[enabled] = 0, credit = 0
				OUTPUT DELETED.custid, DELETED.roleid
				INTO #tmp_UpdateBatch(CustID, RoleID)
				WHERE	recommend = @AgentID AND [enabled] = 1 
				
				IF @@ROWCOUNT = 0
					BREAK

				--CLosed Agent and downlines
				IF(dbo.f_CheckRepTable('CustProductStatus') = 1)
				BEGIN
					UPDATE cps
						SET CloseInfo = CASE WHEN ci.RoleID = 1 THEN CloseInfo|3 -- turn on member's bit = 1 and agent's bit = 1
											 WHEN ci.RoleID = 2 THEN CloseInfo|POWER(2,@RoleID - 1) -- turn on agent's bit = 1. It means this agent is closed.
										END  
					FROM #tmp_UpdateBatch ci WITH (NOLOCK)
						INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
					WHERE ci.roleid = 1 AND (CloseInfo&POWER(2,0) = 0 OR CloseInfo&POWER(2,@RoleID - 1) = 0) --check member's bit = 0 or agent's bit = 0. It means this direct agent opens or this member still opens.
						OR (ci.RoleID = 2 AND CloseInfo&POWER(2,@RoleID - 1) = 0) --check agent's bit = 0. It means this agent opens.)
				END
			END 
		END
		
	END	
	ELSE IF @Type = 1
	BEGIN
		IF dbo.f_CheckRepTable('CustVirtualSetting') = 1
		BEGIN
			WHILE 1=1
			BEGIN
				DELETE TOP(5000)
				FROM dbo.CustVirtualSetting WITH(ROWLOCK,UPDLOCK)
				WHERE custid IN (SELECT custid 
								 FROM custinfo WITH(NOLOCK) 
								 WHERE recommend = @AgentID
								)
				IF @@ROWCOUNT < 5000
					BREAK
			END
		END


	     IF dbo.f_CheckRepTable('CustSetting') = 1 		 	     
		BEGIN
			WHILE(1=1)
			BEGIN
				DELETE TOP(5000) dbo.CustSetting WITH (UPDLOCK,ROWLOCK)
				WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) WHERE recommend = @AgentID)
						
				IF @@ROWCOUNT < 5000 
					BREAK
			END						
		END
		   
		--------- Archive more settings data (new tables/DCS)

		IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(5000) dbo.CustBetSetting3rd_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 5000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustDiscount3rd_Member') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(5000) dbo.CustDiscount3rd_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 5000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(5000) dbo.CustPTSetting3rd_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 5000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustSettingMode3rd') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(5000) dbo.CustSettingMode3rd WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 5000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustStakeLevel_Member') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(5000) dbo.CustStakeLevel_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 5000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustWinLossLimit_Member') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(5000) dbo.CustWinLossLimit_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 5000 
				BREAK
		END

		--#162050 : more tables
		IF dbo.f_CheckRepTable('CustBetSetting_Member') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(5000) dbo.CustBetSetting_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 5000 
				BREAK
		END

		IF dbo.f_CheckRepTable('CustCommRate') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(5000) dbo.CustCommRate WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 5000 
				BREAK
		END

		--#188850  : more tables
		IF dbo.f_CheckRepTable('CustMaxPayoutSetting_Member') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(5000) dbo.CustMaxPayoutSetting_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 5000 
				BREAK
		END

		-->Agent
		IF dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 1 
		BEGIN
			DELETE dbo.CustPTGroupSetting3rd_Member WITH (UPDLOCK,ROWLOCK)
			WHERE	AgentID = @AgentID 
			
		END

		IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 1 
		BEGIN
			DELETE dbo.CustBetSetting3rd_Agent WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @AgentID 
			
		END

		IF dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 1 
		BEGIN
			DELETE dbo.CustDiscount3rd_Agent WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @AgentID 
			
		END

		IF dbo.f_CheckRepTable('custOverride') = 1 
		BEGIN
			DELETE dbo.custOverride WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @AgentID 
			
		END		

		IF dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 1 
		BEGIN
			DELETE dbo.CustPTSetting3rd_Agent WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @AgentID 
			
		END

		IF dbo.f_CheckRepTable('CustStakeLevel_Agent') = 1 
		BEGIN
			DELETE dbo.CustStakeLevel_Agent WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @AgentID 
			
		END

		IF dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 1 
		BEGIN
			DELETE dbo.CustWinLossLimit_Agent WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @AgentID 
			
		END

		IF dbo.f_CheckRepTable('AgentCommRate') = 1 
		BEGIN
			DELETE dbo.AgentCommRate WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @AgentID 
			
		END

		IF dbo.f_CheckRepTable('CustBetSetting_Agent') = 1 
		BEGIN
			DELETE dbo.CustBetSetting_Agent WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @AgentID 
			
		END

		--#188850  : more tables
		IF dbo.f_CheckRepTable('CustMaxPayoutSetting_Agent') = 1 
		BEGIN
			DELETE dbo.CustMaxPayoutSetting_Agent WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @AgentID 
			
		END

		IF DATABASEPROPERTYEX('bodb_Credit', 'Updateability') = 'READ_WRITE' -- allow update
		BEGIN
			IF OBJECT_ID('bodb_Credit.dbo.CustProfilePicture') IS NOT NULL
			BEGIN
				DECLARE @CustProfilePicture TABLE (CustId int, ImageId int) 

				UPDATE t
				SET t.IsDeleted = 1,
					t.RepUpdateTime = SYSDATETIME()
				OUTPUT deleted.CustId,deleted.ImageId INTO @CustProfilePicture(CustId,ImageId)
				FROM bodb_Credit.dbo.CustProfilePicture t WITH (UPDLOCK,ROWLOCK)
				WHERE custid = @AgentID 
			
				UPDATE t
				SET t.IsDeleted = 1,
					t.RepUpdateTime = SYSDATETIME()
				FROM bodb_Credit.dbo.ProfilePicture t WITH (UPDLOCK,ROWLOCK)
					INNER JOIN @CustProfilePicture c
						ON t.ImageId = c.ImageId
				WHERE t.ImageId > 1000000 -- just delete user upload image ( id > 1000000, not delete system library image id <= 1000000)
			END
		END
	END 
	ELSE IF @Type = 2  --Stage 4
	BEGIN
		IF @@SERVERNAME IN ('DBTRANS','SITDBTRANS','TESTDBTRANS','DB66')  
			OR  @@SERVERNAME LIKE 'DBGRP%'   -- PRO
			OR  @@SERVERNAME LIKE 'SITDBGRP%'  --SIT 
			OR  @@SERVERNAME LIKE 'DBSITEC%'   -- PRO
			OR  @@SERVERNAME LIKE 'SITDBSITEC%'  --SIT 
			OR  @@SERVERNAME LIKE 'TESTSITEDB%'  --Local
		BEGIN

			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalCreditSports WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 5000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalDebitSports WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 5000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalCreditCasino WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 5000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalDebitCasino WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 5000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalCreditOthers WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 5000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalDebitOthers WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 5000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalCreditTransfer WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 5000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalDebitTransfer WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (	SELECT custid 
									FROM  Custinfo c WITH (NOLOCK)
									WHERE	c.roleid = 1 AND c.recommend = @AgentID 
								)
				IF @@ROWCOUNT < 5000
					BREAK
			END

		END -- END of DBTRANS - delete balance tables

		----- add more tables----------------------------

		IF dbo.f_CheckRepTable('CustProductStatus') = 1 		
		WHILE(1=1)
		BEGIN
			DELETE TOP(5000) dbo.CustProductStatus WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE  recommend = @AgentID
									)
			IF @@ROWCOUNT < 5000 
				BREAK
		END

		--------------------------------------------------
		IF dbo.f_CheckRepTable('CustLoginInfo_Member') = 1
		WHILE(1=1)
		BEGIN
			
			DELETE TOP(5000) dbo.CustLoginInfo_Member WITH (ROWLOCK)
			OUTPUT DELETED.custid ,dbo.f_GetDateTime2()
			INTO CustLoginInfo_Member_Del_Inhouse(custid,RepUpdateTime)
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
				DELETE TOP(5000) dbo.Custinfo WITH (UPDLOCK,ROWLOCK)
				WHERE	recommend = @AgentID 
				IF @@ROWCOUNT < 5000
					BREAK

			END 
			WHILE(1=1)
			BEGIN
				DELETE TOP(5000) dbo.Customer WITH (UPDLOCK,ROWLOCK)
				WHERE	recommend = @AgentID 
				IF @@ROWCOUNT < 5000
					BREAK			
			END
		END
				
	    IF dbo.f_CheckRepTable('custsub') = 1 
		BEGIN
			DELETE dbo.custSub WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @AgentID 
			
		END

		--#162050 : more tables
		IF dbo.f_CheckRepTable('CustAgent') = 1 
		BEGIN
			DELETE dbo.CustAgent WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @AgentID 
			
		END

		IF dbo.f_CheckServerName() = 1 AND dbo.f_CheckEnvironment() = 'Active'
		BEGIN
			DELETE dbo.CustLoginInfo WITH (UPDLOCK,ROWLOCK)
			OUTPUT DELETED.custid ,dbo.f_GetDateTime2()
			INTO CustLoginInfo_Del_Inhouse(custid,RepUpdateTime)
			WHERE	custid = @AgentID 
			
		END

		IF dbo.f_CheckServerName() = 1 AND dbo.f_CheckEnvironment() = 'Active' 
		BEGIN
			DELETE dbo.CustLoginInfoSub WITH (UPDLOCK,ROWLOCK)
			OUTPUT DELETED.SubAccID ,dbo.f_GetDateTime2()
			INTO CustLoginInfoSub_Del_Inhouse(SubAccID,RepUpdateTime)
			WHERE	custid = @AgentID 
			
		END
		
	END 
END