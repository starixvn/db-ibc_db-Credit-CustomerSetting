/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].Acc_CustomerIns_CloneMemberSetting_Sel
	@siteid SMALLINT =0,
	@currency SMALLINT =0,
	@ExistingCustID INT = 0,
	@AgentID INT = 0,
	@SettingType25 VARCHAR(MAX)= '' OUTPUT,
	@SettingType26 VARCHAR(MAX)= '' OUTPUT,
	@SettingType27 VARCHAR(MAX)= '' OUTPUT,
	@SettingType28 VARCHAR(MAX)= '' OUTPUT,
	@SettingType30 VARCHAR(MAX)= '' OUTPUT,
	@SettingStatus TINYINT = 0
AS
/*
	Created: 20231010@Eden  
	Task : Get Sportsbook setting from SourceCust, use for search and copy member setting
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20231010@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20240619@Johnson: Scale out dbcust [redmine:#199915]
		- 20250512@Johnson: Add Potential Win Limit [redmine: #226060]
		- 20250731@Johnson: Include Parlay for Potential Win Limit [RedmineID: #233805]
	Examples:
		DECLARE @SettingType25 VARCHAR(MAX)= '',
				@SettingType26 VARCHAR(MAX)= '',
				@SettingType27 VARCHAR(MAX)= '',
				@SettingType28 VARCHAR(MAX)= ''
		EXEC Acc_CustomerIns_CloneMemberSetting_Sel
			 @siteid = 1
			,@currency = 20
			,@ExistingCustID = 1176092
			,@AgentID = 1176086
			,@SettingType25 = @SettingType25 OUT
			,@SettingType26 = @SettingType26 OUT
			,@SettingType27 = @SettingType27 OUT
			,@SettingType28 = @SettingType28 OUT
			,@SettingType30 = @SettingType30 OUT
			,@SettingStatus = 3

		SELECT CONVERT(XML,@SettingType25)
			,CONVERT(XML,@SettingType26)
			,CONVERT(XML,@SettingType27)
			,CONVERT(XML,@SettingType28)
			,CONVERT(XML,@SettingType30)
*/	
BEGIN
	SET NOCOUNT ON
	DECLARE @IsGrouped BIT = 0

	SELECT @IsGrouped = IsGrouped
	FROM dbo.CustSettingMode3rd
	WHERE CustID= @ExistingCustID

	DECLARE @ProductSettingDetail TABLE (
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		Child_DisplayOrder [int]
	)

	INSERT INTO @ProductSettingDetail(SportType,BetType,SettingType,IsLive,Child_DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)
	WHERE SettingType IN (25,26,27,28,30)

	SELECT @SettingType25 = CONVERT(VARCHAR(MAX),
				(
					SELECT dc.SportType
						, dc.BetType
						, dc.PlayerDiscount AS Discount
					FROM dbo.CustDiscount3rd_Member dc WITH(NOLOCK)
						INNER JOIN @ProductSettingDetail fil ON fil.SportType = dc.SportType AND fil.BetType = dc.BetType AND fil.SettingType = 25
					WHERE dc.CustID	= @ExistingCustID
					ORDER BY fil.Child_DisplayOrder
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType26 = CONVERT(VARCHAR(MAX),
				(
					SELECT bl.SportType
						, bl.BetType
						, bl.MinBet
						, bl.MaxBet
						, bl.MaxPerMatch AS MPM
						, bl.MaxPayoutPerMatch AS MaxPayout
					FROM dbo.BetSetting_Member bl WITH (NOLOCK)
						INNER JOIN @ProductSettingDetail fil ON fil.SportType = bl.SportType AND fil.BetType = bl.BetType AND fil.SettingType = 26	
					WHERE bl.custid = @ExistingCustID
					ORDER BY fil.Child_DisplayOrder
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType27 = CONVERT(VARCHAR(MAX),
				(
					SELECT cs.SportType, 
						cs.BetType, 
						CASE WHEN cs.SingleMatchParlay > upl.SingleMatchParlay  AND upl.SingleMatchParlay > 0 THEN upl.SingleMatchParlay ELSE cs.SingleMatchParlay END AS SingleMP,
						CASE WHEN cs.Combo2 > upl.Combo2  AND upl.Combo2 > 0 THEN upl.Combo2 ELSE cs.Combo2 END AS Combo2,
						CASE WHEN cs.Combo35 > upl.Combo35  AND upl.Combo35 > 0 THEN upl.Combo35 ELSE cs.Combo35 END AS Combo35,
						CASE WHEN cs.ComboOver6 > upl.ComboOver6  AND upl.ComboOver6 > 0 THEN upl.ComboOver6 ELSE cs.ComboOver6 END AS Combo6
					FROM dbo.CustMaxPayoutSetting_Member cs WITH (NOLOCK)
						INNER JOIN dbo.CustMaxPayoutSetting_Agent upl WITH (NOLOCK) ON cs.SportType = upl.SportType AND cs.BetType = upl.BetType
						INNER JOIN @ProductSettingDetail fil ON fil.SportType = cs.SportType AND fil.BetType = cs.BetType AND fil.SettingType = 27		
					WHERE cs.CustID  = @ExistingCustID  AND Upl.CustID = @AgentID
					ORDER BY fil.Child_DisplayOrder
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	IF @IsGrouped = 0
	BEGIN	
		SELECT @SettingType28 = CONVERT(VARCHAR(MAX),
				(
					SELECT mcs.SportType
						, mcs.BetType
						, mcs.IsLive
						, CASE WHEN mcs.agentPT > acs.agentPT THEN acs.agentPT ELSE mcs.agentPT END AS AgentPT
					FROM dbo.CustPTSetting3rd_Member mcs WITH (NOLOCK)
						INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND acs.islive = mcs.islive
						INNER JOIN @ProductSettingDetail fil ON fil.SportType = mcs.SportType AND fil.BetType = mcs.BetType AND fil.IsLive = mcs.IsLive AND fil.SettingType = 28	
					WHERE mcs.custid = @ExistingCustID AND acs.custid = @AgentID
					ORDER BY fil.Child_DisplayOrder
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)
	END
	ELSE
	BEGIN	
		SELECT @SettingType28 = CONVERT(VARCHAR(MAX),
				(
					SELECT mcs.SportType
						, mcs.BetType
						, mcs.IsLive
						, CASE WHEN mcs.agentPT > acs.agentPT THEN acs.agentPT ELSE mcs.agentPT END AS AgentPT
					FROM dbo.CustPTGroupSetting3rd_Member mcs WITH (NOLOCK)
						INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND acs.islive = mcs.islive
						INNER JOIN @ProductSettingDetail fil ON fil.SportType = mcs.SportType AND fil.BetType = mcs.BetType AND fil.IsLive = mcs.IsLive AND fil.SettingType = 28	
					WHERE mcs.AgentID = @AgentID AND acs.custid = @AgentID
					ORDER BY fil.Child_DisplayOrder
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)
	END

	SELECT @SettingType30 = CONVERT(VARCHAR(MAX),
				(
					SELECT cs.SportType
						, cs.BetType
						, cs.PotentialWinLimit as WinLimit
						, cs.IsAutoReset
						, dbo.f_CustPotentialWinLimit_GetOfferOption(cs.OfferOption, 1) AS IncludeParlay
					FROM dbo.CustPotentialWinLimit cs WITH(NOLOCK)
						INNER JOIN @ProductSettingDetail fil ON fil.SportType = cs.SportType AND fil.BetType = cs.BetType AND fil.SettingType = 30
					WHERE cs.CustID	= @ExistingCustID
					ORDER BY fil.Child_DisplayOrder
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)
END	
GO