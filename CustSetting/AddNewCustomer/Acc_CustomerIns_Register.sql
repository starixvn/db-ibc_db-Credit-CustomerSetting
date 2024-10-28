/*<info serverAlias="DBGLOB-GLOBCUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerIns_Register]
(
	@username	VARCHAR(30),
	@sitedbgroupid	TINYINT, 
	@site		VARCHAR(10)= NULL,
	@roleid		TINYINT = NULL,
	@UplineID	INT = NULL,
	@currency INT = NULL,
	@Language	VARCHAR(2)= 'E',
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg	NVARCHAR(4000) = '' OUTPUT,
	@custid	INT = 0 OUTPUT
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
		- 20241028@July: [Scale out DBCUST] Wrong Currency [Redmine: #212777]
		
	Parameter's Explanation:
		
*/	
BEGIN
	SET NOCOUNT ON

	IF @roleid = 4 AND (@currency IS NULL OR @currency = 0 )
	BEGIN
		SELECT @ErrMsg ='Failed to create Super due to invalid currency [0 or Null].'
			 , @ErrCode = 100
		RETURN
	END

	IF @roleid = 4 AND (@site IS NULL OR @site = '' )
	BEGIN
		SELECT @ErrMsg ='Failed to create Super due to invalid site [Empty or Null].'
			 , @ErrCode = 100
		RETURN
	END

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
	
	-----------Generate systemid (username)---------------
	DECLARE @recommend INT = 0,	@mrecommend INT = 0, @srecommend INT = 0

	IF @roleid = 1
	BEGIN
		SELECT @recommend = recommend,
			@mrecommend = mrecommend,
			@srecommend = srecommend,
			@Currency = Currency
		FROM dbo.CustInfoMini WITH(NOLOCK)    
		WHERE custid = @UplineID 
	END
	ELSE IF @roleid = 2
	BEGIN
		SELECT @mrecommend = mrecommend,
			@srecommend = srecommend,
			@Currency = Currency
		FROM dbo.CustInfoMini WITH(NOLOCK)    
		WHERE custid = @UplineID 
	END
	ELSE IF @roleid = 3
	BEGIN
		SELECT @srecommend = srecommend,
			@Currency = Currency
		FROM dbo.CustInfoMini WITH(NOLOCK)    
		WHERE custid = @UplineID 
	END

	BEGIN TRY
		---UAT Test
		/*
		SELECT @custid = NEXT VALUE FOR dbo.seq_CustinfoMini

		IF @roleid = 4   
			SET @srecommend = @CustID
		ELSE IF @roleid = 3
			SET @mrecommend = @CustID
		ELSE IF @roleid = 2
			SET @recommend = @CustID

		INSERT INTO dbo.CustInfoMini (custid,username,sitedbgroupid, srecommend, mrecommend, recommend,currency, site, roleid) 
		VALUES (@custid,@username,@sitedbgroupid, @srecommend, @mrecommend, @recommend, @currency, @site, @roleid )
		*/
		--PRO
		
		INSERT INTO dbo.CustInfoMini (username,sitedbgroupid, srecommend, mrecommend, recommend,currency, site, roleid) 
			VALUES (@username,@sitedbgroupid, @srecommend, @mrecommend, @recommend, @currency, @site, @roleid)
		SET @custid = SCOPE_IDENTITY()

		IF @roleid = 4 
		BEGIN
			UPDATE CustInfoMini WITH(ROWLOCK,UPDLOCK)
			SET srecommend = @CustID
			WHERE custid = @CustID
		END
		ELSE IF @roleid = 3 
		BEGIN
			UPDATE CustInfoMini WITH(ROWLOCK,UPDLOCK)
			SET mrecommend = @CustID
			WHERE custid = @CustID
		END
		ELSE IF @roleid = 2 
		BEGIN
			UPDATE CustInfoMini WITH(ROWLOCK,UPDLOCK)
			SET recommend = @CustID
			WHERE custid = @CustID
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

