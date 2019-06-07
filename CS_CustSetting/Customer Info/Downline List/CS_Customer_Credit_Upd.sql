/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet" isFunction="0" isNested="0"></info>*/
USE [CustDB]
GO

ALTER PROCEDURE [dbo].[CS_Customer_Credit_Upd]
	@UserId		INT,
	@SubAccId	INT,
	@CustId		INT,
	@UpdCredit	MONEY,
	@IP			VARCHAR(15) = '',
	@Language	VARCHAR(2) = 'E',
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS

/*
	Created: 20181218@Percy
	DB: DBCUST/CustDB
	Task: Member Information >> Downline List >> Update Given Credit

	Revisions:
		- 20181218@Percy: Initialize SP [RedmineID: #105338]
		- 20190527@Elodie: New account status for CN88 [Redmine: 113198]
*/

BEGIN
	SET NOCOUNT ON

	SELECT  @UpdCredit = ISNULL(@UpdCredit, 0)

	DECLARE @srecommend INT, @mrecommend INT, @recommend INT, @HeadlineID INT
	DECLARE @username NVARCHAR(50), @RoleId TINYINT, @Credit MONEY, @UsedCredit MONEY, @BetCredit MONEY
	DECLARE @UplineCredit MONEY, @UplineUsedCredit MONEY
	DECLARE @MinCredit MONEY, @MaxCredit MONEY, @UplineStatus TINYINT

	SELECT  @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend,
			@username = username, @RoleId = roleId, @Credit = ISNULL(credit, 0)
	FROM dbo.custInfo WITH (NOLOCK) WHERE custId = @custId

	IF ISNULL(@RoleId, 0) NOT BETWEEN 1 AND 4
	BEGIN
		-- Invalid user!!
		SELECT @ErrCode = 101, @ErrMsg = dbo.f_Get_MsgNamebyMsgID (40002, @Language)
		RETURN
	END

	IF ISNULL(@Credit, 0) = ISNULL(@UpdCredit, 0)
	BEGIN
		-- Data not change
		RETURN
	END

	IF @RoleId = 4
	BEGIN
		SELECT	@UsedCredit	= SUM(ISNULL(credit, 0))
		FROM dbo.custInfo WITH (NOLOCK)
		WHERE srecommend = @srecommend
			AND roleId = 3
		
		SELECT @HeadlineID = UplineId FROM CustSuper WITH (NOLOCK) WHERE custid = @CustId

		SELECT @UplineStatus = CustStatus FROM dbo.f_CS_GetCustomerStatus(@HeadlineID)

		SELECT	@MinCredit = ISNULL(@UsedCredit, 0)
	END
	ELSE IF @RoleId = 3
	BEGIN
		SELECT	@UplineCredit		= SUM(CASE WHEN roleId = 4 THEN ISNULL(credit, 0) ELSE 0 END),
				@UplineUsedCredit	= SUM(CASE WHEN roleId = 3 THEN ISNULL(credit, 0) ELSE 0 END),
				@UsedCredit			= SUM(CASE WHEN mrecommend = @custId AND roleId = 2 THEN ISNULL(credit, 0) ELSE 0 END) 
		FROM dbo.custInfo WITH (NOLOCK)
		WHERE srecommend = @srecommend

		SELECT @UplineStatus = CustStatus FROM dbo.f_CS_GetCustomerStatus(@srecommend)

		SELECT	@MinCredit = ISNULL(@UsedCredit, 0),
				@MaxCredit = ISNULL(@UplineCredit, 0) - ISNULL(@UplineUsedCredit, 0) + ISNULL(@Credit, 0)
	END
	ELSE IF @RoleId = 2
	BEGIN
		SELECT	@UplineCredit		= SUM(CASE WHEN roleId = 3 THEN ISNULL(credit, 0) ELSE 0 END),
				@UplineUsedCredit	= SUM(CASE WHEN roleId = 2 THEN ISNULL(credit, 0) ELSE 0 END),
				@UsedCredit			= SUM(CASE WHEN recommend = @custId AND roleId = 1 THEN ISNULL(credit, 0) ELSE 0 END) 
		FROM dbo.custInfo WITH (NOLOCK)
		WHERE mrecommend = @mrecommend

		SELECT @UplineStatus = CustStatus FROM dbo.f_CS_GetCustomerStatus(@mrecommend)

		SELECT	@MinCredit = ISNULL(@UsedCredit, 0),
				@MaxCredit = ISNULL(@UplineCredit, 0) - ISNULL(@UplineUsedCredit, 0) + ISNULL(@Credit, 0)
	END
	ELSE IF @RoleId = 1
	BEGIN
		SELECT @UplineStatus = CustStatus FROM dbo.f_CS_GetCustomerStatus(@recommend)
	END

	IF @UplineStatus <> 4
	BEGIN
		-- You cannot do this action because this account''s upline is not active.
		SELECT @ErrCode = 102, @ErrMsg = dbo.f_Get_MsgNamebyMsgID (70029, @Language)

		RETURN
	END

	-- SP check on SMA/MA/Agent, web check Member
	IF (@RoleId IN (2,3) AND @UpdCredit NOT BETWEEN @MinCredit AND @MaxCredit)
		OR (@RoleId = 4 AND @UpdCredit < @MinCredit) -- SMA not have MaxCredit
	BEGIN
		-- New Credit is out of range, please refresh the form and try again.
		SELECT @ErrCode = 103, @ErrMsg = dbo.f_Get_MsgNamebyMsgID (70026, @Language)

		RETURN
	END

	BEGIN TRY
		UPDATE dbo.custInfo WITH (ROWLOCK, UPDLOCK)
		SET credit = @UpdCredit
			,CreditUpdatedDate = GETDATE()
		WHERE custId = @custId
	END TRY
	BEGIN CATCH
		-- Update process is unsuccessful.
		SELECT @ErrCode = 104, @ErrMsg = dbo.f_Get_MsgNamebyMsgID (90001, @Language)
		RETURN
	END CATCH

	-- Write log
	DECLARE @ActionId INT, @levelName VARCHAR(20), @LogData VARCHAR(500)
	SELECT  @ActionId = CASE @RoleId
							WHEN 1 THEN 1217
							WHEN 2 THEN 1218
							WHEN 3 THEN 1219
							WHEN 4 THEN 1220
							END
			,@levelName = CASE @RoleId
							WHEN 1 THEN 'Member'
							WHEN 2 THEN 'Agent'
							WHEN 3 THEN 'Master Agent'
							WHEN 4 THEN 'SMA'
							END

	SELECT  @LogData = 'Update Credit for ' + @levelName + ' Account ' + COALESCE(@username, SPACE(1))

	IF @SubAccID > 0
	BEGIN  
		SELECT @LogData = @LogData + ' by Sub-Account ' + COALESCE(dbo.f_GetSubUsername(@SubAccId), SPACE(1))
	END

	EXEC dbo.CS_WriteLog_UserLog_Credit_Wrapper
		@UserId		= @UserId,
		@CustId		= @CustId,
		@Doing		= @LogData,
		@OldValue	= @Credit,
		@NewValue	= @UpdCredit,
		@IP			= @IP,
		@ActionId	= @ActionId
END
GO