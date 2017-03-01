ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterGoldDeluxe_Positiontaking]
    @custid								INT,
    @v255spositiontaking_1701			SMALLMONEY,
    @v255mpositiontaking_1701			SMALLMONEY,
    
    @isauto_v255spositiontaking_1701	BIT,
    @auto_v255spositiontaking_1701		SMALLMONEY,
    
    @v255UpdatePositiontaking_1701		BIT,
    @v255UpdateAutoPositiontaking_1701	BIT,
    
    @updateallmembers					BIT				= 0,
    @newspositiontaking					SMALLMONEY		= 0,
    
    @SubAccID							INT				= 0, -- Sub Account
    @UserID								INT				= 0    ,
    @IP									VARCHAR(50)		= '',    
    @Language							VARCHAR(20) 	= 'E',        
    
    @ErrCode							VARCHAR(300)	= '' OUTPUT,
    @ErrMsg								NVARCHAR(4000)	= '' OUTPUT
AS
    /*
        Created: Kathy
        Date: 20150424
        Task: Super/Admin edit positiontaking on master
        DB: DBTXN/custdb
        
        Revisions:
			- 20150610@Elodie: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST)
			- 20151007@Elodie: Remove code to check old and new value
			- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]	
        Parameters Explanation:
    */
BEGIN
    SET NOCOUNT ON

    DECLARE @startRun	DATETIME
    DECLARE @endRun		DATETIME
    DECLARE @duration	INT

    SET @startRun = GETDATE()

    DECLARE @roleid				TINYINT, 
            @UserName			VARCHAR(30), 
            @srecommend			INT, 
			@recommend			INT, 
            @ErrType			VARCHAR(4000),
            @ErrCode_Cur		INT, 
            @ErrMsg_Cur			NVARCHAR(4000), 
            @ErrAcc				NVARCHAR(4000)


    SELECT	@ErrCode_Cur = 0
			,@ErrMsg_Cur = ''
			,@ErrCode = ''
			,@ErrMsg = ''

    ---- Checking total downlines before UPDATEs 
    EXEC Acc_CustomerSelCheckAllowedDownlines    
		@custid		= @custid,
        @roleid		= 3,
        @isExecRep	= 1,
        @isUpdatePT = 1,
        @Sporttype	= 1,
        @Language	= 'E',
        @ErrMsg		= @ErrMsg OUTPUT,
        @ErrCode	= @ErrCode OUTPUT
        
    IF  @ErrCode <> 0 
        RETURN 
  
    DECLARE @db_v255spositiontaking_1701			SMALLMONEY
			,@db_v255mpositiontaking_1701			SMALLMONEY
			,@db_isauto_v255spositiontaking_1701	BIT
			,@db_auto_v255spositiontaking_1701		SMALLMONEY
        
    SELECT	@db_v255spositiontaking_1701		= spositiontaking,
			@db_v255mpositiontaking_1701		= mpositiontaking,
			@db_isauto_v255spositiontaking_1701 = isautopositiontaking,
			@db_auto_v255spositiontaking_1701	= autopositiontaking
    FROM	dbo.CustSettingGame WITH(NOLOCK)
    WHERE	custid = @custid 
			AND sporttype = 255 
			AND bettype = 1701 

    SELECT	@username			= username 
			,@srecommend		= srecommend
			,@recommend			= recommend
			,@roleid = roleid
    FROM	dbo.CustInfo WITH(NOLOCK)
    WHERE	custid = @custid

	
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
	
    ----check if not change value
    --IF @db_v255spositiontaking_1701 = @v255spositiontaking_1701
    --    AND @db_v255mpositiontaking_1701 = @v255mpositiontaking_1701
    --    AND @db_isauto_v255spositiontaking_1701 = @isauto_v255spositiontaking_1701
    --    AND @db_auto_v255spositiontaking_1701 = @auto_v255spositiontaking_1701
    --RETURN

    IF (@v255spositiontaking_1701 < 0 OR @v255mpositiontaking_1701 < 0
        OR @v255spositiontaking_1701 + @v255mpositiontaking_1701 > 1
        OR @auto_v255spositiontaking_1701 < 0 OR @auto_v255spositiontaking_1701 > 1)
    BEGIN
            SELECT @ErrMsg = CASE @Language 
                                WHEN 'E' THEN 'Wrong position taking.'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
							 END
							 ,@ErrCode = 100
            RETURN
    END

    SELECT @ErrType = ''

    --check n4<=s3+m3<=s4, s3<=s4 if i3 = 0, 
    --m3<=s4 and u3+m3>=n4 if i3 = 1    
    SELECT	@ErrType = @ErrType + 'Min: ' + CAST(co.minpositiontaking AS VARCHAR(10)) + ' -Max: ' + CAST(cs.spositiontaking AS VARCHAR(10)) + '<br>'
    FROM	CustSettingGame cs WITH(NOLOCK)
        INNER JOIN CustOverrideGame co WITH(NOLOCK) 
			ON	cs.custid = co.custid 
				AND cs.sporttype = co.sporttype 
				AND cs.bettype = co.bettype 
    WHERE	cs.custid = @srecommend 
			AND cs.sporttype = 255 
			AND cs.bettype = 1701
			AND (
				(@isauto_v255spositiontaking_1701 > 0 
					AND (@v255mpositiontaking_1701 + @auto_v255spositiontaking_1701 < co.minpositiontaking 
							OR @v255mpositiontaking_1701 > cs.spositiontaking
						)
				)
				OR (@isauto_v255spositiontaking_1701 = 0 
					AND (@v255spositiontaking_1701 + @v255mpositiontaking_1701 < minpositiontaking 
							OR @v255spositiontaking_1701 + @v255mpositiontaking_1701 > cs.spositiontaking 
							OR @v255spositiontaking_1701 > cs.spositiontaking
						)
				)
			)

    IF @ErrType <> ''
    BEGIN    
        SELECT @ErrMsg = CASE @Language 
                            WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
						 END
						 ,@ErrCode = 101
        RETURN
    END

    --a2+m2<=m3
    SELECT @ErrAcc = ''

    SELECT	TOP 100 @ErrAcc = @ErrAcc + Username + ', '
    FROM	dbo.CustSettingGame cs WITH(NOLOCK)
		INNER JOIN dbo.CustInfo ci WITH(NOLOCK) 
			ON cs.custid = ci.custid
    WHERE	ci.mrecommend = @custid
		   AND ci.roleid     = 2
		   AND ci.Enabled    = 1
		   AND cs.sporttype  = 255
		   AND cs.bettype    = 1701
		   AND cs.mpositiontaking + cs.apositiontaking > @v255mpositiontaking_1701

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

    SELECT	TOP 100 @ErrAcc = @ErrAcc + Username + ', '
    FROM	dbo.CustSettingGame cs WITH(NOLOCK)
		INNER JOIN dbo.CustInfo ci WITH(NOLOCK) 
			ON	cs.custid = ci.custid 
    WHERE	ci.mrecommend = @custid
			AND ci.roleid     = 1
			AND ci.Enabled    = 1
			AND cs.sporttype  = 255
			AND cs.bettype    = 1701
			AND cs.mpositiontaking + cs.apositiontaking > @v255mpositiontaking_1701 

    IF @ErrAcc <> ''
    BEGIN    
        SELECT	@ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ').'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
                 END
				,@ErrCode = 103
        RETURN
    END

    --m3>=u2
    SELECT @ErrAcc = ''

    SELECT	TOP 100 @ErrAcc = @ErrAcc + Username + ', '
    FROM	dbo.CustSettingGame cs WITH(NOLOCK)
	INNER JOIN CustInfo ci WITH(NOLOCK) 
		ON	cs.custid = ci.custid 
    WHERE   ci.mrecommend = @custid
		   AND ci.roleid     = 2
		   AND ci.Enabled    = 1
		   AND cs.sporttype  = 255
		   AND cs.bettype    = 1701
		   AND cs.isautompositiontaking = 1
		   AND cs.autompositiontaking > @v255mpositiontaking_1701

    IF @ErrAcc <> ''
    BEGIN        
        SELECT	@ErrMsg = CASE @Language
                           WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                         END
				,@ErrCode = 104
        RETURN
    END

    --check u3<=s4
    SELECT @ErrType = ''

    SELECT	@ErrType = @ErrType + 'Max: ' + CAST (cs.spositiontaking AS VARCHAR(10)) + '<br>'
    FROM	dbo.CustSettingGame cs WITH(NOLOCK)        
    WHERE	custid = @srecommend 
			AND sporttype = 255 
			AND bettype = 1701
			AND @auto_v255spositiontaking_1701 > spositiontaking 

    IF @ErrType <>''    
    BEGIN
        SELECT	@ErrMsg =   @UserName + ': '+
                            CASE @Language 
                                WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            END    
                            ,@ErrCode = 105
        RETURN
    END

    IF @v255UpdatePositiontaking_1701 = 1
    BEGIN
        UPDATE	dbo.CustSettingGame WITH(UPDLOCK,ROWLOCK)
			SET spositiontaking = @v255spositiontaking_1701
				,mpositiontaking = @v255mpositiontaking_1701
        WHERE	custid = @custid 
				AND sporttype = 255 
				AND bettype = 1701 

        IF (@@error <> 0)
        BEGIN
            SELECT @ErrMsg = @UserName + ': '+
                            CASE @Language 
                                WHEN 'E' THEN 'Update process is unsuccessful !'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                            END    
                            ,@ErrCode = 106                 
            RETURN
        END
    END

    IF @v255UpdateAutoPositiontaking_1701 = 1
    BEGIN
        --Update Master Agent account (autopositiontaking field)
        UPDATE	CustSettingGame WITH(UPDLOCK,ROWLOCK)
        SET		autopositiontaking		= @auto_v255spositiontaking_1701
				,isautopositiontaking	= @isauto_v255spositiontaking_1701
        WHERE	custid = @custid 
				AND sporttype = 255 
				AND bettype = 1701
        
        IF @@Error <> 0
        BEGIN
            
            SELECT	@ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Error updating auto position taking'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
							  END    
					,@ErrCode=201
					
            RETURN
        END
        
        EXEC dbo.Acc_CustSetting3rd_05
            @srecommend = @srecommend,
            @mrecommend = @custid,
            @roleid = 3,
            @mode = 'GoldDeluxe',
            
            @isauto_v255spositiontaking_1701 = @isauto_v255spositiontaking_1701,
            @old_isauto_v255spositiontaking_1701 = @db_isauto_v255spositiontaking_1701,
            
            @auto_v255spositiontaking_1701 = @auto_v255spositiontaking_1701, 
            
            @Updateallmembers = @Updateallmembers,
            @newspositiontaking = @newspositiontaking           
    END

    IF @v255UpdateAutoPositiontaking_1701 = 1 OR @v255UpdatePositiontaking_1701 = 1
    BEGIN
         EXEC dbo.Acc_CustSetting3rd_07
            @srecommend = @srecommend,
            @mrecommend = @custid,
            @roleid = 3,
            @mode = 'GoldDeluxe',
            @sporttype = 255,
            @bettype = 1701
                
        IF (@@error <> 0)
        BEGIN        
            SELECT	@ErrMsg = @UserName + ': '+ CASE @Language 
													WHEN 'E' THEN 'Update process is unsuccessful !'
													ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
												END
					,@ErrCode = 107             
            
            RETURN
        END		
    END

    DECLARE @LogSPData VARCHAR(MAX),
            @TrackingValueDB VARCHAR(4000)
         
    SELECT @LogSPData = '<Acc_CustomerUpdMasterGoldDeluxe_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
					'v255spositiontaking_1701="' + COALESCE(CAST(@v255spositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'v255mpositiontaking_1701="' + COALESCE(CAST(@v255mpositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'isauto_v255spositiontaking_1701="' + COALESCE(CAST(@isauto_v255spositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'auto_v255spositiontaking_1701="' + COALESCE(CAST(@auto_v255spositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'v255UpdatePositiontaking_1701="' + COALESCE(CAST(@V255UpdatePositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'v255UpdateAutoPositiontaking_1701="' + COALESCE(CAST(@V255UpdateAutoPositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'updateallmembers="' + COALESCE(CAST (@updateallmembers AS VARCHAR(3)), SPACE(1)) + '" ' +
					'newspositiontaking="' + COALESCE(CAST (@newspositiontaking AS VARCHAR(30)), SPACE(1)) + '" ' +

					'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
					'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
					'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
					'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
					'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
					'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'

    SELECT @TrackingValueDB = '<Acc_CustomerUpdMasterGoldDeluxe_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
					'v255spositiontaking_1701="' + COALESCE(CAST(@db_v255spositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'v255mpositiontaking_1701="' + COALESCE(CAST(@db_v255mpositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'isauto_v255spositiontaking_1701="' + COALESCE(CAST(@db_isauto_v255spositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'auto_v255spositiontaking_1701="' + COALESCE(CAST(@db_auto_v255spositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'v255UpdatePositiontaking_1701="' + COALESCE(CAST(@V255UpdatePositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'v255UpdateAutoPositiontaking_1701="' + COALESCE(CAST(@V255UpdateAutoPositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
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
            @ActionID = 458,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END TRY
    BEGIN CATCH
        SELECT @LogSPData = '<Acc_CustomerUpdMasterGoldDeluxe_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
					'v255spositiontaking_1701="' + COALESCE(CAST(@v255spositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'v255mpositiontaking_1701="' + COALESCE(CAST(@v255mpositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'isauto_v255spositiontaking_1701="' + COALESCE(CAST(@isauto_v255spositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'auto_v255spositiontaking_1701="' + COALESCE(CAST(@auto_v255spositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'v255UpdatePositiontaking_1701="' + COALESCE(CAST(@V255UpdatePositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'v255UpdateAutoPositiontaking_1701="' + COALESCE(CAST(@V255UpdateAutoPositiontaking_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
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
            @ActionID = 458,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_Positiontaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_Positiontaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_Positiontaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_Positiontaking] TO [vnteam] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_Positiontaking] TO [vnteam] AS [dbo]