 
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuper_MinMaxBet151_31]
	@custid			INT,
	@MinBet			MONEY,
	@MaxBet			MONEY,
	@MaxPerMatch	MONEY,
	@UserID			INT = 0,	
	@Language		VARCHAR(2) = 'E',
	@IP				VARCHAR(15)='',
	@ErrCode		INT = 0 OUTPUT,
	@ErrMsg			NVARCHAR(4000) = '' OUTPUT
AS
/*
Created: 20081022@VinhTruong
Task : Update super's minbet, maxbet, max per match for Horseracing
DB: DBTRANS.bodb02

Revisions:
	- 20100415@Shifu: Add condition bettype = 31.
	- 20090917@Phuc: write log into DBLOG.
	- 20101019@Henry: Record execution time
	- 20110225@Lukas: 
			-	change SP name from [Acc_CustomerUpdSuper_MinMaxBetHR] to [Acc_CustomerUpdSuper_MinMaxBet151_31]
			-	Check the difference from old value before update
	- 20110511@Johnson: Write log for old setting
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130227@Johnson: write log on DBTXN if DBLOG failure
Param's Explanation:
â€¢ @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
â€¢ @ErrMsg: Error description.
*/
 
SET NOCOUNT ON
DECLARE @startRun datetime, 
		@endRun datetime, 
		@duration int,
		@minbet_old money,
		@maxbet_old money,
		@maxpermatch_old money

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

SELECT @minbet_old = MinBet, @maxbet_old = MaxBet
FROM custsetting3rd WITH(NOLOCK)
WHERE custid = @custid and sporttype = 151 and bettype = 31

SELECT @maxpermatch_old = maxpermatch151 FROM custinfo WITH(NOLOCK) WHERE custid = @custid

IF @MinBet <> @minbet_old OR @MaxBet <> @maxbet_old
BEGIN
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
END



IF @MaxPerMatch <> @maxpermatch_old
BEGIN
	EXEC dbo.Acc_CustomerUpdMaxPerMatch151_31
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
		
Select @LogSPData ='<Acc_CustomerUpdSuper_MinMaxBet151_31 custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

SELECT @TrackingValueDB = '<Acc_CustomerUpdSuper_MinMaxBet151_31 custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@MinBet_old as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@MaxBet_old as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@MaxPerMatch_old as varchar(50)),space(1)) + '" ' +
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
		@ActionID = 337,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH	
	Select @LogSPData ='<Acc_CustomerUpdSuper_MinMaxBet151_31 custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
	'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
	'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 337,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH




GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuper_MinMaxBet151_31] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuper_MinMaxBet151_31] TO [vnteam]