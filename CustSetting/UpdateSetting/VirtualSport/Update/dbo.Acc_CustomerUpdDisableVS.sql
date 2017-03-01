ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableVS]
	@CustID					INT,	
	@Disable			BIT,
	@DisableDownlines	BIT = true, --Disable all downline
	@SubAccID				INT = 0, --Sub-AccountID
	@UserID					INT,
	@Language				VARCHAR(2) = 'E',
	@ErrCode				INT = 0 OUTPUT,
	@ErrMsg					NVARCHAR(200) = '' OUTPUT,
	@IP						VARCHAR(15)=''
AS
/*
Created: 20120801@dan.nguyen
Task : Update Vistual Sport status for customer
DB: DBTXN/CustDB
Original: Acc_CustomerUpdDisable151_31
	
Revisions:
    - 20121101: allow updating downline only if number of customer <= 5000
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20121206@Scott : Check Allowed downlines during peak hour at weekend
    - 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
	- 20130926@Kathy: Apply execRep
	- 20131108@Elodie: Splitting bodb02 into CustDB (Turn to use Acc_ExecRep_Cust_04)	
	- 20141125@Jamie: Use Acc_CustomerInfo_Execrep_04 instead of Acc_ExecRep_Cust_04 [Redmine:#26497]
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines, Acc_CustomerSelCheckEnable to DBCUST.CustDB)
	- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]

Param's Explanation:
• @custid: customer id.   
• @Disable: status
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
Declare @RoleID tinyint , @UplineDisable bit, @Old_Disable bit

select	@RoleID = RoleID,
		@Old_Disable = isnull(DisableVirtualSports, 0)
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

-- Only direct upline have update permission
IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
BEGIN
	SELECT @ErrMsg = 'You don''t have permission to perform this action.',
		   @ErrCode = 103	
	RETURN
END
	
if @Old_Disable = @Disable RETURN--and @IsUpdDownline = 0

if @Disable = 0 -- check status upline
begin			
	if @RoleID = 3
		SELECT @UplineDisable = isnull(DisableVirtualSports,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT SRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 2
		SELECT @UplineDisable = isnull(DisableVirtualSports,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT MRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	if @RoleID = 1
		SELECT @UplineDisable = isnull(DisableVirtualSports,0) FROM CustInfo with (nolock)
		WHERE custid = (SELECT Recommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	IF @RoleID = 4 SELECT @UplineDisable = 0   --not checking the upline when the customer is the super
		
	IF @UplineDisable = 1
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'Account disabled for Virtual Sports. Unable to edit downlines.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60015,@Language)
						END, @ErrCode = 105
		return
	END 
end

--Check Allowed downlines during peak hour at weekend
IF (@Disable = 1 or (@Disable = 0 and @DisableDownlines = 0))
BEGIN
	EXEC Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
											@roleid=@roleid,
											@isExecRep=1,
											@Language=@Language,
											@ErrMsg=@ErrMsg output,
											@ErrCode=@ErrCode output
		IF @ErrCode <>0 RETURN
		
END
---------------------

update CustInfo with (ROWLOCK, UPDLOCK) set DisableVirtualSports = @Disable
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
if (@Disable = 1 or (@Disable = 0 and @DisableDownlines = 0)) --Disable all downline or enable all downline
BEGIN TRY
	--20130924@Kathy: Apply ExecRep 
	EXEC [Acc_CustomerInfo_Execrep_04]
			@CustID		= @CustID,
			@RoleID		= @RoleID,
			@Action		= 'DisableVS',
			@DisableVS = @Disable
END TRY
BEGIN CATCH
	Select @ErrMsg = case @Language when 'E' then 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					 end
	IF @RoleID = 4
		SELECT 	@ErrCode = 102
	ELSE IF @RoleID = 3
		SELECT 	@ErrCode = 103	
	ELSE IF @RoleID = 2
		SELECT 	@ErrCode = 104

	RETURN
END CATCH

declare @LogSPData varchar(2000)

Select @LogSPData = '<Acc_CustomerUpdDisableVS CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
					'Disable="'+ coalesce(cast(@Disable as varchar(50)),space(1)) + '" '+
					'DisableDownlines="'+ coalesce(cast(@DisableDownlines as varchar(50)),space(1)) + '" '+
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
		@ActionID = 1136,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerUpdDisableVS CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
					'Disable="'+ coalesce(cast(@Disable as varchar(50)),space(1)) + '" '+
					'DisableDownlines="'+ coalesce(cast(@DisableDownlines as varchar(50)),space(1)) + '" '+
					'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
					'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
					'ErrMsg="'+ ERROR_MESSAGE() + '" ' +
					'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1136,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration
END CATCH

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableVS] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableVS] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableVS] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdDisableVS] TO [vnteam] AS [dbo]