/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="1"></info>*/
ALTER FUNCTION f_FomatNumericToChar(@str MONEY) 
	RETURNS VARCHAR(50) 
AS
/*
    Created: Eden
    Date: 20201029
    Task: Format number to write log PT 
    DB: DBCUST/CustDB
    Original versions:                
    Revision:
		- 20201029@Eden: Initial SP [Redmine: #143764]
    Example:
		DECLARE @PT smallmoney = 0.0855
		SELECT dbo.f_FomatNumericToChar (@PT)
*/
BEGIN
	RETURN CONVERT(VARCHAR(50),CONVERT(FLOAT,@str))
END

