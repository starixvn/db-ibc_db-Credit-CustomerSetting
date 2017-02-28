ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableSuperLive]
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
		Created: Elodie
		Date: 2015-07-07
		Task: Update status of Super Live
		DB: DBCUST/CustDB
		
		Revisions:

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
			@HasDownline BIT = 0
	
	SELECT @roleid = roleid,
			@Disable_Old = DisableSuperLive		
	FROM custInfo WITH(NOLOCK)
	WHERE custid = @custid
	
	IF (@RoleID NOT IN (1, 2, 3, 4))
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Invalid user!'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](40002, @Language)
				END
			,@ErrCode = 100

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
			SELECT @UplineDisable = ISNULL(c1.DisableSuperLive, 0)
			FROM custInfo c1 WITH (NOLOCK)
			WHERE c1.custid = (SELECT c2.srecommend FROM custInfo c2 WITH (NOLOCK) WHERE c2.custid = @CustID)
		IF @RoleID = 2
			SELECT @UplineDisable = ISNULL(c1.DisableSuperLive, 0)
			FROM custInfo c1 WITH (NOLOCK)
			WHERE c1.custid = (SELECT c2.mrecommend FROM custInfo c2 WITH (NOLOCK) WHERE c2.custid = @CustID)
		IF @RoleID = 1
			SELECT @UplineDisable = ISNULL(c1.DisableSuperLive, 0)
			FROM custInfo c1 WITH (NOLOCK)
			WHERE c1.custid = (SELECT c2.recommend FROM custInfo c2 WITH (NOLOCK) WHERE c2.custid = @CustID)
	END
	
	IF @UplineDisable = 1
	BEGIN
		--SELECT @ErrMsg =  CASE @Language 
		--					WHEN 'E' THEN 'Account was disabled Super Live. Unable to edit downlines.'
		--					ELSE [dbo].[f_Get_MsgNamebyMsgID](60031,@Language)
		--				END, @ErrCode = 101
		SELECT @ErrMsg = 'Account was disabled Super Live. Unable to edit downlines.', @ErrCode = 101
		RETURN
	END 
	
	UPDATE dbo.CustInfo WITH(ROWLOCK, UPDLOCK)
	SET DisableSuperLive = @Disable
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
					,@DisableSuperLive = @Disable
					,@Action = 'SuperLive'
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
	  
	 Select @LogSPData = '<Acc_CustomerUpdDisableSuperLive CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  

		  'Disable="'+ coalesce(cast(@Disable as varchar(50)),space(1)) + '" '+  
		  'ApplyDownlines="'+ coalesce(cast(CASE WHEN @Disable = 1 THEN 1 ELSE @EnableDownlines END as varchar(50)),space(1)) + '" '+  
		  'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+  
		  'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' +
		  'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		  'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		  'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+  
		  'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'  
	  
	  SELECT @LogSPData_Old = '<Acc_CustomerUpdDisableSuperLive CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		  'Disable="'+ coalesce(cast(@Disable_old as varchar(50)),space(1)) + '" '+  
		  'ApplyDownlines="'+ coalesce(cast(CASE WHEN @Disable = 1 THEN 1 ELSE @EnableDownlines END as varchar(50)),space(1)) + '" '+  
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
		@ActionID = 1156,  
		@TrackingValue = @LogSPData  , 
		@TrackingValue2 = @LogSPData_old  ,  
		@duration = @duration  
	END TRY 
	BEGIN CATCH
		Select @LogSPData = '<Acc_CustomerUpdDisableSuperLive CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		  'Disable="'+ coalesce(cast(@Disable as varchar(50)),space(1)) + '" '+  
		  'ApplyDownlines="'+ coalesce(cast(CASE WHEN @Disable = 1 THEN 1 ELSE @EnableDownlines END as varchar(50)),space(1)) + '" '+  
		  'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+  
		  'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' +
		  'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		  'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		  'ErrMsg="'+ ERROR_MESSAGE() +'" '+  
		  'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />' 
		 		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
		@UserID = @UserID,  
		@CustID = @CustID,  
		@ActionID = 1156,  
		@TrackingValue = @LogSPData,  
		@TrackingValue2 = @LogSPData_old,  
		@duration = @duration
	END CATCH
		
END

GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdDisableSuperLive] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableSuperLive] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableSuperLive] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableSuperLive] TO [bodbExtAccNet]
GO 
