ALTER PROCEDURE [dbo].[Acc_CustomerSelMEditCustomerVS]
	@CustID INT
AS
/*
	Created by: Dan
	Date: 2012-08-10
	Task: Master get virtual sports setting of member
	DB: DBCUST.CustDB
	Original: Acc_CustomerSelEditCustomer_MAg
	
	Revisions:		
		- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
		- 20130220@Johnson: get virtual horse racing setting (sporttype: 181, bettype: 1231)
		- 20131121@Kathy: Add Virtual Greyhounds (182), Virtual Motor Racing (184) [Redmine:#7234]
		- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
*/
SET NOCOUNT ON

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @mrecommend				INT, 
		@DisableAutoMPT			BIT, 
		@AgentID				INT, 
		@SuperID				INT, 
		@MasterID				INT,
		@DisableVirtualSports	BIT,
		@HideVirtualSports		BIT,
		@MaxPerMatch180			MONEY,
		@MaxPerMatch181			MONEY,
		@MaxPerMatch182			MONEY,
		@MaxPerMatch183			MONEY,
		@MaxPerMatch184			MONEY,
		@MaxPerMatch185			MONEY,
		@MaxPerMatch186			MONEY

SELECT	@mrecommend = mrecommend, 
		@MaxPerMatch180	= MaxPerMatch180,
		@MaxPerMatch181	= MaxPerMatch181,
		@MaxPerMatch182	= MaxPerMatch182,
		@MaxPerMatch183	= MaxPerMatch183,
		@MaxPerMatch184	= MaxPerMatch184,
		@MaxPerMatch185	= MaxPerMatch185,
		@MaxPerMatch186	= MaxPerMatch186,
--		@DisableVirtualSports	= isnull(DisableVirtualSports,0),
		@HideVirtualSports		= isnull(HideVirtualSports,0)
FROM custinfo WITH (NOLOCK)
WHERE custid = @custid

--Disable auto master PT
SELECT @DisableAutoMPT = ISNULL(DisableAutoMPT,0)
FROM CustMaster WITH (NOLOCK) 
WHERE CustID = @mrecommend

SELECT @AgentID = recommend, @SuperID = srecommend, @MasterID = mrecommend 
FROM custinfo WITH(NOLOCK) 
WHERE custid = @CustID

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- get master PT value
DECLARE @MinMaxPTMaster TABLE(
			sporttype int, 
			bettype int, 
			n3 smallmoney,	
			m3 smallmoney		
			)
INSERT INTO @MinMaxPTMaster  (sporttype, bettype,n3,m3)
SELECT cs.sporttype, cs.bettype,
	--@mapos_max=min(m3,l3,m4)	
	co.minpositiontaking as n3,
	CASE WHEN cs.mpositiontaking<co.maxpositiontaking 
		THEN CASE WHEN cs.mpositiontaking<scs.mpositiontaking
				THEN cs.mpositiontaking
				ELSE scs.mpositiontaking 
			END
		ELSE CASE WHEN co.maxpositiontaking < scs.mpositiontaking
				THEN co.maxpositiontaking
				ELSE scs.mpositiontaking 
			END
	END AS m3
From 
	CustSetting3rd as cs with (NOLOCK)
	LEFT JOIN CustOverride3rd as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
	LEFT JOIN CustSetting3rd as scs with (NOLOCK) on scs.custid=@SuperID and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
Where cs.CustID = @MasterID
		AND cs.sporttype in (180, 181, 182, 183, 184, 185, 186) and cs.bettype in (1201, 1231, 1220)

/*
DECLARE @MaxPT TABLE(
			sporttype int, 
			bettype int, 
			m1_max smallmoney
			)		
--@max_mp = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
INSERT INTO @MaxPT(sporttype, bettype, m1_max )
SELECT	cs.sporttype, cs.bettype,
		case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) 
				then mcs.mpositiontaking-cs.apositiontaking 
				else case when mcs.mpositiontaking - cs.apositiontaking <= Scs.spositiontaking - cs.spositiontaking - cs.apositiontaking 
						then  mcs.mpositiontaking - cs.apositiontaking 
						else Scs.spositiontaking - cs.spositiontaking - cs.apositiontaking 
					end 
		end as m1_max
FROM CustSetting3rd as cs WITH (NOLOCK) 
	JOIN custinfo as c WITH (NOLOCK) ON cs.custid = c.custid
	JOIN CustSetting3rd as mcs WITH (NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype =cs.bettype
	JOIN CustSetting3rd as Scs  WITH (NOLOCK) ON Scs.custid = c.srecommend AND Scs.sporttype = cs.sporttype AND Scs.bettype =cs.bettype	
WHERE cs.custid = @custid 
		AND cs.sporttype = 180 and cs.bettype=1201
*/
-- CUSTOMER
SELECT	c.username, 
		c.username2, 
		c.firstname,
		c.lastname,
		c.phone,
		c.mobilephone,
		c.email,
		c.fax,		
--		@DisableVirtualSports as DisableVirtualSports,
		@HideVirtualSports as HideVirtualSports,
		@DisableAutoMPT as DisableAutoMPT
FROM	Customer c WITH (NOLOCK)			
WHERE	c.custID = @CustID 
	
SELECT
	cs.sporttype,
	cs.bettype,
	
	cs.minbet, 
	cs.maxbet , 
	CASE cs.sporttype WHEN 180 then @MaxPerMatch180 
						WHEN 181 then @MaxPerMatch181 
						WHEN 182 then @MaxPerMatch182 
						WHEN 183 then @MaxPerMatch183 
						WHEN 184 then @MaxPerMatch184 
						WHEN 185 then @MaxPerMatch185
						WHEN 186 then @MaxPerMatch186 END AS MaxPerMatch,

	cs.apositiontaking as a1,
	cs.mpositiontaking as m1,

	--im2
	acs.isautompositiontaking  as im2,
		
	--im1
	cs.isautompositiontaking as im1,
	
	--um1
	cs.autompositiontaking as um1,
	
	--maxpos_1= min(m3,l3,m4)-a1	
	m3 - cs.apositiontaking as m1_max,
	------------------------------------------------------------------------------------------------------------------------------------
	case when n3 - cs.apositiontaking <0 
			then 0 else n3 - cs.apositiontaking end as m1_min,		
			
	-- um1_min = [Max(0, N3-A1)
	case when n3 - cs.apositiontaking <0 
			then 0 else n3 - cs.apositiontaking end as um1_min,				
	--um1_max =  Min(M3, M4)
	isnull(m3,0) as um1_max
	
FROM 
	CustSetting3rd as cs with (NOLOCK) 
	INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = @AgentID AND acs.sporttype=cs.sporttype AND acs.bettype=cs.bettype
	JOIN @MinMaxPTMaster m on cs.sporttype=m.sporttype and cs.bettype=m.bettype
	--JOIN @MaxPT maxPT on cs.sporttype=maxPT.sporttype and cs.bettype=maxPT.bettype	
WHERE cs.custid=@custId 
		AND cs.sporttype  in (180, 181, 182, 183, 184, 185, 186) and cs.bettype in (1201, 1231, 1220)


GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerVS] TO [bodbAdminNet]

GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerVS] TO [bodbExtAccNet]

GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerVS] TO [bodbDownlineNet]

GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerVS] TO [bodbDownlineNetView]

GO 
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelMEditCustomerVS] TO [vnteam]
GO 
