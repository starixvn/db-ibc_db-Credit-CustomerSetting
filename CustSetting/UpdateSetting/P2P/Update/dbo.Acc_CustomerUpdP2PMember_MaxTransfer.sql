 ALTER PROCEDURE [dbo].[Acc_CustomerUpdP2PMember_MaxTransfer]
	@custid INT,
	@MaxTransfer MONEY,
	@IsDailyAutoReset BIT,

	@SubAccID INT = 0, --Sub-AccountID
	@UserID INT = 0, 
	@Language VARCHAR(2) = 'E',
	@IP VARCHAR(40)='',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
Created: 20110421@Amy
Task : Update Agent's P2P Max Transfer limit
DB: DBTXN/bodb02
Original:

Revisions: 
	- 20120329@Sophia: Change LogAction to 704
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130318@Elodie: Write more log on DBTXN server in case of DBLOG server failure

Param's Explanation:
@ErrCode:
	= 0: Update commission successfully.
	> 0: SpecIFic Error.	
	range: 301-302
@ErrMsg: Error description.
*/

SET NOCOUNT ON

DECLARE @startRun DATETIME, @duration INT
SET @startRun = getdate()

DECLARE @Old_MaxTransfer MONEY,@Old_IsDailyAutoReset BIT, @MinTransferLimit MONEY, @MaxTransferLimit MONEY, @Roleid INT, @Currency int
DECLARE @UplineIsAutoReset BIT, @Uplinedisablep2p BIT;

SELECT @MaxTransferLimit = sa.MaxTransferP2P,
		@Roleid=c.roleid,
		@Currency = sa.currency,
		@Old_MaxTransfer = c.MaxTransferP2P,
		@Old_IsDailyAutoReset = c.IsAutoResetP2P,		
		@UplineIsAutoReset = sa.IsAutoResetP2P 
FROM CustInfo c WITH (NOLOCK) 
	INNER JOIN CustInfo sa WITH (NOLOCK) ON sa.custid=c.recommend
WHERE c.custid=@custid

SELECT @MinTransferLimit = MinCredit 
FROM P2PDefaultSetting WITH (NOLOCK)
WHERE Currency = @Currency

IF @Roleid <>1
BEGIN
	SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Invalid user!!'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
					END	,
		@ErrCode = 301	
	RETURN
END

IF @MaxTransfer < @MinTransferLimit or @MaxTransfer > @MaxTransferLimit
BEGIN
	SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Max transfer credit must be in range'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](50008,@Language)
					END	
					+ ' '+ CONVERT(VARCHAR(20),@MinTransferLimit) +'-'+ CONVERT(VARCHAR(20),@MaxTransferLimit) 
			,@ErrCode = 302	
	RETURN
END

IF @UplineIsAutoReset = 0 AND @IsDailyAutoReset = 1
BEGIN
	SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'You are not allowed to change Daily Auto Reset Limit.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](10022,@Language)
					END	
			,@ErrCode = 303
	RETURN
END

UPDATE custInfo WITH (UPDLOCK,ROWLOCK)
SET MaxTransferP2P = @MaxTransfer,
	IsAutoResetP2P = @IsDailyAutoReset
WHERE custid = @custid

DECLARE @LogSPData VARCHAR(5000)
DECLARE @TrackingValue2 VARCHAR(5000)

SELECT @LogSPData = '<Acc_CustomerUpdP2PMember_MaxTransfer custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MaxTransfer="'+ coalesce(cast(@MaxTransfer as varchar(50)),space(1)) + '" ' +
'AutoReset="'+ coalesce(cast(@IsDailyAutoReset as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(40)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

SELECT @TrackingValue2 = '<Acc_CustomerUpdP2PMember_MaxTransfer custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MaxTransfer="'+ coalesce(cast(@Old_MaxTransfer as varchar(50)),space(1)) + '" ' +
'AutoReset="'+ coalesce(cast(@Old_IsDailyAutoReset as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(40)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

SET @duration  = datedIFf (millisecond,@startRun,getdate())

BEGIN TRY
	--Log customer info 
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 704,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END TRY
BEGIN CATCH
	SELECT @LogSPData = '<Acc_CustomerUpdP2PMember_MaxTransfer custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'MaxTransfer="'+ coalesce(cast(@MaxTransfer as varchar(50)),space(1)) + '" ' +
	'AutoReset="'+ coalesce(cast(@IsDailyAutoReset as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(40)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ error_message() + '" />'

	SELECT @TrackingValue2 = '<Acc_CustomerUpdP2PMember_MaxTransfer custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'MaxTransfer="'+ coalesce(cast(@Old_MaxTransfer as varchar(50)),space(1)) + '" ' +
	'AutoReset="'+ coalesce(cast(@Old_IsDailyAutoReset as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(40)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ error_message() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 704,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END CATCH	

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdP2PMember_MaxTransfer] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdP2PMember_MaxTransfer] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdP2PMember_MaxTransfer] TO vnteam


