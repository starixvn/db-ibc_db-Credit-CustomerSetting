/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_DisableNewProductSyncStatusSelect]   
	@CustID	INT, 
	@ProductID INT, 
	@SettingStatus TINYINT = 0
AS  
/*  
	Created: 20170613@Elodie
	Task : Get sync status of customer by product (Setting Type 13)
	DB:  DBCUST/CustDB
	Original:  
	
	Revisions: 
		- 20170919@Johnson: fix the unsynchronized setting, remove IsHidden,IsDownlineSynced [Redmine: #72973]
		- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
					
	Param's Explanation:  
   
 */  
BEGIN
	DECLARE @BitmapOrder TINYINT

	CREATE TABLE #Sport(
		[SportType] [smallint],
		[BetType] [smallint],
	PRIMARY KEY([SportType] ASC,[BetType]ASC)
	)
	
	INSERT INTO #Sport(SportType,BetType)
	SELECT SportType, BetType 
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,13,@SettingStatus)
	WHERE RealProductId = @ProductID
	UNION 
	SELECT SportType, BetType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,21,@SettingStatus)
	WHERE RealProductId = @ProductID
	
	SELECT @BitmapOrder = PSP.bitmapOrder
	FROM #Sport psd
		INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Sporttype = psd.SportType AND psp.Bettype = psd.BetType

	SELECT	dbo.f_GetProductStatus(cps.bitmapHasSynced, @BitmapOrder) IsSynced
	FROM dbo.CustProductStatus cps  WITH (NOLOCK)			
	WHERE cps.CustID = @CustID 

END
GO


