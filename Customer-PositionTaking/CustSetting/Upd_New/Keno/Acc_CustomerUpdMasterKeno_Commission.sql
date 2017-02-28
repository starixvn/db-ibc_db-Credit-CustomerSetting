
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMasterKeno_Commission    Script Date: 8/21/2014 3:12:19 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMasterKeno_Commission    Script Date: 8/21/2014 2:58:11 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterKeno_Commission] 
(
    @CustId INT --Master
    , @Discount DECIMAL(9,8) = 0 --adiscount
    , @SportType INT = 202
    , @BetType INT
    
    , @SubAccID INT = 0 --Sub-AccountID
    , @UserID INT
    , @Language VARCHAR(10) = 'E'
    , @IP VARCHAR(21) = ''
    , @ErrCode INT = 0 OUTPUT
    , @ErrMsg NVARCHAR(200) = '' OUTPUT
)
AS
/*
    Created: 20140326@Patrick
    Task: Update master Keno setting - commission
    DB: DBTXN/CustDB
    
    Revisions:
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]		
    Parameters Explanation:
*/
BEGIN
    SET NOCOUNT ON

    IF @Discount = 0
        RETURN

    DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT, @username NVARCHAR(50)
        , @srecommend INT, @Old_adiscount DECIMAL(9,8), @roleid INT, @MaxDiscount DECIMAL(9,8)
    SET @startRun = GETDATE()

    SELECT @UserName = username, @srecommend = srecommend, @roleid = roleid
    FROM dbo.customer WITH (NOLOCK)
    WHERE CustID = @CustID
	
	         
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END

    SELECT @Old_adiscount = adiscount
    FROM dbo.CustSettingGame WITH (NOLOCK)
    WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType

    --check if not change setting
    IF @Old_adiscount = @discount RETURN

    --Get iif(adiscount > sdiscount, sdiscount, adiscount)
    SELECT @discount = CASE WHEN @discount > sdiscount THEN sdiscount ELSE @discount END
    FROM dbo.CustSettingGame AS cs WITH (NOLOCK)
    WHERE custid = @srecommend AND bettype = @BetType AND sporttype = @SportType

    -- apply exec rep
    EXEC Acc_CustSetting3rd_06 @CustId = @custid
        , @RoleId = @roleid
        , @discount = @discount
        , @mode = 'Keno'
        , @SportType = @SportType
        , @BetType = @BetType

    SELECT @endRun = GETDATE(), @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)
    DECLARE @LogSPData VARCHAR(MAX), @TrackingValueDB VARCHAR(4000)

    SELECT @LogSPData = '<Acc_CustomerUpdMasterKeno_Commission CustId="' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1))
        + '" ' + 'Discount="' + COALESCE(CAST(@Discount AS VARCHAR(50)), SPACE(1))
        + '" ' + 'SportType="' + COALESCE(CAST(@SportType AS VARCHAR(50)), SPACE(1))
        + '" ' + 'BetType="' + COALESCE(CAST(@BetType AS VARCHAR(50)), SPACE(1))
        + '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1)) 
        + '" ' + 'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
        + '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) 
        + '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) 
        + '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) 
        + '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

    SELECT @TrackingValueDB = '<Acc_CustomerUpdMasterKeno_Commission CustId="' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1))
        + '" ' + 'Discount="' + COALESCE(CAST(@Old_adiscount AS VARCHAR(50)), SPACE(1))
        + '" ' + 'SportType="' + COALESCE(CAST(@SportType AS VARCHAR(50)), SPACE(1))
        + '" ' + 'BetType="' + COALESCE(CAST(@BetType AS VARCHAR(50)), SPACE(1))
        + '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1)) 
        + '" ' + 'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
        + '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) 
        + '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) 
        + '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) 
        + '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

    --Log customer info 
    BEGIN TRY
        EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
            , @CustID = @CustID
            , @ActionID = 234
            , @TrackingValue = @LogSPData
            , @TrackingValue2 = @TrackingValueDB
            , @duration = @duration
    END TRY
    BEGIN CATCH
        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
            ,@CustID = @CustID
            ,@ActionID = 234
            ,@TrackingValue = @LogSPData
            ,@TrackingValue2 = @TrackingValueDB
            ,@duration = @duration
    END CATCH
END



GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterKeno_Commission] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_Commission] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_Commission] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_Commission] TO [bodbExtAccNet]
GO 
