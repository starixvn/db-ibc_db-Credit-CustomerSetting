ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableNumber]
	@CustID int,
	@DisableNumber bit,
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
Task : Update Bingo Number Game status for customer
DB: DBTXN/bodb02
Original:

Revisions:
	- 20101021@Henry: Record execution time
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20121206@Scott : Check Allowed downlines during peak hour at weekend
	- 20130218@Dan: Change linked server DB053 to DBAGE; Write more log on DBTXN server in case of DBLOG server failure
	- 20130926@Kathy: Apply exec rep
	- 20131108@Elodie: Splitting bodb02 into CustDB (Turn to use Acc_ExecRep_Cust_04)	
	- 20141125@Jamie: Use Acc_CustomerInfo_Execrep_04 instead of Acc_ExecRep_Cust_04 [Redmine:#26497]
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines, Acc_CustomerSelCheckEnable to DBCUST.CustDB)
	
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
EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return
--end
Declare @RoleID tinyint , @UplineDisableNumber bit, @Old_DisableNumber bit

select	@RoleID = RoleID,
		@Old_DisableNumber = isnull(DisableNumber, 0)

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

--Check Allowed downlines during peak hour at weekend
IF (@DisableNumber = 1 or (@DisableNumber = 0 and @DisableDownline = 0))
BEGIN
	EXEC Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
											@roleid=@roleid,
											@isExecRep=1,
											@Language=@Language,
											@ErrMsg=@ErrMsg output,
											@ErrCode=@ErrCode output
	IF @ErrCode <>0 RETURN

END
--END

if @Old_DisableNumber = @DisableNumber RETURN

if @DisableNumber = 0 -- check status upline
begin			
	if @RoleID = 3
		SELECT @UplineDisableNumber = isnull(DisableNumber,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT SRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 2
		SELECT @UplineDisableNumber = isnull(DisableNumber,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT MRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 1
		SELECT @UplineDisableNumber = isnull(DisableNumber,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT Recommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	IF @RoleID = 4 SELECT @UplineDisableNumber = 0   --not checking the upline when the customer is the super
		
	IF @UplineDisableNumber = 1
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'Your account was disabled Number Game betting. Cannot edit customer.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60017,@Language)
						END, @ErrCode = 105
		return
	END 
end



---------------------

update CustInfo with (ROWLOCK, UPDLOCK) set DisableNumber = @DisableNumber
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
IF (@DisableNumber = 1 or (@DisableNumber = 0 and @DisableDownline = 0)) --Disable all downline or enable all downline
BEGIN TRY
	--20130926@Kathy: Apply ExecRep 
	EXEC [Acc_CustomerInfo_Execrep_04]
		@CustID		= @CustID,
		@RoleID		= @RoleID,
		@Action		= 'DisableNumberGame',
		@DisableNumberGame = @DisableNumber     
END TRY
BEGIN CATCH
	SELECT @ErrMsg = 	case @Language 
							when 'E' then 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	
	IF @RoleID = 4 
		SELECT @ErrCode = 102
	ELSE IF @RoleID = 3
		SELECT @ErrCode = 103
	ELSE IF @RoleID = 2
		SELECT @ErrCode = 104
	RETURN
END CATCH

declare @LogSPData varchar(8000)

Select @LogSPData = '<Acc_CustomerUpdDisableNumber CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
					'DisableNumber="'+ coalesce(cast(@DisableNumber as varchar(50)),space(1)) + '" '+
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
	/*1120	Acc_CustomerUpdDisableNumber	Update Enabled/Disabled Number Game status*/
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1120,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerUpdDisableNumber CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
						'DisableNumber="'+ coalesce(cast(@DisableNumber as varchar(50)),space(1)) + '" '+
						'DisableDownline="'+ coalesce(cast(@DisableDownline as varchar(50)),space(1)) + '" '+
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
						'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" '+
						'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+'" '+
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
						
	/*1120	Acc_CustomerUpdDisableNumber	Update Enabled/Disabled Number Game status*/
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1120,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration		
END CATCH


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableNumber] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableNumber] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableNumber] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdDisableNumber] TO [vnteam] AS [dbo]