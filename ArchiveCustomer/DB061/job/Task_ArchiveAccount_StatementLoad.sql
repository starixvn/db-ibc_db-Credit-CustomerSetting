/*<info serverAlias="DBRPT-bodb_Report" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [Task_ArchiveAccount_StatementLoad]
AS
/*
	Task: Load statement data incrementally to check credit customers to be archived, used for various stages
	Created: Daniel@20190519
	Database: DBRPT.bodb_Report

	Revisions:
	- 20190519@Daniel: Created

*/
BEGIN
	SET NOCOUNT ON
	declare @status varchar(200)
	declare @from smalldatetime, @to smalldatetime, @fromEx smalldatetime, @toEx smalldatetime
	declare @_from smalldatetime, @_to smalldatetime
	declare @Msg VARCHAR(150), @batch_days int

	set @batch_days = 10 --set days per batch to load avoiding performance issue

	select @status = VValue from bodb02.dbo.Systemsettings with (nolock) where VName = 'aa_Stmt_Status'

	if @status IN('Stage 4 - Done', 'Stage 1 - Running')--start routine - Load statement for stage 1 (3 months)
	begin
		select @from = convert(varchar(10), dateadd(MM, -3, getdate()), 120)

		set @status = 'Stage 1 - Running'

		truncate table tempCustID
	end
	else if @status IN('Stage 1 - Done', 'Stage 2 - Running') --continue load statement for stage 2: load more 1-month statement (4 months)
	begin
		select @from = VValue from bodb02.dbo.Systemsettings with (nolock) where VName = 'aa_Stmt_EndDate'
		select @from =  dateadd(dd, 1, @from)

		set @status = 'Stage 2 - Running'
	end
	else if @status IN('Stage 2 - Done', 'Stage 3 - Running') --continue load statement for stage 3: load more statement (7 months)
	begin
		select @from = VValue from bodb02.dbo.Systemsettings with (nolock) where VName = 'aa_Stmt_EndDate'
		select @from =  dateadd(dd, 1, @from)

		select @fromEx = convert(varchar(10), dateadd(MM, -7, getdate()), 120)

		select @toEx = VValue from bodb02.dbo.Systemsettings with (nolock) where VName = 'aa_Stmt_StartDate'
		select @toEx =  dateadd(dd, -1, @toEx)

		set @status = 'Stage 3 - Running'
	end
	else if @status IN('Stage 3 - Done', 'Stage 4 - Running') --continue load statement for stage 2: load more 1-month statement (4 months)
	begin
		select @from = VValue from bodb02.dbo.Systemsettings with (nolock) where VName = 'aa_Stmt_EndDate'
		select @from =  dateadd(dd, 1, @from)

		set @status = 'Stage 4 - Running'
	end
	else return

	update bodb02.dbo.Systemsettings with(rowlock, updlock) set VValue = @status where VName = 'aa_Stmt_Status'

	SELECT 
		TOP 1 @to = winlostdate--balance-up date
	FROM bodb02.dbo.Bettrans WITH(NOLOCK)
	WHERE bettype = 20000 and matchid = 0 and custid = 3

	--select @from, @to, @status

	select @_from = @from, @_to = dateadd(dd, @batch_days + 1, @_from)

	while (1=1)
	begin
		SELECT @Msg = ''

		if (@_from > @to) SET @_from = @to
		if (@_to > @to) SET @_to = dateadd(dd, 1, @to)

		insert into tempCustID
		SELECT distinct custid
		FROM dbo.STATEMENT WITH (NOLOCK)
		WHERE TransType <> 'bal' 
			AND transdesc NOT LIKE 'For Delete Account%' --exclude clear balance trans inserted by Archive process
			AND accDate >= @_from and accdate < @_to
			AND custid NOT IN(select custid from tempCustID)

		SET @msg = 'Statement loaded from ' + CONVERT(varchar(10), @_from, 120) + ' to ' + CONVERT(VARCHAR(10), dateadd(dd, -1, @_to), 120)
		RAISERROR(@msg, 0, 0) WITH NOWAIT

		if (@_to >= @to) break

		set @_from = dateadd(dd, @batch_days + 1, @_from)
		set @_to = dateadd(dd, @batch_days + 1, @_to)
	end

	--load 2nd for s3 (7 month)
	if (@status = 'Stage 3 - Running')
	begin
		select @_from = @fromEx, @_to = dateadd(dd, @batch_days + 1, @_from)

		while (1=1)
		begin
			SELECT @Msg = ''

			if (@_from > @ToEx) SET @_from = @ToEx
			if (@_to > @ToEx) SET @_to = dateadd(dd, 1, @ToEx)

			insert into tempCustID
			SELECT distinct custid
			FROM dbo.STATEMENT WITH (NOLOCK)
			WHERE TransType <> 'bal' 
				AND transdesc NOT LIKE 'For Delete Account%' --exclude clear balance trans inserted by Archive process
				AND accDate >= @_from and accdate < @_to
				AND custid NOT IN(select custid from tempCustID)

			SET @msg = 'Statement loaded from ' + CONVERT(varchar(10), @_from, 120) + ' to ' + CONVERT(VARCHAR(10), dateadd(dd, -1, @_to), 120)
			RAISERROR(@msg, 0, 0) WITH NOWAIT

			if (@_to >= @ToEx) break

			set @_from = dateadd(dd, @batch_days + 1, @_from)
			set @_to = dateadd(dd, @batch_days + 1, @_to)

		end
	end


	--update status after load statement data
	if (@status like '%Running')
		update bodb02.dbo.Systemsettings with(rowlock, updlock) set VValue = replace(@status, 'Running', 'Done') where VName = 'aa_Stmt_Status'

	if (@status = 'Stage 1 - Running')
		update bodb02.dbo.Systemsettings with(rowlock, updlock) set VValue = @from where VName = 'aa_Stmt_StartDate'
	else if(@status = 'Stage 3 - Running')
		update bodb02.dbo.Systemsettings with(rowlock, updlock) set VValue = @fromEx where VName = 'aa_Stmt_StartDate'


	update bodb02.dbo.Systemsettings with(rowlock, updlock) set VValue = @to where VName = 'aa_Stmt_EndDate'
END