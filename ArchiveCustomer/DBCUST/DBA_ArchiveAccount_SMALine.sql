/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount_SMALine]
	@CustID		INT,
	@StageID	SMALLINT
AS 
/*
	Created: 20250102@Eden
	Task: Archive S/M/A and their direct members
	DB: DBCUST/CustDB
	Original: Acc_ExecRep_Cust_00
	Revision:
		- 20250102@Eden: Archiving direct member [redmine: #215533] 

	Param's Explanation:
		@StageID: 
			+ Stage 1: update closed = 1 for whole agent line
			+ Stage 2: update enable = 0 & credit = 0 for whole agent line
			+ Stage 3: Delete cust setting for members under agent
			+ Stage 4: Delete cust info for members under agent
*/
BEGIN
	EXEC [Acc_ExecRep_Cust_03] @CustID = @CustID, @StageID = @StageID
END
GO