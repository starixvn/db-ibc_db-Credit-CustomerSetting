ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableKeno] 
	@CustID INT
	,@Bettype INT
	,@Disable BIT			
	,@DisableDownLines BIT = 1

	,@SubAccID INT = 0
	,@UserID INT
	,@UplineID INT	= 0
	,@Language VARCHAR(2) = 'E'
	,@Errcode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
	,@IP VARCHAR(15) = ''
AS
/*
	Created: Elodie
	Date: 20140225
	Task: Update Keno status for customer
	DB: DBCUST/CustDB
	Original: 
	Revisions:
		20140227@Bobby: Implement upd disabled keno gaming for credit customers
		20140320@Bobby: Implement tracking values & cheking HasDownline
		20141125@Jamie: Use Acc_CustomerInfo_Execrep_04 instead of Acc_ExecRep_Cust_04 [Redmine:#26497]
		- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines, Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID)
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
		
	Param's Explanation:
		• @custid: customer id.   
		• @Disable: status of HideKeno
		• @DisableDownLines: 0|1: 0 affect to downlines and vice versa
		
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT

	SET @startRun = GETDATE()

	
	DECLARE @RoleID TINYINT
		,@RoleID_Ck TINYINT
		,@UplineHideKeno BIT = 0
		,@UplineDisable BIT = 0
		,@Old_HideKeno BIT
		,@Old_DisableBetType BIT
		,@GameTypeID INT
		,@HasUpdatedDisable BIT = 0
		,@HasDownline BIT = 0

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT

	IF (@ErrCode <> 0) RETURN

	SELECT	@RoleID = RoleID, 
			@Old_HideKeno = ISNULL(HideKeno, 0)
	FROM dbo.CustInfo WITH (NOLOCK)
	WHERE CustID = @CustID

	            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END

	
	SELECT	@HasDownline = 1 
	FROM dbo.CustInfo WITH (NOLOCK)
	WHERE (@RoleID = 4 AND srecommend = @CustID and roleid = 3)
		OR (@RoleID = 3 AND mrecommend = @CustID and roleid = 2)
		OR (@RoleID = 2 AND recommend = @CustID and roleid = 1)

	IF(@RoleID = 1)
	BEGIN
		---------------------------
		-- ***Check Downline Belonging***
		EXEC dbo.Age_CustomerSelCheckBelongingByCustID 
			@SessionCustID = @Userid, 
			@Custid = @custid,
			@roleid = @RoleID_Ck OUTPUT
		IF (@RoleID_Ck = 0) RETURN
	END


	IF (@RoleID NOT IN (1, 2, 3, 4))
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Invalid user!'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](40002, @Language)
				END
			,@ErrCode = 100

		RETURN
	END

	-- update CustGameType proccess
	SELECT @GameTypeID = g.GameTypeID
	FROM DBPRO.bodb02.dbo.GameType g WITH(NOLOCK)
	WHERE g.IBCBetTypeID = @Bettype
		AND g.IsDisabled = 0 -- active bettype
	
	SET @GameTypeID = ISNULL(@GameTypeID, 0)

	-- get old status on keno bettype	
	SELECT TOP(1) @Old_DisableBetType = ISNULL(c.IsDisabled, 1)
	FROM dbo.CustGameType c WITH(NOLOCK)
	WHERE c.custid = @CustID
		AND c.GameTypeID = @GameTypeID
		
	SET @Old_DisableBetType = ISNULL(@Old_DisableBetType, 1)

	-- check to update IsDisabled
	IF(@GameTypeID > 0
		AND ( @Old_DisableBetType <> @Disable )
	)
	BEGIN
		-- check uplineDisable
		IF (@RoleID = 3) 
			SELECT TOP(1) @UplineDisable = CASE 
				WHEN c.HideKeno = 0 AND ISNULL(IsDisabled, 0) = 0 THEN 0 
				ELSE 1 END
			FROM dbo.CustInfo c WITH (NOLOCK)
			LEFT JOIN dbo.CustGameType g WITH (NOLOCK)
				ON g.custid = c.custid
			WHERE g.custid = (SELECT SRecommend FROM dbo.Custinfo WITH (NOLOCK)
							WHERE custid = @CustID)
				and g.GameTypeID = @GameTypeID

		IF (@RoleID = 2) 
			SELECT TOP(1) @UplineDisable = CASE 
				WHEN c.HideKeno = 0 AND ISNULL(IsDisabled, 0) = 0 THEN 0 
				ELSE 1 END
			FROM dbo.CustInfo c WITH (NOLOCK)
			LEFT JOIN dbo.CustGameType g WITH (NOLOCK)
				ON g.custid = c.custid
			WHERE g.custid = (SELECT MRecommend FROM dbo.Custinfo WITH (NOLOCK)
							WHERE custid = @CustID)
				and g.GameTypeID = @GameTypeID

		IF (@RoleID = 1) 
			SELECT TOP(1) @UplineDisable = CASE 
				WHEN c.HideKeno = 0 AND ISNULL(IsDisabled, 0) = 0 THEN 0 
				ELSE 1 END
			FROM dbo.CustInfo c WITH (NOLOCK)
			LEFT JOIN dbo.CustGameType g WITH (NOLOCK)
				ON g.custid = c.custid
			WHERE g.custid = (SELECT Recommend FROM dbo.Custinfo WITH (NOLOCK)
							WHERE custid = @CustID)
				and g.GameTypeID = @GameTypeID

		IF (@RoleID = 4) SET @UplineDisable = 0 --not checking the upline when the customer is the super

		IF (@UplineDisable = 1)
		BEGIN
			SELECT @ErrMsg = CASE @Language
					WHEN 'E' THEN 'Account was disabled Keno. Unable to edit downlines.'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](60030, @Language)
					END
				,@ErrCode = 101

			RETURN
		END

		UPDATE g
		SET IsDisabled = @Disable
		FROM dbo.CustGameType g WITH(ROWLOCK, UPDLOCK)
		WHERE g.custid = @CustID
			AND g.GameTypeID = @GameTypeID

		--Check condition for update all downline
		IF ( @RoleID > 1 
				AND (@Disable = 1
						OR (@Disable = 0 AND (@DisableDownlines = 0 AND @HasDownline = 1))
				)
			)
		BEGIN
			EXEC Acc_CustomerSelCheckAllowedDownlines @custid = @custid
				,@roleid = @roleid
				,@isExecRep = 1
				,@Language = @Language
				,@ErrMsg = @ErrMsg OUTPUT
				,@ErrCode = @ErrCode OUTPUT

			IF @ErrCode <> 0 RETURN

			--Disable all downline or enable all downline
			BEGIN TRY
				EXEC [Acc_Custsetting3rd_10] @CustID = @CustID
					,@RoleID = @RoleID
					,@Action = 'UpdKeno-Disable'
					,@DisableKeno = @Disable
					,@GameTypeID = @GameTypeID
			END TRY
			BEGIN CATCH
				SELECT @ErrMsg = CASE @Language
						WHEN 'E' THEN 'Update process is unsuccessful.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)
						END
				SET @ErrCode = 102
				RETURN
			END CATCH
		END

		SET @HasUpdatedDisable = 1
	END

	IF(@GameTypeID = 0)
	BEGIN
		SELECT @ErrMsg = 'Bettype is disabled. Update process is unsuccessful.'
			,@ErrCode = 105

		RETURN
	END

	-- check to update HideKeno
	IF (@HasUpdatedDisable = 1 
		AND @Old_HideKeno = 1) 
	BEGIN
		UPDATE cust
		SET HideKeno = 0
		FROM dbo.CustInfo cust WITH (ROWLOCK, UPDLOCK)
		WHERE CustID = @CustID
		
		IF(@RoleID > 1 
			AND @HasDownline = 1)
		BEGIN
			BEGIN TRY	
				--update HideKeno for all downline
				EXEC [Acc_CustomerInfo_Execrep_04] @CustID = @CustID
					,@RoleID = @RoleID
					,@Action = 'UpdKeno-Hide'	
			END TRY
			BEGIN CATCH
				SELECT @ErrMsg = CASE @Language
						WHEN 'E' THEN 'Update process is unsuccessful.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)
						END

				SET @ErrCode = 103

				RETURN
			END CATCH
		END
	END
	
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Update process is unsuccessful.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)
				END
			,@ErrCode = 104

		RETURN
	END
	
	IF(@HasUpdatedDisable = 0) RETURN

	-- write runSP log
	DECLARE @LogSPData VARCHAR(2000)
		, @TrackingValue VARCHAR(2000)
	

	SELECT @LogSPData = '<Acc_CustomerUpdDisableKeno CustID="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Bettype="' + coalesce(cast(@Bettype AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Disable="' + coalesce(cast(@Disable AS VARCHAR(50)), space(1)) + '" ' 
		+ 'DisableDownlines="' + CASE WHEN @HasDownline = 1 THEN coalesce(cast(@DisableDownlines AS VARCHAR(50)), space(1)) ELSE '' END  + '" ' 
		+ 'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' 
		+ 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'UplineID="' + coalesce(cast(@UplineID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' 
		+ 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(50)), space(1)) + '" ' 
		+ 'ErrMsg="' + coalesce(cast(@ErrMsg AS VARCHAR(400)), space(1)) + '" ' 
		+ 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" />'
		--tracking values
		,@TrackingValue = '<Acc_CustomerUpdDisableKeno CustID="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Bettype="' + coalesce(cast(@Bettype AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Disable="' + coalesce(cast(@Old_DisableBetType AS VARCHAR(50)), space(1)) + '" ' 
		+ 'DisableDownlines="' + CASE WHEN @HasDownline = 1 THEN coalesce(cast(@DisableDownlines AS VARCHAR(50)), space(1)) ELSE '' END  + '" ' 
		+ 'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' 
		+ 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'UplineID="' + coalesce(cast(@UplineID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' 
		+ 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(50)), space(1)) + '" ' 
		+ 'ErrMsg="' + coalesce(cast(@ErrMsg AS VARCHAR(400)), space(1)) + '" ' 
		+ 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" />'

	SET @endRun = GETDATE()
	SET @duration = DATEDIFF(millisecond, @startRun, @endRun)

	/*1148	Acc_CustomerUpdDisableKeno	Update Enabled/Disabled Keno status*/
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = 1148
			,@Doing = 'Update Keno status for credit customer'
			,@TrackingValue = @LogSPData
			,@TrackingValue2 = @TrackingValue
			,@duration = @duration
	END TRY

	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdDisableKeno CustID="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' 
			+ 'Bettype="' + coalesce(cast(@Bettype AS VARCHAR(50)), space(1)) + '" ' 
			+ 'Disable="' + coalesce(cast(@Disable AS VARCHAR(50)), space(1)) + '" ' 
			+ 'DisableDownlines="' + CASE WHEN @HasDownline = 1 THEN coalesce(cast(@DisableDownlines AS VARCHAR(50)), space(1)) ELSE '' END  + '" ' 
			+ 'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' 
			+ 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' 
			+ 'UplineID="' + coalesce(cast(@UplineID AS VARCHAR(50)), space(1)) + '" ' 
			+ 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' 
			+ 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(50)), space(1)) + '" ' 
			+ 'ErrMsg="' + ERROR_MESSAGE() + '" ' 
			+ 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = 1148
			,@Doing = 'Update Keno status for credit customer'
			,@TrackingValue = @LogSPData
			,@TrackingValue2 = @TrackingValue
			,@duration = @duration
	END CATCH

	RETURN
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableKeno] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableKeno] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableKeno] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdDisableKeno] TO [vnteam] AS [dbo]