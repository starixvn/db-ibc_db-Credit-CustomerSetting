/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" isFunction="0" isNested="0"></info>*/
USE [CustDB]
GO

ALTER PROCEDURE [dbo].[Acc_CustomerSelTransferOption]
	@CustId				INT
	,@TransferOption	VARCHAR(8) OUTPUT
	,@IsAutoTransfer	BIT = 0
AS

/*
	Created:
	Task: select transfer option.
	DB: DBCUST.CustDB
	Original:

	Revisions:
		- 20100413@Kiwi: Get transferoption from CustSuper/CustMaster/CustAgent
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
		- 20190409@Percy: Check upline is in automate transfer list [RedmineID: #111365]
	
	Param's Explanation:
*/

BEGIN
	DECLARE @RoleID TINYINT, @srecommend INT

	SELECT @RoleID = RoleID, @srecommend = srecommend
	FROM custinfo WITH (NOLOCK) 
	WHERE custid = @CustId

	SELECT @IsAutoTransfer = COUNT(1) FROM dbo.Acc_ClearBalanceList WITH (NOLOCK) WHERE custid = @srecommend

	IF (@RoleID = 4)
	BEGIN 
		SELECT @TransferOption = dbo.F_Decimal_Binary(ISNULL(TransferOption, 0))
		FROM dbo.CustSuper WITH (NOLOCK) 
		WHERE custid = @CustId
	END
	ELSE IF (@RoleID = 3)
	BEGIN 
		SELECT @TransferOption = dbo.F_Decimal_Binary(ISNULL(TransferOption, 0))
		FROM dbo.CustMaster WITH (NOLOCK) 
		WHERE custid = @CustId
	END
	ELSE IF (@RoleID = 2)
	BEGIN 
		SELECT @TransferOption = dbo.F_Decimal_Binary(ISNULL(TransferOption, 0))
		FROM dbo.CustAgent WITH (NOLOCK) 
		WHERE custid = @CustId
	END
END
GO