ALTER PROCEDURE [dbo].[Acc_CustomerSelSEditCustomerVS]
	@custid		INT
 AS
/*
	Created: Johnson
	Date: 2012-08-13
	Task: Get setting of virtual sports for super edit member
	DB: DBCUST.CustDB
		
	Revisions:
		- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
		- 20130220@Johnson: get virtual horse racing setting (sporttype: 181, bettype: 1231)
		- 20131121@Kathy: Add Virtual Greyhounds (182), Virtual Motor Racing (184) [Redmine:#7234]
		- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Parameter's Explanation:
*/
SET NOCOUNT ON
-------------------------------
	DECLARE @srecommend				INT,
			@mrecommend				INT,
			@HideVirtualSports		BIT,
			@v180MaxPerMatch_1201	MONEY,
			@v181MaxPerMatch_1231	MONEY,
			@v182MaxPerMatch_1231	MONEY,
			@v183MaxPerMatch_1231	MONEY,
			@v184MaxPerMatch_1231	MONEY,
			@v185MaxPerMatch_1231	MONEY,
			@v186MaxPerMatch_1220	MONEY
	
	SELECT @srecommend = srecommend,
			@mrecommend = mrecommend,
			@v180MaxPerMatch_1201 = maxpermatch180,
			@v181MaxPerMatch_1231 = maxpermatch181,
			@v182MaxPerMatch_1231 = maxpermatch182,
			@v183MaxPerMatch_1231 = maxpermatch183,
			@v184MaxPerMatch_1231 = maxpermatch184,
			@v185MaxPerMatch_1231 = maxpermatch185,
			@v186MaxPerMatch_1220 = MaxPerMatch186,
			@HideVirtualSports	  = isnull(HideVirtualSports,0)
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid
	
	SELECT username,
			username2,
			firstname,
			lastname,
			phone,
			mobilephone,			
			fax,
			roleid,							
			@HideVirtualSports as HideVirtualSports
	FROM customer WITH(NOLOCK)
	WHERE custid = @custid
	
	SELECT cs.sporttype,
			cs.bettype,
			
			cs.minbet,
			cs.maxbet,
			CASE cs.sporttype WHEN 180 then @v180MaxPerMatch_1201
								WHEN 181 then @v181MaxPerMatch_1231 
								WHEN 182 then @v182MaxPerMatch_1231 
								WHEN 183 then @v183MaxPerMatch_1231 
								WHEN 184 then @v184MaxPerMatch_1231 
								WHEN 185 then @v185MaxPerMatch_1231 
								WHEN 186 then @v186MaxPerMatch_1220 END AS MaxPerMatch,
			
			cs.apositiontaking as a1,
			cs.mpositiontaking as m1,
			cs.spositiontaking as s1,
			cs.isautopositiontaking as is1,
			cs.autopositiontaking as us1,
			
			mcs.isautopositiontaking as is3,
			-- us1_max=S4
			scs.spositiontaking as us1_max,
			
			-- s1_max= Max(N4-M1-A1, S4-M3)
			CASE WHEN scs.spositiontaking - mcs.mpositiontaking > sco.minpositiontaking - (cs.mpositiontaking + cs.apositiontaking)
				THEN scs.spositiontaking - mcs.mpositiontaking
				ELSE sco.minpositiontaking - (cs.mpositiontaking + cs.apositiontaking)
			END AS s1_max,
			
			-- s1_min = Max(0, N4-M1-A1)
			CASE WHEN sco.minpositiontaking - (cs.mpositiontaking + cs.apositiontaking) < 0 THEN 0 ELSE sco.minpositiontaking - (cs.mpositiontaking + cs.apositiontaking) END as s1_min
	FROM custsetting3rd cs WITH(NOLOCK)		
		INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
		INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
		INNER JOIN custoverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype
	WHERE cs.custid = @custid 
		AND cs.sporttype  in (180, 181, 182, 183, 184, 185, 186)
		AND cs.bettype in (1201, 1231, 1220)

		
		
		

		
		
		
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelSEditCustomerVS] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerVS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerVS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerVS] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerVS] TO [bodbExtAccNet]