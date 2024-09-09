/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].Acc_Custsetting_CloneSetting_3rdProductIns 
	  @CustID			INT
	, @ExistingCustID	INT		= 0
	, @RoleID			TINYINT	
	, @SiteID			SMALLINT
	, @Currency			SMALLINT	
	, @ProductProfile	VARCHAR(MAX) = NULL -- Json
	, @ErrCode			INT	= 0 OUTPUT
	, @SettingStatus	TINYINT = 0
AS
/*
	Created: 20240605@Eden
	Task : Initialize Customer Setting for New accounts Search and Copy SMA
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
			[IsHiddenSource] [BIT] NOT NULL,
			[HasSyncSource] [BIT] NOT NULL,
			[SubType] [tinyint]
		)

	INSERT INTO #ProductProfile(SettingType,SportType,BetType,IsLive,IsHiddenSource,HasSyncSource)
	SELECT SettingType,SportType,BetType,IsLive,IsHiddenSource,HasSyncSource
	FROM OPENJSON(@ProductProfile) WITH (
			SettingType smallint  '$.SettingType', 
			SportType smallint  '$.SportType',
			BetType smallint  '$.BetType',
			IsLive bit  '$.IsLive',
			IsHiddenSource bit '$.IsHiddenSource',
			HasSyncSource bit '$.HasSyncSource'
		)

	UPDATE fil
	SET fil.SubType = t.SubType
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency) t		
		INNER JOIN #ProductProfile fil 
					ON t.SettingType = fil.SettingType 
					AND t.SportType = fil.SportType 
					AND t.BetType = fil.BetType

	IF NOT EXISTS( SELECT 1 FROM #ProductProfile)
	BEGIN
		SELECT @ErrCode = 99
		RETURN
	END

	-------------------------Settingtype = 23: Bet Setting--------------------------------
	BEGIN TRY
		IF EXISTS(SELECT TOP 1 1 FROM [dbo].BetSetting3rd_Agent WITH(NOLOCK) WHERE CustID = @ExistingCustID)
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
			SELECT		@CustID
						,cs.SportType
						,cs.BetType
						,[MinBet]
						,[MaxBet]
						,[MaxPerMatch]
						,[MaxPerNumber]
						,dbo.f_GetDateTime2()
			FROM [dbo].BetSetting3rd_Agent cs WITH (NOLOCK)
				INNER JOIN #ProductProfile ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType
			WHERE CustID = @ExistingCustID 
				AND ps.SettingType IN (23) 
				AND ps.IsHiddenSource = 0 
				AND (@RoleID <> 4 OR ps.HasSyncSource = 1)

		IF @RoleID = 4
		BEGIN
			INSERT INTO [dbo].[BetSetting3rd_Agent]
					(
						 [CustID]
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
				,CASE WHEN SubType = 2 THEN 0 END
				,dbo.f_GetDateTime2()
			FROM #ProductProfile t 
			WHERE t.SettingType IN (23) 
				AND (t.IsHiddenSource = 1 OR t.HasSyncSource = 0)
		END
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 23
		
		DELETE c
		OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2()
		INTO BetSetting3rd_Agent_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
		FROM BetSetting3rd_Agent c WITH(ROWLOCK) 
		WHERE CustID = @CustID

		RETURN
	END CATCH

	DROP TABLE #ProductProfile
END