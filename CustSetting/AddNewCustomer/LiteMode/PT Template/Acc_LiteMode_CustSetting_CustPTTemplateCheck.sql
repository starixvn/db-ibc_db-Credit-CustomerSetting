/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_CustPTTemplateCheck] 
	@CustID INT,	
	@Settings VARCHAR(MAX),
	@CreationStatus TINYINT = 0,
	
	@Language VARCHAR(3) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20230509@Johnson  
	Task : Check PT Template List for customer
	DB:  DBCUST/CustDB  
	
	Revisions: 
		- 20230509@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
		- @Settings = '<Root>
						<r group="1" sub="1" pt="85" />
						<r group="2" sub="2" pt="85" />
						<r group="3" sub="5" pt="85" />
						<r group="3" sub="6" pt="85" />
						<r group="4" sub="0" pt="85" />
					</Root>'
		- group: Product Group/sub: Sub Group			
*/	
BEGIN
	SET NOCOUNT ON
	
	DECLARE @tmpSetting TABLE (groupID TINYINT, SubGroupID TINYINT, PT SMALLMONEY, MinPT SMALLMONEY, MaxPT SMALLMONEY)
	
	DECLARE @xml XML = CONVERT (XML,@Settings)
	
	INSERT INTO @tmpSetting(groupID,SubGroupID,PT)
	SELECT T.c.query('.').value('(r/@group)[1]', 'tinyint') AS GroupID,
		T.c.query('.').value('(r/@sub)[1]', 'tinyint') AS subGroupID,
		T.c.query('.').value('(r/@pt)[1]', 'smallmoney') AS PT
	FROM   @xml.nodes('/Root/r') T(c) 
	
	DECLARE @SiteLabel VARCHAR(10), @roleid TINYINT
	
	SELECT @roleid = roleid, @SiteLabel=s.SiteLabel 
	FROM customer c WITH(NOLOCK) 
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE CustID = @custid
		
	CREATE TABLE #SportBettypeFilter(SportType SMALLINT,Bettype SMALLINT, IsLive BIT, ProductID TINYINT)
	DECLARE @GroupID TINYINT,
		@GroupType TINYINT,
		@SubGroupID TINYINT
		
	IF @roleid = 4
	BEGIN 
		CREATE TABLE #tmpSuperPT (sporttype SMALLINT, bettype SMALLINT, IsLive BIT, groupID TINYINT, SubGroupID TINYINT, S4 SMALLMONEY)
		--check SB
		SELECT @GroupID = 1, @GroupType = 153, @SubGroupID = 1
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID)
		SELECT SportType,Bettype,IsLive,ProductID	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @SubGroupID, @CreationStatus) 
		
		INSERT INTO #tmpSuperPT(sporttype, bettype, IsLive,GroupID,SubGroupID, S4)
		SELECT cs.sporttype, cs.bettype, 0 IsLive, @GroupID, @SubGroupID,
			(CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END)*100 S4
		FROM CustSetting cs WITH(NOLOCK) 
			LEFT JOIN custoverride as co WITH (NOLOCK) ON cs.custid = co.custid AND cs.sporttype=co.sporttype and cs.bettype=co.bettype
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype 
				AND s.IsLive = 0
		WHERE cs.CustID = @custid
			AND 1 = case when cs.Sporttype = 2 AND cs.Bettype IN (7,8) THEN 0 ELSE 1 END
		UNION ALL 
		SELECT cs.sporttype, cs.bettype, 1 as IsLive, @GroupID, @SubGroupID,			
			(CASE WHEN cs.slivepositiontaking<co.maxlivepositiontaking THEN cs.slivepositiontaking ELSE co.maxlivepositiontaking END)*100 S4
		FROM CustSetting cs WITH(NOLOCK) 
			LEFT JOIN custoverride as co WITH (NOLOCK) ON cs.custid = co.custid AND cs.sporttype=co.sporttype and cs.bettype=co.bettype
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype 
				AND s.IsLive = 1
		WHERE cs.CustID = @custid
			AND cs.sporttype = 1
			AND cs.bettype IN (1,3,7,8)
		UNION ALL
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,@GroupID 
			,@SubGroupID
			, cs.SuperPT AS S4  			 
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
		WHERE cs.CustID = @custid		
		
		DELETE #SportBettypeFilter
		
		--check RNG Games
		SELECT @GroupID = 2, @GroupType = 153, @SubGroupID = 2
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID)
		SELECT SportType,Bettype,IsLive,ProductID	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @SubGroupID,@CreationStatus) 
		
		INSERT INTO #tmpSuperPT(sporttype, bettype, IsLive,GroupID,SubGroupID, S4)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,@GroupID 
			,@SubGroupID
			, cs.SuperPT AS S4  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
						
		DELETE #SportBettypeFilter
		
		--Allbet & SA Gaming
		SELECT @GroupID = 3, @GroupType = 153, @SubGroupID = 5
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID)
		SELECT SportType,Bettype,IsLive,ProductID	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @SubGroupID,@CreationStatus) 
		
		INSERT INTO #tmpSuperPT(sporttype, bettype, IsLive,GroupID,SubGroupID, S4)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			, @GroupID 
			, @SubGroupID
			, cs.SuperPT AS S4  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
		
		DELETE #SportBettypeFilter
		
		--Other Live Casino & RnG Games
		SELECT @GroupID = 3, @GroupType = 153, @SubGroupID = 6
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID)
		SELECT SportType,Bettype,IsLive,ProductID	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @SubGroupID,@CreationStatus) 
		
		INSERT INTO #tmpSuperPT(sporttype, bettype, IsLive,GroupID,SubGroupID, S4)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			, @GroupID 
			, @SubGroupID
			, cs.SuperPT AS S4  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
		
		DELETE #SportBettypeFilter
				
		--check NG2
		IF @SiteLabel = '789y'
		BEGIN
			SELECT @GroupID = 4, @GroupType = 160, @SubGroupID = NULL
		
			INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID)
			SELECT SportType,Bettype,IsLive,ProductID	
			FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @SubGroupID,@CreationStatus) 
			
			INSERT INTO #tmpSuperPT(sporttype, bettype, IsLive,GroupID,SubGroupID, S4)
			SELECT cs.SportType  
				, cs.BetType  
				, cs.IsLive  
				, @GroupID 
				, 0 SubGroupID
				, cs.SuperPT AS S4  			 
			FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
				INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
													AND cs.BetType = ft.bettype
													AND cs.IsLive = ft.islive
			WHERE custid = @custid
			
			DELETE #SportBettypeFilter
		END		
				
		IF EXISTS (	
			SELECT TOP 1 1
			FROM #tmpSuperPT t
				INNER JOIN @tmpSetting s ON t.GroupID = s.GroupID
											AND t.SubGroupID = s.SubGroupID
			WHERE t.S4 < s.PT
		)
		BEGIN		
			SET @xml = (
						SELECT 20046 AS '@MsgID'
							, 'Invalid Position Taking(max set by upline).' AS '@Msg'
							, (
								SELECT t.SportType AS '@SportType'
									, t.BetType AS '@BetType'
									, t.IsLive AS '@IsLive'
									, t.S4 AS '@MaxPT'
								FROM #tmpSuperPT t
									INNER JOIN @tmpSetting s ON t.GroupID = s.GroupID
																AND t.SubGroupID = s.SubGroupID
								WHERE t.S4 < s.PT
								FOR XML PATH('Row')
									, TYPE
								)
						FOR XML PATH('Root')
							, TYPE
						)
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @ErrType = 63
			SET @ErrCode = 101			
		END		
	END
END	