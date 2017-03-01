/*
	Created: Helen
	Date: 20161202
	Task: Update VIP Status - StakeLevel for Super for Batch 1
	DB: DBCust/CustDB
	
*/

--------STEP 1: Update stake level for supers ------------------
CREATE TABLE #SuperAndDirectMasterAgent (custID INT PRIMARY KEY, ExchangeID INT, RoleID INT)
CREATE TABLE #currency_tmp (ExchangeID INT)
CREATE TABLE #currency_StakelevelList (ExchangeID INT, StakeLevelList VARCHAR(100))

-- list of super, direct master/agent need to be updated
INSERT INTO #SuperAndDirectMasterAgent (custID,ExchangeID,RoleID)
SELECT ci.custid,ci.currency AS ExchangeID, roleid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE (ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		-- Production
		AND ci.site in ('755555','Koribc')
		AND ci.srecommend <> 72
		and ci.currency <> 20
		) 
INSERT INTO #SuperAndDirectMasterAgent (custID,ExchangeID,RoleID)
SELECT ci.custid,ci.currency AS ExchangeID, roleid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE (ci.roleid = 3 -- Direct Master	
		AND ci.custid NOT IN (SELECT custid FROM Acc_CustDirect WITH(NOLOCK))
		AND ci.srecommend IN (SELECT custid FROM Acc_CustDirect WITH(NOLOCK))
		AND ci.site in ('755555','Koribc')
		AND ci.srecommend <> 72
		and ci.currency <> 20
		)
INSERT INTO #SuperAndDirectMasterAgent (custID,ExchangeID,RoleID)
SELECT ci.custid,ci.currency AS ExchangeID, roleid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE (ci.roleid = 2 -- Direct Agent	
		AND ci.custid NOT IN (SELECT custid FROM Acc_CustDirect WITH(NOLOCK))
		AND ci.mrecommend IN (SELECT custid FROM Acc_CustDirect WITH(NOLOCK))
		AND ci.site in ('755555','Koribc')
		AND ci.srecommend <> 72
		and ci.currency <> 20
		)
-- Dummy accounts
INSERT INTO #SuperAndDirectMasterAgent (custID,ExchangeID,RoleID)
SELECT distinct ci.mrecommend,ci.currency AS ExchangeID, 3
FROM dbo.Customer ci WITH(NOLOCK)
WHERE custid in (select custid from #SuperAndDirectMasterAgent where roleid = 2)

INSERT INTO #SuperAndDirectMasterAgent (custID,ExchangeID,RoleID)
SELECT distinct ci.srecommend,ci.currency AS ExchangeID, 4
FROM dbo.Customer ci WITH(NOLOCK)
WHERE custid in (select custid from #SuperAndDirectMasterAgent where roleid = 3)


-- get currencies
INSERT INTO #currency_tmp (ExchangeID)
SELECT DISTINCT ExchangeID 
FROM #SuperAndDirectMasterAgent

-- get stakelevelist of each currency
INSERT INTO #currency_StakelevelList (ExchangeID,StakeLevelList)
SELECT s.exchangeID, STUFF(tmp.StakeLevelList,1,1,'')  AS StakeLevelList
FROM #currency_tmp s
	CROSS APPLY (SELECT TOP 100 ',' + CONVERT(VARCHAR(10),t.StakeLevelID)
					 FROM StakeLevel T (NOLOCK)
					 WHERE T.ExchangeId = s.exchangeID AND T.GameTypeID = 2401
					 ORDER BY T.MaxStake, T.MinStake
					 FOR XML PATH ('')
					 ) tmp (StakeLevelList)
				 		
--------STEP 2: 
-------------------- update stakelevel: Offer ALL STAKELEVEL FOR SUPER AND DIRECT MASTER/AGENT ----------------------------
UPDATE 	T
	SET StakeLevelList = SLL.stakelevelList
FROM CustStakeLevel_Agent T (ROWLOCK)
	INNER JOIN #SuperAndDirectMasterAgent S ON T.CustID = S.custID
	INNER JOIN #currency_StakelevelList SLL ON SLL.exchangeID = S.ExchangeID
WHERE T.SportType = 211 AND T.BetType = 2401

DROP TABLE #SuperAndDirectMasterAgent
DROP TABLE #currency_StakelevelList
DROP TABLE #currency_tmp


/************** Enable VIP *********************/
-- only offer Super: list of follow LC
--Sheet 3: 755, INDO, KORIBC (Special) - Follow LC & Super only - [VIEW]

UPDATE cs
	SET bitmapIsDisabled = CASE WHEN ci.SyncLiveCasino = 1 AND ci.DisableLiveCasino = 0 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0) ELSE bitmapIsDisabled END
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
WHERE ci.roleid = 4 AND ci.username IN ('S69RD',
'S69TB',
'S69W',
'S69K',
'S69RP',
'S69NT',
'S56TB',
'S56TC',
'S56TH',
'S56TA',
'S56TD',
'S56TT',
'S56I',
'S56D',
'S56AI',
'S56II',
--'S56K',
'TM01',
'TM02',
'TM03',
'TM04',
'TM05',
'TM06',
'TM07',
'TM08',
'TM09',
'TM10',
'TM11',
'VV00',
'VV01',
'VV02',
'VV03',
'VV04',
'VV05',
'VV06',
'VV07',
'VV08',
'VV09',
'VV10',
'VV11',
'VV12',
'VV22',
'VV33',
'VV39',
'VV55',
'VV66',
'VV77',
'VV88',
'VV99',
'VV13',
'TBB01',
--'S56KA',
'TM12',
'TM13',
'TM14',
'TM15',
'TM16',
'TM17',
'TM18',
'TM19',
'TM20',
'TM21',
'S222T',
'S222TH',
'S222TA',
'2ID',
'2DD',
'2DE',
'S222K',
'S222W',
'2KR',
'2AC',
'2IE',
'2TH',
'2IR',
'S99TB',
'S99T',
'S99TH',
'S99K',
'S999TB',
'S99W',
'S99C',
'S99THB',
'S99A',
'S99D',
'S99CH',
'S99V',
'S99BT',
'S99TC',
'S99BA',
'S99BB',
'S99BC',
'S99BD',
'K9',
'K8',
'KSS',
'SAI'
)

-- only offer Super: list of follow LC
--Sheet 3: 755, INDO, KORIBC (Special) - Follow LC & Untill Member Level [VIEW]
CREATE TABLE #Cust_2 (custid int primary key) --Mode 0: depend on disable LC, 1: enable all
INSERT INTO #Cust_2(custid)
SELECT ci.custid
FROM custInfo CI (NOLOCK)
WHERE CI.roleid = 4 AND CI.SyncLiveCasino = 1 AND DisableLiveCasino =0 AND ci.username IN ('CHTB',
'ST',
'STT',
'ST1T',
'ST2T',
'ST3T',
'ST4T',
'ST5T',
'ST6T',
'ST7T',
'ST8T',
'ST9T',
'BT',
'B5T',
'B1T',
'B2T',
'B3T',
'B4T',
'B6T',
'B7T',
'B8T',
'B9T',
'B10T',
'B11T',
'B12T',
'B13T',
'B14T',
'B15T',
'B16T',
'B17T',
'B18T',
'B19T',
'B20T',
'B21T',
'B22T',
'B23T',
'B24T',
'B25T',
'STEB',
'SABT',
'B26T',
'B27T',
'B28t',
'B29T',
'B30T',
'B31T',
'B32T',
'B33T',
'B35T',
'B34T',
'B36T',
'B37T',
'B38T',
'B39T',
'B40T',
'B41T',
'B42T',
'B43T',
'B44T',
'B45T',
'B46T',
'B47T',
'B48T',
'B49T',
'B50T',
'B51T',
'B52T',
'B53T',
'B54T',
'MGTB',
'MGBTB',
'MGCTB',
'SGTB',
'SGATB',
'SGI',
'SGT',
'SGAT',
'SGBT',
'SGCT',
'SGKB',
'THT',
'THD',
'THF',
'S6RUP',
'S6ARUP',
'AA',
'BA',
'DA',
'FA',
'VC',
'VD',
'VM',
'VF',
'GA',
'VO',
'GG',
'VP',
'S6KW',
'S7KW',
'VQ',
'FM',
'VI',
'AKO1',
'AKO2',
'VE',
'KRW',
'VA',
'VG',
'S9KW',
'MD',
'AKO3',
'S6T',
'S9KS',
'VJ',
'S9KK',
'S6S',
'VN',
'VR',
'S88ID',
'S88IE',
'JAT',
'MBO',
'HPI',
'HPJ',
'HPH',
'HPE',
'HPA',
'MO',
'MP',
'HPG',
'MQ',
'MG',
'HTB',
'MU',
'MV',
'MZ',
'ML',
'MX',
'SLS',
'SLT',
'ALTH',
'ALRP',
'ALKR',
'KKT',
'KKB',
'KAE',
'KAF',
'KBF',
'KBT',
'KCT',
'KDT',
'KET',
'KND',
'KNE',
'KFT',
'KFU',
'HGW',
'S7D',
'S7W')

UPDATE cs
	SET bitmapIsDisabled = dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0)
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #Cust_2 ci WITH(NOLOCK) ON cs.CustID = ci.CustID 
	
------------Sheet 1: 755, INDO, KORIBC (Enable)- not Follow LC & Untill Member Level [VIEW]
CREATE TABLE #Cust_3 (custid int PRIMARY KEY)

INSERT INTO #Cust_3(custid)
SELECT ci.custid
FROM dbo.custInfo ci WITH(NOLOCK)
WHERE ci.SyncLiveCasino = 1 AND ci.roleid = 4 AND ci.username IN ('WW',
'JJ',
'II',
'IM',
'IK',
'IA',
'IE',
'IG',
'IO',
'IU',
'S60RUP',
'S60AR',
'D60',
'E60',
'S16RUP',
'S88D',
'SWO',
'LJ',
'LH',
'LU',
'LY',
'LL',
'LB',
'LC',
'LD',
'LE',
'LV',
'LF',
'LT',
'KD',
'KL',
'HA',
'LS',
'LA',
'LG',
'LM',
'LII',
'LZ',
'BGR',
'CHU',
'FFF',
'FEF',
'BET',
'USD',
'GN',
'GO',
'SEA',
'SEB',
'SEC',
'SYI',
'SNI',
'HT1',
'HT2',
'HT3',
'HT4',
'HT5',
'U8',
'PK',
'P11',
'P12',
'P15',
'P13',
'P14',
'P16',
'P17',
'P18',
'P19',
'P22',
'P20',
'P21',
'AS',
'AP',
'AJ',
'AN',
'WINA',
'WINB',
'WINC',
'WINZ',
'WINE',
'WINS',
'WINF',
'WING',
'WINH',
'WINJ',
'WINI',
'WINO',
'WINP',
'ACE',
'FAT',
'DON',
'BAT',
'TOP',
'BJB',
'BTM',
'AW',
'AZ',
'AG',
'AF',
'WJ',
'AWTA',
'AWTB',
'KID',
'ZTA',
'ZTB',
'CRA',
'STL',
'STK',
'STJ',
'STP',
'STG',
'STY',
'TU1',
'TU2',
'TU3',
'SI',
'UU',
'WH',
'UT',
'D8G',
'UK',
'IB',
'LK',
'JA',
'UM',
'SB',
'UN',
'UL',
'JB',
'IN',
'JC',
'YN',
'CL',
'UA',
'UB',
'WB',
'IJ',
'WU',
'AT',
'ZZ',
'UC',
'LN',
'KK',
'VB',
'YY',
'UE',
'IF',
'BB',
'HO',
'HU',
'SL',
'UD',
'IZ',
'JK',
'HW',
'UW',
'CX',
'UV',
'AK',
'JN',
'AI',
'JT',
'UF',
'CY',
'UZ',
'UH',
'MH',
'AH',
'UG',
'UY',
'YM',
'TA',
'AQ',
'AD',
'WG',
'WA',
'CP',
'HI',
'BI',
'BJ',
'LI',
'LW',
'UI',
'HP',
'GI',
'SW',
'DI',
'WI',
'QQ',
'DW',
'FF',
'TI',
'CI',
'IP',
'RR',
'IC',
'CO',
'CU',
'CS',
'YI',
'IR',
'VV',
'ID',
'MW',
'MM',
'AL',
'DB',
'SD',
'LR'
)

UPDATE cs
	SET bitmapIsDisabled = dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0) 
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #Cust_3 ci WITH(NOLOCK) ON cs.CustID = ci.CustID

DROP TABLE #Cust_2
DROP TABLE #Cust_3
