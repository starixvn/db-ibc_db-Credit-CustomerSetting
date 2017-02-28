ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMasterColossusBet]  
(
	@custid INT,  
	@srecommend INT  
)
AS 

/*  
    Created: Helen  
    Date: 20150821
    Task: Master: Getting data before updating in Update Colossus Bet Module - (Redmine: #41264)
    DB: DBCUST / CustDB
    
    
	Revisions:
	
	Parameters Explanation
	
*/ 
  
BEGIN  
	SET NOCOUNT ON  

	DECLARE @max_discount_comm   DECIMAL(9,8)    
		,@max_discount_CashInShare   DECIMAL(9,8)    
		,@Downlines    BIT = 1  
		,@DisableDownlines  BIT = 0  
		,@DisableColossusBet  BIT  
		,@DisableUpline   BIT = 0  
	 
	IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE mrecommend = @CustID AND roleid = 2)  
		SET @Downlines = 0 -- dont have any downlines  
	ELSE IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE mrecommend = @custid AND roleid = 2 AND DisableColossusBet = 1)  
		SET @DisableDownlines = 1  

	SELECT @DisableColossusBet = DisableColossusBet  
	FROM dbo.custInfo WITH(NOLOCK)  
	WHERE custid = @custid  

	SELECT @DisableUpline = DisableColossusBet  
	FROM dbo.custInfo WITH(NOLOCK)  
	WHERE custid = @srecommend  

	SELECT @max_discount_comm = CommRate  
	FROM AgentCommRate cs WITH(NOLOCK)  
	WHERE custid = @srecommend   
		AND sporttype = 204   
		AND bettype = 18001  

	SELECT @max_discount_CashInShare = CommRate  
	FROM AgentCommRate cs WITH(NOLOCK)  
	WHERE custid = @srecommend   
		AND sporttype = 204   
		AND bettype = 18002  
		
	--Customer Info  
	SELECT username  
		,username2 AS nickname  
		,firstname  
		,lastname  
		,phone  
		,mobilephone  
		,fax  
		,ISNULL(@DisableUpline,1)   AS DisableUpline  
		,ISNULL(@DisableColossusBet,1) AS DisableColossusBet  
		,@Downlines      AS Downlines  
		,@DisableDownlines    AS DisableDownlines  
	FROM dbo.Customer WITH (NOLOCK)  
	WHERE custID = @CustID        

	--Commission  
	SELECT CommRate AS v204discount_18001
		, ISNULL(@max_discount_comm,0)  AS v204discount_18001_max
	FROM AgentCommRate WITH(NOLOCK)  
	WHERE custid = @custid   
		AND sporttype = 204   
		AND bettype = 18001  
		
	-- Cash In Share
	SELECT CommRate AS v204discount_18002
		, ISNULL(@max_discount_CashInShare,0)  AS v204discount_18002_max
	FROM AgentCommRate WITH(NOLOCK)  
	WHERE custid = @custid   
		AND sporttype = 204   
		AND bettype = 18002  

	SET NOCOUNT OFF
END

GO

GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterColossusBet] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterColossusBet]  TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterColossusBet]  TO [bodbExtAccNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterColossusBet]  TO bodbDownlineNetView