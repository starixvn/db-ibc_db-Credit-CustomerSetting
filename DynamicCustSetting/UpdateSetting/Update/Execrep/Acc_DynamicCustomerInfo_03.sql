ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_03]
	@CustID		INT,
	@IsSynced	BIT = 1,
	@RoleID		TINYINT,
	@ProductID	TINYINT
AS
/*
	Created: 20160215@Elodie
	Task : Update Sync status settings
	DB: DBCust/CustDB

*/
BEGIN
	SET NOCOUNT ON 
	IF dbo.f_CheckRepTable('custinfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustProductStatus') = 0 RETURN
	
	CREATE TABLE #NewSyncStatTbl(
				SportType SMALLINT,
				BetType SMALLINT
			)
	INSERT INTO	#NewSyncStatTbl (
					SportType
				,	BetType
				)
	SELECT		psd.SportType
			,	psd.BetType
	FROM	dbo.ProductSettingDetail AS psd WITH (NOLOCK)
	WHERE	psd.ProductID = @ProductID
		AND	psd.SettingType = 4

	DECLARE @xmlStrSynced XML
	
	SET @xmlStrSynced = (
			SELECT (
					SELECT psp.bitmapOrder	AS '@b', @IsSynced	AS '@s'
					FROM ProductStatusProfile psp WITH (NOLOCK)
						JOIN #NewSyncStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
					FOR XML PATH('r')
						, TYPE
					)
			FOR XML PATH('root')
				, TYPE
			)
	
	IF @RoleID=4
	BEGIN
		UPDATE T 
			SET bitmapHasSynced = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSynced)))	
		FROM  CustProductStatus T
			INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
		WHERE CI.srecommend = @custid AND CI.roleid IN (1,2,3)
	END
	ELSE IF @RoleID=3
	BEGIN
		UPDATE T 
			SET bitmapHasSynced = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSynced)))	
		FROM  CustProductStatus T
			INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
		WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
	END
	ELSE IF @RoleID=2
	BEGIN
		UPDATE T 
			SET bitmapHasSynced = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSynced)))	
		FROM  CustProductStatus T
			INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
		WHERE CI.recommend = @custid AND CI.roleid = 1
	END
	
END

GO
GRANT EXECUTE ON [dbo].[Acc_DynamicCustomerInfo_03] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_DynamicCustomerInfo_03] TO [vnteam] AS [dbo]
