
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperKeno    Script Date: 8/21/2014 3:12:19 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperKeno    Script Date: 8/21/2014 2:58:11 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperKeno]
    @custid INT,-- superid    
    @sporttype INT = 202,
    @bettype INT,
    
    @s4 SMALLMONEY, --s4
    @n4 SMALLMONEY, --n4
    @Discount DECIMAL(9,8)=0,
            
    @UpdatePositiontaking    BIT = 0,
    @UpdateMinPositiontaking    BIT = 0,
    @UpdateCommission BIT = 0,
    
    @SubAccID INT = 0, --Sub-AccountID
    @UserID INT = 0,    
    @Language varchar(2) = 'E',
    @IP VARCHAR(15)='',
    @ErrCode VARCHAR(300)  = '' OUTPUT,
    @ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
    Created: 20140225@Elodie
    Task : Update Keno's Super PT 
    DB: DBCUST/CustDB
    
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
	
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103
		RETURN
	END
	
    --Check disable user
    EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
    IF @ErrCode_Cur > 0
    BEGIN
        select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
        return
    END
    --end

    --check n4<=s4
    IF @s4 < @n4
    BEGIN 
        Select @ErrMsg = 
                    case @Language 
                            when 'E' then 'Wrong position taking .<br>'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'
                    end, @ErrCode = 100
        return    
    END

    IF @UpdateCommission = 1
    BEGIN        
        EXEC Acc_CustomerUpdSuperKeno_Commission
            @custid = @custid,
            @sporttype = @sporttype,
            @bettype = @bettype,
            @discount = @discount,
            @IP = @IP,
            @SubAccID = @SubAccID,
            @UserID = @userid,
            @Language = @Language,
            @ErrCode = @ErrCode_Cur OUTPUT,
            @ErrMsg = @ErrMsg_Cur OUTPUT
    
        IF @ErrCode_Cur <> 0
        BEGIN
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
            RETURN    
        END
        ELSE
            SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)        
    END


    IF @UpdatePositiontaking = 1
    BEGIN
        EXEC Acc_CustomerUpdSuperKeno_Positiontaking
            @custid = @custid
          , @sporttype = @sporttype
          , @bettype = @bettype
          , @s4 = @s4
          , @IP = @IP
          , @SubAccID = @SubAccID
          , @UserID = @userid
          , @Language = @Language
          , @ErrCode = @ErrCode_Cur OUTPUT
          , @ErrMsg    = @ErrMsg_Cur OUTPUT

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
        EXEC Acc_CustOverrideUpdKeno
            @custid = @custid,
            @sporttype = @sporttype,
            @bettype = @bettype,
            @Min_Positiontaking = @n4,
            @IP = @IP,
            @SubAccID = @SubAccID,
            @UserID = @userid,
            @Language = @Language,
            @ErrCode = @ErrCode_Cur OUTPUT,
            @ErrMsg    = @ErrMsg_Cur OUTPUT
    
        IF @ErrCode_Cur <> 0
        BEGIN
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
            RETURN    
        END
        ELSE
            SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)        
    END
END


GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperKeno] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno] TO [bodbExtAccNet]
GO 
