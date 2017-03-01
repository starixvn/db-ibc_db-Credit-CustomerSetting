USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdSuperLiveCS_All]    Script Date: 06/10/2015 15:59:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperLiveCS_All    Script Date: 8/28/2014 2:05:19 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperLiveCS_All    Script Date: 8/21/2014 3:12:19 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperLiveCS_All    Script Date: 8/21/2014 2:58:09 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperLiveCS_All]
    @custid        INT,        
    
    @v162spositiontaking_1101        SMALLMONEY,
    @v162spositiontaking_1101_min    SMALLMONEY,
    @v162discount_1101            SMALLMONEY,
    
    @v162UpdatePositiontaking_1101 BIT = 1,
    @v162UpdateMinPositiontaking_1101 BIT = 1,
    @v162UpdateCommission_1101 BIT = 1,
    
    @IP            VARCHAR(50)='',    
    @UserID        INT = 0,
    @Language    VARCHAR(20) = 'E',        
    @ErrCode    VARCHAR(300) = '' OUTPUT,
    @ErrMsg        NVARCHAR(4000) = '' OUTPUT
    
AS
    /*
        Created: Johnson
        Date: 26Dec2011
        Task: Company updates live casino setting on super
        DB: DBTXN/BODB02
        
        Revisions:
            - 20120914@Johnson: update pt first then min pt
            - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
            - 20130301@Johnson: change linked server DB053 to DBAGE 
            - 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID, temp sport, bettype table) [Redmine:#36216]
        Parameters Explanation:
    */
SET NOCOUNT ON 


DECLARE @roleid TINYINT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000)
SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

---------------------------
-- ***Check Downline Belonging***
EXEC dbo.Age_CustomerSelCheckBelongingByCustID
    @SessionCustID = @Userid, 
    @Custid = @custid,
    @roleid = @roleid OUTPUT
    IF (@roleid = 0) RETURN
---------------------------

--Check disable user
EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
    select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
            @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
    return
END
--end


--check n4<=s4
IF @v162spositiontaking_1101 < @v162spositiontaking_1101_min
BEGIN 
    Select @ErrMsg = 
                case @Language 
                        when 'E' then 'Wrong position taking .<br>'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'
                end, @ErrCode = 100
    return    
END

IF @v162UpdateCommission_1101 = 1
BEGIN        
                                                                                                                                EXEC Acc_CustomerUpdSuperLiveCS_Commission @custid = @custid, @v162discount_1101 = @v162discount_1101, @IP = @IP ,@UserID = @userid, @Language = @Language, @ErrCode = @ErrCode_Cur OUTPUT, @ErrMsg    =@ErrMsg_Cur OUTPUT
    
    IF @ErrCode_Cur <> 0
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
                                                                                                                                EXEC Acc_CustomerUpdSuperLiveCS_Positiontaking @custid = @custid, @v162spositiontaking_1101 = @v162spositiontaking_1101, @IP = @IP ,@UserID = @userid, @Language = @Language, @ErrCode    = @ErrCode_Cur OUTPUT, @ErrMsg    = @ErrMsg_Cur OUTPUT
    
    IF @ErrCode_Cur <> 0
    BEGIN
        SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
            @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
        RETURN    
    END
    ELSE
        SELECT @ErrCode = @ErrCode + '-103' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)        
END


IF @v162UpdateMinPositiontaking_1101 = 1
BEGIN
                                                                                                                                EXEC Acc_CustOverrideUpdLiveCS @custid = @custid, @min_v162positiontaking_1101 = @v162spositiontaking_1101_min, @IP = @IP ,@UserID = @userid, @Language = @Language, @ErrCode    = @ErrCode_Cur OUTPUT, @ErrMsg    =@ErrMsg_Cur OUTPUT
    
    IF @ErrCode_Cur <> 0
    BEGIN
        SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
            @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
        RETURN    
    END
    ELSE
        SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)        
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperLiveCS_All] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperLiveCS_All] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperLiveCS_All] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperLiveCS_All] TO [vnteam] AS [dbo]