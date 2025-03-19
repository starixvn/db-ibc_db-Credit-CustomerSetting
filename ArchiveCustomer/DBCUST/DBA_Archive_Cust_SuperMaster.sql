/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_Archive_Cust_SuperMaster]
	@CustID	INT,
	@Stage SMALLINT
AS 
/*
		Description: Disable an Master, Super
		Create date: 20200911
		Original SP: 
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
			- 20201130@Eden: NAP/Alpha & EXT - Apply color for archived accounts [Redmine:145018]
			- 20210316@Helen: backup CustSub and delete for stage 4 [RedmineID: #130032]
			- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
			- 20210810@Eden: Enhance Performance for stage 1 [RedmineID: #155969]
			- 20210923@Eden: Include newly created tables into Archive Credit Dormant Account process [redmine: #162050]
			- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
			- 20230529@Eden: Archiving credit accounts for additional tables [Redmine: #188850]
			- 20231019@Helios: Customer Setting - Remove old Structure un Use [RedmineID: #193083]
			- 20241030@Helios: ScaleOut Apply DeleteInHouse - Extend more table - Remove Code Old Structure [RedmineID: #201061] 
*/
BEGIN
	DECLARE @RoleID INT

	IF @Stage = 1
	BEGIN
		SELECT @RoleID = ci.roleid FROM custInfo ci WITH (NOLOCK) WHERE ci.custid = @CustID
		--CLosed Super, Master, Agent
		IF @RoleID = 4
		BEGIN
			WHILE (1=1)
			BEGIN 
				UPDATE TOP(5000) cps
					SET CloseInfo = CloseInfo|POWER(2,@RoleID - 1)
						, RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.custInfo ci WITH (NOLOCK)
					INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
				WHERE ci.srecommend = @CustID AND ci.roleid IN (4,3) AND CloseInfo&POWER(2,@RoleID - 1) = 0

				IF @@ROWCOUNT < 5000
					BREAK
			END
		END
		ELSE IF @RoleID = 3
		BEGIN
			WHILE (1=1)
			BEGIN
				UPDATE TOP(5000) cps
					SET CloseInfo = CloseInfo|POWER(2,@RoleID - 1)
					, RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.custInfo ci WITH (NOLOCK)
					INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
				WHERE ci.mrecommend = @CustID AND ci.roleid IN (3,2) AND CloseInfo&POWER(2,@RoleID - 1) = 0 

				IF @@ROWCOUNT < 5000
					BREAK
			END
		END

		--> Insert Update ClosedReason
		IF NOT EXISTS (SELECT 1 FROM dbo.CustLoginInfo WITH(NOLOCK) WHERE custid = @custid)
			INSERT INTO CustLoginInfo(CustID, ClosedReason) SELECT @CustID, 4
		ELSE
			UPDATE m
			SET ClosedReason = 4
			, RepUpdateTime = dbo.f_GetDateTime2()
			FROM CustLoginInfo m WITH (ROWLOCK, UPDLOCK)
			WHERE m.CustID = @CustID
		
	END
	ELSE IF @Stage = 2 
	BEGIN 
		UPDATE dbo.Custinfo WITH (UPDLOCK,ROWLOCK)
		SET	[enabled] = 0, credit = 0, RepUpdateTime = dbo.f_GetDateTime2()
		WHERE	custid = @CustID

		SELECT @RoleID = ci.roleid FROM custInfo ci WITH (NOLOCK) WHERE ci.custid = @CustID

		IF @RoleID = 4
		BEGIN
			WHILE (1=1)
			BEGIN 
				UPDATE TOP(5000) cps
					SET CloseInfo = CloseInfo|POWER(2,@RoleID - 1)
					, RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.custInfo ci WITH (NOLOCK)
					INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
				WHERE ci.srecommend = @CustID AND ci.roleid IN (4,3) AND CloseInfo&POWER(2,@RoleID - 1) = 0

				IF @@ROWCOUNT < 5000
					BREAK
			END
		END
		ELSE IF @RoleID = 3
		BEGIN
			WHILE (1=1)
			BEGIN
				UPDATE TOP(5000) cps
					SET CloseInfo = CloseInfo|POWER(2,@RoleID - 1)
					, RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.custInfo ci WITH (NOLOCK)
					INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
				WHERE ci.mrecommend = @CustID AND ci.roleid IN (3,2) AND CloseInfo&POWER(2,@RoleID - 1) = 0 

				IF @@ROWCOUNT < 5000
					BREAK
			END
		END

	END
	ELSE IF @Stage = 3
	BEGIN
		-- Profile Picture use old style rep in house DELETE
		DECLARE @CustProfilePicture TABLE (CustId int, ImageId int) 

		UPDATE t
		SET t.IsDeleted = 1,
			t.RepUpdateTime = SYSDATETIME()
		OUTPUT deleted.CustId,deleted.ImageId INTO @CustProfilePicture(CustId,ImageId)
		FROM dbo.CustProfilePicture t WITH (UPDLOCK,ROWLOCK)
		WHERE custid = @CustID 
			
		UPDATE t
		SET t.IsDeleted = 1,
			t.RepUpdateTime = SYSDATETIME()
		FROM dbo.ProfilePicture t WITH (UPDLOCK,ROWLOCK)
			INNER JOIN @CustProfilePicture c
				ON t.ImageId = c.ImageId
		WHERE t.ImageId > 1000000 -- just delete user upload image ( id > 1000000, not delete system library image id <= 1000000)


		-- New Style Rep InHouse DELETE


		-- Virtual:
		DELETE rmv
		OUTPUT DELETED.CustID, DELETED.seqNo, dbo.f_GetDateTime2()
		INTO CustVirtualSetting_Del_Inhouse(CustID, seqNo, RepUpdateTime)
		FROM CustVirtualSetting rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		-- Discount Setting:
		DELETE rmv
		OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
		INTO CustDiscount3rd_Agent_Del_Inhouse(CustID, SportType, BetType, RepUpdateTime)
		FROM CustDiscount3rd_Agent rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		-- PT Setting:
		DELETE rmv
		OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, DELETED.IsLive, dbo.f_GetDateTime2()
		INTO CustPTSetting3rd_Agent_Del_Inhouse(CustID, SportType, BetType, IsLive, RepUpdateTime)
		FROM CustPTSetting3rd_Agent rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		-- StakeLevel Setting:
		DELETE rmv
		OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
		INTO CustStakeLevel_Agent_Del_Inhouse(CustID, SportType, BetType, RepUpdateTime)
		FROM CustStakeLevel_Agent rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		-- WL Setting:
		DELETE rmv
		OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
		INTO CustWinLossLimit_Agent_Del_Inhouse(CustID, SportType, BetType, RepUpdateTime)
		FROM CustWinLossLimit_Agent rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		-- MaxPayout Setting:
		DELETE rmv
		OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
		INTO CustMaxPayoutSetting_Agent_Del_Inhouse(CustID, SportType, BetType, RepUpdateTime)
		FROM CustMaxPayoutSetting_Agent rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		-- BetSetting Setting SportsBook:
		DELETE rmv
		OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
		INTO BetSetting_Agent_Del_Inhouse(CustID, SportType, BetType, RepUpdateTime)
		FROM BetSetting_Agent rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		-- BetSetting Setting 3rd:
		DELETE rmv
		OUTPUT DELETED.CustID, DELETED.SportType, DELETED.BetType, dbo.f_GetDateTime2()
		INTO BetSetting3rd_Agent_Del_Inhouse(CustID, SportType, BetType, RepUpdateTime)
		FROM BetSetting3rd_Agent rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		-- Extend more table:
		DELETE rmv
		OUTPUT DELETED.CustID, DELETED.BetLimitTypeID, dbo.f_GetDateTime2()
		INTO BetLimitControlCustSetting_Del_Inhouse(CustID, BetLimitTypeID, RepUpdateTime)
		FROM BetLimitControlCustSetting rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		--DECLARE @CustPTTemplate_tmp TABLE (TemplateID INT) 

		DELETE cpd
		OUTPUT DELETED.TemplateID, DELETED.GroupID, DELETED.SubGroupID, dbo.f_GetDateTime2()
		INTO CustPTTemplateDetail_Del_Inhouse(TemplateID, GroupID, SubGroupID , RepUpdateTime)
		FROM CustPTTemplateDetail cpd WITH(ROWLOCK)
		INNER JOIN CustPTTemplate rmv WITH (NOLOCK) ON rmv.TemplateID = cpd.TemplateID
		WHERE CustID = @CustID

		DELETE rmv
		OUTPUT DELETED.TemplateID, dbo.f_GetDateTime2()
		INTO CustPTTemplate_Del_Inhouse(TemplateID, RepUpdateTime)
		FROM CustPTTemplate rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		DELETE rmv
		OUTPUT DELETED.CustID, DELETED.Type, dbo.f_GetDateTime2()
		INTO VRCustLockStatus_Del_Inhouse(CustID, Type, RepUpdateTime)
		FROM VRCustLockStatus rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		DELETE rmv
		OUTPUT DELETED.CustID, DELETED.LevelID, dbo.f_GetDateTime2()
		INTO VRCustSetting_Del_Inhouse(CustID, LevelID, RepUpdateTime)
		FROM VRCustSetting rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		DELETE rmv
		OUTPUT DELETED.SportType, DELETED.CustID, dbo.f_GetDateTime2()
		INTO VRSettingManualUpdAcc_Del_Inhouse(SportType, CustID, RepUpdateTime)
		FROM VRSettingManualUpdAcc rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

	END

	ELSE IF @Stage = 4
	BEGIN
		
		DELETE rmv
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO Custinfo_Del_Inhouse(CustID, RepUpdateTime)
		FROM Custinfo rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		DELETE rmv
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO Customer_Del_Inhouse(CustID, RepUpdateTime)
		FROM Customer rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID
		
		DELETE rmv
		OUTPUT DELETED.SubAccId, dbo.f_GetDateTime2()
		INTO custSub_Del_Inhouse(SubAccId, RepUpdateTime)
		FROM custSub rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID
		
		DELETE rmv
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustProductStatus_Del_Inhouse(CustID, RepUpdateTime)
		FROM CustProductStatus rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		DELETE rmv
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustMaster_Del_Inhouse(CustID, RepUpdateTime)
		FROM CustMaster rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID
		
		DELETE rmv
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustLoginInfo_Del_Inhouse(CustID, RepUpdateTime)
		FROM CustLoginInfo rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		DELETE rmv
		OUTPUT DELETED.SubAccId, dbo.f_GetDateTime2()
		INTO CustLoginInfoSub_Del_Inhouse(SubAccId, RepUpdateTime)
		FROM CustLoginInfoSub rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID
		
		DELETE rmv
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustSuper_Del_Inhouse(CustID, RepUpdateTime)
		FROM CustSuper rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID

		DELETE rmv
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustSuperProfile_Del_Inhouse(CustID, RepUpdateTime)
		FROM CustSuperProfile rmv WITH(ROWLOCK) 
		WHERE CustID = @CustID
	END
END