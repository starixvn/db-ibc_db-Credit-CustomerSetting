ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperGoldDeluxe_Positiontaking]
    @custid						INT,
    @v255spositiontaking_1701	SMALLMONEY,
    
    @UserID						INT				= 0,
    @IP							VARCHAR(50)		= '',    
    @Language					VARCHAR(20)		= 'E',        
    
    @ErrCode					VARCHAR(300)	= '' OUTPUT,
    @ErrMsg						NVARCHAR(4000)	= '' OUTPUT
AS
    /*
        Created: Kathy
        Date: 20150423
        Task: Company update positiontaking on super
        DB: DBTXN/custDB
        
        Revisions:
			- 20150610@Elodie: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable, Acc_CustomerSelCheckAllowedDownlines, Change Age_CustomerSelCheckBelonging to Age_CustomerSelCheckBelongingByCustID]           
			- 20151007@Elodie: Remove code to check old and new value
			- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
			
        Parameters Explanation:
			
        Note:
            - Check synchronize status off member before update
    */
BEGIN
    SET NOCOUNT ON

    DECLARE @startRun	DATETIME
			,@endRun	DATETIME
			,@duration	INT

    SET @startRun = GETDATE()

    DECLARE @roleid			TINYINT
			,@ErrCode_Cur	INT
			,@ErrMsg_Cur	NVARCHAR(4000)
			,@ErrAcc		NVARCHAR(4000)
			
    SELECT	@ErrCode_Cur	= 0
			,@ErrMsg_Cur	= ''
			,@ErrCode		= ''
			,@ErrMsg		= ''

    ---------------------------
    -- ***Check Downline Belonging***
    EXEC Age_CustomerSelCheckBelongingByCustID 
        @SessionCustID	= @Userid, 
        @Custid			= @custid,
        @roleid			= @roleid	OUTPUT
        
    IF (@roleid = 0) RETURN
    
    -- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
    ---------------------------

    --Check disable user
    EXEC Acc_CustomerSelCheckEnable 
		@custid		= @custid
		,@ErrCode	= @ErrCode_Cur	OUTPUT
		,@ErrMsg	= @ErrMsg_Cur	OUTPUT
		
    IF @ErrCode_Cur > 0
    BEGIN
        SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
        RETURN
    END
    --end

    ---- Checking total downlines before UPDATEs 
    EXEC Acc_CustomerSelCheckAllowedDownlines    
		@custid		= @custid,
        @roleid		= 4,
        @isExecRep	= 1,
        @isUpdatePT = 1,
        @Sporttype	= 1,
        @Language	= 'E',
        @ErrMsg		= @ErrMsg	OUTPUT,
        @ErrCode	= @ErrCode	OUTPUT
        
    IF @ErrCode <> 0 
        RETURN 

    DECLARE @db_v255spositiontaking_1701 SMALLMONEY

    SELECT	@db_v255spositiontaking_1701 = spositiontaking 
    FROM	CustSettingGame WITH(NOLOCK)
    WHERE	Custid = @custid 
			AND sporttype = 255 
			AND bettype = 1701

    ----check if not change value
    --IF @db_v255spositiontaking_1701 = @v255spositiontaking_1701
    --    RETURN

    --check all s3+m3<=s4 if i3 = 0,
    --m3<=s4 and u3<=s4 if i3=1
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + ci.username + ', '
    FROM	CustSettingGame cs WITH(NOLOCK)
			INNER JOIN custinfo ci WITH(NOLOCK) 
				ON	ci.custid = cs.custid 
    WHERE	ci.srecommend = @custid 
			AND ci.roleid = 3
			AND cs.sporttype = 255 
			AND bettype = 1701
			AND ((cs.isautopositiontaking = 0 AND cs.spositiontaking + cs.mpositiontaking > @v255spositiontaking_1701)
					OR (cs.isautopositiontaking = 1 AND (cs.mpositiontaking > @v255spositiontaking_1701 OR cs.autopositiontaking > @v255spositiontaking_1701))
				)

    IF @ErrAcc<>''
    BEGIN
        SELECT @ErrMsg =
                    CASE @Language 
                            WHEN 'E' THEN 'Existing masters exceeded new super position taking ('+@ErrAcc+').'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20013,@Language) + ' ('+@ErrAcc+').'
                    END, @ErrCode = 103
        RETURN
    END

    --check all s1+m1+a1 <= s4
    --check all u1<=s4 if i1=1
    SELECT @ErrAcc = ''

    SELECT	@ErrAcc = @ErrAcc + ci.username + ', '
    FROM	CustSettingGame cs WITH(NOLOCK)
		INNER JOIN custinfo ci WITH(NOLOCK) 
			ON	cs.custid = ci.custid
    WHERE	ci.srecommend = @custid
			AND ci.roleid     = 1
			AND ci.Enabled    = 1
			AND cs.sporttype  = 255
			AND cs.Bettype    = 1701
			AND (cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > @v255spositiontaking_1701
					OR (cs.isautopositiontaking = 1
						AND cs.autopositiontaking > @v255spositiontaking_1701
				   )
			   )

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new super position taking (' + @ErrAcc + ').'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20014,@Language) + ' (' + @ErrAcc + ').'
                 END
             , @ErrCode = 104
             
        RETURN
    END


    UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK)
		SET spositiontaking = @v255spositiontaking_1701
    WHERE	custid = @custid
		   AND sporttype = 255
		   AND bettype = 1701

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
    EXEC dbo.Acc_CustSetting3rd_07 
		@srecommend = @custid 
		,@roleid = 4
		,@mode = 'GoldDeluxe'
		,@sporttype = 255
		,@bettype = 1701
    /*
    UPDATE cs 
    SET spositiontaking = CASE WHEN @v162spositiontaking_1101 - cs.mpositiontaking - cs.apositiontaking >
                                 CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END THEN
                                (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) 
                            ELSE @v162spositiontaking_1101 - cs.mpositiontaking - cs.apositiontaking 
                        END                            
    FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON ci.custid = cs.custid
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
        --INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @custid AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
    WHERE ci.srecommend = @custid AND roleid = 1 AND ci.SyncLiveCasino = 1
        AND cs.sporttype = 162 AND cs.bettype = 1101 
        AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)     

    IF (@@ERROR <> 0)
    BEGIN
        SELECT @ErrMsg = 
                        CASE @Language 
                            WHEN 'E' THEN 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        END    , @ErrCode = 105                     
        
        RETURN
    END
    */

    Declare @LogSPData varchar(MAX),
            @TrackingValueDB varchar(4000)
         
    SELECT @LogSPData = '<Acc_CustomerUpdSuperGoldDeluxe_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
					'v255spositiontaking_1701="' + COALESCE(CAST(@v255spositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
					'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
					'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
					'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
					'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


    SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperGoldDeluxe_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
						'v255spositiontaking_1701="' + COALESCE(CAST(@db_v255spositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
						'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
						'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
						'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


    SET @endRun = GETDATE()
    SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

    --Log customer info 
    BEGIN TRY
        EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
            @UserID			= @UserID,
            @CustID			= @CustID,
            @ActionID		= 457,
            @TrackingValue	= @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration		= @duration
    END TRY
    BEGIN CATCH
        SELECT @LogSPData = '<Acc_CustomerUpdSuperLiveCS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
						'v255spositiontaking_1701="' + COALESCE(CAST(@v255spositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
						'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
						'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
						'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrMsg="'+ ERROR_MESSAGE() + '" />'
        
        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
            @UserID			= @UserID,
            @CustID			= @CustID,
            @ActionID		= 457,
            @TrackingValue	= @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration		= @duration
    END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperGoldDeluxe_Positiontaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperGoldDeluxe_Positiontaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperGoldDeluxe_Positiontaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperGoldDeluxe_Positiontaking] TO [vnteam] AS [dbo]