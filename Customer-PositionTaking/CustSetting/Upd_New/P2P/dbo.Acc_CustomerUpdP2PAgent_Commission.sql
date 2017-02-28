ALTER PROCEDURE [dbo].[Acc_CustomerUpdP2PAgent_Commission]
	@custid INT,
	@v253discount_1 DECIMAL(9,8),--Comm for Game
	@v253discount_2 DECIMAL(9,8),--Comm for Private Games
	@SubAccID INT = 0, --Sub-AccountID
	@UserID INT = 0, 
	@Language VARCHAR(2) = 'E',
	@IP VARCHAR(40)='',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
Created: 20110421@Amy
Task : Update Agent's P2P Commission
DB: DBTXN/bodb02
Original:

Revisions: 
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130318@Elodie: Write more log on DBTXN server in case of DBLOG server failure
	
Param's Explanation:
@ErrCode:
	= 0: Update commission successfully.
	> 0: SpecIFic Error.
	range: 101-102
@ErrMsg: Error description.
*/

SET NOCOUNT ON

DECLARE @startRun DATETIME,@duration INT
SET @startRun = getdate()

DECLARE @Old_v253discount_1 DECIMAL(9,8),@Old_v253discount_2 DECIMAL(9,8);

DECLARE @Maxdiscount_1 DECIMAL(9,8),@Maxdiscount_2 DECIMAL(9,8),@GroupID Tinyint;

DECLARE  cur_discount CURSOR FOR
SELECT PG.GROUPID ,
	Case WHEN PD.Maxdiscount > PG.ADISCOUNT THEN PG.ADISCOUNT
		ELSE PD.Maxdiscount END
FROM DBO.CUSTINFO (nolock) INF
Inner Join DBO.P2PDEFAULTSETTING (nolock) PD
	On INF.CURRENCY = PD.CURRENCY
INNER JOIN DBO.P2PGROUPCOMM (NOLOCK) PG 
	ON INF.mrecommend = PG.CUSTID
Where INF.CUSTID = @custid ;

OPEN cur_discount ;

FETCH NEXT FROM cur_discount Into  @GroupID,@Old_v253discount_1 
WHILE @@FETCH_STATUS = 0	
	Begin
		IF (@GroupID = 1 )
			SET @Maxdiscount_1 = @Old_v253discount_1
		Else
			SET @Maxdiscount_2 = @Old_v253discount_1
		FETCH NEXT FROM cur_discount Into @GroupID,@Old_v253discount_1
	End
Close cur_discount 
Deallocate cur_discount 
	
--Check Param
IF	@v253discount_1 < 0 OR @v253discount_1 > @Maxdiscount_1
BEGIN
	SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Invalid commission rate (Game).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](8,@Language)
					END, @ErrCode = 101
	RETURN
END

IF	@v253discount_2 < 0 OR @v253discount_2 > @Maxdiscount_2
BEGIN
	SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Invalid commission rate (Private Game).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](9,@Language)
					END, @ErrCode = 102
	RETURN
END

SELECT @Old_v253discount_1= discount
FROM DBO.P2PGroupComm WITH (NOLOCK) WHERE CustID = @custid AND GroupID=1

SELECT @Old_v253discount_2= discount
FROM DBO.P2PGroupComm WITH (NOLOCK) WHERE CustID = @custid AND GroupID=2

--Update for Agent
UPDATE DBO.P2PGroupComm WITH (ROWLOCK, UPDLOCK)
SET	discount = CASE	WHEN GroupID =1 AND ISNULL(@Old_v253discount_1,0) <> @v253discount_1 THEN @v253discount_1 
					WHEN GroupID =2 AND ISNULL(@Old_v253discount_2,0) <> @v253discount_2 THEN @v253discount_2 
				ELSE discount END
WHERE custid=@custid and GroupID in (1,2)

-- Update for Member level
UPDATE gc WITH (ROWLOCK, UPDLOCK) 
SET	gc.discount = CASE WHEN GroupID =1 THEN @v253discount_1 
					WHEN GroupID =2 THEN @v253discount_2 
					ELSE discount END
FROM DBO.P2PGroupComm gc 
	INNER JOIN DBO.CustInfo c WITH (NOLOCK) ON gc.CustID=c.CustID
WHERE c.recommend = @custid AND GroupID IN (1,2) AND c.roleid=1

-- Update for Member level update playerdiscount = discount if playerdiscount > discount
UPDATE gc WITH (ROWLOCK, UPDLOCK) 
SET	gc.playerdiscount = gc.discount
FROM DBO.P2PGroupComm gc 
	INNER JOIN DBO.CustInfo c WITH (NOLOCK) ON gc.CustID=c.CustID
WHERE c.recommend = @custid AND c.roleid=1 AND GroupID IN (1,2) AND gc.playerdiscount > gc.discount

DECLARE @LogSPData VARCHAR(5000)
DECLARE @TrackingValue2 VARCHAR(5000)

SELECT @LogSPData = '<Acc_CustomerUpdP2PAgent_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'discount_1="'+ coalesce(cast(@v253discount_1 as varchar(50)),space(1)) + '" ' +
'discount_2="'+ coalesce(cast(@v253discount_2 as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(40)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

SELECT @TrackingValue2 = '<Acc_CustomerUpdP2PAgent_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'discount_1="'+ coalesce(cast(@old_v253discount_1 as varchar(50)),space(1)) + '" ' +
'discount_2="'+ coalesce(cast(@old_v253discount_2 as varchar(50)),space(1)) + '" ' +
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
		@ActionID = 222,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END TRY
BEGIN CATCH
	SELECT @LogSPData = '<Acc_CustomerUpdP2PAgent_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'discount_1="'+ coalesce(cast(@v253discount_1 as varchar(50)),space(1)) + '" ' +
		'discount_2="'+ coalesce(cast(@v253discount_2 as varchar(50)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(40)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ error_message() + '" />'

SELECT @TrackingValue2 = '<Acc_CustomerUpdP2PAgent_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'discount_1="'+ coalesce(cast(@old_v253discount_1 as varchar(50)),space(1)) + '" ' +
		'discount_2="'+ coalesce(cast(@old_v253discount_2 as varchar(50)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(40)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ error_message() + '" />'
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 222,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
END CATCH		
	
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdP2PAgent_Commission] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdP2PAgent_Commission] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdP2PAgent_Commission] TO vnteam


