ALTER PROCEDURE [dbo].[Acc_CustOverrideUpdGoldDeluxe]
    @custid							INT,
    @UplineID						INT = 0,
    @min_v255positiontaking_1701    SMALLMONEY,
    
    @SubAccID						INT = 0 ,
    @UserID							INT = 0    ,
    @IP								VARCHAR(50)= '',    
    @Language						VARCHAR(20) = 'E',        
    
    @ErrCode						VARCHAR(300) = '' OUTPUT,
    @ErrMsg							NVARCHAR(4000) = '' OUTPUT
AS
/*
    Created: Elodie
    Date: 20150422
    Task: Update min positiontaking
    DB: DBTXN/CustDB
        
    Revisions:
		- 20150610@Elodie: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable, Acc_CustomerSelCheckAllowedDownlines to DBCUST, Change Age_CustomerSelCheckBelonging to Age_CustomerSelCheckBelongingByCustID)
		- 20151007@Elodie: Remove code to check old and new value
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
    Parameters Explanation:
*/
BEGIN
	SET NOCOUNT ON
        
    DECLARE @startRun DATETIME
    DECLARE @endRun DATETIME
    DECLARE @duration INT
    SET @startRun = GETDATE()

    DECLARE @roleid TINYINT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000)
    DECLARE @old_min_v255positiontaking_1701 SMALLMONEY
    
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
                
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
    --Check Allowed downlines    
    EXEC Acc_CustomerSelCheckAllowedDownlines    
				@custid=@custid,
                @roleid=@roleid,
                @isExecRep=1,
                @isUpdatePT = 1,
                @Sporttype = 1,
                @Language='E',
                @ErrMsg=@ErrMsg output,
                @ErrCode=@ErrCode output
    IF @ErrCode <> 0 
        RETURN 
    
    SELECT @old_min_v255positiontaking_1701 = minpositiontaking
    FROM CustOverrideGame WITH(NOLOCK)
    WHERE custid = @custid AND sporttype = 255 AND bettype = 1701
    
    --IF @old_min_v255positiontaking_1701 = @min_v255positiontaking_1701
    --    RETURN     
    
    UPDATE CustOverrideGame WITH(UPDLOCK, ROWLOCK)
    SET minpositiontaking = @min_v255positiontaking_1701
    WHERE custid = @custid AND sporttype = 255 AND bettype = 1701

    IF @roleid = 4
    BEGIN
                EXEC [Acc_CustSetting3rd_04] @srecommend = @custid, @roleid = 4, @mode = 'GoldDeluxe', @sporttype = 255, @bettype = 1701
    END

    IF @roleid = 3
    BEGIN
                EXEC [Acc_CustSetting3rd_04] @custid = @custid, @srecommend = @UplineID, @roleid = 3, @mode = 'GoldDeluxe', @sporttype = 255, @bettype = 1701
    END

    IF @roleid = 2
    BEGIN
                EXEC [Acc_CustSetting3rd_04] @custid = @custid, @mrecommend = @UplineID, @roleid = 2, @mode = 'GoldDeluxe', @sporttype = 255, @bettype = 1701
    END

    DECLARE @LogSPData VARCHAR(MAX),
            @TrackingValueDB VARCHAR(4000)
            
    SELECT @LogSPData = '<Acc_CustOverrideUpdGoldDeluxe custid="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1)) + '" ' +
        'min_v255positiontaking_1701="' + COALESCE(CAST(@min_v255positiontaking_1701 AS VARCHAR(30)), SPACE(1)) + '" ' + 
        'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
        'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
        'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
        'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
        'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
        'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

    SELECT @TrackingValueDB = '<Acc_CustOverrideUpdGoldDeluxe custid="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1)) + '" ' +
        'min_v255positiontaking_1701="' + COALESCE(CAST(@old_min_v255positiontaking_1701 AS VARCHAR(30)), SPACE(1)) + '" ' + 
        'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
        'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
        'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
        'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
        'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
        'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'
    
    SET @endRun = GETDATE()
    SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)
    
    --Write log
    BEGIN TRY
        EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 507,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END TRY
    BEGIN CATCH
        SELECT @LogSPData = '<Acc_CustOverrideUpdGoldDeluxe custid="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1)) + '" ' +
        'min_v255positiontaking_1701="' + COALESCE(CAST(@min_v255positiontaking_1701 AS VARCHAR(30)), SPACE(1)) + '" ' + 
        'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
        'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
        'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
        'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
        'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
        'ErrMsg="'+ ERROR_MESSAGE() + '" />'
        
        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 507,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END CATCH
END


GO  
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpdGoldDeluxe] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpdGoldDeluxe] TO [bodbDownlineNet]
GO 
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpdGoldDeluxe] TO [vnteam]
