ALTER PROCEDURE [dbo].[Acc_CustomerSelEditAgentColossusBet]  
(
	 @custid  INT,  
	 @mrecommend INT  
)
AS  

/*  
    Created: Helen  
    Date: 20150821
    Task: Agent: Getting data before updating in Update Colossus Bet - (Redmine: #41264)
    DB: DBCUST / CustDB
    
    
	Revisions:
	
	Parameters Explanation
	
*/ 

BEGIN  
	SET NOCOUNT ON  

	DECLARE @roleID INT   

	-- Check Downline Belonging  
	EXEC dbo.Age_CustomerSelCheckBelonging    
	@SessionCustID = @mrecommend,   
	@Custid   = @CustID,  
	@roleID   = @roleID OUTPUT  

	IF @roleID = 0  
		RETURN  

	DECLARE @max_discount_comm   DECIMAL(9,8)    
	   , @max_discount_CashInShare   DECIMAL(9,8)    
	   , @Downlines      BIT = 1  
	   , @DisableDownlines    BIT = 0  
	   , @DisableColossusBet    BIT  
	   , @DisableUpline     BIT = 0  

	 
	IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE recommend = @CustID AND roleid = 1)  
		SET @Downlines = 0 -- dont have any downlines  
	ELSE IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE recommend = @custid AND roleid = 1 AND DisableColossusBet = 1)  
		SET @DisableDownlines = 1  

	SELECT @DisableColossusBet = DisableColossusBet  
	FROM dbo.custInfo WITH(NOLOCK)  
	WHERE custid = @custid  

	SELECT @DisableUpline = DisableColossusBet  
	FROM dbo.custInfo WITH(NOLOCK)  
	WHERE custid = @mrecommend  

	--Master Comm   
	SELECT @max_discount_comm = CommRate
	FROM AgentCommRate WITH(NOLOCK)  
	WHERE custid = @mrecommend   
		AND sporttype = 204
		AND bettype = 18001 

	SELECT @max_discount_CashInShare = CommRate
	FROM AgentCommRate WITH(NOLOCK)  
	WHERE custid = @mrecommend   
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

	-- Commission  
	SELECT    
		ISNULL(CommRate,0) AS v204discount_18001,  
		ISNULL(@max_discount_comm,0) AS v204discount_18001_max
	FROM AgentCommRate cs WITH(NOLOCK)  
	WHERE cs.custid = @custid   
		AND cs.sporttype = 204
		AND cs.bettype = 18001  
	
	-- Cash In Share	
		
	SELECT    
		ISNULL(CommRate,0) AS v204discount_18002,  
		ISNULL(@max_discount_CashInShare,0) AS v204discount_18002_max
	FROM AgentCommRate cs WITH(NOLOCK)  
	WHERE cs.custid = @custid   
		AND cs.sporttype = 204
		AND cs.bettype = 18002
  
END
go
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentColossusBet] TO [bodbAdminNet] -- accouting
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentColossusBet]TO [bodbDownlineNet] -- alpha
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentColossusBet] TO [bodbExtAccNet] -- External
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentColossusBet] TO bodbDownlineNetView

GO 
