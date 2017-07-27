/*
	Created: Elodie
	Task: Copy PT & Bet Setting for BetRadarVS
	DB: DBCUST/CustDB
	Date: 20170801
*/ 

ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_09]
	@srecommend INT	
	,@maxcustid INT
	,@target VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON
	
	IF (@target = 'REPLICATED' AND @@SERVERNAME = 'DBCUST') RETURN	-- run at all replicated servers
	IF (@target = 'DBCUST' AND @@SERVERNAME <> 'DBCUST') RETURN -- run at dbtrans only
	
	IF dbo.f_CheckRepTable('CustInfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 RETURN
	
	DECLARE @ProductID TINYINT = 5
	CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT)
	INSERT INTO #DestinationSportBetType
	SELECT	CASE WHEN SportType IN (190, 191, 199) THEN 180 ELSE SportType END, 
			CASE WHEN SportType IN (190, 191, 199) THEN 1201 ELSE BetType END, 
			SportType, BetType, 0, SettingType
	FROM dbo.ProductSettingDetail WITH (NOLOCK)
	WHERE ProductID = @ProductID AND SettingType IN (1, 2)

	CREATE TABLE #MemberTemp
	(
		CustID INT PRIMARY KEY CLUSTERED
	)

	CREATE TABLE #SMATemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
		roleid TINYINT
	)
	
	INSERT INTO #MemberTemp (CustID)
	SELECT custid
	FROM Custinfo WITH (NOLOCK)
	WHERE srecommend = @srecommend AND roleid = 1 AND custid <= @maxcustid
	
	
	INSERT INTO #SMATemp (CustID, roleid)
	SELECT custid, roleid
	FROM Custinfo WITH (NOLOCK)
	WHERE srecommend = @srecommend AND roleid IN (2,3,4) AND custid <= @maxcustid 

	DECLARE @MaxPT TINYINT--, @MaxComm DECIMAL(9,8), @Currency INT
	SELECT TOP 1 @MaxPT = MaxPT FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = @ProductID AND SettingType = 1
	--SELECT TOP 1 @MaxComm = MaxDiscount FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = @ProductID AND SettingType = 3
	--SELECT @Currency = currency FROM customer WITH (NOLOCK) WHERE custid = @srecommend
	
	--------------------------------------PT Setting-------------------------------------------------	
	--AGENT LEVEL
	INSERT INTO dbo.CustPTSetting3rd_Agent
		(	[CustID]
		   ,[SportType]
		   ,[BetType]
		   ,[IsLive]
		   ,[SuperPT]
		   ,[MasterPT]
		   ,[AgentPT]
		   ,[IsAutoMasterPT]
		   ,[AutoMasterPT]
		   ,[IsAutoSuperPT]
		   ,[AutoSuperPT]
		   ,[MinPT]
		   ,[MaxPT])
	SELECT 
		cs.custid, dest.tsporttype, dest.tbettype, dest.IsLive
		,cs.spositiontaking  *100
		,cs.mpositiontaking  *100
		,cs.apositiontaking  *100
		,cs.isautompositiontaking
		,cs.autompositiontaking *100
		,cs.isautopositiontaking 
		,cs.autopositiontaking  *100
		,co.minpositiontaking  *100
		,@MaxPT
	FROM dbo.CustSetting3rd cs WITH(NOLOCK) 
		INNER JOIN dbo.custOverride3rd co WITH(NOLOCK) ON cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype
		INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	
	--MEMBER LEVEL
	INSERT INTO dbo.CustPTSetting3rd_Member
		(	[custid]
		  ,	[sporttype]
		  ,	[bettype]
		  ,	[islive]
		  ,	[superPT]
		  ,	[masterPT]
		  ,	[agentPT]
		  ,	[IsAutoMasterPT]
		  ,	[AutoMasterPT]
		  ,	[IsAutoSuperPT]
		  ,	[AutoSuperPT])
	SELECT 
		cs.custid, dest.tsporttype, dest.tbettype, dest.IsLive
		,cs.spositiontaking  *100
		,cs.mpositiontaking  *100
		,cs.apositiontaking  *100
		,cs.isautompositiontaking
		,cs.autompositiontaking *100
		,cs.isautopositiontaking 
		,cs.autopositiontaking  *100
	FROM dbo.CustSetting3rd cs WITH(NOLOCK)
		INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	
	--DECLARE @apos SMALLMONEY,
	--		@mpos SMALLMONEY
	
	--UPDATE cs
	--SET cs.MinPT = @MaxPT
	--FROM dbo.CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	--	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	--	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	--WHERE MinPT > @MaxPT		
	
	--UPDATE cs
	--SET @apos = CASE WHEN cs.AgentPT > @MaxPT THEN @MaxPT ELSE cs.AgentPT END,
	--	cs.AgentPT = @apos,
	--	@mpos = CASE WHEN @apos + cs.MasterPT > @MaxPT THEN @MaxPT- @apos ELSE cs.MasterPT END,
	--	cs.MasterPT = @mpos,
	--	cs.SuperPT = CASE WHEN @apos + @mpos + cs.SuperPT > @MaxPT THEN @MaxPT - @mpos -@apos ELSE cs.SuperPT END
	--FROM  CustPTSetting3rd_Member cs WITH(UPDLOCK,ROWLOCK) 
	--	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	--	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	--WHERE cs.SuperPT + cs.MasterPT + cs.AgentPT > @MaxPT
		
	--UPDATE cs
	--SET @apos = CASE WHEN cs.AgentPT > @MaxPT THEN @MaxPT ELSE cs.AgentPT END,
	--	cs.AgentPT = @apos,
	--	cs.MasterPT = CASE WHEN @apos + cs.MasterPT > @MaxPT THEN @MaxPT- @apos ELSE cs.MasterPT END		
	--FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	--	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	--	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	--WHERE cs.MasterPT + cs.AgentPT > @MaxPT	AND roleid = 2
	
	--UPDATE cs
	--SET @mpos = CASE WHEN cs.MasterPT > @MaxPT THEN @MaxPT ELSE cs.MasterPT END,
	--	cs.MasterPT = @mpos,
	--	cs.SuperPT = CASE WHEN cs.SuperPT + @mpos > @MaxPT THEN @MaxPT - @mpos ELSE cs.SuperPT END 		
	--FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	--	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	--	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	--WHERE cs.MasterPT + cs.SuperPT > @MaxPT	AND roleid = 3
		
	--UPDATE cs
	--SET cs.SuperPT = CASE WHEN cs.SuperPT <> @MaxPT THEN @MaxPT ELSE cs.SuperPT END, 		
	--	cs.MasterPT = CASE WHEN cs.MasterPT <> @MaxPT THEN @MaxPT ELSE cs.MasterPT END, 	
	--	cs.AgentPT = CASE WHEN cs.AgentPT <> @MaxPT THEN @MaxPT ELSE cs.AgentPT END 	
	--FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	--	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	--	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	--WHERE ci.custid = @srecommend		
	--	AND (cs.SuperPT <> @MaxPT	
	--		OR cs.MasterPT <> @MaxPT
	--		OR cs.AgentPT <> @MaxPT)	

	--------------------------------------Bet Setting-------------------------------------------------		
	--Agent Level
	INSERT INTO dbo.CustBetSetting3rd_Agent(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
	SELECT ci.custid, dest.tsporttype, dest.tbettype, cs.minbet, cs.maxbet, 
			CASE WHEN dest.fSportType = 181 THEN ci.maxpermatch181
					WHEN dest.fSportType = 182 THEN ci.maxpermatch182					 
					WHEN dest.fSportType = 183 THEN ci.maxpermatch183
					WHEN dest.fSportType = 184 THEN ci.maxpermatch184
					WHEN dest.fSportType = 185 THEN ci.maxpermatch185
					WHEN dest.fSportType = 186 THEN ci.maxpermatch186
					ELSE ci.maxpermatch180 END
	FROM dbo.CustSetting3rd cs WITH(NOLOCK)
		INNER JOIN #SMATemp s WITH(NOLOCK) ON cs.CustID = s.custid
		INNER JOIN custInfo ci WITH(NOLOCK) ON cs.CustID = ci.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 2 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType

	--Member Level
	INSERT INTO dbo.CustBetSetting3rd_Member(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
	SELECT ci.custid, dest.tsporttype, dest.tbettype, cs.minbet, cs.maxbet, 
			CASE WHEN dest.fSportType = 181 THEN ci.maxpermatch181
					WHEN dest.fSportType = 182 THEN ci.maxpermatch182					 
					WHEN dest.fSportType = 183 THEN ci.maxpermatch183
					WHEN dest.fSportType = 184 THEN ci.maxpermatch184
					WHEN dest.fSportType = 185 THEN ci.maxpermatch185
					WHEN dest.fSportType = 186 THEN ci.maxpermatch186
					ELSE ci.maxpermatch180 END
	FROM dbo.CustSetting3rd cs WITH(NOLOCK)
		INNER JOIN #MemberTemp m WITH(NOLOCK) ON cs.CustID = m.custid
		INNER JOIN custInfo ci WITH(NOLOCK) ON cs.CustID = ci.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 2 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	
	DROP TABLE #SMATemp
	DROP TABLE #MemberTemp
	DROP TABLE #DestinationSportBetType		
END
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS (06/DBTP) -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT

SELECT @max_custid = xxx

INSERT INTO #supers(custid)
SELECT ci.custid
FROM customer ci WITH (NOLOCK) 
	INNER JOIN site s WITH (NOLOCK) ON ci.site = s.site
	LEFT JOIN custsuper cs WITH (NOLOCK) ON ci.custid = cs.custid
WHERE ci.roleid = 4  
			AND ci.username NOT LIKE '3rdSuper%'
			AND cs.isinternal = 0
			AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
			AND s.islicensee = 0
			AND ci.custid <= @max_custid

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	EXEC dbo.Acc_DynamicCustSetting3rd_09 @srecommend = @srecommend
			,@maxcustid = @max_custid
			,@target = 'REPLICATED'
			
			
	waitfor delay '00:00:0.280'
END
GO

-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT

SELECT @max_custid = xxx

INSERT INTO #supers(custid)
SELECT ci.custid
FROM customer ci WITH (NOLOCK) 
	INNER JOIN site s WITH (NOLOCK) ON ci.site = s.site
	LEFT JOIN custsuper cs WITH (NOLOCK) ON ci.custid = cs.custid
WHERE ci.roleid = 4  
			AND ci.username NOT LIKE '3rdSuper%'
			AND cs.isinternal = 0
			AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
			AND s.islicensee = 0
			AND ci.custid <= @max_custid

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK

	EXEC dbo.Acc_DynamicCustSetting3rd_09 @srecommend = @srecommend
			,@maxcustid = @max_custid
			,@target = 'DBCUST'
						
	waitfor delay '00:00:0.280'
END