
/*
	Created By: Helen
	Created Date: 20161006
	Task: Update minlabel,minstake - https://nexdev.net/issues/65361
	
	DB: DBCUST/CustDB
*/

UPDATE StakeLevel WITH (ROWLOCK,UPDLOCK)
	SET MinLabel = '1', MinStake = 1
WHERE GameTypeID IN (2401,2402) and exchangeid = 72

