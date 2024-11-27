/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_MaxPayoutUpd_Multi] 
	  @CustID			INT
	, @MaxPayoutLimit	VARCHAR(MAX)
	, @UserID			INT
	, @IP				VARCHAR(50)	= ''
	, @SettingStatus	TINYINT = 0
	, @GroupType		SMALLINT = 152
	, @GroupID			TINYINT = 1
	, @UpdSingleMP		BIT	= 1
	, @UpdCombo2		BIT	= 1
	, @UpdCombo35		BIT	= 1
	, @UpdCombo6		BIT	= 1
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(1000)	= ''	OUTPUT
AS
/*
	Created: 20241010@Tacy
	Task : Update Customer's Parlay Max Payout - Multiple
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20241010@Tacy: NAP & Ext - Manage super settings [redmine: #206291]
		
	Param's Explanation:
	- @MaxPayoutLimit:
		'[
			{ "SportType": "1", "BetType": "9", "SingleMP": "3000", "Combo2": "40000", "Combo35": "6000000", "Combo6": "1000000"  },
			{ "SportType": "99", "BetType": "9", "SingleMP": "6000", "Combo2": "40000", "Combo35": "6000000", "Combo6": "1000000" }
		]'
*/
BEGIN
	SET NOCOUNT ON;

	IF @MaxPayoutLimit IS NULL OR @MaxPayoutLimit = ''
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
	DECLARE @NewMaxPayoutTbl TABLE (
		  CustID		INT
		, SportType		SMALLINT
		, BetType		SMALLINT
		, SingleMatchParlay	MONEY
		, Combo2			MONEY
		, Combo35			MONEY
		, ComboOver6		MONEY 
		, PRIMARY KEY CLUSTERED (CustID		ASC
								, SportType	ASC
								, BetType	ASC)
	)

	INSERT @NewMaxPayoutTbl(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
	SELECT @CustID,
	    SportType,
	    BetType,
	    SingleMP,
		Combo2,
		Combo35,
		Combo6	    
	FROM OPENJSON(@MaxPayoutLimit)
		WITH
			(
			SportType	SMALLINT,
			BetType		SMALLINT,
			SingleMP	MONEY,
			Combo2		MONEY,
			Combo35		MONEY,
			Combo6		MONEY
		) AS PayoutLimit 

	IF @roleid>1
	BEGIN
		--SMA: Get current value
		UPDATE t
		SET t.SingleMatchParlay=CASE WHEN @UpdSingleMP=0 THEN bs.SingleMatchParlay ELSE t.SingleMatchParlay END
			,t.Combo2=CASE WHEN @UpdCombo2=0 THEN bs.Combo2 ELSE t.Combo2 END
			,t.Combo35=CASE WHEN @UpdCombo35=0 THEN bs.Combo35 ELSE t.Combo35 END
			,t.ComboOver6=CASE WHEN @UpdCombo6=0 THEN bs.ComboOver6 ELSE t.ComboOver6 END
		FROM @NewMaxPayoutTbl t
		INNER JOIN CustMaxPayoutSetting_Agent bs WITH (NOLOCK) 
				ON t.CustID=bs.CustID
				AND t.SportType=bs.SportType
				AND t.BetType=bs.BetType

		--Delete nochange:
		DELETE t
		FROM @NewMaxPayoutTbl t
		INNER JOIN CustMaxPayoutSetting_Agent bs WITH (NOLOCK) 
				ON t.CustID=bs.CustID
				AND t.SportType=bs.SportType
				AND t.BetType=bs.BetType
		WHERE t.SingleMatchParlay=bs.SingleMatchParlay
			AND t.Combo2=bs.Combo2
			AND t.Combo35=bs.Combo35
			AND t.ComboOver6=bs.ComboOver6
	END
	ELSE
	BEGIN
		--Member: Get current value
		UPDATE t
		SET t.SingleMatchParlay=CASE WHEN @UpdSingleMP=0 THEN bs.SingleMatchParlay ELSE t.SingleMatchParlay END
			,t.Combo2=CASE WHEN @UpdCombo2=0 THEN bs.Combo2 ELSE t.Combo2 END
			,t.Combo35=CASE WHEN @UpdCombo35=0 THEN bs.Combo35 ELSE t.Combo35 END
			,t.ComboOver6=CASE WHEN @UpdCombo6=0 THEN bs.ComboOver6 ELSE t.ComboOver6 END
		FROM @NewMaxPayoutTbl t
		INNER JOIN CustMaxPayoutSetting_Member bs WITH (NOLOCK) 
				ON t.CustID=bs.CustID
				AND t.SportType=bs.SportType
				AND t.BetType=bs.BetType

		DELETE t
		FROM @NewMaxPayoutTbl t
		INNER JOIN CustMaxPayoutSetting_Member bs WITH (NOLOCK) 
				ON t.CustID=bs.CustID
				AND t.SportType=bs.SportType
				AND t.BetType=bs.BetType
		WHERE  t.SingleMatchParlay=bs.SingleMatchParlay
			AND t.Combo2=bs.Combo2
			AND t.Combo35=bs.Combo35
			AND t.ComboOver6=bs.ComboOver6
	END

	IF NOT EXISTS (SELECT 1 FROM @NewMaxPayoutTbl)
		RETURN

	SELECT @MaxPayoutLimit = (SELECT SportType,BetType
									,SingleMatchParlay AS SingleMP 
									,Combo2
									,Combo35
									,ComboOver6 AS Combo6
								FROM @NewMaxPayoutTbl T
								WHERE CustID=@CustID
								FOR JSON PATH)

	EXEC [Acc_CustSetting_MaxPayoutUpd] 
			@CustID			= @CustID
		, @MaxPayoutLimit	= @MaxPayoutLimit
		, @UserID			= @UserID
		, @IP				= @IP
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