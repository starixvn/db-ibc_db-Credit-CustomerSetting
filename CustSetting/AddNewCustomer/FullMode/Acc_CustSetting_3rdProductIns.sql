/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].Acc_CustSetting_3rdProductIns 
	  @CustID			INT
	, @SuperID			INT			= NULL
	, @MasterID			INT			= NULL
	, @AgentID			INT			= NULL
	, @RoleID			TINYINT	
	, @SiteID			SMALLINT
	, @Currency			SMALLINT	
	, @ProductProfile	VARCHAR(MAX) = NULL -- Json
	, @ErrCode			INT	= 0 OUTPUT
	, @SettingStatus	TINYINT = 0
AS
/*
	Created: 20240605@Eden
	Task : Initialize Customer Setting for New accounts
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20240520@Eden: Unify RNG Games [redmine: #204358]
		
	Param's Explanation:
	*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #ProductProfile(
			[SettingType] [smallint] NOT NULL,
			[SportType] [smallint] NOT NULL,
			[BetType] [smallint] NOT NULL,
			[IsLive] [bit] NOT NULL,
			[SubType] [tinyint]
		)

	IF @RoleID = 4
	BEGIN
		INSERT INTO #ProductProfile(SettingType,SportType,BetType,IsLive)
		SELECT SettingType,SportType,BetType,IsLive
		FROM OPENJSON(@ProductProfile) WITH (
				SettingType smallint  '$.SettingType', 
				SportType smallint  '$.SportType',
				BetType smallint  '$.BetType',
				IsLive bit  '$.IsLive'
			)

		UPDATE fil
		SET fil.SubType = t.SubType
		FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency) t		
			INNER JOIN #ProductProfile fil 
						ON t.SettingType = fil.SettingType 
						AND t.SportType = fil.SportType 
						AND t.BetType = fil.BetType
	END
	ELSE
	BEGIN
		INSERT INTO #ProductProfile(SettingType,SportType,BetType,IsLive,SubType)
		SELECT SettingType,SportType,BetType,IsLive,SubType
		FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency) t
	END

	IF NOT EXISTS( SELECT 1 FROM #ProductProfile)
	BEGIN
		SELECT @ErrCode = 99
		RETURN
	END

	-------------------------Settingtype = 23: Bet Setting--------------------------------
	DECLARE @Settingtype23 TABLE(
			[SportType] [smallint] NOT NULL,
			[BetType] [smallint] NOT NULL,
			[SubType] [tinyint]
	)

	INSERT INTO @Settingtype23 (SportType,BetType,SubType)
	SELECT SportType,BetType,SubType
	FROM #ProductProfile 
	WHERE SettingType = 23

	IF EXISTS (SELECT 1 FROM @Settingtype23)
	BEGIN
		BEGIN TRY
			IF @RoleID = 4
			BEGIN
				--Min: 0
				--Max: 0
				--Max Per Match: 0
				--Max Per Ball = 0 (SubType = 2)
				INSERT INTO [dbo].[BetSetting3rd_Agent]
					([CustID]
					,[SportType]
					,[BetType]
					,[MinBet]
					,[MaxBet]
					,[MaxPerMatch]
					,[MaxPerNumber]
					,[RepUpdateTime]
					)
				SELECT
					@CustID
					,t.SportType
					,t.BetType
					,0
					,0
					,0
					,CASE WHEN t.SubType = 2 THEN 0 END
					,dbo.f_GetDateTime2()
				FROM @Settingtype23 t
			END
			ELSE IF @RoleID = 3
			BEGIN
				INSERT INTO [dbo].BetSetting3rd_Agent
					([CustID]
					,[SportType]
					,[BetType]
					,[MinBet]
					,[MaxBet]
					,[MaxPerMatch]
					,[MaxPerNumber]
					,[RepUpdateTime]
					)
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,MinBet
					,MaxBet
					,MaxPerMatch
					,CASE WHEN s.SubType = 2 THEN cs.MaxPerNumber END
					,dbo.f_GetDateTime2()
				FROM dbo.BetSetting3rd_Agent cs WITH (NOLOCK)
					INNER JOIN @Settingtype23 s 
						ON s.SportType = cs.SportType 
						AND s.Bettype = cs.BetType
				WHERE custid = @SuperID
			END
			ELSE IF @RoleID = 2
			BEGIN
				--Min: max(master.minbet; super.minbet)
				--Max: min(master.maxbet; super.maxbet)
				--Max Per Match: min(master.maxpermatch; super.maxpermatch)
				--Max Per Number: min(master.MaxPerNumber; super.MaxPerNumber)
				DECLARE @BetlimitAgent23 TABLE(
						SportType SMALLINT,
						BetType SMALLINT,
						MinBet MONEY,
						MaxBet MONEY,
						MaxPerMatch MONEY,
						MaxPerNumber MONEY,
						SubType TINYINT
					)

				INSERT INTO @BetlimitAgent23(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,SubType)
				SELECT smcs.SportType,smcs.BetType,
							Max(case when MinBet = 0 then NULL else MinBet end) MinBet,
							Min(case when MaxBet = 0 then NULL else MaxBet end) MaxBet,
							Min(case when MaxPerMatch = 0 then NULL else MaxPerMatch end) MaxPerMatch,
							Min(case when MaxPerNumber = 0 then NULL else MaxPerNumber end) MaxPerNumber,
							MIN(s.SubType)
				FROM dbo.BetSetting3rd_Agent smcs WITH (NOLOCK)
					INNER JOIN @Settingtype23 s 
						ON s.SportType = smcs.SportType 
						AND s.Bettype = smcs.BetType
				WHERE smcs.custid IN (@SuperID,@MasterID)
				GROUP BY smcs.SportType,smcs.BetType
		
				INSERT INTO [dbo].[BetSetting3rd_Agent]
					([CustID]
					,[SportType]
					,[BetType]
					,[MinBet]
					,[MaxBet]
					,[MaxPerMatch]
					,MaxPerNumber
					,[RepUpdateTime]
					)
				SELECT
					@CustID
					,SportType
					,BetType
					,ISNULL(MinBet,0)
					,ISNULL(MaxBet,0)
					,ISNULL(MaxPerMatch,0)
					,CASE WHEN SubType = 2 THEN ISNULL(MaxPerNumber,0) END
					,dbo.f_GetDateTime2()
				FROM @BetlimitAgent23
			END
			ELSE
			BEGIN
				--Min: max(agent.minbet; master.minbet; super.minbet)
				--Max: min(agent.maxbet; master.maxbet; super.maxbet)
				--Max Per Match: min(agent.maxpermatch; master.maxpermatch; super.maxpermatch)
				--Max Per Number: min(agent.MaxPerNumber; master.MaxPerNumber; super.MaxPerNumber)
				DECLARE @BetlimitMember23 TABLE(
						SportType SMALLINT,
						BetType SMALLINT,
						MinBet MONEY,
						MaxBet MONEY,
						MaxPerMatch MONEY,
						MaxPerNumber MONEY,
						SubType TINYINT
					)

				INSERT INTO @BetlimitMember23(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,SubType)
				SELECT smcs.SportType,smcs.BetType,
							Max(case when MinBet = 0 then NULL else MinBet end) MinBet,
							Min(case when MaxBet = 0 then NULL else MaxBet end) MaxBet,
							Min(case when MaxPerMatch = 0 then NULL else MaxPerMatch end) MaxPerMatch,
							Min(case when MaxPerNumber = 0 then NULL else MaxPerNumber end) MaxPerNumber,
							MIN(s.SubType)
				FROM dbo.BetSetting3rd_Agent smcs WITH (NOLOCK)
					INNER JOIN @Settingtype23 s ON s.SportType = smcs.SportType AND s.Bettype = smcs.BetType
				WHERE smcs.custid IN (@SuperID,@MasterID,@AgentID)
				GROUP BY smcs.SportType,smcs.BetType

				INSERT INTO [dbo].[BetSetting3rd_Member]
					([CustID]
					,[SportType]
					,[BetType]
					,[MinBet]
					,[MaxBet]
					,[MaxPerMatch]
					,MaxPerNumber
					,[RepUpdateTime]
					)
				SELECT
					@CustID
					,SportType
					,BetType
					,ISNULL(MinBet,0)
					,ISNULL(MaxBet,0)
					,ISNULL(MaxPerMatch,0)
					,CASE WHEN SubType = 2 THEN ISNULL(MaxPerNumber,0) END
					,dbo.f_GetDateTime2()
				FROM @BetlimitMember23
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 23

			IF @RoleID = 1
			BEGIN
				DELETE c
				OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2()
				INTO BetSetting3rd_Member_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
				FROM BetSetting3rd_Member c WITH(ROWLOCK) 
				WHERE CustID = @CustID
			END
			ELSE
			BEGIN
				DELETE c
				OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2()
				INTO BetSetting3rd_Agent_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
				FROM BetSetting3rd_Agent c WITH(ROWLOCK) 
				WHERE CustID = @CustID
			END

			RETURN
		END CATCH
	END

	DROP TABLE #ProductProfile
END