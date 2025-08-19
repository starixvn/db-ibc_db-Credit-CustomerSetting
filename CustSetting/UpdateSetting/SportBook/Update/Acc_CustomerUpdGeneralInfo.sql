/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustomerUpdGeneralInfo]
	@custid	 INT
    , @firstname	 NVARCHAR(50)
    , @lastname	 NVARCHAR(50)
    , @phone	 NVARCHAR(50)
    , @mobilephone NVARCHAR(50)
    , @email	 NVARCHAR(50)	= NULL
    , @fax		 NVARCHAR(50)
    , @SubAccID	 INT			= 0

    , @credit	 MONEY
    , @TotalAmt	 MONEY		= NULL
    , @Maxcredit	 MONEY		= NULL
    , @Language	 VARCHAR(2)		= 'E'
    , @IP		 VARCHAR(15)	= ''
    , @UserID	 INT			= 0
    , @Username	 VARCHAR(30)	= '' 
    ,	@ErrCode	 INT	   		= 0  OUTPUT
    , @ErrMsg	 NVARCHAR(500)	= '' OUTPUT
	, @AccumCreditAllCashMember	MONEY = 0
    

AS
/*
	Created: 20231122@Helios
	Task : Update General Info Customer
	DB: DBCUST/CUSTDB
	Original:   Acc_CustomerUpdSuper_All
			Acc_CustomerUpdMaster_All
			Acc_CustomerUpdAgent_All
			Acc_CustomerUpdMember_All
	Revisions:
	    - 20231019@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]
	    - 20250623@Helios: Offer Direct Member for Super/Master [redmine: #211969]
	    - 20250623@Helios: Offer CashService - Skip update Credit Cash Member [RedmineID: #231204]
		- 20250729@Dave: Get data AccumCredit on SiteDB (is not select from the current DB (replicated)) [Redmine: #234627]
		

	Parameter's Explanation:
		• AccumCreditAllCashMember: total accumulated credit of all cash members under an agent (data from SiteDB)
		• @ErrCode:
			= 0: Update successfully.
			> 0: Specific Error.
	
		• @ErrMsg: Error description.
*/
BEGIN

	DECLARE
	    	@RoleID	 TINYINT

	SELECT
		@ErrCode	 = 0
	    , @ErrMsg	 = ''
		  
	EXEC Age_CustomerSelCheckBelongingByCustID
		 @SessionCustID	= @Userid,   
		 @Custid		= @custid,  
		 @Username		= @Username OUTPUT,  
		 @RoleID		= @RoleID OUTPUT
		 
	 IF (@RoleID = 0) 
		RETURN   
	  
	-- Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
						@custid		= @custid
					,	@ErrCode		= @ErrCode OUTPUT
					,	@ErrMsg		= @ErrMsg  OUTPUT

	IF @ErrCode > 0
	BEGIN
		SELECT @ErrCode , @ErrMsg
		RETURN
	END


	-- Update User Info
	
	EXEC dbo.Acc_CustomerUpdUserInfo @CustID	    = @CustID
						 , @firstname   = @firstname
						 , @lastname    = @lastname
						 , @phone	    = @phone
						 , @mobilephone = @mobilephone
						 , @fax	    = @fax
						 , @email	    = @email
						 , @SubAccID    = @SubAccID
						 , @UserID	    = @UserID
						 , @ErrMsg	    = @ErrMsg OUTPUT
						 , @ErrCode	    = @ErrCode OUTPUT
						 , @IP	    = @IP
						 , @Language    = @Language

	IF    @ErrCode > 0
	BEGIN
		SELECT @ErrCode , @ErrMsg
		RETURN

	END
	ELSE
	BEGIN
		SELECT @ErrCode , @ErrMsg

	END

	DECLARE @isCashService TINYINT

	EXEC Age_CashService_CustServiceTypeSel @CustID =  @custid  , @ServiceType = @isCashService OUTPUT
	
	IF @isCashService = 1 AND @roleid = 1 	-- skip updating the credit for Cash Member
	BEGIN
		RETURN;
	END


	-- Update Credit
	EXEC dbo.Acc_CustomerUpdCredit @CustID    = @CustID
					     , @NewCredit = @credit
					     , @maxcredit = @maxcredit
					     , @SubAccID  = @SubAccID
					     , @UserID    = @UserID
					     , @Language  = @Language
					     , @ErrMsg    = @ErrMsg OUTPUT
					     , @ErrCode   = @ErrCode OUTPUT
					     , @TotalAmt  = @TotalAmt
					     , @IP		= @IP
						 , @AccumCreditAllCashMember = @AccumCreditAllCashMember

	IF    @ErrCode > 0
	BEGIN
		SELECT @ErrCode , @ErrMsg
		RETURN

	END
	ELSE
	BEGIN
		SELECT @ErrCode , @ErrMsg

	END



END