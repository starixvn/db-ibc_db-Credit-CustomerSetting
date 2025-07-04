/*<info serverAlias="DBTXN-bodb02" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_BalanceGameReset_CashMember]
	@Custid				INT
	,@SportTypeRef		SMALLINT
	,@BetTypeRef		SMALLINT
	,@SettingStatus		TINYINT			= 0
    ,@ErrCode			INT	   			= 0  OUTPUT
    ,@ErrMsg			NVARCHAR(500)	= '' OUTPUT
AS
/*
	Created: 20250703@Dave
	Task: Customer Setting - Reset Banlace WinLimit for Cash Member
	DB: DBTXN-bodb02
	
	Revisions:
		- 20250703@Dave: Initial SP [Redmine: #232054]
		
	Parameter's Explanation:
	
*/	
BEGIN
	SET NOCOUNT ON;

	DECLARE @WinlostDate	SMALLDATETIME = GETDATE();
	
	IF EXISTS (
		SELECT 1 FROM DBCUST.CustDB.dbo.CustWinLossLimit_Member WITH (NOLOCK)
		WHERE CustID = @Custid AND SportType = @SportTypeRef AND BetType = @BetTypeRef AND IsAutoReset = 1)
	BEGIN
		SET @ErrCode = 1;
		SET @ErrMsg = N'IsAutoReset = 1';
		RETURN;
	END;

	/*Check if the member is already rested today*/
	IF EXISTS (
		SELECT 1 FROM DBCUST.CustDB.dbo.CustWinLossLimit_Member WITH (NOLOCK)
		WHERE CustID = @Custid AND SportType = @SportTypeRef AND BetType = @BetTypeRef AND DATEDIFF(DAY, RestedDate, @WinlostDate) = 0)
	BEGIN
		SET @ErrCode = 2;
		SET @ErrMsg = N'You’ve reached the daily reset limit per day (1 time). Please try again tomorrow.';
		RETURN;
	END;

	CREATE TABLE #Tmp_WinLimit( BetType SMALLINT);

	INSERT INTO #Tmp_WinLimit (BetType)
	SELECT st.bettype
	FROM CustDB.dbo.f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) st
		INNER JOIN CustDB.dbo.f_CustSetting_SportBetTypeSettingSelect(NULL, 22, @SettingStatus) AS s
			ON st.SporttypeRefWinlossLimit = s.SportType 
			AND st.BettypeRefWinlossLimit = s.Bettype
			AND st.isLicensee = 0 AND st.Site = 'ALL'
	WHERE SporttypeRefWinlossLimit = @SportTypeRef
		AND BettypeRefWinlossLimit = @BetTypeRef
		AND st.isDeleted = 0;


	WHILE 1 = 1
	BEGIN
		DELETE TOP (50000) bal
		FROM dbo.BalanceCreditGame bal WITH (ROWLOCK)
			INNER JOIN #Tmp_WinLimit t 
				ON bal.custid = @Custid AND bal.bettype = t.BetType
		WHERE winlostdate <= @WinlostDate
		OPTION (MAXDOP 4,RECOMPILE);
			
		IF @@ROWCOUNT < 50000
			BREAK;
				
		WAITFOR DELAY '00:00:00.280';
	END;

	WHILE 1 = 1
	BEGIN
		DELETE TOP (50000) bal
		FROM dbo.BalanceDebitGame bal WITH (ROWLOCK)
			INNER JOIN #Tmp_WinLimit t 
				ON bal.custid = @Custid AND bal.bettype = t.BetType
		WHERE winlostdate <= @WinlostDate
		OPTION (MAXDOP 4,RECOMPILE);
			
		IF @@ROWCOUNT < 50000
			BREAK;
				
		WAITFOR DELAY '00:00:00.280';
	END;

	UPDATE DBCUST.CustDB.dbo.CustWinLossLimit_Member
	SET RestedDate = @WinlostDate,
		RepUpdateTime = dbo.f_GetDateTime2()
	WHERE CustID = @Custid 
		AND SportType = @SportTypeRef 
		AND BetType = @BetTypeRef;
	
	DROP TABLE #Tmp_WinLimit;

END
GO
