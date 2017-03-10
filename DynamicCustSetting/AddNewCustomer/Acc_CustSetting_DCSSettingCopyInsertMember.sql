ALTER PROCEDURE [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember] 
	@CustID				INT
	, @ProductID		TINYINT = NULL
	, @ExistingCustID	INT		
	, @SubAccID			INT				= 0
	, @IP				VARCHAR(50)		= ''
	, @UserID			INT				= 0
	, @ErrCode			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(4000)	= ''	OUTPUT
AS
/*
	Created: 20151030@Elodie
	Task : Copy Insert Settings of an existing member Into DCS Structure
	DB:  DBCUST/CustDB
	Original:

	Revision
		- 20160104@Dominic: Implementing Charge Commission Plugin - Redmine #49689
		- 20160115@Dominic: Do not update setting when there is no data Redmine: #50937
		- 20160108@Elodie: Implementing SMA WinLossLimit Plugin - [Redmine #50082]
		- 20160125@Billy: Implementing Stake Level Settings - [Redmine: #51026]
		- 20160407@Winnie: Group stake level setting - [Redmine: #55532]
		- 20160711@Winnie: fix bug #60611 [NAP - Copy New Member: a single log is written for both Allbet and Macau Games when copying]
		- 20160801@Elodie: Implementing BetGameLimit Settings, GameStatus Setting - [Redmine: #60809]
		- 20161011@Winnie:  Implement for Loss limit setting type RedmineID: #65472
		- 20160801@Elodie: Implementing NewProductStatus Plugin - [Redmine #70722]	
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @xmlPT XML, @xmlBetLimit XML, @xmlDiscount XML, @xmlStatus XML, @xmlWinLossLimit XML, @xmlStakeLevel XML,@xmlStakeLevel8 XML, @xmlLossLimit XML
	DECLARE @xmlStr VARCHAR(MAX)
	SELECT @ErrCode = 0		
	
	/********************************************* Position Taking: SettingType = 1 ***********************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,1))
	BEGIN
		DECLARE @ProductID1 INT
		CREATE TABLE #TempPT (ProductID INT)
		DECLARE @NewPTTble TABLE (
				  SportType			SMALLINT
				, BetType			SMALLINT
				, IsLive			BIT
				, AgentPT			TINYINT
				UNIQUE CLUSTERED (SportType, BetType, IsLive)
			)
	
		DECLARE @SettingMode BIT, @AgentID INT
		--Get setting mode
		SELECT @SettingMode = IsGrouped
		FROM dbo.CustSettingMode3rd
		WHERE CustID= @ExistingCustID

		SELECT @AgentID = recommend FROM CustInfo WITH (NOLOCK) WHERE custid = @CustID

		IF @SettingMode = 0
		BEGIN
			INSERT INTO @NewPTTble (
						SportType
						, BetType
						, Islive
						, AgentPT
						)
					SELECT mcs.SportType
						, mcs.BetType
						, mcs.IsLive
						, CASE WHEN mcs.agentPT > acs.agentPT THEN acs.agentPT ELSE mcs.agentPT END
					FROM dbo.CustPTSetting3rd_Member mcs WITH (NOLOCK)
						INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND acs.islive = mcs.islive
						INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,1) fil ON fil.SportType = mcs.SportType AND fil.BetType = mcs.BetType AND fil.IsLive = mcs.IsLive
					WHERE mcs.custid = @ExistingCustID AND acs.custid = @AgentID
		END
		ELSE
		BEGIN
			----check a1<a2
			--IF EXISTS (SELECT 1
			--		FROM dbo.CustPTGroupSetting3rd_Member mcs WITH (NOLOCK)
			--			INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND acs.islive = mcs.islive
			--		WHERE mcs.AgentID = @AgentID AND acs.custid = @AgentID AND mcs.agentPT > acs.agentPT)
			--	SET @SettingMode = 0

			INSERT INTO @NewPTTble (
						SportType
						, BetType
						, Islive
						, AgentPT
						)
					SELECT mcs.SportType
						, mcs.BetType
						, mcs.IsLive
						, CASE WHEN mcs.agentPT > acs.agentPT THEN acs.agentPT ELSE mcs.agentPT END
					FROM dbo.CustPTGroupSetting3rd_Member mcs WITH (NOLOCK)
						INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND acs.islive = mcs.islive
						INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,1) fil ON fil.SportType = mcs.SportType AND fil.BetType = mcs.BetType AND fil.IsLive = mcs.IsLive
					WHERE mcs.AgentID = @AgentID AND acs.custid = @AgentID		
		END
		
		INSERT INTO #TempPT(ProductID)	
		SELECT 
				DISTINCT
				psd.ProductID				
		FROM	ProductSettingDetail AS psd WITH(NOLOCK)
		INNER JOIN	@NewPTTble AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.SettingType =1
			AND psd.ProductID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempPT)
		BEGIN
		SELECT TOP 1 @ProductID1=ProductID FROM #TempPT
		
		SET @xmlPT = ( SELECT
							(
							SELECT nslt.SportType	AS '@SportType'
								, nslt.BetType		AS '@BetType'
								, nslt.IsLive		AS '@IsLive'
								, AgentPT		AS '@AgentPT'
							FROM @NewPTTble nslt
							INNER JOIN ProductSettingDetail AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType AND nslt.IsLive=psd.IsLive
										WHERE psd.SettingType=1 AND psd.ProductID=@ProductID1
							FOR XML PATH('PT')
								, TYPE
							)
						FOR XML PATH('ROOT')
							, TYPE
						)
	
		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlPT)	
		
		IF EXISTS (SELECT TOP 1 1 FROM @NewPTTble)
		BEGIN
			EXEC Acc_CustSetting_AgentPTOnMemberUpd
				@CustID = @CustID
				, @PT = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
		END
		
		DELETE FROM	#TempPT WHERE ProductID=@ProductID1
		END
	END
	/********************************************* Bet Limit : SettingType = 2 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,2))
	BEGIN
		DECLARE @ProductID2 INT
		CREATE TABLE #TempBetlimit (ProductID INT)
		DECLARE @NewBetLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			)

		INSERT INTO @NewBetLimitTbl
		SELECT bl.SportType
			, bl.BetType
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
		FROM dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,2) fil ON fil.SportType = bl.SportType AND fil.BetType = bl.BetType		
		WHERE bl.custid = @ExistingCustID
		
		INSERT INTO #TempBetlimit(ProductID)	
		SELECT 
				DISTINCT
				psd.ProductID				
		FROM	ProductSettingDetail AS psd WITH(NOLOCK)
		INNER JOIN	@NewBetLimitTbl AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.SettingType =2
			AND psd.ProductID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempBetlimit)
		BEGIN
		SELECT TOP 1 @ProductID2=ProductID FROM #TempBetlimit		
		SET @xmlBetLimit = (SELECT (
									SELECT nslt.SportType	AS '@SportType'
										, nslt.BetType		AS '@BetType'
										, MinBet		AS '@MinBet'
										, MaxBet		AS '@MaxBet'
										, MaxPerMatch	AS '@MaxPerMatch'
									FROM @NewBetLimitTbl nslt
									INNER JOIN ProductSettingDetail AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType
										WHERE psd.SettingType=2 AND psd.ProductID=@ProductID2
									FOR XML PATH('BetLimit')
										, TYPE
									)
							FOR XML PATH('ROOT')
								, TYPE
							)
	
		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlBetLimit)

		IF EXISTS(SELECT TOP 1 1 FROM @NewBetLimitTbl)
		BEGIN
			EXEC Acc_CustSetting_BetLimitUpd 
				  @CustID = @CustID
				, @BetLimit = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
		END
		DELETE FROM	#TempBetlimit WHERE ProductID=@ProductID2
		END
	END
	/********************************************* Commision : SettingType = 3 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,3))
	BEGIN
		DECLARE @ProductID3 INT
		CREATE TABLE #TempComm (ProductID INT)
		DECLARE @NewDiscountTbl TABLE (
					SportType	SMALLINT
				,	BetType		SMALLINT
				,	Discount	DECIMAL(9, 8)
			)
	
		INSERT INTO @NewDiscountTbl
		SELECT dc.SportType
			, dc.BetType
			, dc.PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dc WITH(NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,3) fil ON fil.SportType = dc.SportType AND fil.BetType = dc.BetType
		WHERE dc.CustID	= @ExistingCustID
		
		INSERT INTO #TempComm(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@NewDiscountTbl AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.SettingType =3
				AND psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempComm)
		BEGIN
		SELECT TOP 1 @ProductID3=ProductID FROM #TempComm		
		SET @xmlDiscount = ( SELECT (
									SELECT nslt.SportType AS '@SportType'
										, nslt.BetType AS '@BetType'
										, Discount AS '@Discount'
									FROM @NewDiscountTbl nslt
									INNER JOIN ProductSettingDetail AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
										WHERE psd.SettingType =3 AND psd.ProductID=@ProductID3
									FOR XML PATH('Discount')
										, TYPE
									)
							FOR XML PATH('ROOT')
								, TYPE
							)

		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlDiscount)

		IF EXISTS(SELECT TOP 1 1 FROM @NewDiscountTbl)
		BEGIN
			EXEC Acc_CustSetting_DiscountUpd 		
				  @CustID = @CustID
				, @Discount = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
		END
		DELETE FROM	#TempComm WHERE ProductID=@ProductID3
		END
	END
	/*********************************************Charge Commision : SettingType = 5 ****************************************/
	DECLARE @ProductID5 INT
	CREATE TABLE #TempChargeComm (ProductID INT)
	
	DECLARE @NewChargeCommTbl TABLE (
					SportType	SMALLINT
				,	BetType		SMALLINT
				,	Discount	DECIMAL(9, 8)
			)
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,5))
	BEGIN
	
		INSERT INTO @NewChargeCommTbl
		SELECT dc.SportType
			, dc.BetType
			, dc.PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dc WITH(NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,5) fil ON fil.SportType = dc.SportType AND fil.BetType = dc.BetType
		WHERE dc.CustID	= @ExistingCustID
		
		INSERT INTO #TempChargeComm(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@NewChargeCommTbl AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.SettingType =5
				AND psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempChargeComm)
		BEGIN
		SELECT TOP 1 @ProductID5=ProductID FROM #TempChargeComm		
		SET @xmlDiscount = ( SELECT (
									SELECT nslt.SportType AS '@SportType'
										, nslt.BetType AS '@BetType'
										, Discount AS '@Discount'
									FROM @NewChargeCommTbl nslt
									INNER JOIN ProductSettingDetail AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
										WHERE psd.SettingType =5 AND psd.ProductID=@ProductID5
									FOR XML PATH('Discount')
										, TYPE
									)
							FOR XML PATH('ROOT')
								, TYPE
							)

		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlDiscount)

		IF EXISTS(SELECT TOP 1 1 FROM @NewChargeCommTbl)
		BEGIN
			EXEC Acc_CustSetting_DiscountUpd 		
				  @CustID = @CustID
				, @Discount = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @SettingType = 5
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
		END
		DELETE FROM	#TempChargeComm WHERE ProductID=@ProductID5
		END
	END
	/********************************************* Product Status: SettingType = 4 ************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,4))
	BEGIN
		DECLARE @ProductID4 INT
		CREATE TABLE #TempStatus (ProductID INT)
		DECLARE @NewDisableStatTbl TABLE(
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, IsDisabledDownline	BIT
			)
	
		INSERT INTO @NewDisableStatTbl (SportType,BetType,IsDisabled,IsDisabledDownline)
		SELECT psp.SportType
			, psp.BetType		
			, dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
			, 0 AS IsDisabledDownline
		FROM dbo.CustProductStatus stt WITH (NOLOCK) 
			CROSS JOIN ProductStatusProfile PSP WITH (NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,4) fil ON fil.SportType = PSP.SportType AND fil.BetType = PSP.BetType 
		WHERE stt.CustID = @ExistingCustID

		INSERT INTO #TempStatus(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@NewDisableStatTbl AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE psd.SettingType =4
				AND	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempStatus)
		BEGIN
		SELECT TOP 1 @ProductID4=ProductID FROM #TempStatus		
		SET @xmlStatus = (SELECT (
								SELECT nslt.SportType	AS '@SportType'
									, nslt.BetType		AS '@BetType'
									, nslt.IsDisabled	AS '@IsDisabled'
									, nslt.IsDisabledDownline AS '@IsDisabledDownline'
								FROM @NewDisableStatTbl nslt								
									INNER JOIN ProductSettingDetail AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
										WHERE psd.SettingType =4 AND psd.ProductID=@ProductID4
								FOR XML PATH('ProductStatus')
									, TYPE
								)
						FOR XML PATH('ROOT')
							, TYPE
						)

		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlStatus)

		IF EXISTS(SELECT TOP 1 1 FROM @NewDisableStatTbl)
		BEGIN
			EXEC Acc_CustSetting_DisableStatUpd
				  @CustID = @CustID
				, @IsDisabled = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT			
		END
		DELETE FROM	#TempStatus WHERE ProductID=@ProductID4
		END
	END

	/********************************************* SMA Win Loss Limit : SettingType = 6 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,6))
	BEGIN
		DECLARE @ProductID6 INT
		CREATE TABLE #TempWLLimit (ProductID INT)
		DECLARE @NewWinLossLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			INT
			, MaxWinLimit		SMALLMONEY
			, MaxLossLimit		MONEY
			, IsAutoReset		BIT
			)

		INSERT INTO @NewWinLossLimitTbl
		SELECT wl.SportType
			, wl.BetType
			, wl.MaxWinLimit
			, wl.MaxLossLimit
			, wl.IsAutoReset
		FROM dbo.CustWinLossLimit_Member wl WITH (NOLOCK)		
		WHERE wl.custid = @ExistingCustID
		
		INSERT INTO #TempWLLimit(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@NewWinLossLimitTbl AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.SettingType =6
				AND psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempWLLimit)
		BEGIN
		SELECT TOP 1 @ProductID6=ProductID FROM #TempWLLimit
		SET @xmlWinLossLimit = (SELECT (
									SELECT nslt.SportType	AS '@SportType'
										, nslt.BetType		AS '@BetType'
										, nslt.MaxWinLimit	AS '@MaxWinLimit'
										, nslt.MaxLossLimit	AS '@MaxLossLimit'
										, nslt.IsAutoReset	AS '@IsAutoReset'
									FROM @NewWinLossLimitTbl nslt
									INNER JOIN ProductSettingDetail AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
										WHERE psd.SettingType =6 AND psd.ProductID=@ProductID6
									FOR XML PATH('Limit')
										, TYPE
									)
							FOR XML PATH('ROOT')
								, TYPE
							)
	
		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlWinLossLimit)

				EXEC dbo.Acc_CustSetting_WinLossLimitUpd 
			  @CustID = @CustID
			, @Limit = @xmlStr
			, @SettingType = 6
			, @SubAccID = @SubAccID
			, @IP = @IP
			, @UserID = @UserID
			, @ErrCode = @ErrCode OUTPUT
			, @ErrMsg = @ErrMsg OUTPUT
		DELETE FROM	#TempWLLimit WHERE ProductID=@ProductID6
		END
			
	END
	
	/****************************** Stake Level Member Single Selection : SettingType = 7 ******************************/
	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL, 7))
	BEGIN
		DECLARE @ProductID7 INT
		CREATE TABLE #TempStakeLevel (ProductID INT)
		DECLARE	@NewStakeLevelTbl TABLE (
					SportType		SMALLINT
				,	BetType			SMALLINT
				,	StakeLevelList	VARCHAR(200)
				)
		INSERT INTO @NewStakeLevelTbl
			(	SportType     , BetType     , StakeLevelList)
		SELECT	cslm.SportType, cslm.BetType, cslm.StakeLevelList
		FROM	dbo.CustStakeLevel_Member AS cslm WITH(NOLOCK)		
		WHERE	cslm.CustID = @ExistingCustID
		
		INSERT INTO #TempStakeLevel(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@NewStakeLevelTbl AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.SettingType =7
				AND psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempStakeLevel)
		BEGIN
		SELECT TOP 1 @ProductID7=ProductID FROM #TempStakeLevel
		SELECT	@xmlStakeLevel =	(
										SELECT	nslt.SportType			AS '@SportType'
											,	nslt.BetType			AS '@BetType'
											,	nslt.StakeLevelList		AS '@StakeLevelList'
										FROM	@NewStakeLevelTbl AS nslt
										INNER JOIN ProductSettingDetail AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
										WHERE SettingType=7 AND  psd.ProductID=@ProductID7 
										FOR XML PATH('StakeLevel')
									,	ROOT('ROOT')
									,	TYPE
									)
	
		SELECT	@xmlStr = CONVERT(VARCHAR(MAX), @xmlStakeLevel)

		EXEC	dbo.Acc_CustSetting_StakeLevelUpd 
					@CustID		= @CustID
				,	@StakeLevel	= @xmlStr
				,	@SubAccID	= @SubAccID
				,	@UserID		= @UserID
				,	@IP			= @IP
				,	@ErrCode	= @ErrCode		OUTPUT
				,	@ErrMsg		= @ErrMsg		OUTPUT	
		DELETE FROM	#TempStakeLevel WHERE ProductID=@ProductID7			
	END
	END
	/****************************** Stake Level Member Single Selection : SettingType = 8 ******************************/
	IF EXISTS (SELECT TOP 1 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL, 8))
	BEGIN
		DECLARE @ProductID8 INT
		CREATE TABLE #TempStakeLevel8 (	ProductID INT) 	
				
		DECLARE	@NewStakeLevelTbl8 TABLE (
					SportType		SMALLINT
				,	BetType			SMALLINT
				,	StakeLevelList	VARCHAR(200)
				)
		INSERT INTO @NewStakeLevelTbl8
			(	SportType     , BetType     , StakeLevelList)
		SELECT	cslm.SportType, cslm.BetType, cslm.StakeLevelList
		FROM	dbo.CustStakeLevel_Member AS cslm WITH(NOLOCK)		
		WHERE	cslm.CustID = @ExistingCustID
		
		INSERT INTO #TempStakeLevel8(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@NewStakeLevelTbl8 AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.SettingType =8
				AND psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				
		WHILE (EXISTS (SELECT TOP 1 1 FROM #TempStakeLevel8))
		BEGIN
		SELECT TOP 1 @ProductID8=ProductID FROM #TempStakeLevel8
		SELECT	@xmlStakeLevel8 =	(
										SELECT	nslt.SportType			AS '@SportType'
											,	nslt.BetType			AS '@BetType'
											,	nslt.StakeLevelList		AS '@StakeLevelList'
										FROM	@NewStakeLevelTbl8 AS nslt
										INNER JOIN ProductSettingDetail AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
										WHERE SettingType=8 AND psd.ProductID=@ProductID8 
										FOR XML PATH('StakeLevel')
									,	ROOT('ROOT')
									,	TYPE
									)
	
		SELECT	@xmlStr = CONVERT(VARCHAR(MAX), @xmlStakeLevel8)

		EXEC	dbo.Acc_CustSetting_StakeLevelUpd
					@CustID		= @CustID
				,	@StakeLevel	= @xmlStr
				,	@SubAccID	= @SubAccID
				,	@UserID		= @UserID
				,	@IP			= @IP
				,	@ErrCode	= @ErrCode		OUTPUT
				,	@ErrMsg		= @ErrMsg		OUTPUT	
				
		DELETE FROM	#TempStakeLevel8 WHERE ProductID=@ProductID8
	
		END
	END
	/********************************************* Game Bet Limit : SettingType = 9 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,9))
	BEGIN
		DECLARE @ProductID9 INT
		CREATE TABLE #TempGameBetlimit (ProductID INT)
		DECLARE @NewGameBetLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			)

		INSERT INTO @NewGameBetLimitTbl
		SELECT bl.SportType
			, bl.BetType
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
		FROM dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,9) fil ON fil.SportType = bl.SportType AND fil.BetType = bl.BetType		
		WHERE bl.custid = @ExistingCustID
		
		INSERT INTO #TempGameBetlimit(ProductID)	
		SELECT 
				DISTINCT
				psd.ProductID				
		FROM	ProductSettingDetail AS psd WITH(NOLOCK)
		INNER JOIN	@NewGameBetLimitTbl AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.SettingType = 9
			AND psd.ProductID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempGameBetlimit)
		BEGIN
			SELECT TOP 1 @ProductID9=ProductID FROM #TempGameBetlimit		
			SET @xmlBetLimit = (SELECT (
										SELECT nslt.SportType	AS '@SportType'
											, nslt.BetType		AS '@BetType'
											, MinBet			AS '@MinBet'
											, MaxBet			AS '@MaxBet'
											, MaxPerMatch		AS '@MaxPerNumber'
										FROM @NewGameBetLimitTbl nslt
										INNER JOIN ProductSettingDetail AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType
											WHERE psd.SettingType = 9 AND psd.ProductID = @ProductID9
										FOR XML PATH('GameBetLimit')
											, TYPE
										)
								FOR XML PATH('ROOT')
									, TYPE
								)
	
			SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlBetLimit)

			IF EXISTS(SELECT TOP 1 1 FROM @NewGameBetLimitTbl)
			BEGIN
				EXEC Acc_CustSetting_GameBetLimitUpd
					  @CustID = @CustID
					, @GameBetLimit = @xmlStr
					, @SubAccID = @SubAccID
					, @IP = @IP
					, @UserID = @UserID
					, @ErrCode = @ErrCode OUTPUT
					, @ErrMsg = @ErrMsg OUTPUT
			END
			DELETE FROM	#TempGameBetlimit WHERE ProductID=@ProductID9
		END
	END
	/********************************************* Game Status: SettingType = 11 ************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,11))
	BEGIN
		DECLARE @ProductID11 INT
		CREATE TABLE #TempGameStatus (ProductID INT)
		DECLARE @NewDisableGameStatTbl TABLE(
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, IsDisabledDownline	BIT
			)
	
		INSERT INTO @NewDisableGameStatTbl (SportType,BetType,IsDisabled,IsDisabledDownline)
		SELECT psp.SportType
			, psp.BetType		
			, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled
			, 0 AS IsDisabledDownline
		FROM dbo.CustProductStatus stt WITH (NOLOCK) 
			CROSS JOIN ProductStatusProfile PSP WITH (NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,11) fil ON fil.SportType = PSP.SportType AND fil.BetType = PSP.BetType 
		WHERE stt.CustID = @ExistingCustID

		INSERT INTO #TempGameStatus(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@NewDisableGameStatTbl AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE psd.SettingType = 11
				AND	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempGameStatus)
		BEGIN
			SELECT TOP 1 @ProductID11 = ProductID FROM #TempGameStatus		
			SET @xmlStatus = (SELECT (
									SELECT nslt.SportType	AS '@SportType'
										, nslt.BetType		AS '@BetType'
										, nslt.IsDisabled	AS '@IsDisabled'
										, nslt.IsDisabledDownline AS '@IsDisabledDownline'
									FROM @NewDisableGameStatTbl nslt								
										INNER JOIN ProductSettingDetail AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
											WHERE psd.SettingType = 11 AND psd.ProductID = @ProductID11
									FOR XML PATH('GameStatus')
										, TYPE
									)
							FOR XML PATH('ROOT')
								, TYPE
							)

			SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlStatus)

			IF EXISTS(SELECT TOP 1 1 FROM @NewDisableGameStatTbl)
			BEGIN
				EXEC Acc_CustSetting_DisableGameStatusUpd
					  @CustID = @CustID
					, @IsDisabled = @xmlStr
					, @SubAccID = @SubAccID
					, @IP = @IP
					, @UserID = @UserID
					, @ErrCode = @ErrCode OUTPUT
					, @ErrMsg = @ErrMsg OUTPUT			
			END
			DELETE FROM	#TempGameStatus WHERE ProductID = @ProductID11
		END
	END
	
	/********************************************* SMA Loss Limit : SettingType = 12 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,12))
	BEGIN
		DECLARE @ProductID12 INT
		CREATE TABLE #TempLLimit (ProductID INT)
		DECLARE @NewLossLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			INT			
			, MaxLossLimit		MONEY
			, IsAutoReset		BIT
			)

		INSERT INTO @NewLossLimitTbl
		SELECT wl.SportType
			, wl.BetType			
			, wl.MaxLossLimit
			, wl.IsAutoReset
		FROM dbo.CustWinLossLimit_Member wl WITH (NOLOCK)		
		WHERE wl.custid = @ExistingCustID
		
		INSERT INTO #TempLLimit(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@NewLossLimitTbl AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.SettingType =12
				AND psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempLLimit)
		BEGIN
			SELECT TOP 1 @ProductID12=ProductID FROM #TempLLimit
			SET @xmlLossLimit = (SELECT (
										SELECT nslt.SportType	AS '@SportType'
											, nslt.BetType		AS '@BetType'										
											, nslt.MaxLossLimit	AS '@MaxLossLimit'
											, nslt.IsAutoReset	AS '@IsAutoReset'
										FROM @NewLossLimitTbl nslt
										INNER JOIN ProductSettingDetail AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
											WHERE psd.SettingType =12 AND psd.ProductID=@ProductID12
										FOR XML PATH('Limit')
											, TYPE
										)
								FOR XML PATH('ROOT')
									, TYPE
								)
		
			SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlLossLimit)

						EXEC dbo.Acc_CustSetting_WinLossLimitUpd 
				  @CustID = @CustID
				, @Limit = @xmlStr
				, @SettingType = 12
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
			DELETE FROM	#TempLLimit WHERE ProductID=@ProductID12
		END
			
	END

	/********************************************* New Product Status: SettingType = 13 ************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,13))
	BEGIN
		DECLARE @ProductID13 INT
		CREATE TABLE #TempProductStatus (ProductID INT)
		DECLARE @NewDisableProductStatTbl TABLE(
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, IsDisabledDownline	BIT
			)
	
		INSERT INTO @NewDisableProductStatTbl (SportType,BetType,IsDisabled,IsDisabledDownline)
		SELECT psp.SportType
			, psp.BetType		
			, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled
			, 0 AS IsDisabledDownline
		FROM dbo.CustProductStatus stt WITH (NOLOCK) 
			CROSS JOIN ProductStatusProfile PSP WITH (NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,13) fil ON fil.SportType = PSP.SportType AND fil.BetType = PSP.BetType 
		WHERE stt.CustID = @ExistingCustID

		INSERT INTO #TempProductStatus(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@NewDisableProductStatTbl AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE psd.SettingType = 13
				AND	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempProductStatus)
		BEGIN
			SELECT TOP 1 @ProductID13 = ProductID FROM #TempProductStatus		
			SET @xmlStatus = (SELECT (
									SELECT nslt.SportType	AS '@SportType'
										, nslt.BetType		AS '@BetType'
										, nslt.IsDisabled	AS '@IsDisabled'
										, nslt.IsDisabledDownline AS '@IsDisabledDownline'
									FROM @NewDisableProductStatTbl nslt								
										INNER JOIN ProductSettingDetail AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
											WHERE psd.SettingType = 13 AND psd.ProductID = @ProductID13
									FOR XML PATH('ProductStatus')
										, TYPE
									)
							FOR XML PATH('ROOT')
								, TYPE
							)

			SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlStatus)

			IF EXISTS(SELECT TOP 1 1 FROM @NewDisableProductStatTbl)
			BEGIN
				EXEC Acc_CustSetting_DisableNewProductStatusUpd
					  @CustID = @CustID
					, @IsDisabled = @xmlStr
					, @SubAccID = @SubAccID
					, @IP = @IP
					, @SystemID = 1
					, @UserID = @UserID
					, @ErrCode = @ErrCode OUTPUT
					, @ErrMsg = @ErrMsg OUTPUT			
			END
			DELETE FROM	#TempProductStatus WHERE ProductID = @ProductID13
		END
	END
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember] TO [vnteam]