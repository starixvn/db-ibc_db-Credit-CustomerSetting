/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableKeno] 
	@CustID INT
	,@Bettype INT
	,@Disable BIT	
	,@IsSC BIT = 0
	,@SystemID	TINYINT = 1
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
		- 20170303@Winnie: Change enable behavior & Allowed disable on EXT-NAP [Redmine: #72336]
		- 20170115@Johnson: use this sp for update status on alpha and remove enableDownlines for new direction [redmine:#87328]				
		- 20190517@Elodie: Change name of Keno to RNG Keno [Redmine: #113490]
		- 20200225@Tiara: Don't allow SMA under 789y headline to update status [Redmine: #124311]
		- 20200610@Johnson: add param isSC to allow SC status from i7 [redmine:#135489]
		- 20200722@Eden: Minimize UM Time - Lock updating customer settings [#136464]
		- 20221226@Tacy: Alpha/NAP - Split 789y Site [RedmineID: #181596]

	Param's Explanation:
		• @custid: customer id.   
		• @Disable: status of HideKeno		
		
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT
	DECLARE @SiteLabel VARCHAR (50)

	SET @startRun = GETDATE()

	--> Check UM config
	EXEC [Acc_CheckUM] @CustID = @CustID, @ProductID = 8
		, @Language = @Language, @FunctionType = 1
		, @ErrCode = @ErrCode OUTPUT, @ErrMsg = @ErrMsg OUTPUT 
		, @ReturnUMData = 0
		
	IF @ErrCode <>0 
		RETURN

	--Check if user is SMA under 789y headline and call update action from ALPHA/EXT - 20200225@Tiara
	SELECT @SiteLabel = s.SiteLabel
	FROM customer c with (NOLOCK)
	INNER JOIN Site s with (nolock) ON s.site=c.site
	WHERE C.custid = @UserID

	IF @SystemID != 1 AND @SiteLabel IN ('789y') AND @IsSC = 0
		RETURN
	
	DECLARE @RoleID TINYINT
		,@RoleID_Ck TINYINT
		,@UplineHideKeno BIT = 0
		,@UplineDisable BIT = 0
		,@Old_HideKeno BIT
		,@Old_DisableBetType BIT
		,@GameTypeID INT			
		,@DownlinesHideKeno BIT = 0		
		
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
	
	IF @Old_DisableBetType = @Disable
		RETURN

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
	
	--dont allow disable on alpha
	IF @Disable = 1 AND @Old_DisableBetType = 0 AND @SystemID = 2 AND @roleid IN (4,3,2)
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'You are not allowed to disable for downlines.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60035,@Language)
						END, @ErrCode = 102
		RETURN
	END 
	
	IF(ISNULL(@GameTypeID,0) = 0)
	BEGIN
		SELECT @ErrMsg = 'Bettype is disabled. Update process is unsuccessful.'
			,@ErrCode = 105

		RETURN
	END

	
	-- check uplineDisable
	IF (@RoleID = 3) 
	BEGIN
		SELECT TOP(1) @UplineDisable = CASE 
			WHEN c.HideKeno = 0 AND ISNULL(IsDisabled, 0) = 0 THEN 0 
			ELSE 1 END
		FROM dbo.CustInfo c WITH (NOLOCK)
		LEFT JOIN dbo.CustGameType g WITH (NOLOCK)
			ON g.custid = c.custid
		WHERE g.custid = (SELECT SRecommend FROM dbo.Custinfo WITH (NOLOCK)
						WHERE custid = @CustID)
			and g.GameTypeID = @GameTypeID
	END
	ELSE IF (@RoleID = 2) 
	BEGIN
		SELECT TOP(1) @UplineDisable = CASE 
			WHEN c.HideKeno = 0 AND ISNULL(IsDisabled, 0) = 0 THEN 0 
			ELSE 1 END
		FROM dbo.CustInfo c WITH (NOLOCK)
		LEFT JOIN dbo.CustGameType g WITH (NOLOCK)
			ON g.custid = c.custid
		WHERE g.custid = (SELECT MRecommend FROM dbo.Custinfo WITH (NOLOCK)
						WHERE custid = @CustID)
			and g.GameTypeID = @GameTypeID
	END
	ELSE IF (@RoleID = 1) 
	BEGIN
		SELECT TOP(1) @UplineDisable = CASE 
			WHEN c.HideKeno = 0 AND ISNULL(IsDisabled, 0) = 0 THEN 0 
			ELSE 1 END
		FROM dbo.CustInfo c WITH (NOLOCK)
		LEFT JOIN dbo.CustGameType g WITH (NOLOCK)
			ON g.custid = c.custid
		WHERE g.custid = (SELECT Recommend FROM dbo.Custinfo WITH (NOLOCK)
						WHERE custid = @CustID)
			and g.GameTypeID = @GameTypeID
	END
	ELSE IF (@RoleID = 4) 
		SET @UplineDisable = 0 --not checking the upline when the customer is the super

	IF (@UplineDisable = 1)
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Account was disabled RNG Keno. Unable to edit downlines.'
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
	
	--Disable all downline
	IF (@RoleID > 1 AND @Disable = 1)	
	BEGIN TRY
		--Check condition for update all downline		
		EXEC Acc_CustomerSelCheckAllowedDownlines @custid = @custid
			,@roleid = @roleid
			,@isExecRep = 1
			,@Language = @Language
			,@ErrMsg = @ErrMsg OUTPUT
			,@ErrCode = @ErrCode OUTPUT

		IF @ErrCode <> 0 RETURN
		
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
	
	-- check to update HideKeno
	IF (@Old_HideKeno = 1) 
	BEGIN	
		UPDATE cust
		SET HideKeno = 0
		FROM dbo.CustInfo cust WITH (ROWLOCK, UPDLOCK)
		WHERE CustID = @CustID
		
		SELECT TOP (1) @DownlinesHideKeno = HideKeno
		FROM dbo.CustInfo WITH(NOLOCK)
		WHERE (@RoleID = 4 AND srecommend = @CustID AND Custid <> @CustID AND HideKeno = 1)
			OR (@RoleID = 3 AND mrecommend = @CustID AND Custid <> @CustID AND HideKeno = 1)
			OR (@RoleID = 2 AND recommend = @CustID AND Custid <> @CustID AND HideKeno = 1)
				
		IF(@RoleID > 1 			
			AND @DownlinesHideKeno = 1
			)--touch on downline
		BEGIN
			BEGIN TRY	
				--update HideKeno for all downline
				EXEC [Acc_CustomerInfo_Execrep_04] @CustID = @CustID
					,@RoleID = @RoleID
					,@Action = 'UpdKeno-Hide'	
					,@UpdateAllMasters = 1
					,@UpdateAllAgents = 1
					,@UpdateAllMembers = 1
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
		
	-- write runSP log
	DECLARE @LogSPData VARCHAR(2000)
		, @TrackingValue VARCHAR(2000)
		, @ActionID INT

	SELECT @LogSPData = '<Acc_CustomerUpdDisableKeno CustID="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Bettype="' + coalesce(cast(@Bettype AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Disable="' + coalesce(cast(@Disable AS VARCHAR(50)), space(1)) + '" ' 		
		+ 'IsSC="' + coalesce(cast(@IsSC AS VARCHAR(1)), space(1)) + '" ' 		
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
		+ 'IsSC="' + coalesce(cast(@IsSC AS VARCHAR(1)), space(1)) + '" ' 		
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
		--write log for themself
		SELECT @ActionID = CASE @roleid WHEN 4 THEN 60002 
										WHEN 3 THEN 65004 
										WHEN 2 THEN 70006
										WHEN 1 THEN 75008 END
										
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = @ActionID
			,@Doing = 'Update Keno status for credit customer'
			,@TrackingValue = @LogSPData
			,@TrackingValue2 = @TrackingValue
			,@duration = @duration
		
		--write log for downlines in-case disable downline
		IF @Disable = 1 
		BEGIN
			IF @roleid >3
			BEGIN
				SELECT @ActionID = 65005
				
				--actionID on master
				EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@Doing = 'Update Keno status for credit customer',
					@TrackingValue = @LogSPData  , 
					@TrackingValue2 = @TrackingValue  ,  
					@duration = @duration  
			END
			
			IF @Roleid >2
			BEGIN
				SELECT @ActionID = CASE @roleid WHEN 3 THEN 70007 
												WHEN 4 THEN 70008 END
										
				--actionID on agent
				EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@Doing = 'Update Keno status for credit customer',
					@TrackingValue = @LogSPData  , 
					@TrackingValue2 = @TrackingValue  ,  
					@duration = @duration 
			END
			
			IF @Roleid >1
			BEGIN
				SELECT @ActionID = CASE @roleid WHEN 2 THEN 75009 
												WHEN 3 THEN 75010 
												WHEN 4 THEN 75011 END
												
				--actionID on member
				EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@Doing = 'Update Keno status for credit customer',
					@TrackingValue = @LogSPData  , 
					@TrackingValue2 = @TrackingValue  ,  
					@duration = @duration
			END		
		END		
	END TRY

	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdDisableKeno CustID="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' 
			+ 'Bettype="' + coalesce(cast(@Bettype AS VARCHAR(50)), space(1)) + '" ' 
			+ 'Disable="' + coalesce(cast(@Disable AS VARCHAR(50)), space(1)) + '" ' 			
			+ 'IsSC="' + coalesce(cast(@IsSC AS VARCHAR(1)), space(1)) + '" ' 		
			+ 'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' 
			+ 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' 
			+ 'UplineID="' + coalesce(cast(@UplineID AS VARCHAR(50)), space(1)) + '" ' 
			+ 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' 
			+ 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(50)), space(1)) + '" ' 
			+ 'ErrMsg="' + ERROR_MESSAGE() + '" ' 
			+ 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" />'

		--write log for themself
		SELECT @ActionID = CASE @roleid WHEN 4 THEN 60002 
										WHEN 3 THEN 65004 
										WHEN 2 THEN 70006
										WHEN 1 THEN 75008 END
										
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = @ActionID
			,@Doing = 'Update Keno status for credit customer'
			,@TrackingValue = @LogSPData
			,@TrackingValue2 = @TrackingValue
			,@duration = @duration
		
		--write log for downlines in-case disable downline
		IF @Disable = 1 
		BEGIN
			IF @roleid >3
			BEGIN
				SELECT @ActionID = 65005
				
				--actionID on master
				EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@Doing = 'Update Keno status for credit customer',
					@TrackingValue = @LogSPData  , 
					@TrackingValue2 = @TrackingValue  ,  
					@duration = @duration  
			END
			
			IF @Roleid >2
			BEGIN
				SELECT @ActionID = CASE @roleid WHEN 3 THEN 70007 
												WHEN 4 THEN 70008 END
										
				--actionID on agent
				EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@Doing = 'Update Keno status for credit customer',
					@TrackingValue = @LogSPData  , 
					@TrackingValue2 = @TrackingValue  ,  
					@duration = @duration 
			END
			
			IF @Roleid >1
			BEGIN
				SELECT @ActionID = CASE @roleid WHEN 2 THEN 75009 
												WHEN 3 THEN 75010 
												WHEN 4 THEN 75011 END
												
				--actionID on member
				EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@Doing = 'Update Keno status for credit customer',
					@TrackingValue = @LogSPData  , 
					@TrackingValue2 = @TrackingValue  ,  
					@duration = @duration
			END		
		END	
	END CATCH

	RETURN
END

GO