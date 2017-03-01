ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterKeno_Positiontaking]
(
    @CustId INT
    , @SportType INT = 202
    , @BetType INT

    , @s3 SMALLMONEY --s3
    , @us3 SMALLMONEY --us3
    , @is3 BIT = 0 --is3
    , @m3 SMALLMONEY --m3
    , @n3 SMALLMONEY --n3
    
    , @UpdateAllMembers    BIT = 0
    , @NewSPositionTaking SMALLMONEY = 0 --s1
    
    , @UpdatePositionTaking BIT = 0
    , @UpdateAutoPositionTaking    BIT = 0
    , @UpdateMinPositionTaking    BIT = 0
    
    , @SubAccID INT = 0 --Sub-AccountID        
    , @UserID    INT = 0
    , @Language VARCHAR(2) = 'E'
    , @IP VARCHAR(15) = ''
    , @ErrCode INT = 0 OUTPUT
    , @ErrMsg NVARCHAR(4000) = '' OUTPUT
)
AS
/*
    Created: 20140326@Patrick
    Task: Super/Admin edit positiontaking on master
    DB: DBCUST/CustDB
        
    Revisions:
        - 20140729@Logan: 1.Exclude disabled agents, members while updating master setting [Redmine: #19631]
                          2.Code aligning on modified parts
		- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB)
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]	

    Parameters Explanation:
        @ErrCode is 0 update successful
*/
BEGIN

    SET NOCOUNT ON

    DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT
        , @UserName NVARCHAR(50), @mrecommend INT, @srecommend INT, @roleid TINYINT
        , @ErrAcc VARCHAR(4000), @ErrType VARCHAR(4000)

    SELECT @ErrCode = 0, @ErrMsg = '', @ErrAcc = '', @ErrType = '', @startRun = GETDATE()
    
    EXEC Acc_CustomerSelCheckAllowedDownlines @custid = @custid
        , @roleid = 3
        , @isExecRep = 1
        , @isUpdatePT = 1
        , @Sporttype = 1
        , @Language = 'E'
        , @ErrMsg = @ErrMsg OUTPUT
        , @ErrCode = @ErrCode OUTPUT
    IF    @ErrCode <> 0 
        RETURN 
    
    DECLARE @Old_SPositionTaking SMALLMONEY, @Old_MPositionTaking SMALLMONEY,
        @Old_IsAuto_SPositionTaking BIT, @Old_Auto_SPositionTaking SMALLMONEY
    
    SELECT @Old_SPositionTaking = spositiontaking
        , @Old_MPositionTaking = mpositiontaking
        , @Old_IsAuto_SPositionTaking = isautopositiontaking
        , @Old_Auto_SPositionTaking = autopositiontaking
      FROM dbo.CustSettingGame WITH(NOLOCK)
     WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType

    SELECT @username = username , @srecommend = srecommend
			, @roleid = roleid
     FROM dbo.CustInfo WITH(NOLOCK)
     WHERE custid = @custid

	            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END

    --check if not change value
    IF(@Old_SPositionTaking = @s3
        AND @Old_MPositionTaking = @m3
        AND @Old_IsAuto_SPositionTaking = @is3
        AND @Old_Auto_SPositionTaking = @us3)
        RETURN

    IF (@s3 < 0 OR @m3 < 0
        OR @s3 + @m3 > 1
        OR @us3 < 0 OR @us3 > 1)
    BEGIN
        SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Wrong position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) END
            , @ErrCode = 100
        RETURN
    END


    SELECT @ErrType = ''
    --check n4<=s3+m3<=s4, s3<=s4 if i3 = 0, 
    --m3<=s4 and u3+m3>=n4 if i3 = 1
    SELECT @ErrType = @ErrType + 'Min: ' + CAST(co.minpositiontaking AS VARCHAR(10)) + ' -Max: ' + CAST(cs.spositiontaking AS VARCHAR(10)) + '<br>'
      FROM dbo.CustSettingGame cs WITH(NOLOCK)
INNER JOIN dbo.CustOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid AND cs.bettype = co.bettype AND cs.sporttype = co.sporttype 
     WHERE cs.custid = @srecommend 
        AND cs.bettype = @BetType
        AND cs.sporttype = @SportType
        AND ((@is3 > 0 
                AND (@m3 + @us3 < co.minpositiontaking 
                    OR @m3 > cs.spositiontaking))
            OR (@is3 = 0 
                AND (@s3 + @m3 < co.minpositiontaking 
                    OR @s3 + @m3 > cs.spositiontaking 
                    OR @s3 > cs.spositiontaking)))

    IF @ErrType <> ''
    BEGIN    
        SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>' + @ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002, @Language) + '<br>' + @ErrType END
                , @ErrCode = 101
        RETURN
    END


    --a2+m2<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
      FROM dbo.CustSettingGame cs WITH(NOLOCK)
INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
     WHERE ci.mrecommend = @custid
       AND ci.roleid     = 2
       AND ci.Enabled    = 1
       AND cs.bettype    = @BetType
       AND cs.sporttype  = @SportType
       AND cs.mpositiontaking + cs.apositiontaking > @m3

    IF @ErrAcc <> ''
    BEGIN        
        SELECT @ErrMsg =
                 CASE @Language
                   WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ') .'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                 END
             , @ErrCode = 102
        RETURN
    END

    --a1+m1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
      FROM dbo.CustSettingGame cs WITH(NOLOCK)
INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
     WHERE ci.mrecommend = @custid
       AND ci.roleid     = 1
       AND ci.Enabled    = 1
       AND cs.bettype    = @BetType
       AND cs.sporttype  = @SportType
       AND cs.mpositiontaking + cs.apositiontaking > @m3 

    IF @ErrAcc <> ''
    BEGIN    
        SELECT @ErrMsg =
                 CASE @Language
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ').'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').' END
            , @ErrCode = 103
        RETURN
    END


    --m3>=u2
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
      FROM dbo.CustSettingGame cs WITH(NOLOCK)
INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
     WHERE ci.mrecommend = @custid
       AND ci.roleid     = 2
       AND ci.Enabled    = 1
       AND cs.bettype    = @BetType
       AND cs.sporttype  = @SportType
       AND cs.isautompositiontaking = 1
       AND cs.autompositiontaking > @m3

    IF @ErrAcc <> ''
    BEGIN        
        SELECT @ErrMsg = CASE @Language
                           WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011,@Language) + ' (' + @ErrAcc + ').'
                         END
             , @ErrCode = 104
        RETURN
    END    

    --check u3<=s4
    SELECT @ErrType = ''
    SELECT @ErrType = @ErrType + 'Max: ' + CAST (cs.spositiontaking AS VARCHAR(10)) + '<br>'
      FROM dbo.CustSettingGame cs WITH(NOLOCK)        
     WHERE custid = @srecommend
        AND cs.bettype = @BetType AND cs.sporttype = @SportType
        AND @us3 > spositiontaking 

    IF @ErrType <> ''    
    BEGIN
        SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
                                WHEN 'E' THEN 'Wrong auto position taking.<br>' + @ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009, @Language) + '<br>' + @ErrType END
            , @ErrCode = 105
        RETURN
    END

    IF @UpdatePositionTaking = 1
    BEGIN
        UPDATE dbo.CustSettingGame WITH(UPDLOCK, ROWLOCK)
        SET spositiontaking = @s3, mpositiontaking = @m3
         WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType 

        IF (@@ERROR <> 0)
        BEGIN
            SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
                                WHEN 'E' THEN 'Update process is unsuccessful !'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language) END
                , @ErrCode = 106                 
            RETURN
        END
    END

    IF @UpdateAutoPositionTaking = 1
    BEGIN
        --Update Master Agent account (autopositiontaking field)
        UPDATE dbo.CustSettingGame WITH(UPDLOCK, ROWLOCK)
        SET autopositiontaking = @us3, isautopositiontaking = @is3
         WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType 
    
        IF @@ERROR <> 0
        BEGIN
            SELECT @ErrMsg =  CASE @Language 
                                WHEN 'E' THEN 'Error updating auto position taking'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) END    
                ,  @ErrCode = 201
            RETURN
        END
    
                                EXEC dbo.Acc_CustSetting3rd_05
            @srecommend = @srecommend
            , @mrecommend = @custid
            , @roleid = 3
            , @mode = 'Keno'

            , @IsAuto_KenoSPositionTaking = @is3
            , @Old_IsAuto_KenoSPositionTaking = @Old_IsAuto_SPositionTaking
            , @Auto_KenoSPositionTaking = @us3
        
            , @Updateallmembers = @Updateallmembers
            , @newspositiontaking = @NewSPositionTaking
            , @KenoBetType = @BetType
    END

    --apply new value position taking for super on members
    IF @UpdatePositiontaking=1 AND @UpdateAutoPositiontaking = 0 AND @UpdateAllMembers = 1 AND @is3 = 0
    BEGIN
                                EXEC dbo.Acc_CustSetting3rd_05
            @srecommend = @srecommend,
            @mrecommend = @custid,
            @roleid = 3,
            @mode = 'Keno',
                        
            @KenoBettype = @Bettype,
            
            @IsAuto_KenoSPositionTaking = @is3,--is3
            @Old_IsAuto_KenoSPositionTaking = @Old_IsAuto_SPositionTaking,--is3_old
                                    
            @updateautopositiontakingv202 = 0,
            @newspositiontaking = @NewSPositionTaking
    END

    IF @UpdateAutoPositionTaking = 1 OR @UpdatePositionTaking = 1
    BEGIN
                                EXEC dbo.Acc_CustSetting3rd_07
            @srecommend = @srecommend,
            @mrecommend = @custid,
            @roleid = 3,
            @mode = 'Keno',
            @Sporttype = @SportType,
            @Bettype = @Bettype
        
        IF (@@ERROR <> 0)
        BEGIN
            SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
                                WHEN 'E' THEN 'Update process is unsuccessful !'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language) END
                , @ErrCode = 107             
            RETURN
        END
    END
    
    --SELECT @ErrCode = -103

    DECLARE @LogSPData VARCHAR(MAX), @TrackingValueDB VARCHAR(4000)
    SELECT @LogSPData = '<Acc_CustomerUpdMasterKeno_Positiontaking CustId ="' + COALESCE(CAST(@CustId AS VARCHAR(50)), SPACE(1))
        + '" ' + 'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) 
        + '" ' + 'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) 
        + '" ' + 's3="' + COALESCE(CAST(@s3 AS VARCHAR(50)), SPACE(1))
        + '" ' + 'm3="' + COALESCE(CAST(@m3 AS VARCHAR(50)), SPACE(1))
        + '" ' + 'is3="' + COALESCE(CAST(@is3 AS VARCHAR(50)), SPACE(1))
        + '" ' + 'us3="' + COALESCE(CAST(@us3 AS VARCHAR(50)), SPACE(1))
        + '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(50)), SPACE(1))
        + '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(50)), SPACE(1))
        + '" ' + 'UpdateAllMembers="' + COALESCE(CAST (@UpdateAllMembers AS VARCHAR(3)), SPACE(1))
        + '" ' + 'NewSPositionTaking="' + COALESCE(CAST (@NewSPositionTaking AS VARCHAR(30)), SPACE(1))

        + '" ' + 'UserId="' + COALESCE(CAST(@userid AS VARCHAR(50)), SPACE(1))
        + '" ' + 'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
        + '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
        + '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)), SPACE(1))
        + '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
        + '" ' + 'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

    SELECT @TrackingValueDB = '<Acc_CustomerUpdMasterKeno_Positiontaking CustId ="' + COALESCE(CAST(@CustId AS VARCHAR(50)), SPACE(1))
        + '" ' + 'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) 
        + '" ' + 'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) 
        + '" ' + 's3="' + COALESCE(CAST(@Old_SPositionTaking AS VARCHAR(50)), SPACE(1))
        + '" ' + 'm3="' + COALESCE(CAST(@Old_MPositionTaking AS VARCHAR(50)), SPACE(1))
        + '" ' + 'is3="' + COALESCE(CAST(@Old_IsAuto_SPositionTaking AS VARCHAR(50)), SPACE(1))
        + '" ' + 'us3="' + COALESCE(CAST(@Old_Auto_SPositionTaking AS VARCHAR(50)), SPACE(1))
        + '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(50)), SPACE(1))
        + '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(50)), SPACE(1))
        + '" ' + 'UpdateAllMembers="' + COALESCE(CAST (@UpdateAllMembers AS VARCHAR(3)), SPACE(1))
        + '" ' + 'NewSPositionTaking="' + COALESCE(CAST (@NewSPositionTaking AS VARCHAR(30)), SPACE(1))
        + '" ' + 'UserId="' + COALESCE(CAST(@userid AS VARCHAR(50)), SPACE(1))
        + '" ' + 'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
        + '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
        + '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)), SPACE(1))
        + '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
        + '" ' + 'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

    SELECT @endRun = GETDATE(), @duration = DATEDIFF (MILLISECOND, @startRun, @endRun)
    --Log customer info 
    BEGIN TRY
        EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 443,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END TRY
    BEGIN CATCH
        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 443,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END CATCH

END

GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterKeno_Positiontaking] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_Positiontaking] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_Positiontaking] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_Positiontaking] TO [bodbExtAccNet]
GO 
