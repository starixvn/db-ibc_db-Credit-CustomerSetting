ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMasterVS] 
	@custid	INT
AS
/*
	Created: Johnson
	Date: 2012-08-09
	Task: get virtual sports info of master
	DB: DBCUST.CustDB
		
	Revisions:
		- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
		- 20130220@Johnson: get virtual horse racing setting (sporttype : 181, bettype: 1231)
		- 20131121@Kathy: Add Virtual Greyhounds (182), Virtual Motor Racing (184) [Redmine:#7234]
		- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)

	Parameter's Explanation:
*/
SET NOCOUNT ON 
---------------------------
	DECLARE @Downlines						BIT,
			@DisableDownlinesVirtualSports				BIT,
			@DisableUplineVirtualSports					BIT,
			
			@DisableVirtualSports			BIT,
			@HideVirtualSports				BIT,
			@v180MaxPerMatch_1201			MONEY,
			@v181MaxPerMatch_1231			MONEY,
			@v182MaxPerMatch_1231			MONEY,
			@v183MaxPerMatch_1231			MONEY,
			@v184MaxPerMatch_1231			MONEY,
			@v185MaxPerMatch_1231			MONEY,
			@v186MaxPerMatch_1220			MONEY,
			@DisableAutoMPT					BIT,
			@srecommend						INT			
			
	--setting upline
	DECLARE  @SuperSetting TABLE(	
			sporttype			INT,
			bettype				INT,	
			mpositiontaking		SMALLMONEY,
			spositiontaking		SMALLMONEY,			
			minpositiontaking	SMALLMONEY,
			MinBet				MONEY,
			MaxBet				MONEY,
			MaxPerMatch			MONEY				
	)
		
	SELECT @DisableVirtualSports	= ISNULL(DisableVirtualSports,0),
			@HideVirtualSports		= ISNULL(HideVirtualSports,0),
			@v180MaxPerMatch_1201	= MaxPerMatch180,
			@v181MaxPerMatch_1231	= MaxPerMatch181,
			@v182MaxPerMatch_1231	= MaxPerMatch182,
			@v183MaxPerMatch_1231	= MaxPerMatch183,
			@v184MaxPerMatch_1231	= MaxPerMatch184,
			@v185MaxPerMatch_1231	= MaxPerMatch185,
			@v186MaxPerMatch_1220	= MaxPerMatch186,
			@srecommend = srecommend
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid
	
	--Disable auto master PT
	SELECT @DisableAutoMPT = ISNULL(DisableAutoMPT,0)
	FROM CustMaster (nolock) 
	WHERE CustID = @custid
		
	SELECT top 1 @Downlines = 1 FROM custinfo WITH(NOLOCK) WHERE mrecommend = @custid AND roleid = 2
	
	SELECT top 1 @DisableDownlinesVirtualSports = ISNULL(DisableVirtualSports,0)
	FROM custinfo WITH(NOLOCK)
	WHERE mrecommend =@custid
		AND roleid = 2
		AND DisableVirtualSports = 1
				
	select @DisableUplineVirtualSports = isnull(DisableVirtualSports,0)
	FROM custinfo with (NOLOCK) 
	WHERE custid = @srecommend
	
	--upline setting
	INSERT INTO @SuperSetting (sporttype , bettype, mpositiontaking, spositiontaking, minpositiontaking, minbet, maxbet, maxpermatch)
	SELECT cs.sporttype, 
			cs.bettype, 
			cs.mpositiontaking,
			cs.spositiontaking, 
			co.minpositiontaking, 
			cs.minbet, 
			cs.maxbet, 
			CASE cs.sporttype WHEN 180 then ci.MaxPerMatch180
								WHEN 181 then ci.MaxPerMatch181
								WHEN 182 then ci.MaxPerMatch182
								WHEN 183 then ci.MaxPerMatch183
								WHEN 184 then ci.MaxPerMatch184
								WHEN 185 then ci.MaxPerMatch185
								WHEN 186 then ci.MaxPerMatch186 END AS MaxPerMatch
	FROM custinfo ci WITH(NOLOCK)
		INNER JOIN custsetting3rd cs WITH(NOLOCK) ON ci.custid = cs.custid 
		LEFT JOIN CustOverride3rd as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
	WHERE ci.custid = @srecommend 
		AND cs.sporttype in (180, 181, 182, 183, 184, 185, 186)
		AND cs.bettype  in (1201, 1231, 1220)
			
		
	SELECT username,
			username2,
			firstname,
			lastname,
			phone,
			mobilephone,			
			fax,
			roleid,
			@DisableUplineVirtualSports as DisableUplineVirtualSports,
			@DisableAutoMPT DisableAutoMPT,
			@DisableVirtualSports as DisableVirtualSports,
			@HideVirtualSports as HideVirtualSports,
			CASE WHEN @Downlines = 1 THEN ISNULL(@DisableDownlinesVirtualSports,0) ELSE @DisableVirtualSports END as DisableDownlinesVirtualSports
	FROM customer WITH(NOLOCK)
	WHERE custid = @custid
	

	SELECT cs.sporttype,
			cs.bettype,
			
			cs.minbet,
			cs.maxbet,
			--@v180MaxPerMatch_1201 as MaxPerMatch,
			CASE cs.sporttype WHEN 180 then @v180MaxPerMatch_1201
								WHEN 181 then @v181MaxPerMatch_1231
								WHEN 182 then @v182MaxPerMatch_1231
								WHEN 183 then @v183MaxPerMatch_1231
								WHEN 184 then @v184MaxPerMatch_1231
								WHEN 185 then @v185MaxPerMatch_1231
								WHEN 186 then @v186MaxPerMatch_1220 END AS MaxPerMatch,
			
			scs.MinBet as minbet_min,
			scs.MaxBet as maxbet_max,
			scs.MaxPerMatch as maxpermatch_max,
			
			cs.spositiontaking as s3,
			cs.mpositiontaking as m3,
			cs.isautopositiontaking as is3,
			cs.autopositiontaking as us3, 						
			co.minpositiontaking as n3,
			
			scs.minpositiontaking as n4,
			scs.mpositiontaking as m4,
			scs.spositiontaking as s4
			/* 
			-- web will handle min/max 
			--s3_min = MAX(0, n4-m4)
			CASE WHEN scs.minpositiontaking - scs.mpositiontaking > 0 THEN scs.minpositiontaking - scs.mpositiontaking ELSE 0 END AS s3_min,
			--s3_max= s4
			scs.spositiontaking as s3_max,			
			
			-- m3_min = (is3=0?Max(0, N4-S3): Max(0, N4-US3))
			case when cs.isautopositiontaking = 0 
				then (case when scs.minpositiontaking - cs.spositiontaking > 0 then scs.minpositiontaking - cs.spositiontaking else 0 end)
				else (case when scs.minpositiontaking - cs.autopositiontaking > 0 then scs.minpositiontaking - cs.autopositiontaking else 0 end)
			end as m3_min,
			
			--m3_max= (IS3 = 0?  Min(S4-S3, M4): M4)
			case when cs.isautopositiontaking = 0 
				then (case when scs.spositiontaking - cs.spositiontaking < scs.mpositiontaking then scs.spositiontaking - cs.spositiontaking else scs.mpositiontaking end)
				else scs.mpositiontaking
			end as m3_max,
			
			--us3_min = MAX(0, n4-m4)
			CASE WHEN scs.minpositiontaking - scs.mpositiontaking > 0 THEN scs.minpositiontaking - scs.mpositiontaking ELSE 0 END AS us3_min,
			
			--us3_max = s4
			scs.spositiontaking as us3_max
			*/
	FROM custsetting3rd cs WITH(NOLOCK)
		INNER JOIN custoverride3rd co WITH(NOLOCK) ON cs.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype
		JOIN @SuperSetting scs ON cs.sporttype = scs.sporttype AND cs.bettype = scs.bettype
	WHERE cs.custid = @custid
		AND cs.sporttype in (180, 181, 182, 183, 184, 185, 186)
		AND cs.bettype in (1201, 1231, 1220)





GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditMasterVS] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterVS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterVS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterVS] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterVS] TO [bodbExtAccNet]