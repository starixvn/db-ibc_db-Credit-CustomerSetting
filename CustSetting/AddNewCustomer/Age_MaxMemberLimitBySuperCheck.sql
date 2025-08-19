/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_MaxMemberLimitBySuperCheck]
	@AgentId	INT,
	@Language	VARCHAR(10) = 'E',
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(300) = '' OUTPUT
AS

/*
	Created by: 20180924@Phillip
	Task: Limit max members creation per Super: #101994
	DB: DBCUST/CustDB
	Original:	
	
	Revisions:
		-20180924@Phillip: Init
		-20250730@Dave: Exclude cash member from the total member count [Redmine: #235266]
	
	Param's Explanation:
	- @AgentId: Agent Id
	- @Language: Language
	- @ErrCode: Error Code
	- @ErrMsg: Error Message
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @CurrentMembers INT,
			@MaxMemberLimit	INT,
			@SuperId		INT
		
	SELECT @SuperId = srecommend
	FROM dbo.custinfo WITH (NOLOCK)
	WHERE custid = @AgentId
		
	SELECT @MaxMemberLimit = MaxMember
	FROM dbo.CustSuper WITH (NOLOCK)
	WHERE CustId = @SuperId
	
	IF @MaxMemberLimit = -1
	BEGIN
		RETURN
	END
	
	SELECT @CurrentMembers = COUNT(1)
	FROM dbo.custinfo AS c WITH (NOLOCK)
	CROSS APPLY (SELECT TOP 1 ServiceType
				FROM vw_CustInfoExtra WITH (NOLOCK)
				WHERE custid = c.custid) ci
	WHERE c.srecommend = @SuperId
		AND c.roleid = 1
		AND c.[Enabled] = 1
		AND ci.ServiceType = 0; /* Exclude Cash Service Members */
	
	SET @ErrCode = CASE
		WHEN @CurrentMembers > = @MaxMemberLimit THEN 1
		ELSE 0
	END
	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrMsg = CASE @Language 
			WHEN 'E' THEN N'Sorry, you cannot create more Member accounts because the total Members under your upline have exceeded the limit. Please contact your upline for further assistance.'
			ELSE [dbo].[f_Get_MsgNamebyMsgID](40038,@Language)
			END
	END
END
GO
