ALTER PROCEDURE [dbo].[Acc_CustomerSelP2PStatus]
	@custid INT
/*
	Created: TOM
	Date: 08112011
	DB: DB053.BODB02
	Task: get disable status of P2P 
	
	Revisions:
*/
AS
SET NOCOUNT ON


DECLARE @roleid TINYINT, @username Nvarchar(100) , @currency Tinyint,
	@srecommend INT, @mrecommend INT, @recommend INT,@downlines BIT,
	@DISABLEP2P BIT , @DisableFunP2P BIT,
	@DisableDownlinesP2P BIT, @DisableDownlinesFUNP2P BIT,
	@DisableUplinesP2P BIT, @DisableUplinesFUNP2P BIT

SELECT @roleid = roleid , @username = username , @currency = currency  ,
	@srecommend = srecommend , @mrecommend = mrecommend , @recommend = recommend , 
	@DisableP2P = DisableP2P ,
	@DisableFunP2P = DisableFunP2P 
FROM custInfo WITH(NOLOCK) 
WHERE CustID = @custid

SELECT @downlines = CASE @roleid WHEN 4 THEN  CASE WHEN EXISTS(SELECT TOP 1 1 FROM custInfo WITH(NOLOCK) WHERE srecommend = @custid AND roleid = 3) THEN 1 ELSE 0 End
								 WHEN 3 THEN  CASE WHEN EXISTS(SELECT TOP 1 1 FROM custInfo WITH(NOLOCK) WHERE mrecommend = @custid AND roleid = 2) THEN 1 ELSE 0 End
								 WHEN 2 THEN  CASE WHEN EXISTS(SELECT TOP 1 1 FROM custInfo WITH(NOLOCK) WHERE recommend = @custid  AND roleid = 1) THEN 1 ELSE 0 End
								 ELSE 0 End	  

SELECT @DisableDownlinesP2P = CASE @roleid WHEN 4 THEN (SELECT TOP 1 ISNULL(DisableP2P,0) FROM custInfo WITH (NOLOCK) WHERE srecommend = @custid AND roleid = 3 AND DisableP2P = 1)
										   WHEN 3 THEN (SELECT TOP 1 ISNULL(DisableP2P,0) FROM custInfo WITH (NOLOCK) WHERE mrecommend = @custid AND roleid = 2 AND DisableP2P = 1)
										   WHEN 2 THEN (SELECT TOP 1 ISNULL(DisableP2P,0) FROM custInfo WITH (NOLOCK) WHERE recommend  = @custid AND roleid = 1 AND DisableP2P = 1)
										   ELSE 0 End 

SELECT @DisableDownlinesFUNP2P = CASE @roleid WHEN 4 THEN (SELECT TOP 1 ISNULL(DisableFunP2P,0) FROM custInfo WITH (NOLOCK) WHERE srecommend = @custid AND roleid = 3 AND DisableFunP2P = 1)
										   WHEN 3 THEN (SELECT TOP 1 ISNULL(DisableFunP2P,0) FROM custInfo WITH (NOLOCK) WHERE mrecommend = @custid AND roleid = 2 AND DisableFunP2P = 1)
										   WHEN 2 THEN (SELECT TOP 1 ISNULL(DisableFunP2P,0) FROM custInfo WITH (NOLOCK) WHERE recommend  = @custid AND roleid = 1 AND DisableFunP2P = 1)
									 	   ELSE 0 End 

SELECT @DisableUplinesP2P = ISNULL(DisableP2P,0), 
	@DisableUplinesFUNP2P = ISNULL(DisableFunP2P,0)
FROM custInfo WITH (NOLOCK)
WHERE CustID = CASE @roleid WHEN 1 THEN @recommend
							WHEN 2 THEN @mrecommend
							WHEN 3 THEN @srecommend
							ELSE 0 End
SELECT
	@username username,
	@roleid roleid,
	@currency currency,
	CASE WHEN @downlines = 0 THEN @DisableP2P ELSE ISNULL(@DisableDownlinesP2P,0) End AS DisableDownlinesP2P,
	CASE WHEN @downlines = 0 THEN @DISABLEFUNP2P ELSE ISNULL(@DisableDownlinesFUNP2P,0) End AS DisableDownlinesFUNP2P,
	ISNULL(@DisableUplinesP2P,0) AS DisableUplinesP2P,
	ISNULL(@DisableUplinesFUNP2P,0) AS DisableUplinesFUNP2P,
	@DisableP2P AS DisableP2P,
	@DISABLEFUNP2P AS DisableFunP2P
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelP2PStatus] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelP2PStatus] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelP2PStatus] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelP2PStatus] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelP2PStatus] TO [vnteam]