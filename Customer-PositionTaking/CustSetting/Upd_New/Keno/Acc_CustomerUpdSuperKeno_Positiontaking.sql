USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdSuperKeno_Positiontaking]    Script Date: 06/10/2015 15:53:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperKeno_Positiontaking    Script Date: 8/28/2014 2:05:46 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperKeno_Positiontaking    Script Date: 8/21/2014 3:12:20 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperKeno_Positiontaking    Script Date: 8/21/2014 2:58:14 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperKeno_Positiontaking]
    @custid INT,-- superid    
    @sporttype INT = 202,
    @bettype INT,
    
    @s4 SMALLMONEY, --s4

    @SubAccID INT = 0, --Sub-AccountID        
    @UserID INT = 0,    
    @Language varchar(2) = 'E',
    @IP VARCHAR(15)='',
    @ErrCode INT  = 0 OUTPUT,
    @ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
    Created: 20140225@Elodie
    Task : Update Keno's Super PT 
    DB: DBTXN/CustDB
    Revisions:

        - 20140818@Logan:   Exclude disabled members while checking constraints for Super [Redmine: #19631]
        - 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckAllowedDownlines, change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID) [Redmine:#36216]
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]	
    Param's Explanation:
    • @ErrCode is:
            = 0: Transaction recorded successfully.
            > 0: Specific Error.
      
    • @ErrMsg: Error description.
*/
BEGIN
    SET NOCOUNT ON
    DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT

    SET @startRun = GETDATE()

    DECLARE @roleid TINYINT, @MaxPT SMALLMONEY

    ---------------------------
    -- ***Check Downline Belonging***
    EXEC Age_CustomerSelCheckBelongingByCustID 
        @SessionCustID = @Userid, 
        @Custid = @custid,
        @roleid = @roleid OUTPUT
    IF (@roleid = 0) RETURN
    ---------------------------

	
    --Check disable user
    EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
    IF @ErrCode <> 0
        RETURN
    --end

	         
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END


    ---- Checking total downlines before UPDATEs 
    EXEC dbo.Acc_CustomerSelCheckAllowedDownlines    
        @custid=@custid,
        @roleid=4,
        @isExecRep=1,
        @isUpdatePT = 1,
        @Sporttype = 1,
        @Language='E',
        @ErrMsg=@ErrMsg output,
        @ErrCode=@ErrCode output
    IF    @ErrCode <> 0 
        RETURN 

    DECLARE @old_spositiontaking SMALLMONEY

    SELECT @old_spositiontaking = spositiontaking 
      FROM CustSettingGame WITH(NOLOCK)
     WHERE Custid = @custid AND sporttype = @sporttype AND bettype = @bettype

    --check if not change value
    IF @old_spositiontaking = @s4
        RETURN
    
    SELECT @MaxPT = MaxPositiontaking FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = @sporttype AND Bettype = @bettype and IsDep = 0
    IF @MaxPT < @s4
    BEGIN
        SELECT @ErrMsg =
                    CASE @Language 
                            WHEN 'E' then 'Super Max PT exceeded Company limit:' + cast(@MaxPT AS VARCHAR(10)) + '.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20018,@Language) + cast(@MaxPT AS VARCHAR(10)) + '.'
                    END, @ErrCode = 102
        RETURN
    END

    Declare @ErrAcc nvarchar(4000)
    --check all s3+m3<=s4 if i3 = 0,
    --m3<=s4 and u3<=s4 if i3=1
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + ci.username + ', '
      FROM CustSettingGame cs WITH(NOLOCK)
INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid 
     WHERE ci.srecommend = @custid AND ci.roleid = 3
        AND cs.sporttype = @sporttype AND bettype = @bettype
        AND ((cs.isautopositiontaking = 0 AND cs.spositiontaking + cs.mpositiontaking > @s4)
            OR (cs.isautopositiontaking = 1 AND (cs.mpositiontaking > @s4 OR cs.autopositiontaking > @s4)))
    IF @ErrAcc<>''
    BEGIN
        Select @ErrMsg =
                    case @Language 
                            when 'E' then 'Existing masters exceeded new super position taking (' + @ErrAcc + ').'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20013,@Language) + ' (' + @ErrAcc + ').'
                    end, @ErrCode = 103
        return
    END

    --check all s1+m1+a1 <= s4
    --check all u1<=s4 if i1=1
    SELECT @ErrAcc = ''

    SELECT @ErrAcc = @ErrAcc + ci.username + ', '    
      FROM CustSettingGame cs WITH(NOLOCK)
INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
     WHERE ci.srecommend = @custid
       AND ci.roleid     = 1
       AND ci.Enabled    = 1
       AND cs.sporttype  = @sporttype
       AND cs.Bettype    = @bettype
       AND (cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > @s4
            OR (cs.isautopositiontaking = 1
                AND cs.autopositiontaking > @s4
               )
           )

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new super position taking (' + @ErrAcc + ').'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20014, @Language) + ' (' + @ErrAcc + ').'
                 END
             , @ErrCode = 104
        RETURN
    END


    UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK)
    SET spositiontaking = @s4
     WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype

    IF (@@ERROR <> 0)
    BEGIN
        SELECT @ErrMsg =
                        CASE @Language 
                            WHEN 'E' THEN 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        END    , @ErrCode = 105                     
    
        RETURN
    END

    --u = (i3 or i1)?(u3 or u1)
    --s1 = min(s4-m1-a1, u)
                                EXEC dbo.Acc_CustSetting3rd_07 @srecommend = @custid , @roleid = 4, @mode = 'Keno', @sporttype = @sporttype, @bettype = @bettype
    
    Declare @LogSPData varchar(MAX),
            @TrackingValueDB varchar(4000)
     
    SELECT @LogSPData = '<Acc_CustomerUpdSuperKeno_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
    'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
    'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
    's4="' + COALESCE(CAST(@s4 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
    'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +
    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


    SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperKeno_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
    'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
    'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
    's4="' + COALESCE(CAST(@old_spositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
    'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
    'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +
    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


    SET @endRun = GETDATE()
    SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

    --Log customer info 
    BEGIN TRY
        EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 442,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END TRY
    BEGIN CATCH
        SELECT @LogSPData = '<Acc_CustomerUpdSuperKeno_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
        'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
        'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
        's4="' + COALESCE(CAST(@s4 AS VARCHAR(50)),SPACE(1)) + '" ' +
        'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
        'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +
        'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
        'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
        'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
        'ErrMsg="'+ ERROR_MESSAGE() + '" />'
    
        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 442,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno_Positiontaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno_Positiontaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno_Positiontaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperKeno_Positiontaking] TO [vnteam] AS [dbo]