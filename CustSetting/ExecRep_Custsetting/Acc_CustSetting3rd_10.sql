ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_10] 
	@Custid			INT
	,@RoleID		TINYINT
	,@Action		VARCHAR(30) = ''
	,@DisableKeno	BIT = 0
	,@GameTypeID	INT = 0
AS
/*
	Created: Bobby
	Date: 2014-03-18
	Task: Apply execrep update keno setting - disable
	DB: DBTXN/custDB
	Original versions:	[Acc_ExecRep_Cust_04]
				
	Revision:
		- 20140228@Bobby: Update Keno status [Redmine:#12474]

	Parameter's Explanation:
		+ 'DisableKeno' : Disable Keno gaming
		+ 'GameTypeID' : Keno game ID
*/
BEGIN
	SET NOCOUNT ON
	IF (
			NOT EXISTS (
				SELECT 1
				FROM sys.sysobjects
				WHERE NAME = 'custgametype'
					AND xtype = 'U'
					AND @@SERVERNAME not in ('DBBingoAdmin','DBLVCasino','DBBingo01','DBCasinoAdmin','DBCasinoQA1','DBCasinoQA2','LiveCasinoAdminDB')
				)
			) 
			RETURN

	IF @Action = 'UpdKeno-Disable'
	BEGIN
		IF (@RoleID = 4)
		BEGIN
			UPDATE g
			SET IsDisabled = @DisableKeno
			FROM dbo.CustGameType g WITH (ROWLOCK, UPDLOCK)
				INNER JOIN dbo.CustInfo c WITH (NOLOCK)
				ON g.custid = c.custid
			WHERE c.CustID <> @CustID
				AND c.SRecommend = @CustID
				AND g.GameTypeID = @GameTypeID
		END

		IF (@RoleID = 3)
		BEGIN
			UPDATE g
			SET IsDisabled = @DisableKeno
			FROM dbo.CustGameType g WITH (ROWLOCK, UPDLOCK)
				INNER JOIN dbo.CustInfo c WITH (NOLOCK)
				ON g.custid = c.custid
			WHERE c.CustID <> @CustID
				AND c.MRecommend = @CustID
				AND g.GameTypeID = @GameTypeID
		END

		IF (@RoleID = 2)
		BEGIN
			UPDATE g
			SET IsDisabled = @DisableKeno
			FROM dbo.CustGameType g WITH (ROWLOCK, UPDLOCK)
				INNER JOIN dbo.CustInfo c WITH (NOLOCK)
				ON g.custid = c.custid
			WHERE c.CustID <> @CustID
				AND c.Recommend = @CustID
				AND g.GameTypeID = @GameTypeID
		END
	END
END

GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting3rd_10] TO [vnteam] AS [dbo]