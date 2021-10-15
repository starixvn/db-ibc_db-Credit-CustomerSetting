/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdDangerLevel]
	@CustList	VARCHAR(MAX) = '',		
	@ErrCode	INT = 0	OUTPUT,
	@ErrMsg		NVARCHAR(200) = '' OUTPUT	
AS
SET NOCOUNT ON
/*
	Created: 20211007@Johnson
	Task : Service update DangerLevel for saba performance[Redmine:#161351]
	DB: DBCUST/CUSTDB
	
	Revisions:
		- 20211007@Johnson: initial sp [redmine:#161351]
	
	Parameter's Explanation:		
		-@custList = '<Root>
					<r id="100" sport="1" parlay="0" winloss="1000"/>
					<r id="100" sport="1" parlay="1" winloss="-1000"/>
					<r id="101" sport="2" parlay="0" winloss="10000"/>
					</Root>'
*/	
BEGIN
	SET NOCOUNT ON
	DECLARE @StartRun DATETIME, @Duration INT, @LogDataNew VARCHAR(500), @LogDataOld VARCHAR(500)

	SET @startRun = GETDATE()


	CREATE TABLE #tblCustWinloss (custid INT, sporttype SMALLINT, isParlay BIT, winloss MONEY)
	CREATE TABLE #tblCustDangerInfo (Custid INT PRIMARY KEY, Soccer TINYINT, Basketball TINYINT, WinlossSoccer MONEY, WinlossBasketball MONEY, UpdateSoccer BIT, UpdateBasketball BIT)
	CREATE TABLE #tblCustDangerOld (Custid INT PRIMARY KEY, Soccer TINYINT, Basketball TINYINT, IsManualSoccer BIT, IsManualBasketball BIT)
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
	FROM CustDangerWinlossInfo WITH(NOLOCK)
	
	INSERT INTO CustDangerWinlossInfo(Custid,
				SportType,
				IsParlay,
				Winloss,
				CreatedDate,
				BatchNo)
	SELECT Custid, SportType, IsParlay, Winloss, GETDATE(), @BatchNo
	FROM #tblCustWinloss
	
	;WITH T AS (
	SELECT custid,	
		SUM(CASE WHEN sporttype = 1 AND isParlay = 0 THEN winloss ELSE 0 END) soccer,
		MAX(CASE WHEN sporttype = 1 THEN 1 ELSE 0 END) isSoccer,
		SUM(CASE WHEN sporttype = 1 AND isParlay = 1 THEN winloss ELSE 0 END) soccerParlay,
		MAX(CASE WHEN sporttype = 1 AND isParlay = 1 THEN 1 ELSE 0 END) isSoccerParlay,
		SUM(CASE WHEN sporttype = 2 AND isParlay = 0 THEN winloss ELSE 0 END) basketball,
		MAX(CASE WHEN sporttype = 2 THEN 1 ELSE 0 END) isBasketball
	FROM #tblCustWinloss t1
	GROUP BY custid
	)
	INSERT INTO #tblCustDangerInfo(custid,Soccer,Basketball,WinlossSoccer,WinlossBasketball,UpdateSoccer,UpdateBasketball)
	SELECT custid,
		CASE WHEN soccer + soccerParlay < 100000 THEN
				CASE WHEN soccer < -200000 THEN 1
					WHEN soccer <-140000 AND soccer >= -200000 THEN 2
					WHEN soccer <-120000 AND soccer >= -140000 THEN 3
					WHEN soccer <-100000 AND soccer >= -120000 THEN 4
					WHEN soccer <-80000 AND soccer >= -100000 THEN 5
					WHEN soccer <-60000 AND soccer >= -80000 THEN 6
					WHEN soccer <-40000 AND soccer >= -60000 THEN 7 
				ELSE
					CASE WHEN s.custid IS NULL THEN	
						CASE WHEN soccer <-20000 AND soccer >= -40000 THEN 8
							WHEN soccer <0 AND soccer >= -20000 THEN 9
							WHEN soccer <60000 AND soccer >= 0 THEN 10
							ELSE 11 END
						ELSE 
						CASE WHEN soccer <0 AND soccer >= -40000 THEN 8
							WHEN soccer <60000 AND soccer >= 0 THEN 9 
							ELSE 10 END
					END	
				END					
			ELSE 	
				CASE WHEN isSoccerParlay = 0 THEN
					CASE WHEN Soccer < 150000 THEN 11
						WHEN soccer < 250000 AND soccer >= 150000 THEN 12
						ELSE 13 END
					ELSE 
					CASE WHEN soccer + soccerParlay < 150000 THEN 14
						ELSE 15 END
				END
			END level1,
		CASE WHEN basketball < -200000 THEN 1
			WHEN basketball < -140000 AND basketball >= -200000 THEN 2
			WHEN basketball < -100000 AND basketball >= -140000 THEN 3
			WHEN basketball < -80000 AND basketball >= -100000 THEN 4
			WHEN basketball < -60000 AND basketball >= -80000 THEN 5
			WHEN basketball < -40000 AND basketball >= -60000 THEN 6
			WHEN basketball < -20000 AND basketball >= -40000 THEN 7
			WHEN basketball < 0 AND basketball >= -20000 THEN 8
			WHEN basketball < 20000 AND basketball >= 0 THEN 9
			WHEN basketball < 40000 AND basketball >= 20000 THEN 10
			WHEN basketball < 60000 AND basketball >= 40000 THEN 11
			WHEN basketball < 100000 AND basketball >= 60000 THEN 12
			ELSE 13 END as Level2,
		Soccer + SoccerParlay as WinlossSoccer,
		Basketball as WinlossBasketball,
		IsSoccer,
		IsBasketball
	FROM T
		INNER JOIN custinfo ci WITH(NOLOCK) ON t.custid = ci.custid
		LEFT JOIN Dep_custsuper s WITH(NOLOCK) ON ci.srecommend = s.custid
	
	INSERT INTO #tblCustDangerOld(custid,DangerLevel,Soccer,Basketball,IsManualSoccer,IsManualBasketball)
	SELECT custid, DangerLevel, soccer, basketball, IsManualSoccer, IsManualBasketball
	FROM custifno c WITH(NOLOCK)
		CROSS APPLY dbo.f_GetDangerLevelInfo(DangerLevel) t
	WHERE custid IN (SELECT custid FROM #tblCustDangerInfo)
	
	INSERT INTO #tblCustUpdate(custid, Soccer, Basketball, UpdateSoccer, UpdateBasketball, DangerLevel, OldSoccer, OldBasketball, WinlossSoccer, WinlossBasketball)
	SELECT t1.custid, t1.Level1 as Soccer, t1.Level2 as Basketball,
		CASE WHEN IsManualSoccer = 0 AND IsSoccer = 1 AND t1.Level1 <> t2.soccer THEN 1 ELSE 0 END as UpdateSoccer,
		CASE WHEN IsManualBasketball = 0 AND IsBasketball = 1 AND t1.level2 <> t2.Basketball THEN 1 ELSE 0 END as UpdateBasketball,
		t2.DangerLevel,
		t2.soccer as OldSoccer,
		t2.basketball as OldBasketball,
		t1.WinlossSoccer,
		t1.WinlossBasketball		
	FROM #tblCustDangerInfo t1
		INNER JOIN #tblCustDangerOld t2 ON t1.custid = t2.Custid
	WHERE (IsManualSoccer = 0 AND IsSoccer = 1 AND t1.Level1 <> t2.soccer)
		OR (IsManualBasketball = 0 AND IsBasketball = 1 AND t1.level2 <> t2.Basketball)
	
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
	
	DECLARE @Log VARCHAR(MAX)
	
	SELECT @Log = CAST((
		SELECT custid as '@id',
			soccer as '@s',
			basketball as '@b',
			UpdateSoccer as '@us',
			UpdateBasketball as '@ub',
			OldSoccer as '@os',
			OldBasketball as '@ob',
			WinlossSoccer as '@wls',
			WinlossBasketball as '@wlb'
		FROM #tblCustUpdate t			
		FOR XML PATH('r'), ROOT('Root')
	) AS VARCHAR(MAX))	
	
	SELECT @Duration = DATEDIFF (MILLISECOND, @startRun, GETDATE())
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
			@UserId		= 10278938,	--StarixIT	
			@ActionId	= 1187,
			@Log		= @Log,		
			@IP			= '125.227.140.97',	
			@Duration	= @Duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
			@UserId		= 10278938,	--StarixIT
			@ActionId	= 1187,
			@Log		= @Log,		
			@IP			= '125.227.140.97',	
			@Duration	= @Duration
	END CATCH
	
	DROP TABLE #tblCustDangerInfo
	DROP TABLE #tblCustDangerOld
	DROP TABLE #tblCustWinloss
	DROP TABLE #tblCustUpdate
END	