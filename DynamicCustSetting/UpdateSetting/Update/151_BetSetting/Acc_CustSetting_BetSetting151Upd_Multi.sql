/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_BetSetting151Upd_Multi] 
	  @CustID			INT
	, @BetSetting		VARCHAR(MAX)
	, @UserID			INT
	, @IP				VARCHAR(50)	= ''
	, @SystemID			INT = 1 
	, @SettingStatus	TINYINT = 0
	, @GroupType		SMALLINT = 151
	, @GroupID			TINYINT = 1
	, @UpdMinBet		BIT	= 1
	, @UpdMaxBet		BIT	= 1
	, @UpdMPM			BIT	= 1
	, @UpdMaxPO			BIT	= 1
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(1000)	= ''	OUTPUT
AS
/*
	Created: 20241010@Tacy
	Task : Update Bet Setting of Sportbook - Multiple
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20241010@Tacy: NAP & Ext - Manage super settings [redmine: #206291]
		
	Param's Explanation:
	- @BetSetting: Json Type
		'[
				  { "SportType": "1","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "880" },
				  { "SportType": "1","BetType": "9","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "2","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "3","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "5","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "8","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "10","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "11","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "99","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "99","BetType": "9","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "9901","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "9902","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "43","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "0" },
				  { "SportType": "44","BetType": "3","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "0" }
		]'
*/
BEGIN
	SET NOCOUNT ON;

	IF @BetSetting IS NULL OR @BetSetting = ''
		RETURN

	DECLARE @roleid		TINYINT
		, @CurrencyID	INT			
		, @siteid		INT	

	SELECT @roleid=roleid, @CurrencyID=c.currency
		, @siteid=s.siteid
	FROM Customer c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid=@CustID

	IF @roleid NOT BETWEEN 1 AND 4
	BEGIN
		SELECT @ErrMsg = 'Invalid account'
			, @ErrCode = 100
		RETURN
	END
	
	--Get betlimit
	DECLARE @NewBetSettingTbl TABLE (
		  CustID		INT
		, SportType		SMALLINT
		, BetType		SMALLINT
		, MinBet		MONEY
		, MaxBet		MONEY
		, MaxPerMatch	MONEY
		, MaxPayoutPerMatch  MONEY 
		, PRIMARY KEY CLUSTERED (CustID		ASC
								, SportType	ASC
								, BetType	ASC)
	)

	INSERT @NewBetSettingTbl(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch)
	SELECT @CustID,
	    SportType,
	    BetType,
	    MinBet,
	    MaxBet,
	    MPM,
	    MaxPayout
	FROM OPENJSON(@BetSetting)
		WITH
			(
			SportType	SMALLINT,
			BetType		SMALLINT,
			MinBet		MONEY,
			MaxBet		MONEY,
			MPM			MONEY,
			MaxPayout	MONEY
		) AS BetSetting 

	IF @roleid>1
	BEGIN
		--SMA: Get current value
		UPDATE t
		SET t.MinBet=CASE WHEN @UpdMinBet=0 THEN bs.MinBet ELSE t.MinBet END
			,t.MaxBet=CASE WHEN @UpdMaxBet=0 THEN bs.MaxBet ELSE t.MaxBet END
			,t.MaxPerMatch=CASE WHEN @UpdMPM=0 THEN bs.MaxPerMatch ELSE t.MaxPerMatch END
			,t.MaxPayoutPerMatch=CASE WHEN @UpdMaxPO=0 THEN bs.MaxPayoutPerMatch ELSE t.MaxPayoutPerMatch END
		FROM @NewBetSettingTbl t
		INNER JOIN BetSetting_Agent bs WITH (NOLOCK) 
				ON t.CustID=bs.CustID
				AND t.SportType=bs.SportType
				AND t.BetType=bs.BetType
	
		--Delete nochange:
		DELETE t
		FROM @NewBetSettingTbl t
		INNER JOIN BetSetting_Agent bs WITH (NOLOCK) 
				ON t.CustID=bs.CustID
				AND t.SportType=bs.SportType
				AND t.BetType=bs.BetType
		WHERE t.MinBet=bs.MinBet
			AND t.MaxBet=bs.MaxBet
			AND t.MaxPerMatch=bs.MaxPerMatch
			AND ISNULL(t.MaxPayoutPerMatch,0)=ISNULL(bs.MaxPayoutPerMatch,0)
	END
	ELSE
	BEGIN
		--Member: Get current value
		UPDATE t
		SET t.MinBet=CASE WHEN @UpdMinBet=0 THEN bs.MinBet ELSE t.MinBet END
			,t.MaxBet=CASE WHEN @UpdMaxBet=0 THEN bs.MaxBet ELSE t.MaxBet END
			,t.MaxPerMatch=CASE WHEN @UpdMPM=0 THEN bs.MaxPerMatch ELSE t.MaxPerMatch END
			,t.MaxPayoutPerMatch=CASE WHEN @UpdMaxPO=0 THEN bs.MaxPayoutPerMatch ELSE t.MaxPayoutPerMatch END
		FROM @NewBetSettingTbl t
		INNER JOIN BetSetting_Member bs WITH (NOLOCK) 
				ON t.CustID=bs.CustID
				AND t.SportType=bs.SportType
				AND t.BetType=bs.BetType

		DELETE t
		FROM @NewBetSettingTbl t
		INNER JOIN BetSetting_Member bs WITH (NOLOCK) 
				ON t.CustID=bs.CustID
				AND t.SportType=bs.SportType
				AND t.BetType=bs.BetType
		WHERE t.MinBet=bs.MinBet
			AND t.MaxBet=bs.MaxBet
			AND t.MaxPerMatch=bs.MaxPerMatch
			AND ISNULL(t.MaxPayoutPerMatch,0)=ISNULL(bs.MaxPayoutPerMatch,0)
	END

	IF NOT EXISTS (SELECT 1 FROM @NewBetSettingTbl)
		RETURN

	--Validate when updating MinBet only:
	IF (@UpdMinBet=1 AND @UpdMaxBet=0 AND @UpdMPM=0 AND @UpdMaxPO=0)
	BEGIN
		DECLARE @xml	XML

		--Check MinBet<=MaxBet
		IF EXISTS(SELECT TOP 1 1
				  FROM @NewBetSettingTbl tmp
				  WHERE (tmp.MinBet <> 0 OR tmp.MaxBet <> 0)
					AND tmp.MinBet > tmp.MaxBet)
		BEGIN
			SET @xml = (
					SELECT NULL AS '@MsgID'
						, 'Min Bet must be less than or equal to Max Bet' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, psdc.GroupID AS '@GroupID'
								, psdc.GroupType AS '@GroupType'
							FROM @NewBetSettingTbl tmp
							CROSS APPLY (SELECT f.GroupID, f.GroupType
										 FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@CurrencyID) f
										 WHERE Grouptype = @GroupType
											AND (GroupID = @GroupID OR @GroupID IS NULL)
											AND tmp.SportType = f.SportType AND tmp.BetType = f.BetType
										) psdc
							WHERE (tmp.MinBet <> 0 OR tmp.MaxBet <> 0)
								AND tmp.MinBet > tmp.MaxBet
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 110
		
			RETURN
		END
	END

	SELECT @BetSetting = (SELECT SportType,BetType
								,MinBet,MaxBet
								,MaxPerMatch AS MPM
								,MaxPayoutPerMatch AS MaxPayout
							FROM @NewBetSettingTbl T
							WHERE CustID=@CustID
							FOR JSON PATH)

	EXEC [Acc_CustSetting_BetSetting151Upd] 
		  @CustID			= @CustID
		, @BetSetting		= @BetSetting
		, @UserID			= @UserID
		, @IP				= @IP
		, @SystemID			= @SystemID 
		, @ErrCode			= @ErrCode	OUTPUT
		, @MsgType			= @MsgType	OUTPUT
		, @ErrMsg			= @ErrMsg	OUTPUT
		, @SettingStatus	= @SettingStatus
		, @GroupType		= @GroupType
		, @GroupID			= @GroupID

	IF @ErrCode<>0
		RETURN
END
GO