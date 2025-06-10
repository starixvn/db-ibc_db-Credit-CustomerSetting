/*<info serverAlias="DBGLOB-GlobCustDB" executers="asv_CashService" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[API_CustomerIns_CashMember_Register]
	@Username VARCHAR(30),
	@UserName2 VARCHAR(50),
	@UplineId INT,
	@roleid TINYINT = 1, -- roleid of New account	
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(2000) = '' OUTPUT,
	@CustID	INT = NULL OUTPUT	
AS
/*
	Created: 20250517@Elodie 
	Task : Insert new cash member--> Register Username/username2 on DBGLOB
	DB:  DBGLOB-GlobCustDB
	Original sp: 
	
	Revisions: 
		- 20241107@Elodie: Offer Cash service [redmine: #224778]

	Param's Explanation: 
	Examples:
	    DECLARE @CustID	INT = NULL,
				@ErrCode INT = 0,
				@ErrMsg NVARCHAR(2000) = ''
		EXEC [API_CustomerIns_CashMember_Register]
			 @UserName		= 'sabacoinsSBC01S117835055'
			,@UserName2		= 'sabacoins$117835055'
			,@UplineID		= 117835401
			,@roleid		= 1			
			,@CustID		= @CustID OUT
			,@ErrCode		= @ErrCode OUT
			,@ErrMsg		= @ErrMsg OUT

		SELECT  @CustID	AS  CustID
			   ,@ErrCode AS ErrCode
			   ,@ErrMsg	AS ErrMsg
*/	
BEGIN
	SET NOCOUNT ON 
	IF @Username = @username2
	BEGIN
		SELECT @ErrMsg = 'The username is not available.'
			, @ErrCode = 10

		RETURN
	END

	--Check exist username2
	IF EXISTS(SELECT 1 FROM CustInfoMini WITH(NOLOCK) WHERE username = @username2)  
		OR EXISTS(SELECT 1 FROM CustInfoMini WITH (NOLOCK) WHERE username2 = @username2)  
		OR EXISTS(SELECT 1 FROM CustSubMini WITH (NOLOCK) WHERE username = @username2)  
		OR EXISTS(SELECT 1 FROM CustSubMini WITH (NOLOCK) WHERE username2 = @username2) 
	BEGIN
		SELECT @ErrMsg = 'The username is not available.'
			, @ErrCode = 11

		RETURN
	END

	--Check exist username
	IF EXISTS(SELECT 1 FROM CustInfoMini WITH(NOLOCK) WHERE username = @username)  
		OR EXISTS(SELECT 1 FROM CustInfoMini WITH (NOLOCK) WHERE username2 = @username)  
		OR EXISTS(SELECT 1 FROM CustSubMini WITH (NOLOCK) WHERE username = @username)  
		OR EXISTS(SELECT 1 FROM CustSubMini WITH (NOLOCK) WHERE username2 = @username)		
	BEGIN
		SELECT @ErrMsg = 'The username is not available.'
			, @ErrCode = 201

		RETURN
	END		
	-----------Insert to CustInfoMini-------------
	BEGIN TRY	
		INSERT INTO dbo.CustInfoMini(username,username2,recommend, mrecommend,srecommend,roleid,SiteDBGroupID,Site, Currency)
		SELECT @Username, @UserName2, recommend,mrecommend, srecommend, @roleid, SiteDBGroupID, site, Currency
		FROM dbo.CustInfoMini WITH(NOLOCK)
		WHERE custid = @UplineId
		
		SET @custid = SCOPE_IDENTITY()  		
		
	END TRY
	BEGIN CATCH  
		SELECT @ErrCode = 911 ,
			@ErrMsg = 'Create customer failed. Please try again.'
		RETURN
	END CATCH  
END	