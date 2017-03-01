ALTER PROCEDURE [dbo].[Acc_CustomerSelEditSuperVS]
	@custid		INT
AS
/*
	Created: Dan
	Date: 09Aug2012
	Task: Company edits super's virtual soccer setting
	DB: DBCUST.CustDB
		
	Revisions:
		- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
		- 20130220@Johnson: get virtual horse racing setting (sporttype : 181, bettype: 1231)
		- 20131121@Kathy: Add Virtual Greyhounds (182), Virtual Motor Racing (184) [Redmine:#7234]	
		- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)

	Parameters Explanations:

*/
SET NOCOUNT ON

DECLARE 
	@downlines				BIT,	
	@DisableDownlinesVirtualSports		BIT,
	@DisableVirtualSports	BIT,
	@HideVirtualSports		BIT,
	@maxpermatch180_min		MONEY,
	@MaxPerMatch180			MONEY,
	@maxpermatch181_min		MONEY,
	@MaxPerMatch181		 	MONEY,
	@maxpermatch186_min		MONEY,
	@MaxPerMatch186			MONEY,
	@maxpermatch182_min		MONEY,
	@MaxPerMatch182			MONEY,
	@maxpermatch184_min		MONEY,
	@MaxPerMatch184			MONEY,
	@maxpermatch183_min		MONEY,
	@MaxPerMatch183			MONEY,
	@maxpermatch185_min		MONEY,
	@MaxPerMatch185			MONEY

SELECT @downlines = CASE WHEN EXISTS(SELECT TOP 1 1 FROM custinfo WITH(NOLOCK) WHERE srecommend = @custid and roleid = 3) THEN 1 ELSE 0 END

SELECT TOP 1 @DisableDownlinesVirtualSports = ISNULL(DisableVirtualSports, 0) 
FROM custinfo WITH (NOLOCK) 
WHERE srecommend = @custid and roleid = 3 and DisableVirtualSports = 1
	
--to facilitate in Web Interface
SELECT 	@MaxPerMatch180_Min = 0, 
		@MaxPerMatch181_Min = 0, 
		@maxpermatch186_min = 0,
		@MaxPerMatch182_Min = 0, 
		@maxpermatch184_min = 0,
		@maxpermatch183_min = 0,
		@maxpermatch185_min = 0

SELECT @DisableVirtualSports	= ISNULL(DisableVirtualSports, 0),
		@HideVirtualSports		= ISNULL(HideVirtualSports, 0),
		@MaxPerMatch180			= MaxPerMatch180,
		@MaxPerMatch181			= MaxPerMatch181,
		@MaxPerMatch186			= MaxPerMatch186,
		@MaxPerMatch182			= MaxPerMatch182,
		@MaxPerMatch184			= MaxPerMatch184,
		@MaxPerMatch183			= MaxPerMatch183,
		@MaxPerMatch185			= MaxPerMatch185
FROM custinfo WITH(NOLOCK)
WHERE custid = @custid

-- CUSTOMER
SELECT	c.username, 
		c.username2, 
		c.firstname,
		c.lastname,
		c.phone,
		c.mobilephone,
		c.email,
		c.fax,
		@DisableVirtualSports as DisableVirtualSports,
		@HideVirtualSports as HideVirtualSports,
		CASE 
			WHEN @downlines = 0 THEN @DisableVirtualSports 
			ELSE ISNULL(@DisableDownlinesVirtualSports,0) 
		END AS DisableDownlinesVirtualSports
FROM	Customer c WITH (NOLOCK)
WHERE	c.custID = @CustID 

-- bet setting
SELECT
	cs.sporttype,
	cs.bettype,
	cs.minbet, 
	cs.maxbet,

	CASE cs.sporttype WHEN 180 THEN @MaxPerMatch180 
						WHEN 181 THEN @MaxPerMatch181
						WHEN 186 THEN @MaxPerMatch186 
						WHEN 182 THEN @MaxPerMatch182
						WHEN 184 THEN @MaxPerMatch184 
						WHEN 183 THEN @MaxPerMatch183 
						WHEN 185 THEN @MaxPerMatch185
						END AS MaxPerMatch,
	CASE cs.sporttype WHEN 180 THEN @MaxPerMatch180_Min 
						WHEN 181 THEN @MaxPerMatch181_Min 
						WHEN 186 THEN @MaxPerMatch186_Min 
						WHEN 182 THEN @MaxPerMatch182_Min 
						WHEN 184 THEN @MaxPerMatch184_Min
						WHEN 183 THEN @MaxPerMatch183_Min
						WHEN 185 THEN @MaxPerMatch185_Min
						END AS MaxPerMatch_Min,
		
	cs.spositiontaking as s4,
	cs.mpositiontaking as m4,
	cs.apositiontaking as a4,
	co.minpositiontaking as n4
	--0.9 as s4_max		
FROM dbo.CustSetting3rd AS cs WITH (NOLOCK) 
	JOIN dbo.custOverride3rd AS co WITH (NOLOCK) 
	ON cs.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype
WHERE cs.custid = @custId 
	AND cs.sporttype in (180, 181, 182, 183, 184, 185, 186) 
	AND cs.bettype in (1201, 1231, 1220)


GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditSuperVS] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperVS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperVS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperVS] TO [bodbExtAccNet]