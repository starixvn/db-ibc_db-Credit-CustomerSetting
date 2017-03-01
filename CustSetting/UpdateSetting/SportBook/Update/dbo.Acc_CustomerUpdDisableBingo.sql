 ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableBingo]
	@CustID int,
	@DisableBingo bit,
	@DisableDownline bit = true, --Disable all downline
	@SubAccID int = 0, --Sub-AccountID
	@UserID int,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@IP varchar(15)=''
AS
/*
Created: 20100831@Jamie
Task : Update Bingo status for customer
DB: DBTXN/bodb02
Original:

Revisions:
	- 20101021@Henry: Record execution time
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Change linked server DB053 to DBAGE; Write more log on DBTXN server in case of DBLOG server failure
Param's Explanation:
• @custid: customer id.   
• @DisableNumber: status
*/
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

--Check disable user
EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return
--end
Declare @RoleID tinyint , @UplineDisableBingo bit, @Old_DisableBingo bit

select	@RoleID = RoleID,
		@Old_DisableBingo = isnull(DisableBingo, 0)

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

if @Old_DisableBingo = @DisableBingo RETURN

if @DisableBingo = 0 -- check status upline
begin			
	if @RoleID = 3
		SELECT @UplineDisableBingo = isnull(DisableBingo,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT SRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 2
		SELECT @UplineDisableBingo = isnull(DisableBingo,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT MRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 1
		SELECT @UplineDisableBingo = isnull(DisableBingo,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT Recommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	IF @RoleID = 4 SELECT @UplineDisableBingo = 0   --not checking the upline when the customer is the super
		
	IF @UplineDisableBingo = 1
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'Your account was disabled Bingo betting. Cannot edit customer.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60019,@Language)
						END, @ErrCode = 105
		return
	END 
end



---------------------

update CustInfo with (ROWLOCK, UPDLOCK) set DisableBingo = @DisableBingo
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
--Check condition for update all downline
if (@DisableBingo = 1 or (@DisableBingo = 0 and @DisableDownline = 0)) --Disable all downline or enable all downline
begin
	if @RoleID = 4 
	BEGIN
		update CustInfo with (ROWLOCK, UPDLOCK) set DisableBingo = @DisableBingo where SRecommend = @CustID
		if (@@error <> 0)
		begin
			
			Select @ErrMsg = 
						case @Language 
							when 'E' then 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 102
		return
		end
	END

	if @RoleID = 3 
	BEGIN
		update CustInfo with (ROWLOCK, UPDLOCK) set DisableBingo = @DisableBingo where MRecommend = @CustID
		if (@@error <> 0)
		begin
			
			Select @ErrMsg = 
						case @Language 
							when 'E' then 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 103
		return
		end
	END

	if @RoleID = 2 
	BEGIN
		update CustInfo with (ROWLOCK, UPDLOCK) set DisableBingo = @DisableBingo where Recommend = @CustID
		if (@@error <> 0)
		begin
			
			Select @ErrMsg = 
						case @Language 
							when 'E' then 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 104
		return
		end
	END
End

declare @LogSPData varchar(8000)

Select @LogSPData = '<Acc_CustomerUpdDisableBingo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
					'DisableBingo="'+ coalesce(cast(@DisableBingo as varchar(50)),space(1)) + '" '+
					'DisableDownline="'+ coalesce(cast(@DisableDownline as varchar(50)),space(1)) + '" '+
					'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
					'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
					'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+
					'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
	/*1121	Acc_CustomerUpdDisableBingo	Update Enabled/Disabled Bingo status*/
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1121,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerUpdDisableBingo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
						'DisableBingo="'+ coalesce(cast(@DisableBingo as varchar(50)),space(1)) + '" '+
						'DisableDownline="'+ coalesce(cast(@DisableDownline as varchar(50)),space(1)) + '" '+
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
						'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" '+
						'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+'" '+
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
	
	/*1121	Acc_CustomerUpdDisableBingo	Update Enabled/Disabled Bingo status*/
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1121,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration
END CATCH
		
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableBingo] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableBingo] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableBingo] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdDisableBingo] TO [vnteam]