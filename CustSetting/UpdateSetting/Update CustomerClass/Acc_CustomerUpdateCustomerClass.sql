/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdateCustomerClass]  
	@custList	VARCHAR(MAX) = '',
	@ErrCode 	INT = 0 OUTPUT,	
	@ErrMsg		VARCHAR(500) = '' OUTPUT
AS  
/*  

	Created: 20200901@Johnson   
	Task: Service update CustomerClass for custinfo
	DB: DBCUST/CustDB  

	Revisions:  		
		- 20200901@Johnson: Initial sp [redmine:#140809]
		- 20210420@Johnson: sync categroy for PA redmine:[#153617]
	Parameter's Explanation: 
		@custList = '<Root>
					<r id="100" c="10" t="1" />
					<r id="101" c="11" t="2" />
					<r id="102" c="12" t="3" />
					</Root>'
*/
BEGIN
	SET NOCOUNT ON 
	
	BEGIN TRY	
		EXEC Acc_CustomerInfo_Execrep_03 @CustList = @CustList,
										@mode = 'CustomerClass'	
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 100,
			@ErrMsg = 'Update unsuccessfully'
	END CATCH 
	
END	