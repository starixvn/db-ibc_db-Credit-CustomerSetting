/*
	Created: 20170208@Helen
	Task: Missing Allbet setting - [Redmine:68644]
	DB: DBCUST/CUSTDB
*/

CREATE TABLE #cust_missingsetting (custid INT, Roleid INT,currency INT, srecommend INT, mrecommend INT, recommend INT)

INSERT INTO #cust_missingsetting (custid,Roleid,currency,srecommend,mrecommend,recommend)
SELECT custid,Roleid,currency,srecommend,mrecommend,recommend
FROM custInfo CI WITH (NOLOCK)
WHERE CI.custid IN (1265,
31987,
972611,
13044498,
13053168,
23714571,
23714708,
23715065,
23715144,
23719280,
23729783,
23733083,
24846893,
24856018,
24907927,
24908028,
24499121,
24499654,
847386,
62570,
76640,
98802,
31988,
641835,
20807548,
21052568,
8228116,
8590039,
11668266,
12228758,
18327723,
19542865,
33929,
91819,
2222517,
5120527,
6087105,
7467827,
63254,
490535,
1150760,
2228197,
119255,
79004,
24738391,
23714954,
23714937,
23714639,
23714566,
24738131,
24738397,
24908055,
24738177,
24737817,
3507,
6317,
1803,
1418,
29447,
1521065,
1725,
8458734,
1635,
1637,
1646,
1404,
1518,
1461,
1385,
1434,
6750,
1349,
17637,
1411,
15846209,
2942,
19341845,
19545984,
2957769,
1234984,
1395,
1881542,
3102484,
3508804,
6489501,
10228779,
2360,
13788,
24713,
1799,
1166405,
51499,
1680,
88291,
11557,
110254,
1447,
7906,
1829,
662238,
1343,
106514,
662233,
1423,
2361,
15083,
15966,
51948,
34686,
1743,
24738444,
24499458,
24738025,
23713930,
23714100,
23714123,
23714138,
23714087,
23714129,
23714176,
23714092,
23714160,
23714077,
23714107,
24499948,
24499115,
24738446,
24499304,
24737809,
24499591,
24738349,
23714542,
23714809,
24738501,
23714088,
24738073,
23714705,
24738575,
24499845,
23714265,
24738722,
24738136,
24499083,
24738748,
24738753,
24738164,
24738354,
24738135,
24738569,
24738591,
24738590,
24499493,
24738129,
24738141,
24738324,
24738468,
23778555,
23943934,
23714661,
24738083,
24499707,
24499623,
24738500,
24499896,
24499022,
23715324,
24499635,
24499954,
24738219,
24738494,
24738562,
24738427,
24738419,
23714792,
23714871,

25076282,25076227,25076292,25076260,25076217,25076252,25076279,25076272,25076464,25076266,25076331,25076249

)

DECLARE @ProductID INT = 21, @SportType SMALLINT = 211, @Bettype SMALLINT = 2401, @IsLive BIT = 0
/********************************************* SMA WinLimit : SettingType = 6 ****************************************/
-- @RoleID = 4
--MaxWinLimit: 0 (Unlimited)
--MaxLossLimit: get from global setting based on currency
--IsAutoReset: 1		
INSERT INTO [dbo].[CustWinLossLimit_Agent]
   ([CustID]
   ,[SportType]
   ,[BetType]
   ,[MaxWinLimit]
   ,[MaxLossLimit]
   ,[IsAutoReset])
SELECT
	ft.custid
	,@SportType
	,@Bettype
	,0
	,gs.DefaultLossLimit
	,1
FROM #cust_missingsetting ft 
	INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = @ProductID AND gs.ExchangeId = ft.currency
WHERE ft.Roleid = 4
--@RoleID = 3
--MaxWinLimit: super.MaxWinLimit
--MaxLossLimit: super.MaxLossLimit
--IsAutoReset: super.IsAutoReset
INSERT INTO [dbo].[CustWinLossLimit_Agent]
	([CustID]
	,[SportType]
	,[BetType]
	,[MaxWinLimit]
	,[MaxLossLimit]
	,[IsAutoReset])
SELECT	ft.custid
	,cs.SportType
	,cs.BetType
	,cs.MaxWinLimit
	,cs.MaxLossLimit
	,cs.IsAutoReset
FROM #cust_missingsetting ft  
	INNER JOIN dbo.CustWinLossLimit_Agent cs WITH (NOLOCK) ON cs.CustId = ft.srecommend AND cs.SportType = @SportType AND cs.BetType = @Bettype
WHERE ft.Roleid = 3

-- @RoleID = 2
--MaxWinLimit: master.MaxWinLimit
--MaxLossLimit: master.MaxLossLimit
--IsAutoReset: master.IsAutoReset
INSERT INTO [dbo].[CustWinLossLimit_Agent]
	([CustID]
	,[SportType]
	,[BetType]
	,[MaxWinLimit]
	,[MaxLossLimit]
	,[IsAutoReset])
SELECT
	ft.custid
	,cs.SportType
	,cs.BetType
	,cs.MaxWinLimit
	,cs.MaxLossLimit
	,cs.IsAutoReset
FROM #cust_missingsetting ft  
	INNER JOIN dbo.CustWinLossLimit_Agent cs WITH (NOLOCK) ON cs.CustId = ft.mrecommend AND cs.SportType = @SportType AND cs.BetType = @Bettype
WHERE ft.Roleid = 2

-- @Roleid = 1
--MaxWinLimit: agent.MaxWinLimit
--MaxLossLimit: agent.MaxLossLimit
--IsAutoReset: agent.IsAutoReset
INSERT INTO [dbo].[CustWinLossLimit_Member]
	([CustID]
	,[SportType]
	,[BetType]
	,[MaxWinLimit]
	,[MaxLossLimit]
	,[IsAutoReset])
SELECT
	ft.custid
	,cs.SportType
	,cs.BetType
	,cs.MaxWinLimit
	,cs.MaxLossLimit
	,cs.IsAutoReset
FROM #cust_missingsetting ft  
	INNER JOIN dbo.CustWinLossLimit_Agent cs WITH (NOLOCK) ON cs.CustId = ft.recommend AND cs.SportType = @SportType AND cs.BetType = @Bettype
WHERE ft.Roleid = 1

DROP TABLE #cust_missingsetting