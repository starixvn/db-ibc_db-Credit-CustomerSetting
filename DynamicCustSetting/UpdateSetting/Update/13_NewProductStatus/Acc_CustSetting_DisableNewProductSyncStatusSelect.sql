/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_DisableNewProductSyncStatusSelect]   
	@CustID	INT, 
	@ProductID INT
AS  
/*  
	Created: 20170613@Elodie
	Task : Get sync status of customer by product (Setting Type 13)
	DB:  DBCUST/CustDB
	Original:  
	
	Revisions: 
		- 20170919@Johnson: fix the unsynchronized setting, remove IsHidden,IsDownlineSynced [Redmine: #72973]
		- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
					
	Param's Explanation:  
   
 */  
BEGIN
	DECLARE @BitmapOrder TINYINT			
	
	SELECT @BitmapOrder = PSP.bitmapOrder
	FROM dbo.ProductSettingDetail psd WITH(NOLOCK)  
		INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Sporttype = psd.SportType AND psp.Bettype = psd.BetType
	WHERE psd.SettingType IN(13,21) AND psd.ProductID = @ProductID

	SELECT	dbo.f_GetProductStatus(cps.bitmapHasSynced, @BitmapOrder) IsSynced
	FROM dbo.CustProductStatus cps  WITH (NOLOCK)			
	WHERE cps.CustID = @CustID 

END
GO


