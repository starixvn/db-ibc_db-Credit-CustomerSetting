/*
	Created: Elodie 
	Task: Update Sport_Bettype_Reference_Setting table
	DB: DBTXN/bodb02
	Date: 20170801
*/ 
USE bodb02
GO

UPDATE ps
SET ps.isActive = 1
FROM dbo.Sport_Bettype_Reference_Setting ps WITH (ROWLOCK,UPDLOCK)
WHERE SportType = 220


