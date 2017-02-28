ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisable151_31]
	@CustID					INT,
	@Disable151_31			BIT,
	@DisableDownlines151_31 BIT = true, --Disable all downline
	@SubAccID				INT = 0, --Sub-AccountID
	@UserID					INT,
	@Language				VARCHAR(2) = 'E',
	@ErrCode				INT = 0 OUTPUT,
	@ErrMsg					NVARCHAR(200) = '' OUTPUT,
	@IP						VARCHAR(15)=''
AS
/*
Created: 20081029@phuong.nguyen
Task : Update Horseracing status for customer
DB: DBTXN/bodb02
Original:

Revisions:
    - 20090122@[Reviewer]: [Description of revision] 
    - 20090228@MinhNguyen: Show the alert if the account is disabled already. 
	- 20090314@PhuongDao: Not checking the upline when the customer is the super 
	- 20090317@Phuc: open all downline.   
	- 20090320@PhuongDao: Change param @IsUpdDownline to @DisableDownline151_31 
	- 20090723@Phuc: Write log subaccname instead of subaccid.
	- 20090801@Shifu: check disabled user
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090917@Phuc: write log into DBLOG.
	- 20091008@Kiwi: Remove WriteLog_UserLog
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20101021@Henry: Record execution time
	- 20110427@Johnson: change type of @SubAccID to INT
	- 20110509@Johnson: Update error message for Thai version
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB)

Param's Explanation:
• @custid: customer id.   
• @Disable151_31: status
*/
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

--Check disable user
EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return
--end
Declare @RoleID tinyint , @UplineDisable151_31 bit, @Old_Disable151_31 bit

select	@RoleID = RoleID,
		@Old_Disable151_31 = isnull(DisableHorseracing, 0)

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

if @Old_Disable151_31 = @Disable151_31 RETURN--and @IsUpdDownline = 0
--begin
	--rase message if Account was already disabled!
--	if (@Disable151_31 = 1 AND @UplineDisable151_31 = 1)
--	begin
--		SELECT @ErrMsg =  CASE @Language 
--							WHEN 'E' THEN 'Your account was disabled Horse Racing betting. Cannot edit customer.'
--							WHEN 'CS' THEN N'赛马投注目前已被上线限制。无法修改会员。'
--							WHEN 'CT' THEN N'賽馬投注目前已被上線限制。無法修改會員。'
--							WHEN 'TH' THEN N'Your account was disabled Horse Racing betting. Cannot edit customer.'							
--							WHEN 'J' THEN N'Your account was disabled Horse Racing betting. Cannot edit customer.'
--							WHEN 'KO' THEN N'Your account was disabled Horse Racing betting. Cannot edit customer.'
--							ELSE N'Your account was disabled Horse Racing betting. Cannot edit customer.'
--						END
--	end
--
--	return
--end

if @Disable151_31 = 0 -- check status upline
begin			
	if @RoleID = 3
		SELECT @UplineDisable151_31 = isnull(DisableHorseracing,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT SRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 2
		SELECT @UplineDisable151_31 = isnull(DisableHorseracing,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT MRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 1
		SELECT @UplineDisable151_31 = isnull(DisableHorseracing,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT Recommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	IF @RoleID = 4 SELECT @UplineDisable151_31 = 0   --not checking the upline when the customer is the super
		
	IF @UplineDisable151_31 = 1
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'Account disabled for SA Racing. Unable to edit downlines.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60012,@Language)
						END, @ErrCode = 105
		return
	END 
end



---------------------

update CustInfo with (ROWLOCK, UPDLOCK) set DisableHorseracing = @Disable151_31
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
if (@Disable151_31 = 1 or (@Disable151_31 = 0 and @DisableDownlines151_31 = 0)) --Disable all downline or enable all downline
begin
	if @RoleID = 4 
	BEGIN
		update CustInfo with (ROWLOCK, UPDLOCK) set DisableHorseracing = @Disable151_31 where SRecommend = @CustID
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
		update CustInfo with (ROWLOCK, UPDLOCK) set DisableHorseracing = @Disable151_31 where MRecommend = @CustID
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
		update CustInfo with (ROWLOCK, UPDLOCK) set DisableHorseracing = @Disable151_31 where Recommend = @CustID
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

declare @LogSPData varchar(MAX)

Select @LogSPData = '<Acc_CustomerUpdDisable151_31 CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
					'Disable151_31="'+ coalesce(cast(@Disable151_31 as varchar(50)),space(1)) + '" '+
					'DisableDownline151_31="'+ coalesce(cast(@DisableDownlines151_31 as varchar(50)),space(1)) + '" '+
					'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
					'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
					'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+
					'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

/*1107	Acc_CustomerUpdDisableHR	Update Enabled/Disabled Horse racing status*/
BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1129,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration
END TRY
BEGIN CATCH	
	Select @LogSPData = '<Acc_CustomerUpdDisable151_31 CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
						'Disable151_31="'+ coalesce(cast(@Disable151_31 as varchar(50)),space(1)) + '" '+
						'DisableDownline151_31="'+ coalesce(cast(@DisableDownlines151_31 as varchar(50)),space(1)) + '" '+
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
						'ErrMsg="'+ ERROR_MESSAGE() +'" '+
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1129,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration
END CATCH

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisable151_31] TO [bodbAdminNet]
GO
GRANT  EXECUTE  ON [dbo].[Acc_CustomerUpdDisable151_31]  TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdDisable151_31] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisable151_31] TO [bodbExtAccNet] 