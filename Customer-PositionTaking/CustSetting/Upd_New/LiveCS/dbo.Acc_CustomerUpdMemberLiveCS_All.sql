ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberLiveCS_All]
	@custid		INT,
	@recommend	INT,
	@v162apositiontaking_1101	SMALLMONEY,
	@v162playerdiscount_1101	SMALLMONEY,
	
	@v162UpdatePositiontaking_1101	BIT,
	@v162UpdateCommission_1101	BIT,
	
	@SubAccID	INT = 0,
	@IP			VARCHAR(50)='',	
	@UserID		INT = 0,
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	VARCHAR(300) = '' OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT	
AS
	/*
		Created: Johnson
		Date: 17Jan2012
		Task: Admin/Agent update setting live casino on member
		DB: DBTXN/BODB02
		
		Revisions:
			- 20130301@Johnson: change linked server DB053 to DBAGE
			- 20150610@Elodie: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable, Change Age_CustomerSelCheckBelonging to Age_CustomerSelCheckBelongingByCustID]
		Parameters Explanation:
	*/
SET NOCOUNT ON 

DECLARE @roleid TINYINT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000)
SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

---------------------------
-- ***Check Downline Belonging***
EXEC Age_CustomerSelCheckBelongingByCustID
	@SessionCustID = @Userid, 
	@Custid = @custid,
	@roleid = @roleid OUTPUT
	IF (@roleid = 0) RETURN
---------------------------

--Check disable user
EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
	select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
--end

IF @v162UpdateCommission_1101 = 1
BEGIN
		EXEC Acc_CustomerUpdMemberLiveCS_Commission @custid = @custid, @v162playerdiscount_1101 = @v162playerdiscount_1101, @SubAccID = @SubAccID, @IP = @IP, @UserID = @UserID, @Language = @Language, @ErrCode = @ErrCode_Cur OUTPUT, @ErrMsg = @ErrMsg_Cur OUTPUT
	
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN	
	END
	ELSE
		SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)		
END

IF @v162UpdatePositiontaking_1101 = 1
BEGIN
		EXEC Acc_CustomerUpdMemberLiveCS_Positiontaking @custid = @custid, @v162apositiontaking_1101 = @v162apositiontaking_1101, @SubAccID = @SubAccID, @IP = @IP, @UserID = @UserID, @Language = @Language, @ErrCode = @ErrCode_Cur OUTPUT, @ErrMsg = @ErrMsg_Cur OUTPUT
	
	IF @ErrCode_Cur > 0 
	BEGIN
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN	
	END
	ELSE
		SELECT @ErrCode = @ErrCode + '-103' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)		

END


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_All] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_All] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_All] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberLiveCS_All] TO [vnteam] AS [dbo]