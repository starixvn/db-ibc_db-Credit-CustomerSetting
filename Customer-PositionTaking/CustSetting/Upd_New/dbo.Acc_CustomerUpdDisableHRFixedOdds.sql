ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableHRFixedOdds]
	@custid		INT,
	@DisableHRFixedOdds BIT = NULL,	
	@EnableDownlinesHRFixedOdds BIT = 0,
	
	@UserID		INT = 0,
	@SubAccID	INT = 0, --Sub-AccountID
	@IP			VARCHAR(20)= '',
	@Language	VARCHAR(2) = 'E',
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		VARCHAR(4000) = '' OUTPUT
AS
/*
Created: 20131011@Elodie
Task : Update HR Fixed Odds status for customer [Redmine:#6505]
DB: DBTXN/CustDB
Original:

Revisions:
	- 20131108@Elodie: Splitting bodb02 into CustDB (call Acc_ExecRep_Cust_04 instead of Acc_ExecRep_04)
	- 20141125@Jamie: Use Acc_CustomerInfo_Execrep_04 instead of Acc_ExecRep_Cust_04 [Redmine:#26497]		
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines, Acc_CustomerSelCheckEnable to DBCUST.CustDB)
Param's Explanation:
• @custid: customer id.   
• @DisabledHRFixedOdds: status
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
Declare @RoleID tinyint , @UplineDisableHRFixedOdds bit, @Old_DisableHRFixedOdds bit

select	@RoleID = RoleID,
		@Old_DisableHRFixedOdds = isnull(DisableHRFixedOdds, 0)

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
IF (@DisableHRFixedOdds = 1 or (@DisableHRFixedOdds = 0 and @EnableDownlinesHRFixedOdds = 1))
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

if @Old_DisableHRFixedOdds = @DisableHRFixedOdds RETURN

if @DisableHRFixedOdds = 0 -- check status upline
begin			
	if @RoleID = 3
		SELECT @UplineDisableHRFixedOdds = isnull(DisableHRFixedOdds,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT SRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 2
		SELECT @UplineDisableHRFixedOdds = isnull(DisableHRFixedOdds,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT MRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 1
		SELECT @UplineDisableHRFixedOdds = isnull(DisableHRFixedOdds,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT Recommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	IF @RoleID = 4 SELECT @UplineDisableHRFixedOdds = 0   --not checking the upline when the customer is the super
		
	IF @UplineDisableHRFixedOdds = 1
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'Your account was disabled Horse Racing Fixed Odds betting. Cannot edit customer.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60017,@Language)
						END, @ErrCode = 105
		return
	END 
end



---------------------

update CustInfo with (ROWLOCK, UPDLOCK) set DisableHRFixedOdds = @DisableHRFixedOdds
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
IF (@DisableHRFixedOdds = 1 or (@DisableHRFixedOdds = 0 and @EnableDownlinesHRFixedOdds = 1)) --Disable all downline or enable all downline
BEGIN TRY
	--20130926@Kathy: Apply ExecRep 
	EXEC [Acc_CustomerInfo_Execrep_04]
		@CustID		= @CustID,
		@RoleID		= @RoleID,
		@Action		= 'DisableHRFixedOdds',
		@DisableHRFixedOdds = @DisableHRFixedOdds     
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

Select @LogSPData = '<Acc_CustomerUpdDisableHRFixedOdds CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
					'DisabledHRFixedOdds="'+ coalesce(cast(@DisableHRFixedOdds as varchar(50)),space(1)) + '" '+
					'EnableDownlinesHRFixedOdds="'+ coalesce(cast(@EnableDownlinesHRFixedOdds as varchar(50)),space(1)) + '" '+
					'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
					'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
					'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+
					'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1147,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerUpdDisableHRFixedOdds CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
						'DisabledHRFixedOdds="'+ coalesce(cast(@DisableHRFixedOdds as varchar(50)),space(1)) + '" '+
						'EnableDownlinesHRFixedOdds="'+ coalesce(cast(@EnableDownlinesHRFixedOdds as varchar(50)),space(1)) + '" '+
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
						'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" '+
						'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+'" '+
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
						
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1147,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration		
END CATCH


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableHRFixedOdds] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableHRFixedOdds] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableHRFixedOdds] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdDisableHRFixedOdds] TO [vnteam] AS [dbo]