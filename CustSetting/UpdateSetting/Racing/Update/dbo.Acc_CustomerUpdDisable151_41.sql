ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisable151_41]
	@CustID					INT,
	@Disable151_41			BIT,
	@DisableDownlines151_41	BIT = true, --Disable all downline
	@SubAccID				INT = 0, --Sub-AccountID
	@UserID					INT,
	@SystemID				TINYINT = 1,
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
	- 20170303@Winnie: Change enable behavior [Redmine: #72336]
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
		,@HasDownline BIT = 0 
		,@DisableDownlines_Old BIT = 0


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
SELECT top 1 @HasDownline = 1   
	FROM dbo.CustInfo WITH (NOLOCK)  
	WHERE (@RoleID = 4 AND srecommend = @CustID and roleid = 3)  
		OR (@RoleID = 3 AND mrecommend = @CustID and roleid = 2)  
		OR (@RoleID = 2 AND recommend = @CustID and roleid = 1)  
IF (@Old_Disable151_41 = @Disable151_41 AND @Disable151_41=1) OR  (@Old_Disable151_41 = @Disable151_41 AND @Disable151_41=0 AND @DisableDownlines151_41=1) 
BEGIN
SELECT @ErrCode=1
RETURN
END
IF (@Old_Disable151_41 = @Disable151_41 AND @Disable151_41=0 AND @DisableDownlines151_41=0)
	BEGIN
	IF @HasDownline = 1
	BEGIN
		IF @roleid = 4 
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE srecommend = @custid AND roleid<>4  AND DisableOpenTote = 1)
				SET @DisableDownlines_Old = 1
		END
		ELSE IF @roleid = 3
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE mrecommend = @custid AND roleid<>3  AND DisableOpenTote = 1)
				SET @DisableDownlines_Old = 1
		END
		ELSE IF @roleid = 2
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE recommend = @custid AND roleid<>2 AND DisableOpenTote = 1)
				SET @DisableDownlines_Old = 1
		END
	END
		IF @DisableDownlines_Old=0
		BEGIN
		SELECT @ErrCode=1
		RETURN
		END
END


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
IF (@Disable151_41 = 1 AND @SystemID <> 1 AND @roleid IN (4,3,2))
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'You are not allowed to perform this action.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90012,@Language)
						END, @ErrCode = 103
		RETURN
	END 
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
IF ( @RoleID > 1 AND 
		(@Disable151_41 = 1  
			OR (@Disable151_41 = 0 AND (@DisableDownlines151_41 = 0 AND @HasDownline = 1))  
		)  
		) 
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

/*1119	Acc_CustomerUpdDisableOpenTote_xtest	Update Enabled/Disabled Horse racing status*/
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