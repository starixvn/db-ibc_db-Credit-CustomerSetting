/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_xnap,wsv_alp,wsv_alpv,vnteam" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMemberColossusBet]
(  
	@custid  INT,  
	@recommend INT  
)	
AS  

/*  
    Created: Helen  
    Date: 20150821
    Task: Member: Getting data before updating in Update Colossus Bet Module - (Redmine: #41264) 
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
		@SessionCustID = @recommend,   
		@Custid   = @CustID,  
		@roleID   = @roleID OUTPUT  

	IF @roleID = 0  
		RETURN  

	DECLARE @mrecommend      INT
		, @max_discount_comm   DECIMAL(9,8)    
		, @max_discount_CashInShare   DECIMAL(9,8)    
		, @DisableColossusBet    BIT
		, @DisableUpline     BIT  
	 
	SELECT @mrecommend = mrecommend   
		,@DisableColossusBet = DisableColossusBet  
	FROM dbo.CustInfo WITH(NOLOCK)  
	WHERE custid = @custid  

	SELECT @DisableUpline = DisableColossusBet  
	FROM dbo.custInfo WITH(NOLOCK)  
	WHERE custid = @recommend  

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
	FROM dbo.AgentCommRate WITH(NOLOCK)  
	WHERE custid = @recommend   
		AND sporttype = 204   
		AND bettype = 18001  
	
	-- Cash In Share
	SELECT CommRate AS v204discount_18002 
	FROM dbo.AgentCommRate WITH(NOLOCK)  
	WHERE custid = @recommend   
		AND sporttype = 204   
		AND bettype = 18002
	
	SET NOCOUNT OFF
	
END  
GO

