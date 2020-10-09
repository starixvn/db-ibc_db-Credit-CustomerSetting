/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_WinningShareCommissionSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingStatus TINYINT = 0
AS
/*
	Created: 20170424@Elodie
	Task : Get Winning Share commission values of a product
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20170424@Elodie: Get Winning Share commission values of a product [Redmine: #75221]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	Param's Explanation:
	
	Example: EXEC Acc_CustSetting_WinningShareCommissionSelect @CustID = 1176070, @ProductID = 26
	*/
BEGIN
	DECLARE	@RoleID			TINYINT,
			@SuperID		INT,
			@MasterID		INT,
			@AgentID		INT,
			@VName1			VARCHAR(50),
			@VName2			VARCHAR(50)		

	DECLARE @WinningShare TABLE (sporttype SMALLINT, bettype SMALLINT, NumberValue1 DECIMAL(19,8), NumberValue2 DECIMAL(19,8))
	SELECT SportType,Bettype,SettingType
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,15,@SettingStatus) --Commission

	-- Select customer's information
	SELECT	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID

	IF @RoleID = 4
		IF EXISTS (SELECT 1 FROM dbo.CustDirectAccount WITH (NOLOCK) WHERE CustID = @CustID) --direct supper
			SELECT @VName1 = 'WinningShareSuper', @VName2 = 'WinningShareMaster'
		ELSE
		BEGIN --dummy supper
			SELECT @VName1 = 'WinningShareSuper_DirectMaster', @VName2 = 'WinningShareMaster_DirectMaster'
		END
	ELSE IF @RoleID = 3
		IF EXISTS (SELECT 1 FROM dbo.CustDirectAccount WITH (NOLOCK) WHERE CustID = @CustID) --direct master
			SELECT @VName1 = 'WinningShareMaster_DirectMaster', @VName2 = 'WinningShareAgent_DirectMaster'
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.CustDirectAccount da WITH (NOLOCK) WHERE CustID = @SuperID) --normal master
				SELECT @VName1 = 'WinningShareMaster', @VName2 = 'WinningShareAgent'
			ELSE -- dummy master
				SELECT @VName1 = 'WinningShareMaster_DirectAgent', @VName2 = 'WinningShareAgent_DirectAgent'
		END
	ELSE IF @RoleID = 2
		IF EXISTS (SELECT 1 FROM dbo.CustDirectAccount WITH (NOLOCK) WHERE CustID = @CustID) --direct agent
			SELECT @VName1 = 'WinningShareAgent_DirectAgent', @VName2 = ''
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.CustDirectAccount da WITH (NOLOCK) WHERE CustID = @SuperID OR CustID = @MasterID) --normal agent
				SELECT @VName1 = 'WinningShareAgent', @VName2 = ''
			ELSE -- dummy agent
				SELECT @VName1 = 'WinningShareAgent_DirectMember', @VName2 = ''
		END 

	IF @RoleID IN (4,3)
		INSERT INTO @WinningShare (sporttype, bettype, NumberValue1, NumberValue2)
		SELECT gs1.sporttype, gs1.bettype, gs1.NumberValue AS NumberValue1, gs2.NumberValue AS NumberValue2		
		FROM dbo.VendorGlobalSetting gs1 WITH (NOLOCK) 
			INNER JOIN dbo.VendorGlobalSetting gs2 WITH (NOLOCK) ON gs2.sporttype = gs1.sporttype AND gs2.bettype = gs1.bettype
			INNER JOIN #SportBettypeFilter ft ON gs1.sporttype = ft.sporttype AND gs1.bettype = ft.bettype
		WHERE gs1.VName = @VName1 AND gs2.VName = @VName2
	ELSE IF @RoleID = 2
		INSERT INTO @WinningShare (sporttype, bettype, NumberValue1, NumberValue2)
		SELECT gs1.sporttype, gs1.bettype, gs1.NumberValue AS NumberValue1, 0 AS NumberValue2
		FROM dbo.VendorGlobalSetting gs1 WITH (NOLOCK) 
			INNER JOIN #SportBettypeFilter ft ON gs1.sporttype = ft.sporttype AND gs1.bettype = ft.bettype
		WHERE gs1.VName = @VName1

	SELECT sporttype, bettype, NumberValue1 - NumberValue2 AS WinningShareCommission
	FROM @WinningShare

	DROP TABLE #SportBettypeFilter
END
GO