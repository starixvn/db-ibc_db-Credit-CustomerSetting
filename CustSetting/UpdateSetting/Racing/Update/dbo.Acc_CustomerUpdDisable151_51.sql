/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisable151_51]
	@CustID					INT,
	@Disable151_51			BIT,
	@DisableDownlines151_51	BIT				= true, --Disable all downline
	@SubAccID				INT				= 0, --Sub-AccountID
	@UserID					INT,
	@Language				VARCHAR(2)		= 'E',
	@ErrCode				INT				= 0 OUTPUT,
	@ErrMsg					NVARCHAR(200)	= '' OUTPUT,
	@IP						VARCHAR(15)		= '',
	@SystemID				TINYINT = 1
AS
/*
Created: 20110111@Lukas
Task : Update AU Horseracing status for customer
DB: DBTXN/bodb02
Original:

Revisions:    
	- 20110509@Johnson: Update error message for Thai version.
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB)
	- 20170303@Winnie: Change enable behavior [Redmine: #72336]
Param's Explanation:
• @custid: customer id.   

*/
BEGIN
	SET NOCOUNT ON

	DECLARE	@startRun	DATETIME,
			@endRun		DATETIME,
			@duration	INT
	SET @startRun = GETDATE()

	--Check disable user
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode OUTPUT,@ErrMsg=@ErrMsg OUTPUT
	IF @ErrCode <>0 
		RETURN 
	--end
	DECLARE @RoleID TINYINT, 
			@UplineDisable151_51 BIT, 
			@Old_Disable151_51 BIT
			,@HasDownline BIT = 0 
			,@DisableDownlines_Old BIT = 0
			,@EnableDownlines BIT=0
SET @EnableDownlines = CASE @DisableDownlines151_51 WHEN 0 THEN 1 ELSE 0 END


	SELECT	@RoleID = RoleID,
			@Old_Disable151_51 = ISNULL(Disable151_AU, 0)
	FROM	Custinfo WITH(nolock)
	WHERE	CustID = @CustID

	IF @RoleID NOT IN (1,2,3,4)
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid user!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
						END, @ErrCode = 100	
		RETURN
	END
SELECT top 1 @HasDownline = 1   
	FROM dbo.CustInfo WITH (NOLOCK)  
	WHERE (@RoleID = 4 AND srecommend = @CustID and roleid = 3)  
		OR (@RoleID = 3 AND mrecommend = @CustID and roleid = 2)  
		OR (@RoleID = 2 AND recommend = @CustID and roleid = 1)  
		
IF @HasDownline = 1
	BEGIN
		IF @roleid = 4 
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE srecommend = @custid AND roleid = 3 AND Disable151_AU = 1)
				SET @DisableDownlines_Old = 1
		END
		ELSE IF @roleid = 3
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE mrecommend = @custid AND roleid = 2 AND Disable151_AU = 1)
				SET @DisableDownlines_Old = 1
		END
		ELSE IF @roleid = 2
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE recommend = @custid AND roleid = 1 AND Disable151_AU = 1)
				SET @DisableDownlines_Old = 1
		END
	END

	IF @Old_Disable151_51 = @Disable151_51 AND @DisableDownlines_Old <> @EnableDownlines
		RETURN

	IF @Disable151_51 = 0 -- check status upline
	BEGIN
		IF @RoleID = 3
			SELECT @UplineDisable151_51 = ISNULL(Disable151_AU,0) FROM CustInfo WITH(nolock)
			WHERE custid = (SELECT SRecommend FROM Custinfo WITH(NOLOCK) WHERE custid = @CustID)
		IF @RoleID = 2
			SELECT @UplineDisable151_51 = ISNULL(Disable151_AU,0) FROM CustInfo WITH(NOLOCK)
			WHERE custid = (SELECT MRecommend FROM Custinfo WITH(nolock) WHERE custid = @CustID)
		IF @RoleID = 1
			SELECT @UplineDisable151_51 = ISNULL(Disable151_AU,0) FROM CustInfo WITH(NOLOCK)
			WHERE custid = (SELECT Recommend FROM Custinfo WITH(NOLOCK) WHERE custid = @CustID)
		IF @RoleID = 4 SELECT @UplineDisable151_51 = 0   --not checking the upline when the customer is the super
			
		IF @UplineDisable151_51 = 1
		BEGIN
			SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 'Account disabled  for Aust Racing. Unable to edit downlines.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60010,@Language)
							END, @ErrCode = 105
			RETURN
		END 
	END
	IF ((@Disable151_51 = 1 AND @Old_Disable151_51 = 0) OR 
	(@DisableDownlines_Old = 0 AND @EnableDownlines = 0 AND @HasDownline = 1)) AND @SystemID =2 AND @roleid IN (4,3,2)
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'You are not allowed to disable for downlines.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60035,@Language)
						END, @ErrCode = 102
		RETURN
	END 

	IF @Disable151_51 = 1  AND @EnableDownlines = 1 AND @HasDownline=1
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'You are not allowed to perform this action.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90012,@Language)
						END, @ErrCode = 103
		RETURN
	END 

	---------------------

	UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
	SET		Disable151_AU = @Disable151_51
	WHERE	CustID = @CustID
	if (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg =
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 101
		RETURN
	END
	--Check condition for update all downline
	IF (@Disable151_51 = 1 or (@Disable151_51 = 0 and @DisableDownlines151_51 = 0)) --Disable all downline or enable all downline
	BEGIN
		IF @RoleID = 4 
		BEGIN
			UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
			SET Disable151_AU = @Disable151_51 
			WHERE SRecommend = @CustID

			IF (@@ERROR <> 0)
			BEGIN				
				SELECT @ErrMsg = 
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 102
				RETURN
			END
		END

		IF @RoleID = 3 
		BEGIN
			UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
			SET		Disable151_AU = @Disable151_51 
			WHERE	MRecommend = @CustID
			IF(@@ERROR <> 0)
			BEGIN				
				SELECT @ErrMsg = 
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 103
				RETURN
			END
		END

		IF @RoleID = 2 
		BEGIN
			UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
			SET Disable151_AU = @Disable151_51 
			WHERE Recommend = @CustID

			IF(@@ERROR <> 0)
			BEGIN				
				SELECT @ErrMsg = 
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 104
				RETURN
			END
		END
	END

	DECLARE @LogSPData VARCHAR(MAX)

	SELECT @LogSPData = '<Acc_CustomerUpdDisable151_51 CustID="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" '+
						'Disable151_51="'+ COALESCE(CAST(@Disable151_51 AS VARCHAR(50)),SPACE(1)) + '" '+
						'DisableDownline151_51="'+ COALESCE(CAST(@DisableDownlines151_51 AS VARCHAR(50)),SPACE(1)) + '" '+
						'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" '+
						'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" '+
						'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))+'" '+
						'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" '+
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(400)),SPACE(1))+'" '+
						'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1))+'" />'

	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF(millisecond,@startRun,@endRun)

	/*1125	Acc_CustomerUpdDisable151_51	Update Enabled/Disabled AU Horse racing status*/
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 1125,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH		
		SELECT @LogSPData = '<Acc_CustomerUpdDisable151_51 CustID="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" '+
							'Disable151_51="'+ COALESCE(CAST(@Disable151_51 AS VARCHAR(50)),SPACE(1)) + '" '+
							'DisableDownline151_51="'+ COALESCE(CAST(@DisableDownlines151_51 AS VARCHAR(50)),SPACE(1)) + '" '+
							'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" '+
							'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" '+
							'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))+'" '+
							'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" '+
							'ErrMsg="'+ ERROR_MESSAGE() +'" '+
							'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1))+'" />'
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 1125,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisable151_51] TO [bodbAdminNet]
GO
GRANT  EXECUTE  ON [dbo].[Acc_CustomerUpdDisable151_51]  TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdDisable151_51] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisable151_51] TO [bodbExtAccNet] 