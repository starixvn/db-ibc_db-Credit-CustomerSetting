/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdDangerLevel]
	@CustList	VARCHAR(MAX) = '',
	@Enviroment VARCHAR(100) = 'PRO',
	@IncludeUUS BIT = 1,
	@ErrCode	INT = 0	OUTPUT,
	@ErrMsg		NVARCHAR(200) = '' OUTPUT	
AS
/*
	Created: 20211007@Johnson
	Task : Service update DangerLevel for saba performance[Redmine:#161351]
	DB: DBCUST/CUSTDB
	
	Revisions:
		- 20211007@Johnson: initial sp [redmine:#161351]
		- 20220119@Johnson: update DangerLevel (TB currency & Licensees' customers)	[redmine:#167686]
		- 20220524@Winfred: update DangerLevel IG128/SM88/SL88SW/LIVV88SW with All Currencies [redmine:#172982]
		- 20220607@Winfred: NAP CM - scan and update DangerLevel according to Winloss of Saba Basketball Sport [redmine:#173752]
		- 20220711@Tacy: update DangerLevel for Haifa, 789y site and USDT currency of Saba Basketball Sport [redmine:#175247]
		- 20220715@Tacy: update DangerLevel for (INH currency and Happy8/SM88/AEUG/368cash/365online site) or (IN currency and WINCLUB88 site) of Saba Basketball Sport [redmine:#175505]
		- 20220802@Tacy: Update Danger Level if Problem Customer Class [RedmineId: #175857]
		- 20220817@Tacy: scan and update DangerLevel according to Winloss of Saba Basketball Sport (Livv88sw site) [redmine:#176712]
		- 20220922@Tacy: NAP CM - Update flow for All sites - Basketball and Remove Dengerlevel 14, 15 [RedmineID: #178053]
		- 20221110@Tacy: LAP - Support Danger Level report, modify ActionID writelog [RedmineID: #179078]
		- 20221226@Tacy: NAP CM - Split 789y Site [RedmineID: #184879]
		- 20230622@Tacy: NAP CM - Saba Danger Level - list Zhifeng032 & ManbetX same danger category as Haifa site [RedmineID: #190161]

	Parameter's Explanation:		
		-@custList = '<Root>
					<r id="100" sport="1" parlay="0" winloss="1000"/>
					<r id="100" sport="1" parlay="1" winloss="-1000"/>
					<r id="101" sport="2" parlay="0" winloss="10000"/>
					</Root>'
		-@Enviroment = 'UAT/PRO'			
*/	
BEGIN
	SET NOCOUNT ON
	DECLARE @StartRun DATETIME, 
			@ScanDate DATETIME,
			@Duration INT--, @LogDataNew VARCHAR(500), @LogDataOld VARCHAR(500)

	SET @StartRun = GETDATE()
	SET @ScanDate = (SELECT MAX(CreatedDate) FROM CustDangerWinlossInfo WITH (NOLOCK))

	CREATE TABLE #tblCustWinloss (custid INT, sporttype SMALLINT, isParlay BIT, winloss MONEY)
	CREATE TABLE #tblCustDangerInfo (Custid INT PRIMARY KEY, Soccer TINYINT, Basketball TINYINT, WinlossSoccer MONEY, WinlossBasketball MONEY, UpdateSoccer BIT, UpdateBasketball BIT)
	CREATE TABLE #tblCustDangerOld (Custid INT PRIMARY KEY, DangerLevel BIGINT, Soccer TINYINT, Basketball TINYINT, IsManualSoccer BIT, IsManualBasketball BIT)
	CREATE TABLE #tblCustUpdate (Custid INT PRIMARY KEY, DangerLevel BIGINT, Soccer TINYINT, Basketball TINYINT, SoccerOld TINYINT, BasketballOld TINYINT, UpdateSoccer BIT, UpdateBasketball BIT, WinlossSoccer MONEY, WinlossBasketball MONEY)

	DECLARE @xml XML = CAST (@CustList as XML)
	DECLARE @batchNo INT
	
	INSERT INTO #tblCustWinloss (custid, sporttype, isParlay, winloss)
	SELECT t.c.value('@id[1]','int'),
		t.c.value('@sport[1]','int'),
		t.c.value('@parlay[1]','bit'),
		t.c.value('@winloss[1]','money')
	FROM @xml.nodes('Root/r')as t(c)
	
	SELECT @batchNo = MAX(batchNo) + 1 
	FROM CustDangerLevelInfo WITH(NOLOCK)

	SELECT @batchNo = CASE WHEN @batchNo < (MAX(batchNo) + 1) THEN MAX(batchNo) + 1 ELSE @batchNo END
	FROM CustDangerWinlossInfo WITH(NOLOCK)
	
	DELETE t
	FROM #tblCustWinloss t
		INNER JOIN custinfo ci WITH(NOLOCK) ON t.custid = ci.custid
	WHERE 1 = CASE WHEN @Enviroment = 'UAT' AND ci.currency <> 20 THEN 1
				WHEN @Enviroment = 'PRO' AND @IncludeUUS = 0 AND ci.currency = 20 THEN 1
				ELSE 0 END	
	
	SELECT @batchNo = ISNULL(@batchNo,1)
	
	INSERT INTO CustDangerWinlossInfo(Custid,
				SportType,
				IsParlay,
				Winloss,
				CreatedDate,
				BatchNo)
	SELECT Custid, SportType, IsParlay, Winloss, GETDATE(), @BatchNo
	FROM #tblCustWinloss t	

	IF @@ROWCOUNT = 0
		RETURN;
		
	;WITH T AS (
		SELECT custid,	
			 SUM(CASE WHEN sporttype = 1 AND isParlay = 0 THEN winloss ELSE 0 END) soccer
			,MAX(CASE WHEN sporttype = 1 AND isParlay = 0 THEN 1 ELSE 0 END) isSoccer
			--,SUM(CASE WHEN sporttype = 1 AND isParlay = 1 THEN winloss ELSE 0 END) soccerParlay
			--,MAX(CASE WHEN sporttype = 1 AND isParlay = 1 THEN 1 ELSE 0 END) isSoccerParlay
			,SUM(CASE WHEN sporttype = 2 AND isParlay = 0 THEN winloss ELSE 0 END) basketball
			,MAX(CASE WHEN sporttype = 2 AND isParlay = 0 THEN 1 ELSE 0 END) isBasketball
			--,SUM(CASE WHEN sporttype = 2 AND isParlay = 1 THEN winloss ELSE 0 END) basketballParlay
			--,MAX(CASE WHEN sporttype = 2 AND isParlay = 1 THEN 1 ELSE 0 END) isBasketballParlay
		FROM #tblCustWinloss t1
		GROUP BY custid
	)
	INSERT INTO #tblCustDangerInfo(custid,Soccer,Basketball,WinlossSoccer,WinlossBasketball,UpdateSoccer,UpdateBasketball)
	SELECT t.custid,
		CASE 
			WHEN sc.CustID IS NOT NULL THEN 13
			WHEN isSoccer=1 THEN
				CASE
					WHEN s.custid IS NOT NULL AND s.site IN ('IG128','SM88','SL88SW','LIVV88SW','365Online','SKY88','Sin88','One88')  THEN -- Flow C : 8 Licensees: IG128/SM88/SL88SW/LIVV88SW/365Online/SKY88/Sin88/One88
						--CASE WHEN soccer + soccerParlay < 50000 OR isSoccerParlay = 0 THEN
						CASE WHEN soccer <-250000						THEN 1
							 WHEN soccer <-200000 AND soccer >= -250000	THEN 2
							 WHEN soccer <-140000 AND soccer >= -200000	THEN 3
							 WHEN soccer <-120000 AND soccer >= -140000	THEN 4
							 WHEN soccer <-100000 AND soccer >= -120000	THEN 5
							 WHEN soccer <-80000  AND soccer >= -100000	THEN 6 
							 WHEN soccer <-60000  AND soccer >= -80000	THEN 7
							 WHEN soccer <-40000  AND soccer >= -60000	THEN 8
							 WHEN soccer < 0	  AND soccer >= -40000	THEN 9
							 WHEN soccer < 45000  AND soccer >=  0		THEN 10
							 WHEN soccer < 100000 AND soccer >=  45000	THEN 11
							 WHEN soccer < 200000 AND soccer >=  100000	THEN 12
							 WHEN Soccer >=200000						THEN 13 END
						--ELSE	
							--CASE WHEN isSoccerParlay = 1 AND Soccer + SoccerParlay < 150000 THEN 14 ELSE 15 END
						--END
					WHEN s.custid IS NOT NULL AND s.currency IN (4) THEN ---- Flow B : ALL Licensee & currency = TB
						--CASE WHEN soccer + soccerParlay < 50000 THEN
						CASE WHEN soccer <-300000						THEN 1
							 WHEN soccer <-250000 AND soccer >= -300000	THEN 2
							 WHEN soccer <-200000 AND soccer >= -250000	THEN 3
							 WHEN soccer <-140000 AND soccer >= -200000 THEN 4
							 WHEN soccer <-120000 AND soccer >= -140000 THEN 5
							 WHEN soccer <-100000 AND soccer >= -120000 THEN 6
							 WHEN soccer <-80000  AND soccer >= -100000 THEN 7 
							 WHEN soccer <-60000  AND soccer >= -80000	THEN 8
							 WHEN soccer <-40000  AND soccer >= -60000	THEN 9
							 WHEN soccer < 0	  AND soccer >= -40000	THEN 10
							 WHEN soccer < 30000  AND soccer >=  0		THEN 11
							 WHEN soccer < 50000  AND soccer >=  30000	THEN 12
							 WHEN Soccer >=50000						THEN 13 END
						--ELSE	
						--	CASE WHEN isSoccerParlay = 0 THEN 13
						--		--ELSE CASE WHEN Soccer +SoccerParlay < 100000 THEN 14								
						--		--		ELSE 15 END
						--		END
						--END 
						--ELSE CASE WHEN soccer + soccerParlay < 100000 THEN 
					ELSE
						CASE WHEN soccer <-200000									THEN 1
							 WHEN soccer <-140000	AND soccer >= -200000			THEN 2
							 WHEN soccer <-120000	AND soccer >= -140000			THEN 3
							 WHEN soccer <-100000	AND soccer >= -120000			THEN 4
							 WHEN soccer <-80000	AND soccer >= -100000			THEN 5
							 WHEN soccer <-60000	AND soccer >= -80000			THEN 6
							 WHEN soccer <-40000	AND soccer >= -60000			THEN 7
							 WHEN soccer < 100000	AND soccer >= -40000		THEN
								 CASE WHEN s.custid IS NULL THEN	-- Credit
									CASE WHEN soccer <-20000  AND soccer >= -40000	THEN 8
										 WHEN soccer < 0	  AND soccer >= -20000	THEN 9
										 WHEN soccer < 60000  AND soccer >=  0		THEN 10
																					ELSE 11 END
								 ELSE
									CASE WHEN soccer < 0	  AND soccer >= -40000	THEN 8
										 WHEN soccer < 60000  AND soccer >=	0		THEN 9 
																					ELSE 10 END
								 END
							 WHEN soccer < 150000 AND soccer >= 100000				THEN 11
							 WHEN soccer < 250000 AND soccer >= 150000				THEN 12
							 WHEN soccer >=250000									THEN 13 END
					END	
				--	CASE WHEN soccer + soccerParlay < 150000 THEN 14
				--		ELSE 15 END
				--END
			--END 
		--END	
		END	SoccerLevel,
		CASE 
			WHEN bb.CustID IS NOT NULL THEN 13
			WHEN isBasketball=1 THEN
				CASE
					WHEN (s.custid IS NOT NULL AND s.site in ('haifa','livv88sw','Zhifeng032','ManbetX'))
						OR (s.custid IS NULL AND ss.SiteLabel='789y')		
						OR s.currency=96											THEN -- Flow B : Haifa, 789y, Livv88sw, Zhifeng032, ManbetX site and USDT currency
							--CASE WHEN basketball + basketballParlay < 8000 OR isbasketballParlay = 0 THEN
							CASE 
								WHEN basketball <-140000								THEN 1
								WHEN basketball <-110000	AND basketball >=-140000	THEN 2
								WHEN basketball <-80000		AND basketball >=-110000	THEN 3
								WHEN basketball <-60000		AND basketball >=-80000		THEN 4
								WHEN basketball <-35000		AND basketball >=-60000		THEN 5
								WHEN basketball <-20000		AND basketball >=-35000		THEN 6 
								WHEN basketball <-10000		AND basketball >=-20000		THEN 7
								WHEN basketball <-5000		AND basketball >=-10000		THEN 8
								WHEN basketball < 0			AND basketball >=-5000		THEN 9
								WHEN basketball < 1500		AND basketball >= 0			THEN 10
								WHEN basketball < 3000		AND basketball >= 1500		THEN 11
								WHEN basketball < 8000		AND basketball >= 3000		THEN 12
								WHEN basketball >=8000									THEN 13 END
							--ELSE	
							--	CASE WHEN isbasketballParlay = 1 AND basketball + basketballParlay < 25000 THEN 14 ELSE 15 END
							--END
					WHEN s.custid IS NOT NULL AND ((s.site IN ('Happy8','SM88','AEUG','368cash','365online') AND s.currency=51) 
						OR (s.site IN ('WINCLUB88') AND s.currency=15))							THEN	-- Flow C: (INH currency and Happy8/SM88/AEUG/368cash/365online site) or (IN currency and WINCLUB88 site)
						--CASE WHEN basketball + basketballParlay < 25000 OR isbasketballParlay = 0 THEN
							CASE 
								WHEN basketball <-140000								THEN 1
								WHEN basketball <-110000	AND basketball >=-140000	THEN 2
								WHEN basketball <-80000		AND basketball >=-110000	THEN 3
								WHEN basketball <-60000		AND basketball >=-80000		THEN 4
								WHEN basketball <-35000		AND basketball >=-60000		THEN 5
								WHEN basketball <-20000		AND basketball >=-35000		THEN 6 
								WHEN basketball <-10000		AND basketball >=-20000		THEN 7
								WHEN basketball <-5000		AND basketball >=-10000		THEN 8
								WHEN basketball < 0			AND basketball >=-5000		THEN 9
								WHEN basketball < 5000		AND basketball >= 0			THEN 10
								WHEN basketball < 10000		AND basketball >= 5000		THEN 11
								WHEN basketball < 30000		AND basketball >= 10000		THEN 12
								WHEN basketball >=30000									THEN 13 END
						--ELSE	
						--	CASE WHEN isbasketballParlay = 1 AND basketball + basketballParlay < 50000 THEN 14 ELSE 15 END
						--END 
					ELSE
						--CASE WHEN (basketball + basketballParlay < 50000 OR isbasketballParlay = 0) THEN 
							CASE 
								WHEN basketball <-140000								THEN 1
								WHEN basketball <-120000	AND basketball >=-140000	THEN 2
								WHEN basketball <-100000	AND basketball >=-120000	THEN 3
								WHEN basketball <-80000		AND basketball >=-100000	THEN 4
								WHEN basketball <-60000		AND basketball >=-80000		THEN 5
								WHEN basketball <-40000		AND basketball >=-60000		THEN 6
								WHEN basketball <-20000		AND basketball >=-40000		THEN 7
								WHEN basketball < 0			AND basketball >=-20000		THEN 8
								WHEN basketball < 10000		AND basketball >= 0			THEN 9
								WHEN basketball < 20000		AND basketball >= 10000		THEN 10
								WHEN basketball < 30000		AND basketball >= 20000		THEN 11
								WHEN basketball < 40000		AND basketball >= 30000		THEN 12
								WHEN basketball >=40000									THEN 13 END
					END
				--ELSE
				--	CASE WHEN isbasketballParlay = 1 AND basketball + basketballParlay < 75000 THEN 14 ELSE 15 END
				--END
			END	BasketballLevel,
		Soccer as WinlossSoccer,
		Basketball as WinlossBasketball,
		CASE WHEN sc.CustID IS NOT NULL THEN 1 ELSE IsSoccer END UpdateSoccer,
		CASE WHEN bb.CustID IS NOT NULL THEN 1 ELSE IsBasketball END UpdateBasketball
	FROM T
		INNER JOIN Customer c WITH(NOLOCK) ON c.custid = t.custid
		INNER JOIN Site ss WITH(NOLOCK) ON ss.site=c.site
		LEFT JOIN Dep_custsuper s WITH(NOLOCK) ON c.srecommend = s.custid
		LEFT JOIN CustDangerJobExclusion sc WITH (NOLOCK) ON sc.custid=t.custid AND sc.SportType=1
		LEFT JOIN CustDangerJobExclusion bb WITH (NOLOCK) ON bb.custid=t.custid AND bb.SportType=2
			
	--PA List
	INSERT INTO #tblCustDangerInfo(custid,Soccer,Basketball,WinlossSoccer,WinlossBasketball,UpdateSoccer,UpdateBasketball)
	SELECT DISTINCT 
		  cd.CustID
		, CASE WHEN sc.CustID IS NOT NULL THEN 13 END SoccerLevel
		, CASE WHEN bb.CustID IS NOT NULL THEN 13 END BasketballLevel
		, NULL AS WinlossSoccer
		, NULL AS WinlossBasketball
		, CASE WHEN sc.CustID IS NOT NULL THEN 1 ELSE 0 END UpdateSoccer
		, CASE WHEN bb.CustID IS NOT NULL THEN 1 ELSE 0 END UpdateBasketball
	FROM CustDangerJobExclusion cd WITH (NOLOCK)
		OUTER APPLY (SELECT TOP (1) sc.CustID FROM CustDangerJobExclusion sc WITH (NOLOCK) WHERE sc.custid=cd.custid AND sc.SportType=1 AND sc.CreateDate>=@ScanDate) sc
		OUTER APPLY (SELECT TOP (1) bb.CustID FROM CustDangerJobExclusion bb WITH (NOLOCK) WHERE bb.custid=cd.custid AND bb.SportType=2 AND bb.CreateDate>=@ScanDate) bb
	WHERE cd.CreateDate>=@ScanDate 
		AND NOT EXISTS (SELECT 1 FROM #tblCustDangerInfo WHERE cd.CustID=Custid)

	INSERT INTO #tblCustDangerOld(custid,DangerLevel,Soccer,Basketball,IsManualSoccer,IsManualBasketball)
	SELECT custid, ISNULL(DangerLevel,0), soccer, basketball, IsManualSoccer, IsManualBasketball
	FROM custinfo c WITH(NOLOCK)
		CROSS APPLY dbo.f_GetDangerLevelInfo(ISNULL(DangerLevel,0)) t
	WHERE custid IN (SELECT custid FROM #tblCustDangerInfo)

	INSERT INTO #tblCustUpdate(custid, Soccer, Basketball, UpdateSoccer, UpdateBasketball, DangerLevel, SoccerOld, BasketballOld, WinlossSoccer, WinlossBasketball)
	SELECT t1.custid, t1.Soccer , t1.Basketball,
		CASE WHEN IsManualSoccer = 0 AND UpdateSoccer = 1 AND t1.Soccer <> t2.soccer THEN 1 ELSE 0 END as UpdateSoccer,
		CASE WHEN IsManualBasketball = 0 AND UpdateBasketball = 1 AND t1.Basketball <> t2.Basketball THEN 1 ELSE 0 END as UpdateBasketball,
		t2.DangerLevel,
		t2.soccer as SoccerOld,
		t2.basketball as BasketballOld,
		t1.WinlossSoccer,
		t1.WinlossBasketball		
	FROM #tblCustDangerInfo t1
		INNER JOIN #tblCustDangerOld t2 ON t1.custid = t2.Custid
	WHERE (IsManualSoccer = 0 AND UpdateSoccer = 1 AND t1.Soccer <> t2.soccer)
		OR (IsManualBasketball = 0 AND UpdateBasketball = 1 AND t1.Basketball <> t2.Basketball)

	DECLARE @CustUpdate VARCHAR(MAX) 
	
	SELECT @CustUpdate = CAST((
		SELECT custid as '@id',
			dbo.f_GenerateDangerLevelInfo(DangerLevel,Soccer,Basketball,UpdateSoccer,UpdateBasketball) as '@value'
		FROM #tblCustUpdate
		FOR XML PATH('r'),ROOT('Root')
	) AS VARCHAR(MAX))
	
	--update dangerlevel 
	DECLARE @ErrMsgLog VARCHAR(1000)
	
	BEGIN TRY	
		EXEC Acc_CustomerInfo_Execrep_03 @CustList = @CustUpdate,										
										@mode = 'SabaDangerLevel'	
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 100,
			@ErrMsgLog = ERROR_MESSAGE(),
			@ErrMsg = 'Update unsuccessfully'		
	END CATCH 

	--logging
	INSERT INTO CustDangerLevelInfo(Custid,
									BatchNo,
									Soccer,
									Basketball,
									UpdateSoccer,
									UpdateBasketball,
									Status,
									Description,		
									CreatedDate)
	SELECT custid, @BatchNo, Soccer, Basketball, UpdateSoccer, UpdateBasketball, 
		CASE WHEN @ErrCode > 0 THEN 'fail' ELSE 'completed' END status,
		@ErrMsgLog as Description,
		GETDATE() as CreatedDate
	FROM #tblCustUpdate 

	IF @ErrCode > 0
		RETURN;
	
	DECLARE @LogSoccer		VARCHAR(MAX),	--1191
			@LogBasketball	VARCHAR(MAX)	--1192
	
	SELECT @LogSoccer = CAST((SELECT t.custid	as '@id',
									'0'			as '@sport',
									soccer		as '@newlevel',
									SoccerOld	as '@oldlevel',
									CASE WHEN WinlossSoccer IS NULL THEN 'NULL' ELSE CAST(WinlossSoccer AS VARCHAR) END  as '@wl',
									CASE WHEN cd.CustID IS NOT NULL THEN '1' ELSE '0' END as '@IsPA'
								FROM #tblCustUpdate t		
									OUTER APPLY (SELECT TOP (1) CustID FROM CustDangerJobExclusion cd WITH (NOLOCK)
												 WHERE cd.CustID=t.Custid AND cd.CreateDate>=@ScanDate) cd
								WHERE UpdateSoccer=1
								FOR XML PATH('r'), ROOT('Root')
							) AS VARCHAR(MAX)),
	@LogBasketball = CAST((SELECT t.custid	as '@id',
								'1'			as '@sport',
								Basketball		as '@newlevel',
								BasketballOld	as '@oldlevel',
								CASE WHEN WinlossBasketball IS NULL THEN 'NULL' ELSE CAST(WinlossBasketball AS VARCHAR) END  as '@wl',
								CASE WHEN cd.CustID IS NOT NULL THEN '1' ELSE '0' END as '@IsPA'
							FROM #tblCustUpdate t		
								OUTER APPLY (SELECT TOP (1) CustID FROM CustDangerJobExclusion cd WITH (NOLOCK)
												WHERE cd.CustID=t.Custid AND cd.CreateDate>=@ScanDate) cd
							WHERE UpdateBasketball=1
							FOR XML PATH('r'), ROOT('Root')
						) AS VARCHAR(MAX))
	
	SELECT @Duration = DATEDIFF (MILLISECOND, @startRun, GETDATE())
	
	BEGIN TRY
		-- Log Soccer
		IF @LogSoccer IS NOT NULL OR @LogSoccer<>''
		BEGIN
			EXEC DBLOG.bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
				@UserId		= 10278938,	--StarixIT	
				@ActionId	= 1191,
				@Log		= @LogSoccer,		
				@IP			= '125.227.140.97',	
				@Duration	= @Duration

			--LAP
			EXEC DBLOG.bodb_CustomerLog.dbo.Lrf_WriteLog_UserLog_UserControl_Multiple
				@LogData = @LogSoccer,	
				@ActionID = 1191,
				@Duration = @Duration,
				@UserID	= 10278938
		END

		--Log Basketball
		IF @LogBasketball IS NOT NULL OR @LogBasketball<>''
		BEGIN
			EXEC DBLOG.bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
				@UserId		= 10278938,	--StarixIT	
				@ActionId	= 1192,
				@Log		= @LogBasketball,		
				@IP			= '125.227.140.97',	
				@Duration	= @Duration

			EXEC DBLOG.bodb_CustomerLog.dbo.Lrf_WriteLog_UserLog_UserControl_Multiple
				@LogData = @LogBasketball,	
				@ActionID = 1192,
				@Duration = @Duration,
				@UserID	= 10278938
		END
	END TRY
	BEGIN CATCH
		-- Log Soccer
		IF @LogSoccer IS NOT NULL OR @LogSoccer<>''
		BEGIN
			EXEC DBLOG.bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
				@UserId		= 10278938,	--StarixIT	
				@ActionId	= 1191,
				@Log		= @LogSoccer,		
				@IP			= '125.227.140.97',	
				@Duration	= @Duration

			--LAP
			EXEC DBLOG.bodb_CustomerLog.dbo.Lrf_WriteLog_UserLog_UserControl_Multiple
				@LogData = @LogSoccer,	
				@ActionID = 1191,
				@Duration = @Duration,
				@UserID	= 10278938
		END

		--Log Basketball
		IF @LogBasketball IS NOT NULL OR @LogBasketball<>''
		BEGIN
			EXEC DBLOG.bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
				@UserId		= 10278938,	--StarixIT	
				@ActionId	= 1192,
				@Log		= @LogBasketball,		
				@IP			= '125.227.140.97',	
				@Duration	= @Duration

			EXEC DBLOG.bodb_CustomerLog.dbo.Lrf_WriteLog_UserLog_UserControl_Multiple
				@LogData = @LogBasketball,	
				@ActionID = 1192,
				@Duration = @Duration,
				@UserID	= 10278938
		END
	END CATCH

	DROP TABLE #tblCustDangerInfo
	DROP TABLE #tblCustDangerOld
	DROP TABLE #tblCustWinloss
	DROP TABLE #tblCustUpdate
END	
