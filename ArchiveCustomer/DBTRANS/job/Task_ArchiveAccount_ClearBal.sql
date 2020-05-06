/*<info serverAlias="DBTXN-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [Task_ArchiveAccount_ClearBal]
AS
/*
	Task: Archive unused credit account - step 3: clear balance
	Creator:	@Daniel
	Date: 20190708
	Database: DBTRANS.custdb

	Revisions:
		- 20190708@Daniel: Created

*/
BEGIN

	SET NOCOUNT ON

	DECLARE @agent varchar(50), @ErrMsg VARCHAR(150), @msg VARCHAR(100)

	if exists(select 1 from DBACC.bodb02.dbo.SystemSettings with(nolock) where VName = 'aa_Status' AND VValue = 'Stage 3 - Running')
	BEGIN
		WHILE(1=1)
		BEGIN
			SELECT @ErrMsg = ''
			SELECT TOP 1 @agent = Agent FROM tmpCustArchived WHERE IsFinished = 0	
			IF (@@ROWCOUNT = 0) BREAK
	
			EXEC bodb02.dbo.DBA_ArchiveAccount3_ClearBalance @AccName = @agent, @ErrMsg = @ErrMsg OUTPUT

			UPDATE tmpCustArchived 
			SET ErrMsg = @ErrMsg, IsFinished = 1
			WHERE Agent = @agent

			SET @msg = 'Done agent ' + @agent + CHAR(13)
			RAISERROR(@msg, 0, 0) WITH NOWAIT	
			
			WAITFOR DELAY '00:00:00.180'
			--IF (@ErrMsg <> '') BREAK
		END
	END
END