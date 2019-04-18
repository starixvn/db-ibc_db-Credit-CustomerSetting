/*<info serverAlias="DBTXN-bodb02" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" isFunction="0" isNested="0"></info>*/
USE [bodb02]
GO

ALTER PROCEDURE [dbo].[CS_Member_TotalBetStake_Sel]
	@CustId INT
AS

/*
	Created: 20190214@Percy
	DB: DBTXN.bodb02
	Task: Get Member Used Credit

	Revisions:
		- 20190214@Percy: Initialize SP [RedmineID: #105338]
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @today SMALLDATETIME
	SELECT  @today = CONVERT(DATE, GETDATE())

	DECLARE @TotalBetStake MONEY = 0, @ErrCode INT = 0

	/*
	-- for local testing
	DELETE dbo.DailyBetStake WITH (ROWLOCK, UPDLOCK)
	WHERE  CustId = @CustId AND Date = @today
	*/
	
	EXEC dbo.Dot_Member_CalcDailyBetStake_test @CustId = @CustId, @Date = @today, @Stake = 0, @TotalBetStake = @TotalBetStake OUTPUT, @ErrCode = @ErrCode OUTPUT

	-- try again for case violation of primary key when insert action
	IF @ErrCode <> 0
		EXEC dbo.Dot_Member_CalcDailyBetStake_test @CustId = @CustId, @Date = @today, @Stake = 0, @TotalBetStake = @TotalBetStake OUTPUT, @ErrCode = @ErrCode OUTPUT
	
	SELECT @TotalBetStake AS TotalBetStake
END
GO