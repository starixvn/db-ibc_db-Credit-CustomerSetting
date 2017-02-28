ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterKeno_BetSetting]
(
	@CustId INT --Master
	, @Sporttype INT = 202
	, @Bettype INT

	, @UpdateStatus BIT = 0
	, @Disable BIT = 1
	, @DisableDownLines BIT = 1
	
	, @UpdateMinMaxBet BIT = 0
	, @MinBet MONEY
	, @MaxBet MONEY
	, @MaxPerMatch MONEY

	, @UserId INT = 0
	, @SubAccID INT = 0
	, @Ip VARCHAR(50) = ''
	, @Language VARCHAR(20) = 'E'
	, @ErrCode VARCHAR(300) = '' OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
)
AS
/*
	Created: 20140326@Patrick
	Task: Master updates Keno bet setting on Master
	DB: DBCUST/CustDB

	Revisions:
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
	Parameters Explanation:
		@ErrCode = -100 & -101: update successfully
			-100: status
			-101: Min max bet
		else update not successfully
	
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @roleid TINYINT, @ErrCode_Cur INT, @VarErrCode_Cur VARCHAR(300), @ErrMsg_Cur NVARCHAR(4000)
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	--Check downline belonging
	EXEC dbo.Age_CustomerSelCheckBelonging @SessionCustID = @Userid
		, @Custid = @custid
		, @roleid = @roleid OUTPUT
	IF (@roleid = 0) RETURN

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode = @ErrCode_Cur OUTPUT, @ErrMsg = @ErrMsg_Cur OUTPUT
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN
	END
	            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END


	--Update status
	IF @UpdateStatus = 1
	BEGIN								
		SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''
		EXEC dbo.Acc_CustomerUpdDisableKeno @custid = @custid
			, @Bettype = @Bettype
			, @Disable = @Disable
			, @DisableDownlines = @DisableDownlines
			, @UserID = @UserID
			, @SubAccID = @SubAccID
			, @Language	= @Language
			, @ErrCode = @ErrCode_Cur OUTPUT
			, @ErrMsg = @ErrMsg_Cur OUTPUT
			, @IP = @IP
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		END
		ELSE
		BEGIN
			SELECT @ErrCode = @ErrCode + '-100'+ CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
		END
	END

	IF @UpdateMinMaxBet = 1
	BEGIN
		SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''
				EXEC dbo.Acc_CustomerUpdMasterKeno_MinMaxBet @CustID = @CustID
			, @SportType = @Sporttype
			, @BetType = @Bettype
			, @MinBet = @MinBet
			, @MaxBet = @MaxBet
			, @MaxPerMatch = @MaxPerMatch
			, @SubAccID = @SubAccID
			, @UserID = @UserID
			, @Language = @Language
			, @IP = @IP
			, @ErrCode = @ErrCode_Cur OUTPUT 
			, @ErrMsg	= @ErrMsg_Cur OUTPUT
		
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		END
		ELSE
		BEGIN
			SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
		END
	END
		
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_BetSetting] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_BetSetting] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_BetSetting] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterKeno_BetSetting] TO [vnteam] AS [dbo]