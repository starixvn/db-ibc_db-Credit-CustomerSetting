ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberKeno] 
	@custid				INT
	,@sporttype			INT = 202
	,@bettype			INT
	
	,@UpdatePT			BIT = 0
	,@a1				SMALLMONEY = NULL

	--Update Commission
	,@UpdateComm		BIT = 0
	,@discount			DECIMAL(9, 8) = NULL

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
		+@UpdatePT: check to update PT (0:nothing, 1:update)
		+@UpdateComm: check to update Comm (0:nothing, 1:update)
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

	---------------------------
	 -- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103
		RETURN
	END
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
	IF(@UpdatePT = 1)
	BEGIN
		EXEC [dbo].[Acc_CustomerUpdMemberKeno_Positiontaking] 
			@CustID = @custid
			,@sporttype = @sporttype
			,@Bettype = @bettype

			,@apositiontaking = @a1

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

	--update commission
	IF(@UpdateComm = 1)
	BEGIN
		EXEC [dbo].[Acc_CustomerUpdMemberKeno_Commission]  
			@custid = @custid
			,@sporttype = @sporttype
			,@Bettype = @bettype

			,@discount	= @discount

			,@SubAccID = @SubAccID
			,@IP = @IP
			,@UserID = @UserID
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
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberKeno] TO [vnteam] AS [dbo]
GO