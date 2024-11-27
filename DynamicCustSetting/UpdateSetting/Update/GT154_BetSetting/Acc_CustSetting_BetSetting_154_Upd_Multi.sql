/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_BetSetting_154_Upd_Multi] 
	  @CustID			INT
	, @BetLimit			VARCHAR(MAX)
	, @UserID			INT
	, @IP				VARCHAR(50)		= ''
	, @SystemID			INT = 1 
	, @SettingStatus	TINYINT = 0
	, @GroupType		SMALLINT = 154
	, @GroupID			TINYINT = 2
	, @UpdMinBet		BIT	= 1
	, @UpdMaxBet		BIT	= 1
	, @UpdMPM			BIT	= 1
	, @UpdMPNumber		BIT	= 1
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(1000)	= ''	OUTPUT
AS
/*
	Created: 20241010@Tacy
	Task : Update Customer's Bet Limits - Multiple
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20241010@Tacy: NAP & Ext - Manage super settings [redmine: #206291]
		
	Param's Explanation:
	- @BetLimit:
		[
			{"SportType": "169","BetType": "3611","MinBet": "1","MaxBet": "10","MPM": "100"},
			{"SportType": "9919","BetType": "1501","MinBet": "1","MaxBet": "10","MPM": "100"},
			{"SportType": "9908","BetType": "1201","MinBet": "1","MaxBet": "10","MPM": "100"},
			{"SportType": "161","BetType": "81","MinBet": "1","MaxBet": "10","MPM": "100","MaxPerNumber": "80"}
		]
	*/
BEGIN
	SET NOCOUNT ON;

	IF @BetLimit IS NULL OR @BetLimit = ''
		RETURN

	DECLARE @roleid TINYINT

	SELECT @roleid=roleid
	FROM Customer WITH (NOLOCK)
	WHERE custid=@CustID

	IF @roleid NOT BETWEEN 1 AND 4
	BEGIN
		SELECT @ErrMsg = 'Invalid account'
			, @ErrCode = 100
		RETURN
	END

	--Get betlimit
	DECLARE @NewBetLimitTbl TABLE (
		  CustID		INT
		, SportType		SMALLINT
		, BetType		SMALLINT
		, MinBet		MONEY
		, MaxBet		MONEY
		, MaxPerMatch	MONEY
		, MaxPerNumber  MONEY 
		, PRIMARY KEY CLUSTERED (CustID		ASC
								, SportType	ASC
								, BetType	ASC)
	)

	INSERT @NewBetLimitTbl(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
	SELECT @CustID,
	    SportType,
	    BetType,
	    MinBet,
	    MaxBet,
	    MPM,
	    MaxPerNumber
	FROM OPENJSON(@BetLimit)
		WITH
			(
			SportType	SMALLINT,
			BetType		SMALLINT,
			MinBet		MONEY,
			MaxBet		MONEY,
			MPM			MONEY,
			MaxPerNumber	MONEY
		) AS BetLimit 

	IF @roleid>1
	BEGIN
		--SMA: Get current value
		UPDATE t
		SET t.MinBet=CASE WHEN @UpdMinBet=0 THEN bs.MinBet ELSE t.MinBet END
			,t.MaxBet=CASE WHEN @UpdMaxBet=0 THEN bs.MaxBet ELSE t.MaxBet END
			,t.MaxPerMatch=CASE WHEN @UpdMPM=0 THEN bs.MaxPerMatch ELSE t.MaxPerMatch END
			,t.MaxPerNumber=CASE WHEN @UpdMPNumber=0 THEN bs.MaxPerNumber ELSE t.MaxPerNumber END
		FROM @NewBetLimitTbl t
		INNER JOIN BetSetting3rd_Agent bs WITH (NOLOCK) 
				ON t.CustID=bs.CustID
				AND t.SportType=bs.SportType
				AND t.BetType=bs.BetType
	
		--Delete nochange:
		DELETE t
		FROM @NewBetLimitTbl t
		INNER JOIN BetSetting3rd_Agent bs WITH (NOLOCK) 
				ON t.CustID=bs.CustID
				AND t.SportType=bs.SportType
				AND t.BetType=bs.BetType
		WHERE t.MinBet=bs.MinBet
			AND t.MaxBet=bs.MaxBet
			AND t.MaxPerMatch=bs.MaxPerMatch
			AND ISNULL(t.MaxPerNumber,0)=ISNULL(bs.MaxPerNumber,0)
	END
	ELSE
	BEGIN
		--Member: Get current value
		UPDATE t
		SET t.MinBet=CASE WHEN @UpdMinBet=0 THEN bs.MinBet ELSE t.MinBet END
			,t.MaxBet=CASE WHEN @UpdMaxBet=0 THEN bs.MaxBet ELSE t.MaxBet END
			,t.MaxPerMatch=CASE WHEN @UpdMPM=0 THEN bs.MaxPerMatch ELSE t.MaxPerMatch END
			,t.MaxPerNumber=CASE WHEN @UpdMPNumber=0 THEN bs.MaxPerNumber ELSE t.MaxPerNumber END
		FROM @NewBetLimitTbl t
		INNER JOIN BetSetting3rd_Member bs WITH (NOLOCK) 
				ON t.CustID=bs.CustID
				AND t.SportType=bs.SportType
				AND t.BetType=bs.BetType

		DELETE t
		FROM @NewBetLimitTbl t
		INNER JOIN BetSetting3rd_Member bs WITH (NOLOCK) 
				ON t.CustID=bs.CustID
				AND t.SportType=bs.SportType
				AND t.BetType=bs.BetType
		WHERE t.MinBet=bs.MinBet
			AND t.MaxBet=bs.MaxBet
			AND t.MaxPerMatch=bs.MaxPerMatch
			AND ISNULL(t.MaxPerNumber,0)=ISNULL(bs.MaxPerNumber,0)
	END

	IF NOT EXISTS (SELECT 1 FROM @NewBetLimitTbl)
		RETURN

	--Validate when updating MinBet only:
	IF (@UpdMinBet=1 AND @UpdMaxBet=0 AND @UpdMPM=0 AND @UpdMPNumber=0)
	BEGIN
		DECLARE @xml	XML

		--Check MinBet<=MaxBet
		IF EXISTS(SELECT TOP 1 1
				  FROM @NewBetLimitTbl tmp
				  WHERE (tmp.MinBet <> 0 OR tmp.MaxBet <> 0)
					AND tmp.MinBet > tmp.MaxBet)
		BEGIN
			SET @xml = (
					SELECT NULL AS '@MsgID'
						, 'Min Bet must be less than or equal to Max Bet' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @NewBetLimitTbl tmp
							WHERE (tmp.MinBet <> 0 OR tmp.MaxBet <> 0)
								AND tmp.MinBet > tmp.MaxBet
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 72
			SET @ErrCode = 107
		
			RETURN
		END
	END

	SELECT @BetLimit = (SELECT SportType,BetType
							,MinBet,MaxBet
							,MaxPerMatch AS MPM
							,MaxPerNumber
						FROM @NewBetLimitTbl T
						WHERE CustID=@CustID
						FOR JSON PATH)

	EXEC [Acc_CustSetting_BetSetting_154_Upd] 
		  @CustID			= @CustID
		, @BetLimit			= @BetLimit
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