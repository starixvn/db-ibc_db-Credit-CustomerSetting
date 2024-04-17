/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_xnap,wsv_alp,wsv_alpv" selecters="" viewers="vnteam" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE Acc_CustomerSelProductStatus
	  @SportName		VARCHAR(20)
	, @CustID			INT
	, @RoleID			TINYINT
	, @Status			BIT = 0 OUTPUT
	, @UplineStatus		BIT = 0 OUTPUT
	, @DownlineStatus	BIT = 0 OUTPUT
AS
/*
	Created: Elodie@20151221
	Task: Get product status of customer
	DB: DBCUST/CustDB
	
	Revisions:
		- 20160126@Helen: get CB Status - [Redmine: 51387]
		- 20230620@Tacy: Remove columns and code used by Colossus Bets, GD product [RedmineID: #179132]
	
	Param's Explanation:

*/
BEGIN
	DECLARE @UplineID INT = 0

	SELECT @UplineID = CASE WHEN @RoleID = 3 THEN srecommend 
							WHEN @RoleID = 2 THEN mrecommend 
							WHEN @RoleID = 1 THEN recommend 
							END 
	FROM Customer WITH (NOLOCK) 
	WHERE custid = @CustID

	IF @SportName = 'SuperLive'
	BEGIN
		SELECT @Status = DisableSuperLive 
		FROM CustInfo WITH (NOLOCK)
		WHERE custid = @CustID

		IF @UplineID <> 0
			SELECT @UplineStatus = DisableSuperLive 
			FROM CustInfo WITH (NOLOCK)
			WHERE custid = @UplineID

		IF @RoleID = 4
			BEGIN
				SELECT	@DownlineStatus = @DownlineStatus | COALESCE(i.DisableSuperLive, CAST(1 AS BIT))
				FROM	custInfo i WITH(NOLOCK)
				WHERE	i.srecommend = @CustID
					AND	i.custid <> @CustID
			END
			ELSE IF @RoleID = 3
			BEGIN
				SELECT	@DownlineStatus = @DownlineStatus | COALESCE(i.DisableSuperLive, CAST(1 AS BIT))
				FROM	custInfo i WITH(NOLOCK)
				WHERE	i.mrecommend = @CustID
					AND	i.custid <> @CustID
			END
			ELSE IF @RoleID = 2
			BEGIN
				SELECT	@DownlineStatus = @DownlineStatus | COALESCE(i.DisableSuperLive, CAST(1 AS BIT))
				FROM	custInfo i WITH(NOLOCK)
				WHERE	i.recommend = @CustID
					AND	i.custid <> @CustID
			END
	END
END	
GO