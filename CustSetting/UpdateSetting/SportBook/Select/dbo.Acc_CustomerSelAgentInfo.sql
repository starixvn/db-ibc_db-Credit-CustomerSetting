/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelAgentInfo] 
	@CustID int--agentID
AS
/*
Created by: []
Date:[]
Task: Add new Member at Agent Site
DB: DBCUST.CustDB
Original: agentsite\account\addnewmember.asp

Revisions:
	- @PphuongDoan: remove '_1' on the SP name
	- 20090515@PhuongDao: Add 1x2 Commission
	- 20090521@PhuongDao: Get maxcredit from CustAgent 
	- 20090630@Phuc: remove check allowPT.
	- 20091118@Jamie: Assign the closed status of upline to member
	- 20091215@Kiwi: Remove HR (151) and Financials (201).
	- 20100729@Shifu: Grant execute for bodbExAccNet
	- 20100828@Henry: Add Mix Parlay Mixed Sports & Number Game
	- 20101027@Lukas: add max per ball (number game)
	- 20110802@Lukas: (Number Game)
			- Add more bettypes: Warrior, Next Combo, Number Group
			- Remove Dead ball Over/Under
	- 20120726@Johnson: suggest new username
	- 20120827@Johnson: max_a1 = min(a2,a4)
	- 20130121@Dan: call to DBAGE/bodb_AGE for Age_CustomerSelSuggestUsername sp because moving this SP to bodb_AGE 
	- 20130530@Johnson: correct a2_live for soccer
	- 20131017@Kathy: Add HR Fixed Odds (154)[Redmine:#6505]
	- 20131029@Elodie: Put link server DBAGE [Redmine:#7261]	
	- 20140701@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20160627@Winnie: Out right PT [Redmine #59438]
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20181123@Helen: DB053.bodb_AGE/BODB02 & DB052.bodb_Summary Migration [Redmine: 104770]
	- 20181105@Johnson: add Happy 5 [Redmine: #104006]
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]
	- 20190828@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
	- 20201028@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20210510@Tina: Lock account & indirect close account [redmine: #148600]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
	- 20230310@Tacy: NAP/Alpha - Split 789y site [RedmineID: #181596]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
*/
BEGIN
SET NOCOUNT ON

Declare @UserName varchar(50), @UplineUsername varchar(50),@Asuspended bit, @UplineClosed bit 
Declare @MinBet_Max money,
		@MaxBet_Min money,		
		@MaxPerMatch_Min money,
		@MaxPerMatch_Max money,
		
		@MinBetv2_Max money, 
		@MaxBetv2_Min money,		
		@MaxPerMatchv2_Min money,
		@MaxPerMatchv2_Max money,
		
		@MinBetv3_Max money, 
		@MaxBetv3_Min money,		
		@MaxPerMatchv3_Min money,
		@MaxPerMatchv3_Max money,

		@MinBetv5_Max money, 
		@MaxBetv5_Min money,		
		@MaxPerMatchv5_Min money,
		@MaxPerMatchv5_Max money,

		@MinBetv8_Max money, 
		@MaxBetv8_Min money,		
		@MaxPerMatchv8_Min money,
		@MaxPerMatchv8_Max money,

		@MinBetv10_Max money, 
		@MaxBetv10_Min money,		
		@MaxPerMatchv10_Min money,
		@MaxPerMatchv10_Max money,

		@MinBetv11_Max money, 
		@MaxBetv11_Min money,		
		@MaxPerMatchv11_Min money,
		@MaxPerMatchv11_Max money,
		
		@MinBetv99_Max money, 
		@MaxBetv99_Min money,		
		@MaxPerMatchv99_Min money,
		@MaxPerMatchv99_Max money,
		
		@MinBetv99MP_Max money,
		@MaxBetv99MP_Min money,
		@MaxPerMatchv99MP_Min money,
		@MaxPerMatchv99MP_Max money,
		
		@MinBetv1MP_Max money,
		@MaxBetv1MP_Min money,
		@MaxPerMatchv1MP_Min money,
		@MaxPerMatchv1MP_Max money,			

		--Max Payout Per Match
		@MaxPayoutPerMatch_max money = 0,
		@MaxPayoutPerMatchv2_max money = 0,
		@MaxPayoutPerMatchv3_max money = 0,
		@MaxPayoutPerMatchv5_max money = 0,
		@MaxPayoutPerMatchv8_max money = 0,
		@MaxPayoutPerMatchv10_max money = 0,
		@MaxPayoutPerMatchv11_max money = 0,
		@MaxPayoutPerMatchv99_max money = 0,
		@MaxPayoutPerMatchv99mp_max money = 0,
		@MaxPayoutPerMatchv1mp_max money = 0,
		--- Saba soccer
		@MinBetv1saba_Max            MONEY = 0, 
		@MaxBetv1saba_Min            MONEY = 0, 
		@MaxPerMatchv1saba_Min       MONEY = 0, 
		@MaxPerMatchv1saba_Max       MONEY = 0, 
		@MaxPayoutPerMatchv1saba_max MONEY = 0,
		--- Saba Basketball
		@MinBetv2saba_Max            MONEY = 0, 
		@MaxBetv2saba_Min            MONEY = 0, 
		@MaxPerMatchv2saba_Min       MONEY = 0, 
		@MaxPerMatchv2saba_Max       MONEY = 0, 
		@MaxPayoutPerMatchv2saba_max MONEY = 0,
		
		@Credit_AllOtherMember money, 
		@Credit_Ag money,
		@Credit_Mem_Max money, 
		@Credit_Ag_Bal money,
		@MaxCredit_Mem money,
		@AllowedCurr bit,
		@CurrencyID int
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select @Credit_AllOtherMember = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where recommend = @CustID and RoleID = 1

SELECT	@Credit_Ag = isnull(credit, 0),
		@Asuspended = cs.reject , 
		@UplineClosed = cs.closed,
		@CurrencyID=ci.currency
FROM CustInfo as ci with (NOLOCK) 
	CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
WHERE CustID = @CustID

select @MaxCredit_Mem = isnull(maxcredit,0) from CustAgent WITH (NOLOCK) where CustID = @CustID

select @Credit_Ag_Bal = @Credit_Ag - @Credit_AllOtherMember
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select @Credit_Mem_Max = case when @MaxCredit_Mem =0  then @Credit_Ag_Bal 
							  when @MaxCredit_Mem > @Credit_Ag_Bal then @Credit_Ag_Bal
							  else @MaxCredit_Mem end 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare @mrecommend int, @srecommend INT = 0
select @mrecommend = mrecommend,@srecommend = srecommend from custinfo with (NOLOCK) where custid = @custid
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Get BetSetting limit
EXEC Age_CustomerSelMinMaxLimit @custid = @custid, @IsCreatedDowline = 1,
	@MinBet_Max = @MinBet_Max output, @MaxBet_Min = @MaxBet_Min output, @MaxPerMatch_Min = @MaxPerMatch_Min output, @MaxPerMatch_Max = @MaxPerMatch_Max output,
	@MinBetv2_Max = @MinBetv2_Max output, @MaxBetv2_Min = @MaxBetv2_Min output, @MaxPerMatchv2_Min = @MaxPerMatchv2_Min output, @MaxPerMatchv2_Max = @MaxPerMatchv2_Max output,
	@MinBetv3_Max = @MinBetv3_Max output, @MaxBetv3_Min = @MaxBetv3_Min output, @MaxPerMatchv3_Min = @MaxPerMatchv3_Min output, @MaxPerMatchv3_Max = @MaxPerMatchv3_Max output,
	@MinBetv5_Max = @MinBetv5_Max output, @MaxBetv5_Min = @MaxBetv5_Min output, @MaxPerMatchv5_Min = @MaxPerMatchv5_Min output, @MaxPerMatchv5_Max = @MaxPerMatchv5_Max output,
	@MinBetv8_Max = @MinBetv8_Max output, @MaxBetv8_Min = @MaxBetv8_Min output, @MaxPerMatchv8_Min = @MaxPerMatchv8_Min output, @MaxPerMatchv8_Max = @MaxPerMatchv8_Max output,
	@MinBetv10_Max = @MinBetv10_Max output, @MaxBetv10_Min = @MaxBetv10_Min output, @MaxPerMatchv10_Min = @MaxPerMatchv10_Min output, @MaxPerMatchv10_Max = @MaxPerMatchv10_Max output,
	@MinBetv11_Max = @MinBetv11_Max output, @MaxBetv11_Min = @MaxBetv11_Min output, @MaxPerMatchv11_Min = @MaxPerMatchv11_Min output, @MaxPerMatchv11_Max = @MaxPerMatchv11_Max output,
	@MinBetv99_Max = @MinBetv99_Max output, @MaxBetv99_Min = @MaxBetv99_Min output, @MaxPerMatchv99_Min = @MaxPerMatchv99_Min output, @MaxPerMatchv99_Max = @MaxPerMatchv99_Max output,		
	@MinBetv99MP_Max = @MinBetv99MP_Max output, @MaxBetv99MP_Min = @MaxBetv99MP_Min output, @MaxPerMatchv99MP_Min = @MaxPerMatchv99MP_Min output, @MaxPerMatchv99MP_Max = @MaxPerMatchv99MP_Max output,
	@MinBetv1MP_Max = @MinBetv1MP_Max output, @MaxBetv1MP_Min = @MaxBetv1MP_Min output, @MaxPerMatchv1MP_Min = @MaxPerMatchv1MP_Min output, @MaxPerMatchv1MP_Max = @MaxPerMatchv1MP_Max output,
	@MaxPayoutPerMatch_max      = @MaxPayoutPerMatch_max      OUTPUT,
	@MaxPayoutPerMatchv2_max    = @MaxPayoutPerMatchv2_max    OUTPUT,
	@MaxPayoutPerMatchv3_max    = @MaxPayoutPerMatchv3_max    OUTPUT,
	@MaxPayoutPerMatchv5_max    = @MaxPayoutPerMatchv5_max    OUTPUT,
	@MaxPayoutPerMatchv8_max    = @MaxPayoutPerMatchv8_max    OUTPUT,
	@MaxPayoutPerMatchv10_max   = @MaxPayoutPerMatchv10_max   OUTPUT,
	@MaxPayoutPerMatchv11_max   = @MaxPayoutPerMatchv11_max   OUTPUT,
	@MaxPayoutPerMatchv99_max   = @MaxPayoutPerMatchv99_max   OUTPUT,
	@MaxPayoutPerMatchv99mp_max = @MaxPayoutPerMatchv99mp_max OUTPUT,
	@MaxPayoutPerMatchv1mp_max  = @MaxPayoutPerMatchv1mp_max  OUTPUT,
	--saba
	@MinBetv1saba_Max = @MinBetv1saba_Max output, @MaxBetv1saba_Min = @MaxBetv1saba_Min output, @MaxPerMatchv1saba_Min = @MaxPerMatchv1saba_Min output, 
	@MaxPerMatchv1saba_Max = @MaxPerMatchv1saba_Max output, @MaxPayoutPerMatchv1saba_max = @MaxPayoutPerMatchv1saba_max OUTPUT,
	@MinBetv2saba_Max = @MinBetv2saba_Max output, @MaxBetv2saba_Min = @MaxBetv2saba_Min output, @MaxPerMatchv2saba_Min = @MaxPerMatchv2saba_Min output, 
	@MaxPerMatchv2saba_Max = @MaxPerMatchv2saba_Max output, @MaxPayoutPerMatchv2saba_max = @MaxPayoutPerMatchv2saba_max OUTPUT

-- Myanmar Odds

DECLARE @MyanmarOdds DECIMAL (9,8),@IsMyanmarOdds BIT = 0

SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@srecommend)

IF @IsMyanmarOdds = 1
	SET @MyanmarOdds = (SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @CustID AND Sporttype = 1 AND Bettype = 1)

select @UplineUsername = ci.username 
from custinfo ci with (nolock) where custid = @CustID

EXEC dbo.Age_CustomerSelSuggestUsername @prefix = @uplineusername,@custid = @custid, @roleid = 2, @seqname = @username output
 
/*
Select @username = isnull(right(max(username),3), '000')
from customer with (nolock)
where recommend = @custid and roleid = 1
	and charindex(@UplineUsername, username) = 1
	and len(username) = len(@UplineUsername) + 3
*/

Select
	@UserName as NewUserName,
	@Asuspended as suspended, 
	@UplineClosed as closed,
	@AllowedCurr AS AllowedCurr,
	@Credit_Mem_Max as Credit_Max,
		
	max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as apositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as apositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as apositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as apositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as apositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as apositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as apositiontaking_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v2apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v3apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v5apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v8apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v10apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v11apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v99apositiontaking_10,
	max(case when cs.bettype = 9999 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as apositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then case when cs.alivepositiontaking < scs.alivepositiontaking then cs.alivepositiontaking else scs.alivepositiontaking end else case when co.maxlivepositiontaking < scs.alivepositiontaking then co.maxlivepositiontaking else scs.alivepositiontaking end end else 0 end) as alivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then case when cs.alivepositiontaking < scs.alivepositiontaking then cs.alivepositiontaking else scs.alivepositiontaking end else case when co.maxlivepositiontaking < scs.alivepositiontaking then co.maxlivepositiontaking else scs.alivepositiontaking end end else 0 end) as alivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then case when cs.alivepositiontaking < scs.alivepositiontaking then cs.alivepositiontaking else scs.alivepositiontaking end else case when co.maxlivepositiontaking < scs.alivepositiontaking then co.maxlivepositiontaking else scs.alivepositiontaking end end else 0 end) as alivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then case when cs.alivepositiontaking < scs.alivepositiontaking then cs.alivepositiontaking else scs.alivepositiontaking end else case when co.maxlivepositiontaking < scs.alivepositiontaking then co.maxlivepositiontaking else scs.alivepositiontaking end end else 0 end) as alivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v2apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v2apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v2apositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v2apositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v2apositiontaking_8,
	--max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v2apositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v2apositiontaking_20,
	
	max(case when cs.bettype = 9999 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v2apositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v3apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v3apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v3apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v3apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v5apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v5apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v5apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v5apositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v5apositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v8apositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v8apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v8apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v10apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v10apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v10apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v10apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v11apositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v11apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v99apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v99apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v99apositiontaking_3,
	max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v99apositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v99apositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then case when cs.apositiontaking < scs.apositiontaking then cs.apositiontaking else scs.apositiontaking end else case when co.maxpositiontaking < scs.apositiontaking then co.maxpositiontaking else scs.apositiontaking end end else 0 end) as v99apositiontaking_9999,
	
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.discount else 0 end) as discountcs,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.discount else 0 end) as discount1x2,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end) as groupa,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end) as groupb,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end) as groupc,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end) as groupd,
		
	-- For MyanmarOdds
	ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds,
	ISNULL(@MyanmarOdds,0) AS discountMyanmarOdds,
	
	max(case when cs.bettype = 1 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_3_min,
	max(case when cs.bettype = 4 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_4_min,
	max(case when cs.bettype = 5 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_5_min,
	max(case when cs.bettype = 6 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_6_min,
	max(case when cs.bettype = 7 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_7_min,
	max(case when cs.bettype = 8 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_8_min,
	max(case when cs.bettype = 9 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_9_min,
	max(case when cs.bettype = 10 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=8 then co.minpositiontaking else 0 end) as v8apositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=11 then co.minpositiontaking else 0 end) as v11apositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_10_min,
	max(case when cs.bettype = 9999 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_9999_min,

	max(case when cs.bettype = 1 and cs.sporttype=1 then co.minlivepositiontaking else 0 end) as alivepositiontaking_1_min,
	max(case when cs.bettype = 3 and cs.sporttype=1 then co.minlivepositiontaking else 0 end) as alivepositiontaking_3_min,
	max(case when cs.bettype = 7 and cs.sporttype=1 then co.minlivepositiontaking else 0 end) as alivepositiontaking_7_min,
	max(case when cs.bettype = 8 and cs.sporttype=1 then co.minlivepositiontaking else 0 end) as alivepositiontaking_8_min,

	max(case when cs.bettype = 1 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_3_min,
	max(case when cs.bettype = 7 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_7_min,
	max(case when cs.bettype = 8 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_8_min,
	--max(case when cs.bettype = 9 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_9_min,
	max(case when cs.bettype = 20 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_20_min,
	
	max(case when cs.bettype = 9999 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_9999_min,
		
	max(case when cs.bettype = 1 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_20_min,

	max(case when cs.bettype = 1 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_20_min,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_9999_min,

	max(case when cs.bettype = 1 and cs.sporttype=8 then co.minpositiontaking else 0 end) as v8apositiontaking_1_min,
	max(case when cs.bettype = 3 and cs.sporttype=8 then co.minpositiontaking else 0 end) as v8apositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=8 then co.minpositiontaking else 0 end) as v8apositiontaking_20_min,

	max(case when cs.bettype = 1 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_20_min,

	max(case when cs.bettype = 1 and cs.sporttype=11 then co.minpositiontaking else 0 end) as v11apositiontaking_1_min,
	max(case when cs.bettype = 20 and cs.sporttype=11 then co.minpositiontaking else 0 end) as v11apositiontaking_20_min,
	
	max(case when cs.bettype = 1 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_3_min,
	max(case when cs.bettype = 9 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_9_min,	
	max(case when cs.bettype = 20 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_20_min,	
	max(case when cs.bettype = 9999 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_9999_min,	
	
	MAX(Customer.site) AS Site,
	MAX(s.SiteLabel) AS SiteLabel,
	IsNull(@MinBet_Max, 0) as MinBet_Max,
	IsNull(@MaxBet_Min, 0) as MaxBet_Min,
	IsNull(@MaxPerMatch_Min, 0) as MaxPerMatch_Min,
	IsNull(@MaxPerMatch_Max, 0) as MaxPerMatch_Max,
	
	IsNull(@MinBetv2_Max, 0) as MinBetv2_Max,	
	IsNull(@MaxBetv2_Min, 0) as MaxBetv2_Min,	
	IsNull(@MaxPerMatchv2_Min, 0) as MaxPerMatchv2_Min,	
	IsNull(@MaxPerMatchv2_Max, 0) as MaxPerMatchv2_Max,	
	
	IsNull(@MinBetv3_Max, 0) as MinBetv3_Max,	
	IsNull(@MaxBetv3_Min, 0) as MaxBetv3_Min,	
	IsNull(@MaxPerMatchv3_Min, 0) as MaxPerMatchv3_Min,	
	IsNull(@MaxPerMatchv3_Max, 0) as MaxPerMatchv3_Max,

	IsNull(@MinBetv5_Max, 0) as MinBetv5_Max,	
	IsNull(@MaxBetv5_Min, 0) as MaxBetv5_Min,	
	IsNull(@MaxPerMatchv5_Min, 0) as MaxPerMatchv5_Min,	
	IsNull(@MaxPerMatchv5_Max, 0) as MaxPerMatchv5_Max,

	IsNull(@MinBetv8_Max, 0) as MinBetv8_Max,	
	IsNull(@MaxBetv8_Min, 0) as MaxBetv8_Min,	
	IsNull(@MaxPerMatchv8_Min, 0) as MaxPerMatchv8_Min,	
	IsNull(@MaxPerMatchv8_Max, 0) as MaxPerMatchv8_Max,

	IsNull(@MinBetv10_Max, 0) as MinBetv10_Max,	
	IsNull(@MaxBetv10_Min, 0) as MaxBetv10_Min,	
	IsNull(@MaxPerMatchv10_Min, 0) as MaxPerMatchv10_Min,	
	IsNull(@MaxPerMatchv10_Max, 0) as MaxPerMatchv10_Max,

	IsNull(@MinBetv11_Max, 0) as MinBetv11_Max,	
	IsNull(@MaxBetv11_Min, 0) as MaxBetv11_Min,	
	IsNull(@MaxPerMatchv11_Min, 0) as MaxPerMatchv11_Min,	
	IsNull(@MaxPerMatchv11_Max, 0) as MaxPerMatchv11_Max,

	IsNull(@MinBetv99_Max, 0) as MinBetv99_Max,	
	IsNull(@MaxBetv99_Min, 0) as MaxBetv99_Min,	
	IsNull(@MaxPerMatchv99_Min, 0) as MaxPerMatchv99_Min,	
	IsNull(@MaxPerMatchv99_Max, 0) as MaxPerMatchv99_Max,
	
	IsNull(@MinBetv99MP_Max, 0) as MinBetv99MP_Max,	
	IsNull(@MaxBetv99MP_Min, 0) as MaxBetv99MP_Min,	
	IsNull(@MaxPerMatchv99MP_Min, 0) as MaxPerMatchv99MP_Min,	
	IsNull(@MaxPerMatchv99MP_Max, 0) as MaxPerMatchv99MP_Max,
	
	IsNull(@MinBetv1MP_Max, 0) as MinBetv1MP_Max,	
	IsNull(@MaxBetv1MP_Min, 0) as MaxBetv1MP_Min,	
	IsNull(@MaxPerMatchv1MP_Min, 0) as MaxPerMatchv1MP_Min,	
	IsNull(@MaxPerMatchv1MP_Max, 0) as MaxPerMatchv1MP_Max,
		
	--> MaxMaxPayoutPerMatch
	@MaxPayoutPerMatch_max AS MaxPayoutPerMatch_max, 
    @MaxPayoutPerMatchv2_max AS MaxPayoutPerMatchv2_max, 
    @MaxPayoutPerMatchv3_max AS MaxPayoutPerMatchv3_max, 
    @MaxPayoutPerMatchv5_max AS MaxPayoutPerMatchv5_max, 
    @MaxPayoutPerMatchv8_max AS MaxPayoutPerMatchv8_max, 
    @MaxPayoutPerMatchv10_max AS MaxPayoutPerMatchv10_max, 
    @MaxPayoutPerMatchv11_max AS MaxPayoutPerMatchv11_max, 
    @MaxPayoutPerMatchv99_max AS MaxPayoutPerMatchv99_max, 
    @MaxPayoutPerMatchv99mp_max AS MaxPayoutPerMatchv99mp_max, 
    @MaxPayoutPerMatchv1mp_max AS MaxPayoutPerMatchv1mp_max,
	--saba
	ISNULL(@MinBetv1saba_Max			,0)	AS MinBetv1saba_Max,
	ISNULL(@MaxBetv1saba_Min			,0)	AS MaxBetv1saba_Min,
	ISNULL(@MaxPerMatchv1saba_Min 		,0)	AS MaxPerMatchv1saba_Min ,
	ISNULL(@MaxPerMatchv1saba_Max 		,0)	AS MaxPerMatchv1saba_Max ,
	ISNULL(@MaxPayoutPerMatchv1saba_max	,0) AS MaxPayoutPerMatchv1saba_max,
	ISNULL(@MinBetv2saba_Max			,0)	AS MinBetv2saba_Max,
	ISNULL(@MaxBetv2saba_Min			,0)	AS MaxBetv2saba_Min,
	ISNULL(@MaxPerMatchv2saba_Min 		,0)	AS MaxPerMatchv2saba_Min ,
	ISNULL(@MaxPerMatchv2saba_Max 		,0)	AS MaxPerMatchv2saba_Max ,
	ISNULL(@MaxPayoutPerMatchv2saba_max	,0)	AS MaxPayoutPerMatchv2saba_max
From 
	Customer with (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON s.site=customer.site
	INNER JOIN custinfo as ci with (NOLOCK) on Customer.CustID = ci.CustID
	INNER JOIN CustSetting as cs with (NOLOCK) on Customer.CustID = CS.CustID
	INNER JOIN custsetting as scs with(NOLOCK) on ci.srecommend = scs.custid and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
	LEFT JOIN custoverride as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype= cs.bettype	
Where Customer.CustID = @CustID
END

GO