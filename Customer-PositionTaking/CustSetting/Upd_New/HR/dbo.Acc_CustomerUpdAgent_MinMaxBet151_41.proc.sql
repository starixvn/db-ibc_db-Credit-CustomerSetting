ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgent_MinMaxBet151_41]
	@custid int,-- agentID
	@minbet money,
	@maxbet money,
	@maxpermatch money,
	@UpdateMultiple bit = 0,			
	@SubAccID int = 0, --Sub-AccountID		
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
as
/*
Created: 20100415@Shifu
Task : Update agent's minbet, maxbet, max per match for Horseracing OpenTote
DB: DBTXN/bodb02

Revisions:
	- 20100612@Kiwi: Change to write Log in XML format
	- 20101019@Henry: Record execution time
	- 20110304@Johnson: check old values minbet/maxbet/maxpermatch with new values before update
	- 20110427@Simon: Add Popup Message For Betting Limit.
	- 20110517@Johnson: write log for old setting
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130226@Johnson: change linked server DB03 to DBONUSER and write log on DBTXN if DBLOG failure
Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

Declare 
	@MinMinBet money, @MaxMaxBet money,	@MaxMaxPerMatch money	
declare @UserName varchar(30), @mrecommend int
		
Select @UserName = username, @mrecommend = mrecommend
from customer with (NOLOCK)
where CustID = @CustID and roleid = 2

if (@UserName = NULL) return


if @UpdateMultiple = 0
BEGIN
	if 
		@MinBet<0
		or @MaxBet < 0
		or @MaxPerMatch <0
	BEGIN
		select @ErrCode = 2
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)
					end
		return
	END
END

Select @MinMinBet = 0, @MaxMaxBet = 0

Select 
	@MinMinBet = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBet = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	CustSetting3rd as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 41 and cs.sporttype=151
where ci.custid = @MRecommend


Select	
	@MaxMaxperMatch = isnull(Min(case when cs.MaxPerMatch151_OT = 0 then NULL else cs.MaxPerMatch151_OT end),0)
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
where ci.custid = @CustID

if @UpdateMultiple = 0
BEGIN

	if (@MinBet<>0 and @MaxBet <> 0 and  @MinBet>@MaxBet) or (@MaxBet<> 0 and @MaxPerMatch <> 0 and @MaxBet>@MaxPerMatch) 
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match!!!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBet) + '-' + convert(varchar(20), @MaxBet) + '-' + convert(varchar(20), @MaxPerMatch), @ErrCode = 109					 
		
		return
	END

	if (@MinMinBet>0 and @MinBet>0 and @MinBet<@MinMinBet)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Master Agent min bet'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language)
						end						
						+' (' + convert(varchar(20), @MinMinBet) + ').', @ErrCode = 110				 
		
		return
	END
	
	if (@MaxMaxBet>0 and @MaxBet>0 and @MaxBet>@MaxMaxBet)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Master Agent max bet'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language)
						end						
						+' (' + convert(varchar(20), @MaxMaxBet) + ').', @ErrCode = 111					 
		
		return
	END
	
	if (@MaxMaxPerMatch>0 and @MaxPerMatch>0 and @MaxPerMatch>@MaxMaxPerMatch)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language)
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatch) + ').', @ErrCode = 111					 
		
		return
	END
END



---------------------------------------------------------------
-- check old values and new values before update
DECLARE @old_minbet money, @old_maxbet money
SELECT @old_minbet = minbet , @old_maxbet = maxbet
FROM custsetting3rd WITH(NOLOCK) 
WHERE custid = @custid AND sporttype = 151 and bettype = 41

IF @old_minbet <> @minbet OR @old_maxbet <> @maxbet
BEGIN
	update CustSetting3rd with (ROWLOCK, UPDLOCK)
	set
		MinBet=CASE WHEN @UpdateMultiple = 1 THEN MinBet ELSE @MinBet END,
		MaxBet=CASE WHEN @UpdateMultiple = 1 THEN MaxBet ELSE @MaxBet END
	where custid=@custid and sporttype = 151 and bettype in (41,42)

	if (@@error <> 0)
	begin
		
		Select @ErrMsg = @UserName + ': '+
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end, @ErrCode = 115	
		return
	end
END

DECLARE @old_maxpermatch money
SELECT @old_maxpermatch = maxpermatch151_OT
FROM custinfo WITH(NOLOCK)
WHERE custid = @custid
	
IF @old_maxpermatch <> @maxpermatch
BEGIN
	EXEC dbo.Acc_CustomerUpdMaxPerMatch151_41 -- Acc_CustomerUpdMaxPerMatchOpenTote -> Acc_CustomerUpdMaxPerMatch151_41
		@custid = @custid,
		@MaxPerMatch = @MaxPerMatch,
		@Language = @Language,
		@ErrCode = @ErrCode OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
		if @ErrCode > 0
		BEGIN
			return
		END
END

-- Compare old value & new value Betting Limit: Popup Message For Betting Limit 
IF @MinBet != @old_minbet OR @MaxBet != @old_maxbet OR @MaxPerMatch != @old_maxpermatch
BEGIN
	EXEC DBONUSER.On_User.dbo.Age_MessageNoticeUpd @custID = @custid, @userID = @UserID, @TypeID = 2
END

/*318	Bet Setting	Acc_CustomerUpdAgent_MinMaxBetOpenTote	Update Horse racing Bet Setting for agent*/
Declare @LogSPData varchar(MAX),
		@TrackingValueDB varchar(4000)
		
Select @LogSPData ='<Acc_CustomerUpdAgent_MinMaxBet151_41 custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@minbet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@maxbet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1)) + '" ' +
'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

Select @TrackingValueDB ='<Acc_CustomerUpdAgent_MinMaxBet151_41 custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@old_minbet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@old_maxbet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@old_maxpermatch as varchar(50)),space(1)) + '" ' +
'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
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
		@ActionID = 343,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH				
	Select @LogSPData ='<Acc_CustomerUpdAgent_MinMaxBet151_41 custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'MinB="'+ coalesce(cast(@minbet as varchar(50)),space(1)) + '" ' +
	'MaxB="'+ coalesce(cast(@maxbet as varchar(50)),space(1)) + '" ' +
	'MPM="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1)) + '" ' +
	'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 343,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH
---------------------------------------------------------

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_MinMaxBet151_41] TO [bodbAdminNet]

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_MinMaxBet151_41] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgent_MinMaxBet151_41] TO vnteam