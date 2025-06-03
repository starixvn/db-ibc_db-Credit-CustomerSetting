/*<info serverAlias="DBGLOB-GlobCustDB" executers="asv_CashService" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[API_CustomerInsMember_CashMember_CheckUsername]
	@username		VARCHAR(30)	
	,@ErrCode		INT = 0 OUTPUT
	,@ErrMsg		NVARCHAR(MAX) = '' OUTPUT	
	
AS
/*
	Created: 20250509@Elodie	
	Task: Validate username when member register from member site
	DB: DBGLOB.GlobCustDB
	
	Revisions:
		- 20250423@Elodie: Offer Cash Member [redmine: #223896] 
		
	Parameter's Explanation:	
	
*/	
BEGIN
	SET NOCOUNT ON	

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
END
GO
