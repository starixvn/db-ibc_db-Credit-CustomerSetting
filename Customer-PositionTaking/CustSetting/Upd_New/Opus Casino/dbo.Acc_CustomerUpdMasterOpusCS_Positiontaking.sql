ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterOpusCS_Positiontaking]
	@custid INT,
	@v163spositiontaking_1401 SMALLMONEY,
	@v163mpositiontaking_1401	SMALLMONEY,
	
	@isauto_v163spositiontaking_1401 BIT,
	@auto_v163spositiontaking_1401	SMALLMONEY,
	
	@v163UpdatePositiontaking_1401	BIT,
	@v163UpdateAutoPositiontaking_1401 BIT,
	
	@updateallmembers	BIT = 0,
	@newspositiontaking SMALLMONEY = 0,
	
	@SubAccID	INT = 0, -- Sub Account
	@UserID		INT = 0	,
	@IP			VARCHAR(50)= '',	
	@Language	VARCHAR(20) = 'E',		
	
	@ErrCode	VARCHAR(300) = '' OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS 
	/*
		Created: Johnson
		Date: 20131119
		Task: Update pt on master for Opus Casino
		DB: DBTXN/bodb02
		
		Revisions:
		
		Parameter's Explanation:
			
	*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT

	SET @startRun = GETDATE()

	DECLARE @roleid			TINYINT, 			
			@UserName		VARCHAR(30), 
			@srecommend		INT, 
			@ErrType		VARCHAR(4000),
			@ErrCode_Cur	INT, 
			@ErrMsg_Cur		NVARCHAR(4000), 
			@ErrAcc			NVARCHAR(4000)


	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	---- Checking total downlines before UPDATEs 
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
		@roleid=3,
		@isExecRep=1,
		@isUpdatePT = 1,
		@Sporttype = 1,
		@Language='E',
		@ErrMsg=@ErrMsg output,
		@ErrCode=@ErrCode output
	IF	@ErrCode <> 0 
		RETURN 
	
	DECLARE @db_v163spositiontaking_1401	SMALLMONEY,
		@db_v163mpositiontaking_1401		SMALLMONEY,	
		@db_isauto_v163spositiontaking_1401 BIT,
		@db_auto_v163spositiontaking_1401	SMALLMONEY	
	
	SELECT @db_v163spositiontaking_1401 = spositiontaking,
		@db_v163mpositiontaking_1401 = mpositiontaking,
		@db_isauto_v163spositiontaking_1401 = isautopositiontaking,
		@db_auto_v163spositiontaking_1401 = autopositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = 163 AND bettype = 1401
	
	SELECT @username = username , @srecommend = srecommend
	FROM CustInfo WITH(NOLOCK)
	WHERE custid = @custid

	--check if not change value
	IF @db_v163spositiontaking_1401 = @v163spositiontaking_1401
		AND @db_v163mpositiontaking_1401 = @v163mpositiontaking_1401
		AND @db_isauto_v163spositiontaking_1401 = @isauto_v163spositiontaking_1401
		AND @db_auto_v163spositiontaking_1401 = @auto_v163spositiontaking_1401		
	RETURN	
			
	IF (@v163spositiontaking_1401 < 0 OR @v163mpositiontaking_1401 < 0
		OR @v163spositiontaking_1401 + @v163mpositiontaking_1401 > 1
		OR @auto_v163spositiontaking_1101 < 0 OR @auto_v163spositiontaking_1401 > 1)
	BEGIN
			Select @ErrMsg = 	case @Language 
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
	WHERE cs.custid = @srecommend AND cs.sporttype = 163 AND cs.bettype = 1401
		AND ((@isauto_v163spositiontaking_1401 > 0 AND (@v163mpositiontaking_1401 + @auto_v163spositiontaking_1401 < co.minpositiontaking OR @v163mpositiontaking_1401 > cs.spositiontaking))
		OR (@isauto_v163spositiontaking_1401 = 0 AND (@v163spositiontaking_1401 + @v163mpositiontaking_1401 < minpositiontaking OR @v163spositiontaking_1401 + @v163mpositiontaking_1401 > cs.spositiontaking OR @v163spositiontaking_1401 > cs.spositiontaking)))

	IF @ErrType <> ''
	BEGIN	
		SELECT @ErrMsg = 	CASE @Language 
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
	WHERE ci.mrecommend = @custid AND ci.roleid = 2
		AND cs.sporttype = 163 AND cs.bettype = 1401
		AND cs.mpositiontaking + cs.apositiontaking > @v163mpositiontaking_1401 

	IF @ErrAcc<>''
	BEGIN		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Existing agents exceeded new master position taking ('+@ErrAcc+') .'							
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20011,@Language) + ' ('+@ErrAcc+').'
					END, @ErrCode = 102
		RETURN
	END	
		
	--a1+m1<=m3
	SELECT @ErrAcc = ''

	SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
	FROM CustSettingGame cs WITH(NOLOCK)
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
	WHERE ci.mrecommend = @custid AND ci.roleid = 1
		AND cs.sporttype = 163 AND cs.bettype = 1401
		AND cs.mpositiontaking + cs.apositiontaking > @v163mpositiontaking_1401 

	IF @ErrAcc<>''
	BEGIN	
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Existing members exceeded new master position taking ('+@ErrAcc+').'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20012,@Language) + ' ('+@ErrAcc+').'
					END, @ErrCode = 103
		RETURN
	END
		
	--m3>=u2
	SELECT @ErrAcc = ''

	SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
	FROM CustSettingGame cs WITH(NOLOCK)
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
	WHERE ci.mrecommend = @custid AND ci.roleid = 2
		AND cs.sporttype = 163 AND cs.bettype = 1401
		AND cs.isautompositiontaking = 1 AND cs.autompositiontaking > @v163mpositiontaking_1401

	IF @ErrAcc<>''
	BEGIN		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Existing agents exceeded new master position taking ('+@ErrAcc+').'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20011,@Language) + ' ('+@ErrAcc+').'
					END, @ErrCode = 104
		RETURN
	END		
	
	--check u3<=s4
	SELECT @ErrType = ''

	SELECT @ErrType = @ErrType + 'Max: ' + CAST (cs.spositiontaking AS VARCHAR(10)) + '<br>'
	FROM CustSettingGame cs WITH(NOLOCK)		
	WHERE custid = @srecommend AND sporttype = 163 AND bettype = 1401
		AND @auto_v163spositiontaking_1401 > spositiontaking 

	IF @ErrType <>''	
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
							END	, @ErrCode = 105
		RETURN
	END
	
	IF @v163UpdatePositiontaking_1401 = 1
	BEGIN
		UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK)
		SET spositiontaking = @v163spositiontaking_1401, mpositiontaking = @v163mpositiontaking_1401
		WHERE custid = @custid AND sporttype = 163 AND bettype = 1401 

		IF (@@error <> 0)
		BEGIN
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 106				 
			RETURN
		END
	END
	
		
	IF @v163UpdateAutoPositiontaking_1401 = 1
	BEGIN
		--Update Master Agent account (autopositiontaking field)
		UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK)
		SET autopositiontaking = @auto_v163spositiontaking_1401, isautopositiontaking = @isauto_v163spositiontaking_1401
		WHERE custid = @custid AND sporttype = 163 AND bettype = 1401
		
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
			@mode = 'OpusCasino',
			
			@isauto_v163spositiontaking_1401 = @isauto_v163spositiontaking_1401,
			@old_isauto_v163spositiontaking_1401 = @db_isauto_v163spositiontaking_1401,
			
			@auto_v163spositiontaking_1401 = @auto_v163spositiontaking_1401, 
			
			@Updateallmembers = @Updateallmembers,
			@newspositiontaking = @newspositiontaking
		
	END
	
	
	IF @v163UpdateAutoPositiontaking_1401 = 1 OR @v163UpdatePositiontaking_1401 = 1
	BEGIN
		EXEC dbo.Acc_CustSetting3rd_07 
			@srecommend = @srecommend,
			@mrecommend = @custid,
			@roleid = 3,
			@mode = 'OpusCasino'

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
		 
	SELECT @LogSPData = '<Acc_CustomerUpdMasterOpusCS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v163spositiontaking_1401="' + COALESCE(CAST(@v163spositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v163mpositiontaking_1401="' + COALESCE(CAST(@v163mpositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'isauto_v163spositiontaking_1401="' + COALESCE(CAST(@isauto_v163spositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'auto_v163spositiontaking_1401="' + COALESCE(CAST(@auto_v163spositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v163UpdatePositiontaking_1401="' + COALESCE(CAST(@V163UpdatePositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v163UpdateAutoPositiontaking_1401="' + COALESCE(CAST(@V163UpdateAutoPositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'updateallmembers="' + COALESCE(CAST (@updateallmembers AS VARCHAR(3)), SPACE(1)) + '" ' +
	'newspositiontaking="' + COALESCE(CAST (@newspositiontaking AS VARCHAR(30)), SPACE(1)) + '" ' +

	'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMasterOpusCS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v163spositiontaking_1401="' + COALESCE(CAST(@db_v163spositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v163mpositiontaking_1401="' + COALESCE(CAST(@db_v163mpositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'isauto_v163spositiontaking_1401="' + COALESCE(CAST(@db_isauto_v163spositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'auto_v163spositiontaking_1401="' + COALESCE(CAST(@db_auto_v163spositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v163UpdatePositiontaking_1401="' + COALESCE(CAST(@V163UpdatePositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v163UpdateAutoPositiontaking_1401="' + COALESCE(CAST(@V163UpdateAutoPositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
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
			@ActionID = 438,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdMasterOpusCS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v163spositiontaking_1401="' + COALESCE(CAST(@v163spositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v163mpositiontaking_1401="' + COALESCE(CAST(@v163mpositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'isauto_v163spositiontaking_1401="' + COALESCE(CAST(@isauto_v163spositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'auto_v163spositiontaking_1401="' + COALESCE(CAST(@auto_v163spositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v163UpdatePositiontaking_1401="' + COALESCE(CAST(@V163UpdatePositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v163UpdateAutoPositiontaking_1401="' + COALESCE(CAST(@V163UpdateAutoPositiontaking_1401 AS VARCHAR(50)),SPACE(1)) + '" ' +
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
			@ActionID = 438,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH


	
END
	

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterOpusCS_Positiontaking] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterOpusCS_Positiontaking] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterOpusCS_Positiontaking] TO [bodbExtAccNet]