ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CheckIP]
	@IP varchar (15),
	@isValid bit = 1 OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-06-19
		Task: Check user's IP in block IP list retricted creation downlines
		DB: DBTXN/CustDB
		
		Revisions:
	*/ 
BEGIN
	SET NOCOUNT ON 
	
	IF @IP IN ('127.0.0.1')
		SELECT @isValid = 0
	ELSE SELECT @isValid = 1
END