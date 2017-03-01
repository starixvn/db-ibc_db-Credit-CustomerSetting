USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdSuperHR_All]    Script Date: 06/10/2015 15:34:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperHR_All    Script Date: 8/28/2014 2:05:12 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperHR_All    Script Date: 8/21/2014 3:12:19 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperHR_All    Script Date: 8/21/2014 2:58:08 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperHR_All]
    @custid int,-- superid
    @UserID int = 0,
    
    @v151spositiontaking_31 smallmoney = 0,
    @v151spositiontaking_32 smallmoney = 0,
    @v151spositiontaking_41 smallmoney = 0,
    @v151spositiontaking_42 smallmoney = 0,

    @v151spositiontaking_51 smallmoney = 0,
    @v151spositiontaking_52 smallmoney = 0,

    @v152spositiontaking_41 smallmoney = 0,
    @v152spositiontaking_42 smallmoney = 0,
    @v152spositiontaking_51 smallmoney = 0,
    @v152spositiontaking_52 smallmoney = 0,

    @v153spositiontaking_51 smallmoney = 0,
    @v153spositiontaking_52 smallmoney = 0,
    
    @v151mpositiontaking_31 smallmoney = 0,
    @v151mpositiontaking_32 smallmoney = 0,
    @v151mpositiontaking_41 smallmoney = 0,
    @v151mpositiontaking_42 smallmoney = 0,

    @v151mpositiontaking_51 smallmoney = 0,
    @v151mpositiontaking_52 smallmoney = 0,

    @v152mpositiontaking_41 smallmoney = 0,
    @v152mpositiontaking_42 smallmoney = 0,
    @v152mpositiontaking_51 smallmoney = 0,
    @v152mpositiontaking_52 smallmoney = 0,

    @v153mpositiontaking_51 smallmoney = 0,
    @v153mpositiontaking_52 smallmoney = 0,

    @v151apositiontaking_31 smallmoney = 0,
    @v151apositiontaking_32 smallmoney = 0,
    @v151apositiontaking_41 smallmoney = 0,
    @v151apositiontaking_42 smallmoney = 0,
    
    @v151apositiontaking_51 smallmoney = 0,
    @v151apositiontaking_52 smallmoney = 0,

    @v152apositiontaking_41 smallmoney = 0,
    @v152apositiontaking_42 smallmoney = 0,
    @v152apositiontaking_51 smallmoney = 0,
    @v152apositiontaking_52 smallmoney = 0,

    @v153apositiontaking_51 smallmoney = 0,
    @v153apositiontaking_52 smallmoney = 0,

    @v151IBCPositiontaking_31 smallmoney = 0,--Auto PT for IBC(tote) 
    @v151IBCPositiontaking_41 smallmoney = 0,--Auto PT for IBC(fixed odd) 

    @v151IBCPositiontaking_51 smallmoney = 0,
    @v152IBCPositiontaking_41 smallmoney = 0,
    @v152IBCPositiontaking_51 smallmoney = 0,
    @v153IBCPositiontaking_51 smallmoney = 0,

    @UpdateCommission        bit = 1,
    @UpdatePositiontaking    bit = 1,
    
    @UpdateDisable151_31    bit = 1,    --- old name: @UpdateDisableHR
    @UpdateMinMaxBet151_31    bit = 1,    --- old name: @UpdateMinMaxBetHR
    
    @UpdateDisable151_41    bit = 1,    --- old name: @UpdateDisableOpentTote    
    @UpdateMinMaxBet151_41    bit = 1,    --- old name: @UpdateMinMaxBetOpentTote

    @UpdateDisable151_51    bit = 1,
    @UpdateMinMaxBet151_51    bit = 1,
    
    @UpdateDisable152_41    bit = 1,
    @UpdateMinMaxBet152_41    bit = 1,

    @UpdateDisable152_51    bit = 1,
    @UpdateMinMaxBet152_51    bit = 1,

    @UpdateDisable153_51    bit = 1,
    @UpdateMinMaxBet153_51    bit = 1,
    
    @Disable151_31            bit = true,        -- old name: @DisableHR
    @DisableDownlines151_31    bit = true,        -- old name: @DisableDownlineHR
    
    @Disable151_41            bit,              -- old name: @DisableOpentTote
    @DisableDownlines151_41 bit,               -- old name: @DisableDownlinesOpenTote

    @Disable151_51            bit = 0,
    @DisableDownlines151_51    bit = 0,

    @Disable152_41            bit = 0,
    @DisableDownlines152_41    bit = 0,

    @Disable152_51            bit = 0,
    @DisableDownlines152_51    bit = 0,

    @Disable153_51            bit = 0,
    @DisableDownlines153_51    bit = 0,
    
    @v151minbet_31            money = 0,    -- old name: @minbet_31
    @v151maxbet_31            money = 0,    -- old name: @maxbet_31
    @v151maxpermatch_31        money = 0,    -- old name: @maxpermatch_31
    
    @v151minbet_41            money,        -- old name: @minbet_41
    @v151maxbet_41            money,        -- old name: @maxbet_41
    @v151maxpermatch_41        money,        -- old name: @maxpermatch_41

    @v151minbet_51            money = 0,
    @v151maxbet_51            money = 0,
    @v151maxpermatch_51        money = 0,

    @v152minbet_41        money = 0,
    @v152maxbet_41        money = 0,
    @v152maxpermatch_41 money = 0,

    @v152minbet_51        money = 0,
    @v152maxbet_51        money = 0,
    @v152maxpermatch_51 money = 0,

    @v153minbet_51        money = 0,
    @v153maxbet_51        money = 0,
    @v153maxpermatch_51 money = 0,
    
    
    @v151discount_31 decimal(9,8) = 0,    
    @v151discount_41 decimal(9,8),

    @v151discount_51 decimal(9,8) = 0,
    @v152discount_41 decimal(9,8) = 0,
    @v152discount_51 decimal(9,8) = 0,
    @v153discount_51 decimal(9,8) = 0,    
    
    @SubAccID int = 0, --Sub-AccountID    
    @Language varchar(2) = 'E',
    @Username varchar(30) = '' OUTPUT,
    @ErrCode varchar(300) = '' OUTPUT,
    @ErrMsg nvarchar(4000) = '' OUTPUT,
    @IP varchar(15)=''
AS
/*
Created: 20090514@Phuc
Task : update HR setting(super).
DB: DBTXN/bodb02

Revisions:
    - 20090703@Phuc: enrich error message.(-101: general info, -102: closed, -103: suspended, 
                        - 104: credit, -105: commission, -106: min/max bet, -107: positiontaking
                        - 108: disable FI, -109: disableHR, 
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
                        -120: Update Min/Max bet Harness AU
    - 20100511@Shifu: update opentote setting
    - 20110111@Lukas: Add setting
                        + AU Horse racing
                        + UK, AU Greyhound racing
                        + AU Harness racing
    - 20110323@Johnson: check @custid must be super's ID
    - 20110709@Johnson: Change to use new server BD053 instead DB052
    - 20130227@Johnson: change linked server DB053 to DBAGE
    - 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID) [Redmine:#36216]
    
Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.

•    @vxxxMinbet_yy:
    xxx: sporttype        
        151: Horse racing
        152: Greyhound racing
        153: Harness racing
    yy: bettype (to represent the partner)
        41,42: UK/Irish
        51,52: AU (Australia)
        
*/

SET NOCOUNT ON
Declare @ErrCode_Cur int, @ErrMsg_Cur nvarchar(4000), @roleid tinyint
Select @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

EXEC dbo.Age_CustomerSelCheckBelongingByCustID 
    @SessionCustID = @Userid, 
    @Custid = @custid,
    @Username = @Username OUTPUT,
    @roleid = @roleid OUTPUT
    if (@roleid <> 4) return-- return if not super
    
--Check disable user
EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
    select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
            @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
    return
END
--end
    
--Update Horseracing status (allow/disallow)
IF @UpdateDisable151_31    = 1
BEGIN                                
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''        
                EXEC dbo.Acc_CustomerUpdDisable151_31    
        @custid                    = @custid, 
        @Disable151_31            = @Disable151_31, 
        @DisableDownlines151_31    = @DisableDownlines151_31,
        @UserID                    = @UserID,             
        @Language                = @Language, 
        @ErrCode                = @ErrCode_Cur output, 
        @ErrMsg                    = @ErrMsg_Cur output, 
        @IP                        = @IP
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


--Update Horseracing OpenTote status (allow/disallow)
IF @UpdateDisable151_41    = 1
BEGIN
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''        
                EXEC dbo.Acc_CustomerUpdDisable151_41
        @custid                    = @custid, 
        @Disable151_41            = @Disable151_41, 
        @DisableDownlines151_41    = @DisableDownlines151_41,
        @UserID                    = @UserID,
        @Language                = @Language, 
        @ErrCode                = @ErrCode_Cur output, 
        @ErrMsg                    = @ErrMsg_Cur output, 
        @IP                        = @IP
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
--END Horseracing OpenTote status

--Update AU Horseracing status (allow/disallow)
IF @UpdateDisable151_51    = 1
BEGIN                                
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''        
                EXEC dbo.Acc_CustomerUpdDisable151_51
        @custid                    = @custid, 
        @Disable151_51            = @Disable151_51, 
        @DisableDownlines151_51    = @DisableDownlines151_51,
        @UserID                    = @UserID,             
        @Language                = @Language, 
        @ErrCode                = @ErrCode_Cur OUTPUT, 
        @ErrMsg                    = @ErrMsg_Cur OUTPUT, 
        @IP                        = @IP
    IF @ErrCode_Cur > 0
    BEGIN
        SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7),
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
        --RETURN
    END
    ELSE
    BEGIN
        SELECT @ErrCode = @ErrCode + '-113'+ CHAR(7), @ErrMsg = @ErrMsg + char(7)
    END
END
--END AU Horseracing status

--Update UK Greyhound racing status (allow/disallow)
IF @UpdateDisable152_41    = 1
BEGIN                                
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''        
                EXEC dbo.Acc_CustomerUpdDisable152_41
        @custid                    = @custid, 
        @Disable152_41            = @Disable152_41, 
        @DisableDownlines152_41    = @DisableDownlines152_41,
        @UserID                    = @UserID,             
        @Language                = @Language, 
        @ErrCode                = @ErrCode_Cur OUTPUT, 
        @ErrMsg                    = @ErrMsg_Cur OUTPUT, 
        @IP                        = @IP
    IF @ErrCode_Cur > 0
    BEGIN
        SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7),
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
        --RETURN
    END
    ELSE
    BEGIN
        SELECT @ErrCode = @ErrCode + '-114'+ CHAR(7), @ErrMsg = @ErrMsg + char(7)
    END
END
--END UK Greyhound racing status

--Update AU Greyhound racing status (allow/disallow)
IF @UpdateDisable152_51    = 1
BEGIN                                
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''        
                EXEC dbo.Acc_CustomerUpdDisable152_51
        @custid                    = @custid, 
        @Disable152_51            = @Disable152_51, 
        @DisableDownlines152_51    = @DisableDownlines152_51,
        @UserID                    = @UserID,             
        @Language                = @Language, 
        @ErrCode                = @ErrCode_Cur OUTPUT, 
        @ErrMsg                    = @ErrMsg_Cur OUTPUT, 
        @IP                        = @IP
    IF @ErrCode_Cur > 0
    BEGIN
        SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7),
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
        --RETURN
    END
    ELSE
    BEGIN
        SELECT @ErrCode = @ErrCode + '-115'+ CHAR(7), @ErrMsg = @ErrMsg + char(7)
    END
END
--END AU Greyhound racing status

--Update AU Harness racing status (allow/disallow)
IF @UpdateDisable153_51    = 1
BEGIN                                
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''        
                EXEC dbo.Acc_CustomerUpdDisable153_51
        @custid                    = @custid, 
        @Disable153_51            = @Disable153_51, 
        @DisableDownlines153_51    = @DisableDownlines153_51,
        @UserID                    = @UserID,             
        @Language                = @Language, 
        @ErrCode                = @ErrCode_Cur OUTPUT, 
        @ErrMsg                    = @ErrMsg_Cur OUTPUT, 
        @IP                        = @IP
    IF @ErrCode_Cur > 0
    BEGIN
        SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7),
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
        --RETURN
    END
    ELSE
    BEGIN
        SELECT @ErrCode = @ErrCode + '-116'+ CHAR(7), @ErrMsg = @ErrMsg + char(7)
    END
END
--END AU Harness racing status


--Update Horseracing commission        
IF @UpdateCommission = 1 
BEGIN
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
                                                                EXEC dbo.Acc_CustomerUpdSuper_CommissionHR
        @custid=@custid, 
        @v151discount_31=@v151discount_31, 
        @v151discount_41=@v151discount_41,
        @v151discount_51=@v151discount_51,
        @v152discount_41=@v152discount_41,
        @v152discount_51=@v152discount_51,
        @v153discount_51=@v153discount_51,
        @UserID=@UserID,            
        @Language=@Language, 
        @IP=@IP,  
        @ErrCode=@ErrCode_Cur output, 
        @ErrMsg=@ErrMsg_Cur output
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
                EXEC dbo.Acc_CustomerUpdSuper_MinMaxBet151_31    
        @custid        = @custid, 
        @minbet        = @v151minbet_31, 
        @maxbet        = @v151maxbet_31, 
        @maxpermatch= @v151maxpermatch_31, 
        @UserID        = @UserID,
        @Language    = @Language, 
        @IP            = @IP, 
        @ErrCode    = @ErrCode_Cur output, 
        @ErrMsg        = @ErrMsg_Cur output
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
                EXEC dbo.Acc_CustomerUpdSuper_MinMaxBet151_41
        @custid        = @custid, 
        @minbet        = @v151minbet_41, 
        @maxbet        = @v151maxbet_41, 
        @maxpermatch= @v151maxpermatch_41, 
        @UserID        = @UserID,            
        @Language    = @Language, 
        @IP            = @IP, 
        @ErrCode    = @ErrCode_Cur output, 
        @ErrMsg        = @ErrMsg_Cur output
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

--Update AU Horse racing
IF @UpdateMinMaxBet151_51 = 1
BEGIN
                EXEC dbo.Acc_CustomerUpdSuper_MinMaxBet151_51
        @custid        = @custid, 
        @minbet        = @v151minbet_51, 
        @maxbet        = @v151maxbet_51, 
        @maxpermatch= @v151maxpermatch_51, 
        @UserID        = @UserID,
        @Language    = @Language, 
        @IP            = @IP, 
        @ErrCode    = @ErrCode_Cur output, 
        @ErrMsg        = @ErrMsg_Cur output
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
--end Update AU Horse racing

--Update UK Greyhound racing
IF @UpdateMinMaxBet152_41 = 1
BEGIN
                EXEC dbo.Acc_CustomerUpdSuper_MinMaxBet152_41
        @custid            =    @custid, 
        @minbet            =    @v152minbet_41, 
        @maxbet            =    @v152maxbet_41, 
        @maxpermatch    =    @v152maxpermatch_41, 
        @UserID            =    @UserID,            
        @Language        =    @Language, 
        @IP                =    @IP, 
        @ErrCode        =    @ErrCode_Cur output, 
        @ErrMsg            =    @ErrMsg_Cur output
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
--end update UK Greyhound racing

--Update AU Greyhound racing
IF @UpdateMinMaxBet152_51 = 1
BEGIN
                EXEC dbo.Acc_CustomerUpdSuper_MinMaxBet152_51
        @custid            =    @custid, 
        @minbet            =    @v152minbet_51, 
        @maxbet            =    @v152maxbet_51, 
        @maxpermatch    =    @v152maxpermatch_51, 
        @UserID            =    @UserID,            
        @Language        =    @Language, 
        @IP                =    @IP, 
        @ErrCode        =    @ErrCode_Cur output, 
        @ErrMsg            =    @ErrMsg_Cur output
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
--end update AU Greyhound racing

--Update AU Harness racing
IF @UpdateMinMaxBet153_51 = 1
BEGIN
                EXEC dbo.Acc_CustomerUpdSuper_MinMaxBet153_51
        @custid            =    @custid, 
        @minbet            =    @v153minbet_51, 
        @maxbet            =    @v153maxbet_51, 
        @maxpermatch    =    @v153maxpermatch_51, 
        @UserID            =    @UserID,            
        @Language        =    @Language, 
        @IP                =    @IP, 
        @ErrCode        =    @ErrCode_Cur output, 
        @ErrMsg            =    @ErrMsg_Cur output
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
--end Update AU Harness racing

--Update Horseracing positiontaking        
IF @UpdatePositiontaking = 1
BEGIN 
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
                                                                EXEC dbo.Acc_CustomerUpdSuperHR_Positiontaking
        @custid = @custid,
        @v151spositiontaking_31 = @v151spositiontaking_31,
        @v151spositiontaking_32 = @v151spositiontaking_32,
        @v151spositiontaking_41 = @v151spositiontaking_41,
        @v151spositiontaking_42 = @v151spositiontaking_42,
        @v151spositiontaking_51 = @v151spositiontaking_51,
        @v151spositiontaking_52 = @v151spositiontaking_52,
        @v152spositiontaking_41 = @v152spositiontaking_41,
        @v152spositiontaking_42 = @v152spositiontaking_42,
        @v152spositiontaking_51 = @v152spositiontaking_51,
        @v152spositiontaking_52 = @v152spositiontaking_52,
        @v153spositiontaking_51 = @v153spositiontaking_51,
        @v153spositiontaking_52 = @v153spositiontaking_52,

        @v151mpositiontaking_31 = @v151mpositiontaking_31,
        @v151mpositiontaking_32 = @v151mpositiontaking_32,
        @v151mpositiontaking_41 = @v151mpositiontaking_41,
        @v151mpositiontaking_42 = @v151mpositiontaking_42,
        @v151mpositiontaking_51 = @v151mpositiontaking_51,
        @v151mpositiontaking_52 = @v151mpositiontaking_52,
        @v152mpositiontaking_41 = @v152mpositiontaking_41,
        @v152mpositiontaking_42 = @v152mpositiontaking_42,
        @v152mpositiontaking_51 = @v152mpositiontaking_51,
        @v152mpositiontaking_52 = @v152mpositiontaking_52,
        @v153mpositiontaking_51 = @v153mpositiontaking_51,
        @v153mpositiontaking_52 = @v153mpositiontaking_52,

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

        @v151IBCPositiontaking_31 = @v151IBCPositiontaking_31,
        @v151IBCPositiontaking_41 = @v151IBCPositiontaking_41,
        @v151IBCPositiontaking_51 = @v151IBCPositiontaking_51,
        @v152IBCPositiontaking_41 = @v152IBCPositiontaking_41,
        @v152IBCPositiontaking_51 = @v152IBCPositiontaking_51,
        @v153IBCPositiontaking_51 = @v153IBCPositiontaking_51,
        @UserID = @UserID,
        @Language = @Language,
        @IP = @IP,
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

RETURN

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperHR_All] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperHR_All] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperHR_All] TO [vnteam] AS [dbo]