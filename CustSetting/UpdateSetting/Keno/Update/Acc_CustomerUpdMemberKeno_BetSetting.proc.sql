ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberKeno_BetSetting] 
	@custid				INT
	,@sporttype			INT = 202
	,@bettype			INT
	
	,@UpdateStatus		BIT = 0
	,@Disable			BIT = NULL

	--min/max/maxpermatch
	,@MinBet			MONEY = 0
	,@MaxBet			MONEY = 0
	,@MaxPerMatch		MONEY = 0
	,@UpdateMinMaxBet	BIT = 0

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
			,@DisableDownLines = 0
			,@SubAccID = @SubAccID
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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_BetSetting] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_BetSetting] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_BetSetting] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberKeno_BetSetting] TO [vnteam] AS [dbo]