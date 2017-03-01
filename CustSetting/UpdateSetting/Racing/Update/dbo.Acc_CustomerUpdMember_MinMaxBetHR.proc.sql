ALTER PROCEDURE [dbo].[Acc_CustomerUpdMember_MinMaxBetHR]
	@custid int,-- MemberID
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
Created: 20081021@VinhTruong
Task : Update member's minbet, maxbet, max per match for Horseracing
DB: DBTRANS.bodb02

Revisions:
	- 20090723@Phuc: Write log subaccname instead of subaccid.
	- 20090917@Phuc: write log into DBLOG.
	- 20091201@Kiwi: Move custsetting to the separated table CustSetting3rd.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20101019@Henry: Record execution time
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language

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

Declare @MinMinBet money, @MaxMaxBet money,	@MaxMaxPerMatch money
	
declare @ErrAcc varchar(4000), @ErrType varchar(4000),
		@UserName varchar(30), @recommend int
		
Select @UserName = username, @recommend = recommend
from customer with (NOLOCK)
where roleid = 1 and CustID = @CustID

if (@username = NULL) return

---------------------------------------------------------------
--Check Param
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
---------------------------------------------------------------

Select
	@MinMinBet = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxMaxBet = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	CustSetting3rd as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	and cs.bettype = 31 and cs.sporttype=151
where ci.custid = @recommend


Select @MaxMaxperMatch = Min(case when cs.MaxPerMatch151 = 0 then NULL else cs.MaxPerMatch151 end)
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
where ci.custid = @recommend

IF @UpdateMultiple = 0
BEGIN
	if (@MinBet<>0 and @MaxBet <> 0 and  @MinBet>@MaxBet) or (@MaxBet<> 0 and @MaxPerMatch <> 0 and @MaxBet>@MaxPerMatch) 
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match!!!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBet) + '-' + convert(varchar(20), @MaxBet) + '-' + convert(varchar(20), @MaxPerMatch), @ErrCode = 108
			
		return
		
	END
	
	IF (@MinMinBet>0 AND @MinBet>0 AND @MinBet<@MinMinBet)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': ' +
						CASE @Language 
							WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language)
						END						
						+' (' + CONVERT(VARCHAR(20), @MinMinBet) + ').', @ErrCode = 109
				
		return
	END
	
	IF (@MaxMaxBet>0 AND @MaxBet>0 AND @MaxBet>@MaxMaxBet)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language)
						END						
						+'(' + CONVERT(VARCHAR(20), @MaxMaxBet) + ').', @ErrCode = 110
				
		return
	END
	
	IF (@MaxMaxPerMatch>0 AND @MaxPerMatch>0 AND @MaxPerMatch>@MaxMaxPerMatch)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language)
						END						
						+'(' + CONVERT(VARCHAR(20), @MaxMaxPerMatch) + ').', @ErrCode = 110
				
		return
	END

END




UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
SET
	MinBet=CASE WHEN @UpdateMultiple = 1 THEN MinBet ELSE @MinBet END,
	MaxBet=CASE WHEN @UpdateMultiple = 1 THEN MaxBet ELSE @MaxBet END
WHERE custid=@custid AND sporttype = 151 and bettype in(31,32)
if (@@error <> 0)
begin

	Select @ErrMsg = @UserName + ': '+
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end, @ErrCode = 115
	return
end


EXEC dbo.Acc_CustomerUpdMaxPerMatchHR
	@custid = @custid,
	@MaxPerMatch = @MaxPerMatch,
	@Language = @Language,
	@ErrCode = @ErrCode OUTPUT,
	@ErrMsg = @ErrMsg OUTPUT
	if @ErrCode > 0
	BEGIN
		return
	END



Declare @LogSPData varchar(5000)
Select @LogSPData ='<Acc_CustomerUpdMember_MinMaxBetHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 312,
	@TrackingValue = @LogSPData,
	@duration = @duration

---------------------------------------------------------

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_MinMaxBetHR] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_MinMaxBetHR] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMember_MinMaxBetHR] TO [vnteam]