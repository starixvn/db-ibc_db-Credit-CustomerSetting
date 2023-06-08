/*<info serverAlias="DBCTG-bodb02" executers="" isFunction="0"></info>*/
/*
    Created: 20230627@Danny
	Task: Clear super balance [183447]
	DB: DBCTG-bodb02 
*/
USE bodb02
GO
BEGIN
	-- Get super list
	DECLARE @i			INT = 1, 
			@srecommend INT, 
			@ErrMsg		NVARCHAR(200) = '', 
			@ErrCode	INT = 0,
			@IP			VARCHAR(45) = '125.227.140.97'

	CREATE TABLE #ArchiveSuperList (ID INT PRIMARY KEY IDENTITY (1,1) ,CustID INT, ErrCode INT, ErrMsg NVARCHAR(200))

	INSERT INTO #ArchiveSuperList (CustID)
	SELECT CustID FROM DBCUST.custDB.dbo.Cust_ArchiveAccount WITH(NOLOCK) WHERE roleid = 4 and stageid = 3

	WHILE EXISTS (SELECT TOP 1 1 FROM #ArchiveSuperList WHERE ID = @i)
	BEGIN
		SELECT @srecommend = custID FROM #ArchiveSuperList WHERE ID = @i
		SELECT @ErrCode = 0, @ErrMsg = ''

		EXEC DBA_ArchiveAccount3_ClearBalance_Super_xtest
			@srecommend = @srecommend,
			@UserID		= 10278938, --starixIT
			@IP			= @IP,
			@ErrMsg		= @ErrMsg OUTPUT,
			@ErrCode	= @ErrCode OUTPUT

		UPDATE #ArchiveSuperList SET ErrCode = @ErrCode, ErrMsg = @ErrMsg WHERE ID = @i

		SELECT @i = @i + 1
	END
	SELECT * FROM #ArchiveSuperList WHERE ErrCode <> 0

	DROP TABLE #ArchiveSuperList
END