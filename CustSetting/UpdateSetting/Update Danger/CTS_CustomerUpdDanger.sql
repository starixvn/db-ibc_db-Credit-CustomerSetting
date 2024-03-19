/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[CTS_CustomerUpdDanger]
	@CustList			VARCHAR(MAX) = '',	
	@DangerType			TINYINT,
	
	@ErrCode			INT = 0				OUTPUT,
	@ErrMsg				NVARCHAR(200) = ''	OUTPUT	
AS
SET NOCOUNT ON
/*
	Created: 20210326@Johnson
	Task : CTS service update Danger level[Redmine:#86627]
	DB: DBCUST/CUSTDB
	
	Revisions:
		- 20210326@Johnson: initial sp [redmine:#152249]
	
	Parameter's Explanation:
		-@DangerType:  type of danger,
			1: original
			2: ABI
			3: OtherSports
		-@custList = '<Root>
					<r id="100" l="1" />
					<r id="101" l="2" />
					<r id="102" l="3" />
					</Root>'
*/	
BEGIN
	SET NOCOUNT ON
	
	BEGIN TRY	
		EXEC Acc_CustomerInfo_Execrep_03 @CustList = @CustList,
										@DangerType = @DangerType,
										@mode = 'CTSUpdDanger'	
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 100,
			@ErrMsg = 'Update unsuccessfully'
	END CATCH 
END