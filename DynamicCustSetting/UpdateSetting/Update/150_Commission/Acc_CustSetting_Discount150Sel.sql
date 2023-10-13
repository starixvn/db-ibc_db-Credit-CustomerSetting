/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_Discount150Sel]     

	@CustId			INT		
,	@GroupID			TINYINT	= 1
,	@GroupType			TINYINT	= 150
,	@SettingStatus		TINYINT	= 0
,	@UplineRoleID		TINYINT	= NULL
AS

/*
	Created: 
	Task : Get Discount setting values of a SportsBook
	DB: DBCUST/CustDB
	Original: Acc_CustSetting_DiscountSelect

	Revisions:
		- 20231019@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]

	Param's Explanation:
		- @GroupType:	150 - Discount
		- @SettingStatus: 0: Pro, 3: UAT 
	
	-- Get SMA
	EXEC  [dbo].[Acc_CustSetting_Discount150Sel_UAT2]
	    @CustId = 102596104,
	    @GroupID  = 1 ,
	    @GroupType   = 150  ,
	    @SettingStatus = 3 ,
	    @UplineRoleID = NULL

	-- Get Member
	EXEC  [dbo].[Acc_CustSetting_Discount150Sel_UAT2]
	    @CustId = 102596107,
	    @GroupID  = 1 ,
	    @GroupType   = 150  ,
	    @SettingStatus = 3 ,
	    @UplineRoleID = 4
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE	
			@CurrencyID		INT,
			@SiteID		INT,
			@RoleID		TINYINT,
			@srecommend		INT,
			@mrecommend		INT,
			@recommend		INT


	CREATE TABLE #ProductSettingProfile(
		ProductID		TINYINT,	
		SportType		SMALLINT,
		BetType		SMALLINT,
		MaxDiscount		DECIMAL(19,8),
		IntervalValue	DECIMAL(19,8),
		SubType		TINYINT,
		Child_DisplayOrder TINYINT
	)

	----------------------------------------------------------------


	-- Select customer's information
	SELECT	
			@RoleID		= c.roleid,
			@srecommend		= c.srecommend,
			@mrecommend		= c.mrecommend,
			@recommend		= c.recommend,
			@siteid		= s.siteid,
			@CurrencyID		= c.currency
	FROM	Customer c WITH (NOLOCK)
			INNER JOIN Site s WITH (NOLOCK) ON s.site = c.site
	WHERE	c.custID = @CustID 

	-- Collect Product Setting Profile
	INSERT INTO #ProductSettingProfile 	(ProductID , SportType , BetType , MaxDiscount , IntervalValue , SubType , Child_DisplayOrder )
	SELECT ProductID , SportType , Bettype , MaxDiscount , IntervalValue  , SubType , Child_DisplayOrder 
	FROM f_CustSetting_ProductProfileSelByGroupType (@GroupType, @SettingStatus , @SiteID , @CurrencyID)
	WHERE GroupID = @GroupID 


	IF @RoleID = 4
		BEGIN
			SELECT 
				cda.SportType 
			,	cda.BetType
			,	cda.Discount			AS SuperDiscount
			,	ISNULL(psp.MaxDiscount, 0)	AS DefaultMaxDiscount
			,	psp.IntervalValue			AS IntervalComm
			FROM #ProductSettingProfile psp
			INNER JOIN CustDiscount3rd_Agent cda WITH (NOLOCK) ON psp.SportType = cda.SportType AND psp.BetType = cda.BetType
			WHERE cda.CustID = @CustID
			ORDER BY psp.Child_DisplayOrder , cda.SportType , cda.BetType 
		END
	ELSE IF @RoleID = 3
		BEGIN
			SELECT 
				cda.SportType 
			,	cda.BetType
			,	cdas.Discount	AS MasterDiscount
			,	cda.Discount	AS SuperDiscount
			,	psp.IntervalValue AS IntervalComm
			FROM #ProductSettingProfile psp
			INNER JOIN CustDiscount3rd_Agent cda WITH (NOLOCK) ON psp.SportType = cda.SportType AND psp.BetType = cda.BetType
			INNER JOIN CustDiscount3rd_Agent cdas WITH (NOLOCK) ON psp.SportType = cdas.SportType AND psp.BetType = cdas.BetType
			WHERE cda.CustID = @CustID AND cdas.CustID = @srecommend
			ORDER BY psp.Child_DisplayOrder , cda.SportType , cda.BetType 
		END	
	ELSE IF @RoleID = 2
		BEGIN
			SELECT 
				cda.SportType 
			,	cda.BetType
			,	cdam.Discount			AS AgentDiscount
			,	cda.Discount			AS MasterDiscount
			,	psp.IntervalValue			AS IntervalComm
			FROM #ProductSettingProfile psp
			INNER JOIN CustDiscount3rd_Agent cda WITH (NOLOCK) ON psp.SportType = cda.SportType AND psp.BetType = cda.BetType
			INNER JOIN CustDiscount3rd_Agent cdam WITH (NOLOCK) ON psp.SportType = cdam.SportType AND psp.BetType = cdam.BetType
			WHERE cda.CustID = @CustID AND cdam.CustID = @mrecommend
			ORDER BY psp.Child_DisplayOrder , cda.SportType , cda.BetType 
		END
	ELSE IF @RoleID = 1
		BEGIN
			IF @UplineRoleID = 4
			BEGIN
				SELECT	psp.SportType,  
						psp.BetType,  
						dc.PlayerDiscount,  
						dc.AgentDiscount,  
						dc.MasterDiscount,
						psp.IntervalValue AS IntervalComm
				FROM #ProductSettingProfile psp WITH (NOLOCK)  
				INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK) ON psp.SportType = dc.sporttype AND psp.BetType = dc.bettype 
				WHERE dc.custid = @CustID
				ORDER BY psp.Child_DisplayOrder , psp.SportType , psp.BetType  
			END
			ELSE IF @UplineRoleID = 3
			BEGIN
				SELECT	psp.SportType,  
						psp.BetType,
						dc.PlayerDiscount, 
						dc.AgentDiscount,
						psp.IntervalValue AS IntervalComm
				FROM #ProductSettingProfile psp WITH (NOLOCK)  
					INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK) ON psp.SportType = dc.sporttype AND psp.BetType = dc.bettype 
				WHERE dc.custid = @CustID
				ORDER BY psp.Child_DisplayOrder , psp.SportType , psp.BetType
			END
			ELSE IF @UplineRoleID = 2
			BEGIN
				SELECT	psp.SportType,  
						psp.BetType,
						dc.PlayerDiscount, 
						dc.AgentDiscount AS AgentDiscount,
						psp.IntervalValue AS IntervalComm
				FROM #ProductSettingProfile psp WITH (NOLOCK)  
					INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK) ON psp.SportType = dc.sporttype AND psp.BetType = dc.bettype   
					INNER JOIN dbo.CustDiscount3rd_Agent adc WITH (NOLOCK) ON psp.SportType = adc.sporttype AND psp.BetType = adc.bettype 
				WHERE dc.custid = @CustID AND adc.custid = @recommend  
				ORDER BY psp.Child_DisplayOrder , psp.SportType , psp.BetType 
			END

		END
	END
GO
