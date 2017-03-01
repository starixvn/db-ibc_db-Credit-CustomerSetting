ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterHR_All]
    @custid int,
    @UserID int = 0,
    
    @v151spositiontaking_31 smallmoney = 0,
    @v151spositiontaking_32 smallmoney = 0,
    @v151spositiontaking_41 smallmoney=0,
    @v151spositiontaking_42 smallmoney=0,
    
    @v151spositiontaking_51 smallmoney=0,
    @v151spositiontaking_52 smallmoney=0,
    @v152spositiontaking_41 smallmoney=0,
    @v152spositiontaking_42 smallmoney=0,
    @v152spositiontaking_51 smallmoney=0,
    @v152spositiontaking_52 smallmoney=0,
    @v153spositiontaking_51 smallmoney=0,
    @v153spositiontaking_52 smallmoney=0,
    

    @auto_v151spositiontaking_31 smallmoney = 0,
    @auto_v151spositiontaking_32 smallmoney = 0,
    @auto_v151spositiontaking_41 smallmoney = 0,
    @auto_v151spositiontaking_42 smallmoney = 0,
    
    @auto_v151spositiontaking_51 smallmoney=0,
    @auto_v151spositiontaking_52 smallmoney=0,
    @auto_v152spositiontaking_41 smallmoney=0,
    @auto_v152spositiontaking_42 smallmoney=0,
    @auto_v152spositiontaking_51 smallmoney=0,
    @auto_v152spositiontaking_52 smallmoney=0,
    @auto_v153spositiontaking_51 smallmoney=0,
    @auto_v153spositiontaking_52 smallmoney=0,
    
    @isauto_v151spositiontaking_31 bit = 0,
    @isauto_v151spositiontaking_32 bit = 0,
    @isauto_v151spositiontaking_41 bit = 0,
    @isauto_v151spositiontaking_42 bit = 0,
    
    @isauto_v151spositiontaking_51 bit=0,
    @isauto_v151spositiontaking_52 bit=0,
    @isauto_v152spositiontaking_41 bit=0,
    @isauto_v152spositiontaking_42 bit=0,
    @isauto_v152spositiontaking_51 bit=0,
    @isauto_v152spositiontaking_52 bit=0,
    @isauto_v153spositiontaking_51 bit=0,
    @isauto_v153spositiontaking_52 bit=0,
    
    @v151mpositiontaking_31 smallmoney = 0,
    @v151mpositiontaking_32 smallmoney = 0,
    @v151mpositiontaking_41 smallmoney = 0,
    @v151mpositiontaking_42 smallmoney = 0,
    
    @v151mpositiontaking_51 smallmoney=0,
    @v151mpositiontaking_52 smallmoney=0,
    @v152mpositiontaking_41 smallmoney=0,
    @v152mpositiontaking_42 smallmoney=0,
    @v152mpositiontaking_51 smallmoney=0,
    @v152mpositiontaking_52 smallmoney=0,
    @v153mpositiontaking_51 smallmoney=0,
    @v153mpositiontaking_52 smallmoney=0,
    
    @UpdateDisable151_31 bit = 1, --@UpdateDisableHR -> @UpdateDisable151_31
    @UpdateDisable151_51 bit = 1,
    @UpdateDisable152_41 bit = 1,
    @UpdateDisable152_51 bit = 1,
    @UpdateDisable153_51 bit = 1,
    
    @UpdateCommission bit = 1,
    @UpdatePositiontaking bit = 1,
    @UpdateMinMaxBet151_31 bit = 1,--@UpdateMinMaxBet_31 -> @UpdateMinMaxBet151_31
    
    @UpdateDisable151_41 bit = 1,    --@UpdateDisableOpenTote -> @UpdateDisable151_41
    @UpdateMinMaxBet151_41 bit = 1, --@UpdateMinMaxBet_41 -> @UpdateMinMaxBet151_41
    @UpdateMinMaxBet151_51 bit = 1,
    @UpdateMinMaxBet152_41 bit = 1,
    @UpdateMinMaxBet152_51 bit = 1,
    @UpdateMinMaxBet153_51 bit = 1,
    
    @IsCopyPreset151_31 bit = 0,-- @IsCopyPreset_31 -> @IsCopyPreset151_31 Use for copy preset to member
    @IsCopyPreset151_41 bit = 0,--@IsCopyPreset_41 -> @IsCopyPreset151_41 Use for copy preset to member
    @IsCopyPreset151_51 bit = 0,
    @IsCopyPreset152_41 bit = 0,
    @IsCopyPreset152_51 bit = 0,
    @IsCopyPreset153_51 bit = 0,
    @updateallmembers bit = 0,
    @newspositiontaking smallmoney = 0,--equals max(s+m) - chosen(m)

    @Disable151_31 bit = true, --@DisableHorseracing -> @Disable151_31
    @Disable151_51 bit = true,
    @Disable152_41 bit = true,
    @Disable152_51 bit = true,
    @Disable153_51 bit = true,
    
    @DisableDownlines151_31 bit = true,-- @DisableDownline ->@DisableDownlines151_31
    @DisableDownlines151_51 bit = true,
    @DisableDownlines152_41 bit = true,
    @DisableDownlines152_51 bit = true,
    @DisableDownlines153_51 bit = true,
    
    @Disable151_41 bit, -- @DisableOpenTote -> @Disable151_41
    @DisableDownlines151_41 bit, -- @DisableDownlinesOpenTote -> @DisableDownlines151_41
    
    @v151minbet_31 money = 0,-- @minbet_31 -> @v151minbet_31
    @v151maxbet_31 money = 0,-- @maxbet_31 -> @v151maxbet_31
    @v151maxpermatch_31 money = 0,--@maxpermatch_31 -> @v151maxpermatch_31
    
    @v151minbet_41 money =0,--@minbet_41 -> @v151minbet_41
    @v151maxbet_41 money =0,--@maxbet_41 -> @v151maxbet_41
    @v151maxpermatch_41 money =0,--@maxpermatch_41 -> @v151maxpermatch_41 
    
    @v151minbet_51 money =0,
    @v151maxbet_51 money =0,
    @v151maxpermatch_51 money =0,
    
    @v152minbet_41 money =0,
    @v152maxbet_41 money =0,
    @v152maxpermatch_41 money =0,
    
    @v152minbet_51 money =0,
    @v152maxbet_51 money =0,
    @v152maxpermatch_51 money =0,
    
    @v153minbet_51 money =0,
    @v153maxbet_51 money =0,
    @v153maxpermatch_51 money =0,
    
    @v151discount_31 decimal(9,8) = 0,    
    @v151discount_41 decimal(9,8) = 0,
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
Created: 20090514@Phuc
Task : update HR setting(master).
DB: DBTXN/bodb02

Revisions:
    
    - 20090610@Phuc: copy super preset to member(s3->s1).
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
                        -120: Update Min/Max bet Harness AU)
    - 20090801@Shifu: check disabled user
    - 20100415@Shifu: OpenTote setting
    - 20110129@Henry: Add setting  
      + AU Horse racing  
      + UK, AU Greyhound racing  
      + AU Harness racing 
     - 20110323@Johnson: check @custid must be master's ID
     - 20110709@Johnson: Change to use new server BD053 instead DB052
     - 20111018@TOM: Apply Multiple Edit Racing PT.
     - 20111114@TOM: Change condition check Belonging from @roleid<>3 to @roleid=0.
                     Add parameter input @UpdatePositiontakingv151_31 => _51
                                @UpdatePositiontakingv152_41 => _51
    - 20130226@Johnson: change linked server DB053 to DBAGE        
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID)        
Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON
Declare @ErrCode_Cur int, @ErrMsg_Cur nvarchar(4000), @roleid tinyint
Select @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

EXEC Age_CustomerSelCheckBelongingByCustID
    @SessionCustID = @Userid, 
    @Custid = @custid,
    @Username = @Username OUTPUT,
    @roleid = @roleid OUTPUT
    if (@roleid = 0) return --return if not master

--Check disable user
EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
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
                EXEC dbo.Acc_CustomerUpdDisable151_31    -- Acc_CustomerUpdDisableHR -> Acc_CustomerUpdDisable151_31
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
                EXEC dbo.Acc_CustomerUpdDisable151_41 -- Acc_CustomerUpdDisableOpenTote -> Acc_CustomerUpdDisable151_41
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
        --return
    END
    ELSE
    BEGIN
        Select @ErrCode = @ErrCode + '-110'+char(7), @ErrMsg = @ErrMsg + char(7)
    END
END
--END

--Update Australian Horseracing status (allow/disallow)
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
            --return
        END
        ELSE
        BEGIN
            Select @ErrCode = @ErrCode + '-113'+char(7), @ErrMsg = @ErrMsg + char(7)
        END
    END
    
    --Update UK Greyhound status (allow/disallow)
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
            --return
        END
        ELSE
        BEGIN
            Select @ErrCode = @ErrCode + '-114'+char(7), @ErrMsg = @ErrMsg + char(7)
        END
    END
    
    --Update AU Greyhound status (allow/disallow)
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
            --return
        END
        ELSE
        BEGIN
            Select @ErrCode = @ErrCode + '-115'+char(7), @ErrMsg = @ErrMsg + char(7)
        END
    END
    
    --Update AU Harness status (allow/disallow)
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
            --return
        END
        ELSE
        BEGIN
            Select @ErrCode = @ErrCode + '-116'+char(7), @ErrMsg = @ErrMsg + char(7)
        END
    END
    
    


--Update Horseracing commission        
IF @UpdateCommission = 1 
BEGIN
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
                                                                EXEC dbo.Acc_CustomerUpdMaster_CommissionHR
        @custid=@custid, 
        @v151discount_31=@v151discount_31, 
        @v151discount_41=@v151discount_41, 
        @v151discount_51=@v151discount_51, 
        @v152discount_41=@v152discount_41, 
        @v152discount_51=@v152discount_51,
        @v153discount_51=@v153discount_51,
        @UpdateMultiple = @UpdateMultiple,
        @Updatediscountv151_31 = @Updatediscountv151_31,
        @Updatediscountv151_41 = @Updatediscountv151_41,
        @Updatediscountv151_51 = @Updatediscountv151_51,
        @Updatediscountv152_41 = @Updatediscountv152_41,
        @Updatediscountv152_51 = @Updatediscountv152_51,    
        @Updatediscountv153_51 = @Updatediscountv153_51,
        @UserID=@UserID,
        @SubAccID=@SubAccID, 
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
                EXEC dbo.Acc_CustomerUpdMaster_MinMaxBet151_31    -- Acc_CustomerUpdMaster_MinMaxBetHR -> Acc_CustomerUpdMaster_MinMaxBet151_31
        @custid=@custid, 
        @minbet=@v151minbet_31, 
        @maxbet=@v151maxbet_31, 
        @maxpermatch=@v151maxpermatch_31, 
        @UserID=@UserID, 
        @SubAccID=@SubAccID,
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
        Select @ErrCode = @ErrCode + '-112'+char(7), @ErrMsg = @ErrMsg + char(7)
    END
END
--end--


--Update OpenTote bet setting
IF @UpdateMinMaxBet151_41 = 1
BEGIN
                EXEC dbo.Acc_CustomerUpdMaster_MinMaxBet151_41 -- Acc_CustomerUpdMaster_MinMaxBetOpenTote -> Acc_CustomerUpdMaster_MinMaxBet151_41
        @custid=@custid, 
        @minbet=@v151minbet_41, 
        @maxbet=@v151maxbet_41, 
        @maxpermatch=@v151maxpermatch_41, 
        @UserID=@UserID, 
        @SubAccID=@SubAccID,
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
        Select @ErrCode = @ErrCode + '-111'+char(7), @ErrMsg = @ErrMsg + char(7)
    END
END
--end--

--Update Australian Horse bet setting
IF @UpdateMinMaxBet151_51 = 1
BEGIN
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
                EXEC dbo.Acc_CustomerUpdMaster_MinMaxBet151_51
        @custid=@custid, 
        @minbet=@v151minbet_51, 
        @maxbet=@v151maxbet_51, 
        @maxpermatch=@v151maxpermatch_51, 
        @UserID=@UserID, 
        @SubAccID=@SubAccID,
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
        Select @ErrCode = @ErrCode + '-117'+char(7), @ErrMsg = @ErrMsg + char(7)
    END
END
--end
    
--Update UK Greyhound bet setting
IF @UpdateMinMaxBet152_41 = 1
BEGIN
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
                EXEC dbo.Acc_CustomerUpdMaster_MinMaxBet152_41
        @custid=@custid, 
        @minbet=@v152minbet_41, 
        @maxbet=@v152maxbet_41, 
        @maxpermatch=@v152maxpermatch_41, 
        @UserID=@UserID, 
        @SubAccID=@SubAccID,
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
        Select @ErrCode = @ErrCode + '-118'+char(7), @ErrMsg = @ErrMsg + char(7)
    END
END
--end
    
--Update AU Greyhound bet setting
IF @UpdateMinMaxBet152_51 = 1
BEGIN
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
                EXEC dbo.Acc_CustomerUpdMaster_MinMaxBet152_51
        @custid=@custid, 
        @minbet=@v152minbet_51, 
        @maxbet=@v152maxbet_51, 
        @maxpermatch=@v152maxpermatch_51, 
        @UserID=@UserID, 
        @SubAccID=@SubAccID,
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
        Select @ErrCode = @ErrCode + '-119'+char(7), @ErrMsg = @ErrMsg + char(7)
    END
END
--end
    
--Update AU Harness betsetting
IF @UpdateMinMaxBet153_51 = 1
BEGIN
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
        EXEC dbo.Acc_CustomerUpdMaster_MinMaxBet153_51
        @custid=@custid, 
        @minbet=@v153minbet_51, 
        @maxbet=@v153maxbet_51, 
        @maxpermatch=@v153maxpermatch_51, 
        @UserID=@UserID, 
        @SubAccID=@SubAccID,
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
        Select @ErrCode = @ErrCode + '-120'+char(7), @ErrMsg = @ErrMsg + char(7)
    END
END
--end


--Update Horseracing positiontaking    
IF @newspositiontaking <> 0 
    SET @updateallmembers = 1

IF @UpdatePositiontaking = 1
BEGIN 
    Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
                                                                                                                                EXEC dbo.Acc_CustomerUpdMasterHR_Positiontaking
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
        @auto_v151spositiontaking_31 = @auto_v151spositiontaking_31,
        @auto_v151spositiontaking_32 = @auto_v151spositiontaking_32,
        @auto_v151spositiontaking_41 = @auto_v151spositiontaking_41,
        @auto_v151spositiontaking_42 = @auto_v151spositiontaking_42,
        @auto_v151spositiontaking_51 = @auto_v151spositiontaking_51,
        @auto_v151spositiontaking_52 = @auto_v151spositiontaking_52,
        @auto_v152spositiontaking_41 = @auto_v152spositiontaking_41,
        @auto_v152spositiontaking_42 = @auto_v152spositiontaking_42,
        @auto_v152spositiontaking_51 = @auto_v152spositiontaking_51,
        @auto_v152spositiontaking_52 = @auto_v152spositiontaking_52,
        @auto_v153spositiontaking_51 = @auto_v153spositiontaking_51,
        @auto_v153spositiontaking_52 = @auto_v153spositiontaking_52,
        @isauto_v151spositiontaking_31 = @isauto_v151spositiontaking_31,
        @isauto_v151spositiontaking_32 = @isauto_v151spositiontaking_32,
        @isauto_v151spositiontaking_41 = @isauto_v151spositiontaking_41,
        @isauto_v151spositiontaking_42 = @isauto_v151spositiontaking_42,
        @isauto_v151spositiontaking_51 = @isauto_v151spositiontaking_51,
        @isauto_v151spositiontaking_52 = @isauto_v151spositiontaking_52,
        @isauto_v152spositiontaking_41 = @isauto_v152spositiontaking_41,
        @isauto_v152spositiontaking_42 = @isauto_v152spositiontaking_42,
        @isauto_v152spositiontaking_51 = @isauto_v152spositiontaking_51,
        @isauto_v152spositiontaking_52 = @isauto_v152spositiontaking_52,
        @isauto_v153spositiontaking_51 = @isauto_v153spositiontaking_51,
        @isauto_v153spositiontaking_52 = @isauto_v153spositiontaking_52,
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
        @IsCopyPreset151_31 = @IsCopyPreset151_31,--Use for copy preset to member
        @IsCopyPreset151_41 = @IsCopyPreset151_41,--Use for copy preset to member
        @IsCopyPreset151_51 = @IsCopyPreset151_51,
        @IsCopyPreset152_41 = @IsCopyPreset152_41,
        @IsCopyPreset152_51 = @IsCopyPreset152_51,
        @IsCopyPreset153_51 = @IsCopyPreset153_51,
        @updateallmembers = @updateallmembers,
        @newspositiontaking = @newspositiontaking,
        
        @UpdateMultiple = @UpdateMultiple ,
        @UpdatePositiontakingv151_31 = @UpdatePositiontakingv151_31,
        @UpdatePositiontakingv151_41 = @UpdatePositiontakingv151_41,
        @UpdatePositiontakingv151_51 = @UpdatePositiontakingv151_51,
        @UpdatePositiontakingv152_41 = @UpdatePositiontakingv152_41,
        @UpdatePositiontakingv152_51 = @UpdatePositiontakingv152_51,
        @UpdatePositiontakingv153_51 = @UpdatePositiontakingv153_51,
                            
        @SubAccID = @SubAccID,
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
Return

GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterHR_All] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterHR_All] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterHR_All] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterHR_All] TO [bodbExtAccNet]
GO 
