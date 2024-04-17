/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_xnap,wsv_alp,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_SyncGameStatusSelect]   
	@CustID	INT , 
	@ProductID INT, 
	@SettingStatus TINYINT = 0
AS  
/*  
	Created: 20160801@Elodie
	Task : Get sync status of customer by game
	DB:  DBCUST/CustDB
	Original:  

	Revision:
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	
	Param's Explanation:  

	Example: EXEC Acc_CustSetting_SyncGameStatusSelect @CustID = 1275, @ProductID = 23
	
   
 */  
BEGIN
	DECLARE @BitmapOrder TINYINT, @IsSynced BIT, @IsSyncedUpline BIT

	DECLARE	@AgentID		INT
		,	@MasterID		INT
		,	@SuperID		INT
		,	@RoleID			INT

	--Get line information
	SELECT	@AgentID = ci.recommend
		,	@MasterID = ci.mrecommend
		,	@SuperID = ci.srecommend
		,	@RoleID	= ci.roleid
	FROM	dbo.custInfo AS ci WITH (NOLOCK)
	WHERE	ci.custid = @CustID

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID)
	SELECT SportType,BetType,SettingType,IsLive,ProductID 
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)

	SELECT TOP 1 @BitmapOrder = PSP.bitmapOrder
	FROM #ProductSettingDetail psd WITH(NOLOCK)  
		INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Sporttype = psd.SportType AND psp.Bettype = psd.BetType
	WHERE psd.SettingType = 11 AND psd.ProductID = @ProductID

	SELECT	@IsSynced = (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapHasSynced, @BitmapOrder))
	FROM dbo.CustProductStatus cps  WITH (NOLOCK)			
	WHERE cps.CustID = @CustID 

	IF @roleid = 4
	BEGIN
		SELECT @IsSyncedUpline = 1
	END
	ELSE IF @roleid = 3
	BEGIN
		SELECT	@IsSyncedUpline = (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapHasSynced, @BitmapOrder))
		FROM dbo.CustProductStatus cps  WITH (NOLOCK)			
		WHERE cps.CustID = @SuperID 
	END
	ELSE IF @roleid = 2
	BEGIN
		SELECT	@IsSyncedUpline = (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapHasSynced, @BitmapOrder))
		FROM dbo.CustProductStatus cps  WITH (NOLOCK)			
		WHERE cps.CustID = @MasterID 
	END
	ELSE IF @roleid = 1
	BEGIN
		SELECT	@IsSyncedUpline = (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapHasSynced, @BitmapOrder))
		FROM dbo.CustProductStatus cps  WITH (NOLOCK)			
		WHERE cps.CustID = @AgentID 
	END

	SELECT @IsSynced AS IsSynced, @IsSyncedUpline AS IsSyncedUpline

	DROP TABLE #ProductSettingDetail
END
GO


