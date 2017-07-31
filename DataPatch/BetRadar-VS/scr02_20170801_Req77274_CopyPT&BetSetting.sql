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
	
	DECLARE @fSportType SMALLINT, @fBetType SMALLINT, @tSportType SMALLINT, @tBetType SMALLINT, @IsLive BIT

	DECLARE @ProductID TINYINT = 5
	CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT, IsFinished BIT)
	INSERT INTO #DestinationSportBetType(fSportType, fBetType,tSportType, tBetType, IsLive,  SettingType, IsFinished)
	SELECT	CASE WHEN SportType IN (190, 191, 199) THEN 180 ELSE SportType END, 
			CASE WHEN SportType IN (190, 191, 199) THEN 1201 ELSE BetType END, 
			SportType, BetType, 0, SettingType, 0
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
	WHILE (1 = 1)
	BEGIN		
		UPDATE TOP (1) #DestinationSportBetType
		SET IsFinished = 1
			,@fBetType = fBetType	
			,@fSportType = fSportType
			,@tBetType = tBetType
			,@tSportType = tSportType
			,@IsLive = IsLive
		WHERE IsFinished = 0
			AND SettingType = 1

		IF @@ROWCOUNT = 0 BREAK

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
			cs.custid, @tSportType, @tBetType, @IsLive
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
		WHERE cs.bettype = @fBetType AND cs.sporttype = @fSportType
	
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
			cs.custid, @tSportType, @tBetType, @IsLive
			,cs.spositiontaking  *100
			,cs.mpositiontaking  *100
			,cs.apositiontaking  *100
			,cs.isautompositiontaking
			,cs.autompositiontaking *100
			,cs.isautopositiontaking 
			,cs.autopositiontaking  *100
		FROM dbo.CustSetting3rd cs WITH(NOLOCK)
			INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
		WHERE cs.bettype = @fBetType AND cs.sporttype = @fSportType		
	END	

	--------------------------------------Bet Setting-------------------------------------------------		
	WHILE (1 = 1)
	BEGIN		
		UPDATE TOP (1) #DestinationSportBetType
		SET IsFinished = 1
			,@fBetType = fBetType	
			,@fSportType = fSportType
			,@tBetType = tBetType
			,@tSportType = tSportType
			,@IsLive = IsLive
		WHERE IsFinished = 0
			AND SettingType = 2

		IF @@ROWCOUNT = 0 BREAK

		--Agent Level
		INSERT INTO dbo.CustBetSetting3rd_Agent(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
		SELECT ci.custid, @tSportType, @tBetType, cs.minbet, cs.maxbet, 
				CASE WHEN @fSportType = 181 THEN ci.maxpermatch181
						WHEN @fSportType = 182 THEN ci.maxpermatch182					 
						WHEN @fSportType = 183 THEN ci.maxpermatch183
						WHEN @fSportType = 184 THEN ci.maxpermatch184
						WHEN @fSportType = 185 THEN ci.maxpermatch185
						WHEN @fSportType = 186 THEN ci.maxpermatch186
						ELSE ci.maxpermatch180 END
		FROM dbo.CustSetting3rd cs WITH(NOLOCK)
			INNER JOIN #SMATemp s WITH(NOLOCK) ON cs.CustID = s.custid
			INNER JOIN custInfo ci WITH(NOLOCK) ON cs.CustID = ci.custid
		WHERE cs.bettype = @fBetType AND cs.sporttype = @fSportType

		--Member Level
		INSERT INTO dbo.CustBetSetting3rd_Member(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
		SELECT ci.custid, @tSportType, @tBetType, cs.minbet, cs.maxbet, 
				CASE WHEN @fSportType = 181 THEN ci.maxpermatch181
						WHEN @fSportType = 182 THEN ci.maxpermatch182					 
						WHEN @fSportType = 183 THEN ci.maxpermatch183
						WHEN @fSportType = 184 THEN ci.maxpermatch184
						WHEN @fSportType = 185 THEN ci.maxpermatch185
						WHEN @fSportType = 186 THEN ci.maxpermatch186
						ELSE ci.maxpermatch180 END
		FROM dbo.CustSetting3rd cs WITH(NOLOCK)
			INNER JOIN #MemberTemp m WITH(NOLOCK) ON cs.CustID = m.custid
			INNER JOIN custInfo ci WITH(NOLOCK) ON cs.CustID = ci.custid
		WHERE cs.bettype = @fBetType AND cs.sporttype = @fSportType			
	END
	
	DROP TABLE #SMATemp
	DROP TABLE #MemberTemp
	DROP TABLE #DestinationSportBetType		
END
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS -----
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

-- For deployer info
DECLARE @super_cnt INT, @index INT = 0
DECLARE @msg NVARCHAR(200) = 'Currently at order %d, SuperID: %d.'
DECLARE @msg_total NVARCHAR(200) = 'Total of supers: %d.'

SET @super_cnt = (SELECT COUNT(*) FROM #supers )
RAISERROR (@msg_total, 0, 1, @super_cnt) WITH NOWAIT

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
	
	SET @index = @index + 1
	RAISERROR (@msg, 0, 1, @index, @srecommend) WITH NOWAIT
		
	EXEC dbo.Acc_DynamicCustSetting3rd_09 @srecommend = @srecommend
			,@maxcustid = @max_custid
			,@target = 'REPLICATED'			
			
	WAITFOR DELAY '00:00:0.200'
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

-- For deployer info
DECLARE @super_cnt INT, @index INT = 0
DECLARE @msg NVARCHAR(200) = 'Currently at order %d, SuperID: %d.'
DECLARE @msg_total NVARCHAR(200) = 'Total of supers: %d.'

SET @super_cnt = (SELECT COUNT(*) FROM #supers )
RAISERROR (@msg_total, 0, 1, @super_cnt) WITH NOWAIT

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK

	SET @index = @index + 1
	RAISERROR (@msg, 0, 1, @index, @srecommend) WITH NOWAIT

	EXEC dbo.Acc_DynamicCustSetting3rd_09 @srecommend = @srecommend
			,@maxcustid = @max_custid
			,@target = 'DBCUST'
						
	WAITFOR DELAY '00:00:0.200'
END