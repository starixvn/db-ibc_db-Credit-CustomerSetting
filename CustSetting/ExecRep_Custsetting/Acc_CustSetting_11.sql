/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_11]
	@CustID	INT = 0,
	@BetLimitTypeID	INT	= 0,
	@RoleID TINYINT = 0
AS
/*
	Created:	20200819@Eden
	Task:		Delete BetLimitControlCustSetting for multi customer
	DB:			DBCUST/CustDB
	Original:  
  
	Revisions: 
		- 20200818@Eden: NAP CM - Auto Update Bet Limit Control [RedmineID: #139701]

	Param's Explanation:  
		@CustID = 0 : process for all customer of this Type
*/
BEGIN
    SET NOCOUNT ON
	DECLARE @TempCust TABLE ( CustID INT PRIMARY KEY)

	IF @CustID = 0
		INSERT INTO @TempCust(CustID)
		SELECT CustID
		FROM BetLimitControlCustSetting WITH(NOLOCK)
		WHERE BetLimitTypeID = @BetLimitTypeID
	ELSE IF @RoleID = 4
		INSERT INTO @TempCust(CustID)
		SELECT t.CustID
		FROM BetLimitControlCustSetting t WITH(NOLOCK)
			INNER JOIN custInfo c ON t.CustID = c.custid AND c.roleid = 1
		WHERE BetLimitTypeID = @BetLimitTypeID 
			AND c.srecommend = @CustID
	ELSE IF @RoleID = 3
		INSERT INTO @TempCust(CustID)
		SELECT t.CustID
		FROM BetLimitControlCustSetting t WITH(NOLOCK)
			INNER JOIN custInfo c ON t.CustID = c.custid AND c.roleid = 1
		WHERE BetLimitTypeID = @BetLimitTypeID 
			AND c.mrecommend = @CustID
	ELSE IF @RoleID = 2
		INSERT INTO @TempCust(CustID)
		SELECT t.CustID
		FROM BetLimitControlCustSetting t WITH(NOLOCK)
			INNER JOIN custInfo c ON t.CustID = c.custid AND c.roleid = 1
		WHERE BetLimitTypeID = @BetLimitTypeID 
			AND c.recommend = @CustID

	WHILE 1 = 1
	BEGIN
		DELETE TOP (5000) bc
		FROM BetLimitControlCustSetting bc WITH(ROWLOCK)
			INNER JOIN @TempCust t ON t.CustID = bc.CustID 
		WHERE bc.BetLimitTypeID = @BetLimitTypeID
		
		IF @@ROWCOUNT = 0
		BREAK;
		WAITFOR DELAY '00:00:00.001'
	END
END
GO