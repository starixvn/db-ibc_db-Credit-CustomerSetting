/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_TicketCommissionSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @UplineRoleID TINYINT = NULL
	, @SettingStatus TINYINT = 0
AS
/*
	Created: 20170424@Elodie
	Task : Get Ticket commission setting values of a product
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	
	Param's Explanation:
		- @SettingStatus: 0: Pro, 1: UAT
	
	*/
BEGIN
	DECLARE	@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT

	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT, SettingType SMALLINT)

	INSERT INTO #SportBettypeFilter(SportType,Bettype,SettingType)
	SELECT SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,14,@SettingStatus) --Commission

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit],
		[MaxDiscount] decimal(9,8),
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,MaxDiscount)
	SELECT SportType,BetType,SettingType,IsLive,MaxDiscount
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)
	
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
				dc.Discount AS SuperCommission,
				ISNULL(pdt.MaxDiscount, 0) AS MaxGivenCommission
		FROM #ProductSettingDetail pdt WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.SettingType = ft.SettingType
			INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK) ON pdt.SportType = dc.sporttype AND pdt.BetType = dc.bettype 
		WHERE dc.custid = @CustID
	ELSE IF @RoleID = 3
		SELECT	ft.SportType,  
				ft.BetType,  
				dc.Discount AS MasterCommission,
				sdc.Discount AS SuperCommission
		FROM #SportBettypeFilter ft  
			INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK) ON ft.SportType = dc.sporttype AND ft.BetType = dc.bettype    
			INNER JOIN dbo.CustDiscount3rd_Agent sdc WITH (NOLOCK) ON ft.SportType = sdc.sporttype AND ft.BetType = sdc.bettype 
		WHERE dc.custid = @CustID AND sdc.custid = @SuperID
	ELSE IF @RoleID = 2
		SELECT	ft.SportType,  
				ft.BetType,
				dc.Discount AS AgentCommission,
				mdc.Discount AS MasterCommission
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK) ON ft.SportType = dc.sporttype AND ft.BetType = dc.bettype 
			INNER JOIN dbo.CustDiscount3rd_Agent mdc WITH (NOLOCK) ON ft.SportType = mdc.sporttype AND ft.BetType = mdc.bettype 
		WHERE dc.custid = @CustID AND mdc.custid = @MasterID   
	ELSE IF @RoleID = 1
	BEGIN
		IF @UplineRoleID = 4
		BEGIN
			SELECT	ft.SportType,  
					ft.BetType,  
					dc.AgentDiscount AS AgentCommission,  
					dc.MasterDiscount AS MasterCommission
				FROM #SportBettypeFilter ft 
				INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK) ON ft.SportType = dc.sporttype AND ft.BetType = dc.bettype 
			WHERE dc.custid = @CustID
		END
		ELSE IF @UplineRoleID = 3
		BEGIN
			SELECT	ft.SportType,  
					ft.BetType,
					dc.AgentDiscount AS AgentCommission
			FROM #SportBettypeFilter ft 
				INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK) ON ft.SportType = dc.sporttype AND ft.BetType = dc.bettype 
			WHERE dc.custid = @CustID
		END
		ELSE IF @UplineRoleID = 2
		BEGIN
			SELECT	ft.SportType,  
					ft.BetType,
					dc.PlayerDiscount AS MemberCommission, 
					adc.Discount AS AgentCommission
			FROM #SportBettypeFilter ft 
				INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK) ON ft.SportType = dc.sporttype AND ft.BetType = dc.bettype   
				INNER JOIN dbo.CustDiscount3rd_Agent adc WITH (NOLOCK) ON ft.SportType = adc.sporttype AND ft.BetType = adc.bettype 
			WHERE dc.custid = @CustID AND adc.custid = @AgentID  
			  
		END
	END
	DROP TABLE #SportBettypeFilter
	DROP TABLE #ProductSettingDetail
END



