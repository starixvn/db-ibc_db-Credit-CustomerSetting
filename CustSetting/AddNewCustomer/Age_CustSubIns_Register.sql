/*<info serverAlias="DBGLOB-GLOBCUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_CustSubIns_Register]
(
	@username	VARCHAR(30) = NULL,
	@Nickname VARCHAR(50) = NULL,
	@custid	INT,
	@sitedbgroupid	SMALLINT = 0, 
	@Language	VARCHAR(2)= 'E',
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg	NVARCHAR(4000) = '' OUTPUT,
	@SubAccID	INT = 0 OUTPUT
)
AS
/*
	Created: Helen
	Date: 2024-07-04
	Task: register username/nickname/custid for CREDIT
	DB: DBGLOB-GLOBCUSTDB
	
	Revisions:
		- 20240704@Helen:register username/nickname/custid for CREDIT - [Redmine:#206823]
		- 20241001@Helen: release with new structure on GlobCustDB instead of using view on CUSTDB - [Redmine:#206823]
		- 20241024@Eden: Change datatype @sitedbgroupid to smallint [Redmine:#206823]

	Parameter's Explanation:
		
*/	
BEGIN
	SET NOCOUNT ON

	IF @Nickname IS NOT NULL
		SET @username = @Nickname
	
	SELECT  @username = RTRIM(LTRIM(@username))
	
	IF EXISTS (SELECT 1 FROM dbo.CustInfoMini WITH(NOLOCK) WHERE username = @username)
			OR EXISTS (SELECT 1 FROM dbo.CustInfoMini WITH (NOLOCK) WHERE username2 = @username)
			OR EXISTS (SELECT 1 FROM dbo.CustSubMini WITH (NOLOCK) WHERE username = @username)
			OR EXISTS (SELECT 1 FROM dbo.CustSubMini WITH (NOLOCK) WHERE username2 = @username)
	BEGIN
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'This username is not available.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
							END		
				, @ErrCode = 201
		RETURN
	END
	
	BEGIN TRY
		IF @Nickname IS NULL
		BEGIN
			--UAT
			/*
			SELECT @SubAccID = NEXT VALUE FOR dbo.seq_CustSubMini 
			INSERT INTO dbo.CustSubMini (subaccid,custid,username,sitedbgroupid) VALUES (@SubAccID, @custid,@username,@sitedbgroupid)
			*/
			-- PRO
			
			INSERT INTO dbo.CustSubMini (custid,username,sitedbgroupid) VALUES (@custid,@username,@sitedbgroupid)
			SET @SubAccID = SCOPE_IDENTITY()
			
		END
		ELSE 
		BEGIN
			UPDATE [dbo].CustSubMini WITH (ROWLOCK)  
				SET Username2 = @Nickname, RepUpdateTime = SYSDATETIME()
			WHERE subaccid = @subaccid AND CustID = @custid AND ISNULL(Username2, '') = ''
		END
	END TRY
	BEGIN CATCH
		IF @@ERROR = 2627 --- duplicate username
			SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'This username is not available.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
						END		
				, @ErrCode = 201
		ELSE
			SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Create customer failed. Please try again.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						END
			, @ErrCode = 112
	END CATCH
	
END
GO

