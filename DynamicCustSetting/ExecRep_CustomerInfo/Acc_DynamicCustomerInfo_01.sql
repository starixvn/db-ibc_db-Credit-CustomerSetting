/*<info serverAlias="DBCUST-CustDB" executers="bodbadminNet" viewers="" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[Acc_DynamicCustomerInfo_01]
		@CustID			INT,
		@SettingList	VARCHAR(MAX) = NULL,
		@SettingType	SMALLINT = NULL,
		@Mode			VARCHAR(50) = '',
		@UserID			INT	= 0
AS
/*
	Created: 20220808@Tacy
	Task : Update Member's DCS setting when using Search&Copy New member function
	DB: DBCust/CustDB
	Original:

	Revisions:
		- 20220808@Tacy: Initial SP [RedmineID: #176225]

	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @AgentID INT, @iDoc INT

	IF @SettingList IS NULL OR @SettingList='' RETURN

	SELECT @AgentID = recommend
	FROM dbo.custInfo WITH (NOLOCK)
	WHERE custid = @CustID

	IF @Mode='PT'
	BEGIN
		DECLARE @SettingMode	BIT = 0, 
				@MemGroup		INT

		DECLARE @NewPTTble TABLE (
			  SportType			SMALLINT
			, BetType			SMALLINT
			, IsLive			BIT
			, SuperPT			SMALLMONEY
			, MasterPT			SMALLMONEY
			, AgentPT			SMALLMONEY
			, IsAutoMasterPT	BIT
			, AutoMasterPT		SMALLMONEY
			, IsAutoSuperPT		BIT
			, AutoSuperPT		SMALLMONEY
			UNIQUE CLUSTERED (SportType, BetType, IsLive)
		)

		INSERT @NewPTTble 
				(SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT)
		SELECT	 SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT		
		FROM dbo.f_DCS_PT_XMLParse(@SettingList)

		--Get setting mode
		SELECT @SettingMode = IsGrouped
		FROM dbo.CustSettingMode3rd
		WHERE CustID= @CustID
		
		IF ISNULL(@SettingMode,0)=0
			BEGIN
				--Update Adjusted PT for indiviual setting
				UPDATE main
				SET main.SuperPT=npt.SuperPT,
					main.MasterPT=npt.MasterPT,
					main.AgentPT=npt.AgentPT
				FROM dbo.CustPTSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @NewPTTble npt ON  npt.SportType=main.SportType
						AND npt.BetType=main.BetType
						AND npt.IsLive=main.IsLive
				WHERE main.CustID = @CustID AND
					(npt.SuperPT <> main.SuperPT
						OR npt.MasterPT <> main.MasterPT
						OR npt.AgentPT <> main.AgentPT)
		END
		ELSE
		BEGIN			
			SELECT @MemGroup = count(1) 
			FROM CustSettingMode3rd sm WITH (NOLOCK) 
				INNER JOIN CustInfo ci WITH (NOLOCK) ON ci.custid = sm.CustID 
			WHERE ci.recommend = @AgentID AND sm.IsGrouped = 1
		
			IF @MemGroup = 1
			BEGIN
				UPDATE main
				SET main.SuperPT=npt.SuperPT,
					main.MasterPT=npt.MasterPT,
					main.AgentPT=npt.AgentPT
				FROM dbo.CustPTGroupSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @NewPTTble npt ON  npt.SportType=main.SportType
						AND npt.BetType=main.BetType
						AND npt.IsLive=main.IsLive
				WHERE main.AgentID = @AgentID AND
					(npt.SuperPT <> main.SuperPT
					OR npt.MasterPT <> main.MasterPT
					OR npt.AgentPT <> main.AgentPT)
			END
			ELSE
			BEGIN
				--Move to Individual Setting
				INSERT INTO dbo.CustPTSetting3rd_Member(					
							[CustID]
							,[SportType]
							,[BetType]
							,[IsLive]
							,[IsAutoMasterPT]
							,[IsAutoSuperPT]
							,[SuperPT]
							,[MasterPT]
							,[AgentPT]
							,[AutoSuperPT]
							,[AutoMasterPT]
						)
				SELECT
					@CustID,
					grpt.SportType,
					grpt.BetType,
					grpt.IsLive,						
					grpt.IsAutoMasterPT,
					grpt.IsAutoSuperPT,
					grpt.SuperPT,
					grpt.MasterPT,
					grpt.AgentPT,
					grpt.AutoSuperPT,
					grpt.AutoMasterPT
				FROM dbo.CustPTGroupSetting3rd_Member grpt WITH(NOLOCK)
					LEFT JOIN dbo.CustPTSetting3rd_Member mempt
						ON mempt.CustID = @CustID
						AND grpt.SportType=mempt.SportType
						AND grpt.BetType=mempt.BetType
						AND grpt.IsLive=mempt.IsLive
				WHERE grpt.AgentID=@AgentID AND mempt.CustID IS NULL
		
				--Update Adjusted PT for indiviual setting
				UPDATE main
				SET main.SuperPT=npt.SuperPT,
					main.MasterPT=npt.MasterPT,
					main.AgentPT=npt.AgentPT
				FROM dbo.CustPTSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @NewPTTble npt ON  npt.SportType=main.SportType
						AND npt.BetType=main.BetType
						AND npt.IsLive=main.IsLive
				WHERE main.CustID = @CustID AND
					(npt.SuperPT <> main.SuperPT
					OR npt.MasterPT <> main.MasterPT
					OR npt.AgentPT <> main.AgentPT)
		
				---Update setting mode
				UPDATE dbo.CustSettingMode3rd WITH(ROWLOCK,UPDLOCK)
				SET IsGrouped = 0
				WHERE CustID = @CustID
			END
		END
	END
	ELSE IF @Mode='Commission'
	BEGIN
		DECLARE @NewDiscountTbl TABLE (
				SportType	SMALLINT
			,	BetType		SMALLINT
			,	Discount	DECIMAL(9,8)
		)

		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @SettingList
	
		INSERT @NewDiscountTbl (SportType, BetType, Discount)
		SELECT SportType, BetType, Discount
		FROM OPENXML (@iDoc, '/root/r',1) 
		WITH(SportType	SMALLINT, 
				BetType	SMALLINT, 
				Discount	DECIMAL(9, 8))	
	
		EXEC sp_xml_removedocument @iDoc

		--Update NEW_DISCOUNT = MIN( @NEW_DISCOUNT, agent_discount)
		UPDATE tmp
		SET tmp.Discount = CASE 
				WHEN tmp.Discount < dca.Discount
					THEN tmp.Discount
				ELSE dca.Discount
				END
		FROM @NewDiscountTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dca WITH (NOLOCK)
			ON dca.SportType	= tmp.SportType
				AND dca.BetType = tmp.BetType
				AND dca.custid	= @AgentID
	END
	ELSE IF @Mode='BetSetting'
	BEGIN
		DECLARE @NewBetLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
		)

		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @SettingList
	
		INSERT @NewBetLimitTbl (SportType, BetType, MinBet, MaxBet, MaxPerMatch)
		SELECT SportType,BetType,
			CAST(MinBet AS MONEY) AS MinBet,
			CAST(MaxBet AS MONEY) AS MaxBet,
			CASE WHEN ISNUMERIC(MaxPerMatch)=0 THEN NULL ELSE CAST(MaxPerMatch AS MONEY) END AS MaxPerMatch
		FROM OPENXML (@iDoc, '/root/r',1) 
		WITH(SportType	SMALLINT, 
			 BetType	SMALLINT, 
			 MinBet		VARCHAR(15), 
			 MaxBet		VARCHAR(15), 
			 MaxPerMatch VARCHAR(15))	
	
		EXEC sp_xml_removedocument @iDoc

		--update new settings
		UPDATE main
		SET main.minbet			= tmp.MinBet
			, main.maxbet		= tmp.MaxBet
			, main.maxpermatch	= CASE WHEN tmp.MaxperMatch IS NULL THEN main.MaxPerMatch ELSE tmp.MaxPerMatch END
		FROM dbo.CustBetSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (
					main.minbet		<> tmp.MinBet
				OR main.maxbet		<> tmp.MaxBet
				OR (main.maxpermatch <> tmp.MaxperMatch AND tmp.MaxPerMatch IS NOT NULL)
				)
	END
	ELSE IF @Mode='WinLossLimit'
	BEGIN
		DECLARE @NewLimitTbl TABLE (
			  SportType		SMALLINT
			, BetType		SMALLINT
			, MaxWinLimit	SMALLMONEY 
			, MaxLossLimit	MONEY 
			, IsAutoReset	BIT
		)

		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @SettingList
	
		INSERT @NewLimitTbl (SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
		SELECT SportType, BetType
			, CASE WHEN ISNUMERIC(MaxWinLimit)=0 THEN NULL ELSE CAST(MaxWinLimit AS SMALLMONEY) END MaxWinLimit
			, CASE WHEN ISNUMERIC(MaxLossLimit)=0 THEN NULL ELSE CAST(MaxLossLimit AS MONEY) END MaxLossLimit
			, IsAutoReset
		FROM OPENXML (@iDoc, '/root/r',1) 
		WITH(SportType		SMALLINT
			, BetType		SMALLINT
			, MaxWinLimit	VARCHAR(50)
			, MaxLossLimit	VARCHAR(50)
			, IsAutoReset	BIT
		)	
	
		EXEC sp_xml_removedocument @iDoc

		--update new settings
		UPDATE main
		SET main.MaxWinLimit = CASE WHEN tmp.MaxWinLimit IS NOT NULL THEN tmp.MaxWinLimit ELSE main.MaxWinLimit END
			, main.IsAutoReset = tmp.IsAutoReset
			, main.MaxLossLimit = CASE WHEN tmp.MaxLossLimit IS NOT NULL THEN tmp.MaxLossLimit ELSE main.MaxLossLimit END
		FROM dbo.CustWinLossLimit_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (
					(main.MaxWinLimit <> tmp.MaxWinLimit AND tmp.MaxLossLimit IS NULL) 
				 OR (main.MaxLossLimit <> tmp.MaxLossLimit AND tmp.MaxLossLimit IS NULL)
				 OR  main.IsAutoReset <> tmp.IsAutoReset 
				)
	END
	ELSE IF @Mode='StakeLevel'
	BEGIN
		CREATE TABLE #tmpStake (
				ID				INT IDENTITY (1,1)
			,	SportType		SMALLINT
			,	BetType			INT
			,	StakeLevelList	VARCHAR(200)
			,	PRIMARY KEY CLUSTERED (SportType, BetType)
		)

		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @SettingList
	
		INSERT #tmpStake (SportType, BetType, StakeLevelList)
		SELECT SportType, BetType, StakeLevelList
		FROM OPENXML (@iDoc, '/root/r',1) 
		WITH(SportType		SMALLINT
			, BetType		SMALLINT
			, StakeLevelList VARCHAR(200)
		)	
	
		EXEC sp_xml_removedocument @iDoc

		-- Update current customer's stake level
		UPDATE	cslm	WITH(ROWLOCK,UPDLOCK)
		SET		cslm.StakeLevelList = ts.StakeLevelList
				, cslm.LastUpdated = GETDATE()
		FROM		dbo.CustStakeLevel_Member AS cslm
		INNER JOIN	#tmpStake ts
				ON	ts.BetType = cslm.BetType
		WHERE	cslm.CustID = @CustID;

		DROP TABLE #tmpStake
	END
END
GO