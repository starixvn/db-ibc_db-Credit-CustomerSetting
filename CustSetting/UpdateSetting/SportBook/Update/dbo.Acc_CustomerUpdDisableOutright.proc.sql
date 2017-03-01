ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableOutright]
	@CustID int,
	@DisableOutright bit,	
	@SubAccID int = 0, --Sub-AccountID
	@UserID int,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@IP varchar(15)=''
AS
/*
Created: 
Task : Update status 'DisableOutright' for custinfo
DB: DBTXN/bodb02
Original:

Revisions:
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090909@Phuc: check upline suspended.
	- 20090917@Phuc: write log into DBLOG.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20101021@Henry: Record execution time
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20121206@Scott : Check Allowed downlines during peak hour at weekend  
	- 20130218@Dan: Change linked server DB053 to DBAGE; Write more log on DBTXN server in case of DBLOG server failure
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines, Acc_CustomerSelCheckEnable to DBCUST.CustDB)
Param's Explanation:
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

---------------------------

Declare @roleid tinyint, @Old_DisableOutright bit, @UplineDisableOutright bit, @srecommend int, @mrecommend int, @recommend int

select 
	@roleid = roleid, 
	@Old_DisableOutright = DisableOutright,
	@srecommend = srecommend,
	@mrecommend = mrecommend,
	@recommend = recommend
from custinfo with (nolock)
where custid = @custid


-- Check Allowed downlines during peak hour at weekend 
EXEC Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
											@roleid=@roleid,
											@isExecRep=0,
											@Language=@Language,
											@ErrMsg=@ErrMsg output,
											@ErrCode=@ErrCode output
if @ErrCode <>0 return 
--End 

IF @Old_DisableOutright = @DisableOutright 
	return

IF @roleid = 1
	Select @UplineDisableOutright = isnull(disableoutright,0) from Custinfo with (nolock) where custid = @recommend 
ELSE IF @roleid = 2
	Select @UplineDisableOutright = isnull(disableoutright,0) from Custinfo with (nolock) where custid = @mrecommend 
ELSE IF @roleid = 3
	Select @UplineDisableOutright = isnull(disableoutright,0) from Custinfo with (nolock) where custid = @srecommend 
ELSE IF @roleid = 4
	Select @UplineDisableOutright = 0

IF @UplineDisableOutright = 1
BEGIN
	SELECT @ErrMsg =  CASE @Language 
						WHEN 'E' THEN 'Your account was disabled outright. Cannot edit member.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](60016,@Language)
					END, @ErrCode = 105
	return
END 


select @roleid = isnull(@roleid, 0)

if @roleid not in (1,2,3,4)
BEGIN
	Select @ErrMsg = case @Language 
						when 'E' then 'Invalid user!!'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
					end	,
		@ErrCode = 100	
	return
END


update custinfo with (ROWLOCK, UPDLOCK) set DisableOutright = @DisableOutright
where custid = @custid

if (@@error <> 0)
begin
	Select @ErrMsg =
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end	, @ErrCode = 101
	return
end

if @roleid = 4
begin
	update custinfo with (ROWLOCK, UPDLOCK) set DisableOutright = @DisableOutright where srecommend = @custid
	if (@@error <> 0)
	begin
		Select @ErrMsg = 
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end	, @ErrCode = 102
	return
	end
end

if @roleid = 3
begin
	update custinfo with (ROWLOCK, UPDLOCK) set DisableOutright = @DisableOutright where mrecommend = @custid
	if (@@error <> 0)
	begin
		Select @ErrMsg = 
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end	, @ErrCode = 103
	return
	end
end

if @roleid = 2
begin
	update custinfo with (ROWLOCK, UPDLOCK) set DisableOutright = @DisableOutright where recommend = @custid
	if (@@error <> 0)
	begin
		Select @ErrMsg = 
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end	, @ErrCode = 104
	return
	end
end

Declare @LogSPData varchar(8000)
Select @LogSPData = '<Acc_CustomerUpdDisableOutright CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +
'DisableOutright="'+ coalesce(cast(@DisableOutright as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))  + '" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1111,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerUpdDisableOutright CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +
	'DisableOutright="'+ coalesce(cast(@DisableOutright as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))  + '" />'	
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1111,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH

		
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableOutright] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableOutright] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdDisableOutright] TO vnteam
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableOutright] TO [bodbExtAccNet]