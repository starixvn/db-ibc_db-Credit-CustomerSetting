ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterLiveCS_Positiontaking]
    @custid        INT,
    @v162spositiontaking_1101    SMALLMONEY,
    @v162mpositiontaking_1101    SMALLMONEY,
    
    @isauto_v162spositiontaking_1101 BIT,
    @auto_v162spositiontaking_1101    SMALLMONEY,
    
    @v162UpdatePositiontaking_1101    BIT,
    @v162UpdateAutoPositiontaking_1101 BIT,
    
    @updateallmembers    BIT = 0,
    @newspositiontaking SMALLMONEY = 0,
    
    @SubAccID    INT = 0, -- Sub Account
    @UserID        INT = 0    ,
    @IP            VARCHAR(50)= '',    
    @Language    VARCHAR(20) = 'E',        
    
    @ErrCode    VARCHAR(300) = '' OUTPUT,
    @ErrMsg        NVARCHAR(4000) = '' OUTPUT
AS
    /*
        Created: Johnson
        Date: 09Jan2011
        Task: Super/Admin edit positiontaking on master
        DB: DBTrans.BODB02
        
        Revisions:
            - 20120405@Johnson: not check pt change for master not synchronized
            - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
            - 20130301@Amy: change limitation of max super PT to 100% instead of 90%
            - 20130320@Johnson: Write log on DBTXN if DBLOG failure
            - 20131104@Johnson: Apply execrep when recalculate pt on members 
                    and Check total downlines before UPDATEs
            - 20140729@Logan: 1.Exclude disabled agents, members while updating SM's setting [Redmine: #19631]
                              2.Code aligning on modified parts
			- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB)
                              
        Parameters Explanation:
    */
BEGIN
    SET NOCOUNT ON

    DECLARE @startRun DATETIME
    DECLARE @endRun DATETIME
    DECLARE @duration INT

    SET @startRun = GETDATE()

    DECLARE @roleid            TINYINT, 
            @SyncLiveCasino BIT,
            @UserName        VARCHAR(30), 
            @srecommend        INT, 
            @ErrType        VARCHAR(4000),
            @ErrCode_Cur    INT, 
            @ErrMsg_Cur        NVARCHAR(4000), 
            @ErrAcc            NVARCHAR(4000)


    SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

    ---- Johnson@20131104: Checking total downlines before UPDATEs 
    EXEC Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
        @roleid=3,
        @isExecRep=1,
        @isUpdatePT = 1,
        @Sporttype = 1,
        @Language='E',
        @ErrMsg=@ErrMsg output,
        @ErrCode=@ErrCode output
    IF    @ErrCode <> 0 
        RETURN 
    ---------------------------
    -- ***Check Downline Belonging***
    --EXEC DB053.bodb02.dbo.Age_CustomerSelCheckBelonging 
    --    @SessionCustID = @Userid, 
    --    @Custid = @custid,
    --    @roleid = @roleid OUTPUT
    --    IF (@roleid = 0) RETURN
    ---------------------------

    --Check disable user
    --EXEC DB053.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
    --IF @ErrCode_Cur > 0
    --BEGIN
    --    select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
    --            @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
    --    return
    --END
    --end
    DECLARE @db_v162spositiontaking_1101    SMALLMONEY,
        @db_v162mpositiontaking_1101        SMALLMONEY,    
        @db_isauto_v162spositiontaking_1101 BIT,
        @db_auto_v162spositiontaking_1101    SMALLMONEY
        
    SELECT @db_v162spositiontaking_1101 = spositiontaking,
        @db_v162mpositiontaking_1101 = mpositiontaking,
        @db_isauto_v162spositiontaking_1101 = isautopositiontaking,
        @db_auto_v162spositiontaking_1101 = autopositiontaking
    FROM CustSettingGame WITH(NOLOCK)
    WHERE custid = @custid AND sporttype = 162 AND bettype = 1101 

    SELECT @username = username , @srecommend = srecommend, @SyncLiveCasino = SyncLiveCasino 
    FROM CustInfo WITH(NOLOCK)
    WHERE custid = @custid

    --check if not change value
    IF @db_v162spositiontaking_1101 = @v162spositiontaking_1101
        AND @db_v162mpositiontaking_1101 = @v162mpositiontaking_1101
        AND @db_isauto_v162spositiontaking_1101 = @isauto_v162spositiontaking_1101
        AND @db_auto_v162spositiontaking_1101 = @auto_v162spositiontaking_1101
        AND @SyncLiveCasino = 1
    RETURN

    IF (@v162spositiontaking_1101 < 0 OR @v162mpositiontaking_1101 < 0
        OR @v162spositiontaking_1101 + @v162mpositiontaking_1101 > 1
        OR @auto_v162spositiontaking_1101 < 0 OR @auto_v162spositiontaking_1101 > 1)
    BEGIN
            Select @ErrMsg =     case @Language 
                                WHEN 'E' THEN 'Wrong position taking.'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                        END, @ErrCode = 100
            RETURN
    END

    SELECT @ErrType = ''

    --check n4<=s3+m3<=s4, s3<=s4 if i3 = 0, 
    --m3<=s4 and u3+m3>=n4 if i3 = 1    
    SELECT @ErrType = @ErrType + 'Min: ' + CAST(co.minpositiontaking AS VARCHAR(10)) + ' -Max: ' + CAST(cs.spositiontaking AS VARCHAR(10)) + '<br>'
    FROM CustSettingGame cs WITH(NOLOCK)
        INNER JOIN CustOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype 
    WHERE cs.custid = @srecommend AND cs.sporttype = 162 AND cs.bettype = 1101
        AND ((@isauto_v162spositiontaking_1101 > 0 AND (@v162mpositiontaking_1101 + @auto_v162spositiontaking_1101 < co.minpositiontaking OR @v162mpositiontaking_1101 > cs.spositiontaking))
        OR (@isauto_v162spositiontaking_1101 = 0 AND (@v162spositiontaking_1101 + @v162mpositiontaking_1101 < minpositiontaking OR @v162spositiontaking_1101 + @v162mpositiontaking_1101 > cs.spositiontaking OR @v162spositiontaking_1101 > cs.spositiontaking)))

    IF @ErrType <> ''
    BEGIN    
        SELECT @ErrMsg =     CASE @Language 
                            WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    END, @ErrCode = 101
        RETURN
    END

    --a2+m2<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
      FROM CustSettingGame cs WITH(NOLOCK)
INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
     WHERE ci.mrecommend = @custid
       AND ci.roleid     = 2
       AND ci.Enabled    = 1
       AND cs.sporttype  = 162
       AND cs.bettype    = 1101
       AND cs.mpositiontaking + cs.apositiontaking > @v162mpositiontaking_1101

    IF @ErrAcc <> ''
    BEGIN        
        SELECT @ErrMsg = CASE @Language 
                           WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ') .'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                         END
             , @ErrCode = 102
        RETURN
    END

    --a1+m1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
      FROM CustSettingGame cs WITH(NOLOCK)
INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
     WHERE ci.mrecommend = @custid
       AND ci.roleid     = 1
       AND ci.Enabled    = 1
       AND cs.sporttype  = 162
       AND cs.bettype    = 1101
       AND cs.mpositiontaking + cs.apositiontaking > @v162mpositiontaking_1101 

    IF @ErrAcc <> ''
    BEGIN    
        SELECT @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ').'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
                 END
             , @ErrCode = 103
        RETURN
    END

    --m3>=u2
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
      FROM CustSettingGame cs WITH(NOLOCK)
INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
     WHERE ci.mrecommend = @custid
       AND ci.roleid     = 2
       AND ci.Enabled    = 1
       AND cs.sporttype  = 162
       AND cs.bettype    = 1101
       AND cs.isautompositiontaking = 1
       AND cs.autompositiontaking > @v162mpositiontaking_1101

    IF @ErrAcc <> ''
    BEGIN        
        SELECT @ErrMsg = CASE @Language
                           WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                         END
             , @ErrCode = 104
        RETURN
    END

    --check u3<=s4
    SELECT @ErrType = ''

    SELECT @ErrType = @ErrType + 'Max: ' + CAST (cs.spositiontaking AS VARCHAR(10)) + '<br>'
    FROM CustSettingGame cs WITH(NOLOCK)        
    WHERE custid = @srecommend AND sporttype = 162 AND bettype = 1101
        AND @auto_v162spositiontaking_1101 > spositiontaking 

    IF @ErrType <>''    
    BEGIN
        SELECT @ErrMsg =    @UserName + ': '+
                            CASE @Language 
                                WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            END    , @ErrCode = 105
        RETURN
    END

    IF @v162UpdatePositiontaking_1101 = 1
    BEGIN
        UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK)
        SET spositiontaking = @v162spositiontaking_1101, mpositiontaking = @v162mpositiontaking_1101
        WHERE custid = @custid AND sporttype = 162 AND bettype = 1101 

        IF (@@error <> 0)
        BEGIN
            SELECT @ErrMsg = @UserName + ': '+
                            CASE @Language 
                                WHEN 'E' THEN 'Update process is unsuccessful !'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                            END    , @ErrCode = 106                 
            RETURN
        END
    END

    IF @v162UpdateAutoPositiontaking_1101 = 1
    BEGIN
        --Update Master Agent account (autopositiontaking field)
        UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK)
        SET autopositiontaking = @auto_v162spositiontaking_1101, isautopositiontaking = @isauto_v162spositiontaking_1101
        WHERE custid = @custid AND sporttype = 162 AND bettype = 1101
        
        IF @@Error <> 0
        BEGIN
            
            SELECT @ErrMsg =  
                CASE @Language 
                    WHEN 'E' THEN 'Error updating auto position taking'
                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                END    
                ,  @ErrCode=201
            RETURN
        END
        
                                EXEC dbo.Acc_CustSetting3rd_05
            @srecommend = @srecommend,
            @mrecommend = @custid,
            @roleid = 3,
            @mode = 'LiveCasino',
            
            @isauto_v162spositiontaking_1101 = @isauto_v162spositiontaking_1101,
            @old_isauto_v162spositiontaking_1101 = @db_isauto_v162spositiontaking_1101,
            
            @auto_v162spositiontaking_1101 = @auto_v162spositiontaking_1101, 
            
            @Updateallmembers = @Updateallmembers,
            @newspositiontaking = @newspositiontaking
            
        /*
        IF @isauto_v162spositiontaking_1101 >0 --auto PT is used
        BEGIN
            --Update use Auto_SPT at master for all members only when:
                --(autoSPT at master changes AND isauto at master = 1
                --OR isauto at master changes from 0 to 1)
                --AND isauto at member = 0
            DECLARE @maxpos SMALLMONEY
            
            SELECT @maxpos = spositiontaking 
            FROM CustSettingGame with (NOLOCK) 
            WHERE custid = @srecommend and sporttype=162 and bettype = 1101
            
            UPDATE cs
            SET cs.spositiontaking = CASE WHEN @maxpos - cs.mpositiontaking - cs.apositiontaking > @auto_v162spositiontaking_1101 THEN @auto_v162spositiontaking_1101 ELSE @maxpos - cs.mpositiontaking - cs.apositiontaking END
            FROM CustSettingGame cs 
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
            WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101 
                AND cs.isautopositiontaking = 0 -- only update members without AutoSPT at member
            
            IF @@Error <> 0
            BEGIN                    
                SELECT @ErrMsg =  
                    CASE @Language 
                        WHEN 'E' THEN 'Error updating auto position taking'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                    END    
                    ,  @ErrCode=202
                RETURN
            END
        END
        ELSE IF @isauto_v162spositiontaking_1101 <> @db_isauto_v162spositiontaking_1101  --auto PT is NOT used
        BEGIN
            IF @Updateallmembers = 1
            BEGIN
            --Update a specific SPT for all members only when:
                        -- @updateallmembers = 1
                        -- isauto at master = 0
                        --AND isauto at master change from 1 to 0
                        --AND isauto at member = 0
                        
                UPDATE cs
                SET cs.spositiontaking = CASE WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking ELSE @newspositiontaking END
                FROM CustSettingGame cs
                    INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                    INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
                WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                    AND cs.sporttype = 162 AND cs.bettype = 1101 
                    AND cs.isautopositiontaking = 0
                
                IF @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                        case @Language 
                            WHEN 'E' THEN 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        END    
                    ,  @ErrCode=203
                    RETURN
                END
            END
        END*/
    END

    IF @v162UpdateAutoPositiontaking_1101 = 1 OR @v162UpdatePositiontaking_1101 = 1
    BEGIN
                                EXEC dbo.Acc_CustSetting3rd_07
            @srecommend = @srecommend,
            @mrecommend = @custid,
            @roleid = 3,
            @mode = 'LiveCasino'
            
    /*
            EXEC dbo.Acc_CustomerUpdMasterLiveCS_MaxPositiontaking @srecommend = @srecommend , @mrecommend = @custid
    */    
        IF (@@error <> 0)
        BEGIN        
            SELECT @ErrMsg = @UserName + ': '+
                            case @Language 
                                WHEN 'E' THEN 'Update process is unsuccessful !'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                            END, @ErrCode = 107             
            
            RETURN
        END

    END

    Declare @LogSPData varchar(MAX),
            @TrackingValueDB varchar(4000)
         
    SELECT @LogSPData = '<Acc_CustomerUpdMasterLiveCS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
    'v162spositiontaking_1101="' + COALESCE(CAST(@v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'v162mpositiontaking_1101="' + COALESCE(CAST(@v162mpositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'isauto_v162spositiontaking_1101="' + COALESCE(CAST(@isauto_v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'auto_v162spositiontaking_1101="' + COALESCE(CAST(@auto_v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'v162UpdatePositiontaking_1101="' + COALESCE(CAST(@V162UpdatePositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'v162UpdateAutoPositiontaking_1101="' + COALESCE(CAST(@V162UpdateAutoPositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'updateallmembers="' + COALESCE(CAST (@updateallmembers AS VARCHAR(3)), SPACE(1)) + '" ' +
    'newspositiontaking="' + COALESCE(CAST (@newspositiontaking AS VARCHAR(30)), SPACE(1)) + '" ' +

    'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'

    SELECT @TrackingValueDB = '<Acc_CustomerUpdMasterLiveCS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
    'v162spositiontaking_1101="' + COALESCE(CAST(@db_v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'v162mpositiontaking_1101="' + COALESCE(CAST(@db_v162mpositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'isauto_v162spositiontaking_1101="' + COALESCE(CAST(@db_isauto_v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'auto_v162spositiontaking_1101="' + COALESCE(CAST(@db_auto_v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'v162UpdatePositiontaking_1101="' + COALESCE(CAST(@V162UpdatePositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'v162UpdateAutoPositiontaking_1101="' + COALESCE(CAST(@V162UpdateAutoPositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'updateallmembers="' + COALESCE(CAST (@updateallmembers AS VARCHAR(3)), SPACE(1)) + '" ' +
    'newspositiontaking="' + COALESCE(CAST (@newspositiontaking AS VARCHAR(30)), SPACE(1)) + '" ' +

    'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
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
            @ActionID = 425,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END TRY
    BEGIN CATCH
        SELECT @LogSPData = '<Acc_CustomerUpdMasterLiveCS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
        'v162spositiontaking_1101="' + COALESCE(CAST(@v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
        'v162mpositiontaking_1101="' + COALESCE(CAST(@v162mpositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
        'isauto_v162spositiontaking_1101="' + COALESCE(CAST(@isauto_v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
        'auto_v162spositiontaking_1101="' + COALESCE(CAST(@auto_v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
        'v162UpdatePositiontaking_1101="' + COALESCE(CAST(@V162UpdatePositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
        'v162UpdateAutoPositiontaking_1101="' + COALESCE(CAST(@V162UpdateAutoPositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
        'updateallmembers="' + COALESCE(CAST (@updateallmembers AS VARCHAR(3)), SPACE(1)) + '" ' +
        'newspositiontaking="' + COALESCE(CAST (@newspositiontaking AS VARCHAR(30)), SPACE(1)) + '" ' +

        'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
        'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
        'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
        'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
        'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
        'ErrMsg="'+ ERROR_MESSAGE() + '" />'
        
        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 425,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END CATCH
END

GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_Positiontaking] TO [vnteam]
GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterLiveCS_Positiontaking] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_Positiontaking] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_Positiontaking] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_Positiontaking] TO [bodbExtAccNet]
GO 
