/*
	Created By: Helen
	Created Date: 20150928
	Description: commission setting for MO [Redmine #41470]
	DB: DBCust.CustDB, DBTXN.CustDB
*/
CREATE FUNCTION fn_IsMyanmarOdds (@CustID INT = 0)
RETURNs BIT
AS
BEGIN
	
	IF EXISTS (SELECT 1 FROM Customer WITH (NOLOCK) WHERE CustID = @CustID AND [Site] = '766666')
		RETURN 1
	
	RETURN 0	
END



