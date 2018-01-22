/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbExtAccNet,bodbDownlineNet,bodbDownlineNetView,vnteam" viewers="vnteam" isFunction="0"></info>*/
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
		- 20180122@Johnson: remove downline status for new direction [redmine: #87328]
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
	   , @DisableColossusBet    BIT  
	   , @DisableUpline     BIT = 0  

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

