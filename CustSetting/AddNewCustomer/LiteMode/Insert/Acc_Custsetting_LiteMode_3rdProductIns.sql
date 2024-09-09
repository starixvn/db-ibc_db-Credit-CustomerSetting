/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].Acc_Custsetting_LiteMode_3rdProductIns 
	  @CustID			INT
	, @SettingType23	VARCHAR(MAX)= '' --RNG Games
	, @RoleID			TINYINT	
	, @SiteID			SMALLINT
	, @Currency			SMALLINT	
	, @ErrCode			INT	= 0 OUTPUT
	, @SettingStatus	TINYINT = 0
AS
/*
	Created: 20240605@Eden
	Task : Initialize Customer Setting for New accounts Lite Mode
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20240520@Eden: Unify RNG Games [redmine: #204358]
		
	Param's Explanation:
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @xml XML

	CREATE TABLE #ProductProfile(
			[SettingType] [smallint] NOT NULL,
			[SportType] [smallint] NOT NULL,
			[BetType] [smallint] NOT NULL,
			[IsLive] [bit] NOT NULL,
			[SubType] [tinyint]
		)

	INSERT INTO #ProductProfile(SettingType,SportType,BetType,IsLive,SubType)
	SELECT SettingType,SportType,BetType,IsLive,SubType
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency) t

	IF NOT EXISTS( SELECT 1 FROM #ProductProfile)
	BEGIN
		SELECT @ErrCode = 99
		RETURN
	END

	DECLARE @BetSetting TABLE(
			SportType         SMALLINT, 
			BetType           SMALLINT, 
			MinBet            MONEY, 
			MaxBet            MONEY, 
			MaxPerMatch       MONEY, 
			MaxPerNumber      MONEY
			PRIMARY KEY(sporttype, Bettype)
		);


	-------------------------Settingtype = 23: Bet Setting--------------------------------
	DECLARE @Settingtype23_Tbl TABLE(
			[SportType] [smallint] NOT NULL,
			[BetType] [smallint] NOT NULL,
			[SubType] [tinyint]
	)

	INSERT INTO @Settingtype23_Tbl (SportType,BetType,SubType)
	SELECT SportType,BetType,SubType
	FROM #ProductProfile 
	WHERE SettingType = 23

	IF ISNULL(@SettingType23,'') <> '' 
		AND EXISTS (SELECT 1 FROM @Settingtype23_Tbl)
	BEGIN			
		SELECT @xml = CONVERT(XML,@SettingType23)
			
		INSERT INTO @BetSetting(
			SportType, 
			BetType, 
			MinBet, 
			MaxBet, 
			MaxPerMatch, 
			MaxPerNumber)
		SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
			T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
			T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch,
			T.c.query('.').value('(R/@MaxPerNumber)[1]', 'money') AS MaxPerNumber
		FROM  @xml.nodes('/Root/R') T(c)  
	END

	BEGIN TRY
		IF @RoleID IN (3,2)
		BEGIN				
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
				,cs.SportType
				,cs.BetType
				,MinBet
				,MaxBet
				,MaxPerMatch
				,CASE WHEN s.SubType = 2 THEN cs.MaxPerNumber END
				,dbo.f_GetDateTime2()
			FROM @BetSetting cs
				INNER JOIN @Settingtype23_Tbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
		END
		ELSE IF @roleid = 1
		BEGIN
			INSERT INTO [dbo].[BetSetting3rd_Member]
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
			FROM @BetSetting cs
				INNER JOIN @Settingtype23_Tbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
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

	DROP TABLE #ProductProfile
END