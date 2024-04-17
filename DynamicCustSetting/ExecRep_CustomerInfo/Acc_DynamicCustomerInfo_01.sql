/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap" viewers="" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[Acc_DynamicCustomerInfo_01]
		@CustID			INT,
		@SettingList	VARCHAR(MAX)=NULL,
		@SettingType	SMALLINT = NULL,
		@AgentID		INT=NULL
AS
/*
	Created: 20220808@Tacy
	Task : Update Member's DCS setting when using Search&Copy New member function
	DB: DBCust/CustDB
	Original:

	Revisions:
		- 20220808@Tacy: Initial SP [RedmineID: #176225]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20230307@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20240312@Johnson: HF check to Group PT for SC customer [Redmine: #202119]
	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @iDoc INT

	IF @SettingList IS NULL OR @SettingList='' RETURN

	DECLARE @NewBetLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			, MaxPerNumber		MONEY
			, SubType			TINYINT
	)

	DECLARE @NewLimitTbl TABLE (
			  SportType		SMALLINT
			, BetType		SMALLINT
			, MaxWinLimit	SMALLMONEY 
			, MaxLossLimit	MONEY 
			, IsAutoReset	BIT
	)
		
	DECLARE @SuperID INT, @MasterID INT

	SELECT @SuperID = srecommend, @MasterID = mrecommend FROM Custinfo WITH (NOLOCK) WHERE custid = @CustId
				
	IF @SettingType IN (1,18) -- PT
	BEGIN
		IF dbo.f_CheckRepTable('CustSettingMode3rd') = 0 RETURN
		IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 0 RETURN

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
		FROM dbo.CustSettingMode3rd WITH(NOLOCK)
		WHERE CustID = @CustID
		
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
						
				IF EXISTS (SELECT TOP 1 1
						FROM dbo.CustPTGroupSetting3rd_Member grp WITH(NOLOCK)
						WHERE grp.AgentID = @AgentID
						)
					AND NOT EXISTS(SELECT TOP 1 1
								FROM dbo.CustPTGroupSetting3rd_Member grp WITH(NOLOCK)
								JOIN CustPTSetting3rd_Member cs WITH(NOLOCK) ON cs.SportType = grp.SportType
														AND cs.BetType = grp.BetType
														AND cs.Islive = grp.Islive
								WHERE grp.AgentID = @AgentID
								AND cs.custid = @custid
								AND (
									cs.SuperPT <> grp.SuperPT
									OR
									cs.MasterPT <> grp.MasterPT
									OR
									cs.AgentPT <> grp.AgentPT
									OR
									cs.IsAutoMasterPT <> grp.IsAutoMasterPT
									OR
									cs.AutoMasterPT <> grp.AutoMasterPT
									OR
									cs.IsAutoSuperPT <> grp.IsAutoSuperPT
									OR
									cs.AutoSuperPT <> grp.AutoSuperPT
								))
						AND @SuperID IN (
											13869621,
											5340162,
											12262401,
											12141653,
											4138910,
											6379932,
											16112208,
											12141529,
											1539339,
											720475
											--UUS
											,17287861
											,18879367
											,14373244
											,18362423
											,18479460
											,18289591
										)	
				BEGIN
					UPDATE cs 
					SET IsGrouped = 1					
					FROM dbo.CustSettingMode3rd cs WITH(ROWLOCK)
					WHERE CustID = @CustID
					
					DELETE CustPTSetting3rd_Member WITH(ROWLOCK) WHERE custid = @custid
				END
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
					LEFT JOIN dbo.CustPTSetting3rd_Member mempt WITH(NOLOCK)
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
	ELSE IF @SettingType IN (3,19) --Commission
	BEGIN
		IF dbo.f_CheckRepTable('custinfo') = 0 RETURN
		IF dbo.f_CheckRepTable('CustDiscount3rd_Member') = 0 RETURN
		IF dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 0 RETURN

		DECLARE @SuperDiscount DECIMAL(9,8),
				@MasterDiscount DECIMAL(9,8),
				@AgentDiscount DECIMAL(9,8),
				@PlayerDiscount DECIMAL(9,8)

		DECLARE @NewDiscountTbl TABLE (
				SportType	SMALLINT
			,	BetType		SMALLINT
			,	Discount	DECIMAL(9,8)
		)

		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @SettingList
	
		INSERT @NewDiscountTbl (SportType, BetType, Discount)
		SELECT SportType, BetType, Discount
		FROM OPENXML (@iDoc, '/ROOT/Discount',1) 
		WITH(SportType	SMALLINT, 
				BetType	SMALLINT, 
				Discount	DECIMAL(9, 8))	
	
		EXEC sp_xml_removedocument @iDoc
		
		UPDATE dcmem  
		SET @SuperDiscount = dcs.Discount,
			@MasterDiscount = dcm.Discount,
			@AgentDiscount = dca.Discount,
			@PlayerDiscount = tmp.Discount,	
			@SuperDiscount = CASE WHEN @SuperDiscount < @PlayerDiscount THEN @PlayerDiscount ELSE @SuperDiscount END,
			@MasterDiscount= CASE WHEN @MasterDiscount < @PlayerDiscount THEN @PlayerDiscount ELSE @MasterDiscount END,
			@AgentDiscount= CASE WHEN @AgentDiscount < @PlayerDiscount THEN @PlayerDiscount ELSE @AgentDiscount END,
			dcmem.SuperDiscount = @SuperDiscount,
			dcmem.MasterDiscount = @MasterDiscount,
			dcmem.AgentDiscount = @AgentDiscount,
			dcmem.PlayerDiscount = @PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)  
			INNER JOIN @NewDiscountTbl tmp ON tmp.SportType=dcmem.SportType AND tmp.BetType=dcmem.BetType  
			INNER JOIN dbo.CustDiscount3rd_Agent dca WITH(NOLOCK) ON dca.sporttype = dcmem.sporttype AND dca.bettype = dcmem.bettype AND dca.custid=@AgentID
			INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dcmem.sporttype AND dcm.bettype = dcmem.bettype AND dcm.custid=@MasterID
			INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype AND dcs.bettype = dcmem.bettype AND dcs.custid=@SuperID
		WHERE dcmem.CustID=@CustID AND @SettingType IN (3,19)
	END
	ELSE IF @SettingType=2 --BetSetting
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0 RETURN
		
		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @SettingList
	
		INSERT @NewBetLimitTbl (SportType, BetType, MinBet, MaxBet, MaxPerMatch)
		SELECT SportType, BetType, MinBet, MaxBet, MaxPerMatch
		FROM OPENXML (@iDoc, '/root/r',1) 
		WITH(SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
			, MaxPerMatch	MONEY)	
	
		EXEC sp_xml_removedocument @iDoc

		--update new settings
		UPDATE main
		SET main.minbet			= tmp.MinBet
			, main.maxbet		= tmp.MaxBet
			, main.maxpermatch	= tmp.MaxperMatch
		FROM dbo.CustBetSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (
					main.minbet		<> tmp.MinBet
				OR main.maxbet		<> tmp.MaxBet
				OR main.maxpermatch <> tmp.MaxperMatch
				)
	END
	ELSE IF @SettingType=9
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0 RETURN

		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @SettingList
	
		INSERT @NewBetLimitTbl (SportType, BetType, MinBet, MaxBet, MaxPerMatch)
		SELECT SportType, BetType, MinBet, MaxBet, MaxPerNumber
		FROM OPENXML (@iDoc, '/root/r',1) 
		WITH(SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
			, MaxPerNumber	MONEY)	
	
		EXEC sp_xml_removedocument @iDoc

		--update new settings
		UPDATE main
		SET main.minbet			= tmp.MinBet
			, main.maxbet		= tmp.MaxBet
			, main.maxpermatch	= tmp.MaxPerMatch
		FROM dbo.CustBetSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (
					main.minbet		<> tmp.MinBet
				OR main.maxbet		<> tmp.MaxBet
				OR main.maxpermatch <> tmp.MaxPerMatch
				)
	END
	ELSE IF @SettingType=16
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0 RETURN

		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @SettingList
	
		INSERT @NewBetLimitTbl (SportType, BetType, MinBet, MaxBet, MaxPerMatch)
		SELECT SportType, BetType, MinBet, MaxBet, MaxPerMatch
		FROM OPENXML (@iDoc, '/root/r',1) 
		WITH(SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
			, MaxPerMatch	MONEY)	
	
		EXEC sp_xml_removedocument @iDoc

		--update new settings
		UPDATE main
		SET main.minbet			= tmp.MinBet
			, main.maxbet		= tmp.MaxBet
			, main.maxpermatch	= tmp.MaxPerMatch
		FROM dbo.CustBetSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (
					main.minbet		<> tmp.MinBet
				OR main.maxbet		<> tmp.MaxBet
				OR main.maxpermatch <> tmp.MaxPerMatch
				)
	END
	ELSE IF @SettingType=20
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0 RETURN

		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @SettingList
	
		INSERT @NewBetLimitTbl (SportType, BetType, MinBet, MaxBet)
		SELECT SportType, BetType, MinBet, MaxBet
		FROM OPENXML (@iDoc, '/root/r',1) 
		WITH(SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY)
	
		EXEC sp_xml_removedocument @iDoc

		--update new settings
		UPDATE main
		SET main.minbet			= tmp.MinBet
			, main.maxbet		= tmp.MaxBet
		FROM dbo.CustBetSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (
					main.minbet		<> tmp.MinBet
				OR main.maxbet		<> tmp.MaxBet
				)
	END
	ELSE IF @SettingType IN (6,22) --WinLossLimit
	BEGIN
		IF dbo.f_CheckRepTable('CustWinLossLimit_Member') = 0 RETURN

		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @SettingList
	
		INSERT @NewLimitTbl (SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
		SELECT SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
		FROM OPENXML (@iDoc, '/root/r',1) 
		WITH(SportType		SMALLINT
			, BetType		SMALLINT
			, MaxWinLimit	SMALLMONEY
			, MaxLossLimit	MONEY
			, IsAutoReset	BIT
		)	
	
		EXEC sp_xml_removedocument @iDoc

		--update new settings
		UPDATE main
		SET main.MaxWinLimit = tmp.MaxWinLimit
			, main.IsAutoReset = tmp.IsAutoReset
			, main.MaxLossLimit = tmp.MaxLossLimit
		FROM dbo.CustWinLossLimit_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (main.MaxWinLimit <> tmp.MaxWinLimit OR main.IsAutoReset <> tmp.IsAutoReset OR main.MaxLossLimit <> tmp.MaxLossLimit)

	END
	ELSE IF @SettingType=12 --Losslimit
	BEGIN
		IF dbo.f_CheckRepTable('CustWinLossLimit_Member') = 0 RETURN

		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @SettingList
	
		INSERT @NewLimitTbl (SportType, BetType, MaxLossLimit, IsAutoReset)
		SELECT SportType, BetType, MaxLossLimit, IsAutoReset
		FROM OPENXML (@iDoc, '/root/r',1) 
		WITH(SportType		SMALLINT
			, BetType		SMALLINT
			, MaxLossLimit	MONEY
			, IsAutoReset	BIT
		)	
	
		EXEC sp_xml_removedocument @iDoc

		--update new settings
		UPDATE main
		SET main.MaxLossLimit = tmp.MaxLossLimit
			, main.IsAutoReset = tmp.IsAutoReset
		FROM dbo.CustWinLossLimit_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (main.MaxLossLimit <> tmp.MaxLossLimit OR main.IsAutoReset <> tmp.IsAutoReset)

	END
	ELSE IF @SettingType IN (7,8,17) --Stakelevel
	BEGIN
		IF dbo.f_CheckRepTable('CustStakeLevel_Member') = 0 RETURN

		CREATE TABLE #tmpStake (
				SportType		SMALLINT
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
	ELSE IF @SettingType=23 --BetSetting
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0 RETURN
		IF dbo.f_CheckRepTable('CustBetSetting_Member') = 0 RETURN
		
		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @SettingList
	
		INSERT @NewBetLimitTbl (SportType, BetType, MinBet, MaxBet, MaxPerMatch, MaxPerNumber,SubType)
		SELECT SportType, BetType, MinBet, MaxBet, MaxPerMatch, MaxPerNumber,SubType
		FROM OPENXML (@iDoc, '/ROOT/BetLimit',1) 
		WITH(SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
			, MaxPerMatch	MONEY
			, MaxPerNumber	MONEY
			, SubType		TINYINT
			)	
	
		EXEC sp_xml_removedocument @iDoc

		--update new settings CustBetSetting3rd_Member
		UPDATE main
		SET main.minbet			= tmp.MinBet
			, main.maxbet		= tmp.MaxBet
			, main.maxpermatch	= tmp.MaxperMatch
		FROM dbo.CustBetSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
				AND tmp.SubType = 1
		WHERE main.custid = @CustID
			AND (
					main.minbet		<> tmp.MinBet
				OR main.maxbet		<> tmp.MaxBet
				OR main.maxpermatch <> tmp.MaxperMatch
				)

		--update new settings -- CustBetSetting_Member
		UPDATE main
		SET main.minbet			= tmp.MinBet
			, main.maxbet		= tmp.MaxBet
			, main.maxpermatch	= tmp.MaxperMatch
			, main.MaxPerNumber	= tmp.MaxPerNumber
		FROM dbo.CustBetSetting_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
				AND tmp.SubType = 2
		WHERE main.custid = @CustID
			AND (
					main.minbet		<> tmp.MinBet
				OR main.maxbet		<> tmp.MaxBet
				OR main.maxpermatch <> tmp.MaxperMatch
				OR main.MaxPerNumber <> tmp.MaxPerNumber
				)
	END
END
GO