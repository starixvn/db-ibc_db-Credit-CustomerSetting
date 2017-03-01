ALTER PROCEDURE [dbo].[Acc_CustSetting_DiscountSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @UplineRoleID	TINYINT = NULL
AS
/*
	Created: 20160801@Elodie
	Task : Get Discount setting values of a product
	DB: DBCUST/CustDB
	Original:

	Revision:
	
	Param's Explanation:
	
	*/
BEGIN
	DECLARE	@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT

	SELECT SportType,Bettype,SettingType
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,3) --Commission
	
	INSERT #SportBettypeFilter (SportType,Bettype,SettingType)
	SELECT SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,5) --Charge Commission

	-- Select customer's information
	SELECT	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID

	IF @RoleID = 4
		SELECT	pdt.SportType,
				pdt.BetType,
				dc.Discount AS SuperDiscount,
				ISNULL(pdt.MaxDiscount, 0) AS DefaultMaxDiscount,
				pdt.IntervalValue AS IntervalComm
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.SettingType = ft.SettingType
			INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype 
		WHERE dc.custid = @CustID
	ELSE IF @RoleID = 3
		SELECT	pdt.SportType,  
				pdt.BetType,  
				dc.Discount AS MasterDiscount,
				sdc.Discount AS SuperDiscount,
				pdt.IntervalValue AS IntervalComm
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter ft  ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.SettingType = ft.SettingType
			INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype    
			INNER JOIN dbo.CustDiscount3rd_Agent sdc WITH (NOLOCK) ON pdt.SportType = sdc.sporttype AND pdt.BetType = sdc.bettype 
		WHERE dc.custid = @CustID AND sdc.custid = @SuperID
	ELSE IF @RoleID = 2
		SELECT	pdt.SportType,  
				pdt.BetType,
				dc.Discount AS AgentDiscount,
				mdc.Discount AS MasterDiscount,
				pdt.IntervalValue AS IntervalComm
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.SettingType = ft.SettingType
			INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype 
			INNER JOIN dbo.CustDiscount3rd_Agent mdc WITH (NOLOCK) ON pdt.SportType = mdc.sporttype AND pdt.BetType = mdc.bettype 
		WHERE dc.custid = @CustID AND mdc.custid = @MasterID   
	ELSE IF @RoleID = 1
	BEGIN
		IF @UplineRoleID = 4
		BEGIN
			SELECT	pdt.SportType,  
					pdt.BetType,  
					dc.PlayerDiscount,  
					dc.AgentDiscount,  
					dc.MasterDiscount,
					pdt.IntervalValue AS IntervalComm
				FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
				INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.SettingType = ft.SettingType
				INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype 
			WHERE dc.custid = @CustID
		END
		ELSE IF @UplineRoleID = 3
		BEGIN
			SELECT	pdt.SportType,  
					pdt.BetType,
					dc.PlayerDiscount, 
					dc.AgentDiscount,
					pdt.IntervalValue AS IntervalComm
			FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
				INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.SettingType = ft.SettingType
				INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype 
			WHERE dc.custid = @CustID
		END
		ELSE IF @UplineRoleID = 2
		BEGIN
			SELECT	pdt.SportType,  
					pdt.BetType,
					dc.PlayerDiscount, 
					adc.Discount AS AgentDiscount,
					pdt.IntervalValue AS IntervalComm
			FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
				INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.SettingType = ft.SettingType
				INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype   
				INNER JOIN dbo.CustDiscount3rd_Agent adc WITH (NOLOCK) ON pdt.SportType = adc.sporttype AND pdt.BetType = adc.bettype 
			WHERE dc.custid = @CustID AND adc.custid = @AgentID  
			  
		END
	END
	DROP TABLE #SportBettypeFilter
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DiscountSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DiscountSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DiscountSelect] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_DiscountSelect] TO [vnteam]

