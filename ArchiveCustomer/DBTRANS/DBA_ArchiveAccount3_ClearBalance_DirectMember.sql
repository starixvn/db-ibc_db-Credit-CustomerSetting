/*<info serverAlias="DBSIC-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount3_ClearBalance_DirectMember]
	@AccName varchar(50),	
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT
AS
/*
	Description: Clear Balance
	Create date: 20241118@Max
	Original SP: 
	DB: DBTXN/bodb02
	Revisions:    
		- 20241118@Max: Offer Direct Member for Super/Master [Redmine: #211969]
Note:

*/
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

print  'Start:' + convert(varchar(50), getdate(), 113)

Declare @roleid int, @UplineId int, @Amount MONEY,
		@custid int, @member_recommend int, @member_mrecommend int, @member_srecommend int,
		@mrecommend int, @srecommend int, 
		@currency int, @actualrate float, @currencyName nvarchar(10),
		@membername varchar(50), @Uplinename varchar(50),
		@memberBalance MONEY

Declare @refno bigint, @TransID bigint, @TransID2 bigint, @Now datetime, @Enabled bit

DECLARE @MBBU TABLE (BalanceUpDay SMALLDATETIME, MoveBetsDay SMALLDATETIME)
INSERT INTO @MBBU (BalanceUpDay, MoveBetsDay)
EXEC dbo.Age_SelBalanceUpDay

DECLARE @BalanceUpDate SMALLDATETIME
SELECT  @BalanceUpDate = BalanceUpDay FROM @MBBU

SELECT @roleid = roleid, @UplineId = custid, @Enabled = Enabled, @Uplinename = username, @mrecommend = mrecommend, @srecommend = srecommend
FROM CustDB.dbo.custinfo (nolock)
WHERE username = @AccName

if isnull(@UplineId,0) = 0 or @roleid NOT IN (3,4) or @Enabled = 1
BEGIN
	Select @ErrMsg = @AccName +':'+ 'Invalid Upline Username', @ErrCode = 101
	print @ErrMsg
	return
END

--== Check new active trans ==========================

IF EXISTS(select 1 from dbo.bettrans with (nolock) where mrecommend = @UplineId OR srecommend = @UplineId)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This upline just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, roleid) VALUES(@UplineId, @roleid) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from dbo.transfer with (nolock) where (MRecommend = @UplineId OR SRecommend = @UplineId) AND bettype < 20000)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This upline just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, roleid) VALUES(@UplineId, @roleid) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from dbo.translog with (nolock) where mrecommend = @UplineId OR srecommend = @UplineId)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This upline just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, roleid) VALUES(@UplineId, @roleid) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from dbo.bettransLC with (nolock) where mrecommend = @UplineId OR srecommend = @UplineId)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This upline just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, roleid) VALUES(@UplineId, @roleid)
	print @ErrMsg
	return
END

IF EXISTS(select 1 from dbo.bettransRNG with (nolock) where mrecommend = @UplineId OR srecommend = @UplineId)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This upline just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, roleid) VALUES(@UplineId, @roleid) 
	print @ErrMsg
	return
END

--==========================================================
--CREATING TEMP TABLES
--==========================================================

CREATE TABLE #Member 
(
	custid int PRIMARY KEY, recommend int, mrecommend int, srecommend int, 
	currency int, actualrate float, currencyName nvarchar(10),
	membername varchar(50), memberBalance MONEY default 0
)

IF @roleid NOT IN (3,4) RETURN 0
	
IF @roleid = 4
BEGIN
	INSERT INTO #Member 
	      (custid, recommend, mrecommend, srecommend, currency, actualrate, currencyName,
		   membername)
	SELECT c.custid, c.recommend, c.mrecommend, c.srecommend, c.currency,e.actualrate, e.currency,
			c.username
	FROM CustDB.dbo.custinfo c (nolock)
		inner join CustDB.dbo.exchange e  (nolock) on c.currency = e.exchangeid 
	WHERE  c.srecommend = @UplineId 
		AND c.roleid = 1
		AND c.recommend = -4
		
END
ELSE IF @roleid = 3
BEGIN
	INSERT INTO #Member 
	      (custid, recommend, mrecommend, srecommend, currency, actualrate, currencyName,
		   membername)
	SELECT c.custid, c.recommend, c.mrecommend, c.srecommend, c.currency,e.actualrate, e.currency,
			c.username
	FROM CustDB.dbo.custinfo c (nolock)
		inner join CustDB.dbo.exchange e  (nolock) on c.currency = e.exchangeid 
	WHERE  c.mrecommend = @UplineId 
		AND c.roleid = 1
		AND c.recommend = -3
END

IF @@ROWCOUNT = 0
		RETURN

print @AccName +':'+ 'Temp Table Done:' + convert(varchar(50), getdate(), 113)	

Update #Member set memberBalance = b.MemberBalance
from #Member
	inner join (
		Select custid, SUM(isnull(winlost-actual_stake+playercomm, 0)) as MemberBalance
		From transfer with (NOLOCK)
		Where 1 = CASE WHEN bettype = 20000 AND winlostdate > @BalanceUpDate THEN 0 --> new bal
             WHEN winlostdate < @BalanceUpDate THEN 0 --> old data
             ELSE 1 END
		group by custid
		) b on #Member.custid = b.custid	

print @AccName +':'+ 'Member Balance Done:' + convert(varchar(50), getdate(), 113)	

-- Start Transfer (CURSOR Loop) 
SET @Now = CURRENT_TIMESTAMP

--------------------------START:MEMBER-AGENT-------------------------------

DECLARE CS_custid
	CURSOR FOR
	SELECT custid, recommend, mrecommend, srecommend, currency, actualrate, currencyName,
		   membername, memberBalance
	FROM #Member
	WHERE memberBalance <> 0		

OPEN CS_custid
FETCH NEXT FROM CS_custid INTO @custid, @member_recommend, @member_mrecommend, @member_srecommend, @currency, @actualrate, @currencyName, 
							   @membername, @memberBalance

WHILE @@FETCH_STATUS = 0
BEGIN		
		print @AccName +':'+ 'MEMBER-AGENT-->Member:' + @membername + ' ' + CONVERT(varchar(30),@memberBalance,2)
	
		EXEC Get_Refno_Transid @RefNo = @RefNo OUTPUT
		EXEC Get_Bettrans_TransID @TransID = @TransID OUTPUT
		EXEC Get_Bettrans_TransID @TransID = @TransID2 OUTPUT
	
		IF (@memberBalance > 0) 
		BEGIN
			INSERT INTO transfer 
			   (TransId, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
				statusID,  winlostdate, currency, actualrate, currencyName, 
				recommend, mrecommend, srecommend, scomm, swinlost,ip)
			VALUES (@TransID, @UserID, @UplineId, @Uplinename, @refno, @Now, 21004, 'For Delete Account - From Customer::'+@membername, @memberBalance, 0, 
				131, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
				0, @MRecommend, @srecommend, 0, 0,'')
			if @@Error <> 0
			BEGIN
				RaisError (@ErrMsg, 16, 1)

				UPDATE dbo.Transfer WITH(ROWLOCK,UPDLOCK)
				SET     custid = 0, 
						Recommend = 0, 
						MRecommend = 0, 
						SRecommend = 0, 
						Winlost = 0, 
						Actual_Stake = 0, 
						RepUpdateTime = SYSDATETIME()
				WHERE  TransId = @TransID

				return
			END
			
			-- update member's balance debit
			EXEC Dot_BalanceDebitUpd @CustID = @CustID, @balance = @memberbalance, @type = 2, @IsForced = 1
			
			INSERT INTO transfer
			   (TransId, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
				statusID, winlostdate, currency, actualrate, currencyName,
				recommend, mrecommend, srecommend, scomm, swinlost,ip)
			VALUES 
			   (@TransID2, @UserID, @custid, @membername, @refno, @Now, 21004, 'For Delete Account - To Customer::'+@Uplinename, 0, @memberBalance,
				131, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
				@member_recommend, @member_mrecommend, @member_srecommend, 0, 0,'')
			if @@Error <> 0
			BEGIN
				RaisError (@ErrMsg, 16, 1)

				UPDATE dbo.Transfer WITH(ROWLOCK,UPDLOCK)
				SET     custid = 0, 
						Recommend = 0, 
						MRecommend = 0, 
						SRecommend = 0, 
						Winlost = 0, 
						Actual_Stake = 0, 
						RepUpdateTime = SYSDATETIME()
				WHERE  TransId IN (@TransID, @TransID2)

				--rollback balance 

				EXEC Dot_BalanceCreditUpd @CustID = @CustID, @balance = @memberbalance, @type = 2
				return
			END			
			
		END
		ELSE if (@memberBalance<0) 
		BEGIN
			SET @memberBalance = abs(@memberBalance) 			
			INSERT INTO transfer 
			   (TransId, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
				statusID, winlostdate, currency, actualrate, currencyName, 
				recommend, mrecommend, srecommend, scomm, swinlost,ip)
			VALUES 
			   (@TransID, @UserID, @UplineId, @Uplinename, @refno, CURRENT_TIMESTAMP, 21004, 'For Delete Account - To Customer::'+@membername, 0, @memberBalance,
				131, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
				0, @MRecommend, @srecommend, 0, 0,'')
			if @@Error <> 0
			BEGIN
				RaisError (@ErrMsg, 16, 1)

				UPDATE dbo.Transfer WITH(ROWLOCK,UPDLOCK)
				SET     custid = 0, 
						Recommend = 0, 
						MRecommend = 0, 
						SRecommend = 0, 
						Winlost = 0, 
						Actual_Stake = 0, 
						RepUpdateTime = SYSDATETIME()
				WHERE  TransId = @TransID

				return
			END
			
			INSERT INTO transfer
			   (TransId, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
				statusID, winlostdate, currency, actualrate, currencyName,
				recommend, mrecommend, srecommend, scomm, swinlost,ip)
			VALUES 
			   (@TransID2, @UserID, @custid, @membername, @refno, CURRENT_TIMESTAMP, 21004, 'For Delete Account - From Customer::'+@Uplinename, @memberBalance, 0,
				131, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
				@member_recommend, @member_mrecommend, @member_srecommend, 0, 0,'')
			if @@Error <> 0
			BEGIN
				RaisError (@ErrMsg, 16, 1)

				UPDATE dbo.Transfer WITH(ROWLOCK,UPDLOCK)
				SET     custid = 0, 
						Recommend = 0, 
						MRecommend = 0, 
						SRecommend = 0, 
						Winlost = 0, 
						Actual_Stake = 0, 
						RepUpdateTime = SYSDATETIME()
				WHERE  TransId IN (@TransID, @TransID2)

				return
			END
			---update member's balance credit
			EXEC Dot_BalanceCreditUpd @CustID = @CustID, @balance = @memberbalance, @type = 2
		END		
		
	FETCH NEXT FROM CS_custid INTO @custid, @member_recommend, @member_mrecommend, @member_srecommend, @currency, @actualrate, @currencyName, 
							   @membername, @memberBalance
END

CLOSE CS_custid
DEALLOCATE CS_custid
--------------------------END:MEMBER-AGENT-------------------------------	
print @AccName +':'+ 'Member cursor Done:' + convert(varchar(50), getdate(), 113)

DROP TABLE #Member

------------------
declare @LogSPData varchar(5000)

Select @LogSPData = '<DBA_ArchiveAccount3_ClearBalance_DirectMember AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
					'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+ '" ' +
					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))  + '"/>'
					
set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)
					
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @UplineId,
	@ActionID = 1502,
	@TrackingValue = @LogSPData,
	@duration = @duration

