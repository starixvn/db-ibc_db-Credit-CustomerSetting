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

	Param's Explanation: 
		- @SettingStatus: 0: Pro, 1: UAT 	
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @xmlPT XML, @xmlBetLimit XML, @xmlDiscount XML, @xmlStatus XML, @xmlWinLossLimit XML, @xmlStakeLevel XML,@xmlStakeLevel17 XML,@xmlStakeLevel8 XML, @xmlLossLimit XML
	DECLARE @xmlStr VARCHAR(MAX)
	DECLARE @SettingMode BIT, @AgentID INT, @GroupType TINYINT, @GroupID TINYINT
	SELECT @ErrCode = 0		

	DECLARE @_Site VARCHAR(10), @_SiteID INT, @_Currency TINYINT

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
	
	/********************************************* Position Taking: SettingType = 1 ***********************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,1,@SettingStatus))
	BEGIN
		DECLARE @ProductID1 INT
		CREATE TABLE #TempPT (ProductID INT)
		DECLARE @NewPTTble TABLE (
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
						INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,1,@SettingStatus) fil ON fil.SportType = mcs.SportType AND fil.BetType = mcs.BetType AND fil.IsLive = mcs.IsLive
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
						INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,1,@SettingStatus) fil ON fil.SportType = mcs.SportType AND fil.BetType = mcs.BetType AND fil.IsLive = mcs.IsLive
					WHERE mcs.AgentID = @AgentID AND acs.custid = @AgentID		
		END
		
		INSERT INTO #TempPT(ProductID)	
		SELECT 
				DISTINCT
				psd.ProductID				
		FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
		INNER JOIN	@NewPTTble AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.SettingType = 1
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
							INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType AND nslt.IsLive=psd.IsLive
										WHERE psd.SettingType = 1 AND psd.ProductID=@ProductID1
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
				, @IsCountPT = 0
				, @isSearchAndCopy=@isSearchAndCopy
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
				, @SettingStatus = @SettingStatus
		END
		
		DELETE FROM	#TempPT WHERE ProductID=@ProductID1
		END
	END

	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,18,@SettingStatus))
	BEGIN
		DECLARE @ProductID18 INT
		CREATE TABLE #TempPT18 (ProductID INT)
		DECLARE @NewPTTble18 TABLE (
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
			INSERT INTO @NewPTTble18 (
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
						INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,18,@SettingStatus) fil ON fil.SportType = mcs.SportType AND fil.BetType = mcs.BetType AND fil.IsLive = mcs.IsLive
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

			INSERT INTO @NewPTTble18 (
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
						INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,18,@SettingStatus) fil ON fil.SportType = mcs.SportType AND fil.BetType = mcs.BetType AND fil.IsLive = mcs.IsLive
					WHERE mcs.AgentID = @AgentID AND acs.custid = @AgentID		
		END
		
		INSERT INTO #TempPT18(ProductID)	
		SELECT 
				DISTINCT
				psd.ProductID				
		FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
		INNER JOIN	@NewPTTble18 AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.SettingType = 18
			AND psd.ProductID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempPT18)
		BEGIN
		SELECT TOP 1 @ProductID18=ProductID FROM #TempPT18
		
		SET @xmlPT = ( SELECT
							(
							SELECT nslt.SportType	AS '@SportType'
								, nslt.BetType		AS '@BetType'
								, nslt.IsLive		AS '@IsLive'
								, AgentPT		AS '@AgentPT'
							FROM @NewPTTble18 nslt
							INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType AND nslt.IsLive=psd.IsLive
										WHERE psd.SettingType = 18 AND psd.ProductID=@ProductID18
							FOR XML PATH('PT')
								, TYPE
							)
						FOR XML PATH('ROOT')
							, TYPE
						)
	
		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlPT)	
		
		IF EXISTS (SELECT TOP 1 1 FROM @NewPTTble18)
		BEGIN
			EXEC Acc_CustSetting_AgentPTOnMemberUpd
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
		END
		
		DELETE FROM	#TempPT18 WHERE ProductID=@ProductID18
		END
	END
	/********************************************* Bet Limit : SettingType = 2 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,2,@SettingStatus))
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
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,2,@SettingStatus) fil ON fil.SportType = bl.SportType AND fil.BetType = bl.BetType		
		WHERE bl.custid = @ExistingCustID
		
		INSERT INTO #TempBetlimit(ProductID)	
		SELECT 
				DISTINCT
				psd.ProductID				
		FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
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
									INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType
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
				, @SystemID = @SystemID --20200305@Tiara
				, @isSearchAndCopy=@isSearchAndCopy
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
				, @SettingStatus = @SettingStatus
		END
		DELETE FROM	#TempBetlimit WHERE ProductID=@ProductID2
		END
	END
	/********************************************* Commision : SettingType = 3 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,3,@SettingStatus))
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
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,3,@SettingStatus) fil ON fil.SportType = dc.SportType AND fil.BetType = dc.BetType
		WHERE dc.CustID	= @ExistingCustID

		INSERT INTO #TempComm(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
			INNER JOIN	@NewDiscountTbl AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.SettingType = 3
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
									INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
										WHERE psd.SettingType = 3 AND psd.ProductID=@ProductID3
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
				, @isSearchAndCopy=@isSearchAndCopy
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
				, @SettingStatus = @SettingStatus
		END
		DELETE FROM	#TempComm WHERE ProductID=@ProductID3
		END
	END

	/********************************************* Commision : SettingType = 19 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,19,@SettingStatus))
	BEGIN
		DECLARE @ProductID19 INT
		CREATE TABLE #TempComm19 (ProductID INT)
		DECLARE @NewDiscountTbl19 TABLE (
					SportType	SMALLINT
				,	BetType		SMALLINT
				,	Discount	DECIMAL(9, 8)
			)
	
		INSERT INTO @NewDiscountTbl19
		SELECT dc.SportType
			, dc.BetType
			, dc.PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dc WITH(NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,19,@SettingStatus) fil ON fil.SportType = dc.SportType AND fil.BetType = dc.BetType
		WHERE dc.CustID	= @ExistingCustID

		INSERT INTO #TempComm19(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
			INNER JOIN	@NewDiscountTbl19 AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.SettingType = 19
				AND psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempComm19)
		BEGIN
		SELECT TOP 1 @ProductID19=ProductID FROM #TempComm19		
		SET @xmlDiscount = ( SELECT (
									SELECT nslt.SportType AS '@SportType'
										, nslt.BetType AS '@BetType'
										, Discount AS '@Discount'
									FROM @NewDiscountTbl19 nslt
									INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
										WHERE psd.SettingType = 19 AND psd.ProductID=@ProductID19
									FOR XML PATH('Discount')
										, TYPE
									)
							FOR XML PATH('ROOT')
								, TYPE
							)

		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlDiscount)

		IF EXISTS(SELECT TOP 1 1 FROM @NewDiscountTbl19)
		BEGIN
			EXEC Acc_CustSetting_DiscountUpd 		
				  @CustID = @CustID
				, @Discount = @xmlStr
				, @SettingType = 19
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @isSearchAndCopy = @isSearchAndCopy
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
				, @SettingStatus = @SettingStatus
		END
		DELETE FROM	#TempComm19 WHERE ProductID=@ProductID19
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
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,5,@SettingStatus))
	BEGIN
	
		INSERT INTO @NewChargeCommTbl
		SELECT dc.SportType
			, dc.BetType
			, dc.PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dc WITH(NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,5,@SettingStatus) fil ON fil.SportType = dc.SportType AND fil.BetType = dc.BetType
		WHERE dc.CustID	= @ExistingCustID
		
		INSERT INTO #TempChargeComm(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
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
									INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
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
				, @isSearchAndCopy=@isSearchAndCopy
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
				, @SettingStatus = @SettingStatus
		END
		DELETE FROM	#TempChargeComm WHERE ProductID=@ProductID5
		END
	END
	/********************************************* Product Status: SettingType = 4 ************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,4,@SettingStatus))
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

	/********************************************* SMA Win Loss Limit : SettingType = 6 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,6,@SettingStatus))
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
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,6,@SettingStatus) fil ON fil.SportType = wl.SportType AND fil.BetType = wl.BetType	
		WHERE wl.custid = @ExistingCustID
		
		INSERT INTO #TempWLLimit(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
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
									INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
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
			, @isSearchAndCopy=@isSearchAndCopy
			, @ErrCode = @ErrCode OUTPUT
			, @ErrMsg = @ErrMsg OUTPUT
			, @SettingStatus = @SettingStatus
		DELETE FROM	#TempWLLimit WHERE ProductID=@ProductID6
		END
			
	END
	
	/****************************** Stake Level Member Single Selection : SettingType = 7 ******************************/
	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL, 7,@SettingStatus))
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
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,7,@SettingStatus) fil ON fil.SportType = cslm.SportType AND fil.BetType = cslm.BetType	
		WHERE	cslm.CustID = @ExistingCustID
		
		INSERT INTO #TempStakeLevel(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
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
										INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
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
				,   @SystemID = @SystemID --20200305@Tiara
				,   @SettingType = 7 
				,	@isSearchAndCopy=@isSearchAndCopy
				,	@ErrCode	= @ErrCode		OUTPUT
				,	@ErrMsg		= @ErrMsg		OUTPUT	
				,   @SettingStatus = @SettingStatus

		DELETE FROM	#TempStakeLevel WHERE ProductID=@ProductID7			
	END
	END

	/****************************** Stake Level Member Multiple Selection : SettingType = 17 ******************************/
	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL, 17,@SettingStatus))
	BEGIN
		DECLARE @ProductID17 INT
		CREATE TABLE #TempStakeLevel17 (ProductID INT)
		DECLARE	@NewStakeLevelTbl17 TABLE (
					SportType		SMALLINT
				,	BetType			SMALLINT
				,	StakeLevelList	VARCHAR(200)
				)
		INSERT INTO @NewStakeLevelTbl17
			(	SportType     , BetType     , StakeLevelList)
		SELECT	cslm.SportType, cslm.BetType, cslm.StakeLevelList
		FROM	dbo.CustStakeLevel_Member AS cslm WITH(NOLOCK)	
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,17,@SettingStatus) fil ON fil.SportType = cslm.SportType AND fil.BetType = cslm.BetType	
		WHERE	cslm.CustID = @ExistingCustID
		
		INSERT INTO #TempStakeLevel17(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
			INNER JOIN	@NewStakeLevelTbl17 AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.SettingType = 17
				AND psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempStakeLevel17)
		BEGIN
		SELECT TOP 1 @ProductID17=ProductID FROM #TempStakeLevel17
		SELECT	@xmlStakeLevel17 =	(
										SELECT	nslt.SportType			AS '@SportType'
											,	nslt.BetType			AS '@BetType'
											,	nslt.StakeLevelList		AS '@StakeLevelList'
										FROM	@NewStakeLevelTbl17 AS nslt
										INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
										WHERE SettingType=17 AND  psd.ProductID=@ProductID17
										FOR XML PATH('StakeLevel')
									,	ROOT('ROOT')
									,	TYPE
									)
	
		SELECT	@xmlStr = CONVERT(VARCHAR(MAX), @xmlStakeLevel17)

		EXEC	dbo.Acc_CustSetting_StakeLevelUpd 
					@CustID		= @CustID
				,	@StakeLevel	= @xmlStr
				,	@SubAccID	= @SubAccID
				,	@UserID		= @UserID
				,	@IP			= @IP
				,   @SystemID = @SystemID --20200305@Tiara
				,   @SettingType = 17 
				,	@isSearchAndCopy=@isSearchAndCopy
				,	@ErrCode	= @ErrCode		OUTPUT
				,	@ErrMsg		= @ErrMsg		OUTPUT	
				,   @SettingStatus = @SettingStatus
		DELETE FROM	#TempStakeLevel17 WHERE ProductID=@ProductID17			
	END
	END
	/****************************** Stake Level Member Single Selection : SettingType = 8 ******************************/
	IF EXISTS (SELECT TOP 1 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL, 8,@SettingStatus))
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
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,8,@SettingStatus) fil ON fil.SportType = cslm.SportType AND fil.BetType = cslm.BetType		
		WHERE	cslm.CustID = @ExistingCustID
		
		INSERT INTO #TempStakeLevel8(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
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
										INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
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
				,   @SystemID   =  @SystemID --20200305@Tiara
				,   @SettingType = 8
				,	@isSearchAndCopy=@isSearchAndCopy
				,	@ErrCode	= @ErrCode		OUTPUT
				,	@ErrMsg		= @ErrMsg		OUTPUT	
				,   @SettingStatus = @SettingStatus
				
		DELETE FROM	#TempStakeLevel8 WHERE ProductID=@ProductID8
	
		END
	END
	/********************************************* Game Bet Limit : SettingType = 9 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,9,@SettingStatus))
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
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,9,@SettingStatus) fil ON fil.SportType = bl.SportType AND fil.BetType = bl.BetType		
		WHERE bl.custid = @ExistingCustID
		
		INSERT INTO #TempGameBetlimit(ProductID)	
		SELECT 
				DISTINCT
				psd.ProductID				
		FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
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
										INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType
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
					, @SystemID = @SystemID --20200305@Tiara
					, @isSearchAndCopy=@isSearchAndCopy
					, @ErrCode = @ErrCode OUTPUT
					, @ErrMsg = @ErrMsg OUTPUT
					, @SettingStatus = @SettingStatus
			END
			DELETE FROM	#TempGameBetlimit WHERE ProductID=@ProductID9
		END
	END
	
	/********************************************* Game Status: SettingType = 11 ************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,11,@SettingStatus))
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
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,11,@SettingStatus) fil ON fil.SportType = PSP.SportType AND fil.BetType = PSP.BetType 
		WHERE stt.CustID = @ExistingCustID

		INSERT INTO #TempGameStatus(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
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
										INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
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
					, @SystemID = 1
					, @SubAccID = @SubAccID
					, @IP = @IP
					, @UserID = @UserID
					, @ErrCode = @ErrCode OUTPUT
					, @ErrMsg = @ErrMsg OUTPUT	
					, @SettingStatus = @SettingStatus
			END
			DELETE FROM	#TempGameStatus WHERE ProductID = @ProductID11
		END
	END
	
	/********************************************* SMA Loss Limit : SettingType = 12 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,12,@SettingStatus))
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
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,12,@SettingStatus) fil ON fil.SportType = wl.SportType AND fil.BetType = wl.BetType		
		WHERE wl.custid = @ExistingCustID
		
		INSERT INTO #TempLLimit(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
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
										INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
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
				, @isSearchAndCopy=@isSearchAndCopy
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
				, @SettingStatus = @SettingStatus
			DELETE FROM	#TempLLimit WHERE ProductID=@ProductID12
		END
			
	END

	/********************************************* New Product Status: SettingType = 13 ************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,13,@SettingStatus))
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

	/********************************************* Ticket Commision : SettingType = 14 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,14,@SettingStatus))
	BEGIN
		DECLARE @ProductID14 INT
		CREATE TABLE #TicketComm (ProductID INT)
		DECLARE @NewCommTbl TABLE (
				SportType	SMALLINT
			,	BetType		SMALLINT
			,	Discount	DECIMAL(9, 8)
		)
	
		INSERT INTO @NewCommTbl
		SELECT dc.SportType
			, dc.BetType
			, dc.PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dc WITH(NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,14,@SettingStatus) fil ON fil.SportType = dc.SportType AND fil.BetType = dc.BetType
		WHERE dc.CustID	= @ExistingCustID
		
		INSERT INTO #TicketComm(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
			INNER JOIN	@NewCommTbl AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.SettingType = 14
				AND psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TicketComm)
		BEGIN
			SELECT TOP 1 @ProductID14=ProductID FROM #TicketComm		
			SET @xmlDiscount = ( SELECT (
										SELECT nslt.SportType AS '@SportType'
											, nslt.BetType AS '@BetType'
											, Discount AS '@Commission'
										FROM @NewCommTbl nslt
										INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
											WHERE psd.SettingType = 14 AND psd.ProductID=@ProductID14
										FOR XML PATH('Commission')
											, TYPE
										)
								FOR XML PATH('ROOT')
									, TYPE
								)

			SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlDiscount)

			IF EXISTS(SELECT TOP 1 1 FROM @NewCommTbl)
			BEGIN
				EXEC Acc_CustSetting_TicketCommissionUpd 		
					  @CustID = @CustID
					, @Commission = @xmlStr
					, @SubAccID = @SubAccID
					, @IP = @IP
					, @UserID = @UserID
					, @ErrCode = @ErrCode OUTPUT
					, @ErrMsg = @ErrMsg OUTPUT
					, @SettingStatus = @SettingStatus
			END
			DELETE FROM	#TicketComm WHERE ProductID=@ProductID14
		END
	END

	/********************************************* Bet Setting : SettingType = 16 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,16,@SettingStatus))
	BEGIN
		DECLARE @ProductID16 INT
		CREATE TABLE #TempBetSetting (ProductID INT)
		DECLARE @NewBetSettingTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			)

		INSERT INTO @NewBetSettingTbl
		SELECT bl.SportType
			, bl.BetType
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
		FROM dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,16,@SettingStatus) fil ON fil.SportType = bl.SportType AND fil.BetType = bl.BetType		
		WHERE bl.custid = @ExistingCustID
		
		INSERT INTO #TempBetSetting(ProductID)	
		SELECT 
				DISTINCT
				psd.ProductID				
		FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
		INNER JOIN	@NewBetSettingTbl AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.SettingType = 16
			AND psd.ProductID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempBetSetting)
		BEGIN
			SELECT TOP 1 @ProductID16=ProductID FROM #TempBetSetting		
			SET @xmlBetLimit = (SELECT (
										SELECT nslt.SportType	AS '@SportType'
											, nslt.BetType		AS '@BetType'
											, MinBet			AS '@MinBet'
											, MaxBet			AS '@MaxBet'
											, MaxPerMatch		AS '@MaxPerMatch'
										FROM @NewBetSettingTbl nslt
										INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType
											WHERE psd.SettingType = 16 AND psd.ProductID = @ProductID16
										FOR XML PATH('BetLimit')
											, TYPE
										)
								FOR XML PATH('ROOT')
									, TYPE
								)
	
			SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlBetLimit)

			IF EXISTS(SELECT TOP 1 1 FROM @NewBetSettingTbl)
			BEGIN
				EXEC Acc_CustSetting_BetSettingUpd
					  @CustID = @CustID
					, @BetLimit = @xmlStr
					, @SubAccID = @SubAccID
					, @IP = @IP
					, @UserID = @UserID
					, @SystemID = @SystemID --20200305@Tiara
					, @isSearchAndCopy=@isSearchAndCopy
					, @ErrCode = @ErrCode OUTPUT
					, @ErrMsg = @ErrMsg OUTPUT
					, @SettingStatus = @SettingStatus
			END
			DELETE FROM	#TempBetSetting WHERE ProductID=@ProductID16
		END
	END
	/********************************************* Bet Setting : SettingType = 20 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,20,@SettingStatus))
	BEGIN
		DECLARE @ProductID20 INT
		CREATE TABLE #TempBetSetting20 (ProductID INT)
		DECLARE @NewBetSettingTbl20 TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			)

		INSERT INTO @NewBetSettingTbl20
		SELECT bl.SportType
			, bl.BetType
			, bl.MinBet
			, bl.MaxBet
		FROM dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,20,@SettingStatus) fil ON fil.SportType = bl.SportType AND fil.BetType = bl.BetType		
		WHERE bl.custid = @ExistingCustID
		
		INSERT INTO #TempBetSetting20(ProductID)	
		SELECT 
				DISTINCT
				psd.ProductID				
		FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
		INNER JOIN	@NewBetSettingTbl20 AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.SettingType = 20
			AND psd.ProductID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempBetSetting20)
		BEGIN
			SELECT TOP 1 @ProductID20=ProductID FROM #TempBetSetting20		
			SET @xmlBetLimit = (SELECT (
										SELECT nslt.SportType	AS '@SportType'
											, nslt.BetType		AS '@BetType'
											, MinBet			AS '@MinBet'
											, MaxBet			AS '@MaxBet'
										FROM @NewBetSettingTbl20 nslt
										INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType
											WHERE psd.SettingType = 20 AND psd.ProductID = @ProductID20
										FOR XML PATH('BetLimit')
											, TYPE
										)
								FOR XML PATH('ROOT')
									, TYPE
								)
	
			SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlBetLimit)

			IF EXISTS(SELECT TOP 1 1 FROM @NewBetSettingTbl20)
			BEGIN
				EXEC Acc_CustSetting_GameBetSettingUpd
					  @CustID = @CustID
					, @BetLimit = @xmlStr
					, @SubAccID = @SubAccID
					, @IP = @IP
					, @UserID = @UserID
					, @SystemID = @SystemID
					, @isSearchAndCopy=@isSearchAndCopy
					, @ErrCode = @ErrCode OUTPUT
					, @ErrMsg = @ErrMsg OUTPUT
			
			END
			DELETE FROM	#TempBetSetting20 WHERE ProductID=@ProductID20
		END
	END

	/********************************************* New Product Status: SettingType = 21 ************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,21,@SettingStatus))
	BEGIN
		DECLARE @ProductID21 INT
		CREATE TABLE #TempProductStatus21 (ProductID INT)
		DECLARE @NewDisableProductStatTbl21 TABLE(
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, IsDisabledDownline	BIT
			)
	
		INSERT INTO @NewDisableProductStatTbl21 (SportType,BetType,IsDisabled,IsDisabledDownline)
		SELECT psp.SportType
			, psp.BetType		
			, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled
			, 0 AS IsDisabledDownline
		FROM dbo.CustProductStatus stt WITH (NOLOCK) 
			CROSS JOIN ProductStatusProfile PSP WITH (NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,21,@SettingStatus) fil ON fil.SportType = PSP.SportType AND fil.BetType = PSP.BetType 
		WHERE stt.CustID = @ExistingCustID

		INSERT INTO #TempProductStatus21(ProductID)	
			SELECT 
					DISTINCT
					psd.ProductID				
			FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
			INNER JOIN	@NewDisableProductStatTbl21 AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE psd.SettingType = 21
				AND	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempProductStatus21)
		BEGIN
			SELECT TOP 1 @ProductID21 = ProductID FROM #TempProductStatus21		
			SET @xmlStatus = (SELECT (
									SELECT nslt.SportType	AS '@SportType'
										, nslt.BetType		AS '@BetType'
										, nslt.IsDisabled	AS '@IsDisabled'
										, nslt.IsDisabledDownline AS '@IsDisabledDownline'
									FROM @NewDisableProductStatTbl21 nslt								
										INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
											WHERE psd.SettingType = 21 AND psd.ProductID = @ProductID21
									FOR XML PATH('ProductStatus')
										, TYPE
									)
							FOR XML PATH('ROOT')
								, TYPE
							)

			SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlStatus)

			IF EXISTS(SELECT TOP 1 1 FROM @NewDisableProductStatTbl21)
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
					, @Settingtype = 21
					, @SettingStatus = @SettingStatus
			END
			DELETE FROM	#TempProductStatus21 WHERE ProductID = @ProductID21
		END
	END

	/********************************************* SMA Win Loss Limit : SettingType = 22 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,22,@SettingStatus))
	BEGIN
		DECLARE @ProductID22 INT
		CREATE TABLE #TempWLLimit22 (ProductID INT)
		DECLARE @NewWinLossLimitTbl22 TABLE (
			SportType			SMALLINT
			, BetType			INT
			, MaxWinLimit		SMALLMONEY
			, MaxLossLimit		MONEY
			, IsAutoReset		BIT
			)

		INSERT INTO @NewWinLossLimitTbl22(SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset)
		SELECT wl.SportType
			, wl.BetType
			, wl.MaxWinLimit
			, wl.MaxLossLimit
			, wl.IsAutoReset
		FROM dbo.CustWinLossLimit_Member wl WITH (NOLOCK)	
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,22,@SettingStatus) fil ON fil.SportType = wl.SportType AND fil.BetType = wl.BetType	
		WHERE wl.custid = @ExistingCustID
		
		INSERT INTO #TempWLLimit22(ProductID)	
		SELECT 
				DISTINCT
				psd.ProductID				
		FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
		INNER JOIN	@NewWinLossLimitTbl22 AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.SettingType = 22
			AND psd.ProductID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
				
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempWLLimit22)
		BEGIN
			SELECT TOP 1 @ProductID22=ProductID FROM #TempWLLimit22

			SET @xmlWinLossLimit = (SELECT (
										SELECT nslt.SportType	AS '@SportType'
											, nslt.BetType		AS '@BetType'
											, nslt.MaxWinLimit	AS '@MaxWinLimit'
											, nslt.MaxLossLimit	AS '@MaxLossLimit'
											, nslt.IsAutoReset	AS '@IsAutoReset'
										FROM @NewWinLossLimitTbl22 nslt
										INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType 
											WHERE psd.SettingType =22 AND psd.ProductID=@ProductID22
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
				, @SettingType = 22
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @isSearchAndCopy=@isSearchAndCopy
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
				, @SettingStatus = @SettingStatus

			DELETE FROM	#TempWLLimit22 WHERE ProductID=@ProductID22
		END
			
	END

	/********************************************* Bet Limit : SettingType = 23 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,23,@SettingStatus))
	BEGIN
		DECLARE @ProductID23 INT
		CREATE TABLE #TempBetlimit23 (ProductID INT)
		DECLARE @NewBetLimitTbl23 TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			, MaxPerNumber		MONEY
			)

		INSERT INTO @NewBetLimitTbl23(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT bl.SportType
			, bl.BetType
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
			, NULL AS MaxPerNumber
		FROM dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,23,@SettingStatus) fil ON fil.SportType = bl.SportType AND fil.BetType = bl.BetType		
		WHERE bl.custid = @ExistingCustID
			AND SubType = 1

		INSERT INTO @NewBetLimitTbl23(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT bl.SportType
			, bl.BetType
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
			, bl.MaxPerNumber
		FROM dbo.CustBetSetting_Member bl WITH (NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,23,@SettingStatus) fil ON fil.SportType = bl.SportType AND fil.BetType = bl.BetType		
		WHERE bl.custid = @ExistingCustID
			AND SubType = 2
		
		INSERT INTO #TempBetlimit23(ProductID)	
		SELECT 
				DISTINCT
				psd.ProductID				
		FROM	#ProductSettingDetail_tbl AS psd WITH(NOLOCK)
		INNER JOIN	@NewBetLimitTbl23 AS ts
				ON	ts.SportType = psd.SportType
				AND	ts.BetType = psd.BetType
		WHERE	psd.SettingType =23
			AND psd.ProductID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
			
		WHILE EXISTS(SELECT TOP 1 1 FROM #TempBetlimit23)
		BEGIN
		SELECT TOP 1 @ProductID23=ProductID FROM #TempBetlimit23		
		SET @xmlBetLimit = (SELECT (
									SELECT nslt.SportType	AS '@SportType'
										, nslt.BetType		AS '@BetType'
										, MinBet		AS '@MinBet'
										, MaxBet		AS '@MaxBet'
										, MaxPerMatch	AS '@MaxPerMatch'
										, MaxPerNumber	AS '@MaxPerNumber'
									FROM @NewBetLimitTbl23 nslt
									INNER JOIN #ProductSettingDetail_tbl AS psd WITH(NOLOCK) ON nslt.BetType=psd.BetType AND nslt.SportType=psd.SportType
										WHERE psd.SettingType=23 AND psd.ProductID=@ProductID23
									FOR XML PATH('BetLimit')
										, TYPE
									)
							FOR XML PATH('ROOT')
								, TYPE
							)
	
		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlBetLimit)

		IF EXISTS(SELECT TOP 1 1 FROM @NewBetLimitTbl23)
		BEGIN
			EXEC Acc_CustSetting_BetSetting23Upd 
				  @CustID = @CustID
				, @BetLimit = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @SystemID = @SystemID --20200305@Tiara
				, @isSearchAndCopy=@isSearchAndCopy
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
				, @SettingStatus = @SettingStatus
		END
		DELETE FROM	#TempBetlimit23 WHERE ProductID=@ProductID23
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