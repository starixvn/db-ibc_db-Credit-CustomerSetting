/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [Acc_ExecRep_Cust_03]
	@AgentID	INT,
	@Type		SMALLINT
AS 
/*
	Created by: Helios
	Date: 2024-04-11
	Task: For archive Acc (New) - update/delete part in stage 1,2,3 
	DB: DBCUST/CustDB
	Original: Acc_ExecRep_Cust_00
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
		- 20241030@Helios: ScaleOut Apply DeleteInHouse - Extend more table - Remove Code Old Structure [RedmineID: #201061]  


	Param's Explanation:
		@Type: 
			+ -1-Stage 1: update closed = 1 for whole agent line
			+ 0 -Stage 2: update enable = 0 & credit = 0 for whole agent line
			+ 1 -Stage 3: Delete cust setting for members under agent
			+ 2 -Stage 4: Delete cust info for members under agent
*/
BEGIN
	IF NOT (dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
		AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT	
	)
	RETURN;

	DECLARE 
		@RoleID							INT,
		@BatchSize							INT = 2000,
		@delayTime							VARCHAR(20)

	IF EXISTS (SELECT 1 FROM Sys.objects WITH (NOLOCK) WHERE name = 'f_GetWaiFor' AND type ='FN')
		SELECT @delayTime = dbo.f_GetWaiFor()
	ELSE
		SELECT @delayTime = '00:00:00.280'

	-- Param use for Stage 1 , 2
	DECLARE
		@IsInsert_CustLoginInfo_Member			AS INT = 1
	    , @IsUpdate_CustLoginInfo_Member			AS INT = 1
	    , @IsAffected_CustProductStatus				AS INT = 1

	-- tmp table use for Stage 2 , 3 , 4
	CREATE TABLE #tmp_UpdateBatch (CustID INT, RoleID INT)
	
	-- Param use for Stage 3
	DECLARE
		-- Member Affected:
		@IsDelete_BetSetting_Member			    AS INT = 1
	    , @IsDelete_BetSetting3rd_Member		    AS INT = 1
	    , @IsDelete_CustDiscount3rd_Member		    AS INT = 1
	    , @IsDelete_CustMaxPayoutSetting_Member	    AS INT = 1
	    , @IsDelete_CustPTSetting3rd_Member		    AS INT = 1
	    , @IsDelete_CustSettingMode3rd			    AS INT = 1
	    , @IsDelete_CustStakeLevel_Member		    AS INT = 1
	    , @IsDelete_CustWinLossLimit_Member		    AS INT = 1
	    , @IsDelete_VRCustAutoAdjustment		    AS INT = 1
	    , @IsDelete_WinLimit_CustGameMonitoring	    AS INT = 1
	    , @IsDelete_WinLimit_CustGameMonitoring_History AS INT = 1
	    , @IsDelete_WinLimit_CustGameStatus		    AS INT = 1
	    , @IsDelete_RobotList				    AS INT = 1
	    , @IsDelete_CustQRCode				    AS INT = 1

		-- Agent Affected:
	    , @IsDelete_BetSetting_Agent			    AS INT = 1
	    , @IsDelete_BetSetting3rd_Agent			    AS INT = 1
	    , @IsDelete_CustDiscount3rd_Agent		    AS INT = 1
	    , @IsDelete_CustMaxPayoutSetting_Agent	    AS INT = 1
	    , @IsDelete_CustPTSetting3rd_Agent		    AS INT = 1
	    , @IsDelete_CustPTGroupSetting3rd_Member	    AS INT = 1
	    , @IsDelete_CustStakeLevel_Agent		    AS INT = 1
	    , @IsDelete_CustWinLossLimit_Agent		    AS INT = 1
	    , @IsDelete_VRAgentAutoAdjustment		    AS INT = 1	  
	    , @IsDelete_CustPTTemplateDetail		    AS INT = 1
	    , @IsDelete_CustPTTemplate			    AS INT = 1
	   	    
	    -- Agent & Downline Affected:	    
	    , @IsDelete_BetLimitControlCustSetting	    AS INT = 1
	    , @IsDelete_VRCustSetting				    AS INT = 1
	    , @IsDelete_VRCustLockStatus			    AS INT = 1
	    , @IsDelete_VRSettingManualUpdAcc		    AS INT = 1
	    , @IsDelete_CustVirtualSetting			    AS INT = 1

	-- Param use for Stage 4
	DECLARE
		-- Agent Affected:
	      @IsDelete_CustAgent				    AS INT = 1
	    , @IsDelete_CustLoginInfo				    AS INT = 1
	    , @IsDelete_custSub					    AS INT = 1
	    , @IsDelete_CustLoginInfoSub			    AS INT = 1

	      -- Member Affected:
	    , @IsDelete_CustLoginInfo_Member		    AS INT = 1
	    
	      -- Agent & Downline Affected:
	    , @IsDelete_CustProductStatus			    AS INT = 1
	    , @IsDelete_Custinfo				    AS INT = 1
	    , @IsDelete_Customer				    AS INT = 1



	IF @Type = -1  --[Stage 1: update closed = 1 for whole agent line]
	BEGIN
		  IF OBJECT_ID ('CustProductStatus')	IS NOT NULL
		AND  OBJECT_ID ('custInfo')			IS NOT NULL
		AND  OBJECT_ID ('CustLoginInfo')		IS NOT NULL
		AND  OBJECT_ID ('CustLoginInfo_Member')	IS NOT NULL
		BEGIN
	-- Agent:
		--CLosed Agent and downlines
		SET @RoleID = 2

		UPDATE cps
			SET CloseInfo = CloseInfo|POWER(2,@RoleID - 1) -- turn on agent's bit = 1. It means this agent is closed.
			, RepUpdateTime = dbo.f_GetDateTime2()
		FROM dbo.custInfo ci WITH (NOLOCK)
			INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
		WHERE ci.custid = @AgentID 
			AND CloseInfo&POWER(2,@RoleID - 1) = 0 --check agent's bit = 0. It means this agent opens.

		--Insert/Update ClosedReason for Agent
		
		IF NOT EXISTS (SELECT 1 FROM dbo.CustLoginInfo WITH(NOLOCK) WHERE custid = @AgentID)
			INSERT INTO CustLoginInfo(CustID, ClosedReason,RepUpdateTime) 
			SELECT @AgentID, 4,dbo.f_GetDateTime2()
		ELSE
			UPDATE m
			SET ClosedReason = 4
			, RepUpdateTime = dbo.f_GetDateTime2()
			FROM CustLoginInfo m WITH (ROWLOCK, UPDLOCK)
			WHERE m.CustID = @AgentID
		

	-- Member:
		WHILE (1=1)
		BEGIN 
			--CLosed downlines of Agent:
			IF @IsAffected_CustProductStatus = 1
			BEGIN
				UPDATE TOP(@BatchSize) cps
				SET CloseInfo = CloseInfo|3 -- turn on member's bit = 1 and agent's bit = 1
				, RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.custInfo ci WITH (NOLOCK)
					INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
				WHERE ci.recommend = @AgentID 
					AND (CloseInfo&POWER(2,0) = 0 OR CloseInfo&POWER(2,@RoleID - 1) = 0) --check member's bit = 0 or agent's bit = 0. It means this direct agent opens or this member still opens.
					AND ci.roleid = 1

				IF @@ROWCOUNT = 0
					SELECT @IsAffected_CustProductStatus = 0
			END
			--Update ClosedReason for Members
			IF @IsUpdate_CustLoginInfo_Member = 1
			BEGIN
				UPDATE TOP (@BatchSize) m
				SET ClosedReason = 4
				, RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustLoginInfo_Member m WITH (ROWLOCK, UPDLOCK)
					INNER JOIN custinfo c WITH(NOLOCK) ON m.CustID = c.custid
					INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = m.CustID
				WHERE ISNULL(ClosedReason,0) <> 4
					AND c.recommend = @AgentID
					AND cps.CloseInfo > 0

				IF @@ROWCOUNT = 0
					SELECT @IsUpdate_CustLoginInfo_Member = 0
			END
			
			
			IF (@IsAffected_CustProductStatus = 1)
			OR (@IsUpdate_CustLoginInfo_Member = 1)
				WAITFOR DELAY @delayTime; 
			ELSE
				BREAK;			
		END 			
		
		--Insert ClosedReason for Members if not exist
		IF NOT EXISTS (SELECT 1 FROM CustLoginInfo_Member clim WITH (NOLOCK) WHERE clim.CustID IN (SELECT 1 FROM custInfo i WITH (NOLOCK) WHERE i.roleid = 1 AND i.recommend = @AgentID))
		BEGIN
			WHILE (1=1)
			BEGIN 
				IF @IsInsert_CustLoginInfo_Member = 1
				BEGIN
					INSERT INTO [CustLoginInfo_Member](CustID,ClosedReason,RepUpdateTime)
					SELECT TOP (@BatchSize) 
						c.custid,
						4 as ClosedReason,
						dbo.f_GetDateTime2()
					FROM  custinfo c WITH(NOLOCK) 
					WHERE c.recommend = @AgentID 
						AND c.roleid = 1
						AND NOT EXISTS ( SELECT 1 FROM CustLoginInfo_Member m WITH (NOLOCK) WHERE m.CustID = c.custid)

					IF @@ROWCOUNT = 0
						SELECT @IsInsert_CustLoginInfo_Member = 0
				END
			
				IF @IsInsert_CustLoginInfo_Member = 1
					WAITFOR DELAY @delayTime

				ELSE
					BREAK;
			END 
		END
		
		END 
		ELSE -- SiteDB is not exist table Return 
			RETURN;
		-- End Stage 1
	END
	ELSE IF @Type = 0 --[Stage 2: update enable = 0 & credit = 0 for whole agent line]
	BEGIN
		 IF OBJECT_ID ('CustProductStatus')		IS NOT NULL
		AND  OBJECT_ID ('custInfo')			IS NOT NULL
		BEGIN
			WHILE (1=1)
			BEGIN 
				IF @IsAffected_CustProductStatus = 1
				BEGIN
				
					UPDATE TOP(@BatchSize) dbo.Custinfo WITH (UPDLOCK,ROWLOCK)
					SET		[enabled] = 0, credit = 0 , RepUpdateTime = dbo.f_GetDateTime2()
					WHERE	recommend = @AgentID AND [enabled] = 1
				

					--CLosed Agent and downlines
					UPDATE TOP (@BatchSize) cps
						SET CloseInfo = CASE WHEN ci.RoleID = 1 THEN CloseInfo|3 -- turn on member's bit = 1 and agent's bit = 1
												WHEN ci.RoleID = 2 THEN CloseInfo|POWER(2,@RoleID - 1) -- turn on agent's bit = 1. It means this agent is closed.
										END  
						, RepUpdateTime = dbo.f_GetDateTime2()
					FROM dbo.custInfo ci WITH (NOLOCK)
						INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
					WHERE ci.recommend = @AgentID
					AND (
						ci.roleid = 1 AND (CloseInfo&POWER(2,0) = 0 OR CloseInfo&POWER(2,@RoleID - 1) = 0) --check member's bit = 0 or agent's bit = 0. It means this direct agent opens or this member still opens.
						OR (ci.RoleID = 2 AND CloseInfo&POWER(2,@RoleID - 1) = 0) --check agent's bit = 0. It means this agent opens.)
					)

					IF @@ROWCOUNT = 0
						SELECT @IsAffected_CustProductStatus = 0
				END

				IF @IsAffected_CustProductStatus = 1
					WAITFOR DELAY @delayTime
				ELSE
					BREAK;
			END 
		END
		ELSE -- SiteDB is not exist table Return 
			RETURN;
		-- End Stage 2
	END
	ELSE IF @Type = 1 --[Stage 3: Delete cust setting for members under agent]
	BEGIN
		IF OBJECT_ID('BetSetting_Member')		IS NOT NULL
	   AND OBJECT_ID('BetSetting3rd_Member')		IS NOT NULL
	   AND OBJECT_ID('CustDiscount3rd_Member')	IS NOT NULL
	   AND OBJECT_ID('CustMaxPayoutSetting_Member') IS NOT NULL
	   AND OBJECT_ID('CustPTSetting3rd_Member')	IS NOT NULL
	   AND OBJECT_ID('CustSettingMode3rd')		IS NOT NULL
	   AND OBJECT_ID('CustStakeLevel_Member')		IS NOT NULL
	   AND OBJECT_ID('CustWinLossLimit_Member')	IS NOT NULL
	   AND OBJECT_ID('VRCustAutoAdjustment')		IS NOT NULL
	   AND OBJECT_ID('WinLimit_CustGameMonitoring') IS NOT NULL
	   AND OBJECT_ID('WinLimit_CustGameMonitoring_History') IS NOT NULL
	   AND OBJECT_ID('WinLimit_CustGameStatus')	IS NOT NULL
	   AND OBJECT_ID('RobotList')				IS NOT NULL
	   AND OBJECT_ID('CustQRCode')			IS NOT NULL
	   AND OBJECT_ID('BetSetting_Agent')		IS NOT NULL
	   AND OBJECT_ID('BetSetting3rd_Agent')		IS NOT NULL
	   AND OBJECT_ID('CustDiscount3rd_Agent')		IS NOT NULL
	   AND OBJECT_ID('CustMaxPayoutSetting_Agent')	IS NOT NULL
	   AND OBJECT_ID('CustPTSetting3rd_Agent')	IS NOT NULL
	   AND OBJECT_ID('CustPTGroupSetting3rd_Member') IS NOT NULL
	   AND OBJECT_ID('CustStakeLevel_Agent')		IS NOT NULL
	   AND OBJECT_ID('CustWinLossLimit_Agent')	IS NOT NULL
	   AND OBJECT_ID('VRAgentAutoAdjustment')		IS NOT NULL
	   AND OBJECT_ID('CustPTTemplateDetail')		IS NOT NULL
	   AND OBJECT_ID('CustPTTemplate')			IS NOT NULL
	   AND OBJECT_ID('BetLimitControlCustSetting')	IS NOT NULL
	   AND OBJECT_ID('VRCustSetting')			IS NOT NULL
	   AND OBJECT_ID('VRCustLockStatus')		IS NOT NULL
	   AND OBJECT_ID('VRSettingManualUpdAcc')		IS NOT NULL
	   AND OBJECT_ID('CustVirtualSetting')		IS NOT NULL
	   AND OBJECT_ID('CustProfilePicture')		IS NOT NULL
	   AND OBJECT_ID('ProfilePicture')			IS NOT NULL
	   AND OBJECT_ID('VRMemberBigStake')		IS NOT NULL
		BEGIN 

			WHILE (1=1)
			-- New Style In House:
			BEGIN
				-- Member
				IF @IsDelete_BetSetting_Member = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
					INTO BetSetting_Member_Del_InHouse (CustID,SportType,BetType,RepUpdateTime)
					FROM BetSetting_Member rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_BetSetting_Member = 0
				END
				IF @IsDelete_BetSetting3rd_Member = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
					INTO BetSetting3rd_Member_Del_InHouse (CustID,SportType,BetType,RepUpdateTime)
					FROM BetSetting3rd_Member rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_BetSetting3rd_Member = 0
				END
				IF @IsDelete_CustDiscount3rd_Member = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
					INTO CustDiscount3rd_Member_Del_InHouse (CustID,SportType,BetType,RepUpdateTime)
					FROM CustDiscount3rd_Member rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustDiscount3rd_Member = 0
				END
				IF @IsDelete_CustMaxPayoutSetting_Member = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
					INTO CustMaxPayoutSetting_Member_Del_InHouse (CustID,SportType,BetType,RepUpdateTime)
					FROM CustMaxPayoutSetting_Member rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustMaxPayoutSetting_Member = 0
				END
				IF @IsDelete_CustPTSetting3rd_Member = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, DELETED.IsLive, dbo.f_GetDateTime2()
					INTO CustPTSetting3rd_Member_Del_InHouse (CustID,SportType,BetType,IsLive,RepUpdateTime)
					FROM CustPTSetting3rd_Member rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustPTSetting3rd_Member = 0
				END
				IF @IsDelete_CustSettingMode3rd = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
					INTO CustSettingMode3rd_Del_InHouse (CustID,RepUpdateTime)
					FROM CustSettingMode3rd rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustSettingMode3rd = 0
				END
				IF @IsDelete_CustStakeLevel_Member = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
					INTO CustStakeLevel_Member_Del_InHouse (CustID,SportType,BetType,RepUpdateTime)
					FROM CustStakeLevel_Member rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustStakeLevel_Member = 0
				END
				IF @IsDelete_CustWinLossLimit_Member = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
					INTO CustWinLossLimit_Member_Del_InHouse (CustID,SportType,BetType,RepUpdateTime)
					FROM CustWinLossLimit_Member rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustWinLossLimit_Member = 0
				END
				IF @IsDelete_VRCustAutoAdjustment = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.SportType, DELETED.CustID, dbo.f_GetDateTime2()
					INTO VRCustAutoAdjustment_Del_InHouse (SportType,CustID,RepUpdateTime)
					FROM VRCustAutoAdjustment rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_VRCustAutoAdjustment = 0
				END
				IF @IsDelete_WinLimit_CustGameMonitoring = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.ProductID, DELETED.WinlostDate, DELETED.GroupID, dbo.f_GetDateTime2()
					INTO WinLimit_CustGameMonitoring_Del_InHouse (CustID,ProductID,WinlostDate,GroupID,RepUpdateTime)
					FROM WinLimit_CustGameMonitoring rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_WinLimit_CustGameMonitoring = 0
				END
				IF @IsDelete_WinLimit_CustGameMonitoring_History = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.LogID, dbo.f_GetDateTime2()
					INTO WinLimit_CustGameMonitoring_History_Del_InHouse (LogID,RepUpdateTime)
					FROM WinLimit_CustGameMonitoring_History rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_WinLimit_CustGameMonitoring_History = 0
				END
				IF @IsDelete_WinLimit_CustGameStatus = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.ProductID, DELETED.BetTypeID, dbo.f_GetDateTime2()
					INTO WinLimit_CustGameStatus_Del_InHouse (CustID,ProductID,BetTypeID,RepUpdateTime)
					FROM WinLimit_CustGameStatus rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_WinLimit_CustGameStatus = 0
				END
				IF @IsDelete_RobotList = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
					INTO RobotList_Del_InHouse (CustID,RepUpdateTime)
					FROM RobotList rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_RobotList = 0
				END
				IF @IsDelete_CustQRCode = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID,dbo.f_GetDateTime2()
					INTO CustQRCode_Del_InHouse (CustID,RepUpdateTime)
					FROM CustQRCode rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustQRCode = 0
				END

				-- Agent
				IF @IsDelete_BetSetting_Agent = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
					INTO BetSetting_Agent_Del_InHouse (CustID,SportType,BetType,RepUpdateTime)
					FROM BetSetting_Agent rmv WITH (ROWLOCK)
					WHERE	custid = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_BetSetting_Agent = 0
				END
				IF @IsDelete_BetSetting3rd_Agent = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
					INTO BetSetting3rd_Agent_Del_InHouse (CustID,SportType,BetType,RepUpdateTime)
					FROM BetSetting3rd_Agent rmv WITH (ROWLOCK)
					WHERE	custid = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_BetSetting3rd_Agent = 0
				END
				IF @IsDelete_CustDiscount3rd_Agent = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
					INTO CustDiscount3rd_Agent_Del_InHouse (CustID,SportType,BetType,RepUpdateTime)
					FROM CustDiscount3rd_Agent rmv WITH (ROWLOCK)
					WHERE	custid = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustDiscount3rd_Agent = 0
				END
				IF @IsDelete_CustMaxPayoutSetting_Agent = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
					INTO CustMaxPayoutSetting_Agent_Del_InHouse (CustID,SportType,BetType,RepUpdateTime)
					FROM CustMaxPayoutSetting_Agent rmv WITH (ROWLOCK)
					WHERE	custid = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustMaxPayoutSetting_Agent = 0
				END
				IF @IsDelete_CustPTSetting3rd_Agent = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, DELETED.IsLive, dbo.f_GetDateTime2()
					INTO CustPTSetting3rd_Agent_Del_InHouse (CustID,SportType,BetType,IsLive,RepUpdateTime)
					FROM CustPTSetting3rd_Agent rmv WITH (ROWLOCK)
					WHERE	custid = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustPTSetting3rd_Agent = 0
				END
				IF @IsDelete_CustPTGroupSetting3rd_Member = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.AgentID, DELETED.SportType, DELETED.BetType, DELETED.IsLive, dbo.f_GetDateTime2()
					INTO CustPTGroupSetting3rd_Member_Del_InHouse (AgentID,SportType,BetType,IsLive,RepUpdateTime)
					FROM CustPTGroupSetting3rd_Member rmv WITH (ROWLOCK)
					WHERE	rmv.AgentID = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustPTGroupSetting3rd_Member = 0
				END
				IF @IsDelete_CustStakeLevel_Agent = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
					INTO CustStakeLevel_Agent_Del_InHouse (CustID,SportType,BetType,RepUpdateTime)
					FROM CustStakeLevel_Agent rmv WITH (ROWLOCK)
					WHERE	rmv.CustID = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustStakeLevel_Agent = 0
				END
				IF @IsDelete_CustWinLossLimit_Agent = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
					INTO CustWinLossLimit_Agent_Del_InHouse (CustID,SportType,BetType,RepUpdateTime)
					FROM CustWinLossLimit_Agent rmv WITH (ROWLOCK)
					WHERE	rmv.CustID = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustWinLossLimit_Agent = 0
				END
				IF @IsDelete_VRAgentAutoAdjustment = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.AgentID, DELETED.Type, dbo.f_GetDateTime2()
					INTO VRAgentAutoAdjustment_Del_InHouse (AgentID,Type,RepUpdateTime)
					FROM VRAgentAutoAdjustment rmv WITH (ROWLOCK)
					WHERE	rmv.AgentID = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_VRAgentAutoAdjustment = 0
				END
				IF @IsDelete_CustPTTemplateDetail = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.TemplateID, DELETED.GroupID, DELETED.SubGroupID, dbo.f_GetDateTime2()
					INTO CustPTTemplateDetail_Del_InHouse (TemplateID,GroupID,SubGroupID,RepUpdateTime)
					FROM CustPTTemplateDetail rmv WITH (ROWLOCK)
					INNER JOIN CustPTTemplate cp WITH (NOLOCK) ON rmv.TemplateID = cp.TemplateID
					WHERE	cp.CustID = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustPTTemplateDetail = 0
				END
				IF @IsDelete_CustPTTemplate = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.TemplateID, dbo.f_GetDateTime2()
					INTO CustPTTemplate_Del_InHouse (TemplateID,RepUpdateTime)
					FROM CustPTTemplate rmv WITH (ROWLOCK)
					WHERE	rmv.CustID = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustPTTemplate = 0
				END
				-- Agent & Downline
				IF @IsDelete_BetLimitControlCustSetting = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.BetLimitTypeID, dbo.f_GetDateTime2()
					INTO BetLimitControlCustSetting_Del_InHouse (CustID,BetLimitTypeID,RepUpdateTime)
					FROM BetLimitControlCustSetting rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_BetLimitControlCustSetting = 0
				END
				IF @IsDelete_VRCustSetting = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.LevelID, dbo.f_GetDateTime2()
					INTO VRCustSetting_Del_InHouse (CustID,LevelID,RepUpdateTime)
					FROM VRCustSetting rmv WITH (ROWLOCK)
					WHERE	rmv.CustID IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_VRCustSetting = 0
				END
				IF @IsDelete_VRCustLockStatus = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.Type, dbo.f_GetDateTime2()
					INTO VRCustLockStatus_Del_InHouse (CustID,Type,RepUpdateTime)
					FROM VRCustLockStatus rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_VRCustLockStatus = 0
				END
				IF @IsDelete_VRSettingManualUpdAcc = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.SportType, DELETED.CustID, dbo.f_GetDateTime2()
					INTO VRSettingManualUpdAcc_Del_InHouse (SportType,CustID,RepUpdateTime)
					FROM VRSettingManualUpdAcc rmv WITH (ROWLOCK)
					WHERE	rmv.CustID IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_VRSettingManualUpdAcc = 0
				END
				IF @IsDelete_CustVirtualSetting = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, DELETED.seqNo, dbo.f_GetDateTime2()
					INTO CustVirtualSetting_Del_InHouse (CustID,seqNo,RepUpdateTime)
					FROM CustVirtualSetting rmv WITH (ROWLOCK)
					WHERE	rmv.CustID IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustVirtualSetting = 0
				END

				IF 	 ( @IsDelete_BetSetting_Member				= 1)
				    OR ( @IsDelete_BetSetting3rd_Member				= 1)
				    OR ( @IsDelete_CustDiscount3rd_Member				= 1)
				    OR ( @IsDelete_CustMaxPayoutSetting_Member			= 1)
				    OR ( @IsDelete_CustPTSetting3rd_Member			= 1)
				    OR ( @IsDelete_CustSettingMode3rd				= 1)
				    OR ( @IsDelete_CustStakeLevel_Member				= 1)
				    OR ( @IsDelete_CustWinLossLimit_Member			= 1)
				    OR ( @IsDelete_VRCustAutoAdjustment				= 1)
				    OR ( @IsDelete_WinLimit_CustGameMonitoring			= 1)
				    OR ( @IsDelete_WinLimit_CustGameMonitoring_History	= 1)
				    OR ( @IsDelete_WinLimit_CustGameStatus			= 1)
				    OR ( @IsDelete_RobotList						= 1)
				    OR ( @IsDelete_CustQRCode						= 1)
					-- Agent Affected:
				    OR ( @IsDelete_BetSetting_Agent					= 1)
				    OR ( @IsDelete_BetSetting3rd_Agent				= 1)
				    OR ( @IsDelete_CustDiscount3rd_Agent				= 1)
				    OR ( @IsDelete_CustMaxPayoutSetting_Agent			= 1)
				    OR ( @IsDelete_CustPTSetting3rd_Agent				= 1)
				    OR ( @IsDelete_CustPTGroupSetting3rd_Member			= 1)
				    OR ( @IsDelete_CustStakeLevel_Agent				= 1)
				    OR ( @IsDelete_CustWinLossLimit_Agent				= 1)
				    OR ( @IsDelete_VRAgentAutoAdjustment				= 1)	  
				    OR ( @IsDelete_CustPTTemplateDetail				= 1)
				    OR ( @IsDelete_CustPTTemplate					= 1)
				    -- Agent & Downline Affected
				    OR ( @IsDelete_BetLimitControlCustSetting			= 1)
				    OR ( @IsDelete_VRCustSetting					= 1)
				    OR ( @IsDelete_VRCustLockStatus					= 1)
				    OR ( @IsDelete_VRSettingManualUpdAcc				= 1)
				    OR ( @IsDelete_CustVirtualSetting				= 1)
					WAITFOR DELAY @delayTime

				ELSE
					BREAK;
			END

			-- Old Style In House:
			DECLARE @CustProfilePicture TABLE (CustId int, ImageId int) 

			UPDATE t
			SET t.IsDeleted = 1,
				t.RepUpdateTime = SYSDATETIME()
			OUTPUT deleted.CustId,deleted.ImageId INTO @CustProfilePicture(CustId,ImageId)
			FROM dbo.CustProfilePicture t WITH (UPDLOCK,ROWLOCK)
			WHERE custid = @AgentID 
			
			UPDATE t
			SET t.IsDeleted = 1,
				t.RepUpdateTime = SYSDATETIME()
			FROM dbo.ProfilePicture t WITH (UPDLOCK,ROWLOCK)
				INNER JOIN @CustProfilePicture c
					ON t.ImageId = c.ImageId
			WHERE t.ImageId > 1000000 -- just delete user upload image ( id > 1000000, not delete system library image id <= 1000000)

			-- Just Normal Delete, Table Not Yet Apply Rep Inhouse / MS execrep
			DELETE vbs
			FROM VRMemberBigStake vbs WITH (ROWLOCK)
			WHERE vbs.CustID IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)
		END
		ELSE -- SiteDB is not exist table Return 
			RETURN;
		-- End Stage 3

	END

	ELSE IF @Type = 2 --[Stage 4: Delete cust info for members under agent]
	BEGIN
		 IF OBJECT_ID('CustAgent')		IS NOT NULL
	   AND OBJECT_ID('CustLoginInfo')		IS NOT NULL
	   AND OBJECT_ID('custSub')			IS NOT NULL
	   AND OBJECT_ID('CustLoginInfoSub')	IS NOT NULL
	   AND OBJECT_ID('CustLoginInfo_Member')  IS NOT NULL
	   AND OBJECT_ID('CustProductStatus')	IS NOT NULL
	   AND OBJECT_ID('Custinfo')			IS NOT NULL
	   AND OBJECT_ID('Customer')			IS NOT NULL
		BEGIN

			WHILE (1=1)
			BEGIN
				-- Agent Affected:
				IF @IsDelete_CustAgent = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
					INTO CustAgent_Del_InHouse (CustID,RepUpdateTime)
					FROM CustAgent rmv WITH (ROWLOCK)
					WHERE	custid = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustAgent = 0
				END
			
				IF @IsDelete_CustLoginInfo = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
					INTO CustLoginInfo_Del_InHouse (CustID,RepUpdateTime)
					FROM CustLoginInfo rmv WITH (ROWLOCK)
					WHERE	custid = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustLoginInfo = 0
				END
			
				IF @IsDelete_custSub = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.subaccid, dbo.f_GetDateTime2()
					INTO custSub_Del_InHouse (subaccid,RepUpdateTime)
					FROM custSub rmv WITH (ROWLOCK)
					WHERE	custid = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_custSub = 0
				END
			
				IF @IsDelete_CustLoginInfoSub = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.subaccid, dbo.f_GetDateTime2()
					INTO CustLoginInfoSub_Del_InHouse (subaccid,RepUpdateTime)
					FROM CustLoginInfoSub rmv WITH (ROWLOCK)
					WHERE	custid = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustLoginInfoSub = 0
				END
				-- Member Affected:
				IF @IsDelete_CustLoginInfo_Member = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
					INTO CustLoginInfo_Member_Del_InHouse (CustID,RepUpdateTime)
					FROM CustLoginInfo_Member rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE roleid = 1 
										AND recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustLoginInfo_Member = 0
				END
			
				-- Agent & Downline Affected:
				IF @IsDelete_CustProductStatus = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
					INTO CustProductStatus_Del_InHouse (CustID,RepUpdateTime)
					FROM CustProductStatus rmv WITH (ROWLOCK)
					WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
									WHERE recommend = @AgentID
										)

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_CustProductStatus = 0
				END
				IF @IsDelete_Custinfo = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
					INTO Custinfo_Del_InHouse (CustID,RepUpdateTime)
					FROM Custinfo rmv WITH (ROWLOCK)
					WHERE	recommend = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_Custinfo = 0
				END
				IF @IsDelete_Customer = 1
				BEGIN
					DELETE TOP (@BatchSize) rmv
					OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
					INTO Customer_Del_InHouse (CustID,RepUpdateTime)
					FROM Customer rmv WITH (ROWLOCK)
					WHERE	rmv.recommend = @AgentID

					IF @@ROWCOUNT = 0
						SELECT @IsDelete_Customer = 0
				END

				IF 	   ( @IsDelete_CustAgent			= 1)
					OR ( @IsDelete_CustLoginInfo			= 1)
					OR ( @IsDelete_custSub				= 1)
					OR ( @IsDelete_CustLoginInfoSub		= 1)
					OR ( @IsDelete_CustLoginInfo_Member		= 1)
					OR ( @IsDelete_CustProductStatus		= 1)
					OR ( @IsDelete_Custinfo				= 1)
					OR ( @IsDelete_Customer				= 1)
					WAITFOR DELAY @delayTime

				ELSE
					BREAK;
			END
		END
		ELSE -- SiteDB is not exist table Return 
			RETURN;
		-- End Stage 4
	END
END