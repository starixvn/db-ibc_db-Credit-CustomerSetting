use bodb02
go
ALTER PROCEDURE [dbo].[Acc_CustomerInsBalanceLiveCS_WinLimit]
	@CustID					INT,
	@RoleID					INT,
	@isAutoResetLiveCasino	BIT,
	@ErrCode				INT = 0 OUTPUT,
	@ErrMsg					NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20150616@Elodie
	Task: for weekly reset LiveCS WinLimit, insert default balance for member if not exists to keep track balance 
	DB: DBTXN/bodb02
	
	Revisions:		
		- 20150723@Patrick: Support Gold deluxe

	Parameters Explanation:
*/
BEGIN
	SET NOCOUNT ON 

	DECLARE @today smalldatetime, @bettype smallint
	SELECT @today = convert(nvarchar(10), current_timestamp,120), @bettype = 1101

	IF @RoleID = 1 AND @isAutoResetLiveCasino = 0
	BEGIN				
		IF NOT EXISTS(SELECT 1 
					FROM BalanceDebitGame bal
					WHERE bal.custid=@custid AND bal.winlostdate=@today AND bettype = @bettype)
		BEGIN								
			-- insert BalanceDebitGame
			--INSERT dbo.BalanceDebitGame(custid, winlostdate, Balance)
			--SELECT @custid, @today, 0 
			EXEC dbo.Dot_BalanceInsDebitGame @CustID = @custid, @winlostdate = @today, @bettype = @bettype
							
			IF (@@ERROR <> 0)
			BEGIN	
				SELECT @ErrMsg = 'Update process is unsuccessful !', @ErrCode = 107
				RETURN
			END		
		END	
		
		-- insert BalanceCreditGame
		IF NOT EXISTS(SELECT 1 
					FROM BalanceCreditGame bal
					WHERE bal.custid=@custid AND bal.winlostdate=@today AND bettype = @bettype)		
		
		BEGIN
			--INSERT dbo.BalanceCreditGame(custid, winlostdate, Balance)
			--SELECT @custid, @today, 0 
			EXEC DBTXN.bodb02.dbo.Dot_BalanceInsCreditGame @CustID = @custid, @winlostdate = @today, @bettype = @bettype

			IF (@@ERROR <> 0)
			BEGIN	
				SELECT @ErrMsg = 'Update process is unsuccessful !', @ErrCode = 108
				RETURN
			END		
		END	
	END
	ELSE IF @RoleID = 2
	BEGIN									
		-- insert BalanceDebitGame
		INSERT dbo.BalanceDebitGame(custid, winlostdate, bettype, Balance)
		SELECT cust.custid, @today, @bettype, 0
		FROM CustDB.dbo.CustInfo cust WITH (NOLOCK)
		WHERE Recommend = @CustID AND roleid=1
			AND isAutoResetLiveCasino=0 AND MaxWinLiveCasino>0
			AND NOT EXISTS(SELECT 1 
						FROM BalanceDebitGame bal WITH (NOLOCK)
						WHERE bal.custid=cust.custid AND bal.winlostdate=@today AND bettype = @bettype)
		IF (@@ERROR <> 0)
			BEGIN	
				SELECT @ErrMsg = 'Update process is unsuccessful !', @ErrCode = 109
				RETURN
			END			
		
		-- insert BalanceCreditGame
		INSERT dbo.BalanceCreditGame(custid, winlostdate, bettype, Balance)
		SELECT cust.custid, @today, @bettype, 0
		FROM CustDB.dbo.CustInfo cust WITH (NOLOCK)
		WHERE Recommend = @CustID AND roleid=1
			AND isAutoResetLiveCasino=0 AND MaxWinLiveCasino>0
			AND NOT EXISTS(SELECT 1 
						FROM BalanceCreditGame bal WITH (NOLOCK)
						WHERE bal.custid=cust.custid AND bal.winlostdate=@today AND bettype = @bettype)
		IF (@@ERROR <> 0)
		BEGIN	
			SELECT @ErrMsg = 'Update process is unsuccessful !', @ErrCode = 110
			RETURN
		END	
	END
	ELSE IF @RoleID = 3
	BEGIN
		-- insert BalanceDebitGame
		INSERT dbo.BalanceDebitGame(custid, winlostdate, bettype, Balance)
		SELECT cust.custid, @today, @bettype, 0
		FROM CustDB.dbo.CustInfo cust WITH (NOLOCK)
		WHERE MRecommend = @CustID AND roleid=1
			AND isAutoResetLiveCasino=0 AND MaxWinLiveCasino>0
			AND NOT EXISTS(SELECT 1 
						FROM BalanceDebitGame bal WITH (NOLOCK)
						WHERE bal.custid=cust.custid AND bal.winlostdate=@today AND bettype = @bettype)
		IF (@@ERROR <> 0)
		BEGIN	
			SELECT @ErrMsg = 'Update process is unsuccessful !', @ErrCode = 111
			RETURN
		END			
		
		-- insert BalanceCreditGame
		INSERT dbo.BalanceCreditGame(custid, winlostdate, bettype, Balance)
		SELECT cust.custid, @today, @bettype, 0
		FROM CustDB.dbo.CustInfo cust WITH (NOLOCK)
		WHERE MRecommend = @CustID AND roleid=1
			AND isAutoResetLiveCasino=0 AND MaxWinLiveCasino>0
			AND NOT EXISTS(SELECT 1 
						FROM BalanceCreditGame bal WITH (NOLOCK)
						WHERE bal.custid=cust.custid AND bal.winlostdate=@today AND bettype = @bettype)
		IF (@@ERROR <> 0)
		BEGIN	
			SELECT @ErrMsg = 'Update process is unsuccessful !', @ErrCode = 112
			RETURN
		END	
	END
	ELSE IF @RoleID = 4
	BEGIN		
		-- insert BalanceDebitGame
		INSERT dbo.BalanceDebitGame(custid, winlostdate, bettype, Balance)
		SELECT cust.custid, @today, @bettype, 0
		FROM CustDB.dbo.CustInfo cust WITH (NOLOCK)
		WHERE SRecommend = @CustID AND roleid=1
			AND isAutoResetLiveCasino=0 AND MaxWinLiveCasino>0
			AND NOT EXISTS(SELECT 1 
						FROM BalanceDebitGame bal WITH (NOLOCK)
						WHERE bal.custid=cust.custid AND bal.winlostdate=@today AND bettype = @bettype)
		IF (@@ERROR <> 0)
		BEGIN	
			SELECT @ErrMsg = 'Update process is unsuccessful !', @ErrCode = 113
			RETURN
		END			
		
		-- insert BalanceCreditGame
		INSERT dbo.BalanceCreditGame(custid, winlostdate, bettype, Balance)
		SELECT cust.custid, @today, @bettype, 0
		FROM CustDB.dbo.CustInfo cust WITH (NOLOCK)
		WHERE SRecommend = @CustID AND roleid=1
			AND isAutoResetLiveCasino=0 AND MaxWinLiveCasino>0
			AND NOT EXISTS(SELECT 1 
						FROM BalanceCreditGame bal WITH (NOLOCK)
						WHERE bal.custid=cust.custid AND bal.winlostdate=@today AND bettype = @bettype)
		IF (@@ERROR <> 0)
		BEGIN	
			SELECT @ErrMsg = 'Update process is unsuccessful !', @ErrCode = 114
			RETURN
		END	
	END	
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsBalanceLiveCS_WinLimit] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsBalanceLiveCS_WinLimit] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsBalanceLiveCS_WinLimit] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerInsBalanceLiveCS_WinLimit] TO [vnteam] AS [dbo]