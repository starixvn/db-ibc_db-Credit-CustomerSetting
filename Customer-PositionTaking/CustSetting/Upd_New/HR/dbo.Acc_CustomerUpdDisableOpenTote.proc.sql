Alter PROCEDURE [dbo].[Acc_CustomerUpdDisableOpenTote]
	@CustID int,
	@DisableOpenTote bit,
	@DisableDownline bit = true, --Disable all downline
	@SubAccID int = 0, --Sub-AccountID
	@UserID int,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@IP varchar(15)=''
AS
/*
Created: 20100415@Shifu
Task : Update Horseracing status for customer
DB: DBTRANS.bodb02
Original:

Revisions:
    - 20100415@Shifu: Disable OpenTote
    - 20100612@Kiwi: Change to write Log in XML format
    - 20101021@Henry: Record execution time
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
Param's Explanation:
â€¢ @custid: customer id.   
â€¢ @DisableOpenTote: status
*/
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

--Check disable user
EXEC DB052.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return 
--end
Declare @RoleID tinyint , @UplineDisableOpenTote bit, @Old_DisableOpenTote bit

select	@RoleID = RoleID,
		@Old_DisableOpenTote = isnull(DisableOpenTote, 0)

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

--current status change or not?
-- Qui.Nguyen add "and @IsUpdDownline = 0" for wap
-- Remove @IsUpdDownline

if @Old_DisableOpenTote = @DisableOpenTote RETURN--and @IsUpdDownline = 0
--begin
	--rase message if Account was already disabled!
--	if (@DisableOpenTote = 1 AND @UplineDisableOpenTote = 1)
--	begin
--		SELECT @ErrMsg =  CASE @Language 
--							WHEN 'E' THEN 'Your account was disabled Horse Racing betting. Cannot edit customer.'
--							WHEN 'CS' THEN N'èµ›é©¬æŠ•æ³¨ç›®å‰å·²è¢«ä¸Šçº¿é™åˆ¶ã€‚æ— æ³•ä¿®æ”¹ä¼šå‘˜ã€‚'
--							WHEN 'CT' THEN N'è³½é¦¬æŠ•æ³¨ç›®å‰å·²è¢«ä¸Šç·šé™åˆ¶ã€‚ç„¡æ³•ä¿®æ”¹æœƒå“¡ã€‚'
--							WHEN 'TH' THEN N'Your account was disabled Horse Racing betting. Cannot edit customer.'							
--							WHEN 'J' THEN N'Your account was disabled Horse Racing betting. Cannot edit customer.'
--							WHEN 'KO' THEN N'Your account was disabled Horse Racing betting. Cannot edit customer.'
--							ELSE N'Your account was disabled Horse Racing betting. Cannot edit customer.'
--						END
--	end
--
--	return
--end

if @DisableOpenTote = 0 -- check status upline
begin			
	if @RoleID = 3
		SELECT @UplineDisableOpenTote = isnull(DisableOpenTote,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT SRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 2
		SELECT @UplineDisableOpenTote = isnull(DisableOpenTote,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT MRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 1
		SELECT @UplineDisableOpenTote = isnull(DisableOpenTote,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT Recommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	IF @RoleID = 4 SELECT @UplineDisableOpenTote = 0   --not checking the upline when the customer is the super
		
	IF @UplineDisableOpenTote = 1
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'Your account was disabled Horse Racing UK Tote betting. Cannot edit customer.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60005,@Language)
						END, @ErrCode = 105
		return
	END 
end



---------------------

update CustInfo with (ROWLOCK, UPDLOCK) set DisableOpenTote = @DisableOpenTote
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
if (@DisableOpenTote = 1 or (@DisableOpenTote = 0 and @DisableDownline = 0)) --Disable all downline or enable all downline
begin
	if @RoleID = 4 
	BEGIN
		update CustInfo with (ROWLOCK, UPDLOCK) set DisableOpenTote = @DisableOpenTote where SRecommend = @CustID
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
		update CustInfo with (ROWLOCK, UPDLOCK) set DisableOpenTote = @DisableOpenTote where MRecommend = @CustID
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
		update CustInfo with (ROWLOCK, UPDLOCK) set DisableOpenTote = @DisableOpenTote where Recommend = @CustID
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

declare @LogSPData varchar(2000)

Select @LogSPData = '<Acc_CustomerUpdDisableOpenTote CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
					'DisableHR="'+ coalesce(cast(@DisableOpenTote as varchar(50)),space(1)) + '" '+
					'DisableDownline="'+ coalesce(cast(@DisableDownline as varchar(50)),space(1)) + '" '+
					'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
					'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
					'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+
					'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

/*1119	Acc_CustomerUpdDisableOpenTote	Update Enabled/Disabled Horse racing status*/
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 1119,
	@TrackingValue = @LogSPData,
	@duration = @duration

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableOpenTote] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableOpenTote] TO [bodbExtAccNet]
GO
GRANT  EXECUTE  ON [dbo].[Acc_CustomerUpdDisableOpenTote]  TO [bodbDownlineNet]
GO
GRANT  VIEW DEFINITION  ON [dbo].[Acc_CustomerUpdDisableOpenTote]  TO [VNTeam]
GO
