/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterKeno_BetSetting]
(
	@CustId INT --Master
	, @Sporttype INT = 202
	, @Bettype INT

	, @UpdateStatus BIT = 0
	, @Disable BIT = 1
		
	, @UpdateMinMaxBet BIT = 0
	, @MinBet MONEY
	, @MaxBet MONEY
	, @MaxPerMatch MONEY
	, @SystemID TINYINT=1
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
		- 20170303@Winnie: Change enable behavior [Redmine: #72336]
		- 20180312@Johnson: remove @DisableDownLines for new product status direction [redmine: #87328]
		- 20180525@Winnie: Inquiry Bet Limit Rule of Products -  [Redmine:95867]
		- 20200309@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
		- 20200722@Eden: Minimize UM Time - Lock updating customer settings [#136464]

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

	--> Check UM config
	EXEC [Acc_CheckUM] @CustID = @CustID, @ProductID = 8
		, @Language = @Language, @FunctionType = 1
		, @ErrCode = @ErrCode OUTPUT, @ErrMsg = @ErrMsg OUTPUT 
		, @ReturnUMData = 0
		
	IF @ErrCode <>0 
		RETURN

	SET @ErrCode = ''

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
			
			, @UserID = @UserID
			, @SubAccID = @SubAccID
			, @SystemID=@SystemID
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
			, @SystemID=@SystemID --20200309@Tiara
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
