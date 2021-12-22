/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_InitialCustomerStatus_Upd]
	@CustID INT,
	@CurrentStep TINYINT
AS
/*
	Created: 20210713@Eden
	Task : Update Initial_Customer.CurrentStep
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20210713@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]

	Parameter Definition

	Example: 
		EXEC [Acc_Initial_DCS_InitialCustomerStatus_Upd] 
			@CustID = 1,
			@CurrentStep = 2
	
	*/
BEGIN
	SET NOCOUNT ON
	
	UPDATE Initial_Customer WITH(ROWLOCK,UPDLOCK)
	SET CurrentStep = @CurrentStep
	WHERE CustID = @CustID
END
GO


