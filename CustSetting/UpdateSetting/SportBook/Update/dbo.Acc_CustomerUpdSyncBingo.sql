 
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSyncBingo]
	@CustID int,
	@SyncBingo bit,	
	@SubAccID int = 0, --Sub-AccountID
	@UserID int,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@IP varchar(15)=''
AS
/*
Created: 20100908@Steven
Task : Update customer SyncBingo status
DB: DBTXN/bodb02
Original:

Revisions:
	- 20101021@Henry: Record execution time
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20120730@Johnson: Correct action id from 1505 to 1122
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Change linked server DB053 to DBAGE; Write more log on DBTXN server in case of DBLOG server failure
	- 20130827@Johnson: Check enabled status on DBTXN instead of DBAGE
Param's Explanation:
• @custid: customer id.   
• @SyncBingo: status
*/
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

--Check disable user
EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return
--end
Declare @RoleID tinyint

select	@RoleID = RoleID
from Custinfo with (nolock)
where CustID = @CustID

if @RoleID not in (1,2,3,4)
BEGIN
	Select @ErrMsg = case @Language 
						when 'E' then 'Invalid user!'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
					end, @ErrCode = 100	
	return
END
---------------------

update CustInfo with (ROWLOCK, UPDLOCK) set SyncBingo = @SyncBingo
where CustID = @CustID
if (@@error <> 0)
begin

	Select @ErrMsg =
					case @Language 
						when 'E' then 'Update process is unsuccessful.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end	, @ErrCode = 101
	return
end

declare @LogSPData varchar(8000)

Select @LogSPData = '<Acc_CustomerUpdSyncBingo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
					'SyncBingo="'+ coalesce(cast(@SyncBingo as varchar(50)),space(1)) + '" '+
					'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
					'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
					'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1))+'" '+
					'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
	/*1505	[Acc_CustomerUpdSyncBingo]	Update customer SyncBingo status*/
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1122,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration
END TRY
BEGIN CATCH		
	Select @LogSPData = '<Acc_CustomerUpdSyncBingo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
						'SyncBingo="'+ coalesce(cast(@SyncBingo as varchar(50)),space(1)) + '" '+
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
						'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" '+
						'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+'" '+
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
						
	/*1505	[Acc_CustomerUpdSyncBingo]	Update customer SyncBingo status*/
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1122,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration
END CATCH		


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSyncBingo] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSyncBingo] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSyncBingo] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSyncBingo] TO [vnteam]