/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_AdminUpdDisableKeno] 
	@CustID INT
	,@Bettype INT
	,@Disable BIT	
	
	,@UpdateAllMasters BIT = 0
	,@UpdateAllAgents  BIT = 0
	,@UpdateAllMembers BIT = 0
	
	,@DisableAllMasters BIT = NULL
	,@DisableAllAgents  BIT = NULL
	,@DisableAllMembers BIT = NULL
	
	,@UserID INT
	,@UplineID INT	= 0
	,@Language VARCHAR(2) = 'E'
	,@Errcode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
	,@IP VARCHAR(15) = ''
AS
/*
	Created: Johnson
	Date: 2018-01-12
	Task: Admin update Keno status for customer
	DB: DBCUST/CustDB
	Original: Acc_CustomerUpdDisableKeno
	Revisions:
		- 20180110@Johnson: launch new sp from [Acc_CustomerUpdDisableKeno] for new direction status[Redmine:#87328]
	Param's Explanation:
		• @custid: customer id.   
		• @Disable: status of HideKeno		
		
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
		,@DownlinesHideKeno BIT= 0
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
	
	SELECT @HasDownline = 1 
	FROM dbo.CustInfo WITH (NOLOCK)
	WHERE (@RoleID = 4 AND srecommend = @CustID and roleid = 3)
		OR (@RoleID = 3 AND mrecommend = @CustID and roleid = 2)
		OR (@RoleID = 2 AND recommend = @CustID and roleid = 1)
	
	--Get downlines HideKeno status  
	IF (@UpdateAllMasters = 1 OR @UpdateAllAgents = 1 OR @UpdateAllMembers = 1)
	BEGIN
		SELECT TOP (1) @DownlinesHideKeno = HideKeno
		FROM dbo.CustInfo WITH(NOLOCK)
		WHERE (@RoleID = 4 AND srecommend = @CustID AND Custid <> @CustID AND HideKeno = 1
				AND ((@UpdateAllMasters =1 AND roleid = 3)
					OR (@UpdateAllAgents =1 AND roleid = 2)
					OR (@UpdateAllMembers =1 AND roleid = 1)
					)
			)
			OR (@RoleID = 3 AND mrecommend = @CustID AND Custid <> @CustID AND HideKeno = 1
				AND ((@UpdateAllAgents =1 AND roleid = 2)
					OR (@UpdateAllMembers =1 AND roleid = 1)
					)
			)
			OR (@RoleID = 2 AND recommend = @CustID AND Custid <> @CustID AND HideKeno = 1
				AND (@UpdateAllMembers =1 AND roleid = 1)
				)
	END
	
	--dont change anything
	IF @Old_DisableBetType = @Disable AND @UpdateAllMasters = 0 AND @UpdateAllAgents = 0 AND @UpdateAllMembers = 0
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
	
	--status not suitable between upline & downline
	IF @Disable = 1 
		AND 
		(	
			(@UpdateAllMasters = 1 AND @DisableAllMasters = 0)
			OR (@UpdateAllAgents = 1 AND @DisableAllAgents = 0)
			OR (@UpdateAllMembers = 1 AND @DisableAllMembers = 0)
		)
		AND @HasDownline = 1
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'You are not allowed to perform this action.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90012,@Language)
						END, @ErrCode = 103
		RETURN
	END 

	-- check to update IsDisabled
	IF(@GameTypeID > 0)
		--AND ( @Old_DisableBetType <> @Disable )
	--)
	BEGIN
		-- check uplineDisable
		IF (@RoleID = 3) 
		BEGIN
			SELECT TOP(1) @UplineDisable = CASE WHEN c.HideKeno = 0 AND ISNULL(IsDisabled, 0) = 0 
													THEN 0 ELSE 1 END
			FROM dbo.CustInfo c WITH (NOLOCK)
				LEFT JOIN dbo.CustGameType g WITH (NOLOCK) ON g.custid = c.custid
			WHERE g.custid = (SELECT SRecommend 
								FROM dbo.Custinfo WITH (NOLOCK)
								WHERE custid = @CustID
							)
				AND g.GameTypeID = @GameTypeID
		END
		ELSE IF (@RoleID = 2) 
		BEGIN
			SELECT TOP(1) @UplineDisable = CASE WHEN c.HideKeno = 0 AND ISNULL(IsDisabled, 0) = 0 
													THEN 0 ELSE 1 END
			FROM dbo.CustInfo c WITH (NOLOCK)
				LEFT JOIN dbo.CustGameType g WITH (NOLOCK)ON g.custid = c.custid
			WHERE g.custid = (SELECT MRecommend 
								FROM dbo.Custinfo WITH (NOLOCK)
								WHERE custid = @CustID
							)
				AND g.GameTypeID = @GameTypeID
		END
		ELSE IF (@RoleID = 1) 
		BEGIN
			SELECT TOP(1) @UplineDisable = CASE WHEN c.HideKeno = 0 AND ISNULL(IsDisabled, 0) = 0 
													THEN 0 ELSE 1 END
			FROM dbo.CustInfo c WITH (NOLOCK)
				LEFT JOIN dbo.CustGameType g WITH (NOLOCK) ON g.custid = c.custid
			WHERE g.custid = (SELECT Recommend 
								FROM dbo.Custinfo WITH (NOLOCK)
								WHERE custid = @CustID
							)
				AND g.GameTypeID = @GameTypeID
		END
		
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
				OR (@Disable = 0 
					AND @HasDownline = 1
					AND (@UpdateAllMasters = 1 
						OR @UpdateAllAgents = 1 
						OR @UpdateAllMembers = 1
						)
					)
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
					,@UpdateAllMasters = @UpdateAllMasters
					,@UpdateAllAgents = @UpdateAllAgents
					,@UpdateAllMembers = @UpdateAllMembers
					,@DisableAllMasters = @DisableAllMasters
					,@DisableAllAgents = @DisableAllAgents
					,@DisableAllMembers = @DisableAllMembers
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
	
	IF (@HasUpdatedDisable = 1) 		 
	BEGIN
		IF (@Old_HideKeno = 1)
		BEGIN
			UPDATE cust
			SET HideKeno = 0
			FROM dbo.CustInfo cust WITH (ROWLOCK, UPDLOCK)
			WHERE CustID = @CustID
		END
		
		IF(@RoleID > 1 
			AND @HasDownline = 1
			AND @DownlinesHideKeno = 1
			AND (@UpdateAllMasters =1 OR  @UpdateAllAgents =1 OR @UpdateAllMembers =1)
			)
		BEGIN
			BEGIN TRY	
				--update HideKeno for all downlines by level
				EXEC [Acc_CustomerInfo_Execrep_04] @CustID = @CustID
					,@RoleID = @RoleID
					,@UpdateAllMasters = @UpdateAllMasters
					,@UpdateAllAgents = @UpdateAllAgents
					,@UpdateAllMembers = @UpdateAllMembers					
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
		, @ActionID INT
	

	SELECT @LogSPData = '<Acc_AdminUpdDisableKeno CustID="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Bettype="' + coalesce(cast(@Bettype AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Disable="' + coalesce(cast(@Disable AS VARCHAR(50)), space(1)) + '" ' 
		+ 'UpdateAllMasters="'+ coalesce(cast(ISNULL(@UpdateAllMasters,0) as varchar(50)),space(1)) + '" '
		+ 'DisableAllMasters="'+ coalesce(cast(ISNULL(CAST(@DisableAllMasters AS VARCHAR(10)),space(1)) as varchar(50)),space(1)) + '" '
		+ 'UpdateAllAgents="'+ coalesce(cast(ISNULL(@UpdateAllAgents,0) as varchar(50)),space(1)) + '" '  
		+ 'DisableAllAgents="'+ coalesce(cast(ISNULL(CAST(@DisableAllAgents AS VARCHAR(10)),space(1)) as varchar(50)),space(1)) + '" '
		+ 'UpdateAllMembers="'+ coalesce(cast(ISNULL(@UpdateAllMembers,0) as varchar(50)),space(1)) + '" '
		+ 'DisableAllMembers="'+ coalesce(cast(ISNULL(CAST(@DisableAllMembers AS VARCHAR(10)),space(1)) as varchar(50)),space(1)) + '" '
		  
		+ 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'UplineID="' + coalesce(cast(@UplineID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' 
		+ 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(50)), space(1)) + '" ' 
		+ 'ErrMsg="' + coalesce(cast(@ErrMsg AS VARCHAR(400)), space(1)) + '" ' 
		+ 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" />'
		--tracking values
		,@TrackingValue = '<Acc_AdminUpdDisableKeno CustID="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Bettype="' + coalesce(cast(@Bettype AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Disable="' + coalesce(cast(@Old_DisableBetType AS VARCHAR(50)), space(1)) + '" ' 
		+ 'UpdateAllMasters="'+ coalesce(cast(ISNULL(@UpdateAllMasters,0) as varchar(50)),space(1)) + '" '
		+ 'DisableAllMasters="'+ coalesce(cast(ISNULL(CAST(@DisableAllMasters AS VARCHAR(10)),space(1)) as varchar(50)),space(1)) + '" '
		+ 'UpdateAllAgents="'+ coalesce(cast(ISNULL(@UpdateAllAgents,0) as varchar(50)),space(1)) + '" '  
		+ 'DisableAllAgents="'+ coalesce(cast(ISNULL(CAST(@DisableAllAgents AS VARCHAR(10)),space(1)) as varchar(50)),space(1)) + '" '
		+ 'UpdateAllMembers="'+ coalesce(cast(ISNULL(@UpdateAllMembers,0) as varchar(50)),space(1)) + '" '
		+ 'DisableAllMembers="'+ coalesce(cast(ISNULL(CAST(@DisableAllMembers AS VARCHAR(10)),space(1)) as varchar(50)),space(1)) + '" '
		
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
		SELECT @ActionID = CASE @roleid WHEN 4 THEN 60003 
										WHEN 3 THEN 65006
										WHEN 2 THEN 70009 
										WHEN 1 THEN 75012 END
										
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = @ActionID
			,@Doing = 'Update Keno status for credit customer'
			,@TrackingValue = @LogSPData
			,@TrackingValue2 = @TrackingValue
			,@duration = @duration
		
		--write log for downlines in-case update downlines
		IF @HasDownline = 1			
		BEGIN
			IF @roleid >3 
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllMasters = 1 )
					)			
			BEGIN
				SELECT @ActionID = 65007
				
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
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllAgents = 1 )
					)	
			BEGIN	
				SELECT @ActionID = CASE @roleid WHEN 3 THEN 70010 
												WHEN 4 THEN 70011 END
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
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllMembers = 1 )
					)
			BEGIN
				SELECT @ActionID = CASE @roleid WHEN 2 THEN 75013 
												WHEN 3 THEN 75014
												WHEN 4 THEN 75015 END
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
		SELECT @LogSPData = '<Acc_AdminUpdDisableKeno CustID="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' 
			+ 'Bettype="' + coalesce(cast(@Bettype AS VARCHAR(50)), space(1)) + '" ' 
			+ 'Disable="' + coalesce(cast(@Disable AS VARCHAR(50)), space(1)) + '" ' 
			+ 'UpdateAllMasters="'+ coalesce(cast(ISNULL(@UpdateAllMasters,0) as varchar(50)),space(1)) + '" '
			+ 'DisableAllMasters="'+ coalesce(cast(ISNULL(CAST(@DisableAllMasters AS VARCHAR(10)),space(1)) as varchar(50)),space(1)) + '" '
			+ 'UpdateAllAgents="'+ coalesce(cast(ISNULL(@UpdateAllAgents,0) as varchar(50)),space(1)) + '" '  
			+ 'DisableAllAgents="'+ coalesce(cast(ISNULL(CAST(@DisableAllAgents AS VARCHAR(10)),space(1)) as varchar(50)),space(1)) + '" '
			+ 'UpdateAllMembers="'+ coalesce(cast(ISNULL(@UpdateAllMembers,0) as varchar(50)),space(1)) + '" '
			+ 'DisableAllMembers="'+ coalesce(cast(ISNULL(CAST(@DisableAllMembers AS VARCHAR(10)),space(1)) as varchar(50)),space(1)) + '" '
			
			+ 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' 
			+ 'UplineID="' + coalesce(cast(@UplineID AS VARCHAR(50)), space(1)) + '" ' 
			+ 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' 
			+ 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(50)), space(1)) + '" ' 
			+ 'ErrMsg="' + ERROR_MESSAGE() + '" ' 
			+ 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" />'

		--write log for themself
		SELECT @ActionID = CASE @roleid WHEN 4 THEN 60003 
										WHEN 3 THEN 65006
										WHEN 2 THEN 70009 
										WHEN 1 THEN 75012 END
										
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = @ActionID
			,@Doing = 'Update Keno status for credit customer'
			,@TrackingValue = @LogSPData
			,@TrackingValue2 = @TrackingValue
			,@duration = @duration
		
		--write log for downlines in-case update downlines
		IF @HasDownline = 1			
		BEGIN
			IF @roleid >3 
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllMasters = 1 )
					)			
			BEGIN
				SELECT @ActionID = 65007
				
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
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllAgents = 1 )
					)	
			BEGIN	
				SELECT @ActionID = CASE @roleid WHEN 3 THEN 70010 
												WHEN 4 THEN 70011 END
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
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllMembers = 1 )
					)
			BEGIN
				SELECT @ActionID = CASE @roleid WHEN 2 THEN 75013 
												WHEN 3 THEN 75014
												WHEN 4 THEN 75015 END
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