
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuper_MinMaxBetHR]
	@custid int,
	@MinBet money,
	@MaxBet money,
	@MaxPerMatch money,
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20081022@VinhTruong
Task : Update super's minbet, maxbet, max per match for Horseracing
DB: DBTRANS.bodb02

Revisions:
	- 20100415@Shifu: Add condition bettype = 31.
	- 20090917@Phuc: write log into DBLOG.
	- 20101019@Henry: Record execution time
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
Param's Explanation:
â€¢ @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
â€¢ @ErrMsg: Error description.
*/
 
SET NOCOUNT ON
declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

if 
	@MinBet<0
	or @MaxBet < 0
	or @MaxPerMatch <0	
BEGIN
	 
	Select @ErrMsg = case @Language 
						when 'E' then 'Wrong Min bet/ Max bet/ Max per match.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)		
					end, @ErrCode = 101
	return
END

if(@MinBet<>0 and @MaxBet <> 0 and  @MinBet>@MaxBet) 
	or (@MaxBet<> 0 and @MaxPerMatch <> 0 and @MaxBet>@MaxPerMatch) 
	or (@MinBet <> 0 and @MaxPerMatch <> 0 and @MinBet>@MaxPerMatch) 
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
					end, @ErrCode = 102
	RETURN
END


update CustSetting3rd with (ROWLOCK, UPDLOCK)
set	
	MinBet = @MinBet, MaxBet= @MaxBet
where custid=@custid and sporttype = 151 AND bettype in(31,32)
if (@@error <> 0)
begin
	
	Select @ErrMsg = case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end	, @ErrCode = 103 
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
Select @LogSPData ='<Acc_CustomerUpdSuper_MinMaxBetHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
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
	@ActionID = 309,
	@TrackingValue = @LogSPData,
	@duration = @duration

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuper_MinMaxBetHR] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuper_MinMaxBetHR] TO [vnteam]