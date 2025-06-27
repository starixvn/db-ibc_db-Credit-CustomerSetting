/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_CustomerInfoSBSelect] 
	  @CustID		INT,
	  @SystemID		INT = 0
AS
/*
	Created: 20231019@Helios
	Task : Get User infor  for Product SportsBook
	DB: DBCUST/CustDB
	Original:
		Acc_CustomerSelCEditCustomer
		Acc_CustomerSelSEditCustomer
		Acc_CustomerSelMEditCustomer
		Acc_CustomerSelEditCustomer        

	Revisions:
		- 20231019@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083] 
		- 20240423@Elodie: Member Max Credit, Member Given Credit enhancements [Redmine: #203332]
		- 20241028@July: [Scale out DBCUST] Wrong Currency [Redmine: #212777]
		- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969]
		- 20250626@Dave: Add AccumCredit of AllCashMember to AgentUsedCredit [Redmine: #231524]

	Param's Explanation:
	
		EXEC Acc_CustSetting_CustomerInfoSBSelect_UAT2 104421190
	*/
BEGIN
	SET NOCOUNT ON

	DECLARE	
			-- Param Get Credit Role Super
			@Credit_SAg_Min			MONEY,

			-- Param Get Credit Role Master
			@Credit_MAg_Max			MONEY, 
			@Credit_MAg_Min			MONEY,
			@Credit_AllOtherMaster		MONEY,
			@Credit_SAg				MONEY,

			-- Param Get Credit Role Agent
			@Credit_AllOtherAgent		MONEY, 
			@Credit_AllMember			MONEY, 
			@Credit_MAg				MONEY,
			@Credit_Ag_Min			MONEY, 
			@Credit_Ag_Max			MONEY, 
			@MaxCredit_Mem_Min		MONEY, 
			@Mem_MaxCredit			MONEY,

			-- Param Get Credit Role Member
			@Credit_AllOtherMember		MONEY,
			@Credit_Ag				MONEY,
			@Credit_Ag_Bal			MONEY,
			--@Credit_Mem_Max			MONEY,
			@MaxCredit_Mem			MONEY,
			@Credit_AllOtherDirectMember	MONEY,
			@IsDirectMember			INT,

			-- Param get Cust Info
			@RoleID				INT,
			@Username				VARCHAR(50),
			@Username2				VARCHAR(50),
			@firstname				NVARCHAR(50),
			@lastname				NVARCHAR(50),
			@phone				NVARCHAR(50),
			@mobilephone			NVARCHAR(50),
			@email				NVARCHAR(50),
			@fax					NVARCHAR(50),
			@Currency				INT,
			@CurrencyName			NVARCHAR(50),
			@Site					VARCHAR(10),
			@SiteLabel				VARCHAR(50),
			@srecommend				INT,
			@mrecommend				INT,
			@recommend				INT,
			@uGroup				VARCHAR(3),
			@DisableAutoMPT			BIT = 0,
			@SpecialPlatfrom			TINYINT,
			@AccumCredit_AllCashMember	MONEY


	----------------------------------------------------------------
	SELECT  @RoleId = roleID
	FROM dbo.customer WITH (NOLOCK)   
	WHERE custid = @CustId 

	-- Select customer's information
	IF @SystemID IN (4,8) AND @RoleID = 4 -- Get Infor ExtNAP
	BEGIN
		SELECT	@Username		= c.username,
			@Username2		= c.username2,
			@firstname		= cs.firstname,
			@lastname		= cs.lastname,
			@phone			= cs.phone,
			@mobilephone	= cs.mobilephone,
			@email			= cs.email,
			@fax			= cs.fax,	
			@Currency		= c.currency,	
			@CurrencyName	= e.currency,
			@Site			= c.Site,
			@SiteLabel		= s.SiteLabel,
			@srecommend		= c.srecommend,
			@mrecommend		= c.mrecommend,
			@recommend		= c.recommend,
			@uGroup		= c.ugroup,
			@SpecialPlatfrom  = ISNULL(s.SpecialPlatfrom , 0)
		FROM	Customer c WITH (NOLOCK)
		INNER JOIN CustSuperProfile cs WITH (NOLOCK) ON c.custid = cs.Custid
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
		INNER JOIN exchange e WITH (NOLOCK) ON c.currency = e.ExchangeId
		WHERE	c.custID = @CustID 
	END
	ELSE
	BEGIN
		SELECT	@Username		= c.username,
			@Username2		= c.username2,
			@firstname		= c.firstname,
			@lastname		= c.lastname,
			@phone			= c.phone,
			@mobilephone	= c.mobilephone,
			@email			= c.email,
			@fax			= c.fax,	
			@Currency		= c.currency,	
			@CurrencyName	= e.currency,
			@Site			= c.Site,
			@SiteLabel		= s.SiteLabel,
			@srecommend		= c.srecommend,
			@mrecommend		= c.mrecommend,
			@recommend		= c.recommend,
			@uGroup		= c.ugroup,
			@SpecialPlatfrom  = ISNULL(s.SpecialPlatfrom , 0),
			@IsDirectMember	= CASE WHEN c.recommend IN (-3,-4) THEN c.recommend ELSE 0 END
		FROM	Customer c WITH (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
		INNER JOIN exchange e WITH (NOLOCK) ON c.currency = e.ExchangeId
		WHERE	c.custID = @CustID 
	END

	IF @RoleID = 4
	BEGIN
		SELECT @Credit_SAg_Min = MAX(c.credit)
		FROM
			(
				SELECT ISNULL(SUM(credit), 0) as credit FROM custinfo WITH (NOLOCK) WHERE srecommend = @CustID and ((RoleID=3) OR (RoleID=1 AND recommend = -4))
				UNION ALL
				SELECT ISNULL(SUM(credit), 0) as credit FROM custinfo WITH (NOLOCK) WHERE srecommend = @CustID and RoleID=1 AND recommend NOT IN (-3,-4)
				UNION ALL
				SELECT ISNULL(SUM(credit), 0) as credit FROM custinfo WITH (NOLOCK) WHERE srecommend = @CustID and RoleID=2
			) c

		SELECT        
			  @Username							AS UserName
			, @Username2						AS UserName2
			, @firstname						AS FirstName
			, @lastname							AS LastName
			, @phone							AS Phone
			, @mobilephone						AS MobilePhone
			, @email							AS Email
			, @fax							AS Fax
			, @Currency							AS Currency
			, @CurrencyName						AS CurrencyName
			, @Site							AS Site
			, @SiteLabel						AS SiteLabel
		
			-- Get Credit for SB
			, credit							AS MaxCredit
			-- Role Super
			, @Credit_SAg_Min						AS MaxCreditMin 
			, @RoleID							AS RoleID
			, @SpecialPlatfrom					AS SpecialPlatfrom
		FROM dbo.custInfo WITH (NOLOCK)
		WHERE custID = @CustID	
	END

	ELSE IF @RoleID = 3
	BEGIN
		SELECT @Credit_AllOtherMaster = ISNULL(SUM(credit), 0) FROM custinfo as ci WITH (NOLOCK) WHERE srecommend = @srecommend and custid <> @CustID AND ((RoleID = 3) OR (RoleID = 1 AND ci.recommend = -4))
		SELECT @Credit_SAg = ISNULL(credit, 0) FROM CustInfo as ci WITH (NOLOCK) WHERE CustID = @srecommend

		IF @srecommend <= 100
		BEGIN
			--Set unlimited for dummy super
			SELECT @Credit_MAg_Max = 10000000000
		END
		ELSE
		BEGIN
			SELECT @Credit_MAg_Max = @Credit_SAg - @Credit_AllOtherMaster
		END

		SELECT @Credit_MAg_Min = MAX(c.credit)
		FROM
			(
			SELECT ISNULL(SUM(credit), 0) AS credit	FROM custinfo WITH (NOLOCK) WHERE mrecommend = @CustID and RoleID=1 AND recommend NOT IN (-3,-4)
			UNION ALL
			SELECT ISNULL(SUM(credit), 0) AS credit	FROM custinfo WITH (NOLOCK) WHERE mrecommend = @CustID and ((RoleID=2) OR (RoleID=1 AND recommend = -3))
			) c

		SELECT        
			  @Username							AS UserName
			, @Username2						AS UserName2
			, @firstname						AS FirstName
			, @lastname							AS LastName
			, @phone							AS Phone
			, @mobilephone						AS MobilePhone
			, @email							AS Email
			, @fax							AS Fax
			, @Currency							AS Currency
			, @CurrencyName						AS CurrencyName
			, @Site							AS Site
			, @SiteLabel						AS SiteLabel
		
			-- Get Credit for SB
			, i.credit							AS MaxCredit

			-- Role Master
			, @Credit_MAg_Min						AS MaxCreditMin 
			, @Credit_MAg_Max						AS MaxCreditMax 
			, @RoleID							AS RoleID
			, @SpecialPlatfrom					AS SpecialPlatfrom
		FROM dbo.custInfo i WITH (NOLOCK)
		WHERE i.custID = @CustID	
	END

	ELSE IF @RoleID = 2
	BEGIN
		SELECT @Mem_MaxCredit = ISNULL(maxcredit,0) FROM CustAgent WITH (NOLOCK) 
		WHERE  custid=@CustID 

		SELECT @Credit_AllOtherAgent = ISNULL(SUM(credit), 0) FROM custinfo as ci WITH (NOLOCK) WHERE mrecommend = @mrecommend and Custid <> @CustID AND ((RoleID = 2) OR (ci.roleid = 1 AND ci.recommend = -3))
		SELECT @Credit_MAg = ISNULL(credit, 0) FROM CustInfo AS ci WITH (NOLOCK) WHERE CustID = @mrecommend

		SELECT @Credit_Ag_Max = @Credit_MAg - @Credit_AllOtherAgent
		-----------------------------------------------------------------
				
		SELECT @AccumCredit_AllCashMember = ISNULL(SUM(AccumCreditReturn),0)
		FROM dbo.CashAccumCredit WITH (NOLOCK)
		WHERE recommend = @CustID;

		SELECT @Credit_Ag_Min = MAX(c.credit) + ISNULL(@AccumCredit_AllCashMember, 0)
		from
			(
			Select ISNULL(SUM(credit), 0) AS credit FROM custinfo WITH (NOLOCK) WHERE recommend = @CustID and RoleID=1
			) c
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT @MaxCredit_Mem_Min = MAX(ISNULL(credit,0)) FROM custinfo 
		WHERE recommend = @CustID and roleid =1 

		SELECT @DisableAutoMPT = ISNULL(DisableAutoMPT, 0)
		FROM CustMaster WITH (NOLOCK)  
		WHERE CustID = @mrecommend

		SELECT        
			  @Username							AS UserName
			, @Username2						AS UserName2
			, @firstname						AS FirstName
			, @lastname							AS LastName
			, @phone							AS Phone
			, @mobilephone						AS MobilePhone
			, @email							AS Email
			, @fax							AS Fax
			, @Currency							AS Currency
			, @CurrencyName						AS CurrencyName
			, @Site							AS Site
			, @SiteLabel						AS SiteLabel
		
			-- Get Credit for SB
			, i.credit							AS MaxCredit
			-- Role Agent
			
			, @Credit_Ag_Min						AS MaxCreditMin
			, @Credit_Ag_Max						AS MaxCreditMax
			, @Mem_MaxCredit						AS MemberMaxCredit
			, @MaxCredit_Mem_Min					AS MemberMaxCreditMin
			, @RoleID							AS RoleID
			, @DisableAutoMPT						AS DisableAutoMPT
			, @SpecialPlatfrom					AS SpecialPlatfrom
		FROM custInfo i WITH (NOLOCK)
		WHERE i.custID = @CustID	
	END

	ELSE IF @RoleID = 1
	BEGIN
		IF @IsDirectMember = 0
		BEGIN
			-- MaxCredit_Mem : Maximum Normal Member Credit Set by Upline
			SELECT @MaxCredit_Mem = ISNULL(maxcredit,0) ,@site = ca.site, @sitelabel=s.sitelabel
			FROM CustAgent ca WITH (NOLOCK) 
			INNER JOIN site s WITH (NOLOCK) ON s.site=ca.site
			WHERE ca.CustID = @recommend

			-- MaxCreditMax : Avaiable Credit
			SELECT @Credit_Ag = ISNULL(credit, 0) FROM CustInfo AS ci WITH (NOLOCK) WHERE CustID = @recommend
			SELECT @Credit_AllOtherMember = ISNULL(SUM(credit), 0) FROM custinfo as ci WITH (NOLOCK) WHERE recommend = @recommend and RoleID = 1 AND CustID <> @CustID

			SELECT @Credit_Ag_Bal = @Credit_Ag - @Credit_AllOtherMember
		END
		ELSE IF @IsDirectMember = -3
		BEGIN
			-- MaxCredit_Mem : Maximum Normal Member Credit Set by Upline
			SELECT @MaxCredit_Mem = 0

			-- MaxCreditMax : Avaiable Credit
			SELECT @Credit_MAg = isnull(credit, 0)
			FROM CustInfo AS ci with (NOLOCK) 
			WHERE CustID = @mrecommend

			SELECT @Credit_AllOtherAgent = isnull(sum(credit), 0) 
			FROM custinfo as ci with (NOLOCK) 
			WHERE ci.mrecommend = @mrecommend 
				AND RoleID = 2

			SELECT @Credit_AllOtherDirectMember = isnull(sum(credit), 0) 
			FROM custinfo as ci with (NOLOCK) 
			WHERE mrecommend = @mrecommend 
				AND RoleID = 1
				AND recommend = -3
				AND ci.custid <> @CustID

			SELECT @Credit_Ag_Bal = @Credit_MAg - @Credit_AllOtherAgent - @Credit_AllOtherDirectMember
		END
		ELSE IF @IsDirectMember = -4
		BEGIN
			-- MaxCredit_Mem : Maximum Normal Member Credit Set by Upline
			SELECT @MaxCredit_Mem = 0

			-- MaxCreditMax : Avaiable Credit
			SELECT @Credit_SAg = isnull(credit, 0)
			FROM CustInfo as ci with (NOLOCK) 
			WHERE CustID = @srecommend

			SELECT @Credit_AllOtherMaster = isnull(sum(credit), 0) 
			FROM custinfo as ci with (NOLOCK) 
			WHERE srecommend = @srecommend 
				AND RoleID = 3

			SELECT @Credit_AllOtherDirectMember = isnull(sum(credit), 0) 
			FROM custinfo as ci with (NOLOCK) 
			WHERE srecommend = @srecommend 
				AND RoleID = 1
				AND recommend = -4
				AND ci.custid <> @CustID

			SELECT @Credit_Ag_Bal = @Credit_SAg - @Credit_AllOtherMaster - @Credit_AllOtherDirectMember
		END
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--SELECT @Credit_Mem_Max = CASE WHEN @MaxCredit_Mem =0 THEN @Credit_Ag_Bal
		--							WHEN @MaxCredit_Mem > @Credit_Ag_Bal THEN @Credit_Ag_Bal
		--							  ELSE @MaxCredit_Mem END  

		SELECT @DisableAutoMPT = ISNULL(DisableAutoMPT, 0)
		FROM CustMaster WITH (NOLOCK)  
		WHERE CustID = @mrecommend

		SELECT        
			  @Username							AS UserName
			, @Username2						AS UserName2
			, @firstname						AS FirstName
			, @lastname							AS LastName
			, @phone							AS Phone
			, @mobilephone						AS MobilePhone
			, @email							AS Email
			, @fax							AS Fax
			, @Currency							AS Currency
			, @CurrencyName						AS CurrencyName
			, @Site							AS Site
			, @SiteLabel						AS SiteLabel
		
			-- Get Credit for SB
			, i.credit							AS MaxCredit

			-- Role Member			
			, @uGroup							AS uGroup
			, @RoleID							AS RoleID
			, @DisableAutoMPT						AS DisableAutoMPT
			, @SpecialPlatfrom					AS SpecialPlatfrom
			, @Credit_Ag_Bal					as MaxCreditMax
			, @MaxCredit_Mem					AS MaxCredit_Mem
		FROM custInfo i WITH (NOLOCK)
		WHERE i.custID = @CustID	
	END
END

GO
