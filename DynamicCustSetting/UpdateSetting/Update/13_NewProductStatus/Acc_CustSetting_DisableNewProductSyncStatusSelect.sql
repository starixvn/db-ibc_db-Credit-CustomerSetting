/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
USE CustDB
GO

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
					
	Param's Explanation:  
   
 */  
BEGIN
	DECLARE @BitmapOrder TINYINT			
	
	SELECT @BitmapOrder = PSP.bitmapOrder
	FROM dbo.ProductSettingDetail psd WITH(NOLOCK)  
		INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Sporttype = psd.SportType AND psp.Bettype = psd.BetType
	WHERE psd.SettingType = 13 AND psd.ProductID = @ProductID

	SELECT	dbo.f_GetProductStatus(cps.bitmapHasSynced, @BitmapOrder) IsSynced
	FROM dbo.CustProductStatus cps  WITH (NOLOCK)			
	WHERE cps.CustID = @CustID 

END
GO


