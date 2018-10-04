/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet" viewers="vnteam" isFunction="0"></info>*/
USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Age_MaxMemberLimitBySuperCheck]    Script Date: 10/04/2018 15:13:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Age_MaxMemberLimitBySuperCheck]
	@AgentId	INT,
	@Language	VARCHAR(10) = 'E',
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(300) = '' OUTPUT
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
	
	SET @ErrCode = CASE
							WHEN @CurrentMembers > = @MaxMemberLimit THEN 1
							ELSE 0
						END
	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40038,@Language)
	END
END
GO
GRANT EXECUTE ON [dbo].[Age_MaxMemberLimitBySuperCheck] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Age_MaxMemberLimitBySuperCheck] TO [bodbDownlineNet]