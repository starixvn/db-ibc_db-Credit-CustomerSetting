/*<info serverAlias="DBPOL-NAP_UserControl" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_GetDeniedSiteCurrencyByUser]
(
	@Site		NVARCHAR(50) = ''
	,@currency	INT = 0
	,@Creator	INT	
	,@Language	VARCHAR(2)= 'E'
	,@ErrCode	INT = 0 OUTPUT
	,@ErrMsg	NVARCHAR(4000) = '' OUTPUT
)
AS
/*  
 Created by: Helen  
 Date:20240704 
 Original: 
 Task: Check Permission [Redmine:#5456]
 DB: DBPOL-NAP_UserControl  
  
 Revisions:  
	- 20240704@Helen: Check permission - [Redmine:#206823]

 Explanation's Param:  
	- @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.		
	- @ErrMsg: Error description.	
  
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @tmp TABLE (siteid INT,site NVARCHAR(50), SpecialGroup TINYINT )
	DECLARE @tmpExchange TABLE (exchangeID INT, Currency NVARCHAR(50), OfferSite TINYINT)
	
	--get deny currency
	IF ISNULL(@currency,0) > 0
	BEGIN
		INSERT INTO  @tmpExchange (exchangeID, Currency, OfferSite)
		SELECT exchangeID, Currency, OfferSite FROM dbo.f_GetDeniedCurrencyByUser(@creator)

		SELECT @ErrCode = 103
			 , @ErrMsg ='You don''t have permission to access'
		FROM @tmpExchange e
		WHERE @currency = e.exchangeID 
	END

	--get deny site
	IF ISNULL(@Site,'') <> ''
	BEGIN
		INSERT INTO  @tmp (siteid , site,SpecialGroup)
		SELECT siteid , [site], SpecialGroup FROM dbo.f_GetDeniedSiteByUser(@creator)

		SELECT @ErrCode = 110
			 , @ErrMsg ='You don''t have permission to access'
		FROM @tmp t
		WHERE @site = t.Site
	END


END
GO


