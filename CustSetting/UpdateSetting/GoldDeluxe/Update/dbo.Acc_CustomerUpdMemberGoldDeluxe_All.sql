USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberGoldDeluxe_All]    Script Date: 05/12/2015 13:22:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberGoldDeluxe_All]
	@custid		INT,
	@recommend	INT,
	@v255apositiontaking_1701	SMALLMONEY,
	@v255playerdiscount_1701	SMALLMONEY,
	
	@v255UpdatePositiontaking_1701	BIT = 1,
	@v255UpdateCommission_1701		BIT = 1,
	
	@SubAccID	INT = 0,
	@IP			VARCHAR(50)='',	
	@UserID		INT = 0,
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	VARCHAR(300) = '' OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT	
AS
/*
	Created: Elodie
	Date: 20150422
	Task: Admin/Agent update setting Gold Deluxe on member
	DB: DBTXN/CustDB
		
	Revisions:
		- 20150610@Elodie: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable to DBCUST, Change Age_CustomerSelCheckBelonging to Age_CustomerSelCheckBelongingByCustID)
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]	

	Parameters Explanation:
*/
BEGIN
	SET NOCOUNT ON 

	DECLARE @roleid TINYINT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000)
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	---------------------------
	-- ***Check Downline Belonging***
	EXEC Age_CustomerSelCheckBelonging 
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

	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
	IF @v255UpdateCommission_1701 = 1
	BEGIN
								EXEC Acc_CustomerUpdMemberGoldDeluxe_Commission @custid = @custid, @v255playerdiscount_1701 = @v255playerdiscount_1701, @SubAccID = @SubAccID, @IP = @IP, @UserID = @UserID, @Language = @Language, @ErrCode = @ErrCode_Cur OUTPUT, @ErrMsg = @ErrMsg_Cur OUTPUT
	
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN	
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)		
	END

	IF @v255UpdatePositiontaking_1701 = 1
	BEGIN
								EXEC Acc_CustomerUpdMemberGoldDeluxe_Positiontaking @custid = @custid, @v255apositiontaking_1701 = @v255apositiontaking_1701, @SubAccID = @SubAccID, @IP = @IP, @UserID = @UserID, @Language = @Language, @ErrCode = @ErrCode_Cur OUTPUT, @ErrMsg = @ErrMsg_Cur OUTPUT
	
		IF @ErrCode_Cur > 0 
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN	
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-103' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)		

	END
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberGoldDeluxe_All] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberGoldDeluxe_All] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberGoldDeluxe_All] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberGoldDeluxe_All] TO [vnteam] AS [dbo]