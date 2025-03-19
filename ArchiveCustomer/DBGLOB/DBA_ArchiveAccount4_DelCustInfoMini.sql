/*<info serverAlias="DBGlob-GlobCustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount4_DelCustInfoMini]
	@CustIDs VARCHAR(MAX)
AS
/*
	Created: 20240905@Eden  
	Task : arhive Stage 4 : Delete data on dbglob
	DB:  DBGlob-GlobCustDB
	Original sp: 
	
	Revisions: 
		- 20240905@Eden : Scale out DBCUST - Delete data custinfomini [redmine: #210077]

	Param's Explanation: 
	Examples:
		EXEC [DBA_ArchiveAccount4_DelCustInfoMini] @CustIDs = 222222
	  
*/	
BEGIN
	
	DECLARE @BatchNum INT = 2000 
		,@IsFinish_CustinfoMini BIT = 0 
		,@IsFinish_CustSubMini BIT = 0

	CREATE TABLE #CustTemps (CustID INT)
	CREATE TABLE #CustTemps_batch (CustID INT)

	INSERT INTO #CustTemps (CustID)
	SELECT value 
	FROM STRING_SPLIT(@CustIDs,',')
	WHERE value <> 0

	WHILE 1 = 1
	BEGIN 
		SELECT @IsFinish_CustinfoMini = 0, @IsFinish_CustSubMini = 0
		TRUNCATE TABLE #CustTemps_batch

		DELETE TOP(@BatchNum) t
		OUTPUT deleted.custID INTO #CustTemps_batch(custid)
		FROM #CustTemps t

		IF @@ROWCOUNT = 0
			BREAK;
		
		WHILE  (@IsFinish_CustSubMini = 0 OR @IsFinish_CustinfoMini = 0)
		BEGIN
			-- Delete CustSubMini
			IF @IsFinish_CustSubMini = 0
			BEGIN
				DELETE TOP(@BatchNum) c
				OUTPUT deleted.subaccid,dbo.f_GetDateTime2()   
				INTO CustSubMini_Del_Inhouse(subaccid,RepUpdateTime)
				FROM dbo.CustSubMini c WITH(ROWLOCK,UPDLOCK)
				WHERE custid IN (SELECT custid FROM #CustTemps_batch)

				IF @@ROWCOUNT < @BatchNum
				BEGIN
					SET @IsFinish_CustSubMini = 1 -- Stop delete on this table
				END
			END

			-- Delete CustInfoMini
			IF @IsFinish_CustinfoMini = 0
			BEGIN
				DELETE TOP(@BatchNum) c
				OUTPUT deleted.custID,dbo.f_GetDateTime2()   
				INTO CustInfoMini_Del_Inhouse(custid,RepUpdateTime)
				FROM dbo.CustInfoMini c WITH(ROWLOCK,UPDLOCK)
				WHERE custid IN (SELECT custid FROM #CustTemps_batch)

				IF @@ROWCOUNT < @BatchNum
				BEGIN
					SET @IsFinish_CustinfoMini = 1 -- Stop delete on this table
				END
			END

			WAITFOR DELAY '00:00:00.010'
		END
	END 

END