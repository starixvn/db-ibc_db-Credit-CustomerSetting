ALTER PROCEDURE  [dbo].[Acc_CustomerSelRefSport_Bettype]
	 @CustID		INT = NULL
	,@RoleID		INT = 0 
	,@isShowAll		BIT = 1 
AS 
/*
	Created by: Jamie
	Date: 20140916
	Task: Retrieve Customer Setting Reference 
	DB: DBTXN/bodb02 

	Revision: 
		- 20150606@Kathy: Change link server DBTXN.CustDB to DBCust.CustDB [Redmine:#36216]
		- 20150904@Helen: commission setting for MO [Redmine #41470]
		- 20160201@Percy: Support new Cricket [Redmine: #50027]
		- 20160923@Winnie: PH_AIO-_Phase_2 Hide parent(413,414,416) and using Sport_Bettype_Reference_Setting  [Redmine: #63076]
		- 20161010@Elodie: Intergrate NG2 product

	Param's Explanation: 
		@CustID (Login account): =NULL: Admin ; =NOT NULL: SMA 
		@isShowAll: 0: Show Active Bettype, 1: Show ALL 

	Sample: 
				EXEC [Acc_CustomerSelRefSport_Bettype] @CustID = 19096909 , @RoleID = 2 

*/
BEGIN
	SET NOCOUNT ON 
	DECLARE	 @DisableHRFixedOdds	BIT = 0
			,@HideKeno				BIT = 0 
			,@DisableKeno			INT = 0 
			,@DisableNumber			BIT = 0 
			,@HideNG2				BIT = 0 
			,@IsMyanmarOdds BIT = 0
			,@recommend INT = 0
			,@isIMBC BIT = 0
	
	CREATE TABLE #tempRef (Bettype INT,GroupTypeId INT)	
	DECLARE @SearchQuery varchar(1024)
	SELECT @SearchQuery = 'SELECT * 
	FROM OPENQUERY(DBAGE, 
	''SELECT Bettype , GroupTypeId FROM bodb02.dbo.f_GroupBettype( )'')'
	INSERT INTO #tempRef
	EXECUTE(@SearchQuery)
	DELETE FROM #tempRef WHERE bettype=GroupTypeId

	IF @RoleID = 1 AND ISNULL(@CustID, 0) <> 0
		IF (SELECT [Site] FROM DBCUST.CustDB.dbo.Customer WITH (NOLOCK)
						  WHERE custid = (SELECT recommend FROM DBCUST.CustDB.dbo.Customer WITH (NOLOCK)
										  WHERE custid = @CustID)) = 'IMBC'
			SELECT @isIMBC = 1
	ELSE
		IF (SELECT [Site] FROM DBCUST.CustDB.dbo.Customer WITH (NOLOCK)
						  WHERE custid = @CustID) = 'IMBC'
			SELECT @isIMBC = 1
	
	IF @RoleID BETWEEN 2 AND 4 
	BEGIN
			SELECT	 @DisableHRFixedOdds = ci.DisableHRFixedOdds
					,@HideKeno			 = ci.HideKeno
					,@DisableNumber		 = ci.DisableNumber
					
			FROM	CustDB.dbo.CustInfo ci WITH (NOLOCK) 
			WHERE	ci.CustID = @CustID

			SELECT	@DisableKeno = MIN(CAST(cg.IsDisabled AS INT))
			FROM	DBCUST.CustDB.dbo.CustGameType cg WITH (NOLOCK) 
					LEFT JOIN dbo.GameType g WITH (NOLOCK) ON cg.GameTypeID = g.GameTypeID 
			WHERE	cg.CustID = @CustID
					AND g.IBCBetTypeID IN (1501,1503,1504,1505,1507,1508,1509,1511,1513)	--Keno Bettype 
			
			SET @IsMyanmarOdds = CustDB.dbo.fn_IsMyanmarOdds(@Custid)

			SELECT @HideNG2 = (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapIsHidden,4))
			FROM DBCUST.CustDB.dbo.CustProductStatus WITH (NOLOCK)
			WHERE CustID = @CustID		
	END
	
	IF @RoleID = 1
	BEGIN
		SET @recommend = (SELECT recommend FROM DBCUST.CustDB.dbo.CustInfo WITH (NOLOCK) WHERE custid=@CustID)
		SET @IsMyanmarOdds = CustDB.dbo.fn_IsMyanmarOdds(@recommend)
	END
	
	IF @RoleID = 0
		SET @IsMyanmarOdds = 1
		
	SELECT	Sporttype, Bettype, SporttypeRef, BettypeRef,ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
	FROM	dbo.Sport_Bettype_Reference WITH (NOLOCK)
	WHERE	Sporttype NOT IN (
				 CASE WHEN @DisableHRFixedOdds = 1 THEN 154 ELSE 0 END				--HR Fixed Odds
				,CASE WHEN @DisableNumber = 1 THEN 161 ELSE 0 END					--Number Game
				,CASE WHEN @HideKeno = 1 OR @DisableKeno = 1 THEN 202 ELSE 0 END	--Keno 
				,CASE WHEN @IsMyanmarOdds = 0 AND Bettype IN (301,302,303,304) THEN 1 ELSE 0 END -- MyanmarOdds
				,27, 50 -- Cricket
			)
			AND bettype NOT IN(SELECT Bettype FROM #tempRef)
			AND isLicensee = 0 
			AND isActive = CASE WHEN @isShowAll = 0 THEN 1 ELSE isActive END
	UNION ALL
	SELECT	Sporttype, Bettype, SporttypeRef, BettypeRef,ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
	FROM Sport_Bettype_Reference
	WHERE   Sporttype IN (27, 50)
			AND [Site] IN (
				 CASE WHEN ISNULL(@CustID, 0) = 0 THEN 'IMBC' END -- ALL
				,CASE WHEN ISNULL(@CustID, 0) = 0 THEN 'ALL'  END -- ALL
				,CASE WHEN ISNULL(@CustID, 0) <> 0 AND @isIMBC = 1 THEN 'IMBC' END -- IMBC only
				,CASE WHEN ISNULL(@CustID, 0) <> 0 AND @isIMBC = 0 THEN 'ALL'  END -- MBC  only
			)
			AND isLicensee = 0
			AND isActive = CASE WHEN @isShowAll = 0 THEN 1 ELSE isActive END
	
	UNION ALL 
	SELECT DISTINCT Sporttype, Bettype, SporttypeRefPT, BettypeRefPT,ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
	FROM Sport_Bettype_Reference_Setting b WITH(NOLOCK)
	WHERE   bettype NOT IN(SELECT Bettype FROM #tempRef)
			AND isLicensee = 0
			AND isActive = CASE WHEN @isShowAll = 0 THEN 1 ELSE isActive END
			AND (SportType<>SporttypeRefPT OR bettype <>BettypeRefPT)
			AND NOT EXISTS (SELECT TOP 1 1 FROM Sport_Bettype_Reference a (NOLOCK) WHERE a.Sporttype=b.SportType AND a.Bettype=b.BetType)
			AND (SportType<=99 OR b.SportType = 154 OR b.SportType BETWEEN 213 AND 218)
			AND 1 = CASE WHEN @HideNG2 = 1 AND b.SportType BETWEEN 213 AND 218 THEN 0 ELSE 1 END
	ORDER BY Sporttype, Bettype, SporttypeRef, BettypeRef
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelRefSport_Bettype] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelRefSport_Bettype] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelRefSport_Bettype] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelRefSport_Bettype] TO [bodbExtAccNet] AS [dbo]

