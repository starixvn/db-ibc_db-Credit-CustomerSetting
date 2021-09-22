/*<info serverAlias="DBBACKUP2-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [DBA_ArchiveAccount3_ClearBalance_MasterSuper]
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
*/
BEGIN

	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()
	
	print  'Start:' + convert(varchar(50), getdate(), 113)

	Declare @refno bigint, @grefno bigint, @Now datetime, @Enabled bit, @MasterBalance MONEY

	CREATE TABLE #temp_recommend (recommend INT PRIMARY KEY)
	
	INSERT INTO #temp_recommend (recommend)
	SELECT DISTINCT custid
	FROM CustDB.dbo.custinfo WITH (NOLOCK)
	WHERE mrecommend = @mrecommend AND roleid = 2
	
	DECLARE @Balance_Recommend MONEY
	DECLARE @Balance_master MONEY
	
	SELECT @Balance_Recommend = ISNULL(SUM(winlost - actual_stake + mwinlost + acomm + awinlost), 0) 
	FROM #temp_recommend r
		INNER JOIN dbo.bettrans b WITH (NOLOCK, INDEX = IX_recommend) ON r.recommend = b.recommend
	OPTION (MAXDOP 1)		
		
	SELECT @Balance_master =  ISNULL(SUM(winlost - actual_stake + mwinlost + acomm + awinlost), 0) 
	FROM bettrans b WITH (NOLOCK)
	WHERE custid = @mrecommend

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

	UPDATE ref with (rowlock, UPDLOCK)  SET   @grefno=transcode=transcode+1
	WHERE  refid='acc'
	if @@Error <> 0
	BEGIN
		delete bettrans where refno = @refno and matchid = 0
		return
	END
	select @refno=200000000000+@grefno

	IF (@MasterBalance > 0) 
	BEGIN
		-- insert Super
		INSERT INTO bettrans 
		   (matchid, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			comstatus, status,statusID, ruben, winlostdate, currency, actualrate, currencyName, 
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES (0, @UserID, @srecommend, @supername, @refno, @Now, 21004, 'For Delete Account - From Customer::'+@mastername, @MasterBalance, 0, 
			@refno, 'Completed',131, 1, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			0, 0, @srecommend, 0, 0,'')
		if @@Error <> 0
		BEGIN
			RaisError (@ErrMsg, 16, 1)
			delete bettrans where refno = @refno and matchid = 0
			return
		END
		
		-- insert Master
		INSERT INTO bettrans
		   (matchid, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			comstatus, status,statusID, ruben, winlostdate, currency, actualrate, currencyName,
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES 
		   (0, @UserID, @mrecommend, @mastername, @refno, @Now, 21004, 'For Delete Account - To Customer::'+ @supername, 0, @MasterBalance,
			@refno, 'Completed',131, 1, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			0, @MRecommend, @srecommend, 0, 0,'')
		if @@Error <> 0
		BEGIN
			RaisError (@ErrMsg, 16, 1)
			delete bettrans where refno = @refno and matchid = 0
			
			return
		END			
		
	END
	ELSE if (@MasterBalance<0) 
	BEGIN
		SET @MasterBalance = abs(@MasterBalance) 
		-- insert for super			
		INSERT INTO bettrans 
		   (matchid, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			comstatus, status, statusID, ruben, winlostdate, currency, actualrate, currencyName, 
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES 
		   (0, @UserID, @srecommend, @supername, @refno, CURRENT_TIMESTAMP, 21004, 'For Delete Account - To Customer::'+ @mastername, 0, @MasterBalance,
			@refno, 'Completed',131, 1, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			0, 0, @srecommend, 0, 0,'')
		if @@Error <> 0
		BEGIN
			RaisError (@ErrMsg, 16, 1)
			delete bettrans where refno = @refno and matchid = 0
			return
		END
		-- insert for master
		INSERT INTO bettrans
		   (matchid, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			comstatus, status,statusID, ruben, winlostdate, currency, actualrate, currencyName,
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES 
		   (0, @UserID, @mrecommend, @mastername, @refno, CURRENT_TIMESTAMP, 21004, 'For Delete Account - From Customer::'+ @supername, @MasterBalance, 0,
			@refno, 'Completed',131, 1, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			0, @MRecommend, @srecommend, 0, 0,'')
		
		if @@Error <> 0
		BEGIN
			RAISERROR (@ErrMsg, 16, 1)
			DELETE bettrans where refno = @refno and matchid = 0
			RETURN
		END
		
	END	
		
	--------------------------END:Master-Super-------------------------------	
	DROP TABLE #temp_recommend
END
    


