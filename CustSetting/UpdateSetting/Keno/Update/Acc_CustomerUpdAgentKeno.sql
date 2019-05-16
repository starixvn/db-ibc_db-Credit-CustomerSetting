/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentKeno]
(
	@CustId INT --Agent
	, @SportType INT = 202
	, @BetType INT
	
	, @m2 SMALLMONEY --m2
	, @um2 SMALLMONEY --um2
	, @im2 BIT = 0 --im2
	, @a2 SMALLMONEY --a2
	, @n2 SMALLMONEY --n2
	, @UpdateAllMembers	BIT = 0
	, @NewMPositionTaking SMALLMONEY = 0 --equals max(m+a) - chosen(a)

	, @Discount DECIMAL(9,8) = 0
			
	, @UpdatePositiontaking	BIT = 0
	, @UpdateMinPositiontaking BIT = 0
	, @UpdateAutoPositionTaking	BIT = 0
	, @UpdateCommission BIT = 0
	
	, @SubAccID INT = 0 --Sub-AccountID
	, @UserID INT = 0
	, @Language varchar(2) = 'E'
	, @IP VARCHAR(15) = ''
	, @ErrCode VARCHAR(300)  = '' OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
)
AS
/*
	Created: 20140320@Patrick
	Task : Update Keno's Agent PT 
	DB: DBTXN/CustDB
	
	Revisions:
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]			
	
	Param's Explanation:
	• @ErrCode is:
			-101 update success commission
			-102 update success min PT
			-103 update success PT
	  
	• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @roleid TINYINT, @mrecommend INT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000)
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	--Check downline belonging
	EXEC dbo.Age_CustomerSelCheckBelonging @SessionCustID = @Userid
			, @Custid = @custid
			, @roleid = @roleid OUTPUT
	IF (@roleid = 0) RETURN

	 -- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103
		RETURN
	END
	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode = @ErrCode_Cur OUTPUT, @ErrMsg = @ErrMsg_Cur OUTPUT
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN
	END

	SELECT @mrecommend = mrecommend FROM CustInfo WITH (NOLOCK) WHERE custid = @Custid

	IF @UpdateCommission = 1
	BEGIN		
				EXEC dbo.Acc_CustomerUpdAgentKeno_Commission @custid = @custid
			, @sporttype = @sporttype
			, @bettype = @bettype
			, @discount = @discount
			, @IP = @IP
			, @UserID = @userid
			, @SubAccID = @SubAccID
			, @Language = @Language
			, @ErrCode = @ErrCode_Cur OUTPUT
			, @ErrMsg = @ErrMsg_Cur OUTPUT
	
		IF @ErrCode_Cur <> 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)		
	END

	IF(@UpdatePositiontaking = 1 OR @UpdateAutoPositionTaking = 1)
	BEGIN
				EXEC dbo.Acc_CustomerUpdAgentKeno_Positiontaking @custid = @custid
			, @sporttype = @sporttype
			, @bettype = @bettype
			, @m2 =  @m2--m2
			, @um2 = @um2 --um2
			, @im2 = @im2 --im2
			, @a2 = @a2 --a2
			, @n2 = @n2 --n2
	
			, @UpdateAllMembers	= @UpdateAllMembers
			, @NewMPositionTaking = @NewMPositionTaking --equals max(m+a) - chosen(a)
			, @UpdatePositiontaking = @UpdatePositiontaking
			, @UpdateMinPositiontaking = @UpdateMinPositiontaking
			, @UpdateAutoPositionTaking = @UpdateAutoPositionTaking

			, @IP = @IP
			, @SubAccID = @SubAccID
			, @UserID = @userid
			, @Language = @Language
			, @ErrCode = @ErrCode_Cur OUTPUT
			, @ErrMsg	= @ErrMsg_Cur OUTPUT
	
		IF @ErrCode_Cur <> 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN			
		END
		ELSE
		BEGIN
			SELECT @ErrCode = @ErrCode + '-103' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)		
		END
	END

	IF @UpdateMinPositiontaking = 1
	BEGIN
				EXEC dbo.Acc_CustOverrideUpdKeno @custid = @custid
			, @sporttype = @sporttype
			, @bettype = @bettype
			, @Min_Positiontaking = @n2
			, @UplineID = @mrecommend
			, @IP = @IP
			, @SubAccID = @SubAccID
			, @UserID = @userid
			, @Language = @Language
			, @ErrCode	= @ErrCode_Cur OUTPUT
			, @ErrMsg	= @ErrMsg_Cur OUTPUT
	
		IF @ErrCode_Cur <> 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN	
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)		
	END
END

GO