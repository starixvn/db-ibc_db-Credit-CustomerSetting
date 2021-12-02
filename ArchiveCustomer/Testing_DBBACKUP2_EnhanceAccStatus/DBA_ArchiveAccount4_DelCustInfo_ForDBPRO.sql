/*<info serverAlias="DBBACKUP2-bodb02_DB02" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE dbo.DBA_ArchiveAccount4_DelCustInfo_ForDBPRO
	@CustIDs VARCHAR(MAX) = ''
AS
/*
	Created:	Daniel
	Date:		20201014
	Task:		Archive credit accounts - Support delete custinfo by custid for DBPRO
	DB:			DBPRO/bodb02
	
	Revisions:
			20201014@Daniel: Created	
*/
BEGIN
	DECLARE @tmpCust TABLE(CustID INT)
			    
	INSERT INTO @tmpCust(custid)	
	SELECT val
	FROM dbo.f_SplitString(@CustIDs,',')
	OPTION (MAXRECURSION 0)
	
	WHILE(1=1)
	BEGIN
		DELETE TOP(5000) dbo.custinfo WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 5000 
			BREAK
	END
END	
