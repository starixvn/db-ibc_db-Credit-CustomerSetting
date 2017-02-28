ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisable151_41]
	@CustID					INT,
	@Disable151_41			BIT,
	@DisableDownlines151_41	BIT = true, --Disable all downline
	@SubAccID				INT = 0, --Sub-AccountID
	@UserID					INT,
	@Language				VARCHAR(2) = 'E',
	@ErrCode				INT = 0 OUTPUT,
	@ErrMsg					NVARCHAR(200) = '' OUTPUT,
	@IP						VARCHAR(15)=''
AS
/*
Created: 20100415@Shifu
Task : Update Horseracing status for customer
DB: DBTXN/bodb02
Original:

Revisions:
    - 20100415@Shifu: Disable OpenTote
    - 20100612@Kiwi: Change to write Log in XML format
    - 20101021@Henry: Record execution time
    - 20110427@Johnson: change type of @SubAccID to INT
	- 20110509@Johnson: Update error message for Thai version.
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB)
Param's Explanation:
â€¢ @custid: customer id.   
â€¢ @Disable151_41: status
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
Declare @RoleID tinyint , @UplineDisable151_41 bit, @Old_Disable151_41 bit

select	@RoleID = RoleID,
		@Old_Disable151_41 = isnull(DisableOpenTote, 0)

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

if @Old_Disable151_41 = @Disable151_41 RETURN--and @IsUpdDownline = 0
--begin
	--rase message if Account was already disabled!
--	if (@Disable151_41 = 1 AND @UplineDisable151_41 = 1)
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

if @Disable151_41 = 0 -- check status upline
begin			
	if @RoleID = 3
		SELECT @UplineDisable151_41 = isnull(DisableOpenTote,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT SRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 2
		SELECT @UplineDisable151_41 = isnull(DisableOpenTote,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT MRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 1
		SELECT @UplineDisable151_41 = isnull(DisableOpenTote,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT Recommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	IF @RoleID = 4 SELECT @UplineDisable151_41 = 0   --not checking the upline when the customer is the super
		
	IF @UplineDisable151_41 = 1
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'Account disabled for UK/Irish Racing. Unable to edit downlines.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60011,@Language)
						END, @ErrCode = 105
		return
	END 
end



---------------------

update CustInfo with (ROWLOCK, UPDLOCK) set DisableOpenTote = @Disable151_41
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
if (@Disable151_41 = 1 or (@Disable151_41 = 0 and @DisableDownlines151_41 = 0)) --Disable all downline or enable all downline
begin
	if @RoleID = 4 
	BEGIN
		update CustInfo with (ROWLOCK, UPDLOCK) set DisableOpenTote = @Disable151_41 where SRecommend = @CustID
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
		update CustInfo with (ROWLOCK, UPDLOCK) set DisableOpenTote = @Disable151_41 where MRecommend = @CustID
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
		update CustInfo with (ROWLOCK, UPDLOCK) set DisableOpenTote = @Disable151_41 where Recommend = @CustID
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

Select @LogSPData = '<Acc_CustomerUpdDisable151_41 CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
					'DisableHR="'+ coalesce(cast(@Disable151_41 as varchar(50)),space(1)) + '" '+
					'DisableDownline="'+ coalesce(cast(@DisableDownlines151_41 as varchar(50)),space(1)) + '" '+
					'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
					'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
					'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+
					'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

/*1119	Acc_CustomerUpdDisableOpenTote	Update Enabled/Disabled Horse racing status*/
BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1130,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH	
	Select @LogSPData = '<Acc_CustomerUpdDisable151_41 CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
						'DisableHR="'+ coalesce(cast(@Disable151_41 as varchar(50)),space(1)) + '" '+
						'DisableDownline="'+ coalesce(cast(@DisableDownlines151_41 as varchar(50)),space(1)) + '" '+
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
						'ErrMsg="'+ ERROR_MESSAGE() + '" '+
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1130,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH


GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdDisable151_41 TO [bodbAdminNet]
GO
GRANT  EXECUTE  ON [dbo].Acc_CustomerUpdDisable151_41  TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].Acc_CustomerUpdDisable151_41 TO [vnteam]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdDisable151_41 TO [bodbExtAccNet] 