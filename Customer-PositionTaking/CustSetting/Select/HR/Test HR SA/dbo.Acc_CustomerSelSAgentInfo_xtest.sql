/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelSAgentInfo]    Script Date: 11/05/2007 11:35:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_CustomerSelSAgentInfo_xtest] 
	@CustID int
AS

/*
Created by: []
Date: []
Task: Super create Master or edit Multiple Master AT AGENT SITE
DB: DB05.BODB02
Original: agentsite\account\addnewmember.asp
Revisions:
	- 20090336@PhuongDoan: remove '_1' in SP name
	- 20090901@Shifu: add IsInternal	
	- 20091215@Kiwi: Remove HR (151) and Financials (201).
	- 20100803@Henry: grant execute permission to [bodbExtAccNet]
	- 20100828@Henry: Add Mix Parlay Mixed Sports & Number Game
	- 20101027@Lukas: Add max per ball (number game)
*/
SET NOCOUNT ON

Declare @UserName varchar(20), @UplineUserName varchar(20),@Ssuspended bit, @IsInternal bit
Declare @MinBet_Max money, @MaxBet_Min money,
		@MinBetv2_Max money, @MaxBetv2_Min money,
		@MinBetv3_Max money, @MaxBetv3_Min money,
		@MinBetv5_Max money, @MaxBetv5_Min money,
		@MinBetv8_Max money, @MaxBetv8_Min money,
		@MinBetv10_Max money, @MaxBetv10_Min money,
		@MinBetv11_Max money, @MaxBetv11_Min money,
		@MinBetv99_Max money, @MaxBetv99_Min money,
		
		@MinBetv99MP_Max money,
		@MaxBetv99MP_Min money,
		@MaxPerMatchv99MP_Min money,
		@MaxPerMatchv99MP_Max money,
		
		@MinBetv161_Max money,
		@MaxBetv161_Min money,
		@MaxPerMatchv161_Min money,
		@MaxPerMatchv161_Max money,
	
		@MaxPerBallv161_Max money,

		@MaxPerMatch_Min money,
		@MaxPerMatchv2_Min money,
		@MaxPerMatchv3_Min money,
		@MaxPerMatchv5_Min money,
		@MaxPerMatchv8_Min money,
		@MaxPerMatchv10_Min money,
		@MaxPerMatchv11_Min money,		
		@MaxPerMatchv99_Min money,
		@maxdownline smallmoney,
		@MaxPerMatch_Max money,
		@MaxPerMatchv2_Max money,
		@MaxPerMatchv3_Max money,
		@MaxPerMatchv5_Max money,
		@MaxPerMatchv8_Max money,
		@MaxPerMatchv10_Max money,
		@MaxPerMatchv11_Max money,
		@MaxPerMatchv99_Max money,
		@Credit_AllOtherMaster money, @Credit_SAg money, @Credit_MAg_Max money,
		@AllowedCurr bit,
		@CurrencyID int
		
Select @Credit_AllOtherMaster = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where srecommend = @CustID and RoleID = 3
select @Credit_SAg = isnull(credit, 0),@Ssuspended = reject, @CurrencyID=ci.currency from CustInfo as ci with (NOLOCK) where CustID = @CustID
Select @IsInternal = isnull(IsInternal, 0) from custsuper with (NOLOCK) where CustID = @CustId
if @CustID <= 100
BEGIN
	--Set unlimited for dummy super
	select @Credit_MAg_Max = 10000000000
END
ELSE
BEGIN
	select @Credit_MAg_Max = @Credit_SAg - @Credit_AllOtherMaster
END

Select 
	@MinBet_Max = MinBet,
	@MaxBet_Min = MaxBet
from 
	custsetting as cs WITH (NOLOCK)
where cs.custid = @CustID and cs.bettype =  1 and cs.sporttype=1

Select 
	@MinBetv2_Max = MinBet,
	@MaxBetv2_Min = MaxBet
from 
	custsetting as cs WITH (NOLOCK)
where cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=2

Select 
	@MinBetv3_Max = MinBet,
	@MaxBetv3_Min = MaxBet
from 
	custsetting as cs WITH (NOLOCK)
where cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=3

Select 
	@MinBetv5_Max = MinBet,
	@MaxBetv5_Min = MaxBet
from 
	custsetting as cs WITH (NOLOCK)
where cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=5

Select
	@MinBetv8_Max = MinBet,
	@MaxBetv8_Min = MaxBet
from 
	custsetting as cs WITH (NOLOCK)
where cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=8

Select 
	@MinBetv10_Max = MinBet,
	@MaxBetv10_Min = MaxBet
from 
	custsetting as cs WITH (NOLOCK)
where cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=10

Select 
	@MinBetv11_Max = MinBet,
	@MaxBetv11_Min = MaxBet
from 
	custsetting as cs WITH (NOLOCK)
where cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=11


Select 
	@MinBetv99_Max = MinBet,
	@MaxBetv99_Min = MaxBet
from 
	custsetting as cs WITH (NOLOCK)
where cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=99

--Mix parlay mixed sports 
Select 
	@MinBetv99MP_Max = MinBet, 
	@MaxBetv99MP_Min = MaxBet
from 
	custsetting as cs WITH (NOLOCK)
where cs.custid = @CustID and cs.bettype = 9 and cs.sporttype=99

--Number Game 
Select 
	@MinBetv161_Max = MinBet, 
	@MaxBetv161_Min = MaxBet
from 
	custsetting3rd as cs WITH (NOLOCK)	
where cs.custid = @CustID and cs.bettype = 81 and cs.sporttype=161

/*
--Revert MPM
Select 	
	@MaxPerMatch_Min = 0, @MaxPerMatchv2_Min = 0,
	@MaxPerMatch_Max = isnull(max(isnull(sci.MaxPerMatch, 0)), 0) - isnull(sum(ci.MaxPerMatch), 0),
	@MaxPerMatchv2_Max = isnull(max(isnull(sci.MaxPerMatch2, 0)), 0) - isnull(sum(ci.MaxPerMatch2), 0)
from 
	custinfo as sci WITH (NOLOCK) 
	LEFT JOIN custinfo as ci WITH (NOLOCK) on (sci.CustID = ci.sRecommend)  and ci.roleid=3
where sci.custid=@custid
*/

Select 
	@UplineUserName = username,
	@MaxPerMatch_Min = 0,
	@MaxPerMatchv2_Min = 0, 
	@MaxPerMatchv3_Min = 0, 
	@MaxPerMatchv5_Min = 0, 
	@MaxPerMatchv8_Min = 0, 
	@MaxPerMatchv10_Min = 0, 
	@MaxPerMatchv11_Min = 0,	 
	@MaxPerMatchv99_Min = 0, 
	@MaxPerMatchv99MP_Min = 0, --mix parlay mixed sports  
	@MaxPerMatchv161_Min = 0, 
	
	@MaxPerMatch_Max = MaxPerMatch, 
	@MaxPerMatchv2_Max = MaxPerMatch2, 
	@MaxPerMatchv3_Max = MaxPerMatch3, 
	@MaxPerMatchv5_Max = MaxPerMatch5, 
	@MaxPerMatchv8_Max = MaxPerMatch8, 
	@MaxPerMatchv10_Max = MaxPerMatch10, 
	@MaxPerMatchv11_Max = MaxPerMatch11, 
	@MaxPerMatchv99_Max = MaxPerMatch99, 
	@MaxPerMatchv99MP_Max = MaxPerMatch99MP, 
	@MaxPerMatchv161_Max = MaxPerMatch161, 
	@MaxPerBallv161_Max = MaxPerBall161		
from 
	custinfo as ci WITH (NOLOCK) 
where ci.custid = @CustID

/*
Select @Username = max(username) from customer with (nolock) where srecommend = @custid and roleid = 3
--print @username
if isnumeric(right(@username,2)) = 1
BEGIN
	if convert(int, right(@username, 2)) < 99
	BEGIN
		select @username = right('00' + convert(varchar(2), convert(int, right(@username, 2)) + 1),2)
	END
	else
	BEGIN
		select @UserName = '01'
	END
END
else
BEGIN
	select @UserName = '01'
END
*/

/*
Select @username = isnull(right(max(username),2), '00')
from customer with (nolock)
where srecommend = @custid and roleid = 3
	and charindex(@UplineUsername, username) = 1
	and len(username) = len(@UplineUsername) + 2
*/
/* Check Currency upline*/

Exec Acc_CheckHRAllowedCurrency_xtest
@currencyID=@CurrencyID,
@Allowed= @AllowedCurr OUTPUT
----------------------------------------
select @username = '00'


Select 
	@UserName as NewUserName,
	@Ssuspended as suspended,
	@Credit_MAg_Max as Credit_Max,		
	@AllowedCurr AS AllowedCurr,
	@IsInternal as IsInternal,	
	--------------------------------
	--Get m4,, to check m3<=m4 on the web
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_1_max,
	max(case when cs.bettype = 2 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_2_max,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_3_max,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_4_max,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_5_max,
	max(case when cs.bettype = 6 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_6_max,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_7_max,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_8_max,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_9_max,
	max(case when cs.bettype = 10 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_10_max,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_1_max,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_3_max,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_7_max,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_8_max,

	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_1_max,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_2_max,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_3_max,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_7_max,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_8_max,
	--max(case when cs.bettype = 9 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_9_max,	
	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_20_max,
	
	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_1_max,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_2_max,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_3_max,	
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_20_max,
	
	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_1_max,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_2_max,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_3_max,	
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_20_max,
	
	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_1_max,	
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_3_max,	
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_20_max,
	
	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_1_max,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_2_max,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_3_max,	
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_20_max,
	
	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_1_max,	
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_20_max,
	
	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_1_max,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_2_max,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_3_max,	
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_9_max,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_20_max,
	
	
	
	
	--v161
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_81_max,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_83_max,
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_85_max,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_86_max,
	
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_85_max,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_86_max,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_87_max,
	
	---------------------------------------------------------------------------		
	/*
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_10,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.slivepositiontaking else 0 end) as slivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.slivepositiontaking else 0 end) as slivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.slivepositiontaking else 0 end) as slivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.slivepositiontaking else 0 end) as slivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.spositiontaking else 0 end) as 2spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.spositiontaking else 0 end) as 2spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.spositiontaking else 0 end) as 2spositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.spositiontaking else 0 end) as 2spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.spositiontaking else 0 end) as 2spositiontaking_8,
	*/
	max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_10,

	max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as slivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as slivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as slivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as slivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_8,
	--max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_20,
	
	max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3spositiontaking_20,
	
	max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5spositiontaking_20,
	
	max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8spositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8spositiontaking_20,
	
	max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10spositiontaking_20,
	
	max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v11spositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v11spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99spositiontaking_3,
	max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99spositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99spositiontaking_20,
	
	
		
	--v161
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then case when cs3.spositiontaking<co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end) as v161spositiontaking_81,	
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then case when cs3.spositiontaking<co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end) as v161spositiontaking_83,	
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.spositiontaking<co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end) as v161spositiontaking_85,	
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.spositiontaking<co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end) as v161spositiontaking_86,	
	
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.slivepositiontaking<co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161slivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.slivepositiontaking<co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161slivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then case when cs3.slivepositiontaking<co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161slivepositiontaking_87,
		
--	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.discount else 0 end) as discount,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.sdiscount else 0 end) as discountcs,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.sdiscount else 0 end) as discount1x2,
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.sdiscount else 0 end) as discountnumber,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end) as groupa,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end) as groupb,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end) as groupc,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end) as groupd,
	
	max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_10,

	max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as auto_slivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as auto_slivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as auto_slivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as auto_slivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_8,
	--max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v3spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v3spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v3spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v3spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v5spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v5spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v5spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v5spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v8spositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v8spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v8spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v10spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v10spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v10spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v10spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v11spositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v11spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v99spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v99spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v99spositiontaking_3,
	max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v99spositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v99spositiontaking_20,
	
	
	
	--v161
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then case when cs3.spositiontaking<co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end) as auto_v161spositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then case when cs3.spositiontaking<co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end) as auto_v161spositiontaking_83,
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.spositiontaking<co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end) as auto_v161spositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.spositiontaking<co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end) as auto_v161spositiontaking_86,
	
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.slivepositiontaking<co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end) as auto_v161slivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.slivepositiontaking<co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end) as auto_v161slivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then case when cs3.slivepositiontaking<co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end) as auto_v161slivepositiontaking_87,
		
	IsNull(@MinBet_Max, 0) as MinBet_Max,
	IsNull(@MinBetv2_Max, 0) as MinBetv2_Max,
	IsNull(@MinBetv3_Max, 0) as MinBetv3_Max,
	IsNull(@MinBetv5_Max, 0) as MinBetv5_Max,
	IsNull(@MinBetv8_Max, 0) as MinBetv8_Max,
	IsNull(@MinBetv10_Max, 0) as MinBetv10_Max,
	IsNull(@MinBetv11_Max, 0) as MinBetv11_Max,	
	IsNull(@MinBetv99_Max, 0) as MinBetv99_Max,	
	
	IsNull(@MinBetv99MP_Max, 0) as minbetv99MP_Max,	--mix parlay mixed sports 
	IsNull(@MinBetv161_Max, 0) as minbetv161_Max,
	
	IsNull(@MaxBet_Min, 0) as MaxBet_Min,
	IsNull(@MaxBetv2_Min, 0) as MaxBetv2_Min,
	IsNull(@MaxBetv3_Min, 0) as MaxBetv3_Min,
	IsNull(@MaxBetv5_Min, 0) as MaxBetv5_Min,
	IsNull(@MaxBetv8_Min, 0) as MaxBetv8_Min,
	IsNull(@MaxBetv10_Min, 0) as MaxBetv10_Min,
	IsNull(@MaxBetv11_Min, 0) as MaxBetv11_Min,	
	IsNull(@MaxBetv99_Min, 0) as MaxBetv99_Min,
	
	IsNull(@MaxBetv99MP_Min, 0) as maxbetv99MP_Min,	--mix parlay mixed sports 
	IsNull(@MaxBetv161_Min, 0) as maxbetv161_Min,	
	
	IsNull(@MaxPerMatch_Min, 0) as MaxPerMatch_Min,
	IsNull(@MaxPerMatchv2_Min, 0) as MaxPerMatchv2_Min,
	IsNull(@MaxPerMatchv3_Min, 0) as MaxPerMatchv3_Min,
	IsNull(@MaxPerMatchv5_Min, 0) as MaxPerMatchv5_Min,
	IsNull(@MaxPerMatchv8_Min, 0) as MaxPerMatchv8_Min,
	IsNull(@MaxPerMatchv10_Min, 0) as MaxPerMatchv10_Min,
	IsNull(@MaxPerMatchv11_Min, 0) as MaxPerMatchv11_Min,	
	IsNull(@MaxPerMatchv99_Min, 0) as MaxPerMatchv99_Min,	
	
	IsNull(@MaxPerMatchv99MP_Min, 0) as MaxPerMatchv99MP_Min, --mix parlay mixed sports 
	IsNull(@MaxPerMatchv161_Min, 0) as MaxPerMatchv161_Min,	
	
	IsNull(@MaxPerMatch_Max, 0) as MaxPerMatch_Max,
	IsNull(@MaxPerMatchv2_Max, 0) as MaxPerMatchv2_Max,
	IsNull(@MaxPerMatchv3_Max, 0) as MaxPerMatchv3_Max,
	IsNull(@MaxPerMatchv5_Max, 0) as MaxPerMatchv5_Max,
	IsNull(@MaxPerMatchv8_Max, 0) as MaxPerMatchv8_Max,
	IsNull(@MaxPerMatchv10_Max, 0) as MaxPerMatchv10_Max,
	IsNull(@MaxPerMatchv11_Max, 0) as MaxPerMatchv11_Max,	
	IsNull(@MaxPerMatchv99_Max, 0) as MaxPerMatchv99_Max,	
	
	IsNull(@MaxPerMatchv99MP_Max, 0) as MaxPerMatchv99MP_Max, -- mix parlays mixed sports 
	IsNull(@MaxPerMatchv161_Max, 0) as MaxPerMatchv161_Max,

	Isnull(@MaxPerBallv161_Max, 0)	 as MaxPerBallv161_Max,

	max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_1_max,
	max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_2_max,
	max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_3_max,
	max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_4_max,
	max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_5_max,
	max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_6_max,
	max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_7_max,
	max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_8_max,
	max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_9_max,
	max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_10_max,

	max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as mslivepositiontaking_1_max,
	max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as mslivepositiontaking_3_max,
	max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as mslivepositiontaking_7_max,
	max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as mslivepositiontaking_8_max,

	max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_1_max,
	max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_2_max,
	max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_3_max,
	max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_7_max,
	max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_8_max,
	--max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_9_max,
	max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_20_max,

	max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3mspositiontaking_1_max,
	max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3mspositiontaking_2_max,
	max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3mspositiontaking_3_max,
	max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3mspositiontaking_20_max,

	max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5mspositiontaking_1_max,
	max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5mspositiontaking_2_max,
	max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5mspositiontaking_3_max,
	max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5mspositiontaking_20_max,

	max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8mspositiontaking_1_max,
	max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8mspositiontaking_3_max,
	max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8mspositiontaking_20_max,

	max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10mspositiontaking_1_max,
	max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10mspositiontaking_2_max,
	max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10mspositiontaking_3_max,
	max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10mspositiontaking_20_max,

	max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v11mspositiontaking_1_max,
	max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v11mspositiontaking_20_max,
	
	max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99mspositiontaking_1_max,
	max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99mspositiontaking_2_max,
	max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99mspositiontaking_3_max,
	max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99mspositiontaking_9_max,
	max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99mspositiontaking_20_max,
	
	
		
	--v161
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then case when cs3.spositiontaking<co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end) as v161mspositiontaking_81_max,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then case when cs3.spositiontaking<co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end) as v161mspositiontaking_83_max,
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.spositiontaking<co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end) as v161mspositiontaking_85_max,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.spositiontaking<co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end) as v161mspositiontaking_86_max,
	
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.slivepositiontaking<co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161mslivepositiontaking_85_max,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.slivepositiontaking<co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161mslivepositiontaking_86_max,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then case when cs3.slivepositiontaking<co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161mslivepositiontaking_87_max,
		
		
	max(case when co.bettype = 1 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_3_min,
	max(case when co.bettype = 4 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_4_min,
	max(case when co.bettype = 5 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_5_min,
	max(case when co.bettype = 6 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_6_min,
	max(case when co.bettype = 7 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_7_min,
	max(case when co.bettype = 8 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_8_min,
	max(case when co.bettype = 9 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_9_min,
	max(case when co.bettype = 10 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_10_min,

	max(case when co.bettype = 1 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as mslivepositiontaking_1_min,
	max(case when co.bettype = 3 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as mslivepositiontaking_3_min,
	max(case when co.bettype = 7 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as mslivepositiontaking_7_min,
	max(case when co.bettype = 8 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as mslivepositiontaking_8_min,

	max(case when co.bettype = 1 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_3_min,
	max(case when co.bettype = 7 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_7_min,
	max(case when co.bettype = 8 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_8_min,
	--max(case when co.bettype = 9 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_9_min,
	max(case when co.bettype = 20 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_20_min,
	
	max(case when co.bettype = 1 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mspositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mspositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mspositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mspositiontaking_20_min,
	
	max(case when co.bettype = 1 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mspositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mspositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mspositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mspositiontaking_20_min,
	
	max(case when co.bettype = 1 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8mspositiontaking_1_min,
	max(case when co.bettype = 3 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8mspositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8mspositiontaking_20_min,
	
	max(case when co.bettype = 1 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mspositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mspositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mspositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mspositiontaking_20_min,
	
	max(case when co.bettype = 1 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11mspositiontaking_1_min,
	max(case when co.bettype = 20 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11mspositiontaking_20_min,
	
	max(case when co.bettype = 1 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mspositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mspositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mspositiontaking_3_min,
	max(case when co.bettype = 9 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mspositiontaking_9_min,
	max(case when co.bettype = 20 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mspositiontaking_20_min,
	
	
	
	
	--v161
	max(case when co3.bettype = 81 and co3.sporttype=161 then co3.minpositiontaking else 0 end) as v161mspositiontaking_81_min,
	max(case when co3.bettype = 83 and co3.sporttype=161 then co3.minpositiontaking else 0 end) as v161mspositiontaking_83_min,
	max(case when co3.bettype = 85 and co3.sporttype=161 then co3.minpositiontaking else 0 end) as v161mspositiontaking_85_min,
	max(case when co3.bettype = 86 and co3.sporttype=161 then co3.minpositiontaking else 0 end) as v161mspositiontaking_86_min,
	
	max(case when co3.bettype = 85 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161mslivepositiontaking_85_min,	
	max(case when co3.bettype = 86 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161mslivepositiontaking_86_min,	
	max(case when co3.bettype = 87 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161mslivepositiontaking_87_min	
From 
	CustSetting as cs with (NOLOCK)
	LEFT JOIN custoverride as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
	INNER JOIN CustSetting3rd as cs3 with (NOLOCK) on cs3.custid = cs.custid 
	LEFT JOIN CustOverride3rd as co3 with (NOLOCK) on co3.custid = cs3.custid and co3.sporttype = cs3.sporttype and co3.bettype = cs3.bettype
Where cs.CustID = @CustID



GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSAgentInfo_xtest] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSAgentInfo_xtest] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSAgentInfo_xtest] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSAgentInfo_xtest] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelSAgentInfo_xtest] TO [vnteam] 