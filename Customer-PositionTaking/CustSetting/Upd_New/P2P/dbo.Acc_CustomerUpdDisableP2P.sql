ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableP2P]
	@custid int,
	@disablep2p bit,
	@disablefunp2p bit,
	@disablep2pdownlines bit = true, --Disable all downline for P2P
	@disablefunp2pdownlines bit = true, --Disable all downline play for fun P2P
	@SubAccID int = 0,
	@UserID int,
	@language varchar(2) = 'E',
	@errcode int = 0 OUTPUT,
	@errmsg nvarchar(200) = '' OUTPUT,
	@ip varchar(15)=''
AS
/*
Created: 20110727@TOM
Task : Update P2P Game status for customer
DB: DBTXN/bodb02
Original:

Revisions:
	- 20120405@Johnson: correct tracking log
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20121206@Scott : Check Allowed downlines during peak hour at weekend 
	- 20121213@Dan: correct linked server from DB052 --> DB053 
	- 20130318@Elodie: Change linked server DB053 to DBAGE
					   Write more log on DBTXN server in case of DBLOG server failure
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines, Acc_CustomerSelCheckEnable to DBCUST.CustDB)
Param's Explanation:
• @custid: customer id.
• @DisableNumber: status
*/

SET NOCOUNT OFF
DECLARE @startrun DATETIME, @duration INT
SET @startrun = GETDATE()

EXEC Acc_CustomerSelCheckEnable @custid = @custid, @errcode=@errcode OUTPUT,@errmsg=@errmsg OUTPUT
IF @errcode <>0 RETURN

DECLARE @uplinedisablep2p BIT, @old_disablep2p BIT ,
		@uplinedisablefunp2p BIT, @old_disablefunp2p BIT ,
		@roleid TINYINT , @bdisablep2p BIT , @bdisablefunp2p BIT 

SELECT	@roleid = roleid, 
		@old_disablep2p = ISNULL(DisableP2P,0),
		@old_disablefunp2p = ISNULL(DisableFUNP2P,0) 
FROM custInfo WITH (NOLOCK) 
WHERE custId = @custid

IF @roleid NOT IN (1,2,3,4)
BEGIN
	SELECT @errmsg = CASE @language 
						WHEN 'E' THEN 'Invalid user!'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
					END, @ErrCode = 400	
	RETURN
END




IF (@old_disablep2p = @disablep2p)
	SET @bdisablep2p = 0
ELSE
	SET @bdisablep2p = 1

IF (@old_disablefunp2p = @disablefunp2p)
	SET @bdisablefunp2p = 0
ELSE
	SET @bdisablefunp2p = 1

IF (@bdisablep2p = 0 AND @bdisablefunp2p = 0) RETURN


-- Check Allowed downlines during peak hour at weekend 
IF ( 
	(@bdisablep2p = 1 AND (@disablep2p = 1 OR (@disablep2p = 0 AND @disablep2pdownlines = 0)))
	or
	(@bdisablefunp2p = 1  AND (@disablefunp2p = 1 OR (@disablefunp2p = 0 AND @disablefunp2pdownlines = 0)))
	)
BEGIN

	EXEC Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
											@roleid=@roleid,
											@isExecRep=0,
											@Language=@Language,
											@ErrMsg=@ErrMsg output,
											@ErrCode=@ErrCode output
	IF @ErrCode <>0 RETURN
END
--End 




IF @disablep2p = 0 OR @disablefunp2p = 0
BEGIN			
	IF @roleid = 4 
		SELECT @uplinedisablep2p = 0 , @uplinedisablefunp2p = 0
	ELSE IF @roleid = 3
		SELECT @uplinedisablep2p = ISNULL(DisableP2P,0) ,
				@uplinedisablefunp2p = ISNULL(DisableFUNP2P,0)
		FROM custInfo WITH (NOLOCK)
		WHERE custId = (SELECT srecommend 
						FROM custInfo WITH (NOLOCK) 
						WHERE custId = @custid)
	ELSE IF @roleid = 2
		SELECT @uplinedisablep2p = ISNULL(DisableP2P,0) ,
				@uplinedisablefunp2p = ISNULL(DisableFUNP2P,0)
		FROM custInfo WITH (NOLOCK)
		WHERE custId = (SELECT mrecommend 
						FROM custInfo WITH (NOLOCK) 
						WHERE custId = @custid)
	ELSE IF @roleid = 1
		SELECT @uplinedisablep2p = ISNULL(DisableP2P,0) ,
				@uplinedisablefunp2p = ISNULL(DisableFUNP2P,0)
		FROM custInfo WITH (NOLOCK)
		WHERE custId = (SELECT recommend 
						FROM custInfo WITH (NOLOCK) 
						WHERE custId = @custid)

	IF (@uplinedisablep2p = 1 AND @disablep2p = 0 AND @bdisablep2p = 1)
	BEGIN
		SELECT @errmsg = CASE @language
							WHEN 'E' THEN 'Account disabled for P2P Game. Unable to edit downlines.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60013,@Language)
						END, @errcode = 401
		RETURN
	END 

	IF (@uplinedisablefunp2p = 1 AND @disablefunp2p = 0 AND @bdisablefunp2p = 1)
	BEGIN
		SELECT @errmsg = CASE @language
							WHEN 'E' THEN 'Account disabled Play for Fun P2P Game. Unable to edit downlines.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60014,@Language)
						END, @errcode = 402
		RETURN
	END 
END

UPDATE custInfo WITH (ROWLOCK, UPDLOCK) 
SET DisableP2P = @disablep2p ,
	DisableFUNP2P = @disablefunp2p
WHERE custId = @custid

IF (@@ERROR <> 0)
BEGIN
	SELECT @errmsg = CASE @Language 
						WHEN 'E' THEN 'Update process is unsuccessful.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					END	, @errcode = 403
	RETURN
END

--Check condition for update all downline for p2p
IF (@bdisablep2p = 1 AND (@disablep2p = 1 OR (@disablep2p = 0 AND @disablep2pdownlines = 0)))
BEGIN
	IF @RoleID = 4 
	BEGIN
		UPDATE custInfo WITH (ROWLOCK, UPDLOCK)
		SET DisableP2P = @DisableP2P 
		WHERE srecommend = @CustID

		IF (@@ERROR <> 0)
		BEGIN			
			SELECT @errmsg = CASE @language
							WHEN 'E' THEN 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @errcode = 404
			RETURN
		END
	END

	IF @RoleID = 3
	BEGIN
		UPDATE custInfo WITH (ROWLOCK, UPDLOCK)
		SET DisableP2P = @DisableP2P 
		WHERE mrecommend = @CustID

		IF (@@ERROR <> 0)
		BEGIN			
			SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 405
			RETURN
		END
	END

	IF @RoleID = 2 
	BEGIN
		UPDATE custInfo WITH (ROWLOCK, UPDLOCK)
		SET DisableP2P = @DisableP2P 
		WHERE recommend = @CustID

		IF (@@ERROR <> 0)
		BEGIN			
			SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 406
		RETURN
		END
	END
END

--Check condition for update all downline play for fun p2p
IF (@bdisablefunp2p = 1  AND (@disablefunp2p = 1 OR (@disablefunp2p = 0 AND @disablefunp2pdownlines = 0)))
BEGIN
	IF @RoleID = 4 
	BEGIN
		UPDATE custInfo WITH (ROWLOCK, UPDLOCK)
		SET DisableFUNP2P = @disablefunp2p
		WHERE srecommend = @CustID

		IF (@@ERROR <> 0)
		BEGIN			
			SELECT @errmsg = CASE @language
							WHEN 'E' THEN 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @errcode = 407
			RETURN
		END
	END

	IF @RoleID = 3
	BEGIN
		UPDATE custInfo WITH (ROWLOCK, UPDLOCK)
		SET DisableFUNP2P = @disablefunp2p
		WHERE mrecommend = @CustID

		IF (@@ERROR <> 0)
		BEGIN			
			SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 408
			RETURN
		END
	END

	IF @RoleID = 2 
	BEGIN
		UPDATE custInfo WITH (ROWLOCK, UPDLOCK)
		SET DisableFUNP2P = @disablefunp2p
		WHERE recommend = @CustID

		IF (@@ERROR <> 0)
		BEGIN			
			SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 409
			RETURN
		END
	END
END

DECLARE @LogSPData VARCHAR(4000)

SELECT @LogSPData = '<Acc_CustomerUpdDisableP2P CustID="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" '+					
					'DisableP2P="'+ COALESCE(CAST(@DisableP2P AS VARCHAR(2)),SPACE(1)) + '" '+
					'DisableFunP2P="'+ COALESCE(CAST(@DisableFunP2P AS VARCHAR(2)),SPACE(1)) + '" '+
					'DisableP2Pdownlines="'+ COALESCE(CAST(@DisableP2Pdownlines AS VARCHAR(2)),SPACE(1)) + '" '+
					'DisableFunP2Pdownlines="'+ COALESCE(CAST(@DisableFunP2Pdownlines AS VARCHAR(2)),SPACE(1)) + '" '+
					'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" '+
					'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" '+
					'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))+'" '+
					'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" '+
					'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(400)),SPACE(1))+'" '+
					'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1))+'" />'

SET @duration  = DATEDIFF (millisecond,@startRun,GETDATE())

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1132,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH
	SELECT @LogSPData = '<Acc_CustomerUpdDisableP2P CustID="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" '+					
					'DisableP2P="'+ COALESCE(CAST(@DisableP2P AS VARCHAR(2)),SPACE(1)) + '" '+
					'DisableFunP2P="'+ COALESCE(CAST(@DisableFunP2P AS VARCHAR(2)),SPACE(1)) + '" '+
					'DisableP2Pdownlines="'+ COALESCE(CAST(@DisableP2Pdownlines AS VARCHAR(2)),SPACE(1)) + '" '+
					'DisableFunP2Pdownlines="'+ COALESCE(CAST(@DisableFunP2Pdownlines AS VARCHAR(2)),SPACE(1)) + '" '+
					'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" '+
					'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" '+
					'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))+'" '+
					'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" '+
					'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(400)),SPACE(1))+ error_message() +'" '+
					'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1))+'" />'
					
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1132,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH


GO
GRANT EXECUTE ON dbo.Acc_CustomerUpdDisableP2P TO [bodbAdminNet]
GO
GRANT  EXECUTE  ON dbo.Acc_CustomerUpdDisableP2P  TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON dbo.Acc_CustomerUpdDisableP2P TO [vnteam]
GO
GRANT EXECUTE ON dbo.Acc_CustomerUpdDisableP2P TO [bodbExtAccNet]