/*<info serverAlias="DBCUST-CustDB,DBACC-bodb02" executers="" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[DBA_GetResultPT]
	@custid int,
	@Bettype int = 1,
	@Sporttype int = 1,
	@s4 smallmoney = 0 OUTPUT,
	@m4 smallmoney = 0 OUTPUT,
	@a4 smallmoney = 0 OUTPUT,
	@n4 smallmoney = 0 OUTPUT,	
	@l4 smallmoney = 0 OUTPUT,	
	@s3 smallmoney = 0 OUTPUT,
	@m3 smallmoney = 0 OUTPUT,
	@u3 smallmoney = 0 OUTPUT,
	@i3 bit = 0 OUTPUT,
	@n3 smallmoney = 0 OUTPUT,
	@l3 smallmoney = 0 OUTPUT,
	@m2 smallmoney = 0 OUTPUT,
	@a2 smallmoney = 0 OUTPUT,
	@um2 smallmoney = 0 OUTPUT,
	@im2 bit = 0 OUTPUT,
	@um1 smallmoney = 0 OUTPUT,
	@im1 smallmoney = 0 OUTPUT,
	@n2 smallmoney = 0 OUTPUT,
	@l2 smallmoney = 0 OUTPUT,
	@s1 smallmoney = 0 OUTPUT,
	@m1 smallmoney = 0 OUTPUT,
	@a1 smallmoney = 0 OUTPUT,
	@u1 smallmoney = 0 OUTPUT,
	@i1 bit =0 OUTPUT,
	@islive bit =0
AS

/*
Created: 
Date: 
Task : Get Result PT
DB: DBTRANS/CustDB, DBACC/bodb02
Original: 

Revisions:
	- 20100925@Henry: Allow to view Number Game setting
	- 20110317@Johnson: Get PT for Greyhound and Harness
	- 20120803@Dan: Get PT for Virtual Soccer
	- 20121204@Tom: Get PT for Virtual Tennis
	- 20130222@Johnson: get virtual horse racing setting (sporttype: 181)
	- 20140404@Elodie: Get Keno, LiveCasino, Virtual Greyhounds, Virtual Speedway, Virtual Motorsports, Virtual Cycling setting (sporttype: 202,162,182,183,184,185)
					   Remove FI setting
	- 20190906@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20231019@Helios: Customer Setting - Migrate Sportsbook to DCS - Remove Code AutoIBCPositionTaking_Fixed, AutoIBCPositionTaking_Tote [RedmineID: #193083]
	- 20250410@Johnson: change datatype for ExchangeID[redmine: #223630]
Param's Explanation:

*/

declare @srecommend int,
		@mrecommend int,
		@recommend int,
		@currency int

select @srecommend = srecommend,
		@mrecommend = mrecommend,
		@recommend = recommend,
		@currency = currency
from customer with (nolock)
where custid = @custid
		
	-- Max of (IBCPos + TPos)
	--Thien@20100521:	+ Phumelela: for (THB, $US, IRR, NTD, Yen, IN, IND, IDD, IDR) members, IBC MUST take 10% PT, MIN PT to Phumelela is 40%
	--					+ OpenTote: For members in ALL currencies, MIN PT to 3rd Party is ALWAYS 50%
			

SELECT
		@l4 = MaxPT
	,	@n4 = MinPT
	,	@s4 = cpa.SuperPT
	,	@m4 = cpa.MasterPT
	,	@a4 = cpa.AgentPT
	FROM CustPTSetting3rd_Agent cpa WITH (NOLOCK)
	WHERE cpa.CustID = @srecommend AND cpa.SportType = @Sporttype AND cpa.BetType = @Bettype AND cpa.IsLive = @islive

	SELECT
		@l3 = MaxPT
	,	@n3 = MinPT
	,	@s3 = cpa.SuperPT
	,	@m3 = cpa.MasterPT
	,	@u3 = cpa.AutoSuperPT
	,	@i3 = cpa.IsAutoSuperPT
	FROM CustPTSetting3rd_Agent cpa WITH (NOLOCK)
	WHERE cpa.CustID = @mrecommend AND cpa.SportType = @Sporttype AND cpa.BetType = @Bettype AND cpa.IsLive = @islive

	SELECT
		@l2 = MaxPT
	,	@n2 = MinPT
	,	@m2 = cpa.MasterPT
	,	@a2 = cpa.AgentPT
	,	@um2 = cpa.AutoMasterPT
	,	@im2 = cpa.IsAutoMasterPT
	FROM CustPTSetting3rd_Agent cpa WITH (NOLOCK)
	WHERE cpa.CustID = @recommend AND cpa.SportType = @Sporttype AND cpa.BetType = @Bettype AND cpa.IsLive = @islive

	SELECT
		@s1 = cpm.SuperPT
	,	@m1 = cpm.MasterPT
	,	@a1 = cpm.AgentPT
	,	@um1 = cpm.AutoMasterPT
	,	@im1 = cpm.IsAutoMasterPT
	,	@u1 = cpm.AutoSuperPT
	,	@i1 = cpm.IsAutoSuperPT
	FROM CustPTSetting3rd_Member cpm WITH (NOLOCK)
	WHERE cpm.CustID = @recommend AND cpm.SportType = @Sporttype AND cpm.BetType = @Bettype AND cpm.IsLive = @islive

	
GO

