alter PROCEDURE [dbo].[Acc_CustomerUpdMaster_MinMaxBet152_51]
	@custid int,-- masterid	
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
Created: 20110113@Henry
Task : Update master's minbet, maxbet, max per match for Greyhound for AU
DB: DBTXN/bodb02

Revisions:
	- 20110304@Johnson: check old values min/max bet with new values before update
	- 20110516@Johnson: write log for old setting
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130226@Johnson: write log on DBTXN if DBLOG failure
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
	@MinMinBet money, @MaxMaxBet money,	@MaxMaxPerMatch money
	
declare @UserName varchar(30), @srecommend int
		
Select @UserName = username, @srecommend = srecommend
from customer with (NOLOCK)
where CustID = @CustID and roleid = 3

if (@username = NULL) return

if @UpdateMultiple = 0
BEGIN
	if 
		@minbet<0
		or @maxbet < 0
		or @maxpermatch <0
	BEGIN	 
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)
					end, @ErrCode = 101
		return
	END
END

---------------------------------------------------------
if @UpdateMultiple = 0 
BEGIN
	if 
	(@minbet<>0 and @maxbet <> 0 and  @minbet>@maxbet) 
	or (@maxbet<> 0 and @maxpermatch <> 0 and @maxbet>@maxpermatch) 
	or (@minbet <> 0 and @maxpermatch <> 0 and @minbet>@maxpermatch)
	BEGIN
		SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match!!!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
						end	, @ErrCode = 110
		return
	END
END

-------------------------------------------------
Select @MaxMaxPerMatch = isnull(MaxPerMatch152_AU, 0)
from custinfo with (NOLOCK) where custid = @srecommend

---------------------------------------------------------
Select 
	@MinMinBet = MinBet,
	@MaxMaxBet = MaxBet
From CustSetting3rd with (NOLOCK)
where CustID = @srecommend and bettype=51 and sporttype=152



if @UpdateMultiple = 0
BEGIN
	if (@MinMinBet>0 and @MinBet>0 and @minbet<@MinMinBet)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Super Agent min bet'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language)
						end						
						+' (' + convert(varchar(20), @MinMinBet) + ').', @ErrCode = 119	
		return
	END
	
	if (@MaxMaxBet>0 and @MaxBet>0 and @maxbet>@MaxMaxBet)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Super Agent max bet'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language)
						end						
						+' (' + convert(varchar(20), @MaxMaxBet) + ').', @ErrCode = 120	
		return
	END
	
	if (@MaxMaxPerMatch>0 and @MaxPerMatch>0 and @MaxPerMatch>@MaxMaxPerMatch)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language)
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatch) + ').', @ErrCode = 121	
		return
	END
END

------------

------------
--check before update 
DECLARE @old_minbet money, @old_maxbet money
SELECT @old_minbet = minbet , @old_maxbet = maxbet 
FROM custsetting3rd WITH(NOLOCK) 
WHERE custid = @custid AND sporttype = 152 AND bettype =51

IF (@old_minbet <> @minbet OR @old_maxbet <> @maxbet)
BEGIN
	update CustSetting3rd with (ROWLOCK, UPDLOCK)
	set	
		MinBet=CASE WHEN @UpdateMultiple = 1 THEN MinBet ELSE @MinBet END,
		MaxBet=CASE WHEN @UpdateMultiple = 1 THEN MaxBet ELSE @MaxBet END
	where custid=@custid AND sporttype = 152 and bettype in(51,52)
	if (@@error <> 0)
	begin

		Select @ErrMsg = @UserName + ': '+
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 147
		return
	end
END

DECLARE @old_maxpermatch money
SELECT @old_maxpermatch = maxpermatch152_AU
FROM custinfo WITH(NOLOCK)
WHERE custid = @custid
	
IF @old_maxpermatch <> @maxpermatch	
BEGIN
	EXEC dbo.Acc_CustomerUpdMaxPerMatch152_51
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


Declare @LogSPData varchar(MAX),
		@TrackingValueDB varchar(4000)
		
Select @LogSPData ='<Acc_CustomerUpdMaster_MinMaxBet152_51 custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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

Select @TrackingValueDB ='<Acc_CustomerUpdMaster_MinMaxBet152_51 custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
		@ActionID = 330,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH			
	Select @LogSPData ='<Acc_CustomerUpdMaster_MinMaxBet152_51 custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
		@ActionID = 330,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH
---------------------------------------------------------

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_MinMaxBet152_51] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_MinMaxBet152_51] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_MinMaxBet152_51] TO [vnteam] 