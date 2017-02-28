USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdRBStatus]    Script Date: 06/10/2015 14:47:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdRBStatus    Script Date: 12/5/2013 5:35:48 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdRBStatus]
	@custid INT,
	@SubAccID INT = 0,
	@UserID INT,
	
	@UpdateDisable151_31 BIT = 0,
	@UpdateDisable151_41 BIT = 0,
	@UpdateDisable151_51 BIT = 0,
	@UpdateDisable152_41 BIT = 0,
	@UpdateDisable152_51 BIT = 0,
	@UpdateDisable153_51 BIT = 0,
	
	@Disable151_31 BIT = 0,
	@DisableDownlines151_31 BIT = 0 ,
	@Disable151_41 BIT = 0,
	@DisableDownlines151_41 BIT = 0 ,
	@Disable151_51 BIT = 0,
	@DisableDownlines151_51 BIT = 0 ,
	@Disable152_41 BIT = 0,
	@DisableDownlines152_41 BIT = 0 ,
	@Disable152_51 BIT = 0,
	@DisableDownlines152_51 BIT = 0 ,
	@Disable153_51 BIT = 0,
	@DisableDownlines153_51 BIT = 0,
	
	@Language VARCHAR(2) = 'E',
	@IP		VARCHAR(15) = '',
	@ErrCode VARCHAR(500) = '' OUTPUT,
	@ErrMsg VARCHAR(4000) = '' OUTPUT
	
 AS
/*
	Created: Johnson
	Date: 2011-03-15
	Task: Update status of Racing
	DB: DBTXN/BODB02
	
	Revisions:
		- 20110427@Johnson: change type of @SubAccID to INT
		- 20121206@Scott : Check Allowed downlines during peak hour at weekend 
		- 20130124@Scott : Update conditional when call sp  Acc_CustomerSelCheckAllowedDownlines
		- 20130227@Johnson: change linked server DB053 to DBAGE		
		- 20150609@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB) [Redmine:#36216]
		
	Notes:
		@ErrCode: Update Status Success:
				-109: disableHR
				-110: Disable HR OpenTote
				-113: Disable HR AU
				-114: Disable Greyhound UK
				-115: Disable Greyhound AU
				-116: Disable Harness AU
*/ 
SET NOCOUNT ON

 
DECLARE @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000)

-- Check Allowed downlines during peak hour at weekend 
DECLARE @roleid int

IF (
	(@UpdateDisable151_31 = 1 AND  (@Disable151_31 = 1 or (@Disable151_31 = 0 and @DisableDownlines151_31 = 0)))
	OR
	(@UpdateDisable151_41 = 1 AND  (@Disable151_41 = 1 or (@Disable151_41 = 0 and @DisableDownlines151_41 = 0)))
	OR
	(@UpdateDisable151_51 = 1 AND  (@Disable151_51 = 1 or (@Disable151_51 = 0 and @DisableDownlines151_51 = 0)))
	OR
	(@UpdateDisable152_41 = 1 AND  (@Disable152_41 = 1 or (@Disable152_41 = 0 and @DisableDownlines152_41 = 0)))
	OR
	(@UpdateDisable152_51 = 1 AND  (@Disable152_51 = 1 or (@Disable152_51 = 0 and @DisableDownlines152_51 = 0)))
	OR
	(@UpdateDisable153_51 = 1 AND  (@Disable153_51 = 1 or (@Disable153_51 = 0 and @DisableDownlines153_51 = 0)))
	)

BEGIN

	select @roleid = roleid 
	from custinfo with(nolock)
	where custid = @custid 





	EXEC dbo.Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
											@roleid=@roleid,
											@isExecRep=1,
											@Language=@Language,
											@ErrMsg=@ErrMsg output,
											@ErrCode=@ErrCode output
											
IF @ErrCode <>0 RETURN
END 
--End 



SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = '' 
 
IF @UpdateDisable151_31	= 1
BEGIN	
	Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''							
		EXEC dbo.Acc_CustomerUpdDisable151_31
		@custid=@custid, 
		@Disable151_31=@Disable151_31, 
		@DisableDownlines151_31=@DisableDownlines151_31,
		@UserID=@UserID, 
		@SubAccID=@SubAccID,
		@Language=@Language, 
		@ErrCode=@ErrCode_Cur output, 
		@ErrMsg=@ErrMsg_Cur output, 
		@IP=@IP
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	ELSE
	BEGIN
		Select @ErrCode = @ErrCode + '-109'+char(7), @ErrMsg = @ErrMsg + char(7)
	END
END 

 
IF @UpdateDisable151_41	= 1
BEGIN	
	Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''							
		EXEC dbo.Acc_CustomerUpdDisable151_41
		@custid=@custid, 
		@Disable151_41=@Disable151_41,
		@DisableDownlines151_41=@DisableDownlines151_41,
		@UserID=@UserID, 
		@SubAccID=@SubAccID,
		@Language=@Language, 
		@ErrCode=@ErrCode_Cur output, 
		@ErrMsg=@ErrMsg_Cur output, 
		@IP=@IP
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	ELSE
	BEGIN
		Select @ErrCode = @ErrCode + '-110'+char(7), @ErrMsg = @ErrMsg + char(7)
	END
END 
 
IF @UpdateDisable151_51 = 1
BEGIN
	Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''		
		EXEC dbo.Acc_CustomerUpdDisable151_51	
		@custid=@custid, 
		@Disable151_51=@Disable151_51, 
		@DisableDownlines151_51=@DisableDownlines151_51,
		@UserID=@UserID, 
		@SubAccID=@SubAccID,
		@Language=@Language, 
		@ErrCode=@ErrCode_Cur output, 
		@ErrMsg=@ErrMsg_Cur output, 
		@IP=@IP
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	ELSE
	BEGIN
		Select @ErrCode = @ErrCode + '-113'+char(7), @ErrMsg = @ErrMsg + char(7)
	END
END 

IF @UpdateDisable152_41 = 1
BEGIN
	Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''		
		EXEC dbo.Acc_CustomerUpdDisable152_41
		@custid=@custid, 
		@Disable152_41=@Disable152_41, 
		@DisableDownlines152_41=@DisableDownlines152_41,
		@UserID=@UserID, 
		@SubAccID=@SubAccID,
		@Language=@Language, 
		@ErrCode=@ErrCode_Cur output, 
		@ErrMsg=@ErrMsg_Cur output, 
		@IP=@IP
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	ELSE
	BEGIN
		Select @ErrCode = @ErrCode + '-114'+char(7), @ErrMsg = @ErrMsg + char(7)
	END
END

IF @UpdateDisable152_51 = 1
BEGIN
	Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''		
		EXEC dbo.Acc_CustomerUpdDisable152_51
		@custid=@custid, 
		@Disable152_51=@Disable152_51, 
		@DisableDownlines152_51=@DisableDownlines152_51,
		@UserID=@UserID, 
		@SubAccID=@SubAccID,
		@Language=@Language, 
		@ErrCode=@ErrCode_Cur output, 
		@ErrMsg=@ErrMsg_Cur output, 
		@IP=@IP
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	ELSE
	BEGIN
		Select @ErrCode = @ErrCode + '-115'+char(7), @ErrMsg = @ErrMsg + char(7)
	END
END

IF @UpdateDisable153_51 = 1
BEGIN
	Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''		
		EXEC dbo.Acc_CustomerUpdDisable153_51
		@custid=@custid, 
		@Disable153_51=@Disable153_51, 
		@DisableDownlines153_51=@DisableDownlines153_51,
		@UserID=@UserID, 
		@SubAccID=@SubAccID,
		@Language=@Language, 
		@ErrCode=@ErrCode_Cur output, 
		@ErrMsg=@ErrMsg_Cur output, 
		@IP=@IP
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	ELSE
	BEGIN
		Select @ErrCode = @ErrCode + '-116'+char(7), @ErrMsg = @ErrMsg + char(7)
	END
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdRBStatus] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdRBStatus] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdRBStatus] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdRBStatus] TO [vnteam] AS [dbo]