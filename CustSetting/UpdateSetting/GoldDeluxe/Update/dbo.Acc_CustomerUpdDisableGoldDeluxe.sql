ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableGoldDeluxe]
	@custid		INT,
	@Disable	BIT = NULL,	
	@EnableDownlines BIT = 0,
	
	@UserID		INT = 0,
	@SubAccID	INT = 0, --Sub-AccountID
	@IP			VARCHAR(20)= '',
	@Language	VARCHAR(2) = 'E',
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		VARCHAR(4000) = '' OUTPUT
 AS
	/*
		Created: Johnson
		Date: 2015-04-23
		Task: Update status of Gold Deluxe
		DB: DBTXN/CustDB
		
		Revisions:
			- 20150610@Elodie: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckAllowedDownlines, Acc_CustomerSelCheckEnable to DBCUST)
			- 20150821@Elodie: Exclude WON currency for GoldDeluxe [Redmine: #41785]
			- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
		Parameter's Explanation:
	*/
BEGIN
	SET NOCOUNT ON 
	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT

	SET @startRun = GETDATE()
	
	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN
		
	DECLARE @roleid INT,
			@Disable_Old BIT,
			@UplineDisable BIT,			
			@HasDownline BIT = 0,
			@Currency INT
	
	SELECT @roleid = roleid,
			@Disable_Old = DisableGoldDeluxe, 
			@Currency = currency		
	FROM custInfo WITH(NOLOCK)
	WHERE custid = @custid
	
	            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
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
	
	IF (@Currency = 45) --Gold Deluxe doesn't support WON currency [Redmine: #41785]
	BEGIN
		SELECT @ErrMsg = 'Gold Deluxe doesn''t support customers under WON currency', @ErrCode = 103
		RETURN
	END

	IF @Disable_old = @Disable
		RETURN
	
	SELECT	top 1 @HasDownline = 1 
	FROM dbo.CustInfo WITH (NOLOCK)
	WHERE (@RoleID = 4 AND srecommend = @CustID and roleid = 3)
		OR (@RoleID = 3 AND mrecommend = @CustID and roleid = 2)
		OR (@RoleID = 2 AND recommend = @CustID and roleid = 1)
	
	IF @Disable = 0 -- check status upline
	BEGIN
		IF @RoleID = 4  --not checking the upline when the customer is the super
			SELECT @UplineDisable = 0
		IF @RoleID = 3
			SELECT @UplineDisable = ISNULL(c1.DisableGoldDeluxe, 0)
			FROM custInfo c1 WITH (NOLOCK)
			WHERE c1.custid = (SELECT c2.srecommend FROM custInfo c2 WITH (NOLOCK) WHERE c2.custid = @CustID)
		IF @RoleID = 2
			SELECT @UplineDisable = ISNULL(c1.DisableGoldDeluxe, 0)
			FROM custInfo c1 WITH (NOLOCK)
			WHERE c1.custid = (SELECT c2.mrecommend FROM custInfo c2 WITH (NOLOCK) WHERE c2.custid = @CustID)
		IF @RoleID = 1
			SELECT @UplineDisable = ISNULL(c1.DisableGoldDeluxe, 0)
			FROM custInfo c1 WITH (NOLOCK)
			WHERE c1.custid = (SELECT c2.recommend FROM custInfo c2 WITH (NOLOCK) WHERE c2.custid = @CustID)
	END
	
	IF @UplineDisable = 1
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'Account was disabled Gold Deluxe. Unable to edit downlines.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60031,@Language)
						END, @ErrCode = 101
		RETURN
	END 
	
	UPDATE dbo.CustInfo WITH(ROWLOCK, UPDLOCK)
	SET DisableGoldDeluxe = @Disable,
		HideGoldDeluxe = CASE WHEN HideGoldDeluxe = 1 THEN 0 ELSE HideGoldDeluxe END		
	WHERE custid = @CustID
		
	--Check condition for update all downlines
	IF ( @RoleID > 1 
			AND (@Disable = 1
					OR (@Disable = 0 AND (@EnableDownlines = 1 AND @HasDownline = 1))
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
		
		--Disable all downlines or enable all downlines
		BEGIN TRY
			EXEC [Acc_CustomerInfo_Execrep_04] @CustID = @CustID
					,@RoleID = @RoleID
					,@DisableGoldDeluxe = @Disable
					,@Action = 'GoldDeluxe'
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
	
	DECLARE @LogSPData VARCHAR(MAX),  
			@LogSPData_Old VARCHAR(2000)  
	  
	 Select @LogSPData = '<Acc_CustomerUpdDisableGoldDeluxe CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  

		  'Disable="'+ coalesce(cast(@Disable as varchar(50)),space(1)) + '" '+  
		  'ApplyDownlines="'+ coalesce(cast(@EnableDownlines as varchar(50)),space(1)) + '" '+  
		  'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+  
		  'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' +
		  'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		  'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		  'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+  
		  'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'  
	  
	  SELECT @LogSPData_Old = '<Acc_CustomerUpdDisableGoldDeluxe CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		  'Disable="'+ coalesce(cast(@Disable_old as varchar(50)),space(1)) + '" '+  
		  'ApplyDownlines="'+ coalesce(cast(@EnableDownlines as varchar(50)),space(1)) + '" '+  
		  'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+  
		  'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' +
		  'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		  'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		  'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+  
		  'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'  
		  
	 SET @endRun = GETDATE()  
	 SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)  

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
		@UserID = @UserID,  
		@CustID = @CustID,  
		@ActionID = 1155,  
		@TrackingValue = @LogSPData  , 
		@TrackingValue2 = @LogSPData_old  ,  
		@duration = @duration  
	END TRY 
	BEGIN CATCH
		Select @LogSPData = '<Acc_CustomerUpdDisableGoldDeluxe CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		  'Disable="'+ coalesce(cast(@Disable as varchar(50)),space(1)) + '" '+  
		  'ApplyDownlines="'+ coalesce(cast(@EnableDownlines as varchar(50)),space(1)) + '" '+  
		  'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+  
		  'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' +
		  'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		  'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		  'ErrMsg="'+ ERROR_MESSAGE() +'" '+  
		  'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />' 
		 		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
		@UserID = @UserID,  
		@CustID = @CustID,  
		@ActionID = 1155,  
		@TrackingValue = @LogSPData,  
		@TrackingValue2 = @LogSPData_old,  
		@duration = @duration
	END CATCH
		
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableGoldDeluxe] TO [bodbAdminNet] 
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableGoldDeluxe] TO [bodbDownlineNet] 
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableGoldDeluxe] TO [bodbExtAccNet]
GO