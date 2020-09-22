/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberKeno_BetSetting] 
	@custid				INT
	,@sporttype			INT = 202
	,@bettype			INT
	
	,@UpdateStatus		BIT = 0
	,@Disable			BIT = NULL
	,@IsSC				BIT = 0
	
	--min/max/maxpermatch
	,@MinBet			MONEY = 0
	,@MaxBet			MONEY = 0
	,@MaxPerMatch		MONEY = 0
	,@UpdateMinMaxBet	BIT = 0
	, @SystemID			TINYINT=1
	,@SubAccID			INT = 0
	,@IP				VARCHAR(50) = ''
	,@UserID			INT = 0
	,@Language			VARCHAR(20) = 'E'
	,@ErrCode			VARCHAR(300) = '' OUTPUT
	,@ErrMsg			NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: Bobby
	Date: 20140319
	Task: Admin/Agent update setting keno on member
	DB: DBCUST/CustDB
		
	Revisions:
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]		
		- 20170303@Winnie: Change enable behavior [Redmine: #72336]
		- 20180312@Johnson: remove @DisableDownLines for new product status direction [redmine: #87328]
		- 20180525@Winnie: Inquiry Bet Limit Rule of Products -  [Redmine:95867]
		- 20200309@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
		- 20200610@Johnson: add param isSC to allow SC status from i7 [redmine:#135489]
		- 20200722@Eden: Minimize UM Time - Lock updating customer settings [#136464]
	Parameters Explanation:
		+@Disable: Status of bettype (0: enable,1: disable, NULL:nothing)
		+@IsUpdateMinMaxBet: check to update min/max (0:nothing, 1:update)
		+@aPositiontaking: check to update PT (NULL:nothing, else:update)
		+@discount: check to upate commision (NULL:nothing, else:update)
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @roleid TINYINT
		,@ErrCode_Cur INT
		,@ErrMsg_Cur NVARCHAR(4000)
		,@ErrAcc NVARCHAR(4000)

	SELECT @ErrCode_Cur = 0
		,@ErrMsg_Cur = ''
		,@ErrCode = ''
		,@ErrMsg = ''

	--> Check UM config
	EXEC [Acc_CheckUM] @CustID = @CustID, @ProductID = 8
		, @Language = @Language, @FunctionType = 1
		, @ErrCode = @ErrCode OUTPUT, @ErrMsg = @ErrMsg OUTPUT 
		, @ReturnUMData = 0
		
	IF @ErrCode <>0 
		RETURN

	SET @ErrCode = ''

	---------------------------
	-- ***Check Downline Belonging***
	EXEC dbo.Age_CustomerSelCheckBelonging @SessionCustID = @Userid
		,@Custid = @custid
		,@roleid = @roleid OUTPUT

	IF (@roleid = 0) RETURN

	            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END


	---------------------------
	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid
		,@ErrCode = @ErrCode_Cur OUTPUT
		,@ErrMsg = @ErrMsg_Cur OUTPUT

	IF @ErrCode_Cur > 0
	BEGIN
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
			,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

		RETURN
	END

	--update status
	IF(@UpdateStatus = 1
		AND @Disable IS NOT NULL)
	BEGIN
		EXEC [Acc_CustomerUpdDisableKeno] 
			@CustID = @custid
			,@Bettype = @bettype
			,@Disable = @Disable			
			,@IsSC	= @IsSC
			
			,@SubAccID = @SubAccID
			, @SystemID=@SystemID
			,@UserID = @UserID
			,@Language = @Language
			,@IP = @IP
			,@Errcode = @ErrCode_Cur OUTPUT
			,@ErrMsg  = @ErrMsg_Cur OUTPUT

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

			RETURN
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)	
	END

	--update min/max/maxpermatch
	IF(@UpdateMinMaxBet = 1)
	BEGIN
				EXEC [Acc_CustomerUpdMemberKeno_MinMaxBet] 
			@custid = @custid
			,@bettype = @bettype

			,@MinBet	= @MinBet
			,@MaxBet	= @MaxBet
			,@MaxPerMatch = @MaxPerMatch
            ,@SubAccID = @SubAccID
			,@UserID = @UserID
			,@IP = @IP
			,@Language = @Language
			,@SystemID = @SystemID --20200309@Tiara
			,@ErrCode = @ErrCode_Cur OUTPUT
			,@ErrMsg = @ErrMsg_Cur OUTPUT

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

			RETURN
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)		
	END

	RETURN
END

GO
