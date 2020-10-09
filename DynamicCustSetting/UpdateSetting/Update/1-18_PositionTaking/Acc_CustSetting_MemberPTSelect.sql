/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE Acc_CustSetting_MemberPTSelect
	   @CustID		INT  
	 , @ProductID	TINYINT  
	 , @RoleID		INT  
	 , @DisableAutoMPT BIT = 0 OUTPUT
	 , @SettingStatus TINYINT = 0
AS  
/*  
	Created: 20200612@Elodie
	Task : Get all Member'PT values of a product  
	DB:  DBCUST/CustDB  
	Original:  
 
	Revision:
		- 20200612@Elodie: Initial SP for setting type 18 [Redmine: #135363]
		- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]

	Param's Explanation:  
		- @CustID: Member's ID  
		- @RoleID:  2-Agent select  
					3-Master select  
					4-Super select  
 */  
BEGIN  
	IF @RoleID NOT IN (2, 3, 4)  
		RETURN  
  
	DECLARE @SuperID INT, @MasterID INT, @AgentID INT  
	
	SELECT SportType,Bettype,IsLive, SettingType 
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,18,@SettingStatus)
	
	SELECT @SuperID=ci.srecommend, @MasterID=ci.mrecommend , @AgentID = ci.recommend  
	FROM dbo.custInfo ci WITH(NOLOCK)  
	WHERE ci.custid=@CustID 
	
	DECLARE @MemberPT TABLE (  
							SportType  SMALLINT  
							, BetType  SMALLINT  
							, IsLive  BIT  
							, S1   SMALLMONEY  
							, M1   SMALLMONEY  
							, A1   SMALLMONEY  
							, IS1   BIT  
							, US1   SMALLMONEY  
							, IM1   BIT  
							, UM1   SMALLMONEY  
							)	 
		
	--Get member setting from Group OR Individual Settings   
	INSERT INTO @MemberPT  
	SELECT pdt.SportType  
		, pdt.BetType  
		, pdt.IsLive  
		, CASE   
		WHEN mode.IsGrouped = 0  
		THEN pt.SuperPT  
		ELSE ptgr.SuperPT  
		END AS S1  
		, CASE   
		WHEN mode.IsGrouped = 0  
		THEN pt.MasterPT  
		ELSE ptgr.MasterPT  
		END AS M1  
		, CASE   
		WHEN mode.IsGrouped = 0  
		THEN pt.AgentPT  
		ELSE ptgr.AgentPT  
		END AS A1  
		, CASE   
		WHEN mode.IsGrouped = 0  
		THEN pt.IsAutoSuperPT  
		ELSE ptgr.IsAutoSuperPT  
		END AS IS1  
		, CASE   
		WHEN mode.IsGrouped = 0  
		THEN pt.AutoSuperPT  
		ELSE ptgr.AutoSuperPT  
		END AS US1  
		, CASE   
		WHEN mode.IsGrouped = 0  
		THEN pt.IsAutoMasterPT  
		ELSE ptgr.IsAutoMasterPT  
		END AS IM1  
		, CASE   
		WHEN mode.IsGrouped = 0  
		THEN pt.AutoMasterPT  
		ELSE ptgr.AutoMasterPT  
		END AS UM1  
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
		INNER JOIN #SportBettypeFilter ft 
			ON pdt.SportType = ft.sporttype
				AND pdt.BetType = ft.bettype
				AND pdt.IsLive = ft.islive
				AND pdt.SettingType = ft.SettingType
		INNER JOIN dbo.CustSettingMode3rd mode  
			ON mode.CustID = @CustID  
		LEFT JOIN dbo.CustPTSetting3rd_Member pt WITH (NOLOCK)  
			ON pdt.SportType = pt.sporttype  
			AND pdt.BetType = pt.bettype  
			AND pdt.IsLive = pt.islive  
			AND pt.custid = @CustID  
		LEFT JOIN CustPTGroupSetting3rd_Member ptgr WITH (NOLOCK)  
			ON pdt.SportType = ptgr.sporttype  
			AND pdt.BetType = ptgr.bettype  
			AND pdt.IsLive = ptgr.islive  
			AND ptgr.AgentID = @AgentID  
	
	IF @RoleID = 4  
	BEGIN  
		--PT SETTING  
		SELECT  
		mb.SportType  
		, mb.BetType  
		, mb.IsLive  
		, mb.A1  
		, mb.M1  
		, mb.S1  
		, mb.IS1  
		, mb.US1  
		, superpt.SuperPT AS S4  
		, superpt.MinPT AS N4  
		, masterpt.MasterPT AS M3  
		, masterpt.IsAutoSuperPT AS IS3
		FROM @MemberPT mb  
		INNER JOIN dbo.CustPTSetting3rd_Agent masterpt WITH (NOLOCK)  
		ON mb.SportType = masterpt.sporttype  
		AND mb.BetType = masterpt.bettype  
		AND mb.IsLive = masterpt.islive  
		AND masterpt.custid = @MasterID  
		INNER JOIN dbo.CustPTSetting3rd_Agent superpt WITH (NOLOCK)  
		ON mb.SportType = superpt.sporttype  
		AND mb.BetType = superpt.bettype  
		AND mb.IsLive = superpt.islive  
		AND superpt.custid = @SuperID 
	END 
	ELSE IF @RoleID = 3  
	BEGIN  
		--Disable auto master PT  
		SELECT @DisableAutoMPT = ISNULL(DisableAutoMPT, 0)
		FROM CustMaster WITH (NOLOCK)  
		WHERE CustID = @MasterID 
	
		--PT SETTING  
		SELECT  
			mb.SportType  
			, mb.BetType    
			, mb.IsLive  
			, mb.A1  
			, mb.M1  
			, mb.IM1  
			, mb.UM1  
			, masterpt.MasterPT AS M3  
			, masterpt.MinPT AS N3  
			, agentpt.IsAutoMasterPT AS IM2
		FROM @MemberPT mb  
		INNER JOIN dbo.CustPTSetting3rd_Agent masterpt WITH (NOLOCK)  
			ON mb.SportType = masterpt.sporttype  
			AND mb.BetType = masterpt.bettype  
			AND mb.IsLive = masterpt.islive  
			AND masterpt.custid = @MasterID  
		INNER JOIN dbo.CustPTSetting3rd_Agent agentpt WITH (NOLOCK)  
			ON mb.SportType = agentpt.sporttype  
			AND mb.BetType = agentpt.bettype  
			AND mb.IsLive = agentpt.islive  
			AND agentpt.custid = @AgentID 		
	END  
	ELSE IF @RoleID = 2  
	BEGIN  
		SELECT  
			mb.SportType  
			, mb.BetType  
			, mb.IsLive  
			, mb.A1  
			--, agentpt.AgentPT AS A2
			, CASE WHEN agentpt.AgentPT < CASE 
							WHEN (
									agentpt.IsAutoMasterPT = 1
									OR mb.IM1 = 1
									)
								THEN agentpt.AgentPT
							ELSE CASE 
									WHEN NOT (
											mb.IS1 = 0
											AND masterpt.IsAutoSuperPT = 0
											)
										THEN masterpt.MasterPT - mb.M1
									ELSE CASE 
											WHEN masterpt.MasterPT - mb.M1 <= superpt.SuperPT - mb.S1 - mb.M1
												THEN masterpt.MasterPT - mb.M1
											ELSE superpt.SuperPT - mb.S1 - mb.M1
											END
									END
							END
					THEN agentpt.AgentPT
					ELSE
						CASE 
							WHEN (
									agentpt.IsAutoMasterPT = 1
									OR mb.IM1 = 1
									)
								THEN agentpt.AgentPT
							ELSE CASE 
									WHEN NOT (
											mb.IS1 = 0
											AND masterpt.IsAutoSuperPT = 0
											)
										THEN masterpt.MasterPT - mb.M1
									ELSE CASE 
											WHEN masterpt.MasterPT - mb.M1 <= superpt.SuperPT - mb.S1 - mb.M1
												THEN masterpt.MasterPT - mb.M1
											ELSE superpt.SuperPT - mb.S1 - mb.M1
											END
									END
							END
					END AS A2	
			, agentpt.MinPT AS N2  
			, agentpt.IsAutoMasterPT AS IM2
		FROM @MemberPT mb  
		INNER JOIN dbo.CustPTSetting3rd_Agent agentpt WITH (NOLOCK)  
			ON mb.SportType = agentpt.sporttype  
			AND mb.BetType = agentpt.bettype  
			AND mb.IsLive = agentpt.islive  
			AND agentpt.custid = @AgentID
		INNER JOIN dbo.CustPTSetting3rd_Agent masterpt WITH (NOLOCK)  
			ON mb.SportType = masterpt.sporttype  
			AND mb.BetType = masterpt.bettype  
			AND mb.IsLive = masterpt.islive  
			AND masterpt.custid = @MasterID
		INNER JOIN dbo.CustPTSetting3rd_Agent superpt WITH (NOLOCK)  
			ON mb.SportType = superpt.sporttype  
			AND mb.BetType = superpt.bettype  
			AND mb.IsLive = superpt.islive  
			AND superpt.custid = @SuperID  
	END  
	
	DROP TABLE #SportBettypeFilter
END  
GO