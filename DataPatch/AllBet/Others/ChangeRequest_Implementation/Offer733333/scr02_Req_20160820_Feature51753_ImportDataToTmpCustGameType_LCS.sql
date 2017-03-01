/*
	Created: Helen
	Date: 20160824
	Task: prepare data for tmpCustGameType_LCS

     
*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'tmpCustGameType_LCS' and type = 'u')
    DROP TABLE tmpCustGameType_LCS
GO  

CREATE TABLE tmpCustGameType_LCS(
		CustID INT 
		, StakeLevelList VARCHAR(100)
		,PRIMARY KEY CLUSTERED( CustID ASC) WITH (IGNORE_DUP_KEY = ON) 
)


GO

--Use SSIS to import data for 
/*
Source: DBCASINOADMINCS.LiveCasinoAdmin - with select Query below
Destination: DBCUST.custDB.tmpCustGameType_LCS


*/   
SELECT CustID,StakeLevelList
FROM CustGameType WITH (NOLOCK)
WHERE GameTypeID = 108 