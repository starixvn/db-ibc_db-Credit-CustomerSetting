/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_Discount_156_Select]
	  @CustID		INT
	, @UplineRoleID	TINYINT	 = NULL
	, @GroupID		TINYINT	 = 3
	, @GroupType	TINYINT	 = 156 
	, @SettingStatus  TINYINT	 = 0
AS
/*
	Created: 20240219@Helios
	Task : Get Discount setting values of a product
	DB: DBCUST/CustDB
	Original: Acc_CustSetting_DiscountSelect

	Revision:
		- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960]

	Param's Explanation:
		- @SettingStatus: 0: Pro, 1: UAT
	
	*/
BEGIN
	DECLARE	@RoleID		TINYINT,
			@SuperID		INT,
			@MasterID		INT,
			@AgentID		INT,
			@Currency		TINYINT,
			@SiteID		INT

	CREATE TABLE #ProductSettingDetail_Sel(
		[SettingType]		[smallint],
		[SportType]			[smallint],
		[BetType]			[smallint],
		[IsLive]			[bit] ,
		[ProductID]			[tinyint],
		[IntervalValue]		[decimal](19,8),
		[MaxDiscount]		[decimal](9,8),
		[Child_DisplayOrder]	INT
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
		,	@siteid	= s.siteid
	FROM	dbo.Customer c WITH(NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site
	WHERE	c.custid = @CustID

	INSERT INTO #ProductSettingDetail_Sel(SportType,BetType,SettingType,IsLive,ProductID,IntervalValue,MaxDiscount,Child_DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,IntervalValue,MaxDiscount,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)

	-- Select customer's information
	SELECT	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID


	IF @RoleID = 4
	BEGIN
		SELECT	pdt.SportType,
				pdt.BetType,
				dc.Discount AS SuperDiscount,
				ISNULL(pdt.MaxDiscount, 0) AS DefaultMaxDiscount,
				pdt.IntervalValue AS IntervalComm
		FROM #ProductSettingDetail_Sel pdt WITH (NOLOCK)
			INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype 
		WHERE dc.custid = @CustID
		ORDER BY pdt.Child_DisplayOrder,pdt.SportType, pdt.BetType, pdt.IsLive 
	END
	ELSE IF @RoleID = 3
	BEGIN
		SELECT	pdt.SportType,  
				pdt.BetType,  
				dc.Discount AS MasterDiscount,
				sdc.Discount AS SuperDiscount,
				pdt.IntervalValue AS IntervalComm
		FROM #ProductSettingDetail_Sel pdt WITH (NOLOCK) 
			INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype    
			INNER JOIN dbo.CustDiscount3rd_Agent sdc WITH (NOLOCK) ON pdt.SportType = sdc.sporttype AND pdt.BetType = sdc.bettype 
		WHERE dc.custid = @CustID AND sdc.custid = @SuperID
		ORDER BY pdt.Child_DisplayOrder,pdt.SportType, pdt.BetType, pdt.IsLive 
	END
	ELSE IF @RoleID = 2
	BEGIN
		SELECT	pdt.SportType,  
				pdt.BetType,
				dc.Discount AS AgentDiscount,
				mdc.Discount AS MasterDiscount,
				pdt.IntervalValue AS IntervalComm
		FROM #ProductSettingDetail_Sel pdt WITH (NOLOCK)  
			INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype 
			INNER JOIN dbo.CustDiscount3rd_Agent mdc WITH (NOLOCK) ON pdt.SportType = mdc.sporttype AND pdt.BetType = mdc.bettype 
		WHERE dc.custid = @CustID AND mdc.custid = @MasterID 
		ORDER BY pdt.Child_DisplayOrder,pdt.SportType, pdt.BetType, pdt.IsLive 
	END
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
				FROM #ProductSettingDetail_Sel pdt WITH (NOLOCK)  
				INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype 
			WHERE dc.custid = @CustID
			ORDER BY pdt.Child_DisplayOrder,pdt.SportType, pdt.BetType, pdt.IsLive 
		END
		ELSE IF @UplineRoleID = 3
		BEGIN
			SELECT	pdt.SportType,  
					pdt.BetType,
					dc.PlayerDiscount, 
					dc.AgentDiscount,
					pdt.IntervalValue AS IntervalComm
			FROM #ProductSettingDetail_Sel pdt WITH (NOLOCK)  
				INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype 
			WHERE dc.custid = @CustID
			ORDER BY pdt.Child_DisplayOrder,pdt.SportType, pdt.BetType, pdt.IsLive 
		END
		ELSE IF @UplineRoleID = 2
		BEGIN
			SELECT	pdt.SportType,  
					pdt.BetType,
					dc.PlayerDiscount, 
					adc.Discount AS AgentDiscount,
					pdt.IntervalValue AS IntervalComm
			FROM #ProductSettingDetail_Sel pdt WITH (NOLOCK)  
				INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype   
				INNER JOIN dbo.CustDiscount3rd_Agent adc WITH (NOLOCK) ON pdt.SportType = adc.sporttype AND pdt.BetType = adc.bettype 
			WHERE dc.custid = @CustID AND adc.custid = @AgentID  
			ORDER BY pdt.Child_DisplayOrder,pdt.SportType, pdt.BetType, pdt.IsLive 
		END
	END
	
	DROP TABLE #ProductSettingDetail_Sel

END