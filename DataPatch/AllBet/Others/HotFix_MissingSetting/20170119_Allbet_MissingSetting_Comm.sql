/*
	Created: 20170208@Helen
	Task: Missing Allbet setting - [Redmine:68644]
	DB: DBCUST/CUSTDB
*/

CREATE TABLE #cust_missingsetting (custid INT, Roleid INT, srecommend INT, mrecommend INT, recommend INT)

INSERT INTO #cust_missingsetting (custid,Roleid,srecommend,mrecommend,recommend)
SELECT custid,Roleid,srecommend,mrecommend,recommend
FROM custInfo CI WITH (NOLOCK)
WHERE CI.custid IN (116927,
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
24499948,
24499115,
24499954,
24499623,
23715324,
24499304,
24499591,
24499635,
23714566,
24499654,
24499121,
24908055,
23943934,
23778555,
23714661,
24499458,
24499022,
24499493,
24499707,
24499896,
23714705,
23714542,
23714809,
24499083,
23714937,
23714871,
23714639,
23714792,
23714088,
23714087,
23714092,
23714077,
23714123,
23714138,
23714129,
23714100,
23714107,
23714160,
23714176,
23714954,
23714265,
23713930,
24499845,

25076282,25076227,25076292,25076260,25076217,25076252,25076279,25076272,25076464,25076266,25076331,25076249

)

DECLARE @SportType SMALLINT = 211, @Bettype SMALLINT = 2401
/********************************************* Commision : SettingType = 3 ****************************************/
--IF @RoleID = 2,3,4
INSERT INTO [dbo].[CustDiscount3rd_Agent]
   ([CustID]
   ,[SportType]
   ,[BetType]
   ,[Discount])
SELECT custid,@SportType,@Bettype,0 -- 0 zero by default
FROM #cust_missingsetting
WHERE Roleid IN (2,3,4)
-- Roleid = 1
--super.discount: super.discount
--master.discount: master.discount
--agent.discount: agent.discount
--playerdiscount: 0
INSERT INTO [dbo].[CustDiscount3rd_Member]
   ([CustID]
   ,[SportType]
   ,[BetType]
   ,[PlayerDiscount]
   ,[AgentDiscount]
   ,[MasterDiscount]
   ,[SuperDiscount])
SELECT 
	ft.custid
	,acs.SportType
	,acs.BetType
	,0
	,acs.Discount
	,mcs.Discount
	,scs.Discount
FROM #cust_missingsetting ft 
	INNER JOIN dbo.CustDiscount3rd_Agent acs WITH (NOLOCK) ON acs.SportType = @SportType AND acs.BetType = @Bettype AND acs.custid=ft.recommend
	INNER JOIN dbo.CustDiscount3rd_Agent mcs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND mcs.custid = ft.mrecommend
	INNER JOIN dbo.CustDiscount3rd_Agent scs WITH (NOLOCK) ON acs.sporttype = scs.sporttype AND acs.bettype = scs.bettype AND scs.custid = ft.srecommend
WHERE ft.Roleid = 1

DROP TABLE #cust_missingsetting
