SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  
ALTER PROCEDURE [dbo].[Acc_CustSetting_MemberSettingSelect]   
	   @CustID		INT  
	 , @ProductID	TINYINT  
	 , @RoleID		INT  
	 , @SettingType	SMALLINT
	 , @DisableAutoMPT BIT = 0 OUTPUT
AS  
/*  
 Created: 20141104@Dominic  
 Task : Get all Member'setting values of a product  
 DB:  DBCUST/CustDB  
 Original:  
 
 Revision:
	- 20160104@Dominic: Implementing Charge Commission Plugin Redmine #49689
  
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
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType)
	
	SELECT @SuperID=ci.srecommend, @MasterID=ci.mrecommend , @AgentID = ci.recommend  
	FROM dbo.custInfo ci WITH(NOLOCK)  
	WHERE ci.custid=@CustID 
	
	IF @SettingType = 1
	BEGIN
		DECLARE @MemberPT TABLE (  
		SportType  SMALLINT  
		, BetType  SMALLINT  
		, IsLive  BIT  
		, S1   TINYINT  
		, M1   TINYINT  
		, A1   TINYINT  
		, IS1   BIT  
		, US1   TINYINT  
		, IM1   BIT  
		, UM1   TINYINT  
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
	END
	ELSE IF @SettingType = 2
	BEGIN
		DECLARE @Currency TINYINT  

		SELECT @Currency = Currency  
		FROM dbo.Customer c  
		WHERE c.custID = @CustID 
	END
	
	IF @RoleID = 4  
	BEGIN  
		IF @SettingType = 1
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
		--Bet Limit Setting  
		ELSE IF @SettingType = 2
		BEGIN
			SELECT pdt.SportType  
				, pdt.BetType  
				, bl.MinBet  
				, bl.MaxBet  
				, bl.MaxPerMatch  
			FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
			INNER JOIN dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)  
				ON pdt.SportType = bl.sporttype  
				AND pdt.BetType = bl.bettype  
				AND bl.custid = @CustID  
		END  
		--Discount Setting  / Charge Comm
		ELSE IF @SettingType IN (3,5)
		BEGIN
			SELECT pdt.SportType  
				, pdt.BetType  
				, dc.PlayerDiscount AS PlayerDiscount  
				, dc.AgentDiscount  
				, dc.MasterDiscount  
			FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
			INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK)  
				ON pdt.SportType = dc.sporttype  
				AND pdt.BetType = dc.bettype  
				AND dc.custid = @CustID  
		END
		--Product Status  
		ELSE IF @SettingType = 4
		BEGIN
			SELECT 	pdt.SportType
				, pdt.BetType
				, dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) as IsSync
				, dbo.f_GetProductStatus(stt.bitmapIsHidden, PSP.bitmapOrder) as isHidden
				, dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) as isDisabled
				 , dbo.f_GetProductStatus(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder) as IsDisabledUpline
			FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
				INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype
													AND pdt.BetType = ft.bettype
													AND pdt.IsLive = ft.islive
													AND pdt.SettingType = ft.SettingType
				INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType															
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
				INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @AgentID
				
			WHERE pdt.SettingType = @SettingType
		END
	END  
	ELSE IF @RoleID = 3  
	BEGIN  
		IF @SettingType = 1
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
		--Bet Limit Setting  
		ELSE IF @SettingType = 2
		BEGIN
			SELECT pdt.SportType  
				, pdt.BetType  
				, bl.MinBet  
				, bl.MaxBet  
				, bl.MaxPerMatch  
			FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
			INNER JOIN dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)  
				ON pdt.SportType = bl.sporttype  
				AND pdt.BetType = bl.bettype  
				AND bl.custid = @CustID  
		END
		--Discount Setting / Charge Comm 
		ELSE IF @SettingType IN (3,5)
		BEGIN
			SELECT pdt.SportType  
			, pdt.BetType  
			, dc.PlayerDiscount AS PlayerDiscount  
			, dc.AgentDiscount  
			FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
			INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK)  
			ON pdt.SportType = dc.sporttype  
			AND pdt.BetType = dc.bettype  
			AND dc.custid = @CustID  
		END
		--Product Status  
		ELSE IF @SettingType = 4
		BEGIN
			SELECT 	pdt.SportType
				, pdt.BetType
				, dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) as IsSync
				, dbo.f_GetProductStatus(stt.bitmapIsHidden, PSP.bitmapOrder) as isHidden
				, dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) as isDisabled
				 , dbo.f_GetProductStatus(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder) as IsDisabledUpline
			FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
				INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype
													AND pdt.BetType = ft.bettype
													AND pdt.IsLive = ft.islive
													AND pdt.SettingType = ft.SettingType
				INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType															
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
				INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @AgentID
				
			WHERE pdt.SettingType = @SettingType
				
		END
	END  
	ELSE IF @RoleID = 2  
	BEGIN  
		--PT Setting 
		IF @SettingType = 1
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
		--Bet Limit Setting  
		ELSE IF @SettingType = 2
		BEGIN
			SELECT pdt.SportType  
				, pdt.BetType  
				, bl.MinBet  
				, bl.MaxBet  
				, bl.MaxPerMatch  
				, CASE   
				WHEN sbl.minbet >= mbl.minbet  
				AND sbl.minbet >= abl.minbet  
				AND sbl.minbet >= pbs.MinBet  
				THEN sbl.minbet  
				WHEN mbl.minbet >= sbl.minbet  
				AND mbl.minbet >= abl.minbet  
				AND mbl.minbet >= pbs.MinBet  
				THEN mbl.minbet  
				WHEN abl.minbet >= sbl.minbet  
				AND abl.minbet >= mbl.minbet  
				AND abl.minbet >= pbs.MinBet  
				THEN abl.minbet  
				WHEN pbs.MinBet >= sbl.minbet  
				AND pbs.MinBet >= mbl.minbet  
				AND pbs.MinBet >= abl.minbet  
				THEN pbs.MinBet  
				END AS MinBetMin  
				, CASE   
				WHEN ((sbl.maxbet <= mbl.maxbet OR mbl.maxbet=0)  
				AND (sbl.maxbet <= abl.maxbet OR abl.maxbet=0)) AND sbl.maxbet <> 0  
				THEN sbl.maxbet  
				WHEN ((mbl.maxbet <= sbl.maxbet OR sbl.maxbet=0)  
				AND (mbl.maxbet <= abl.maxbet OR abl.maxbet=0)) AND mbl.maxbet <> 0  
				THEN mbl.maxbet  
				ELSE abl.maxbet  
				END AS MaxBetMax  
				, CASE   
				WHEN ((sbl.maxpermatch <= mbl.maxpermatch OR mbl.maxpermatch=0)  
				AND (sbl.maxpermatch <= abl.maxpermatch OR abl.maxpermatch=0)) AND sbl.maxpermatch <> 0  
				THEN sbl.maxpermatch  
				WHEN ((mbl.maxpermatch <= sbl.maxpermatch OR sbl.maxpermatch=0)  
				AND (mbl.maxpermatch <= abl.maxpermatch OR abl.maxpermatch=0)) AND mbl.maxpermatch <> 0  
				THEN mbl.maxpermatch  
				ELSE abl.maxpermatch  
				END AS MaxPerMatchMax  
			FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
			INNER JOIN dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)  
				ON pdt.SportType = bl.sporttype  
				AND pdt.BetType = bl.bettype  
				AND bl.custid = @CustID  
			INNER JOIN dbo.ProductBetSetting pbs  
				ON pbs.SportType = bl.sporttype  
				AND pbs.BetType = bl.bettype  
				AND pbs.Currency = @Currency  
			INNER JOIN dbo.CustBetSetting3rd_Agent abl WITH (NOLOCK)  
				ON pdt.SportType = abl.sporttype  
				AND pdt.BetType = abl.bettype  
				AND abl.custid = @AgentID  
			INNER JOIN dbo.CustBetSetting3rd_Agent mbl WITH (NOLOCK)  
				ON pdt.SportType = mbl.sporttype  
				AND pdt.BetType = mbl.bettype  
				AND mbl.custid = @MasterID  
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK)  
				ON pdt.SportType = sbl.sporttype  
				AND pdt.BetType = sbl.bettype  
				AND sbl.custid = @SuperID  
		END  
		--Discount Setting  / Charge Comm
		ELSE IF @SettingType IN (3,5)
		BEGIN
			SELECT pdt.SportType  
			, pdt.BetType  
			, dc.PlayerDiscount AS PlayerDiscount  
			, adc.Discount AS AgentDiscount  
			FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
			INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK)  
			ON pdt.SportType = dc.sporttype  
			AND pdt.BetType = dc.bettype  
			AND dc.custid = @CustID  
			INNER JOIN dbo.CustDiscount3rd_Agent adc WITH (NOLOCK)  
			ON pdt.SportType = adc.sporttype  
			AND pdt.BetType = adc.bettype  
			AND adc.custid = @AgentID  
		END  
		--Product Status  
		ELSE IF @SettingType = 4
		BEGIN
			SELECT 	pdt.SportType
				, pdt.BetType
				, dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) as IsSync
				, dbo.f_GetProductStatus(stt.bitmapIsHidden, PSP.bitmapOrder) as isHidden
				, dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) as isDisabled
				, CAST(0 AS BIT) AS IsDisabledDownline
				, dbo.f_GetProductStatus(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder) as IsDisabledUpline
				 
			FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
				INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype
													AND pdt.BetType = ft.bettype
													AND pdt.IsLive = ft.islive
													AND pdt.SettingType = ft.SettingType
				INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType															
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
				INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @AgentID
				
			WHERE pdt.SettingType = @SettingType
		END
	END  
	
	DROP TABLE #SportBettypeFilter
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MemberSettingSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MemberSettingSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MemberSettingSelect] TO [bodbExtAccNet]