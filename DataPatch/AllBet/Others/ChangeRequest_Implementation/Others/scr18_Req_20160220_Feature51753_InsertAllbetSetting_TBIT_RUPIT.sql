/*
	Created By: Helen
	Created Date: 20161012
	Task: Initial data for TB-IT - Site : 755555 & RUP-IT  - Site : Indo
	
	DB: DBCUST/CUSTDB

	/* Data reference
	custid	Enabled	closed	srecommend	mrecommend	recommend	username
	19542865	1		0		15		4183		31987		RUP-IT
	19545984	1		0		4		4177		1265		TB-IT

	CustID	SportType	BetType	StakeLevelList
	4183	211	2401	683,684,686
	4183	211	2402	728

	4177	211	2401	671,672,673,674
	4177	211	2402	723
	*/


*/

SET NOCOUNT ON

CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT)
INSERT INTO #DestinationSportBetType
VALUES
(162, 1101, 211	, 2401, 0, 1), --PT
(162, 1101, 211	, 2401, 0, 3), --Comm
(162, 1101, 211	, 2401, 0, 6) --WinLossLimit

CREATE TABLE #MemberTemp
(
	CustID INT PRIMARY KEY CLUSTERED,
	SyncLiveCasino BIT,
	MaxWinLiveCasino SMALLMONEY,
	isAutoResetLiveCasino BIT
	
)

CREATE TABLE #SMATemp
(
	CustID INT PRIMARY KEY CLUSTERED,
	roleid TINYINT,
	SyncLiveCasino BIT,
	MaxWinLiveCasino SMALLMONEY,
	isAutoResetLiveCasino BIT
	
)
INSERT INTO #SMATemp (CustID,roleid,SyncLiveCasino,MaxWinLiveCasino,isAutoResetLiveCasino)
SELECT CustID,roleid,SyncLiveCasino,MaxWinLiveCasino,isAutoResetLiveCasino
FROM custInfo (NOLOCK)
WHERE custid IN (31987,1265) -- agent

INSERT INTO #MemberTemp (CustID,SyncLiveCasino,MaxWinLiveCasino,isAutoResetLiveCasino)
SELECT CustID,SyncLiveCasino,MaxWinLiveCasino,isAutoResetLiveCasino
FROM custInfo (NOLOCK)
WHERE custid IN (19542865,19545984) -- member

------------------Starting  StakeLevel -------------
INSERT INTO dbo.CustStakeLevel_Agent(CustID, SportType, BetType, StakeLevelList)		
VALUES (31987,211,2401,'683,684,686')
		,(31987,211,2402,'728')
		
		,(1265,211,2401,'671,672,673,674')
		,(1265,211,2402,'723')

INSERT INTO dbo.CustStakeLevel_Member(CustID, SportType, BetType, StakeLevelList)	
VALUES (19542865,211,2401,'683')
		,(19542865,211,2402,'728')
		
		, (19545984,211,2401,'671')
		, (19545984,211,2402,'723')

------------------END OF  StakeLevel -------------		

----------------- STATUS ------------------------

DECLARE @xmlStrHidden_0 XML

DECLARE @xmlStrSync_0 XML

SET @xmlStrSync_0 =(
		SELECT (
				SELECT psp.bitmapOrder	AS '@b'
					, 0	AS '@s'
				FROM ProductStatusProfile psp WITH (NOLOCK)
				WHERE psp.Sporttype = 211 AND Bettype IN (2401,2402)	
				FOR XML PATH('r')
					, TYPE
				)
		FOR XML PATH('root')
			, TYPE
		)
				
SET @xmlStrHidden_0 =(
		SELECT (
				SELECT psp.bitmapOrder	AS '@b'
					, 0	AS '@s'
				FROM ProductStatusProfile psp WITH (NOLOCK)
				WHERE psp.Sporttype = 211 AND Bettype IN (2401,2402)	

				FOR XML PATH('r')
					, TYPE
				)
		FOR XML PATH('root')
			, TYPE

		)

UPDATE cs
SET 	
	  bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 0 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
							 ELSE cs.bitmapHasSynced
						END	 
	, bitmapIsHidden =  CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
							 ELSE cs.bitmapIsHidden
						END	
	, bitmapIsDisabled = CASE WHEN ci.SyncLiveCasino = 1 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 6, 0) ELSE bitmapIsDisabled END
						 
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN custInfo CI WITH (NOLOCK) ON cs.CustID = ci.CustID
WHERE ci.custid IN (19542865,19545984 -- MEMBER
					,31987,1265 -- AGENT
					) 
					
----------------- END OF STATUS --------------------
		
DECLARE @MaxPT TINYINT, @MaxComm DECIMAL(9,8)
SELECT @MaxPT = MaxPT FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = 21 AND SettingType = 1
SELECT @MaxComm = MaxDiscount FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = 21 AND SettingType = 3

DECLARE @DefaultLossLimit_15 MONEY
DECLARE @DefaultLossLimit_4 MONEY

SELECT @DefaultLossLimit_15 = ISNULL(DefaultLossLimit,0)
FROM LossLimit_GlobalSetting WITH (NOLOCK)
WHERE ProductId = 21 AND ExchangeId = 15


SELECT @DefaultLossLimit_4 = ISNULL(DefaultLossLimit,0)
FROM LossLimit_GlobalSetting WITH (NOLOCK)
WHERE ProductId = 21 AND ExchangeId = 4

--------------------------------------WinLossLimit-------------------------------------------------
--SuperLevel
/*
INSERT INTO CustWinLossLimit_Agent(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT custid, dest.tSportType, dest.tBetType	
	, CASE WHEN ci.SyncLiveCasino = 0 THEN 0 ELSE MaxWinLiveCasino END AS MaxWinLimit
	, @DefaultLossLimit AS MaxLossLimit 
	,CASE WHEN ci.SyncLiveCasino = 0 THEN 1 ELSE isAutoResetLiveCasino END AS IsAutoReset
FROM #SMATemp ci WITH(NOLOCK)	
	CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
WHERE ci.custid = @srecommend AND dest.SettingType = 6 
								
--Master Level
INSERT INTO CustWinLossLimit_Agent(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT ci.custid, dest.tSportType, dest.tBetType	
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
			WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
			ELSE 0 END AS MaxWinLimit
	
	,@DefaultLossLimit AS MaxLossLimit 
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
			WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
			ELSE 1 END AS IsAutoReset
FROM dbo.custInfo ci WITH(NOLOCK) -- master	
	INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.custid -- srecommend
	CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
WHERE ci.srecommend = @srecommend AND ci.roleid = 3 AND dest.SettingType = 6 
*/
--Agent Level
/*
INSERT INTO CustWinLossLimit_Agent(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT ci.custid, dest.tSportType, dest.tBetType	
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
			WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
			WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
			ELSE 0 END AS MaxWinLimit
	,CASE WHEN ci.srecommend = 15 THEN  @DefaultLossLimit_15 ELSE @DefaultLossLimit_4 END AS MaxLossLimit 
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
			WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
			WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
			ELSE 1 END AS IsAutoReset
FROM dbo.custInfo ci WITH(NOLOCK)
	INNER JOIN #SMATemp mi WITH (NOLOCK) ON ci.mrecommend = mi.custid	
	INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.custid
	CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
WHERE ci.roleid = 2 AND dest.SettingType = 6
*/
--Member Level
INSERT INTO CustWinLossLimit_Member(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT ci.custid, dest.tSportType, dest.tBetType	
	
	,CASE	
			--WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
			WHEN ai.SyncLiveCasino = 1 THEN ai.MaxWinLiveCasino 
			--WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
			--WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
			ELSE 0 END AS MaxWinLimit
	,CASE WHEN ci.srecommend = 15 THEN  @DefaultLossLimit_15 ELSE @DefaultLossLimit_4 END AS MaxLossLimit 
	,CASE	
			--WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
			WHEN ai.SyncLiveCasino = 1 THEN ai.isAutoResetLiveCasino 
			--WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
			--WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
			ELSE 1 END AS IsAutoReset
	
FROM dbo.custInfo ci WITH(NOLOCK)
	INNER JOIN #SMATemp ai WITH (NOLOCK) ON ci.recommend = ai.custid
	--INNER JOIN #SMATemp mi WITH (NOLOCK) ON ci.mrecommend = mi.custid	
	--INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.custid
	CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
WHERE ci.roleid = 1 AND dest.SettingType = 6  AND ci.CustID IN (19542865,19545984)

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
	,93
FROM dbo.CustSettingGame cs WITH(NOLOCK) 
	INNER JOIN dbo.custOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype
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
FROM dbo.CustSettingGame cs WITH(NOLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType

DECLARE @apos SMALLMONEY,
		@mpos SMALLMONEY

UPDATE cs
SET cs.MinPT = @MaxPT
FROM dbo.CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
WHERE MinPT > @MaxPT		

UPDATE cs
SET @apos = CASE WHEN cs.AgentPT > @MaxPT THEN @MaxPT ELSE cs.AgentPT END,
	cs.AgentPT = @apos,
	@mpos = CASE WHEN @apos + cs.MasterPT > @MaxPT THEN @MaxPT- @apos ELSE cs.MasterPT END,
	cs.MasterPT = @mpos,
	cs.SuperPT = CASE WHEN @apos + @mpos + cs.SuperPT > @MaxPT THEN @MaxPT - @mpos -@apos ELSE cs.SuperPT END
FROM  CustPTSetting3rd_Member cs WITH(UPDLOCK,ROWLOCK) 
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
WHERE cs.SuperPT + cs.MasterPT + cs.AgentPT > @MaxPT
	
UPDATE cs
SET @apos = CASE WHEN cs.AgentPT > @MaxPT THEN @MaxPT ELSE cs.AgentPT END,
	cs.AgentPT = @apos,
	cs.MasterPT = CASE WHEN @apos + cs.MasterPT > @MaxPT THEN @MaxPT- @apos ELSE cs.MasterPT END		
FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
WHERE cs.MasterPT + cs.AgentPT > @MaxPT	AND roleid = 2

UPDATE cs
SET @mpos = CASE WHEN cs.MasterPT > @MaxPT THEN @MaxPT ELSE cs.MasterPT END,
	cs.MasterPT = @mpos,
	cs.SuperPT = CASE WHEN cs.SuperPT + @mpos > @MaxPT THEN @MaxPT - @mpos ELSE cs.SuperPT END 		
FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
WHERE cs.MasterPT + cs.SuperPT > @MaxPT	AND roleid = 3
	
UPDATE cs
SET cs.SuperPT = CASE WHEN cs.SuperPT > @MaxPT THEN @MaxPT ELSE cs.SuperPT END 		
FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
WHERE cs.SuperPT > @MaxPT	

--------------------------------------Commission Setting-------------------------------------------------		
--Agent Level
INSERT INTO dbo.CustDiscount3rd_Agent(CustID, SportType, BetType, Discount)
SELECT cs.custid, dest.tsporttype, dest.tbettype, 
		CASE	WHEN roleid = 4 THEN cs.sdiscount
				WHEN roleid = 3 THEN cs.adiscount
				WHEN roleid = 2 THEN cs.discount END
FROM dbo.CustSettingGame cs WITH(NOLOCK)
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	 
--Member Level
INSERT INTO dbo.CustDiscount3rd_Member(CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
SELECT cs.custid, dest.tsporttype, dest.tbettype, cs.PlayerDiscount, cs.discount, cs.adiscount, cs.sdiscount
FROM dbo.CustSettingGame cs WITH(NOLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType

--adjust commission Super = [0; 0.007]	
--correct for super level
IF EXISTS(	SELECT 1
			FROM dbo.CustDiscount3rd_Agent cs WITH(NOLOCK)
				INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
			WHERE cs.Discount > @MaxComm)
BEGIN
	UPDATE cs
	SET cs.Discount = @MaxComm
	FROM  CustDiscount3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
		INNER JOIN #SMATemp ci ON cs.CustID = ci.CustID
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	WHERE cs.Discount > @MaxComm
	
	UPDATE cs
	SET cs.SuperDiscount = CASE WHEN cs.SuperDiscount > @MaxComm THEN @MaxComm ELSE cs.SuperDiscount END,
		cs.MasterDiscount = CASE WHEN cs.MasterDiscount > cs.SuperDiscount THEN cs.SuperDiscount ELSE cs.MasterDiscount END,
		cs.AgentDiscount = CASE WHEN cs.AgentDiscount > cs.MasterDiscount THEN cs.MasterDiscount ELSE cs.AgentDiscount END,
		cs.PlayerDiscount = CASE WHEN cs.PlayerDiscount > cs.AgentDiscount THEN cs.AgentDiscount ELSE cs.PlayerDiscount END
	FROM dbo.CustDiscount3rd_Member cs WITH(UPDLOCK, ROWLOCK)
		INNER JOIN #MemberTemp ci ON cs.CustID = ci.CustID
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType		
	WHERE cs.SuperDiscount > @MaxComm 
		OR cs.MasterDiscount > cs.SuperDiscount 
		OR cs.AgentDiscount > cs.MasterDiscount 
		OR cs.PlayerDiscount > cs.AgentDiscount
	  
END		

DROP TABLE #SMATemp
DROP TABLE #MemberTemp
DROP TABLE #DestinationSportBetType		

