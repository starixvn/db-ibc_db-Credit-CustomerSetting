USE [bodb02]
GO

ALTER PROCEDURE  [dbo].[Acc_CustomerSelWinLimitLiveCS]
	@custid		INT
AS
	/*
		Created: Dan	
		Date: 20120927
		Task: get current win limit  of customer
		DB: DBTXN/BODB02
		
		Revisions:
			- 20121026@Jamie: Set Winlimit = 1 IN CASE credit = 0 
			- 20131108@Elodie: Splitting bodb02 into CustDB (get custinfo by link database)
			- 20150606@Kathy: Migrate custDB to new server DBCust(Get credit from DBCust.CustDB) [Redmine:#36216]
			- 20150717@Patrick: Support Gold Deluxe

		Parameters Explanation:	
	*/
SET NOCOUNT ON	
	DECLARE @Credit MONEY, @Debit MONEY, @Balance MONEY
	SELECT @Credit = SUM(Balance)
	FROM BalanceCreditGame credit WITH (NOLOCK) 
	WHERE custid=@custid AND bettype = 1101
	
	SELECT @Debit = SUM(Balance)
	FROM BalanceDebitGame credit WITH (NOLOCK) 
	WHERE custid=@custid AND bettype = 1101	
	
	SET @Balance = ISNULL(@Credit,0) -  ISNULL(@Debit,0)
	
	SELECT MaxWinLiveCasino,
		@Balance as Balance,
		MaxWinLiveCasino*credit as MaxWinCredit,
		CASE WHEN @Balance > 0 AND Credit = 0  AND MaxWinLiveCasino > 0 THEN @Balance * 100
			 WHEN @Balance > 0 AND Credit > 0 AND MaxWinLiveCasino > 0 THEN @Balance * 100/(MaxWinLiveCasino*credit) 
			 ELSE 0 END AS LCSWinPercent
	FROM DBCUST.CustDB.dbo.Custinfo ci WITH (NOLOCK) 		
	WHERE custid=@custid and roleid=1

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelWinLimitLiveCS] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelWinLimitLiveCS] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelWinLimitLiveCS] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelWinLimitLiveCS] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelWinLimitLiveCS] TO [vnteam] AS [dbo]