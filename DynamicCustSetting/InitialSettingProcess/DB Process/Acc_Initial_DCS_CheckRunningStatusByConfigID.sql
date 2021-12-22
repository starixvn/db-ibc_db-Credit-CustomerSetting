/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_CheckRunningStatusByConfigID]
	@ConfigID INT,
	@IsRunning BIT = 0 OUTPUT
AS
/*
	Created: 20210713@Eden
	Task : Check running status of this config
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20210713@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]

	Parameter Definition

	Example: 
		DECLARE @IsRunning BIT = 0
		EXEC [Acc_Initial_DCS_CheckRunningStatusByConfigID] 
			@ConfigID = 1,
			@IsRunning = @IsRunning OUTPUT
		SELECT @IsRunning
	
	*/
BEGIN
	SET NOCOUNT ON
	SET @IsRunning = 0

	IF EXISTS(
		SELECT 1
		FROM Initial_ProductConfig WITH(NOLOCK)
		WHERE ConfigID = @ConfigID
			AND Status = 1 --Running
	)
	BEGIN
		SET @IsRunning = 1
	END
END
GO


