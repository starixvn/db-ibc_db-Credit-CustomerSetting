ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgent_MinMaxBet]
	@custid int,-- agentID
	
	@minbet money,
	@maxbet money,
	@maxpermatch money,
	
	@minbetv2 money,
	@maxbetv2 money,
	@maxpermatchv2 money,
	
	@minbetv3 money,
	@maxbetv3 money,
	@maxpermatchv3 money,
	
	@minbetv5 money,
	@maxbetv5 money,
	@maxpermatchv5 money,
	
	@minbetv8 money,
	@maxbetv8 money,
	@maxpermatchv8 money,
	
	@minbetv10 money,
	@maxbetv10 money,
	@maxpermatchv10 money,
	
	@minbetv11 money,
	@maxbetv11 money,
	@maxpermatchv11 money,

	@minbetv99 money,
	@maxbetv99 money,
	@maxpermatchv99 money,	

	--- mixed sports
	@minbetv99mp money,
	@maxbetv99mp money,
	@maxpermatchv99mp money,
	
	--- soccer sports
	@minbetv1mp money,
	@maxbetv1mp money,
	@maxpermatchv1mp money,
	
	@MinBetv154 MONEY = 0,
	@MaxBetv154 MONEY = 0,
	@MaxPerMatchv154 MONEY = 0,
	
	-- number game
	@minbetv161 money,
	@maxbetv161 money,
	@maxpermatchv161 money,

	@MaxPerBallv161 money = 0,	

	@UpdateMultiple bit = 0,	
	
	@UpdateMinMaxBet bit = 1,
	@UpdateMinMaxBetv2 bit = 1,
	@UpdateMinMaxBetv3 bit = 1,
	@UpdateMinMaxBetv5 bit = 1,
	@UpdateMinMaxBetv8 bit = 1,
	@UpdateMinMaxBetv10 bit = 1,
	@UpdateMinMaxBetv11 bit = 1,
	@UpdateMinMaxBetv99 bit = 1,

	-- mixed sports
	@UpdateMinMaxBetv99MP bit = 1,
	
	@UpdateMinMaxBetv1MP bit = 1,
	
	@UpdateMinMaxBetv154 bit = 1,
	-- number game
	@UpdateMinMaxBetv161 bit = 1,
		
	@SubAccID int = 0, --Sub-AccountID	
	
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
as
--@Source Control
/*
Created: 20080515@Thien
Task : Update Agent MinBet, MaxBet, MaxPerMatch
DB: DBTXN/bodb02
Original:[Acc_CustomerUpdAgent_MinMaxBet]

Revisions:
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
					Write log subaccname instead of subaccid.	
	- 20090917@Phuc: write log into DBLOG.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100909@Lukas:	- Add Number game bet setting
						- Add Mixed sports bet setting
	- 20101019@Henry: Record execution time
	- 20101027@Lukas: add max per ball (number game)
	- 20101208@Lukas: Remove MaxPerBall constraint (MaxBet <= MaxPerBall <= MaxPerMatch)
	- 20110427@Simon: Add Popup Message For Betting Limit.
	- 20110511@Amy: change SP name Age_CustomerSelMinMax to Acc_
	- 20110606@Amy: Write Log Olv values
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Change linked server DB03 to DBONUSER; Write more log on DBTXN server in case of DBLOG server failure
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20150714@Johnson: Write log value from db if not change when update multiple [Redmine: #39555]
	- 20160309@Winnie: fix bug #53635 [Master edit agent: Log for bet setting is generated when updating without any change]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

Declare 
	@MinMinBet money, @MaxMaxBet money,	@MaxMaxPerMatch money,
	@MinMinBetv2 money, @MaxMaxBetv2 money, @MaxMaxPerMatchv2 money,
	@MinMinBetv3 money, @MaxMaxBetv3 money, @MaxMaxPerMatchv3 money,
	@MinMinBetv5 money, @MaxMaxBetv5 money, @MaxMaxPerMatchv5 money,
	@MinMinBetv8 money, @MaxMaxBetv8 money, @MaxMaxPerMatchv8 money,
	@MinMinBetv10 money, @MaxMaxBetv10 money, @MaxMaxPerMatchv10 money,
	@MinMinBetv11 money, @MaxMaxBetv11 money, @MaxMaxPerMatchv11 money,
	@MinMinBetv99 money, @MaxMaxBetv99 money, @MaxMaxPerMatchv99 money,
	@MinMinBetv99MP money, @MaxMaxBetv99MP money, @MaxMaxPerMatchv99MP money,
	@MinMinBetv1MP money, @MaxMaxBetv1MP money, @MaxMaxPerMatchv1MP money,
	@MinMinBetv154 money, @MaxMaxBetv154 money, @MaxMaxPerMatchv154 money,
	@MinMinBetv161 money, @MaxMaxBetv161 money, @MaxMaxPerMatchv161 money,
	@MaxMaxPerBallv161 money
	
declare @ErrAcc varchar(4000), @ErrType varchar(4000),
		@UserName varchar(30), @mrecommend int

Select @UserName = username, @mrecommend = mrecommend
from customer with (NOLOCK)
where CustID = @CustID


if @UpdateMinMaxBet = 1 or @UpdateMultiple = 0
BEGIN
	if 
		@MinBet<0
		or @MaxBet < 0
		or @MaxPerMatch <0
	BEGIN
		select @ErrCode = 2
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Soccer).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
					end
		return
	END
END


if @UpdateMinMaxBetv1MP = 1 or @UpdateMultiple = 0
BEGIN
	if 
		@minbetv1mp<0
		or @maxbetv1mp < 0
		or @maxpermatchv1mp <0
	BEGIN
		select @ErrCode = 2
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Soccer Parlay).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
					end
		return
	END
END

if @UpdateMinMaxBetv2 = 1 or @UpdateMultiple = 0
BEGIN
	if 
		@MinBetv2 <0
		or @MaxBetv2 <0
		or @MaxPerMatchv2 <0
	BEGIN
		select @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Basketball).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'					
					end
		return
	END
END

if @UpdateMinMaxBetv3 = 1 or @UpdateMultiple = 0
BEGIN
	if 
		@MinBetv3 <0
		or @MaxBetv3 <0
		or @MaxPerMatchv3 <0
	BEGIN
		select @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Football).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
					end
		return
	END
END

if @UpdateMinMaxBetv5 = 1 or @UpdateMultiple = 0
BEGIN
	if 
		@MinBetv5 <0
		or @MaxBetv5 <0
		or @MaxPerMatchv5 <0
	BEGIN
		select @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Tennis).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
					end
		return
	END
END

if @UpdateMinMaxBetv8 = 1 or @UpdateMultiple = 0
BEGIN
	if 
		@MinBetv8 <0
		or @MaxBetv8 <0
		or @MaxPerMatchv8 <0
	BEGIN
		select @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Baseball).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
					end
		return
	END
END

if @UpdateMinMaxBetv10 = 1 or @UpdateMultiple = 0
BEGIN
	if 
		@MinBetv10 <0
		or @MaxBetv10 <0
		or @MaxPerMatchv10 <0
	BEGIN
		select @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Golf).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
					end
		return
	END
END

if @UpdateMinMaxBetv11 = 1 or @UpdateMultiple = 0
BEGIN
	if 
		@MinBetv11 <0
		or @MaxBetv11 <0
		or @MaxPerMatchv11 <0
	BEGIN
		select @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Motorsports).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
					end
		return
	END
END

if @UpdateMinMaxBetv99 = 1 or @UpdateMultiple = 0
BEGIN
	if 
		@MinBetv99 <0
		or @MaxBetv99 <0
		or @MaxPerMatchv99 <0
	BEGIN
		select @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Other Sports).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
					end
		return
	END
END

--- mixed sports
if @UpdateMinMaxBetv99MP = 1 or @UpdateMultiple = 0
BEGIN
	if 
		@MinBetv99MP<0
		or @MaxBetv99MP <0
		or @MaxPerMatchv99MP <0
	BEGIN
		select @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Mix Sports Parlay).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + case @Language 
																							when 'CS' then N'(供混合体育过关)'
																							when 'CT' then N'(供混合體育過關)'
																							when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																							when 'J' then N'(Mix Sports Parlay)'
																							when 'KO' then N'(Mix Sports Parlay)'
																							when 'VI' then N'(Mix Sports Parlay)'
																							else N'(Mix Sports Parlay)' END
					end
		return
	END
END

if @UpdateMinMaxBetv154 = 1 or @UpdateMultiple = 0
BEGIN
	if 
		@MinBetv154 <0
		or @MaxBetv154 <0
		or @MaxPerMatchv154 <0
	BEGIN
		select @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for HR Fixed Odds).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
					end
		return
	END
END

--- number game
if @UpdateMinMaxBetv161 = 1 or @UpdateMultiple = 0
BEGIN
	if 
		@MinBetv161<0
		or @MaxBetv161 <0
		or @MaxPerMatchv161 <0
	BEGIN
		select @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Number Game).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
					end
		return
	END

	-- max per ball
	if @MaxPerBallv161 < 0
	begin
		select @ErrCode = 3
		Select @ErrMsg = 	case @Language 
					when 'E' then 'Wrong Max Per Ball (Number Game).'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](10002,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
			end
		return
	end
END

Select @MinMinBet = 0, @MaxMaxBet = 0,
	@MinMinBetv2 = 0, @MaxMaxBetv2 = 0,
	@MinMinBetv3 = 0, @MaxMaxBetv3 = 0,
	@MinMinBetv5 = 0, @MaxMaxBetv5 = 0,
	@MinMinBetv8 = 0, @MaxMaxBetv8 = 0,
	@MinMinBetv10 = 0, @MaxMaxBetv10 = 0,
	@MinMinBetv11 = 0, @MaxMaxBetv11 = 0,
	@MinMinBetv99 = 0, @MaxMaxBetv99 = 0,
	@MinMinBetv99MP = 0, @MaxMaxBetv99MP = 0,
	@MinMinBetv1MP = 0, @MaxMaxBetv1MP = 0,
	@MinMinBetv154 = 0, @MaxMaxBetv154 = 0,
	@MinMinBetv161 = 0, @MaxMaxBetv161 = 0

Select 
	@MinMinBet = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBet = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=1
where ci.custid = @MRecommend

Select 
	@MinMinBetv2 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv2 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=2
where ci.custid = @MRecommend

Select 
	@MinMinBetv3 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv3 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=3
where ci.custid = @MRecommend

Select 
	@MinMinBetv5 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv5 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=5
where ci.custid = @MRecommend

Select 
	@MinMinBetv8 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv8 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=8
where ci.custid = @MRecommend

Select 
	@MinMinBetv10 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv10 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=10
where ci.custid = @MRecommend

Select 
	@MinMinBetv11 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv11 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=11
where ci.custid = @MRecommend

Select 
	@MinMinBetv99 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv99 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=99
where ci.custid = @MRecommend

-- mixed sports
Select 
	@MinMinBetv99MP = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv99MP = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 9 and cs.sporttype=99
where ci.custid = @MRecommend

-- soccer sports
Select 
	@MinMinBetv1MP = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv1MP = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 9 and cs.sporttype=1
where ci.custid = @MRecommend

Select 
	@MinMinBetv154 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv154 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 20 and cs.sporttype=154
where ci.custid = @MRecommend

-- number game
Select 
	@MinMinBetv161 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv161 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting3rd as cs3 WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs3.CustID = ci.MRecommend or cs3.CustID = ci.SRecommend) and cs3.bettype = 81 and cs3.sporttype=161
where ci.custid = @MRecommend

Select	
	@MaxMaxperMatch = isnull(Min(case when cs.MaxPerMatch = 0 then NULL else cs.MaxPerMatch end),0), 
	@MaxMaxPerMatchv2 = isnull(Min(case when cs.MaxPerMatch2 = 0 then NULL else cs.MaxPerMatch2 end),0),
	@MaxMaxPerMatchv3 = isnull(Min(case when cs.MaxPerMatch3 = 0 then NULL else cs.MaxPerMatch3 end),0),
	@MaxMaxPerMatchv5 = isnull(Min(case when cs.MaxPerMatch5 = 0 then NULL else cs.MaxPerMatch5 end),0),
	@MaxMaxPerMatchv8 = isnull(Min(case when cs.MaxPerMatch8 = 0 then NULL else cs.MaxPerMatch8 end),0),
	@MaxMaxPerMatchv10 = isnull(Min(case when cs.MaxPerMatch10 = 0 then NULL else cs.MaxPerMatch10 end),0),
	@MaxMaxPerMatchv11 = isnull(Min(case when cs.MaxPerMatch11 = 0 then NULL else cs.MaxPerMatch11 end),0),
	@MaxMaxPerMatchv99 = isnull(Min(case when cs.MaxPerMatch99 = 0 then NULL else cs.MaxPerMatch99 end),0),
	@MaxMaxPerMatchv99MP = isnull(Min(case when cs.MaxPerMatch99MP = 0 then NULL else cs.MaxPerMatch99MP end),0),	
	@MaxMaxPerMatchv1MP = isnull(Min(case when cs.MaxPerMatch1MP = 0 then NULL else cs.MaxPerMatch1MP end),0),	
	@MaxMaxPerMatchv154 = isnull(Min(case when cs.MaxPerMatch154 = 0 then NULL else cs.MaxPerMatch154 end),0),
	@MaxMaxPerMatchv161 = isnull(Min(case when cs.MaxPerMatch161 = 0 then NULL else cs.MaxPerMatch161 end),0),
	@MaxMaxPerBallv161 = isnull(Min(case when cs.MaxPerBall161 = 0 then NULL else cs.MaxPerBall161 end),0)
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
where ci.custid = @CustID

if @UpdateMultiple = 0 or @UpdateMinMaxBet = 1
BEGIN

	if (@MinBet<>0 and @MaxBet <> 0 and  @MinBet>@MaxBet) or (@MaxBet<> 0 and @MaxPerMatch <> 0 and @MaxBet>@MaxPerMatch) 
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Soccer)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBet) + '-' + convert(varchar(20), @MaxBet) + '-' + convert(varchar(20), @MaxPerMatch), @ErrCode = 109					 
		
		return
	END

	if (@MinMinBet>0 and @MinBet>0 and @MinBet<@MinMinBet)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet (for Soccer)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MinMinBet) + ').', @ErrCode = 110				 
		
		return
	END
	
	if (@MaxMaxBet>0 and @MaxBet>0 and @MaxBet>@MaxMaxBet)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet (for Soccer)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxBet) + ').', @ErrCode = 111					 
		
		return
	END
	
	if (@MaxMaxPerMatch>0 and @MaxPerMatch>0 and @MaxPerMatch>@MaxMaxPerMatch)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match (for Soccer)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatch) + ').', @ErrCode = 111					 
		
		return
	END
END

-- soccer Parlay
if @UpdateMultiple = 0 or @UpdateMinMaxBetv1MP = 1
BEGIN

	if (@minbetv1mp<>0 and @maxbetv1mp <> 0 and  @minbetv1mp>@maxbetv1mp) or (@maxbetv1mp<> 0 and @maxpermatchv1mp <> 0 and @maxbetv1mp>@maxpermatchv1mp) 
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Soccer Parlay)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
						end						
						+ char(13) + char(10) + convert(varchar(20), @minbetv1mp) + '-' + convert(varchar(20), @maxbetv1mp) + '-' + convert(varchar(20), @maxpermatchv1mp), @ErrCode = 109					 
		
		return
	END

	if (@MinMinBetv1MP>0 and @minbetv1mp>0 and @minbetv1mp<@MinMinBetv1MP)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet (for Soccer Parlay)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MinMinBetv1MP) + ').', @ErrCode = 110				 
		
		return
	END
	
	if (@MaxMaxBetv1MP>0 and @maxbetv1mp>0 and @maxbetv1mp>@MaxMaxBetv1MP)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet (for Soccer Parlay)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxBetv1MP) + ').', @ErrCode = 111					 
		
		return
	END
	
	if (@MaxMaxPerMatchv1MP>0 and @maxpermatchv1mp>0 and @maxpermatchv1mp>@MaxMaxPerMatchv1MP)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match (for Soccer Parlay)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatchv1MP) + ').', @ErrCode = 111					 
		
		return
	END
END

if @UpdateMultiple = 0 or @UpdateMinMaxBetv2 = 1
BEGIN
	if (@MinBetv2 <> 0 and @MaxBetv2 <> 0 and @MinBetv2>@MaxBetv2) or (@MaxBetv2 <> 0 and @MaxPerMatchv2 <> 0 and @MaxBetv2>@MaxPerMatchv2)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Basketball)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBetv2) + '-' + convert(varchar(20), @MaxBetv2) + '-' + convert(varchar(20), @MaxPerMatchv2), @ErrCode = 112					 
		
		return
	END

	if (@MinMinBetv2>0 and @MinBetv2>0 and @MinBetv2<@MinMinBetv2)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet (for Basketball)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MinMinBetv2) + ').', @ErrCode = 113					 
		
		return
	END

	if (@MaxMaxBetv2>0 and @MaxBetv2>0 and @MaxBetv2>@MaxMaxBetv2)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet (for Basketball)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxBetv2) + ').', @ErrCode = 114					 
		
		return
	END
	if (@MaxMaxPerMatchv2>0 and @MaxPerMatchv2>0 and @MaxPerMatchv2>@MaxMaxPerMatchv2)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match (for Basketball)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatchv2) + ').', @ErrCode = 114					 
		
		return
	END
END

if @UpdateMultiple = 0 or @UpdateMinMaxBetv3 = 1
BEGIN
	if (@MinBetv3 <> 0 and @MaxBetv3 <> 0 and @MinBetv3>@MaxBetv3) or (@MaxBetv3 <> 0 and @MaxPerMatchv3 <> 0 and @MaxBetv3>@MaxPerMatchv3)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Football)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBetv3) + '-' + convert(varchar(20), @MaxBetv3) + '-' + convert(varchar(20), @MaxPerMatchv3), @ErrCode = 112					 
		
		return
	END

	if (@MinMinBetv3>0 and @MinBetv3>0 and @MinBetv3<@MinMinBetv3)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet (for Football)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MinMinBetv3) + ').', @ErrCode = 113					 
		
		return
	END

	if (@MaxMaxBetv3>0 and @MaxBetv3>0 and @MaxBetv3>@MaxMaxBetv3)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet (for Football)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxBetv3) + ').', @ErrCode = 114					 
		
		return
	END
	if (@MaxMaxPerMatchv3>0 and @MaxPerMatchv3>0 and @MaxPerMatchv3>@MaxMaxPerMatchv3)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match (for Football)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatchv3) + ').', @ErrCode = 114					 
		
		return
	END
END

if @UpdateMultiple = 0 or @UpdateMinMaxBetv5 = 1
BEGIN
	if (@MinBetv5 <> 0 and @MaxBetv5 <> 0 and @MinBetv5>@MaxBetv5) or (@MaxBetv5 <> 0 and @MaxPerMatchv5 <> 0 and @MaxBetv5>@MaxPerMatchv5)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Tennis)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBetv5) + '-' + convert(varchar(20), @MaxBetv5) + '-' + convert(varchar(20), @MaxPerMatchv5), @ErrCode = 112					 
		
		return
	END

	if (@MinMinBetv5>0 and @MinBetv5>0 and @MinBetv5<@MinMinBetv5)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet (for Tennis)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MinMinBetv5) + ').', @ErrCode = 113					 
		
		return
	END

	if (@MaxMaxBetv5>0 and @MaxBetv5>0 and @MaxBetv5>@MaxMaxBetv5)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet (for Tennis)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxBetv5) + ').', @ErrCode = 114					 
		
		return
	END
	if (@MaxMaxPerMatchv5>0 and @MaxPerMatchv5>0 and @MaxPerMatchv5>@MaxMaxPerMatchv5)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match (for Tennis)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatchv5) + ').', @ErrCode = 114					 
		
		return
	END
END

if @UpdateMultiple = 0 or @UpdateMinMaxBetv8 = 1
BEGIN
	if (@MinBetv8 <> 0 and @MaxBetv8 <> 0 and @MinBetv8>@MaxBetv8) or (@MaxBetv8 <> 0 and @MaxPerMatchv8 <> 0 and @MaxBetv8>@MaxPerMatchv8)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Baseball)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBetv8) + '-' + convert(varchar(20), @MaxBetv8) + '-' + convert(varchar(20), @MaxPerMatchv8), @ErrCode = 112					 
		
		return
	END

	if (@MinMinBetv8>0 and @MinBetv8>0 and @MinBetv8<@MinMinBetv8)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet (for Baseball)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MinMinBetv8) + ').', @ErrCode = 113					 
		
		return
	END

	if (@MaxMaxBetv8>0 and @MaxBetv8>0 and @MaxBetv8>@MaxMaxBetv8)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet (for Baseball)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxBetv8) + ').', @ErrCode = 114					 
		
		return
	END
	if (@MaxMaxPerMatchv8>0 and @MaxPerMatchv8>0 and @MaxPerMatchv8>@MaxMaxPerMatchv8)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match (for Baseball)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatchv8) + ').', @ErrCode = 114					 
		
		return
	END
END

if @UpdateMultiple = 0 or @UpdateMinMaxBetv10 = 1
BEGIN
	if (@MinBetv10 <> 0 and @MaxBetv10 <> 0 and @MinBetv10>@MaxBetv10) or (@MaxBetv10 <> 0 and @MaxPerMatchv10 <> 0 and @MaxBetv10>@MaxPerMatchv10)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Golf)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBetv10) + '-' + convert(varchar(20), @MaxBetv10) + '-' + convert(varchar(20), @MaxPerMatchv10), @ErrCode = 112					 
		
		return
	END

	if (@MinMinBetv10>0 and @MinBetv10>0 and @MinBetv10<@MinMinBetv10)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet (for Golf)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MinMinBetv10) + ').', @ErrCode = 113					 
		
		return
	END

	if (@MaxMaxBetv10>0 and @MaxBetv10>0 and @MaxBetv10>@MaxMaxBetv10)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet (for Golf)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxBetv10) + ').', @ErrCode = 114					 
		
		return
	END
	if (@MaxMaxPerMatchv10>0 and @MaxPerMatchv10>0 and @MaxPerMatchv10>@MaxMaxPerMatchv10)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match (for Golf)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatchv10) + ').', @ErrCode = 114					 
		
		return
	END
END

if @UpdateMultiple = 0 or @UpdateMinMaxBetv11 = 1
BEGIN
	if (@MinBetv11 <> 0 and @MaxBetv11 <> 0 and @MinBetv11>@MaxBetv11) or (@MaxBetv11 <> 0 and @MaxPerMatchv11 <> 0 and @MaxBetv11>@MaxPerMatchv11)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Motorsports)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBetv11) + '-' + convert(varchar(20), @MaxBetv11) + '-' + convert(varchar(20), @MaxPerMatchv11), @ErrCode = 112					 
		
		return
	END

	if (@MinMinBetv11>0 and @MinBetv11>0 and @MinBetv11<@MinMinBetv11)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet (for Motorsports)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MinMinBetv11) + ').', @ErrCode = 113					 
		
		return
	END

	if (@MaxMaxBetv11>0 and @MaxBetv11>0 and @MaxBetv11>@MaxMaxBetv11)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet (for Motorsports)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxBetv11) + ').', @ErrCode = 114					 
		
		return
	END
	if (@MaxMaxPerMatchv11>0 and @MaxPerMatchv11>0 and @MaxPerMatchv11>@MaxMaxPerMatchv11)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match (for Motorsports)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatchv11) + ').', @ErrCode = 114					 
		
		return
	END
END

if @UpdateMultiple = 0 or @UpdateMinMaxBetv99 = 1
BEGIN
	if (@MinBetv99 <> 0 and @MaxBetv99 <> 0 and @MinBetv99>@MaxBetv99) or (@MaxBetv99 <> 0 and @MaxPerMatchv99 <> 0 and @MaxBetv99>@MaxPerMatchv99)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Other sports)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBetv99) + '-' + convert(varchar(20), @MaxBetv99) + '-' + convert(varchar(20), @MaxPerMatchv99), @ErrCode = 112					 
		
		return
	END

	if (@MinMinBetv99>0 and @MinBetv99>0 and @MinBetv99<@MinMinBetv99)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet (for Other sports)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MinMinBetv99) + ').', @ErrCode = 113					 
		
		return
	END

	if (@MaxMaxBetv99>0 and @MaxBetv99>0 and @MaxBetv99>@MaxMaxBetv99)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet (for Other sports)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxBetv99) + ').', @ErrCode = 114					 
		
		return
	END
	if (@MaxMaxPerMatchv99>0 and @MaxPerMatchv99>0 and @MaxPerMatchv99>@MaxMaxPerMatchv99)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match (for Other sports)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatchv99) + ').', @ErrCode = 114					 
		
		return
	END
END


-- mixed sports
if @UpdateMultiple = 0 or @UpdateMinMaxBetv99MP = 1
BEGIN
	if (@MinBetv99MP <> 0 and @MaxBetv99MP <> 0 and @MinBetv99MP > @MaxBetv99MP) or (@MaxBetv99MP <> 0 and @MaxPerMatchv99MP <> 0 and @MaxBetv99MP>@MaxPerMatchv99MP)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Mix Sports Parlay)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + case @Language 
																							when 'CS' then N'(供混合体育过关)'
																							when 'CT' then N'(供混合體育過關)'
																							when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																							when 'J' then N'(Mix Sports Parlay)'
																							when 'KO' then N'(Mix Sports Parlay)'
																							when 'VI' then N'(Mix Sports Parlay)'
																							else N'(Mix Sports Parlay)' END
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBetv99MP) + '-' + convert(varchar(20), @MaxBetv99MP) + '-' + convert(varchar(20), @MaxPerMatchv99MP), @ErrCode = 112					 		
		return
	END

	if (@MinMinBetv99MP>0 and @MinBetv99MP>0 and @MinBetv99MP<@MinMinBetv99MP)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet (for Mix Sports Parlay)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language) + case @Language 
																							when 'CS' then N'(供混合体育过关)'
																							when 'CT' then N'(供混合體育過關)'
																							when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																							when 'J' then N'(Mix Sports Parlay)'
																							when 'KO' then N'(Mix Sports Parlay)'
																							when 'VI' then N'(Mix Sports Parlay)'
																							else N'(Mix Sports Parlay)' END
						end						
						+' (' + convert(varchar(20), @MinMinBetv99MP) + ').', @ErrCode = 113					 
		
		return
	END

	if (@MaxMaxBetv99MP>0 and @MaxBetv99MP>0 and @MaxBetv99MP>@MaxMaxBetv99MP)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet (for Mix Sports Parlay)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language) + case @Language 
																							when 'CS' then N'(供混合体育过关)'
																							when 'CT' then N'(供混合體育過關)'
																							when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																							when 'J' then N'(Mix Sports Parlay)'
																							when 'KO' then N'(Mix Sports Parlay)'
																							when 'VI' then N'(Mix Sports Parlay)'
																							else N'(Mix Sports Parlay)' END
						end						
						+' (' + convert(varchar(20), @MaxMaxBetv99MP) + ').', @ErrCode = 114					 
		
		return
	END
	if (@MaxMaxPerMatchv99MP>0 and @MaxPerMatchv99MP>0 and @MaxPerMatchv99MP>@MaxMaxPerMatchv99MP)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match (for Mix Sports Parlay)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language) + case @Language 
																							when 'CS' then N'(供混合体育过关)'
																							when 'CT' then N'(供混合體育過關)'
																							when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																							when 'J' then N'(Mix Sports Parlay)'
																							when 'KO' then N'(Mix Sports Parlay)'
																							when 'VI' then N'(Mix Sports Parlay)'
																							else N'(Mix Sports Parlay)' END
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatchv99MP) + ').', @ErrCode = 114					 
		
		return
	END
END

if @UpdateMultiple = 0 or @UpdateMinMaxBetv154 = 1
BEGIN
	if (@MinBetv154 <> 0 and @MaxBetv154 <> 0 and @MinBetv154>@MaxBetv154) or (@MaxBetv154 <> 0 and @MaxPerMatchv154 <> 0 and @MaxBetv154>@MaxPerMatchv154)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for HR Fixed Odds)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBetv154) + '-' + convert(varchar(20), @MaxBetv154) + '-' + convert(varchar(20), @MaxPerMatchv154), @ErrCode = 112					 
		
		return
	END

	if (@MinMinBetv154>0 and @MinBetv154>0 and @MinBetv154<@MinMinBetv154)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet (for HR Fixed Odds)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MinMinBetv154) + ').', @ErrCode = 113					 
		
		return
	END

	if (@MaxMaxBetv154>0 and @MaxBetv154>0 and @MaxBetv154>@MaxMaxBetv154)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet (for HR Fixed Odds)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxBetv154) + ').', @ErrCode = 114					 
		
		return
	END
	if (@MaxMaxPerMatchv154>0 and @MaxPerMatchv154>0 and @MaxPerMatchv154>@MaxMaxPerMatchv154)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match (for HR Fixed Odds)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatchv154) + ').', @ErrCode = 114					 
		
		return
	END
END

-- number game
if @UpdateMultiple = 0 or @UpdateMinMaxBetv161 = 1
BEGIN
	if (@MinBetv161 <> 0 and @MaxBetv161 <> 0 and @MinBetv161 > @MaxBetv161) or (@MaxBetv161 <> 0 and @MaxPerMatchv161 <> 0 and @MaxBetv161>@MaxPerMatchv161)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Number Game)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBetv161) + '-' + convert(varchar(20), @MaxBetv161) + '-' + convert(varchar(20), @MaxPerMatchv161), @ErrCode = 112					 		
		return
	END

	if (@MinMinBetv161>0 and @MinBetv161>0 and @MinBetv161<@MinMinBetv161)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet (for Number Game)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MinMinBetv161) + ').', @ErrCode = 113					 
		
		return
	END

	if (@MaxMaxBetv161>0 and @MaxBetv161>0 and @MaxBetv161>@MaxMaxBetv161)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet (for Number Game)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
						end
						+' (' + convert(varchar(20), @MaxMaxBetv161) + ').', @ErrCode = 114					 
		
		return
	END
	if (@MaxMaxPerMatchv161>0 and @MaxPerMatchv161>0 and @MaxPerMatchv161>@MaxMaxPerMatchv161)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match (for Number Game)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatchv161) + ').', @ErrCode = 114					 
		
		return
	END

	/*
	----- max per ball	
	if @MaxPerBallv161 < @MaxBetv161 or @MaxPerBallv161 > @MaxPerMatchv161 
	begin
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
							when 'CS' then N'单粒球最高投注必須大於或等於最高投注和低於或等於单场場游戏最高投注.'
							when 'CT' then N'單粒球最高投注必須大於或等於最高投注和低於或等於單場場遊戲最高投注.'
							when 'TH' then N'ขออภัย, ค่าสูงสุดต่อบอลต้องมากกว่าหรือเท่ากับการเดิมพันสูงสุด และน้อยกว่าหรือเท่ากับการตั้งค่าสูงสุดของการแข่งขัน.'
							when 'J' then N'Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
							when 'KO' then N'Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
							else N'Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
						end						
						+' (' + convert(varchar(20), @MaxPerBallv161) + ').', @ErrCode = 200	
			return
	end
	*/
	if @MaxPerBallv161 > @MaxMaxPerBallv161 and @MaxMaxPerBallv161 > 0
	begin
		SELECT @ErrMsg =	@UserName + ': '+
				case @Language 
					when 'E' then 'Max per ball must be equal to or less than Master Agent Max Per Ball (Number Game).'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](10011,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
				end						
				+' (' + convert(varchar(20), @MaxMaxPerBallv161) + ').', @ErrCode = 201
			return
	end
END
---------------------------------------------------------------

-- Get old minbet, old maxbet & old MaxPerMatch_Min before Update
Declare @old_MinBet money, @old_MaxBet money,	@old_MaxPerMatch money,
	@old_MinBetv2 money, @old_MaxBetv2 money, @old_MaxPerMatchv2 money,
	@old_MinBetv3 money, @old_MaxBetv3 money, @old_MaxPerMatchv3 money,
	@old_MinBetv5 money, @old_MaxBetv5 money, @old_MaxPerMatchv5 money,
	@old_MinBetv8 money, @old_MaxBetv8 money, @old_MaxPerMatchv8 money,
	@old_MinBetv10 money, @old_MaxBetv10 money, @old_MaxPerMatchv10 money,
	@old_MinBetv11 money, @old_MaxBetv11 money, @old_MaxPerMatchv11 money,	
	@old_MinBetv99 money, @old_MaxBetv99 money, @old_MaxPerMatchv99 money,
	@old_MinBetv99MP money, @old_MaxBetv99MP money, @old_MaxPerMatchv99MP money,
	@old_MinBetv1MP money, @old_MaxBetv1MP money, @old_MaxPerMatchv1MP money,
	@old_MinBetv154 money, @old_MaxBetv154 money, @old_MaxPerMatchv154 money,
	@old_MinBetv161 money, @old_MaxBetv161 money, @old_MaxPerMatchv161 money, @old_MaxPerBallv161 money
EXEC Acc_CustomerSelMinMax @custid,
	@MinBet = @old_MinBet output, @MaxBet = @old_MaxBet output, @MaxPerMatch =@old_MaxPerMatch output,
	@MinBetv2 = @old_MinBetv2 output, @MaxBetv2 =@old_MaxBetv2 output, @MaxPerMatchv2 =@old_MaxPerMatchv2 output,
	@MinBetv3 = @old_MinBetv3 output, @MaxBetv3 =@old_MaxBetv3 output, @MaxPerMatchv3 =@old_MaxPerMatchv3 output,
	@MinBetv5 = @old_MinBetv5 output, @MaxBetv5 =@old_MaxBetv5 output, @MaxPerMatchv5 =@old_MaxPerMatchv5 output,
	@MinBetv8 = @old_MinBetv8 output, @MaxBetv8 =@old_MaxBetv8 output, @MaxPerMatchv8 =@old_MaxPerMatchv8 output,
	@MinBetv10 = @old_MinBetv10 output, @MaxBetv10 =@old_MaxBetv10 output, @MaxPerMatchv10 =@old_MaxPerMatchv10 output,
	@MinBetv11 = @old_MinBetv11 output, @MaxBetv11 =@old_MaxBetv11 output, @MaxPerMatchv11 =@old_MaxPerMatchv11 output,
	@MinBetv99 = @old_MinBetv99 output, @MaxBetv99 =@old_MaxBetv99 output, @MaxPerMatchv99 =@old_MaxPerMatchv99 output,
	@MinBetv99MP = @old_MinBetv99MP output, @MaxBetv99MP =@old_MaxBetv99MP output, @MaxPerMatchv99MP =@old_MaxPerMatchv99MP output,
	@MinBetv1MP = @old_MinBetv1MP output, @MaxBetv1MP =@old_MaxBetv1MP output, @MaxPerMatchv1MP =@old_MaxPerMatchv1MP output,
	@MinBetv154 = @old_MinBetv154 output, @MaxBetv154 = @old_MaxBetv154 output, @MaxPerMatchv154 =@old_MaxPerMatchv154 output,    
	@MinBetv161 = @old_MinBetv161 output, @MaxBetv161 =@old_MaxBetv161 output, @MaxPerMatchv161 =@old_MaxPerMatchv161 output, @MaxPerBallv161 =@old_MaxPerBallv161 output
IF 	@Old_MinBet = @MinBet AND @Old_MaxBet = @MaxBet AND	@Old_MaxPerMatch = @MaxPerMatch AND
	@Old_MinBetv2 = @MinBetv2 AND @Old_MaxBetv2 = @MaxBetv2 AND @Old_MaxPerMatchv2 = @MaxPerMatchv2 AND
	@Old_MinBetv3 = @MinBetv3 AND @Old_MaxBetv3 = @MaxBetv3 AND @Old_MaxPerMatchv3 = @MaxPerMatchv3 AND
	@Old_MinBetv5 = @MinBetv5 AND @Old_MaxBetv5 = @MaxBetv5 AND @Old_MaxPerMatchv5 = @MaxPerMatchv5 AND
	@Old_MinBetv8 = @MinBetv8 AND @Old_MaxBetv8 = @MaxBetv8 AND @Old_MaxPerMatchv8 = @MaxPerMatchv8 AND
	@Old_MinBetv10 = @MinBetv10 AND @Old_MaxBetv10 = @MaxBetv10 AND @Old_MaxPerMatchv10 = @MaxPerMatchv10 AND
	@Old_MinBetv11 = @MinBetv11 AND @Old_MaxBetv11 = @MaxBetv11 AND @Old_MaxPerMatchv11 = @MaxPerMatchv11 AND
	@Old_MinBetv99 = @MinBetv99 AND @Old_MaxBetv99 = @MaxBetv99 AND @Old_MaxPerMatchv99 = @MaxPerMatchv99 AND
	@Old_MinBetv99MP = @MinBetv99MP AND @Old_MaxBetv99MP = @MaxBetv99MP AND @Old_MaxPerMatchv99MP = @MaxPerMatchv99MP AND
	@Old_MinBetv1MP = @MinBetv1MP AND @Old_MaxBetv1MP = @MaxBetv1MP AND @Old_MaxPerMatchv1MP = @MaxPerMatchv1MP AND
	@Old_MinBetv154 = @MinBetv154 AND @Old_MaxBetv154 = @MaxBetv154 AND @Old_MaxPerMatchv154 = @MaxPerMatchv154 AND	
	@Old_MinBetv161 = @MinBetv161 AND @Old_MaxBetv161 = @MaxBetv161 AND @Old_MaxPerMatchv161 = @MaxPerMatchv161 AND
	@Old_MaxPerBallv161 = @MaxPerBallv161 RETURN	
---------------------------------------------------------------------------------------------------		
update custsetting with (ROWLOCK, UPDLOCK)
set
	MinBet = case when @UpdateMultiple = 1 and ((@UpdateMinMaxBet = 0 and sporttype=1 AND bettype <> 9) or (@UpdateMinMaxBetv2 = 0 and sporttype=2) or (@UpdateMinMaxBetv3 = 0 and sporttype=3) or (@UpdateMinMaxBetv5 = 0 and sporttype=5) or (@UpdateMinMaxBetv8 = 0 and sporttype=8) or (@UpdateMinMaxBetv10 = 0 and sporttype=10) or (@UpdateMinMaxBetv11 = 0 and sporttype=11)  or (@UpdateMinMaxBetv99 = 0 and sporttype=99 and bettype <> 9) or (@UpdateMinMaxBetv99MP = 0 and sporttype=99 and bettype = 9) or (@UpdateMinMaxBetv1MP = 0 and sporttype=1 and bettype = 9)OR (@UpdateMinMaxBetv154 = 0 and sporttype=154)) then MinBet else case sporttype when 1 then (case when bettype = 9 then @MinBetv1MP else @MinBet end)  when 2 then @MinBetv2 when 3 then @MinBetv3 when 5 then @MinBetv5 when 8 then @MinBetv8 when 10 then @MinBetv10 when 11 then @MinBetv11 when 154 then @MinBetv154 when 99 then (case when bettype = 9 then @MinBetv99MP else @MinBetv99 end) else minbet end end,																																																																																																																																																		
	MaxBet = case when @UpdateMultiple = 1 and ((@UpdateMinMaxBet = 0 and sporttype=1 AND bettype <> 9) or (@UpdateMinMaxBetv2 = 0 and sporttype=2)  or (@UpdateMinMaxBetv3 = 0 and sporttype=3) or (@UpdateMinMaxBetv5 = 0 and sporttype=5) or (@UpdateMinMaxBetv8 = 0 and sporttype=8) or (@UpdateMinMaxBetv10 = 0 and sporttype=10) or (@UpdateMinMaxBetv11 = 0 and sporttype=11) or (@UpdateMinMaxBetv99 = 0 and sporttype=99 and bettype <> 9) or (@UpdateMinMaxBetv99MP = 0 and sporttype=99 and bettype = 9) or (@UpdateMinMaxBetv1MP = 0 and sporttype=1 and bettype = 9) OR (@UpdateMinMaxBetv154 = 0 and sporttype=154)) then MaxBet else case sporttype when 1 then (case when bettype = 9 then @MaxBetv1MP else @MaxBet end)  when 2 then @MaxBetv2 when 3 then @MaxBetv3 when 5 then @MaxBetv5 when 8 then @MaxBetv8 when 10 then @MaxBetv10 when 11 then @MaxBetv11 when 154 then @MaxBetv154 when 99 then (case when bettype = 9 then @MaxBetv99MP else @MaxBetv99 end) else maxbet end end
where custid=@custid
if (@@error <> 0)
begin
	
	Select @ErrMsg = @UserName + ': '+
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end, @ErrCode = 115	
	return
end


--- number game
update custsetting3rd with (ROWLOCK, UPDLOCK)
set
	MinBet = case when @UpdateMultiple = 1 and ((@UpdateMinMaxBetv161 = 0 and sporttype=161)) then MinBet else case when sporttype = 161 then @MinBetv161 else Minbet end end,
	MaxBet = case when @UpdateMultiple = 1 and ((@UpdateMinMaxBetv161 = 0 and sporttype=161)) then MaxBet else case when sporttype = 161 then @MaxBetv161 else Maxbet end end
where custid=@custid
if (@@error <> 0)
begin
	
	Select @ErrMsg = @UserName + ': '+
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end, @ErrCode = 115	
	return
end

EXEC dbo.Acc_CustomerUpdMaxPerMatch 
	@custid = @custid,
	@maxpermatch = @maxpermatch,
	@maxpermatchv2 = @maxpermatchv2,
	@maxpermatchv3 = @maxpermatchv3,
	@maxpermatchv5 = @maxpermatchv5,
	@maxpermatchv8 = @maxpermatchv8,
	@maxpermatchv10 = @maxpermatchv10,
	@maxpermatchv11 = @maxpermatchv11,
	@maxpermatchv99 = @maxpermatchv99,
	@maxpermatchv154 = @maxpermatchv154,
	@maxpermatchv99MP = @maxpermatchv99MP,
	@maxpermatchv1MP = @maxpermatchv1MP,
	@maxpermatchv161 = @maxpermatchv161,
	@UpdateMultiple = @UpdateMultiple,
	@UpdateMinMaxBet = @UpdateMinMaxBet,
	@UpdateMinMaxBetv2 = @UpdateMinMaxBetv2,
	@UpdateMinMaxBetv3 = @UpdateMinMaxBetv3,
	@UpdateMinMaxBetv5 = @UpdateMinMaxBetv5,
	@UpdateMinMaxBetv8 = @UpdateMinMaxBetv8,
	@UpdateMinMaxBetv10 = @UpdateMinMaxBetv10,
	@UpdateMinMaxBetv11 = @UpdateMinMaxBetv11,
	@UpdateMinMaxBetv99 = @UpdateMinMaxBetv99,
	@UpdateMinMaxBetv99MP = @UpdateMinMaxBetv99MP,
	@UpdateMinMaxBetv1MP = @UpdateMinMaxBetv1MP,
	@UpdateMinMaxBetv154 = @UpdateMinMaxBetv154,
	@UpdateMinMaxBetv161 = @UpdateMinMaxBetv161,
	@Language = @Language,
	@ErrCode = @ErrCode OUTPUT,
	@ErrMsg = @ErrMsg OUTPUT
	if @ErrCode > 0
	BEGIN
		return
	END

exec dbo.Acc_CustomerUpdMaxPerBall
	@custid = @custid,
	@MaxPerBallv161 = @MaxPerBallv161,
	@UpdateMultiple = @UpdateMultiple,
	@UpdateMinMaxBetv161 = @UpdateMinMaxBetv161,
	@Language = @Language,
	@ErrCode = @ErrCode output,
	@ErrMsg = @ErrMsg output
if @ErrCode > 0
begin
	return
end

-- Compare old value & new value Betting Limit: Popup Message For Betting Limit 
IF (@MinBet != @old_MinBet OR @MaxBet != @old_MaxBet OR @MaxPerMatch != @old_MaxPerMatch
	OR @MinBetv2 != @old_MinBetv2 OR @MaxBetv2 != @old_MaxBetv2 OR @MaxPerMatchv2 != @old_MaxPerMatchv2
	OR @MinBetv3 != @old_MinBetv3 OR @MaxBetv3 != @old_MaxBetv3 OR @MaxPerMatchv3 != @old_MaxPerMatchv3
	OR @MinBetv5 != @old_MinBetv5 OR @MaxBetv5 != @old_MaxBetv5 OR @MaxPerMatchv5 != @old_MaxPerMatchv5
	OR @MinBetv8 != @old_MinBetv8 OR @MaxBetv8 != @old_MaxBetv8 OR @MaxPerMatchv8 != @old_MaxPerMatchv8
	OR @MinBetv10 != @old_MinBetv10 OR @MaxBetv10 != @old_MaxBetv10 OR @MaxPerMatchv10 != @old_MaxPerMatchv10
	OR @MinBetv11 != @old_MinBetv11 OR @MaxBetv11 != @old_MaxBetv11 OR @MaxPerMatchv11 != @old_MaxPerMatchv11
	OR @MinBetv99 != @old_MinBetv99 OR @MaxBetv99 != @old_MaxBetv99 OR @MaxPerMatchv99 != @old_MaxPerMatchv99
	OR @MinBetv99MP != @old_MinBetv99MP OR @MaxBetv99MP != @old_MaxBetv99MP OR @MaxPerMatchv99MP != @old_MaxPerMatchv99MP
	OR @MinBetv1MP != @old_MinBetv1MP OR @MaxBetv1MP != @old_MaxBetv1MP OR @MaxPerMatchv1MP != @old_MaxPerMatchv1MP
	OR @MinBetv154 != @old_MinBetv154 OR @MaxBetv154 != @old_MaxBetv154 OR @MaxPerMatchv154 != @old_MaxPerMatchv154
	OR @MinBetv161 != @old_MinBetv161 OR @MaxBetv161 != @old_MaxBetv161 OR @MaxPerMatchv161 != @old_MaxPerMatchv161 OR @MaxPerBallv161 != @old_MaxPerBallv161)
BEGIN
	EXEC DBONUSER.On_User.dbo.Age_MessageNoticeUpd @custID = @custid, @userID = @UserID, @TypeID = 2
END	

Declare @LogSPData varchar(8000)
Declare @TrackingValue2 varchar(8000)


----------
-- 20150714@Johnson: Write log value from db if not change when update multiple [Redmine: #39555]
---------------------------------
SELECT @minbet = MAX(CASE WHEN sporttype = 1 AND bettype <> 9 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBet = 0 
											THEN minbet ELSE @minbet END) 
							ELSE 0 END),
	@maxbet = MAX(CASE WHEN sporttype = 1 AND bettype <> 9 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBet = 0 
											THEN maxbet ELSE @maxbet END) 
							ELSE 0 END),
	
	@minbetv2 = MAX(CASE WHEN sporttype = 2 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv2 = 0 
											THEN minbet ELSE @minbetv2 END) 
							ELSE 0 END),
	@maxbetv2 = MAX(CASE WHEN sporttype = 2 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv2 = 0 
											THEN maxbet ELSE @maxbetv2 END) 
							ELSE 0 END),

	@minbetv3 = MAX(CASE WHEN sporttype = 3 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv3 = 0 
											THEN minbet ELSE @minbetv3 END) 
							ELSE 0 END),
	@maxbetv3 = MAX(CASE WHEN sporttype = 3 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv3 = 0 
											THEN maxbet ELSE @maxbetv3 END) 
							ELSE 0 END),
								
	@minbetv5 = MAX(CASE WHEN sporttype = 5 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv5 = 0 
											THEN minbet ELSE @minbetv5 END) 
							ELSE 0 END),
	@maxbetv5 = MAX(CASE WHEN sporttype = 5 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv5 = 0 
											THEN maxbet ELSE @maxbetv5 END) 
							ELSE 0 END),

	@minbetv8 = MAX(CASE WHEN sporttype = 8 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv8 = 0 
											THEN minbet ELSE @minbetv8 END) 
							ELSE 0 END),
	@maxbetv8 = MAX(CASE WHEN sporttype = 8 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv8 = 0 
											THEN maxbet ELSE @maxbetv8 END) 
							ELSE 0 END),

	@minbetv10 = MAX(CASE WHEN sporttype = 10 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv10 = 0 
											THEN minbet ELSE @minbetv10 END) 
							ELSE 0 END),
	@maxbetv10 = MAX(CASE WHEN sporttype = 10 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv10 = 0 
											THEN maxbet ELSE @maxbetv10 END) 
							ELSE 0 END),
	
	@minbetv11 = MAX(CASE WHEN sporttype = 11 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv11 = 0 
											THEN minbet ELSE @minbetv11 END) 
							ELSE 0 END),
	@maxbetv11 = MAX(CASE WHEN sporttype = 11 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv11 = 0 
											THEN maxbet ELSE @maxbetv11 END) 
							ELSE 0 END),
	
	@minbetv99 = MAX(CASE WHEN sporttype = 99 AND bettype <> 9 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv99 = 0 
											THEN minbet ELSE @minbetv99 END) 
							ELSE 0 END),
	@maxbetv99 = MAX(CASE WHEN sporttype = 99 AND bettype <> 9 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv99 = 0 
											THEN maxbet ELSE @maxbetv99 END) 
							ELSE 0 END),
	
	@minbetv99mp = MAX(CASE WHEN sporttype = 99 AND bettype = 9 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv99mp = 0 
											THEN minbet ELSE @minbetv99mp END) 
							ELSE 0 END),
	@maxbetv99mp = MAX(CASE WHEN sporttype = 99 AND bettype = 9 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv99mp = 0 
											THEN maxbet ELSE @maxbetv99mp END) 
							ELSE 0 END),
	
	
	@minbetv1mp = MAX(CASE WHEN sporttype = 1 AND bettype = 9 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv1mp = 0 
											THEN minbet ELSE @minbetv1mp END) 
							ELSE 0 END),
	@maxbetv1mp = MAX(CASE WHEN sporttype = 1 AND bettype = 9 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv1mp = 0 
											THEN maxbet ELSE @maxbetv1mp END) 
							ELSE 0 END),
	
							
	@minbetv154 = MAX(CASE WHEN sporttype = 154 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv154 = 0 
											THEN minbet ELSE @minbetv154 END) 
							ELSE 0 END),
	@maxbetv154 = MAX(CASE WHEN sporttype = 154 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv154 = 0 
											THEN maxbet ELSE @maxbetv154 END) 
							ELSE 0 END)
FROM custSetting WITH(NOLOCK)
WHERE custid = @custid

SELECT @minbetv161 = MAX(CASE WHEN sporttype = 161 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv161 = 0 
											THEN minbet ELSE @minbetv161 END) 
							ELSE 0 END),
	@maxbetv161 = MAX(CASE WHEN sporttype = 161 THEN 
									(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv161 = 0 
											THEN maxbet ELSE @maxbetv161 END) 
							ELSE 0 END)
FROM custSetting3rd WITH(NOLOCK)
WHERE custid = @custid

SELECT	@maxpermatch = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBet = 0 THEN maxpermatch ELSE @maxpermatch END,
	@maxpermatchv2 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv2 = 0 THEN maxpermatch2 ELSE @maxpermatchv2 END,
	@maxpermatchv3 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv3 = 0 THEN maxpermatch3 ELSE @maxpermatchv3 END,
	@maxpermatchv5 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv5 = 0 THEN maxpermatch5 ELSE @maxpermatchv5 END,
	@maxpermatchv8 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv8 = 0 THEN maxpermatch8 ELSE @maxpermatchv8 END,
	@maxpermatchv10 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv10 = 0 THEN maxpermatch10 ELSE @maxpermatchv10 END,
	@maxpermatchv11 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv11 = 0 THEN maxpermatch11 ELSE @maxpermatchv11 END,
	@maxpermatchv99 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv99 = 0 THEN maxpermatch99 ELSE @maxpermatchv99 END,
	@maxpermatchv99MP = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv99MP = 0 THEN maxpermatch99MP ELSE @maxpermatchv99MP END,
	@maxpermatchv1MP = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv1MP = 0 THEN maxpermatch1MP ELSE @maxpermatchv1MP END,
	@maxpermatchv154 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv154 = 0 THEN maxpermatch154 ELSE @maxpermatchv154 END,
	@maxpermatchv161 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv161 = 0 THEN maxpermatch161 ELSE @maxpermatchv161 END,
	@MaxPerBallv161 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv161 = 0 THEN MaxPerBall161 ELSE @MaxPerBallv161 END	
FROM custInfo WITH(NOLOCK)
WHERE custid = @custid		
---------------------------------

Select @LogSPData ='<Acc_CustomerUpdAgent_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@minbet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@maxbet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1)) + '" ' +
'MinBv2="'+ coalesce(cast(@minbetv2 as varchar(50)),space(1)) + '" ' +
'MaxBv2="'+ coalesce(cast(@maxbetv2 as varchar(50)),space(1)) + '" ' +
'MPMv2="'+ coalesce(cast(@maxpermatchv2 as varchar(50)),space(1)) + '" ' +
'MinBv3="'+ coalesce(cast(@minbetv3 as varchar(50)),space(1)) + '" ' +
'MaxBv3="'+ coalesce(cast(@maxbetv3 as varchar(50)),space(1)) + '" ' +
'MPMv3="'+ coalesce(cast(@maxpermatchv3 as varchar(50)),space(1)) + '" ' +
'MinBv5="'+ coalesce(cast(@minbetv5 as varchar(50)),space(1)) + '" ' +
'MaxBv5="'+ coalesce(cast(@maxbetv5 as varchar(50)),space(1)) + '" ' +
'MPMv5="'+ coalesce(cast(@maxpermatchv5 as varchar(50)),space(1)) + '" ' +
'MinBv8="'+ coalesce(cast(@minbetv8 as varchar(50)),space(1)) + '" ' +
'MaxBv8="'+ coalesce(cast(@maxbetv8 as varchar(50)),space(1)) + '" ' +
'MPMv8="'+ coalesce(cast(@maxpermatchv8 as varchar(50)),space(1)) + '" ' +
'MinBv10="'+ coalesce(cast(@minbetv10 as varchar(50)),space(1)) + '" ' +
'MaxBv10="'+ coalesce(cast(@maxbetv10 as varchar(50)),space(1)) + '" ' +
'MPMv10="'+ coalesce(cast(@maxpermatchv10 as varchar(50)),space(1)) + '" ' +
'MinBv11="'+ coalesce(cast(@minbetv11 as varchar(50)),space(1)) + '" ' +
'MaxBv11="'+ coalesce(cast(@maxbetv11 as varchar(50)),space(1)) + '" ' +
'MPMv11="'+ coalesce(cast(@maxpermatchv11 as varchar(50)),space(1)) + '" ' +
'MinBv99="'+ coalesce(cast(@minbetv99 as varchar(50)),space(1)) + '" ' +
'MaxBv99="'+ coalesce(cast(@maxbetv99 as varchar(50)),space(1)) + '" ' +
'MPMv99="'+ coalesce(cast(@maxpermatchv99 as varchar(50)),space(1)) + '" ' +
'MinBv99MP="'+ coalesce(cast(@minbetv99mp as varchar(50)),space(1)) + '" ' +
'MaxBv99MP="'+ coalesce(cast(@maxbetv99mp as varchar(50)),space(1)) + '" ' +
'MPMv99MP="'+ coalesce(cast(@maxpermatchv99mp as varchar(50)),space(1)) + '" ' +

'MinBv1MP="'+ coalesce(cast(@minbetv1mp as varchar(50)),space(1)) + '" ' +
'MaxBv1MP="'+ coalesce(cast(@maxbetv1mp as varchar(50)),space(1)) + '" ' +
'MPMv1MP="'+ coalesce(cast(@maxpermatchv1mp as varchar(50)),space(1)) + '" ' +

'MinBv154="'+ coalesce(cast(@minbetv154 as varchar(50)),space(1)) + '" ' +
'MaxBv154="'+ coalesce(cast(@maxbetv154 as varchar(50)),space(1)) + '" ' +
'MPMv154="'+ coalesce(cast(@maxpermatchv154 as varchar(50)),space(1)) + '" ' +
'MinBv161="'+ coalesce(cast(@minbetv161 as varchar(50)),space(1)) + '" ' +
'MaxBv161="'+ coalesce(cast(@maxbetv161 as varchar(50)),space(1)) + '" ' +
'MPMv161="'+ coalesce(cast(@maxpermatchv161 as varchar(50)),space(1)) + '" ' +
'MPBv161="' + coalesce(cast(@maxperballv161 as varchar(50)), space(1)) + '" ' +
'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
'UMMB="'+ coalesce(cast(@UpdateMinMaxBet as varchar(50)),space(1)) + '" ' +
'UMMBv2="'+ coalesce(cast(@UpdateMinMaxBetv2 as varchar(50)),space(1)) + '" ' +
'UMMBv3="'+ coalesce(cast(@UpdateMinMaxBetv3 as varchar(50)),space(1)) + '" ' +
'UMMBv5="'+ coalesce(cast(@UpdateMinMaxBetv5 as varchar(50)),space(1)) + '" ' +
'UMMBv8="'+ coalesce(cast(@UpdateMinMaxBetv8 as varchar(50)),space(1)) + '" ' +
'UMMBv10="'+ coalesce(cast(@UpdateMinMaxBetv10 as varchar(50)),space(1)) + '" ' +
'UMMBv11="'+ coalesce(cast(@UpdateMinMaxBetv11 as varchar(50)),space(1)) + '" ' +
'UMMBv99="'+ coalesce(cast(@UpdateMinMaxBetv99 as varchar(50)),space(1)) + '" ' +
'UMMBv99MP="'+ coalesce(cast(@UpdateMinMaxBetv99MP as varchar(50)),space(1)) + '" ' +

'UMMBv1MP="'+ coalesce(cast(@UpdateMinMaxBetv1MP as varchar(50)),space(1)) + '" ' +

'UMMBv154="'+ coalesce(cast(@UpdateMinMaxBetv154 as varchar(50)),space(1)) + '" ' +
'UMMBv161="'+ coalesce(cast(@UpdateMinMaxBetv161 as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

Select @TrackingValue2 ='<Acc_CustomerUpdAgent_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@Old_minbet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@Old_maxbet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@Old_maxpermatch as varchar(50)),space(1)) + '" ' +
'MinBv2="'+ coalesce(cast(@Old_minbetv2 as varchar(50)),space(1)) + '" ' +
'MaxBv2="'+ coalesce(cast(@Old_maxbetv2 as varchar(50)),space(1)) + '" ' +
'MPMv2="'+ coalesce(cast(@Old_maxpermatchv2 as varchar(50)),space(1)) + '" ' +
'MinBv3="'+ coalesce(cast(@Old_minbetv3 as varchar(50)),space(1)) + '" ' +
'MaxBv3="'+ coalesce(cast(@Old_maxbetv3 as varchar(50)),space(1)) + '" ' +
'MPMv3="'+ coalesce(cast(@Old_maxpermatchv3 as varchar(50)),space(1)) + '" ' +
'MinBv5="'+ coalesce(cast(@Old_minbetv5 as varchar(50)),space(1)) + '" ' +
'MaxBv5="'+ coalesce(cast(@Old_maxbetv5 as varchar(50)),space(1)) + '" ' +
'MPMv5="'+ coalesce(cast(@Old_maxpermatchv5 as varchar(50)),space(1)) + '" ' +
'MinBv8="'+ coalesce(cast(@Old_minbetv8 as varchar(50)),space(1)) + '" ' +
'MaxBv8="'+ coalesce(cast(@Old_maxbetv8 as varchar(50)),space(1)) + '" ' +
'MPMv8="'+ coalesce(cast(@Old_maxpermatchv8 as varchar(50)),space(1)) + '" ' +
'MinBv10="'+ coalesce(cast(@Old_minbetv10 as varchar(50)),space(1)) + '" ' +
'MaxBv10="'+ coalesce(cast(@Old_maxbetv10 as varchar(50)),space(1)) + '" ' +
'MPMv10="'+ coalesce(cast(@Old_maxpermatchv10 as varchar(50)),space(1)) + '" ' +
'MinBv11="'+ coalesce(cast(@Old_minbetv11 as varchar(50)),space(1)) + '" ' +
'MaxBv11="'+ coalesce(cast(@Old_maxbetv11 as varchar(50)),space(1)) + '" ' +
'MPMv11="'+ coalesce(cast(@Old_maxpermatchv11 as varchar(50)),space(1)) + '" ' +
'MinBv99="'+ coalesce(cast(@Old_minbetv99 as varchar(50)),space(1)) + '" ' +
'MaxBv99="'+ coalesce(cast(@Old_maxbetv99 as varchar(50)),space(1)) + '" ' +
'MPMv99="'+ coalesce(cast(@Old_maxpermatchv99 as varchar(50)),space(1)) + '" ' +
'MinBv99MP="'+ coalesce(cast(@Old_minbetv99mp as varchar(50)),space(1)) + '" ' +
'MaxBv99MP="'+ coalesce(cast(@Old_maxbetv99mp as varchar(50)),space(1)) + '" ' +
'MPMv99MP="'+ coalesce(cast(@Old_maxpermatchv99mp as varchar(50)),space(1)) + '" ' +

'MinBv1MP="'+ coalesce(cast(@Old_minbetv1mp as varchar(50)),space(1)) + '" ' +
'MaxBv1MP="'+ coalesce(cast(@Old_maxbetv1mp as varchar(50)),space(1)) + '" ' +
'MPMv1MP="'+ coalesce(cast(@Old_maxpermatchv1mp as varchar(50)),space(1)) + '" ' +

'MinBv154="'+ coalesce(cast(@Old_minbetv154 as varchar(50)),space(1)) + '" ' +
'MaxBv154="'+ coalesce(cast(@Old_maxbetv154 as varchar(50)),space(1)) + '" ' +
'MPMv154="'+ coalesce(cast(@Old_maxpermatchv154 as varchar(50)),space(1)) + '" ' +
'MinBv161="'+ coalesce(cast(@Old_minbetv161 as varchar(50)),space(1)) + '" ' +
'MaxBv161="'+ coalesce(cast(@Old_maxbetv161 as varchar(50)),space(1)) + '" ' +
'MPMv161="'+ coalesce(cast(@Old_maxpermatchv161 as varchar(50)),space(1)) + '" ' +
'MPBv161="' + coalesce(cast(@Old_maxperballv161 as varchar(50)), space(1)) + '" ' +
'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
'UMMB="'+ coalesce(cast(@UpdateMinMaxBet as varchar(50)),space(1)) + '" ' +
'UMMBv2="'+ coalesce(cast(@UpdateMinMaxBetv2 as varchar(50)),space(1)) + '" ' +
'UMMBv3="'+ coalesce(cast(@UpdateMinMaxBetv3 as varchar(50)),space(1)) + '" ' +
'UMMBv5="'+ coalesce(cast(@UpdateMinMaxBetv5 as varchar(50)),space(1)) + '" ' +
'UMMBv8="'+ coalesce(cast(@UpdateMinMaxBetv8 as varchar(50)),space(1)) + '" ' +
'UMMBv10="'+ coalesce(cast(@UpdateMinMaxBetv10 as varchar(50)),space(1)) + '" ' +
'UMMBv11="'+ coalesce(cast(@UpdateMinMaxBetv11 as varchar(50)),space(1)) + '" ' +
'UMMBv99="'+ coalesce(cast(@UpdateMinMaxBetv99 as varchar(50)),space(1)) + '" ' +
'UMMBv99MP="'+ coalesce(cast(@UpdateMinMaxBetv99MP as varchar(50)),space(1)) + '" ' +

'UMMBv1MP="'+ coalesce(cast(@UpdateMinMaxBetv1MP as varchar(50)),space(1)) + '" ' +

'UMMBv154="'+ coalesce(cast(@UpdateMinMaxBetv154 as varchar(50)),space(1)) + '" ' +
'UMMBv161="'+ coalesce(cast(@UpdateMinMaxBetv161 as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 306,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END TRY
BEGIN CATCH

	Select @LogSPData ='<Acc_CustomerUpdAgent_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'MinB="'+ coalesce(cast(@minbet as varchar(50)),space(1)) + '" ' +
	'MaxB="'+ coalesce(cast(@maxbet as varchar(50)),space(1)) + '" ' +
	'MPM="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1)) + '" ' +
	'MinBv2="'+ coalesce(cast(@minbetv2 as varchar(50)),space(1)) + '" ' +
	'MaxBv2="'+ coalesce(cast(@maxbetv2 as varchar(50)),space(1)) + '" ' +
	'MPMv2="'+ coalesce(cast(@maxpermatchv2 as varchar(50)),space(1)) + '" ' +
	'MinBv3="'+ coalesce(cast(@minbetv3 as varchar(50)),space(1)) + '" ' +
	'MaxBv3="'+ coalesce(cast(@maxbetv3 as varchar(50)),space(1)) + '" ' +
	'MPMv3="'+ coalesce(cast(@maxpermatchv3 as varchar(50)),space(1)) + '" ' +
	'MinBv5="'+ coalesce(cast(@minbetv5 as varchar(50)),space(1)) + '" ' +
	'MaxBv5="'+ coalesce(cast(@maxbetv5 as varchar(50)),space(1)) + '" ' +
	'MPMv5="'+ coalesce(cast(@maxpermatchv5 as varchar(50)),space(1)) + '" ' +
	'MinBv8="'+ coalesce(cast(@minbetv8 as varchar(50)),space(1)) + '" ' +
	'MaxBv8="'+ coalesce(cast(@maxbetv8 as varchar(50)),space(1)) + '" ' +
	'MPMv8="'+ coalesce(cast(@maxpermatchv8 as varchar(50)),space(1)) + '" ' +
	'MinBv10="'+ coalesce(cast(@minbetv10 as varchar(50)),space(1)) + '" ' +
	'MaxBv10="'+ coalesce(cast(@maxbetv10 as varchar(50)),space(1)) + '" ' +
	'MPMv10="'+ coalesce(cast(@maxpermatchv10 as varchar(50)),space(1)) + '" ' +
	'MinBv11="'+ coalesce(cast(@minbetv11 as varchar(50)),space(1)) + '" ' +
	'MaxBv11="'+ coalesce(cast(@maxbetv11 as varchar(50)),space(1)) + '" ' +
	'MPMv11="'+ coalesce(cast(@maxpermatchv11 as varchar(50)),space(1)) + '" ' +
	'MinBv99="'+ coalesce(cast(@minbetv99 as varchar(50)),space(1)) + '" ' +
	'MaxBv99="'+ coalesce(cast(@maxbetv99 as varchar(50)),space(1)) + '" ' +
	'MPMv99="'+ coalesce(cast(@maxpermatchv99 as varchar(50)),space(1)) + '" ' +
	'MinBv99MP="'+ coalesce(cast(@minbetv99mp as varchar(50)),space(1)) + '" ' +
	'MaxBv99MP="'+ coalesce(cast(@maxbetv99mp as varchar(50)),space(1)) + '" ' +
	'MPMv99MP="'+ coalesce(cast(@maxpermatchv99mp as varchar(50)),space(1)) + '" ' +
	
	'MinBv1MP="'+ coalesce(cast(@minbetv1mp as varchar(50)),space(1)) + '" ' +
	'MaxBv1MP="'+ coalesce(cast(@maxbetv1mp as varchar(50)),space(1)) + '" ' +
	'MPMv1MP="'+ coalesce(cast(@maxpermatchv1mp as varchar(50)),space(1)) + '" ' +
	
	'MinBv154="'+ coalesce(cast(@minbetv154 as varchar(50)),space(1)) + '" ' +
	'MaxBv154="'+ coalesce(cast(@maxbetv154 as varchar(50)),space(1)) + '" ' +
	'MPMv154="'+ coalesce(cast(@maxpermatchv154 as varchar(50)),space(1)) + '" ' +
	'MinBv161="'+ coalesce(cast(@minbetv161 as varchar(50)),space(1)) + '" ' +
	'MaxBv161="'+ coalesce(cast(@maxbetv161 as varchar(50)),space(1)) + '" ' +
	'MPMv161="'+ coalesce(cast(@maxpermatchv161 as varchar(50)),space(1)) + '" ' +
	'MPBv161="' + coalesce(cast(@maxperballv161 as varchar(50)), space(1)) + '" ' +
	'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
	'UMMB="'+ coalesce(cast(@UpdateMinMaxBet as varchar(50)),space(1)) + '" ' +
	'UMMBv2="'+ coalesce(cast(@UpdateMinMaxBetv2 as varchar(50)),space(1)) + '" ' +
	'UMMBv3="'+ coalesce(cast(@UpdateMinMaxBetv3 as varchar(50)),space(1)) + '" ' +
	'UMMBv5="'+ coalesce(cast(@UpdateMinMaxBetv5 as varchar(50)),space(1)) + '" ' +
	'UMMBv8="'+ coalesce(cast(@UpdateMinMaxBetv8 as varchar(50)),space(1)) + '" ' +
	'UMMBv10="'+ coalesce(cast(@UpdateMinMaxBetv10 as varchar(50)),space(1)) + '" ' +
	'UMMBv11="'+ coalesce(cast(@UpdateMinMaxBetv11 as varchar(50)),space(1)) + '" ' +
	'UMMBv99="'+ coalesce(cast(@UpdateMinMaxBetv99 as varchar(50)),space(1)) + '" ' +
	'UMMBv99MP="'+ coalesce(cast(@UpdateMinMaxBetv99MP as varchar(50)),space(1)) + '" ' +
	
	'UMMBv1MP="'+ coalesce(cast(@UpdateMinMaxBetv1MP as varchar(50)),space(1)) + '" ' +
	
	'UMMBv154="'+ coalesce(cast(@UpdateMinMaxBetv154 as varchar(50)),space(1)) + '" ' +
	'UMMBv161="'+ coalesce(cast(@UpdateMinMaxBetv161 as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1)) + '" />'

	Select @TrackingValue2 ='<Acc_CustomerUpdAgent_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'MinB="'+ coalesce(cast(@Old_minbet as varchar(50)),space(1)) + '" ' +
	'MaxB="'+ coalesce(cast(@Old_maxbet as varchar(50)),space(1)) + '" ' +
	'MPM="'+ coalesce(cast(@Old_maxpermatch as varchar(50)),space(1)) + '" ' +
	'MinBv2="'+ coalesce(cast(@Old_minbetv2 as varchar(50)),space(1)) + '" ' +
	'MaxBv2="'+ coalesce(cast(@Old_maxbetv2 as varchar(50)),space(1)) + '" ' +
	'MPMv2="'+ coalesce(cast(@Old_maxpermatchv2 as varchar(50)),space(1)) + '" ' +
	'MinBv3="'+ coalesce(cast(@Old_minbetv3 as varchar(50)),space(1)) + '" ' +
	'MaxBv3="'+ coalesce(cast(@Old_maxbetv3 as varchar(50)),space(1)) + '" ' +
	'MPMv3="'+ coalesce(cast(@Old_maxpermatchv3 as varchar(50)),space(1)) + '" ' +
	'MinBv5="'+ coalesce(cast(@Old_minbetv5 as varchar(50)),space(1)) + '" ' +
	'MaxBv5="'+ coalesce(cast(@Old_maxbetv5 as varchar(50)),space(1)) + '" ' +
	'MPMv5="'+ coalesce(cast(@Old_maxpermatchv5 as varchar(50)),space(1)) + '" ' +
	'MinBv8="'+ coalesce(cast(@Old_minbetv8 as varchar(50)),space(1)) + '" ' +
	'MaxBv8="'+ coalesce(cast(@Old_maxbetv8 as varchar(50)),space(1)) + '" ' +
	'MPMv8="'+ coalesce(cast(@Old_maxpermatchv8 as varchar(50)),space(1)) + '" ' +
	'MinBv10="'+ coalesce(cast(@Old_minbetv10 as varchar(50)),space(1)) + '" ' +
	'MaxBv10="'+ coalesce(cast(@Old_maxbetv10 as varchar(50)),space(1)) + '" ' +
	'MPMv10="'+ coalesce(cast(@Old_maxpermatchv10 as varchar(50)),space(1)) + '" ' +
	'MinBv11="'+ coalesce(cast(@Old_minbetv11 as varchar(50)),space(1)) + '" ' +
	'MaxBv11="'+ coalesce(cast(@Old_maxbetv11 as varchar(50)),space(1)) + '" ' +
	'MPMv11="'+ coalesce(cast(@Old_maxpermatchv11 as varchar(50)),space(1)) + '" ' +
	'MinBv99="'+ coalesce(cast(@Old_minbetv99 as varchar(50)),space(1)) + '" ' +
	'MaxBv99="'+ coalesce(cast(@Old_maxbetv99 as varchar(50)),space(1)) + '" ' +
	'MPMv99="'+ coalesce(cast(@Old_maxpermatchv99 as varchar(50)),space(1)) + '" ' +
	'MinBv99MP="'+ coalesce(cast(@Old_minbetv99mp as varchar(50)),space(1)) + '" ' +
	'MaxBv99MP="'+ coalesce(cast(@Old_maxbetv99mp as varchar(50)),space(1)) + '" ' +
	'MPMv99MP="'+ coalesce(cast(@Old_maxpermatchv99mp as varchar(50)),space(1)) + '" ' +
	
	'MinBv1MP="'+ coalesce(cast(@Old_minbetv1mp as varchar(50)),space(1)) + '" ' +
	'MaxBv1MP="'+ coalesce(cast(@Old_maxbetv1mp as varchar(50)),space(1)) + '" ' +
	'MPMv1MP="'+ coalesce(cast(@Old_maxpermatchv1mp as varchar(50)),space(1)) + '" ' +
	
	'MinBv154="'+ coalesce(cast(@Old_minbetv154 as varchar(50)),space(1)) + '" ' +
	'MaxBv154="'+ coalesce(cast(@Old_maxbetv154 as varchar(50)),space(1)) + '" ' +
	'MPMv154="'+ coalesce(cast(@Old_maxpermatchv154 as varchar(50)),space(1)) + '" ' +
	'MinBv161="'+ coalesce(cast(@Old_minbetv161 as varchar(50)),space(1)) + '" ' +
	'MaxBv161="'+ coalesce(cast(@Old_maxbetv161 as varchar(50)),space(1)) + '" ' +
	'MPMv161="'+ coalesce(cast(@Old_maxpermatchv161 as varchar(50)),space(1)) + '" ' +
	'MPBv161="' + coalesce(cast(@Old_maxperballv161 as varchar(50)), space(1)) + '" ' +
	'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
	'UMMB="'+ coalesce(cast(@UpdateMinMaxBet as varchar(50)),space(1)) + '" ' +
	'UMMBv2="'+ coalesce(cast(@UpdateMinMaxBetv2 as varchar(50)),space(1)) + '" ' +
	'UMMBv3="'+ coalesce(cast(@UpdateMinMaxBetv3 as varchar(50)),space(1)) + '" ' +
	'UMMBv5="'+ coalesce(cast(@UpdateMinMaxBetv5 as varchar(50)),space(1)) + '" ' +
	'UMMBv8="'+ coalesce(cast(@UpdateMinMaxBetv8 as varchar(50)),space(1)) + '" ' +
	'UMMBv10="'+ coalesce(cast(@UpdateMinMaxBetv10 as varchar(50)),space(1)) + '" ' +
	'UMMBv11="'+ coalesce(cast(@UpdateMinMaxBetv11 as varchar(50)),space(1)) + '" ' +
	'UMMBv99="'+ coalesce(cast(@UpdateMinMaxBetv99 as varchar(50)),space(1)) + '" ' +
	'UMMBv99MP="'+ coalesce(cast(@UpdateMinMaxBetv99MP as varchar(50)),space(1)) + '" ' +
	
	'UMMBv1MP="'+ coalesce(cast(@UpdateMinMaxBetv1MP as varchar(50)),space(1)) + '" ' +
	
	'UMMBv154="'+ coalesce(cast(@UpdateMinMaxBetv154 as varchar(50)),space(1)) + '" ' +
	'UMMBv161="'+ coalesce(cast(@UpdateMinMaxBetv161 as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1)) + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 306,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END CATCH
---------------------------------------------------------

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_MinMaxBet] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_MinMaxBet] TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgent_MinMaxBet] TO [vnteam] AS [dbo]