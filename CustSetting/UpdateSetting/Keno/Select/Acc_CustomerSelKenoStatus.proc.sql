ALTER PROCEDURE [dbo].[Acc_CustomerSelKenoStatus] 
	@custid INT
	, @roleid INT = NULL
	, @uplineId INT = NULL
	, @HasDownline BIT = 0 OUTPUT
AS
/*
	Created: Bobby
	Date: 2014-03-04
	DB: DBCUST.CustDB
	Task: get disable status of Keno
	
	Revisions:
		- 20140320@Bobby: Add output @HasDownline
		- 20140605@Elodie: Expand bettype for Keno
		- 20140806@Johnson: put WITH(NOLOCK) for missing SELECT commands
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB, use temp table for GameType)
*/
BEGIN
	SET NOCOUNT ON

	----- 20150610@Kos -------------------
	DECLARE @tmp_GameType TABLE (GameTypeID INT, GameTypeName NVARCHAR(50), IsDisabled BIT, IBCBettypeID INT)	

	BEGIN TRY
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK)
	END TRY
	BEGIN CATCH
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK)
	END CATCH
	-----20150610@Kos -------------------

	DECLARE @custRoleid INT, @srecommend INT, @mrecommend INT, @recommend INT
	DECLARE @kenoGameType TABLE (gametypeid INT, isdisabled BIT DEFAULT 0)

	SELECT TOP 1 @custRoleid = roleid, @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend
	FROM dbo.custinfo WITH (NOLOCK)
	WHERE custid = @custid

	--check belong to
	--IF((@roleid > 0 AND @roleid <> @custRoleid)
	--	OR (@uplineId > 0 AND @uplineId <> CASE @custRoleid
	--			WHEN 3 THEN @srecommend
	--			WHEN 2 THEN @srecommend
	--			WHEN 1 THEN @recommend END)
	--	OR (@custRoleid NOT IN (1,2,3,4))) RETURN;

	INSERT INTO @kenoGameType (gametypeid)
	SELECT gametypeid
	FROM @tmp_GameType
	WHERE [IBCBetTypeID] >=  1501 AND [IBCBetTypeID] <= 1599
		AND IsDisabled = 0
	ORDER BY gametypeid

	--check keno-downline
	SELECT *
	INTO #kenoDownlines
	FROM @kenoGameType

	IF (@custRoleid = 4)
	BEGIN
		--check has-dowline
		SELECT TOP 1 @HasDownline = 1
		FROM dbo.custInfo c WITH (NOLOCK)
		WHERE srecommend = @custid AND roleid = 3
		IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo c WITH (NOLOCK) WHERE srecommend = @custid AND roleid = 3 AND hidekeno = 1)
		BEGIN
			UPDATE #kenoDownlines
			SET isdisabled = 1
		END
		ELSE
		BEGIN
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 0)
			FROM #kenoDownlines k
				LEFT JOIN (	SELECT DISTINCT g.gametypeid, g.IsDisabled
							FROM dbo.CustGameType g WITH (NOLOCK)
								INNER JOIN dbo.custInfo c WITH (NOLOCK) ON g.CustID = c.custid
							WHERE (c.custid = @custid OR ( c.srecommend = @custid AND c.roleid = 3)) AND g.IsDisabled = 1
							) t ON k.gametypeid = t.GameTypeID
		END
	END

	IF (@custRoleid = 3)
	BEGIN
		--check has-dowline
		SELECT TOP 1 @HasDownline = 1
		FROM dbo.custInfo c WITH (NOLOCK)
		WHERE mrecommend = @custid AND roleid = 2
		IF EXISTS (	SELECT TOP 1 1 FROM dbo.custInfo c WITH (NOLOCK) WHERE mrecommend = @custid	AND roleid = 2 AND hidekeno = 1)
		BEGIN
			UPDATE #kenoDownlines
			SET isdisabled = 1
		END
		ELSE
		BEGIN
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 0)
			FROM #kenoDownlines k
				LEFT JOIN ( SELECT DISTINCT g.gametypeid, g.IsDisabled
							FROM dbo.CustGameType g WITH (NOLOCK)
								INNER JOIN dbo.custInfo c WITH (NOLOCK) ON g.CustID = c.custid
							WHERE (c.custid = @custid OR ( c.mrecommend = @custid AND c.roleid = 2)) AND g.IsDisabled = 1
							) t ON k.gametypeid = t.GameTypeID
		END
	END

	IF (@custRoleid = 2)
	BEGIN
		--check has-dowline
		SELECT TOP 1 @HasDownline = 1
		FROM dbo.custInfo c WITH (NOLOCK)
		WHERE recommend = @custid
			AND roleid = 1
		IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo c WITH (NOLOCK) WHERE recommend = @custid AND roleid = 1 AND hidekeno = 1)
		BEGIN
			UPDATE #kenoDownlines
			SET isdisabled = 1
		END
		ELSE
		BEGIN
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 0)
			FROM #kenoDownlines k
				LEFT JOIN (	SELECT DISTINCT g.gametypeid, g.IsDisabled
							FROM dbo.CustGameType g WITH (NOLOCK)
								INNER JOIN dbo.custInfo c WITH (NOLOCK) ON g.CustID = c.custid
							WHERE (c.custid = @custid OR ( c.recommend = @custid AND c.roleid = 1)) AND g.IsDisabled = 1
							) t ON k.gametypeid = t.GameTypeID
		END
	END

	--check keno-upline
	;WITH kenoUpline
	AS (
		--upline
		SELECT g.GameTypeID, IsDisabled = CASE WHEN c.HideKeno = 0 AND g.IsDisabled = 0 THEN 0 ELSE 1 END
		FROM [dbo].[custInfo] c
			CROSS APPLY (	SELECT t.GameTypeID, isnull(g1.isdisabled, 0) isdisabled
							FROM @kenoGameType t
								LEFT JOIN (	SELECT GameTypeID, isdisabled
											FROM dbo.CustGameType WITH(NOLOCK)
											WHERE custid = c.custid
											) g1 ON t.gametypeid = g1.GameTypeID
						) g
		WHERE c.custid = CASE @custRoleid	WHEN 3 THEN @srecommend
											WHEN 2 THEN @mrecommend
											WHEN 1 THEN @recommend ELSE 0 END	
		)
		-- customer
		,kenoCustomer
	AS (
		SELECT UserName, 202 AS SportType, g.GameTypeID, gt.IBCBetTypeID, 
				IsDisabled = CASE WHEN c.HideKeno = 0 AND g.IsDisabled = 0 THEN 0 ELSE 1 END
		FROM [dbo].[custInfo] c WITH(NOLOCK)
			CROSS JOIN (SELECT t.GameTypeID, isnull(g1.isdisabled, 1) isdisabled
						FROM @kenoGameType t
							LEFT JOIN (	SELECT GameTypeID, isdisabled
										FROM dbo.CustGameType WITH(NOLOCK)
										WHERE custid = @custid
										) g1 ON t.gametypeid = g1.GameTypeID
						) g
			LEFT JOIN @tmp_GameType gt ON g.GameTypeID = gt.GameTypeID
		WHERE c.custid = @custid
		)

	SELECT c.UserName, c.SportType, c.GameTypeID, c.IBCBetTypeID, 
			CASE WHEN c.IsDisabled = 0 AND ISNULL(u.IsDisabled, 0) = 0 THEN 0 ELSE 1 END IsDisabled, 
			ISNULL(u.IsDisabled, 0) DisableUplines, 
			CASE WHEN c.IsDisabled = 0 AND ISNULL(d.IsDisabled, 0) = 0 THEN 0 ELSE 1 END DisableDownlines
	FROM kenoCustomer c
		LEFT JOIN kenoUpline u ON c.GameTypeID = u.GameTypeID
		LEFT JOIN #kenoDownlines d ON c.GameTypeID = d.GameTypeID;

	DROP TABLE #kenoDownlines
END



GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelKenoStatus] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelKenoStatus] TO [bodbDownlineNet] AS [dbo]
