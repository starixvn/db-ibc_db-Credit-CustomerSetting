/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbExtAccNet,wsv_xnap" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_AdminCheckAllowedDownlinesByLevel]  
	@custid			INT = 0   
	,@roleid		INT = 0  
	,@isExecRep		BIT = 0  		 
	,@UpdateAllMasters BIT = 0
	,@UpdateAllAgents BIT = 0
	,@UpdateAllMembers BIT = 0
	,@Language		VARCHAR(2) = 'E'  
	,@ErrCode		INT = 0 OUTPUT  
	,@ErrMsg		NVARCHAR(200) = '' OUTPUT    
AS  
  
/*  
Created by: Johnson       
Date: 2018-05-29      
Task : Check Allowed downlines during peak hour at weekend on NAP for new direction status    
DB: DBCUST/CustDB        
Original SP: Acc_CustomerSelCheckAllowedDownlines       

Revisions:       
	- 20180529@Johnson:	clone new sp - [Redmine: 87328]

Param's Explanation: 
	 
*/    
BEGIN  
 	SET NOCOUNT ON  	
			
	DECLARE @LimitDownlinesMin int,   --Peak hours 
	  @LimitDownlinesMax int,		  -- Normal 
	  @LimitDownlines int,  
	  @TotalDownlines int  
	  
	IF @isExecRep = 0 
	BEGIN
		SET @LimitDownlinesMin = 5000  
		SET @LimitDownlinesMax = 20000  	
	END   
	ELSE IF @isExecRep = 1  
	BEGIN  
		SET @LimitDownlinesMin = 50000  
		SET @LimitDownlinesMax = 200000  		
	END  
	  
	--GET TOTALDOWNLINE  
	set @TotalDownlines=1  
	  
	IF @roleid = 4   
	BEGIN  
	 SELECT  @TotalDownlines = count(1)   
	 FROM Custinfo WITH (NOLOCK)  
	 WHERE srecommend=@custID 
		AND 1= CASE WHEN (@UpdateAllMasters = 1 AND roleid = 3) 
						OR (@UpdateAllAgents = 1 AND roleid = 2) 
						OR (@UpdateAllMembers = 1 AND roleid = 1) THEN 1 ELSE 0 END
						
	END  
	IF @roleid = 3   
	BEGIN  
	 SELECT  @TotalDownlines = count(1)   
	 FROM Custinfo WITH (NOLOCK)  
	 WHERE mrecommend=@custID  
		AND 1= CASE WHEN (@UpdateAllAgents = 1 AND roleid = 2) 
						OR (@UpdateAllMembers = 1 AND roleid = 1) THEN 1 ELSE 0 END
	END  
	IF @roleid = 2   
	BEGIN  
	 SELECT  @TotalDownlines = count(1)   
	 FROM Custinfo WITH (NOLOCK)  
	 WHERE recommend=@custID  
		AND @UpdateAllMembers = 1 
		AND roleid = 1
	END  
	
	-- BEGIN:	20140614@Viet:	special arrrangment for WC 2014		----
	--			20160601@Billy:	Special arrangment for EC 2016		----
	IF DATEPART(HOUR, GETDATE()) between 8 and 18	---- 08:00 -> 18:00	(PROD Time	GMT - 04:00)
													---- 19:00 -> 05:00	(VN Time	GMT + 07:00)
													---- 20:00 -> 06:00	(TW Time	GMT + 08:00)
	BEGIN
		SET @LimitDownlines = @LimitDownlinesMin 
	END
	ELSE 
	BEGIN
		SET @LimitDownlines = @LimitDownlinesMax 
	END
	--END: 20140614@Viet: special arrrangment for WC 2014 ----
	
	  
	IF @TotalDownlines >  @LimitDownlines  
	BEGIN       
		SELECT	@ErrMsg= CASE @Language WHEN 'E' THEN 'This function is not available during peak hour since it might affect the performance of the whole system. Please contact IT for further assistance.'
										ELSE dbo.f_Get_MsgNamebyMsgID(90010,@Language) END
				,@ErrCode = 113 	     
	END   
END
GO