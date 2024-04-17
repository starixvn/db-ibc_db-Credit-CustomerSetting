/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_xnap,wsv_alp,wsv_alpv,vnteam" viewers="vnteam" isFunction="0"></info>*/
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
		- 20170421@Helen: Enable Downline FishingWorld checkbox is ticked & disabled control although Member is disabled [RedmineID: #74421]
		- 20180122@Johnson: remove downline status for new direction [redmine: #87328]
	Parameters Explanation
	
*/ 
  
BEGIN  
	SET NOCOUNT ON  

	DECLARE @max_discount_comm   DECIMAL(9,8)    
		,@max_discount_CashInShare   DECIMAL(9,8)    		 
		,@DisableColossusBet  BIT  
		,@DisableUpline   BIT = 0  

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
