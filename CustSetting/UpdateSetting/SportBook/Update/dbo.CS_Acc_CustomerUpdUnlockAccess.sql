/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[CS_Acc_CustomerUpdUnlockAccess]
	@CustID INT,
	@Closed BIT,		
	@UserID INT,	
	@Language VARCHAR(2) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(500) = '' OUTPUT,
	@IP VARCHAR(15)=''
AS
/*
	Created: 20190520@Johnson
	Task : Update Unlock access for customer cn88
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20190520@Johnson: initial sp [redmine: #112225]
		
	Parameter's explanations:	
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT
	SET @startRun = GETDATE()

	--Check disable user
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
	IF @ErrCode <>0 RETURN
	
	DECLARE @roleid TINYINT,
			@old_Closed BIT
	
	SELECT @roleid = roleid, @old_Closed = closed
	FROM custinfo WITH (NOLOCK)
	WHERE custid = @custid
	
	IF @Old_Closed = @Closed 
		RETURN
	
	UPDATE custinfo with (ROWLOCK, UPDLOCK) 
	SET Closed = @Closed
	WHERE custid = @custid
	
	IF (@@error <> 0)
	BEGIN
		SELECT @ErrMsg =
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 101
		RETURN
	END
	
	-- WRITE LOG 

	declare @LogSPData varchar(8000)

	Select @LogSPData = '<CS_Acc_CustomerUpdUnlockAccess CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +
						'Closed="'+ coalesce(cast(@Closed as varchar(50)),space(1)) + '" ' +						
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" ' +						
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 1169,
			@TrackingValue = @LogSPData	,
			@duration = @duration
	END TRY
	BEGIN CATCH
		Select @LogSPData = '<CS_Acc_CustomerUpdUnlockAccess CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +
							'Closed="'+ coalesce(cast(@Closed as varchar(50)),space(1)) + '" ' +							
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" ' +
							'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
							'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+'" ' +							
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 1169,
			@TrackingValue = @LogSPData	,
			@duration = @duration
	END CATCH
END
GO