/*<info serverAlias="DBTXN-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount3_ClearBalance_MasterSuper]
	@recommend INT = 0,
	@agentname varchar(50) = '',	
	@mrecommend INT = 0,
	@srecommend INT = 0,
	@mastername VARCHAR (50) = '',
	@supername VARCHAR (50) = '',
	@actualrate float = 0,
	@currencyName nvarchar(10),
	@currency int = 0,
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT
AS
/*
		Description: Close an Master, Super
		Create date: 20200911
		Original SP: 
		DB: DBTXN/bodb02
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
			- 20201109@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - Stage 2,3,4 - [Redmine:130032]
			- 20201109@Helen: Stage 3 - Tuning - [Redmine:130032]
			- 20210817@Elodie: Change data type of Refno  to bigint instead [Redmine: #160262]
			- 20211209@Eden: Split transfer out of bettrans [RedmineID: #162264]
			- 20220907@Eden: Scale out DBTrans [RedmineID: #158293]
			- 20230227@Evan: Balance-Up support transfer 247 [Redmine: #173554]
			- 20230524@Eden: Scale out DBTRANS for Credit  [Redmine: #181595]
*/
BEGIN

	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()
	
	print  'Start:' + convert(varchar(50), getdate(), 113)

	Declare @refno bigint, @TransID bigint, @TransID2 bigint, @Now datetime, @Enabled bit, @MasterBalance MONEY

	DECLARE @MBBU TABLE (BalanceUpDay SMALLDATETIME, MoveBetsDay SMALLDATETIME)
	INSERT INTO @MBBU (BalanceUpDay, MoveBetsDay)
	EXEC dbo.Age_SelBalanceUpDay

	DECLARE @BalanceUpDate SMALLDATETIME
	SELECT  @BalanceUpDate = BalanceUpDay FROM @MBBU

	CREATE TABLE #temp_recommend (recommend INT PRIMARY KEY)
	
	INSERT INTO #temp_recommend (recommend)
	SELECT DISTINCT custid
	FROM CustDB.dbo.custinfo WITH (NOLOCK)
	WHERE mrecommend = @mrecommend AND roleid = 2

	IF EXISTS(select 1 from dbo.transfer with (nolock) where Recommend IN (SELECT recommend FROM #temp_recommend) AND bettype < 20000)
	BEGIN
		Select @ErrMsg = @mastername +':'+ 'This master just got active trans while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (custid, roleid) VALUES(@mrecommend, 3) 
		print @ErrMsg
		return
	END
	
	DECLARE @Balance_Recommend MONEY
	DECLARE @Balance_master MONEY
	
	SELECT @Balance_Recommend = ISNULL(SUM(winlost - actual_stake + mwinlost + acomm + awinlost), 0) 
	FROM #temp_recommend r
		INNER JOIN dbo.transfer b WITH (NOLOCK, INDEX = IX_recommend) ON r.recommend = b.recommend
	WHERE 1 = CASE WHEN bettype = 20000 AND winlostdate > @BalanceUpDate THEN 0 --> new bal
					 WHEN winlostdate < @BalanceUpDate THEN 0 --> old data
					 ELSE 1 END
	OPTION (MAXDOP 1)	
		
	SELECT @Balance_master =  ISNULL(SUM(winlost - actual_stake + mwinlost + acomm + awinlost), 0) 
	FROM transfer b WITH (NOLOCK)
	WHERE custid = @mrecommend
		AND 1 = CASE WHEN bettype = 20000 AND winlostdate > @BalanceUpDate THEN 0 --> new bal
					 WHEN winlostdate < @BalanceUpDate THEN 0 --> old data
					 ELSE 1 END

	--==========================================================
	--CREATING TEMP TABLES
	--==========================================================
	print @mastername +':'+ 'Temp Table Done:' + convert(varchar(50), getdate(), 113)	

	SET @MasterBalance =  @Balance_Recommend + @Balance_master

	IF @MasterBalance = 0
		RETURN
		
	SET @Now = CURRENT_TIMESTAMP
	--------------------------START:Master-Super-------------------------------
		
	print @mastername +':'+ 'Master-Super-->Master:' + @mastername + ' ' + cast(@MasterBalance as varchar(30))

	EXEC Get_Refno_Transid @RefNo = @RefNo OUTPUT
	EXEC Get_Bettrans_TransID @TransID = @TransID OUTPUT
	EXEC Get_Bettrans_TransID @TransID = @TransID2 OUTPUT

	IF (@MasterBalance > 0) 
	BEGIN
		-- insert Super
		INSERT INTO transfer 
		   (TransId, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			statusID, winlostdate, currency, actualrate, currencyName, 
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES (@TransID, @UserID, @srecommend, @supername, @refno, @Now, 21004, 'For Delete Account - From Customer::'+@mastername, @MasterBalance, 0, 
			131, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			0, 0, @srecommend, 0, 0,'')
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
		
		-- insert Master
		INSERT INTO transfer
		   (TransId, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			statusID, winlostdate, currency, actualrate, currencyName,
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES 
		   (@TransID2, @UserID, @mrecommend, @mastername, @refno, @Now, 21004, 'For Delete Account - To Customer::'+ @supername, 0, @MasterBalance,
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
            WHERE  TransId IN (@TransID, @TransID2)

			return
		END			
		
	END
	ELSE if (@MasterBalance<0) 
	BEGIN
		SET @MasterBalance = abs(@MasterBalance) 
		-- insert for super			
		INSERT INTO transfer 
		   (TransId, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			statusID, winlostdate, currency, actualrate, currencyName, 
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES 
		   (@TransId, @UserID, @srecommend, @supername, @refno, CURRENT_TIMESTAMP, 21004, 'For Delete Account - To Customer::'+ @mastername, 0, @MasterBalance,
			131, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			0, 0, @srecommend, 0, 0,'')
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
		-- insert for master
		INSERT INTO transfer
		   (TransId, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			statusID, winlostdate, currency, actualrate, currencyName,
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES 
		   (@TransID2, @UserID, @mrecommend, @mastername, @refno, CURRENT_TIMESTAMP, 21004, 'For Delete Account - From Customer::'+ @supername, @MasterBalance, 0,
			131, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			0, @MRecommend, @srecommend, 0, 0,'')
		
		if @@Error <> 0
		BEGIN
			RAISERROR (@ErrMsg, 16, 1)

			UPDATE dbo.Transfer WITH(ROWLOCK,UPDLOCK)
            SET     custid = 0, 
                    Recommend = 0, 
                    MRecommend = 0, 
                    SRecommend = 0, 
                    Winlost = 0, 
                    Actual_Stake = 0, 
                    RepUpdateTime = SYSDATETIME()
            WHERE  TransId IN (@TransID, @TransID2)

			RETURN
		END
		
	END	
		
	--------------------------END:Master-Super-------------------------------	
	DROP TABLE #temp_recommend
END