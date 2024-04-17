/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE Acc_CustSetting_MemberPT_153_Select
	   @CustID		INT  
	 , @GroupID TINYINT = 1
	 , @GroupType SMALLINT = 153
	 , @RoleID		INT  
	 , @DisableAutoMPT BIT = 0 OUTPUT
	 , @SettingStatus TINYINT = 0
AS  
/*  
	Created: 20231101@Eden
	Task : Get Member'PT values of a product
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20231101@Eden: DCS Sportsbook Credit[redmine: #193083]
		
	Param's Explanation:
		- @CustID: Super's ID
		- @SettingStatus: 0: Pro, 1: UAT

	Example:
		DECLARE @DisableAutoMPT BIT = 0
		EXEC Acc_CustSetting_MemberPT_153_Select
			@CustID = 102596320,
			@RoleID = 4,
			@GroupID = 1,
			@GroupType  = 153,
			@SettingStatus = 3,
			@DisableAutoMPT = @DisableAutoMPT OUT
		SELECT @DisableAutoMPT
 */  
BEGIN  
	IF @RoleID NOT IN (2, 3, 4)  
		RETURN  
  
	DECLARE @SuperID INT,
		@MasterID INT, 
		@AgentID INT,
		@SiteID SMALLINT,
		@Currency SMALLINT	
	
	SELECT  @siteID = s.siteID,
			@Currency = c.currency,
			@SuperID = c.srecommend,
			@MasterID = c.mrecommend,
		    @AgentID = c.recommend  
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid

	CREATE TABLE #ProductSettingDetail(
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[MaxPT]	[smallmoney],
		Child_DisplayOrder INT
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,IsLive,MaxPT,Child_DisplayOrder)
	SELECT SportType,BetType,IsLive,MaxPT,Child_DisplayOrder 
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)

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
							, Child_DisplayOrder INT
							)	 
		
	--Get member setting from Group OR Individual Settings   
	INSERT INTO @MemberPT  (SportType,BetType,IsLive,S1,M1,A1,IS1,US1,IM1,UM1,Child_DisplayOrder)
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
		,pdt.Child_DisplayOrder
	FROM #ProductSettingDetail pdt WITH (NOLOCK)  
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
		ORDER BY mb.Child_DisplayOrder,mb.SportType,mb.BetType,mb.IsLive
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
		ORDER BY mb.Child_DisplayOrder,mb.SportType,mb.BetType,mb.IsLive
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
		ORDER BY mb.Child_DisplayOrder,mb.SportType,mb.BetType,mb.IsLive
	END  
	
	DROP TABLE #ProductSettingDetail
END  
GO