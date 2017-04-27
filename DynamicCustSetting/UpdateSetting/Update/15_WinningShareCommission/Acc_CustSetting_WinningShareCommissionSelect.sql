/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_WinningShareCommissionSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
AS
/*
	Created: 20170424@Elodie
	Task : Get Winning Share commission values of a product
	DB: DBCUST/CustDB
	Original:

	Revision:
	
	Param's Explanation:
	
	Example: EXEC Acc_CustSetting_WinningShareCommissionSelect_xtest @CustID = 1176070, @ProductID = 26
	*/
BEGIN
	DECLARE	@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT,
			@Case		VARCHAR(50)

	SELECT SportType,Bettype,SettingType
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,15) --Commission

	-- Select customer's information
	SELECT	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID

	IF @RoleID = 4
		IF EXISTS (SELECT 1 FROM dbo.CustDirectAccount WITH (NOLOCK) WHERE CustID = @CustID)
			SELECT @Case = 'WinningShareSuper'
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 
						FROM dbo.CustDirectAccount da WITH (NOLOCK) 
							INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.mrecommend = da.CustID)
			SELECT @Case = 'WinningShareSuper_DirectMaster'
		END
	ELSE IF @RoleID = 3
		IF EXISTS (SELECT 1 FROM dbo.CustDirectAccount WITH (NOLOCK) WHERE CustID = @CustID)
			SELECT @Case = 'WinningShareMaster'
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 
						FROM dbo.CustDirectAccount da WITH (NOLOCK) 
							INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.mrecommend = da.CustID)
			SELECT @Case = 'WinningShareMaster'
		END
	ELSE IF @RoleID = 2
		IF EXISTS (SELECT 1 FROM dbo.CustDirectAccount WITH (NOLOCK) WHERE CustID = @CustID)
			SELECT @Case = 'WinningShareAgent'
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 
						FROM dbo.CustDirectAccount da WITH (NOLOCK) 
							INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.mrecommend = da.CustID)
			SELECT @Case = 'WinningShareAgent'
		END 

	ELSE IF @RoleID = 1
	BEGIN
		SELECT @Case = ''
	END

	SELECT sporttype, bettype, NumberValue AS WinningShareCommission 
	FROM dbo.VendorGlobalSetting WITH (NOLOCK) 
	WHERE VName = @Case

	DROP TABLE #SportBettypeFilter
END

