/*<info serverAlias="DBCUST-CUSTDB" executers="bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0" isNested="0"></info>*/
USE [CustDB]
GO

ALTER PROCEDURE [dbo].[Age_MaxMemberLimitBySuperCheck]
	@AgentId		INT,
	@IsReachLimit	BIT OUTPUT
AS

/*
	Created by: 20180924@Phillip
	Task: Limit max members creation per Super: #101994
	DB: DBCUST.CustDB
	Original:	
	
	Revisions:
		-20180924@Phillip: Init
	
	Param's Explanation:
	- @AgentId: Agent Id
	- @IsReachLimit: Is Reach Limit or not
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @CurrentMembers INT,
			@MaxMemberLimit	INT,
			@SuperId		INT
			
	SELECT @CurrentMembers = COUNT(*)
	FROM dbo.custinfo WITH (NOLOCK)
	WHERE recommend = @AgentId
		AND roleid = 1
		AND [Enabled] = 1
		
	SELECT @SuperId = srecommend
	FROM dbo.custinfo WITH (NOLOCK)
	WHERE custid = @AgentId
	
	SELECT @MaxMemberLimit = MaxMember
	FROM dbo.CustSuper
	WHERE CustId = @SuperId
	
	SET @IsReachLimit = CASE
							WHEN @CurrentMembers > = @MaxMemberLimit THEN 1
							ELSE 0
						END
END