/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdateCustomerClassBySport]  
	@custList	VARCHAR(MAX) = '',
	@ErrCode 	INT = 0 OUTPUT,	
	@ErrMsg		VARCHAR(500) = '' OUTPUT
AS  
/*  

	Created: 20220831@Johnson   
	Task: Service update CustomerClass by sport for custinfo
	DB: DBCUST/CustDB  

	Revisions:  		
		- 20220831@Johnson: Initial sp [redmine:#176992]
		
	Parameter's Explanation: 
		@custList = '<Root>
					<r id="100" s="1" c="301" />
					<r id="100" s="2" c="302" />
					<r id="100" s="43" c="303" />
					<r id="100" s="99" c="304" />
					<r id="101" s="1" c="301" />
					<r id="101" s="2" c="302" />					
					</Root>'
*/
BEGIN
	SET NOCOUNT ON 
	
	BEGIN TRY	
		EXEC Acc_CustomerInfo_Execrep_03 @CustList = @CustList,
										@mode = 'CustomerClassBySport'
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 100,
			@ErrMsg = 'Update unsuccessfully'
		
		RETURN;
	END CATCH 
END	