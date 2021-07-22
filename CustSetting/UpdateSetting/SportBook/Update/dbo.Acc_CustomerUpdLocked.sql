/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdLocked]
	@CustID int,
	@UserID int,
	@SubAccID int = 0, --Sub-AccountID
	@Locked tinyint = 0,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(500) = '' OUTPUT,
	@IP varchar(15)='',
	@SystemID TINYINT=1
AS
/*
Created: 20210414@Tina
Task : Update status 'Locked Accessed' for customer
DB: DBCUST/CustDB
Original:

Revisions:
    - 20210408@Tina: Lock account & indirect close account [redmine: #148600]

Param's Explanation
• @custid: custid that need to be viewed.   

*/
BEGIN
	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()

	--Check disable user
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
	if @ErrCode <>0 return
	--end

	IF @UserID <> @CustID AND CURRENT_USER <> 'bodbAdminNet' 
		AND EXISTS (SELECT 1 FROM custInfo WITH (NOLOCK) WHERE custid = @CustID AND LockUpd = 1 AND roleid = 1)
	BEGIN
		 SELECT  @ErrMsg = CASE @Language
                                WHEN 'E' THEN 'You are currently not authorized to perform this action. Please contact the Customer Service Department for further assistance.'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](40033,@Language)
                              END ,
                 @ErrCode = 107
         RETURN
	END
	
	---------------------------

	Declare @roleid tinyint, @LoginCount int, @Old_Locked tinyint

	select @roleid = roleid, @LoginCount = logincount
	from customer with (nolock)
	where custid = @custid

	SELECT @Old_Locked = CPS.Locked
	FROM CustProductStatus CPS WITH (NOLOCK)
	WHERE CPS.CustID = @CustID


	-- Only update 'Locked' status if values are different
	IF @Old_Locked = @Locked
		return

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

	update CustProductStatus with (ROWLOCK, UPDLOCK) set Locked = @Locked
	where custid = @custid


	if (@@error <> 0)
	begin
		Select @ErrMsg =
						case @Language 
							when 'E' then 'Update process is unsuccessful!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 101
		return
	end

	-- WRITE LOG 
	declare @LogSPData varchar(8000)

	Select @LogSPData = '<Acc_CustomerUpdLocked CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +
						'Locked="'+ coalesce(cast(@Locked as varchar(50)),space(1)) + '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" ' +
						'SystemID="'+ coalesce(cast(@SystemID as varchar(50)),space(1)) + '" ' +
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

	/* 1105	Acc_CustomerUpdClosed	Update Closed status  */

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 1182,
			@TrackingValue = @LogSPData	,
			@duration = @duration
	END TRY
	BEGIN CATCH
		Select @LogSPData = '<Acc_CustomerUpdLocked CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +
							'Locked="'+ coalesce(cast(@Locked as varchar(50)),space(1)) + '" ' +
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
							'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" ' +
							'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
							'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+'" ' +
							'SystemID="'+ coalesce(cast(@SystemID as varchar(50)),space(1)) + '" ' +
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 1182,
			@TrackingValue = @LogSPData	,
			@duration = @duration
	END CATCH
END

GO
