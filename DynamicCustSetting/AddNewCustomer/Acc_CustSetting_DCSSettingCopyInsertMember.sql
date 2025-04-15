/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember] 
	  @CustID			INT
	, @ProductID		TINYINT = NULL
	, @ExistingCustID	INT		
	, @SubAccID			INT				= 0
	, @IP				VARCHAR(50)		= ''
	, @UserID			INT				= 0
	, @SystemID TINYINT = 1 --20200305@Tiara  
    , @IsCountPT			BIT = 0
	, @isSearchAndCopy	BIT				= 0
	, @ErrCode			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(4000)	= ''	OUTPUT
	, @SettingStatus TINYINT = 0
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
		- 20170530@Elodie: Implementing TicketCommission Plugin - [Redmine #75221]	
		- 20171017@Elodie: Implementing BetSetting Plugin - [Redmine #83729]	
		- 20190114@Johnson: dont update bettype inactive for settingType = 7(Allbet) [Redmine: #106601]
		- 20190814@Eden: Hide setting of inactive products [Redmine: #117439]
		- 20200305@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
		- 20200414@Tiara: Add new Setting Type 17 for mulitple stakelevel for member [Redmine: #131171]
		- 20200702@Winfred: Update status setting values of Cust when SettingType = 4 (ProductStatus) [RedmineID:#136210]  
		- 20200615@Elodie: Implement new setting type 18,19 [Redmine: #135363]
		- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]
		- 20201118@Eden: Insert New SettingType = 20 [Redmine: #131370]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20211027@Winfred: NAP CM -  Limit Daily PT Update [Redmine: #162476]
		- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
		- 20220808@Tacy: Resolve replication errors when using Search & Copy New member function [RedmineID: #176225]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20230310@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20240215@Eden: Unify Live Casino & RNG slot/RNG Casino [Redmine: #198960]
		- 20240520@Eden: Unify RNG Games [redmine: #204358]
		- 20250325@Johnson: change datatype for ExchangeID[redmine: #221098]
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969]
	Param's Explanation: 
		- @SettingStatus: 0: Pro, 1: UAT 	
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @xmlPT XML, @xmlBetLimit XML, @xmlDiscount XML, @xmlStatus XML, @xmlWinLossLimit XML, @xmlStakeLevel XML,@xmlStakeLevel17 XML,@xmlStakeLevel8 XML, @xmlLossLimit XML
	DECLARE @xmlStr VARCHAR(MAX)
	DECLARE @SettingMode BIT, @AgentID INT, @GroupType TINYINT, @GroupID TINYINT
	SELECT @ErrCode = 0		

	DECLARE @_Site VARCHAR(10), @_SiteID INT, @_Currency INT

	--Get site/currency
	SELECT @_Site = Site, @_Currency = currency FROM dbo.Customer WITH(NOLOCK) WHERE CustID = @CustID
	SELECT @_SiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_Site

	CREATE TABLE #ProductSettingProfile_All( --table include all setting
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		GroupID	tinyint,
		GroupType	tinyint,
		SubType	tinyint,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	CREATE TABLE #ProductSettingProfile( -- table include setting with apply new template by GroupID, GroupType
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		GroupID	tinyint,
		GroupType	tinyint,
		SubType	tinyint,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	CREATE TABLE #ProductSettingDetail_tbl( -- table include setting with apply new template by ProductID, SettingType
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		SubType	tinyint,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingProfile_All(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,GroupID,GroupType,SubType)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,GroupID,GroupType,SubType
	FROM dbo.f_CustSetting_ProductProfileSel (NULL,@SettingStatus,@_SiteID,@_Currency) 
	WHERE SettingType NOT IN (25,26,27,28) -- all setting of SB except product status of MuayThai

	INSERT INTO #ProductSettingProfile(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,GroupID,GroupType,SubType)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,GroupID,GroupType,SubType
	FROM #ProductSettingProfile_All
	WHERE GroupID IN(3,2)

	INSERT INTO #ProductSettingDetail_tbl(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,SubType)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,SubType
	FROM #ProductSettingProfile_All
	WHERE ISNULL(GroupID,0) NOT IN (3,2) 

	/********************************************* Product Status: SettingType = 4 ************************************/
	IF EXISTS (SELECT 1 FROM #ProductSettingDetail_tbl WHERE SettingType = 4)
	BEGIN
		DECLARE @ProductID4 INT
		CREATE TABLE #TempStatus (ProductID INT)
		DECLARE @NewDisableStatTbl TABLE(
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			--, IsDisabledDownline	BIT
			)
	
		INSERT INTO @NewDisableStatTbl (SportType,BetType,IsDisabled)--,IsDisabledDownline)
		SELECT psp.SportType
			, psp.BetType		
			, dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
			--, 0 AS IsDisabledDownline
		FROM dbo.CustProductStatus stt WITH (NOLOCK) 
			CROSS JOIN ProductStatusProfile PSP WITH (NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,4,@SettingStatus) fil ON fil.SportType = PSP.SportType AND fil.BetType = PSP.BetType 
		WHERE stt.CustID = @ExistingCustID

		INSERT INTO #TempStatus(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
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
									--, nslt.IsDisabledDownline AS '@IsDisabledDownline'
								FROM @NewDisableStatTbl nslt								
									INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
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
			EXEC Acc_CustSetting_DisableProductStatusUpd
				  @CustID = @CustID
				, @IsDisabled = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @SystemID = @SystemID
				, @UserID = @UserID
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT	
				, @SettingStatus = @SettingStatus
		END
		DELETE FROM	#TempStatus WHERE ProductID=@ProductID4
		END
	END

	/********************************************* New Product Status: SettingType = 13 ************************************/
	IF EXISTS (SELECT 1 FROM #ProductSettingDetail_tbl WHERE SettingType = 13)
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
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,13,@SettingStatus) fil ON fil.SportType = PSP.SportType AND fil.BetType = PSP.BetType 
		WHERE stt.CustID = @ExistingCustID

		INSERT INTO #TempProductStatus(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
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
										INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
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
					, @SettingStatus = @SettingStatus
			END
			DELETE FROM	#TempProductStatus WHERE ProductID = @ProductID13

		END
	END

	-----------------------------------BY GROUPID, GROUPTYPE--------------------------------------------------------------------
	/********************************************* New Product Status: GroupType = 160  ************************************/
	SELECT @GroupType = 160, @GroupID = NULL, @xmlStatus = NULL
	IF EXISTS (SELECT 1 FROM #ProductSettingProfile WHERE GroupType = @GroupType)
	BEGIN
		CREATE TABLE #TempProductStatus_GT160 (GroupID TINYINT)
		DECLARE @NewDisableProductStatTbl_GT160 TABLE(
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, IsDisabledDownline	BIT
			)
	
		INSERT INTO @NewDisableProductStatTbl_GT160 (SportType,BetType,IsDisabled,IsDisabledDownline)
		SELECT psp.SportType
			, psp.BetType		
			, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled
			, 0 AS IsDisabledDownline
		FROM dbo.CustProductStatus stt WITH (NOLOCK) 
			CROSS JOIN ProductStatusProfile PSP WITH (NOLOCK)
			INNER JOIN #ProductSettingProfile fil 
				ON fil.SportType = PSP.SportType AND fil.BetType = PSP.BetType AND fil.GroupType = @GroupType 
		WHERE stt.CustID = @ExistingCustID

		INSERT INTO #TempProductStatus_GT160(GroupID)	
		SELECT 
				DISTINCT
				psd.GroupID				
		FROM	#ProductSettingProfile AS psd WITH(NOLOCK)
		INNER JOIN	@NewDisableProductStatTbl_GT160 AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.GroupType = @GroupType
			AND psd.GroupID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempProductStatus_GT160)
		BEGIN
			SELECT TOP 1 @GroupID = GroupID FROM #TempProductStatus_GT160		
			SET @xmlStr = (
								SELECT nslt.SportType	AS 'SportType'
									, nslt.BetType		AS 'BetType'
									, nslt.IsDisabled	AS 'IsDisabled'
									, nslt.IsDisabledDownline AS 'IsDisabledDownline'
								FROM @NewDisableProductStatTbl_GT160 nslt								
									INNER JOIN #ProductSettingProfile AS psd WITH(NOLOCK) 
										ON nslt.BetType=psd.BetType 
										AND nslt.SportType=psd.SportType 
										AND psd.GroupType = @GroupType
								WHERE psd.GroupID=@GroupID
								FOR JSON PATH
							)

			IF EXISTS(SELECT TOP 1 1 FROM @NewDisableProductStatTbl_GT160)
			BEGIN
				EXEC Acc_CustSetting_DisableProductStatus_160_Upd
					  @CustID = @CustID
					, @IsDisabled = @xmlStr
					, @SubAccID = @SubAccID
					, @IP = @IP
					, @SystemID = 1
					, @UserID = @UserID
					, @ErrCode = @ErrCode OUTPUT
					, @ErrMsg = @ErrMsg OUTPUT
					, @SettingStatus = @SettingStatus
					, @GroupType = @GroupType
					, @GroupID = @GroupID
			END
			DELETE FROM	#TempProductStatus_GT160 WHERE GroupID=@GroupID
		END
		DROP TABLE #TempProductStatus_GT160
	END

	/********************************************* Position Taking: GroupType = 153 ***********************************/
	SELECT @GroupType = 153, @GroupID = NULL, @xmlPT = NULL
	IF EXISTS (SELECT 1 FROM #ProductSettingProfile WHERE GroupType = @GroupType)
	BEGIN
		CREATE TABLE #TempPT_GT153 (GroupID TINYINT)
		DECLARE @NewPTTble_GT153 TABLE (
				  SportType			SMALLINT
				, BetType			SMALLINT
				, IsLive			BIT
				, AgentPT			SMALLMONEY
				UNIQUE CLUSTERED (SportType, BetType, IsLive)
			)
	
		--Get setting mode
		SELECT @SettingMode = IsGrouped
		FROM dbo.CustSettingMode3rd
		WHERE CustID= @ExistingCustID

		SELECT @AgentID = recommend FROM CustInfo WITH (NOLOCK) WHERE custid = @CustID

		IF @SettingMode = 0
		BEGIN
			INSERT INTO @NewPTTble_GT153 (
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
						INNER JOIN #ProductSettingProfile fil ON fil.SportType = mcs.SportType AND fil.BetType = mcs.BetType AND fil.IsLive = mcs.IsLive AND fil.GroupType = @GroupType
					WHERE mcs.custid = @ExistingCustID AND acs.custid = @AgentID
		END
		ELSE
		BEGIN
			INSERT INTO @NewPTTble_GT153 (
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
						INNER JOIN #ProductSettingProfile fil ON fil.SportType = mcs.SportType AND fil.BetType = mcs.BetType AND fil.IsLive = mcs.IsLive AND fil.GroupType = @GroupType
					WHERE mcs.AgentID = @AgentID AND acs.custid = @AgentID		
		END
		
		INSERT INTO #TempPT_GT153(GroupID)	
		SELECT 
				DISTINCT
				psd.GroupID				
		FROM	#ProductSettingProfile AS psd WITH(NOLOCK)
		INNER JOIN	@NewPTTble_GT153 AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
				AND ts.IsLive = psd.IsLive
		WHERE	psd.GroupType = @GroupType
			AND psd.GroupID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempPT_GT153)
		BEGIN
			SELECT TOP 1 @GroupID = GroupID FROM #TempPT_GT153
		
			SET @xmlStr = ( 
								SELECT nslt.SportType	AS 'SportType'
									, nslt.BetType		AS 'BetType'
									, nslt.IsLive		AS 'IsLive'
									, AgentPT			AS 'AgentPT'
								FROM @NewPTTble_GT153 nslt
									INNER JOIN #ProductSettingProfile AS psd WITH(NOLOCK) 
										ON nslt.BetType=psd.BetType 
										AND nslt.SportType=psd.SportType 
										AND nslt.IsLive=psd.IsLive
										AND psd.GroupType = @GroupType
								WHERE  psd.GroupID=@GroupID
								FOR JSON PATH
							)
		
			IF EXISTS (SELECT TOP 1 1 FROM @NewPTTble_GT153)
			BEGIN
				EXEC Acc_CustSetting_AgentPTOnMember_153_Upd
					  @CustID = @CustID
					, @PT = @xmlStr
					, @SubAccID = @SubAccID
					, @IP = @IP
					, @UserID = @UserID
					, @IsCountPT = 0
					, @isSearchAndCopy=@isSearchAndCopy
					, @ErrCode = @ErrCode OUTPUT
					, @ErrMsg = @ErrMsg OUTPUT
					, @SettingStatus = @SettingStatus
					, @GroupType = @GroupType
					, @GroupID = @GroupID 
			END
			DELETE FROM	#TempPT_GT153 WHERE GroupID=@GroupID
		END
		DROP TABLE #TempPT_GT153
	END

	/********************************************* SMA Win Loss Limit : GroupType = 155 ****************************************/
	SELECT @GroupType = 155, @GroupID = NULL, @xmlWinLossLimit = NULL
	IF EXISTS (SELECT 1 FROM #ProductSettingProfile WHERE GroupType = @GroupType)
	BEGIN
		CREATE TABLE #TempWLLimit_GT155 (GroupID TINYINT)
		DECLARE @NewWinLossLimitTbl_GT155 TABLE (
			SportType			SMALLINT
			, BetType			INT
			, MaxWinLimit		SMALLMONEY
			, MaxLossLimit		MONEY
			, IsAutoReset		BIT
			)

		INSERT INTO @NewWinLossLimitTbl_GT155(SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset)
		SELECT wl.SportType
			, wl.BetType
			, wl.MaxWinLimit
			, wl.MaxLossLimit
			, wl.IsAutoReset
		FROM dbo.CustWinLossLimit_Member wl WITH (NOLOCK)	
			INNER JOIN #ProductSettingProfile fil 
				ON fil.SportType = wl.SportType AND fil.BetType = wl.BetType AND fil.GroupType = @GroupType
		WHERE wl.custid = @ExistingCustID
		
		INSERT INTO #TempWLLimit_GT155(GroupID)	
		SELECT 
				DISTINCT
				psd.GroupID				
		FROM	#ProductSettingProfile AS psd WITH(NOLOCK)
		INNER JOIN	@NewWinLossLimitTbl_GT155 AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.GroupType = @GroupType
			AND psd.GroupID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempWLLimit_GT155)
		BEGIN
			SELECT TOP 1 @GroupID = GroupID FROM #TempWLLimit_GT155

			SET @xmlStr = (
										SELECT nslt.SportType	AS 'SportType'
											, nslt.BetType		AS 'BetType'
											, nslt.MaxWinLimit	AS 'MaxWinLimit'
											, nslt.MaxLossLimit	AS 'MaxLossLimit'
											, nslt.IsAutoReset	AS 'IsAutoReset'
										FROM @NewWinLossLimitTbl_GT155 nslt
											INNER JOIN #ProductSettingProfile AS psd WITH(NOLOCK) 
												ON nslt.BetType=psd.BetType 
												AND nslt.SportType=psd.SportType 
												AND psd.GroupType = @GroupType
										WHERE psd.GroupID=@GroupID
										FOR JSON PATH
									)

			EXEC dbo.Acc_CustSetting_WinLossLimit_155_Upd 
				  @CustID = @CustID
				, @Limit = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @isSearchAndCopy=@isSearchAndCopy
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
				, @SettingStatus = @SettingStatus
				, @GroupType = @GroupType
				, @GroupID = @GroupID 

			DELETE FROM	#TempWLLimit_GT155 WHERE GroupID=@GroupID
		END
		DROP TABLE #TempWLLimit_GT155
	END

	/****************************** Stake Level : GroupType = 158 ******************************/
	SELECT @GroupType = 158, @GroupID = NULL, @xmlStakeLevel = NULL
	IF EXISTS (SELECT 1 FROM #ProductSettingProfile WHERE GroupType = @GroupType)
	BEGIN
		CREATE TABLE #TempStakeLevel_GT158 (GroupID TINYINT)
		DECLARE	@NewStakeLevelTbl_GT158 TABLE (
					SportType		SMALLINT
				,	BetType			SMALLINT
				,	StakeLevelList	VARCHAR(200)
				)
		INSERT INTO @NewStakeLevelTbl_GT158(SportType, BetType, StakeLevelList)
		SELECT	cslm.SportType, cslm.BetType, cslm.StakeLevelList
		FROM	dbo.CustStakeLevel_Member AS cslm WITH(NOLOCK)	
			INNER JOIN #ProductSettingProfile fil 
				ON fil.SportType = cslm.SportType AND fil.BetType = cslm.BetType AND fil.GroupType = @GroupType 
		WHERE	cslm.CustID = @ExistingCustID
		
		INSERT INTO #TempStakeLevel_GT158(GroupID)	
		SELECT 
				DISTINCT
				psd.GroupID				
		FROM	#ProductSettingProfile AS psd WITH(NOLOCK)
		INNER JOIN	@NewStakeLevelTbl_GT158 AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.GroupType = @GroupType
			AND psd.GroupID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempStakeLevel_GT158)
		BEGIN
			SELECT TOP 1 @GroupID = GroupID FROM #TempStakeLevel_GT158	
			SELECT	@xmlStr =	(
											SELECT	nslt.SportType			AS 'SportType'
												,	nslt.BetType			AS 'BetType'
												,	nslt.StakeLevelList		AS 'StakeLevelList'
											FROM	@NewStakeLevelTbl_GT158 AS nslt
												INNER JOIN #ProductSettingProfile AS psd WITH(NOLOCK) 
													ON nslt.BetType=psd.BetType 
													AND nslt.SportType=psd.SportType 
													AND psd.GroupType = @GroupType
											WHERE psd.GroupID=@GroupID
											FOR JSON PATH
										)

			EXEC dbo.Acc_CustSetting_StakeLevel_158_Upd
					 @CustID		= @CustID
					,@StakeLevel	= @xmlStr
					,@SubAccID		= @SubAccID
					,@UserID		= @UserID
					,@IP			= @IP
					,@SystemID		= @SystemID
					,@isSearchAndCopy=@isSearchAndCopy
					,@ErrCode		= @ErrCode		OUTPUT
					,@ErrMsg		= @ErrMsg		OUTPUT	
					,@SettingStatus = @SettingStatus
					,@GroupType		= @GroupType
					,@GroupID		= @GroupID

			DELETE FROM	#TempStakeLevel_GT158 WHERE GroupID=@GroupID			
		END
		DROP TABLE #TempStakeLevel_GT158
	END

	/********************************************* Commision : GroupType = 156 ****************************************/
	SELECT @GroupType = 156, @GroupID = NULL, @xmlDiscount = NULL
	IF EXISTS (SELECT 1 FROM #ProductSettingProfile WHERE GroupType = @GroupType)
	BEGIN
		CREATE TABLE #TempComm_GT156 (GroupID TINYINT)
		DECLARE @NewDiscountTbl_GT156 TABLE (
					SportType	SMALLINT
				,	BetType		SMALLINT
				,	Discount	DECIMAL(9, 8)
			)
	
		INSERT INTO @NewDiscountTbl_GT156(SportType,BetType,Discount)
		SELECT dc.SportType
			, dc.BetType
			, dc.PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dc WITH(NOLOCK)
			INNER JOIN #ProductSettingProfile fil 
				ON fil.SportType = dc.SportType AND fil.BetType = dc.BetType AND fil.GroupType = @GroupType 
		WHERE dc.CustID	= @ExistingCustID

		INSERT INTO #TempComm_GT156(GroupID)	
		SELECT 
				DISTINCT
				psd.GroupID				
		FROM	#ProductSettingProfile AS psd WITH(NOLOCK)
		INNER JOIN	@NewDiscountTbl_GT156 AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.GroupType = @GroupType
			AND psd.GroupID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempComm_GT156)
		BEGIN
			SELECT TOP 1 @GroupID = GroupID FROM #TempComm_GT156	
			SET @xmlStr = ( 
									SELECT nslt.SportType	AS 'SportType'
										, nslt.BetType		AS 'BetType'
										, Discount			AS 'Discount'
									FROM @NewDiscountTbl_GT156 nslt
										INNER JOIN #ProductSettingProfile AS psd WITH(NOLOCK) 
											ON nslt.BetType=psd.BetType
											AND nslt.SportType=psd.SportType 
											AND psd.GroupType = @GroupType
									WHERE psd.GroupID=@GroupID
									FOR JSON PATH
								)

			EXEC Acc_CustSetting_Discount_156_Upd 		
				  @CustID = @CustID
				, @Discount = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @isSearchAndCopy = @isSearchAndCopy
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
				, @SettingStatus = @SettingStatus
				, @GroupType = @GroupType
				, @GroupID = @GroupID

			DELETE FROM	#TempComm_GT156 WHERE GroupID=@GroupID	
		END
		DROP TABLE #TempComm_GT156
	END

	/********************************************* Bet Setting : GroupType = 154 ****************************************/
	SELECT @GroupType = 154, @GroupID = NULL, @xmlDiscount = NULL
	IF EXISTS (SELECT 1 FROM #ProductSettingProfile WHERE GroupType = @GroupType)
	BEGIN
		CREATE TABLE #TempBetSetting_GT154 (GroupID TINYINT)
		DECLARE @NewBetLimitTbl_GT154 TABLE (
			  SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			, MaxPerNumber		MONEY
			)
	
		INSERT INTO @NewBetLimitTbl_GT154(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT bl.SportType
			, bl.BetType
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
			, bl.MaxPerNumber
		FROM dbo.BetSetting3rd_Member bl WITH (NOLOCK)
			INNER JOIN #ProductSettingProfile fil 
				ON fil.SportType = bl.SportType AND fil.BetType = bl.BetType AND fil.GroupType = @GroupType 
		WHERE bl.CustID	= @ExistingCustID

		INSERT INTO #TempBetSetting_GT154(GroupID)	
		SELECT 
				DISTINCT
				psd.GroupID				
		FROM	#ProductSettingProfile AS psd WITH(NOLOCK)
		INNER JOIN	@NewBetLimitTbl_GT154 AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.GroupType = @GroupType
			AND psd.GroupID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempBetSetting_GT154)
		BEGIN
			SELECT TOP 1 @GroupID = GroupID FROM #TempBetSetting_GT154	
			SET @xmlStr = ( 
									SELECT nslt.SportType	AS 'SportType'
										, nslt.BetType		AS 'BetType'
										, MinBet			AS 'MinBet'
										, MaxBet			AS 'MaxBet'
										, MaxPerMatch		AS 'MPM'
										, MaxPerNumber		AS 'MaxPerNumber'
									FROM @NewBetLimitTbl_GT154 nslt
										INNER JOIN #ProductSettingProfile AS psd WITH(NOLOCK) 
											ON nslt.BetType=psd.BetType
											AND nslt.SportType=psd.SportType 
											AND psd.GroupType = @GroupType
									WHERE psd.GroupID=@GroupID
									FOR JSON PATH
								)

			EXEC Acc_CustSetting_BetSetting_154_Upd 		
				  @CustID = @CustID
				, @BetLimit = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @SystemID = @SystemID
				, @isSearchAndCopy=@isSearchAndCopy
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
				, @SettingStatus = @SettingStatus
				, @GroupType = @GroupType
				, @GroupID = @GroupID

			DELETE FROM	#TempBetSetting_GT154 WHERE GroupID=@GroupID	
		END
		DROP TABLE #TempBetSetting_GT154
	END

	DROP TABLE #ProductSettingDetail_tbl
	DROP TABLE #ProductSettingProfile
	DROP TABLE #ProductSettingProfile_All
END


GO