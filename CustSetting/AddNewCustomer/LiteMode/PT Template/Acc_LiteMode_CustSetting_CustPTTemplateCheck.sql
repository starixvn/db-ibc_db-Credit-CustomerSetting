/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_CustPTTemplateCheck] 
	@CustID INT,	
	@Settings VARCHAR(MAX),
	@SettingStatus TINYINT = 0,
	
	@Language VARCHAR(3) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20230509@Johnson  
	Task : Check PT Template List for customer
	DB:  DBCUST/CustDB  
	
	Revisions: 
		- 20230509@Johnson: initial sp [redmine: #179159]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20250404@Helios: Database - Remove un-used tables of credit - Remove redundant code [redmine: #221908]

	Param's Explanation: 
		- @Settings = '<Root>
						<r group="1" sub="1" pt="85" />
						<r group="2" sub="2" pt="85" />
						<r group="3" sub="5" pt="85" />
						<r group="3" sub="6" pt="85" />						
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
	
	DECLARE @roleid TINYINT, @srecommend INT, @siteID INT, @currency SMALLINT
	
	SELECT @roleid = roleid, @srecommend = srecommend, @siteID = Siteid, @currency = c.currency
	FROM customer c WITH(NOLOCK)
		INNER JOIN site s WITH(NOLOCK) ON c.site = s.site
	WHERE CustID = @custid
		
	CREATE TABLE #SportBettypeFilter(SportType SMALLINT,Bettype SMALLINT, IsLive BIT,SettingLevel TINYINT, productID TINYINT)
	CREATE TABLE #tmpPT (sporttype SMALLINT, bettype SMALLINT, IsLive BIT, ProductID TINYINT, groupID TINYINT, SubGroupID TINYINT, SettingLevel TINYINT, MaxPT SMALLMONEY, MinPT SMALLMONEY)
	
	DECLARE @GroupID TINYINT,
		@GroupType TINYINT,
		@SubGroupID TINYINT
		
	IF @roleid = 4
	BEGIN 		
		--check SB
		SELECT @GroupID = 1, @GroupType = 153, @SubGroupID = 1
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency) 
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel,MaxPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,ProductID
			,@GroupID 
			,@SubGroupID
			,SettingLevel
			, cs.SuperPT AS MaxPT  			 
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
		WHERE cs.CustID = @custid		
		
		DELETE #SportBettypeFilter
		
		--check RNG Games
		SELECT @GroupID = 2, @GroupType = 153, @SubGroupID = 2
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive
			,ProductID	
			,@GroupID 
			,@SubGroupID
			,SettingLevel
			, cs.SuperPT AS MaxPT  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
						
		DELETE #SportBettypeFilter
		
		--LCS
		SELECT @GroupID = 3, @GroupType = 153, @SubGroupID = 6
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive 
			, ProductID
			, @GroupID 
			, @SubGroupID
			,SettingLevel
			, cs.SuperPT AS MaxPT  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
		
		DELETE #SportBettypeFilter
		
		--Other RNG Casino
		SELECT @GroupID = 3, @GroupType = 153, @SubGroupID = 5
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive 
			, ProductID
			, @GroupID 
			, @SubGroupID
			,SettingLevel
			, cs.SuperPT AS MaxPT  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
		
		DELETE #SportBettypeFilter
		
		--IBCBet LCS
		SELECT @GroupID = 3, @GroupType = 153, @SubGroupID = 8
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID	
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			, ProductID
			, @GroupID 
			, @SubGroupID
			,SettingLevel
			, cs.SuperPT AS MaxPT  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
		
		DELETE #SportBettypeFilter
		
		--Other Games
		SELECT @GroupID = 4, @GroupType = 153, @SubGroupID = 10
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID	
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			, ProductID
			, @GroupID 
			, @SubGroupID
			,SettingLevel
			, cs.SuperPT AS MaxPT  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
		
		DELETE #SportBettypeFilter
		
		IF EXISTS (	
			SELECT TOP 1 1
			FROM #tmpPT t
				INNER JOIN @tmpSetting s ON t.GroupID = s.GroupID
											AND t.SubGroupID = s.SubGroupID
			WHERE t.MaxPT < s.PT
		)
		BEGIN		
			SET @xml = (
						SELECT 20046 AS '@MsgID'
							, 'Invalid Position Taking(max set by upline).' AS '@Msg'
							, (
								SELECT t.SportType AS '@SportType'
									, t.BetType AS '@BetType'
									, t.IsLive AS '@IsLive'
									, t.MaxPT AS '@MaxPT'
									, SettingLevel as '@SettingLevel'
									, t.ProductID as '@ProductID'
								FROM #tmpPT t
									INNER JOIN @tmpSetting s ON t.GroupID = s.GroupID
																AND t.SubGroupID = s.SubGroupID
								WHERE t.MaxPT < s.PT
								FOR XML PATH('Row')
									, TYPE
								)
						FOR XML PATH('Root')
							, TYPE
						)
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 63
			SET @ErrCode = 101			
		END	
	END
	ELSE IF @roleid = 3
	BEGIN
		--check SB
		SELECT @GroupID = 1, @GroupType = 153, @SubGroupID = 1
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,ProductID
			,@GroupID 
			,@SubGroupID
			,SettingLevel
			, cs.MasterPT AS MaxPT  			 
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
		WHERE cs.CustID = @custid		
		
		DELETE #SportBettypeFilter
		
		--check RNG Games
		SELECT @GroupID = 2, @GroupType = 153, @SubGroupID = 2
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,ProductID
			,@GroupID 
			,@SubGroupID
			,SettingLevel
			, cs.MasterPT AS MaxPT  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
						
		DELETE #SportBettypeFilter
		
		--LCS
		SELECT @GroupID = 3, @GroupType = 153, @SubGroupID = 6
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID,@SettingStatus,@siteID,@currency) 
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,ProductID
			, @GroupID 
			, @SubGroupID
			,SettingLevel
			, cs.MasterPT AS MaxPT  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
		
		DELETE #SportBettypeFilter
		
		--Other RnG Casino
		SELECT @GroupID = 3, @GroupType = 153, @SubGroupID = 5
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID,@SettingStatus,@siteID,@currency) 
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,ProductID
			, @GroupID 
			, @SubGroupID
			,SettingLevel
			, cs.MasterPT AS MaxPT  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
		
		DELETE #SportBettypeFilter
		
		--IBCBet Casino
		SELECT @GroupID = 3, @GroupType = 153, @SubGroupID = 8
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID	
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive 
			,ProductID
			, @GroupID 
			, @SubGroupID
			,SettingLevel
			, cs.MasterPT AS MaxPT  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
		
		DELETE #SportBettypeFilter
		
		--Others Games
		SELECT @GroupID = 4, @GroupType = 153, @SubGroupID = 10
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID	
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive 
			,ProductID
			, @GroupID 
			, @SubGroupID
			,SettingLevel
			, cs.MasterPT AS MaxPT  			 
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
		
		DELETE #SportBettypeFilter
		
		IF EXISTS (	
			SELECT TOP 1 1
			FROM #tmpPT t
				INNER JOIN @tmpSetting s ON t.GroupID = s.GroupID
											AND t.SubGroupID = s.SubGroupID
			WHERE t.MaxPT < s.PT
		)
		BEGIN		
			SET @xml = (
						SELECT 20046 AS '@MsgID'
							, 'Invalid Position Taking(max set by upline).' AS '@Msg'
							, (
								SELECT t.SportType AS '@SportType'
									, t.BetType AS '@BetType'
									, t.IsLive AS '@IsLive'
									, t.MaxPT AS '@MaxPT'
									, t.SettingLevel as '@SettingLevel'
									,ProductID as '@ProductID'
								FROM #tmpPT t
									INNER JOIN @tmpSetting s ON t.GroupID = s.GroupID
																AND t.SubGroupID = s.SubGroupID
								WHERE t.MaxPT < s.PT
								FOR XML PATH('Row')
									, TYPE
								)
						FOR XML PATH('Root')
							, TYPE
						)
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 63
			SET @ErrCode = 101			
		END	
	END
	ELSE IF @roleid = 2
	BEGIN
		--check SB
		SELECT @GroupID = 1, @GroupType = 153, @SubGroupID = 1
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT, MinPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,ProductID
			,@GroupID 
			,@SubGroupID
			,SettingLevel
			,(CASE WHEN cs.AgentPT< scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END) MaxPT			 
			,cs.MinPT
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
			INNER JOIN dbo.CustPTSetting3rd_Agent scs WITH (NOLOCK)  	
				ON scs.custid = @srecommend
				AND	scs.SportType = cs.sporttype  
				AND scs.BetType = cs.bettype  
				AND scs.IsLive = cs.islive
		WHERE cs.CustID = @custid
		
		DELETE #SportBettypeFilter
		
		--check RNG Games
		SELECT @GroupID = 2, @GroupType = 153, @SubGroupID = 2
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT, MinPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,ProductID
			,@GroupID 
			,@SubGroupID
			,SettingLevel
			,(CASE WHEN cs.AgentPT< scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END) MaxPT			 
			,cs.MinPT
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
			INNER JOIN dbo.CustPTSetting3rd_Agent scs WITH (NOLOCK)  	
				ON scs.custid = @srecommend
				AND	scs.SportType = cs.sporttype  
				AND scs.BetType = cs.bettype  
				AND scs.IsLive = cs.islive
		WHERE cs.CustID = @custid
						
		DELETE #SportBettypeFilter
		
		--LCS
		SELECT @GroupID = 3, @GroupType = 153, @SubGroupID = 6
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT, MinPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,ProductID
			,@GroupID 
			,@SubGroupID
			,SettingLevel
			,(CASE WHEN cs.AgentPT< scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END) MaxPT			 
			,cs.MinPT
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
			INNER JOIN dbo.CustPTSetting3rd_Agent scs WITH (NOLOCK)  	
				ON scs.custid = @srecommend
				AND	scs.SportType = cs.sporttype  
				AND scs.BetType = cs.bettype  
				AND scs.IsLive = cs.islive
		WHERE cs.CustID = @custid
		
		DELETE #SportBettypeFilter
		
		--Other RnG Casino
		SELECT @GroupID = 3, @GroupType = 153, @SubGroupID = 5
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
		
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT, MinPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,ProductID
			,@GroupID 
			,@SubGroupID
			,SettingLevel
			,(CASE WHEN cs.AgentPT< scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END) MaxPT			 
			,cs.MinPT
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
			INNER JOIN dbo.CustPTSetting3rd_Agent scs WITH (NOLOCK)  	
				ON scs.custid = @srecommend
				AND	scs.SportType = cs.sporttype  
				AND scs.BetType = cs.bettype  
				AND scs.IsLive = cs.islive
		WHERE cs.CustID = @custid
		
		DELETE #SportBettypeFilter
		
		--IBCBet LCS
		SELECT @GroupID = 3, @GroupType = 153, @SubGroupID = 8
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
				
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT, MinPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,ProductID
			,@GroupID 
			,@SubGroupID
			,SettingLevel
			,(CASE WHEN cs.AgentPT< scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END) MaxPT			 
			,cs.MinPT
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
			INNER JOIN dbo.CustPTSetting3rd_Agent scs WITH (NOLOCK)  	
				ON scs.custid = @srecommend
				AND	scs.SportType = cs.sporttype  
				AND scs.BetType = cs.bettype  
				AND scs.IsLive = cs.islive
		WHERE cs.CustID = @custid
		
		DELETE #SportBettypeFilter
		
		--Others Games
		SELECT @GroupID = 4, @GroupType = 153, @SubGroupID = 10
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingLevel,ProductID)
		SELECT SportType,Bettype,IsLive,SettingLevel,RealProductID
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType, @SubGroupID, @SettingStatus,@siteID,@currency)
				
		INSERT INTO #tmpPT(sporttype, bettype, IsLive,ProductID,GroupID,SubGroupID,SettingLevel, MaxPT, MinPT)
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			,ProductID
			,@GroupID 
			,@SubGroupID
			,SettingLevel
			,(CASE WHEN cs.AgentPT< scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END) MaxPT			 
			,cs.MinPT
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
			INNER JOIN dbo.CustPTSetting3rd_Agent scs WITH (NOLOCK)  	
				ON scs.custid = @srecommend
				AND	scs.SportType = cs.sporttype  
				AND scs.BetType = cs.bettype  
				AND scs.IsLive = cs.islive
		WHERE cs.CustID = @custid
		
		DELETE #SportBettypeFilter
		
		IF EXISTS (	
			SELECT TOP 1 1
			FROM #tmpPT t
				INNER JOIN @tmpSetting s ON t.GroupID = s.GroupID
											AND t.SubGroupID = s.SubGroupID
			WHERE t.MaxPT < s.PT
				OR t.MinPT > s.PT
		)
		BEGIN		
			SET @xml = (
						SELECT 20048 AS '@MsgID'
							, 'Invalid Position Taking(min/max set by upline).' AS '@Msg'
							, (
								SELECT t.SportType AS '@SportType'
									, t.BetType AS '@BetType'
									, t.IsLive AS '@IsLive'
									, t.MaxPT AS '@MaxPT'
									, t.MinPT AS '@MinPT'
									, t.SettingLevel as '@SettingLevel'
									, ProductID AS '@ProductID'
								FROM #tmpPT t
									INNER JOIN @tmpSetting s ON t.GroupID = s.GroupID
																AND t.SubGroupID = s.SubGroupID
								WHERE t.MaxPT < s.PT
									OR t.MinPT > s.PT
								FOR XML PATH('Row')
									, TYPE
								)
						FOR XML PATH('Root')
							, TYPE
						)
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 62
			SET @ErrCode = 102			
		END	
	END	
	
	DROP TABLE #tmpPT
	DROP TABLE #SportBettypeFilter
END	