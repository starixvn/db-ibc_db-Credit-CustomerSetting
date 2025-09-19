/*<info serverAlias="DBCUST-CustDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE dbo.DBA_Del_Member_IncludeHistory
(
    @CustIDList VARCHAR(4000) 
)
AS
/*
    Created:      20250919@Eden
    Task:         Delete credit accounts with incorrect data created during account registration , Include History table [#239047]
    DB:           DBCUST-CustDB
    Revisions:
        - 20250919@Eden: Initial creation for cleaning wrong account history [redmine: 239047]
    Example:
        EXEC dbo.DBA_Del_Member_IncludeHistory @CustIDList = '262876438,262876843';
*/
BEGIN
	DECLARE @CustID INT, @RoleID TINYINT 
	DECLARE @Date DATE -- use index of history table

	CREATE TABLE #Temp_WrongCusts (CustID INT,RoleID TINYINT, IsFinished BIT DEFAULT 0)

	INSERT INTO #Temp_WrongCusts(CustID,RoleID)
	SELECT ci.custid, ci.RoleID
	FROM STRING_SPLIT(@CustIDList, ',') t
		INNER JOIN CustDB.dbo.Custinfo ci WITH(NOLOCK)
			ON t.value = ci.custid
	WHERE ci.roleid = 1

	SELECT @Date = MIN(creatdate) 
	FROM dbo.customer WITH(NOLOCK) 
	WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)

	WHILE 1 = 1
	BEGIN
		UPDATE TOP(1) t
			SET t.IsFinished = 1,
				@CustID = t.CustID,
				@RoleID = t.RoleID
		FROM #Temp_WrongCusts t
		WHERE t.IsFinished = 0

		IF @@ROWCOUNT = 0
			BREAK;

		-- ROLLBACK Custsetting	
		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = @RoleID
		-- ROLLBACK CustInfo
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		--Rollback CustinfoMini
		EXEC DBGLOB.GLOBCUSTDB.dbo.Acc_CustomerIns_Rollback @custid = @CustID
	END

	--------------------CLEAN DATA History table-----------------------------------------------------
	BEGIN

		DELETE FROM CustDB_History.dbo.CustInfo_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;

		DELETE FROM CustDB_History.dbo.Customer_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;

		DELETE FROM CustDB_History.dbo.CustWinLossLimit_Member_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;

		DELETE FROM CustDB_History.dbo.CustVirtualSetting_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;

		DELETE FROM CustDB_History.dbo.VRCustLockStatus_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;

		DELETE FROM CustDB_History.dbo.CustDiscount3rd_Member_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;

		DELETE FROM CustDB_History.dbo.CustMaxPayoutSetting_Member_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;


		DELETE FROM CustDB_History.dbo.CustProductStatus_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;

		DELETE FROM CustDB_History.dbo.BetSetting_Member_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;

		DELETE FROM CustDB_History.dbo.BetSetting3rd_Member_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;

		DELETE FROM CustDB_History.dbo.CustPTSetting3rd_Member_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;

		DELETE FROM CustDB_History.dbo.CustSettingMode3rd_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;

		DELETE FROM CustDB_History.dbo.CustStakeLevel_Member_History WITH (ROWLOCK)
		WHERE CustID IN (SELECT CustID FROM #Temp_WrongCusts)
			AND UpdateTime >= @Date;
	END

	DROP TABLE #Temp_WrongCusts;
END
GO