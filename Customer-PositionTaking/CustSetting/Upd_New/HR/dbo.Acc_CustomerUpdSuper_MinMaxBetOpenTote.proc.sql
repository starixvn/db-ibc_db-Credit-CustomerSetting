
alter PROCEDURE [dbo].[Acc_CustomerUpdSuper_MinMaxBetOpenTote]
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
Created: 20100415@Shifu
Task : Update super's minbet, maxbet, max per match for Horseracing OpenTote 
DB: DBTRANS.bodb02

Revisions:
	- 20100415@Shifu: OpenTote.
	- 20100612@Kiwi: Change to write Log in XML format.
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
Param's Explanation:
â€¢ @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
â€¢ @ErrMsg: Error description.
*/

SET NOCOUNT ON


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
where custid=@custid and sporttype = 151 AND bettype in(41,42)
if (@@error <> 0)
begin
	
	Select @ErrMsg = case @Language 
						when 'E' then 'Update process is unsuccessful !'						
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end	, @ErrCode = 103 
	return
end


EXEC dbo.Acc_CustomerUpdMaxPerMatchOpenTote
	@custid = @custid,
	@MaxPerMatch = @MaxPerMatch,
	@Language = @Language,
	@ErrCode = @ErrCode OUTPUT,
	@ErrMsg = @ErrMsg OUTPUT
	if @ErrCode > 0
	BEGIN
		return
	END

/*316	Acc_CustomerUpdSuper_MinMaxBetOpenTote	Update Horse racing Bet Setting for super*/
	
Declare @LogSPData varchar(5000)
Select @LogSPData ='<Acc_CustomerUpdSuper_MinMaxBetOpenTote custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 316,
	@TrackingValue = @LogSPData	

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuper_MinMaxBetOpenTote] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuper_MinMaxBetOpenTote] TO [vnteam]