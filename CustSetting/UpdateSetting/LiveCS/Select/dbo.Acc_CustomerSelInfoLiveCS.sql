ALTER PROCEDURE [dbo].[Acc_CustomerSelInfoLiveCS]
	@custid	INT
AS
/*
	Created: Johnson	
	Date: 09Jan2012
	Task: get informattion of customer
	DB: DBCUST.CustDB
		
	Revisions:
		- 20120323@Johnson: get site info
		- 20120417@Johnson: Get live casino's status and upline status
		- 20120927@Dan: add win limit
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Parameters Explanation:	
*/
SET NOCOUNT ON
	
	DECLARE 
		@syncLiveCasino BIT,
		@DisableLiveCasino BIT,
		@UplineDisableLiveCasino BIT,
		@UplineID INT, 
		@roleid INT,
		@isAutoResetLiveCasino BIT, 
		@MaxWinLiveCasino SMALLMONEY, 
		@UplineIsAutoResetLiveCasino BIT, 
		@UplineMaxWinLiveCasino SMALLMONEY
	
	SELECT 
		@syncLiveCasino = SyncLiveCasino,
		@DisableLiveCasino = DisableLiveCasino,
		@UplineID = CASE 
						WHEN roleid = 1 THEN recommend 
						WHEN roleid = 2 THEN mrecommend
						WHEN roleid = 3 THEN srecommend
						ELSE 0 
					END,
		@roleid	= roleid,
		@isAutoResetLiveCasino = isAutoResetLiveCasino, 
		@MaxWinLiveCasino = MaxWinLiveCasino 
	FROM CustInfo WITH(NOLOCK)
	WHERE custid = @custid
	
	IF @roleid < 4
		SELECT @UplineDisableLiveCasino = DisableLiveCasino, 
			@UplineIsAutoResetLiveCasino=isAutoResetLiveCasino,
			@UplineMaxWinLiveCasino = MaxWinLiveCasino 
		FROM CustInfo WITH(NOLOCK)
		WHERE custid = @UplineID
		
	SELECT c.username ,
		c.username2, 
		c.firstname,
		c.lastname, 
		c.phone, 
		c.mobilephone,
		c.fax,
		c.currency,
		c.site,
		@SyncLiveCasino AS SyncLiveCasino,
		@DisableLiveCasino AS DisableLiveCasino, 
		ISNULL(@UplineDisableLiveCasino, 0) AS UplineDisableLiveCasino, 
		c.roleid,
		@isAutoResetLiveCasino AS isAutoResetLiveCasino, 
		@MaxWinLiveCasino AS MaxWinLiveCasino,
		ISNULL(@UplineIsAutoResetLiveCasino, 0) AS UplineIsAutoResetLiveCasino,
		ISNULL(@UplineMaxWinLiveCasino, 0) AS UplineMaxWinLiveCasino
	FROM Customer AS c WITH(NOLOCK)
	WHERE c.custid = @custid



GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelInfoLiveCS] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelInfoLiveCS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelInfoLiveCS] TO [bodbDownlineNet] 
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelInfoLiveCS] TO [bodbDownlineNetView] 