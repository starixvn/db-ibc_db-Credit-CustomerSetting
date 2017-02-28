ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentKeno_PositionTaking]
(
	@custid INT
	, @SportType INT = 202
	, @BetType INT

	, @m2 SMALLMONEY --m2
	, @um2 SMALLMONEY --um2
	, @im2 BIT = 0 --im2
	, @a2 SMALLMONEY --a2
	, @n2 SMALLMONEY --n2
	
	, @UpdateAllMembers	BIT = 0
	, @NewMPositionTaking SMALLMONEY = 0 --equals max(m+a) - chosen(a)
	
	, @UpdatePositionTaking BIT = 0
	, @UpdateAutoPositionTaking	BIT = 0
	, @UpdateMinPositionTaking	BIT = 0
	
	, @SubAccID INT = 0 --Sub-AccountID		
	, @UserID	INT = 0
	, @Language VARCHAR(2) = 'E'
	, @IP VARCHAR(15) = ''
	, @ErrCode INT = 0 OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
)
AS
/*
	Created: 20140320@Patrick
	Task: Master update agent's Keno PT setting
	DB: DBCust/CustDB
	
	Revisions:
		- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB, Use temp table for sports, bettype table)
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]	
	Parameters Explanation:
		@ErrCode: 0 is successful
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT, @UserName NVARCHAR(50), @mrecommend INT, @srecommend INT
		, @ErrAcc VARCHAR(4000), @ErrType VARCHAR(4000)
	SET @startRun = GETDATE()

	----- Elodie @ 01 JUN 2015 -------------------
	DECLARE @tmp_Sports TABLE (SportType TINYINT, SportName NVARCHAR(50))
	DECLARE @tmp_Bettype TABLE (TypeID INT, TypeNamee NVARCHAR(50))
	
	BEGIN TRY
		INSERT INTO @tmp_Sports (SportType, SportName)
		SELECT SportType, SportName FROM DBAGE.bodb02.dbo.Sports WITH (NOLOCK)		
	END TRY
	BEGIN CATCH
		INSERT INTO @tmp_Sports (SportType, SportName)
		SELECT SportType, SportName FROM DBTXN.bodb02.dbo.Sports WITH (NOLOCK)	
	END CATCH

	BEGIN TRY			
		INSERT INTO @tmp_Bettype (TypeID, TypeNamee)
		SELECT TypeID, TypeNamee FROM DBAGE.bodb02.dbo.Bettype WITH (NOLOCK)
	END TRY
	BEGIN CATCH		
		INSERT INTO @tmp_Bettype (TypeID, TypeNamee)
		SELECT TypeID, TypeNamee FROM DBTXN.bodb02.dbo.Bettype WITH (NOLOCK)
	END CATCH
	----- /Elodie @ 01 JUN 2015 -------------------

	--Checking total downlines before UPDATEs 
	EXEC Acc_CustomerSelCheckAllowedDownlines @custid = @custid
		, @roleid = 2
		, @isExecRep = 1
		, @isUpdatePT = 1
		, @Sporttype = 1
		, @Language = 'E'
		, @ErrMsg = @ErrMsg OUTPUT
		, @ErrCode = @ErrCode OUTPUT

	IF	@ErrCode <> 0 
		RETURN 
	
	DECLARE @roleid TINYINT
	SELECT @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend
		,@roleid = roleid
	FROM dbo.custinfo WITH(NOLOCK)
	WHERE CustID = @CustID
	
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END

	
	DECLARE @Old_APositionTaking SMALLMONEY, @Old_MPositionTaking SMALLMONEY
		, @Old_Auto_MPositionTaking SMALLMONEY,	@Old_IsAuto_MPositionTaking BIT
		, @MPositiontaking_Max SMALLMONEY, @MaxPos SMALLMONEY

	SELECT @Old_MPositionTaking = mpositiontaking, @Old_APositionTaking = apositiontaking
		, @Old_Auto_MPositionTaking = autompositiontaking, @Old_IsAuto_MPositiontaking = isautompositiontaking	
	FROM dbo.CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType
	
	--check if not change setting
	IF (@Old_MPositionTaking = @m2	AND @Old_APositionTaking = @a2
		AND @Old_Auto_MPositionTaking = @um2 AND @Old_IsAuto_MPositionTaking = @im2)
		RETURN

	IF (@a2 < 0 OR @m2 < 0 OR @a2 + @m2 > 1)
	BEGIN
		SELECT @ErrCode = 100
		SELECT @ErrMsg = @UserName + ': '+ CASE @Language
							WHEN 'E' THEN 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) END
		RETURN
	END
	
	--check n3<=m2+a2  if im2 = 0, 
	--a2<=l3 and um2+a2>=n3 if im2 = 1
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee + '-Min: '+ CAST((co.minpositiontaking) AS VARCHAR(10)) + '<br>'
	FROM dbo.custoverrideGame co WITH(NOLOCK)
		INNER JOIN 
		(
			SELECT @BetType AS bettype, @SportType AS sporttype
				, @a2 AS apositiontaking, @m2 AS mpositiontaking
				, @im2 AS isauto_mpositiontaking, @um2 AS auto_mpositiontaking
		) b ON co.bettype = b.bettype AND co.sporttype = b.sporttype
		INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
	WHERE co.custid = @mrecommend
		AND (((b.isauto_mpositiontaking = 0) AND (b.mpositiontaking + b.apositiontaking < co.minpositiontaking)) 
			OR (b.isauto_mpositiontaking > 0 AND (b.apositiontaking + b.auto_mpositiontaking < co.minpositiontaking)))

	IF @ErrType <> ''
	BEGIN
		SELECT @ErrCode = 101
		SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
							WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>' + @ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002, @Language) + '<br>' + @ErrType END
		RETURN
	END

	--n2<=a2
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee + '-Min: '+ CAST((co.minpositiontaking) AS VARCHAR(10)) + '<br>'
	FROM (SELECT @BetType AS bettype, @SportType AS sporttype, @n2 AS minpositiontaking) AS co
		INNER JOIN (SELECT @BetType AS bettype, @SportType AS sporttype, @a2 AS apositiontaking) AS b
			ON co.bettype = b.bettype AND co.sporttype = b.sporttype
		INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
	WHERE b.apositiontaking < co.minpositiontaking

	IF @ErrType <> ''
	BEGIN
		SELECT @ErrCode = 102
		SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
							WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>' + @ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002, @Language) + '<br>' + @ErrType END
		RETURN
	END
	
	SELECT @MPositiontaking_Max = mpositiontaking 
	FROM dbo.CustSettingGame WITH(NOLOCK) 
	WHERE custid = @mrecommend AND bettype = @BetType AND sporttype = @SportType
	
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType +  'Max: '+ CAST((b.max_mapositiontaking) AS VARCHAR(10)) + '<br>'
	FROM
	(
		SELECT @BetType AS bettype, @SportType AS sporttype, @a2 AS apositiontaking
			, @m2 AS mpositiontaking, @MPositiontaking_Max AS max_mapositiontaking
	) b
		INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
	WHERE (b.apositiontaking + b.mpositiontaking > b.max_mapositiontaking) 

	IF @ErrType <> ''
	BEGIN
		select @ErrCode = 103
		Select @ErrMsg = @UserName + ': '+ CASE @Language 
							WHEN 'E' THEN 'Wrong position taking.<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + '<br>' + @ErrType END
		RETURN
	END
	
	--check um2<=min(m3,l3)
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee + '-Max: '+ CAST(max_mapositiontaking AS VARCHAR(10)) + '<br>'
	FROM 
	(
		SELECT @BetType AS bettype, @SportType AS sporttype, @um2 as autopositiontaking
			, @im2 as isautopositiontaking, @MPositiontaking_Max as max_mapositiontaking
	) AS b 
		INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
	WHERE b.isautopositiontaking = 1
		AND b.autopositiontaking > max_mapositiontaking
		

	IF @ErrType <> ''
	BEGIN
		SELECT @ErrCode = 104
		SELECT @ErrMsg = @UserName + ': ' + CASE @Language 
							WHEN 'E' THEN 'Wrong position taking.<br>' + @ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + '<br>' + @ErrType END
		RETURN
	END
	
	--update
	IF @UpdatePositiontaking = 1
	BEGIN	
		UPDATE dbo.CustSettingGame WITH (ROWLOCK, UPDLOCK)
		SET apositiontaking = @a2
			, mpositiontaking = @m2
		WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType

		IF (@@ERROR <> 0)
		BEGIN
			SELECT @ErrMsg = @UserName + ':' + CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language) END
				, @ErrCode = 105
			RETURN
		END
	END
		
	--Update Master Agent account
	IF @UpdateAutoPositiontaking = 1
	BEGIN	
		UPDATE dbo.CustSettingGame WITH (ROWLOCK, UPDLOCK) 
		SET autompositiontaking	= @um2
			, isautompositiontaking	= @im2
		WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType
		
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
					WHEN 'E' THEN 'Error updating auto position taking'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](20010, @Language) END
				,  @ErrCode = 106
			RETURN
		END
		--Call execrep
		IF (@um2 <> @Old_Auto_MPositionTaking OR @im2 <> @Old_IsAuto_MPositionTaking)
		BEGIN
												EXEC dbo.Acc_CustSetting3rd_05 @mrecommend = @mrecommend
					, @recommend = @custid
					, @roleid = 2
					, @mode = 'Keno'
					, @KenoBettype = @Bettype
					, @IsAuto_KenoMPositionTaking = @im2
					, @Old_IsAuto_KenoMPositionTaking = @Old_IsAuto_MPositiontaking
					, @Auto_KenoMPositionTaking = @um2
					, @UpdateAllMembers = @UpdateAllMembers
					, @NewMPositionTaking = @NewMPositionTaking
		END
	END
	
	IF @UpdatePositiontaking = 1 AND @UpdateAutoPositiontaking = 0 AND @UpdateAllMembers = 1 AND @im2 = 0        
	BEGIN   
								EXEC dbo.Acc_CustSetting3rd_05 		
			@recommend = @custid,
			@roleid = 2,
			@mode = 'Keno',
			@KenoBettype = @Bettype,

			@IsAuto_KenoMPositionTaking = @im2, --im2
			@Old_IsAuto_KenoMPositionTaking = @Old_IsAuto_MPositionTaking,--old_im2
		
			@updateautopositiontakingv202 = 0,						
			@newmpositiontaking = @NewMPositionTaking         
	END		

	IF (@UpdateAutoPositionTaking = 1 OR @UpdatePositionTaking = 1)
	BEGIN 
								EXEC dbo.Acc_CustSetting3rd_07 @recommend = @custid, @roleid = 2, @mode = 'Keno', @Sporttype = @SportType, @BetType = @Bettype
		IF (@@ERROR <> 0)
		BEGIN
			SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language) END
				, @ErrCode = 109					 
			RETURN
		END
	END

	DECLARE @LogSPData VARCHAR(MAX), @TrackingValueDB VARCHAR(4000)

	SELECT @LogSPData ='<Acc_CustomerUpdAgentKeno_PositionTaking CustID="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) 
		+ '" ' + 'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) 
		+ '" ' + 'UpdateAllMembers="' + COALESCE(CAST(@UpdateAllMembers AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'NewMPositionTaking="' + COALESCE(CAST(@NewMPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'a2="' + COALESCE(CAST(@a2 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'm2="' + COALESCE(CAST(@m2 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'um2="' + COALESCE(CAST(@um2 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'im2="' + COALESCE(CAST(@im2 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	SELECT @TrackingValueDB ='<Acc_CustomerUpdAgentKeno_PositionTaking CustID="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) 
		+ '" ' + 'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) 
		+ '" ' + 'UpdateAllMembers="' + COALESCE(CAST(@UpdateAllMembers AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'NewMPositionTaking="' + COALESCE(CAST(@NewMPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'a2="' + COALESCE(CAST(@Old_APositiontaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'm2="' + COALESCE(CAST(@Old_MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'um2="' + COALESCE(CAST(@Old_Auto_MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'im2="' + COALESCE(CAST(@Old_IsAuto_MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	select @endRun = GETDATE(), @duration = DATEDIFF (MILLISECOND, @startRun, @endRun)

	--Log positiontaking
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 444
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 444
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END CATCH	
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentKeno_PositionTaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentKeno_PositionTaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentKeno_PositionTaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentKeno_PositionTaking] TO [vnteam] AS [dbo]