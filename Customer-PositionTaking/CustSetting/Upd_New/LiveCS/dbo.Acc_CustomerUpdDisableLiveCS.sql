ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableLiveCS]
	@custid		INT,
	@DisabledLiveCS BIT = NULL,	
	@EnableDownlinesLiveCS BIT = 0,
	
	@UserID		INT = 0,
	@SubAccID	INT = 0, --Sub-AccountID
	@IP			VARCHAR(20)= '',
	@Language	VARCHAR(2) = 'E',
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		VARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2012-01-31
		Task: Update status setting live casino
		DB: DBTXN/BODB02
		
		Revisions:
			- 20120327@Jamie: Checking Disabled/Enabled account on DBTRANS instead of DB053 
			- 20120417@Johnson: Checking status of upline is enabled before changing status.
			- 20121206@Scott : Check Allowed downlines during peak hour at weekend
			- 20130124@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
			- 20130301@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
			- 20130924@Kathy: Apply Exec Rep 
			- 20131108@Elodie: Splitting bodb02 into CustDB (Turn to use Acc_ExecRep_Cust_04)
			- 20141125@Jamie: Use Acc_CustomerInfo_Execrep_04 instead of Acc_ExecRep_Cust_04 [Redmine:#26497]	
			- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB)
		Parameters Explanation:
	*/ 
SET NOCOUNT ON

	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT
	SET @startRun = GETDATE()
	
	--Check disable user
		EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode OUTPUT,@ErrMsg=@ErrMsg OUTPUT
	IF @ErrCode <>0 RETURN
	
	DECLARE @status INT, @Allow2Update BIT, @SyncLiveCS BIT ,@RoleID TINYINT, @UplineSyncLiveCS BIT, @UplineEnableLiveCS BIT, @Old_DisabledLiveCS BIT
	
	SELECT @SyncLiveCS=SyncLiveCasino,@RoleID=RoleID, @Old_DisabledLiveCS=DisableLiveCasino FROM custinfo(NOLOCK) WHERE custid=@custid
	
	IF(@RoleID IS NULL OR @roleid > 4) 
	BEGIN
		SELECT @status=0,@ErrMsg = CASE @Language WHEN 'E' THEN 'Account does not exist or invalid customer account'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](40019,@Language) END,
						 @ErrCode = 100	
						
		RETURN
	END
	
	IF @SyncLiveCS = 0 AND @DisabledLiveCS = 0
	BEGIN
		SELECT @status=0,@ErrMsg = CASE @Language WHEN 'E' THEN 'Cannot enable live casino for this account due to lack of settings.'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](60022,@Language) END,
						 @ErrCode = 101		
					
		RETURN
	END
--Check Allowed downlines during peak hour at weekend	
	IF @DisabledLiveCS = 1 OR @EnableDownlinesLiveCS = 1
	BEGIN
		EXEC Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
											@roleid=@roleid,
											@isExecRep=1,
											@Language=@Language,
											@ErrMsg=@ErrMsg output,
											@ErrCode=@ErrCode output
		IF @ErrCode <>0 RETURN
	END
--END	
	
	IF @roleid = 4
		SELECT @ALlow2Update = 1
	ELSE
	BEGIN
		SELECT @UplineSyncLiveCS = SyncLiveCasino, @UplineEnableLiveCS = CASE WHEN DisableLiveCasino = 0 THEN 1 ELSE 0 END 
		FROM CustInfo WITH(NOLOCK)
		WHERE custid = (SELECT CASE WHEN roleid = 1 THEN recommend
									WHEN roleid = 2 THEN mrecommend 
									WHEN roleid = 3 THEN srecommend END
						FROM CustInfo WITH(NOLOCK)
						WHERE custid = @custid
					)
		
		IF @UplineSyncLiveCS = 1 AND @UplineEnableLiveCS = 1
			SELECT @Allow2Update = 1
		ELSE 
			SELECT @Allow2Update = 0		
	END
	
	IF @Allow2Update = 0
	BEGIN
		SELECT @status=0,@ErrMsg = CASE @Language WHEN 'E' THEN 'Cannot enable Live Casino because the upline either has Live Casino disabled or does not have any settings.'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](60023,@Language) END,
						 @ErrCode = 102	
		RETURN
	END
	
	IF @old_DisabledLiveCS = @DisabledLiveCS 
		RETURN
		
BEGIN TRY	
	UPDATE CustInfo WITH(ROWLOCK, UPDLOCK)
	SET DisableLiveCasino = ISNULL(@DisabledLiveCS,DisableLiveCasino)
	WHERE custid = @custid 

	--Update Downline
	IF @DisabledLiveCS = 1 OR @EnableDownlinesLiveCS = 1
	BEGIN
		--20130924@Kathy: Apply ExecRep 
		IF @RoleID BETWEEN 2 AND 4 
		BEGIN
			EXEC [Acc_CustomerInfo_Execrep_04]
				 @CustID		= @CustID,
				 @RoleID		= @RoleID,
				 @Action		= 'DisableLiveCasino',
				 @DisableLiveCasino = @DisabledLiveCS
		END
	END
	
	SELECT @status = 1
END TRY
BEGIN CATCH
	SELECT @status = 0
END CATCH

--Log data
DECLARE @LogData NVARCHAR(MAX)
DECLARE @TrackingValue2 NVARCHAR(4000)	

SELECT @LogData ='<Acc_CustomerUpdDisableLiveCS custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
'disabledLiveCS="'+ COALESCE(CAST(@disabledLiveCS AS VARCHAR(50)),SPACE(1)) + '" ' +
'enableDownlinesLiveCS="'+ COALESCE(CAST(@enableDownlinesLiveCS AS VARCHAR(50)),SPACE(1)) + '" ' +
'status="'+ COALESCE(CAST(@status AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(400)),SPACE(1)) + '" ' +
'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(20)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))  + '" />'

SELECT @TrackingValue2 ='<Acc_CustomerUpdDisableLiveCS custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
'disabledLiveCS="'+ COALESCE(CAST(@old_DisabledLiveCS AS VARCHAR(50)),SPACE(1)) + '" ' +
'enableDownlinesLiveCS="'+ COALESCE(CAST(@enableDownlinesLiveCS AS VARCHAR(50)),SPACE(1)) + '" ' +
'status="'+ COALESCE(CAST(@status AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(400)),SPACE(1)) + '" ' +
'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(20)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))  + '" />'	


SET @endRun = GETDATE()
SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID, 
		@CustID = @custid,
		@ActionID = 1134,
		@TrackingValue = @LogData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END TRY
BEGIN CATCH
	SELECT @LogData ='<Acc_CustomerUpdDisableLiveCS custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'disabledLiveCS="'+ COALESCE(CAST(@disabledLiveCS AS VARCHAR(50)),SPACE(1)) + '" ' +
	'enableDownlinesLiveCS="'+ COALESCE(CAST(@enableDownlinesLiveCS AS VARCHAR(50)),SPACE(1)) + '" ' +
	'status="'+ COALESCE(CAST(@status AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" ' +
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(20)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))  + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID, 
		@CustID = @custid,
		@ActionID = 1134,
		@TrackingValue = @LogData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END CATCH

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableLiveCS] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableLiveCS] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableLiveCS] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdDisableLiveCS] TO [vnteam] AS [dbo]