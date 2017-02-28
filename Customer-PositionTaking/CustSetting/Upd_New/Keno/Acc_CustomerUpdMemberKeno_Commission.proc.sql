ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberKeno_Commission] 
	@custid INT
	,@sporttype		INT = 202
	,@bettype		INT
	
	,@discount DECIMAL(9, 8)

	,@SubAccID INT = 0
	,@IP VARCHAR(50) = ''
	,@UserID INT = 0
	,@Language VARCHAR(20) = 'E'
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20140319@Bobby
	Task : Update member's commision for Keno
	DB: DBTXN/CustDB

	Revisions:
		- 20141114@Johnson: Apply execrep when update commission on member [Redmine: #25787]					
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]					
	Param's Explanation:
	* @ErrCode:
		= 0: Transaction recorded successfully.
		> 0: Specific Error.
  
	* @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT

	SET @startRun = getdate()

	DECLARE @old_PlayerDiscount DECIMAL(9, 8)
		,@uplinePlayerDiscount DECIMAL(9, 8)
		,@srecommend INT
		,@mrecommend INT
		,@recommend INT
		,@roleid	INT

	SELECT @srecommend = srecommend
		,@mrecommend = mrecommend
		,@recommend = recommend
		,@roleid = roleid
	FROM CustInfo WITH (NOLOCK)
	WHERE CustID = @custid

	            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END


	SELECT @old_PlayerDiscount = playerdiscount
	FROM CustSettingGame WITH (NOLOCK)
	WHERE custid = @custid
		AND sporttype = @sporttype
		AND bettype = @bettype

	SELECT @uplinePlayerDiscount = discount
	FROM CustSettingGame WITH (NOLOCK)
	WHERE custid = @recommend
		AND sporttype = @sporttype
		AND bettype = @bettype

	IF (@discount < 0
		OR @discount > @uplinePlayerDiscount
		OR  @discount > 0.01 ) --global production comm setting
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Invalid commission rate.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](1, @Language)
				END
			,@ErrCode = 101

		RETURN
	END

	IF ( @discount = @old_PlayerDiscount ) RETURN

	-- Apply exec rep
	exec dbo.Acc_CustSetting3rd_06
			@CustId = @custid,
			@RoleId = @roleid ,
			@Discount = @discount,	
			@sporttype = @sporttype,
			@bettype = @bettype,		
			@mode = 'Keno'
			

	DECLARE @LogSPData VARCHAR(MAX)
	DECLARE @TrackingValue2 VARCHAR(5000)

	SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_Commission custid ="' + CAST(@custid AS VARCHAR(50)) + '" ' 
		+ 'bettype ="' + COALESCE(CAST(@bettype AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'sporttype ="' + COALESCE(CAST(@sporttype AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'playerdiscount ="' + COALESCE(CAST(@discount AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' 
		+ 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' 
		+ 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" ' 
		+ 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(50)), space(1)) + '" ' 
		+ 'ErrMsg="' + coalesce(cast(@ErrMsg AS VARCHAR(5000)), space(1)) + '" />'

	SELECT @TrackingValue2 = '<Acc_CustomerUpdMemberKeno_Commission custid ="' + CAST(@custid AS VARCHAR(50)) + '" ' 
		+ 'bettype ="' + COALESCE(CAST(@bettype AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'sporttype ="' + COALESCE(CAST(@sporttype AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'playerdiscount ="' + COALESCE(CAST(@old_PlayerDiscount AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' 
		+ 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' 
		+ 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" ' 
		+ 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(50)), space(1)) + '" ' 
		+ 'ErrMsg="' + coalesce(cast(@ErrMsg AS VARCHAR(5000)), space(1)) + '" />'

	SET @endRun = GETDATE()
	SET @duration = DATEDIFF(millisecond, @startRun, @endRun)

	--Log customer info 
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = 227
			,@TrackingValue = @LogSPData
			,@TrackingValue2 = @TrackingValue2
			,@duration = @duration
	END TRY

	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_Commission custid ="' + CAST(@custid AS VARCHAR(50)) + '" ' 
		+ 'bettype ="' + COALESCE(CAST(@bettype AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'sporttype ="' + COALESCE(CAST(@sporttype AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'playerdiscount ="' + COALESCE(CAST(@discount AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' 
		+ 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' 
		+ 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" ' 
		+ 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(50)), space(1)) + '" '
		 + 'ErrMsg="' + ERROR_MESSAGE() + '" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = 227
			,@TrackingValue = @LogSPData
			,@TrackingValue2 = @TrackingValue2
			,@duration = @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_Commission] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_Commission] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberKeno_Commission] TO [vnteam] AS [dbo]
GO