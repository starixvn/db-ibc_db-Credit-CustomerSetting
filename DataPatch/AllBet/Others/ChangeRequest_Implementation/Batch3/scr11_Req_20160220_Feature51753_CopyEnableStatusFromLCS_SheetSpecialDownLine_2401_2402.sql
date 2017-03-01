/*
	Created: Helen	
	Task: Initialize Product Status of AllBet for Credit customers
	DB: DBCUST/CustDB
	Date: 20161229
*/ 
ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_09]
	@Custid INT
	,@roleid TINYINT
	,@srecommend INT
	,@mrecommend INT	
	,@target VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON
	
	IF (@target = 'REPLICATED' AND @@SERVERNAME = 'DBCUST') RETURN	-- run at all replicated servers
	IF (@target = 'DBCUST' AND @@SERVERNAME <> 'DBCUST') RETURN -- run at dbtrans only
	
	IF NOT (dbo.f_CheckRepTable('Custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustProductStatus') = 1
	   AND dbo.f_CheckRepTable('ProductSettingDetail') = 1
	   AND dbo.f_CheckRepTable('ProductStatusProfile') = 1
	   )
		RETURN
	
	
	/*******************************CUST PRODUCT STATUS TABLE*******************************/	
	CREATE TABLE #cust_tmp_result (Custid INT PRIMARY KEY,DisableLiveCasino BIT)
	
	DECLARE @xmlDisable_0 XML
	
	SET @xmlDisable_0 =(
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
	-- From excel file, they all Follow LC 
	IF @roleid = 4
	BEGIN
		INSERT INTO #cust_tmp_result (Custid,DisableLiveCasino)
		SELECT ci.custid , ci.DisableLiveCasino
		FROM custInfo CI WITH (NOLOCK)
		WHERE CI.srecommend = @Custid AND ci.SyncLiveCasino = 1  AND roleid IN (1,2,3)
	
		UPDATE cs
			SET bitmapIsDisabled =  CASE WHEN ci.DisableLiveCasino = 0 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 6, 0)
										 ELSE bitmapIsDisabled 
									END
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #cust_tmp_result ci WITH(NOLOCK) ON cs.CustID = ci.CustID
		
		UPDATE cs
			SET bitmapIsDisabled =  CASE WHEN ci.DisableLiveCasino = 0 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlDisable_0)))
										 ELSE bitmapIsDisabled 
									END
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN custInfo CI WITH (NOLOCK) ON cs.CustID = ci.custid
		WHERE cs.CustID = @srecommend	
		
	END
	ELSE IF @roleid = 3
	BEGIN
		INSERT INTO #cust_tmp_result (Custid,DisableLiveCasino)
		SELECT ci.custid , ci.DisableLiveCasino
		FROM custInfo CI WITH (NOLOCK)
		WHERE CI.mrecommend = @Custid AND ci.SyncLiveCasino = 1 AND roleid IN (1,2,3)
		
		UPDATE cs
		SET bitmapIsDisabled = CASE WHEN ci.DisableLiveCasino = 0 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 6, 0)
										 ELSE bitmapIsDisabled 
									END
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #cust_tmp_result ci WITH(NOLOCK) ON cs.CustID = ci.CustID
		
		UPDATE cs
			SET bitmapIsDisabled =  CASE WHEN ci.DisableLiveCasino = 0 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlDisable_0)))
										 ELSE bitmapIsDisabled 
									END
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN custInfo CI WITH (NOLOCK) ON cs.CustID = ci.custid
		WHERE cs.CustID = @srecommend	

	END
	ELSE IF @roleid = 2
	BEGIN
		INSERT INTO #cust_tmp_result (Custid,DisableLiveCasino)
		SELECT ci.custid , ci.DisableLiveCasino
		FROM custInfo CI WITH (NOLOCK)
		WHERE (CI.recommend = @Custid  OR ci.custid IN (@mrecommend)) AND ci.SyncLiveCasino = 1 AND roleid IN (1,2,3)
		
		UPDATE cs
		SET bitmapIsDisabled =CASE WHEN ci.DisableLiveCasino = 0 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 6, 0)
										 ELSE bitmapIsDisabled 
									END
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #cust_tmp_result ci WITH(NOLOCK) ON cs.CustID = ci.CustID
		
		UPDATE cs
			SET bitmapIsDisabled =  CASE WHEN ci.DisableLiveCasino = 0 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlDisable_0)))
										 ELSE bitmapIsDisabled 
									END
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN custInfo CI WITH (NOLOCK) ON cs.CustID = ci.custid
		WHERE cs.CustID = @srecommend	
	END
	
	DROP TABLE #cust_tmp_result
END
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS (DB04x/DB05x/DB06/DBTP) -----
--------------------------------------------------------------------------------------
/* LevelApplied: 
(1,'Super Only'),
(2,'Master Only'),
(4, 'Super,master,Agent,Member'),
(5,'Super,Master only'),
(6,'Agent only')
*/

CREATE TABLE #cust_tmp (username VARCHAR(100),IsFollowLC BIT, LevelApplied SMALLINT)
INSERT INTO #cust_tmp (username,IsFollowLC,LevelApplied)
VALUES
('S32KK',1,1),
('M999RM',0,2),
('M999SD',0,0),
('M9999S',0,0),
('S999S',0,0),
('99HK',0,0),
('PHRM',1,1),
('MPHSD',1,1),
('SHJ',1,1),
('ywrm',1,1),
('TEG',1,4),
('SGS',1,4),
('SGAR',1,4),
('THR',1,4),
('TEK',1,4),
('TED',1,4),
('THH',1,4),
('THS',1,4),
('M789H',0,2),
('M96RM',1,2),
('S96h',1,1),
('KHBH',1,1),
('KM',1,1),
('KH',1,1),
('KR',1,1),
('KS',1,1),
('KT',1,1),
('KRC',1,1),
('KSD',1,1),
('KMM',1,1),
('KRR',1,1),
('KMA',1,1),
('KHH',1,1),
('KHK',1,1),
('KAR',1,1),
('KBR',1,1),
('KCR',1,1),
('KAM',1,1),
('KMAM',1,1),
('KHAH',1,1),
('M28RMB',1,1),
('M28H',1,1),
('CJEU',1,4),
('MPTUS',1,1),
('MPTRMB',1,1),
('MPPU',1,1),
('M26ARMB',1,1),
('M26RM',1,1),
('M26SD',1,1),
('S26H',1,1),
('SVP',1,4),
('SVE',1,4),
('SVM',1,4),
('SVS',1,4),
('SVH',1,4),
('SVUS',1,4),
('SCS',1,1),
('SCSM',1,1),
('SCH',1,1),
('SCAH',1,1),
('SCBH',1,1),
('SCHI',1,1),
('HIU',1,1),
('HAH',1,1),
('HIC',1,1),
('69SD',1,4),
('S69SD',1,4),
('S69RM',1,4),
('S7RM',1,4),
('M69U',1,4),
('M69H',1,4),
('S69H',1,4),
('S69E',1,4),
('S69BP',1,4),
('S69HD',1,4),
('S69M',1,4),
('S69G',1,4),
('S56ARM',1,1),
('S56BRM',1,1),
('S56CRM',1,1),
('S56H',1,1),
('S56AH',1,1),
('S56CH',1,1),
('S56DH',1,1),
('S56HH',1,1),
('S56HK',1,1),
('S56T',1,1),
('S56QH',1,1),
('S56KK',1,1),
('S56SD',1,1),
('S56AC',1,1),
('S56AD',1,1),
('S56US',1,1),
('S56AU',1,1),
('S56BU',1,1),
('S56A',1,1),
('HK06',1,1),
('S56AE',1,1),
('S56CU',1,1),
('S56DU',1,1),
('S56ASD',1,1),
('HK09',1,1),
('S56AF',1,1),
('S49R',0,1),
('S3AAR',1,1),
('S3AK',1,1),
('S3AG',1,1),
('S88US',1,4),
('SOGO',1,4),
('SOGA',1,4),
('SHSD',1,4),
('SHRMB',1,4),
('SHTB',1,4),
('SHHK',1,4),
('SHUS',1,4),
('hhm',1,4),
('SHDK',1,4),
('SHU',1,4),
('SHHK1',1,4),
('SHR',1,4),
('SHR1',1,4),
('SHHK3',1,4),
('shhk5',1,4),
('SHR3',1,4),
('shhk6',1,4),
('SHR5',1,4),
('sh8',1,4),
('SHHK9',1,4),
('SHHK8',1,4),
('HHK1',1,4),
('HHK10',1,4),
('HHK2',1,4),
('HHK3',1,4),
('HHR',1,4),
('BHJ',1,4),
('CFT',1,4),
('TT',1,4),
('TTA',1,4),
('TTB',1,4),
('S222H',1,1),
('S222NH',1,1),
('M222M',1,1),
('2ZH',1,1),
('2EU',1,1),
('S222X',1,1),
('2CR',1,1),
('2CT',1,1),
('2CK',1,1),
('2BP',1,1),
('2UA',1,1),
('2UB',1,1),
('2RA',1,1),
('2RB',1,1),
('A688U',1,1),
('S688H',1,1),
('S688T',1,1),
('LLR',1,1),
('A68US',1,1),
('SB8R',1,5),
('MKYM',1,1),
('M8H',1,1),
('MTRU',1,4),
('MTRE',1,4),
('S2H',1,1),
('SRMB',1,1),
('SRRH',1,1),
('SRR',1,1),
('SRRR',1,1),
('SRUS',1,1),
('SRUN',1,1),
('JAA',1,4),
('JAH',1,4),
('JAS',1,4),
('JAHA',1,4),
('JAU',1,4),
('JARWRONG',1,4),
('JAR',1,4),
('JAHE',1,4),
('M99RMB',1,1),
('S99R',1,1),
('S99HKD',1,1),
('S99RMB',1,1),
('S99U',1,1),
('S99E',1,1),
('FN1',1,1),
('FN2',1,1),
('FN3',1,1),
('FN4',1,1),
('FN5',1,1),
('FN6',1,1),
('FN7',1,1),
('FN8',1,1),
('FN9',1,1),
('FN10',1,1),
('NK1',1,1),
('NK2',1,1),
('NK3',1,1),
('NK4',1,1),
('NK5',1,1),
('NK6',1,1),
('NK7',1,1),
('NK8',1,1),
('NK9',1,1),
('NK10',1,1),
('G33M',1,1),
('G99MK',1,1),
('GMK9',1,1),
('FN11',1,1),
('FN12',1,1),
('GMK7',1,1),
('GMK8',1,1),
('s45m',1,1),
('S45AH',1,1),
('S45AM',1,1),
('AHW',1,4),
('S41K',1,1),
('S41S',1,1),
('S41M',1,1),
('S41H',1,1),
('S43S',1,1),
('S43H',1,1),
('KMK',1,4),
('HPL',1,4),
('KA',1,4),
('SX13',1,4),
('JS',1,1),
('JS1',1,1),
('JS2',1,1),
('SFH',1,1),
('JS3',1,1),
('JU',1,1),
('SJS',1,1),
('SFHA',1,1),
('JS9',1,1),
('JSA',1,1),
('JSC',1,1),
('JSD',1,1),
('JSH',1,1),
('JSK',1,1),
('JR',1,1),
('JRA',1,1),
('JHH',1,1),
('JHJ',1,1),
('JKK',1,1),
('JQ',1,1),
('JZ',1,1),
('JX',1,1),
('JW',1,1),
('SAS',0,1),
('ASA',0,6),
('SAE',0,1),
('ASB',0,2),
('SSN',1,4),
('SSYR',0,1),
('SSYH',0,1),
('SSYU',0,1),
('S359S',1,4),
('SLA',1,4),
('SLU',1,4),
('RMB',1,4),
('ALCN',1,4),
('VKS',0,1),
('WPR',1,4),
('FFM',1,4),
('21M',0,1),
('XCN',1,1),
('BPK',1,1),
('RG8H',1,4),
('RGRMB',1,4),
('RS',1,4),
('TMK1',1,4),
('TF1',1,1),
('A7HK',1,4),
('MHK8',1,4),
('MHK9',1,4),
('M7RRMB',1,4),
('FNG',1,1),
('FNH',1,1),
('FNN',1,1),
('FNU',1,1)

CREATE TABLE #Cust (custid int, srecommend INT, mrecommend INT, roleid TINYINT, IsDownLine BIT, isfinished bit default(0)) 
DECLARE @custid int, @srecommend INT, @mrecommend INT, @roleid TINYINT, @IsDownLine BIT = 0

INSERT INTO #Cust(custid, srecommend, mrecommend, roleid)
SELECT ci.custid, ci.srecommend, ci.mrecommend, ci.roleid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND CI.username IN (SELECT username FROM #cust_tmp T WHERE T.LevelApplied = 4)

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Cust
	SET isfinished = 1
		,@custid = custid	
		,@srecommend = srecommend	
		,@mrecommend = mrecommend
		,@roleid = roleid
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	EXEC dbo.Acc_DynamicCustomerInfo_09 
			@custid = @custid			
			,@srecommend = @srecommend
			,@mrecommend = @mrecommend
			,@roleid = @roleid
			,@target = 'REPLICATED'
			
			
	waitfor delay '00:00:0.280'
END

-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
/* LevelApplied: 
(1,'Super Only'),
(2,'Master Only'),
(4, 'Super,master,Agent,Member'),
(5,'Super,Master only'),
(6,'Agent only')
*/

CREATE TABLE #cust_tmp (username VARCHAR(100),IsFollowLC BIT, LevelApplied SMALLINT)
INSERT INTO #cust_tmp (username,IsFollowLC,LevelApplied)
VALUES
('S32KK',1,1),
('M999RM',0,2),
('M999SD',0,0),
('M9999S',0,0),
('S999S',0,0),
('99HK',0,0),
('PHRM',1,1),
('MPHSD',1,1),
('SHJ',1,1),
('ywrm',1,1),
('TEG',1,4),
('SGS',1,4),
('SGAR',1,4),
('THR',1,4),
('TEK',1,4),
('TED',1,4),
('THH',1,4),
('THS',1,4),
('M789H',0,2),
('M96RM',1,2),
('S96h',1,1),
('KHBH',1,1),
('KM',1,1),
('KH',1,1),
('KR',1,1),
('KS',1,1),
('KT',1,1),
('KRC',1,1),
('KSD',1,1),
('KMM',1,1),
('KRR',1,1),
('KMA',1,1),
('KHH',1,1),
('KHK',1,1),
('KAR',1,1),
('KBR',1,1),
('KCR',1,1),
('KAM',1,1),
('KMAM',1,1),
('KHAH',1,1),
('M28RMB',1,1),
('M28H',1,1),
('CJEU',1,4),
('MPTUS',1,1),
('MPTRMB',1,1),
('MPPU',1,1),
('M26ARMB',1,1),
('M26RM',1,1),
('M26SD',1,1),
('S26H',1,1),
('SVP',1,4),
('SVE',1,4),
('SVM',1,4),
('SVS',1,4),
('SVH',1,4),
('SVUS',1,4),
('SCS',1,1),
('SCSM',1,1),
('SCH',1,1),
('SCAH',1,1),
('SCBH',1,1),
('SCHI',1,1),
('HIU',1,1),
('HAH',1,1),
('HIC',1,1),
('69SD',1,4),
('S69SD',1,4),
('S69RM',1,4),
('S7RM',1,4),
('M69U',1,4),
('M69H',1,4),
('S69H',1,4),
('S69E',1,4),
('S69BP',1,4),
('S69HD',1,4),
('S69M',1,4),
('S69G',1,4),
('S56ARM',1,1),
('S56BRM',1,1),
('S56CRM',1,1),
('S56H',1,1),
('S56AH',1,1),
('S56CH',1,1),
('S56DH',1,1),
('S56HH',1,1),
('S56HK',1,1),
('S56T',1,1),
('S56QH',1,1),
('S56KK',1,1),
('S56SD',1,1),
('S56AC',1,1),
('S56AD',1,1),
('S56US',1,1),
('S56AU',1,1),
('S56BU',1,1),
('S56A',1,1),
('HK06',1,1),
('S56AE',1,1),
('S56CU',1,1),
('S56DU',1,1),
('S56ASD',1,1),
('HK09',1,1),
('S56AF',1,1),
('S49R',0,1),
('S3AAR',1,1),
('S3AK',1,1),
('S3AG',1,1),
('S88US',1,4),
('SOGO',1,4),
('SOGA',1,4),
('SHSD',1,4),
('SHRMB',1,4),
('SHTB',1,4),
('SHHK',1,4),
('SHUS',1,4),
('hhm',1,4),
('SHDK',1,4),
('SHU',1,4),
('SHHK1',1,4),
('SHR',1,4),
('SHR1',1,4),
('SHHK3',1,4),
('shhk5',1,4),
('SHR3',1,4),
('shhk6',1,4),
('SHR5',1,4),
('sh8',1,4),
('SHHK9',1,4),
('SHHK8',1,4),
('HHK1',1,4),
('HHK10',1,4),
('HHK2',1,4),
('HHK3',1,4),
('HHR',1,4),
('BHJ',1,4),
('CFT',1,4),
('TT',1,4),
('TTA',1,4),
('TTB',1,4),
('S222H',1,1),
('S222NH',1,1),
('M222M',1,1),
('2ZH',1,1),
('2EU',1,1),
('S222X',1,1),
('2CR',1,1),
('2CT',1,1),
('2CK',1,1),
('2BP',1,1),
('2UA',1,1),
('2UB',1,1),
('2RA',1,1),
('2RB',1,1),
('A688U',1,1),
('S688H',1,1),
('S688T',1,1),
('LLR',1,1),
('A68US',1,1),
('SB8R',1,5),
('MKYM',1,1),
('M8H',1,1),
('MTRU',1,4),
('MTRE',1,4),
('S2H',1,1),
('SRMB',1,1),
('SRRH',1,1),
('SRR',1,1),
('SRRR',1,1),
('SRUS',1,1),
('SRUN',1,1),
('JAA',1,4),
('JAH',1,4),
('JAS',1,4),
('JAHA',1,4),
('JAU',1,4),
('JARWRONG',1,4),
('JAR',1,4),
('JAHE',1,4),
('M99RMB',1,1),
('S99R',1,1),
('S99HKD',1,1),
('S99RMB',1,1),
('S99U',1,1),
('S99E',1,1),
('FN1',1,1),
('FN2',1,1),
('FN3',1,1),
('FN4',1,1),
('FN5',1,1),
('FN6',1,1),
('FN7',1,1),
('FN8',1,1),
('FN9',1,1),
('FN10',1,1),
('NK1',1,1),
('NK2',1,1),
('NK3',1,1),
('NK4',1,1),
('NK5',1,1),
('NK6',1,1),
('NK7',1,1),
('NK8',1,1),
('NK9',1,1),
('NK10',1,1),
('G33M',1,1),
('G99MK',1,1),
('GMK9',1,1),
('FN11',1,1),
('FN12',1,1),
('GMK7',1,1),
('GMK8',1,1),
('s45m',1,1),
('S45AH',1,1),
('S45AM',1,1),
('AHW',1,4),
('S41K',1,1),
('S41S',1,1),
('S41M',1,1),
('S41H',1,1),
('S43S',1,1),
('S43H',1,1),
('KMK',1,4),
('HPL',1,4),
('KA',1,4),
('SX13',1,4),
('JS',1,1),
('JS1',1,1),
('JS2',1,1),
('SFH',1,1),
('JS3',1,1),
('JU',1,1),
('SJS',1,1),
('SFHA',1,1),
('JS9',1,1),
('JSA',1,1),
('JSC',1,1),
('JSD',1,1),
('JSH',1,1),
('JSK',1,1),
('JR',1,1),
('JRA',1,1),
('JHH',1,1),
('JHJ',1,1),
('JKK',1,1),
('JQ',1,1),
('JZ',1,1),
('JX',1,1),
('JW',1,1),
('SAS',0,1),
('ASA',0,6),
('SAE',0,1),
('ASB',0,2),
('SSN',1,4),
('SSYR',0,1),
('SSYH',0,1),
('SSYU',0,1),
('S359S',1,4),
('SLA',1,4),
('SLU',1,4),
('RMB',1,4),
('ALCN',1,4),
('VKS',0,1),
('WPR',1,4),
('FFM',1,4),
('21M',0,1),
('XCN',1,1),
('BPK',1,1),
('RG8H',1,4),
('RGRMB',1,4),
('RS',1,4),
('TMK1',1,4),
('TF1',1,1),
('A7HK',1,4),
('MHK8',1,4),
('MHK9',1,4),
('M7RRMB',1,4),
('FNG',1,1),
('FNH',1,1),
('FNN',1,1),
('FNU',1,1)

CREATE TABLE #Cust (custid int, srecommend INT, mrecommend INT, roleid TINYINT, IsDownLine BIT, isfinished bit default(0)) 

DECLARE @custid int, @srecommend INT, @mrecommend INT, @roleid TINYINT, @IsDownLine BIT = 0

INSERT INTO #Cust(custid, srecommend, mrecommend, roleid)
SELECT ci.custid, ci.srecommend, ci.mrecommend, ci.roleid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND CI.username IN (SELECT username FROM #cust_tmp T WHERE T.LevelApplied = 4)

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Cust
	SET isfinished = 1
		,@custid = custid	
		,@srecommend = srecommend	
		,@mrecommend = mrecommend
		,@roleid = roleid
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	EXEC dbo.Acc_DynamicCustomerInfo_09 
			@custid = @custid			
			,@srecommend = @srecommend
			,@mrecommend = @mrecommend
			,@roleid = @roleid
			,@target = 'DBCUST'
			
			
	waitfor delay '00:00:0.280'
END