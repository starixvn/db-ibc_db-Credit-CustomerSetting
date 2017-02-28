ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberHR_All]
	@custid int, --MemberID
	@UserID int = 0,

	@v151apositiontaking_31 SMALLMONEY = 0,
	@v151apositiontaking_32 SMALLMONEY = 0,
	@v151apositiontaking_41 SMALLMONEY,
	@v151apositiontaking_42 SMALLMONEY,
	@v151apositiontaking_51 SMALLMONEY = 0,
	@v151apositiontaking_52 SMALLMONEY = 0,

	@v152apositiontaking_41 SMALLMONEY = 0,
	@v152apositiontaking_42 SMALLMONEY = 0,
	@v152apositiontaking_51 SMALLMONEY = 0,
	@v152apositiontaking_52 SMALLMONEY = 0,

	@v153apositiontaking_51 SMALLMONEY = 0,
	@v153apositiontaking_52 SMALLMONEY = 0,

	@UpdateDisable151_31	bit = 1,	-- old name: @UpdateDisableHR
	@UpdateCommission		bit = 1,
	@UpdatePositiontaking	bit = 1,
	@UpdateMinMaxBet151_31	bit = 1,    -- old name: @UpdateMinMaxBet_31
	
	@UpdateDisable151_41	bit = 1,	-- old name: @UpdateDisableOpenTote
	@UpdateMinMaxBet151_41	bit = 1,

	@Disable151_31			bit = 1,	-- old name: @DisableHorseracing
	@Disable151_41			bit,		-- old name: @DisableOpentTote

	@UpdateDisable151_51	bit = 1,
	@Disable151_51			bit = 1,
	@UpdateMinMaxBet151_51	bit = 1,	

	@UpdateDisable152_41	bit = 1,
	@Disable152_41			bit = 1,
	@UpdateMinMaxBet152_41	bit = 1,

	@UpdateDisable152_51	bit = 1,
	@Disable152_51			bit = 1,
	@UpdateMinMaxBet152_51	bit = 1,

	@UpdateDisable153_51	bit = 1,
	@Disable153_51			bit	= 1,
	@UpdateMinMaxBet153_51	bit	= 1,

	@v151minbet_31		money=0,			-- old name: @minbet_31
	@v151maxbet_31		money=0,			-- old name: @maxbet_31
	@v151maxpermatch_31 money=0,			-- old name: @maxpermatch_31
	
	@v151minbet_41		money = 0,		-- old name: @minbet_41
	@v151maxbet_41		money = 0,		-- old name: @maxbet_41
	@v151maxpermatch_41	money = 0,		-- old name: @maxpermatch_41

	@v151minbet_51		money = 0,
	@v151maxbet_51		money = 0,
	@v151maxpermatch_51	money = 0,

	@v152minbet_41		money = 0,
	@v152maxbet_41		money = 0,
	@v152maxpermatch_41	money = 0,

	@v152minbet_51		money = 0,
	@v152maxbet_51		money = 0,
	@v152maxpermatch_51 money = 0,

	@v153minbet_51		money = 0,
	@v153maxbet_51		money = 0,
	@v153maxpermatch_51 money = 0,
	
	@v151discount_31 decimal(9,8)=0,	
	@v151discount_41 decimal(9,8),
	@v151discount_51 decimal(9,8) = 0,
	@v152discount_41 decimal(9,8) = 0,
	@v152discount_51 decimal(9,8) = 0,
	@v153discount_51 decimal(9,8) = 0,

	@UpdateMultiple BIT = 0,
	@UpdatePositiontakingv151_31 BIT = 1,
	@UpdatePositiontakingv151_41 BIT = 1,
	@UpdatePositiontakingv151_51 BIT = 1,
	@UpdatePositiontakingv152_41 BIT = 1,
	@UpdatePositiontakingv152_51 BIT = 1,
	@UpdatePositiontakingv153_51 BIT = 1,	
	@Updatediscountv151_31 BIT = 1,
	@Updatediscountv151_41 BIT = 1,
	@Updatediscountv151_51 BIT = 1,
	@Updatediscountv152_41 BIT = 1,
	@Updatediscountv152_51 BIT = 1,	
	@Updatediscountv153_51 BIT = 1,	
		
	@SubAccID int = 0, --Sub-AccountID	
	@Language varchar(2) = 'E',
	@Username varchar(30) = '' OUTPUT,
	@ErrCode varchar(300) = '' OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT,
	@IP varchar(15)=''
AS
/*
Created: 20090518@Phuc
Task : update HR setting(member).
DB: DBTRANS.bodb02

Revisions:
	
	- 20090703@Phuc: enrich error message.(-101: general info, -102: closed, -103: suspended, 
						-104: credit, -105: commission, -106: min/max bet, -107: positiontaking
						-108: disable FI, -109: disableHR
						-110: Disable HR OpenTote
						-113: Disable HR AU
						-114: Disable Greyhound UK
						-115: Disable Greyhound AU
						-116: Disable Harness AU
						-112: Update Min/Max bet HR SA Tote
						-111: Update Min/Max bet HR OpentTote
						-117: Update Min/Max bet HR AU
						-118: Update Min/Max bet GreyHound UK
						-119: Update Min/Max bet Greyhound AU
						-120: Update Min/Max bet Harness AU )
	- 20090801@Shifu: check disabled user
	- 20100415@Shifu: OpenTote
	- 20110111@Lukas: Add setting
						+ AU Horse racing
						+ UK, AU Greyhound racing
						+ AU Harness racing
	- 20110323@Johnson: check @custid must be member's ID
	- 20110428@Lukas: change Acc_CustomerUpdMember_MinMaxBetHR -> Acc_CustomerUpdMember_MinMaxBet151_31
	- 20110709@Johnson: Change to use new server BD053 instead DB052	
	- 20111017@TOM: Apply Multiple Edit Racing PT.
	- 20111115@TOM: Add parameter input @UpdatePositiontakingv151_31 => _51
								@UpdatePositiontakingv152_41 => _51	
	- 20130227@Johnson: change linked server DB053 to DBAGE
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID)

Param's Explanation:
â€¢ @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
â€¢ @ErrMsg: Error description.
*/

SET NOCOUNT ON
Declare @ErrCode_Cur int, @ErrMsg_Cur nvarchar(4000), @roleid tinyint
Select @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

EXEC Age_CustomerSelCheckBelongingByCustID
	@SessionCustID = @Userid, 
	@Custid = @custid,
	@Username = @Username OUTPUT,
	@roleid = @roleid OUTPUT
	if (@roleid <> 1) return

--Check disable user
EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
	select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
--end

BEGIN
	--Update Horseracing status (allow/disallow)	
	IF @UpdateDisable151_31 = 1 
	BEGIN								
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''		
								EXEC dbo.Acc_CustomerUpdDisable151_31
			@custid			= @custid, 
			@Disable151_31	= @Disable151_31, 
			@UserID			= @UserID, 
			@SubAccID		= @SubAccID,
			@Language		= @Language, 
			@ErrCode		= @ErrCode_Cur output, 
			@ErrMsg			= @ErrMsg_Cur output, 
			@IP				= @IP
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			--return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-109'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end--	
	
	--Update Horseracing OpenTote status (allow/disallow)	
	IF @UpdateDisable151_41 = 1 
	BEGIN								
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''		
								EXEC dbo.Acc_CustomerUpdDisable151_41
			@custid			= @custid, 
			@Disable151_41	= @Disable151_41, 
			@UserID			= @UserID, 
			@SubAccID		= @SubAccID,
			@Language		= @Language, 
			@ErrCode		= @ErrCode_Cur output, 
			@ErrMsg			= @ErrMsg_Cur output, 
			@IP				= @IP
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			--return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-110'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end--	

	--Update AU Horseracing status (allow/disallow)	
	IF @UpdateDisable151_51 = 1 
	BEGIN								
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''		
								EXEC dbo.Acc_CustomerUpdDisable151_51	
			@custid			= @custid, 
			@Disable151_51	= @Disable151_51, 
			@UserID			= @UserID, 
			@SubAccID		= @SubAccID,
			@Language		= @Language, 
			@ErrCode		= @ErrCode_Cur output, 
			@ErrMsg			= @ErrMsg_Cur output, 
			@IP				= @IP
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			--return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-113'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end update AU Horseracing status

	--Update UK Greyhound status (allow/disallow)	
	IF @UpdateDisable152_41 = 1 
	BEGIN								
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''		
								EXEC dbo.Acc_CustomerUpdDisable152_41	
			@custid			= @custid, 
			@Disable152_41	= @Disable152_41, 
			@UserID			= @UserID, 
			@SubAccID		= @SubAccID,
			@Language		= @Language, 
			@ErrCode		= @ErrCode_Cur output, 
			@ErrMsg			= @ErrMsg_Cur output, 
			@IP				= @IP
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			--return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-114'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end update UK Greyhound status
	
	--Update AU Greyhound status (allow/disallow)	
	IF @UpdateDisable152_51 = 1 
	BEGIN								
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''		
								EXEC dbo.Acc_CustomerUpdDisable152_51	
			@custid			= @custid, 
			@Disable152_51	= @Disable152_51, 
			@UserID			= @UserID, 
			@SubAccID		= @SubAccID,
			@Language		= @Language, 
			@ErrCode		= @ErrCode_Cur output, 
			@ErrMsg			= @ErrMsg_Cur output, 
			@IP				= @IP
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			--return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-115'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end update AU Greyhound status

	--Update AU Harness status (allow/disallow)	
	IF @UpdateDisable153_51 = 1 
	BEGIN								
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''		
								EXEC dbo.Acc_CustomerUpdDisable153_51	
			@custid			= @custid, 
			@Disable153_51	= @Disable153_51, 
			@UserID			= @UserID, 
			@SubAccID		= @SubAccID,
			@Language		= @Language, 
			@ErrCode		= @ErrCode_Cur output, 
			@ErrMsg			= @ErrMsg_Cur output, 
			@IP				= @IP
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			--return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-116'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end update AU Harness status

	--Update Horseracing commission	
	IF @UpdateCommission = 1 
	BEGIN
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
								EXEC dbo.Acc_CustomerUpdMember_CommissionHR	
			@custid			= @custid, 
			@v151discount_31= @v151discount_31, 
			@v151discount_41= @v151discount_41, 
			@v151discount_51= @v151discount_51,
			@v152discount_41= @v152discount_41,
			@v152discount_51= @v152discount_51,
			@v153discount_51= @v153discount_51,
			@UpdateMultiple = @UpdateMultiple,
			@Updatediscountv151_31 = @Updatediscountv151_31,
			@Updatediscountv151_41 = @Updatediscountv151_41,
			@Updatediscountv151_51 = @Updatediscountv151_51,
			@Updatediscountv152_41 = @Updatediscountv152_41,
			@Updatediscountv152_51 = @Updatediscountv152_51,	
			@Updatediscountv153_51 = @Updatediscountv153_51,			
			@UserID			= @UserID, 
			@SubAccID		= @SubAccID,
			@Language		= @Language, 
			@IP				= @IP,  
			@ErrCode		= @ErrCode_Cur output, 
			@ErrMsg			= @ErrMsg_Cur output
			
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-105'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end--

	--Update bet setting
	IF @UpdateMinMaxBet151_31 = 1
	BEGIN
								EXEC dbo.Acc_CustomerUpdMember_MinMaxBet151_31	
			@custid		= @custid, 
			@minbet		= @v151minbet_31, 
			@maxbet		= @v151maxbet_31, 
			@maxpermatch= @v151maxpermatch_31, 
			@UserID		= @UserID, 
			@SubAccID	= @SubAccID,
			@Language	= @Language, 
			@IP			= @IP, 
			@ErrCode	= @ErrCode_Cur output, 
			@ErrMsg		= @ErrMsg_Cur output
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-112'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end--
	
	--Update OpenTote bet setting
	IF @UpdateMinMaxBet151_41 = 1
	BEGIN
								EXEC dbo.Acc_CustomerUpdMember_MinMaxBet151_41
			@custid		= @custid, 
			@minbet		= @v151minbet_41, 
			@maxbet		= @v151maxbet_41, 
			@maxpermatch= @v151maxpermatch_41, 
			@UserID		= @UserID, 
			@SubAccID	= @SubAccID,
			@Language	= @Language, 
			@IP			= @IP, 
			@ErrCode	= @ErrCode_Cur output, 
			@ErrMsg		= @ErrMsg_Cur output
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-111'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end--
	
	--Update AU Horse racing bet setting
	IF @UpdateMinMaxBet151_51 = 1
	BEGIN
								EXEC dbo.Acc_CustomerUpdMember_MinMaxBet151_51	
			@custid		= @custid, 
			@minbet		= @v151minbet_51, 
			@maxbet		= @v151maxbet_51, 
			@maxpermatch= @v151maxpermatch_51,
			@UserID		= @UserID, 
			@SubAccID	= @SubAccID,
			@Language	= @Language, 
			@IP			= @IP, 
			@ErrCode	= @ErrCode_Cur output, 
			@ErrMsg		= @ErrMsg_Cur output
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-117'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end--

	--Update UK Greyhound racing bet setting
	IF @UpdateMinMaxBet152_41 = 1
	BEGIN
								EXEC dbo.Acc_CustomerUpdMember_MinMaxBet152_41	
			@custid		= @custid, 
			@minbet		= @v152minbet_41, 
			@maxbet		= @v152maxbet_41, 
			@maxpermatch= @v152maxpermatch_41,
			@UserID		= @UserID, 
			@SubAccID	= @SubAccID,
			@Language	= @Language, 
			@IP			= @IP, 
			@ErrCode	= @ErrCode_Cur output, 
			@ErrMsg		= @ErrMsg_Cur output
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-118'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end--

	--Update AU Greyhound racing bet setting
	IF @UpdateMinMaxBet152_51 = 1
	BEGIN
								EXEC dbo.Acc_CustomerUpdMember_MinMaxBet152_51	
			@custid		= @custid, 
			@minbet		= @v152minbet_51, 
			@maxbet		= @v152maxbet_51, 
			@maxpermatch= @v152maxpermatch_51,
			@UserID		= @UserID, 
			@SubAccID	= @SubAccID,
			@Language	= @Language, 
			@IP			= @IP, 
			@ErrCode	= @ErrCode_Cur output, 
			@ErrMsg		= @ErrMsg_Cur output
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-119'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end--

	--Update AU Harness racing bet setting
	IF @UpdateMinMaxBet153_51 = 1
	BEGIN
								EXEC dbo.Acc_CustomerUpdMember_MinMaxBet153_51	
			@custid		= @custid, 
			@minbet		= @v153minbet_51, 
			@maxbet		= @v153maxbet_51, 
			@maxpermatch= @v153maxpermatch_51,
			@UserID		= @UserID, 
			@SubAccID	= @SubAccID,
			@Language	= @Language, 
			@IP			= @IP, 
			@ErrCode	= @ErrCode_Cur output, 
			@ErrMsg		= @ErrMsg_Cur output
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-120'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	--end--

	--Update PT for HR
	IF @UpdatePositiontaking = 1
	BEGIN
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
								EXEC dbo.Acc_CustomerUpdMemberHR_PositionTaking 
			@custid = @custid,
			@v151apositiontaking_31 = @v151apositiontaking_31,
			@v151apositiontaking_32 = @v151apositiontaking_32,
			@v151apositiontaking_41 = @v151apositiontaking_41,
			@v151apositiontaking_42 = @v151apositiontaking_42,
			@v151apositiontaking_51 = @v151apositiontaking_51,
			@v151apositiontaking_52 = @v151apositiontaking_52,
			@v152apositiontaking_41 = @v152apositiontaking_41,
			@v152apositiontaking_42 = @v152apositiontaking_42,
			@v152apositiontaking_51 = @v152apositiontaking_51,
			@v152apositiontaking_52 = @v152apositiontaking_52,
			@v153apositiontaking_51 = @v153apositiontaking_51,
			@v153apositiontaking_52 = @v153apositiontaking_52,
			@UpdateMultiple = @UpdateMultiple ,
			@UpdatePositiontakingv151_31 = @UpdatePositiontakingv151_31,
			@UpdatePositiontakingv151_41 = @UpdatePositiontakingv151_41,
			@UpdatePositiontakingv151_51 = @UpdatePositiontakingv151_51,
			@UpdatePositiontakingv152_41 = @UpdatePositiontakingv152_41,
			@UpdatePositiontakingv152_51 = @UpdatePositiontakingv152_51,
			@UpdatePositiontakingv153_51 = @UpdatePositiontakingv153_51,			
			@UserID = @UserID,
			@IP = @IP,
			@Language = @Language,
			@SubAccID = @SubAccID,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
		
	END
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberHR_All] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberHR_All] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberHR_All] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberHR_All] TO [vnteam] AS [dbo]