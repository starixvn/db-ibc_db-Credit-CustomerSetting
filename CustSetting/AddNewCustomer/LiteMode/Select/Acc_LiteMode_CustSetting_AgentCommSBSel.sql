/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_AgentCommSBSel] 
	@CustID INT
AS
/*
	Created by: 2023710@Johnson	
	Task: Select agent setting for create member on Lite mode
	DB: DBCUST.CustDB
	
	Revisions:
		- 2023710@Johnson: initial sp [redmine: #179159]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20250108@Johnson: Allow Agents to change member Comm group [RedmineID: #216405]
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969]  
	Parameter's explaination:
	
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @Setting_CustID INT
			
	SELECT @Setting_CustID = CASE WHEN roleid  = 1 AND recommend NOT IN (-3,-4) THEN recommend
								 WHEN roleid  = 1 AND recommend = -3 THEN mrecommend
								 WHEN roleid  = 1 AND recommend = -4 THEN srecommend
								 ELSE @custid 
							 END
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid
	
	SELECT sporttype, bettype, discount		 
	FROM CustDiscount3rd_Agent WITH(NOLOCK)
	WHERE custid = @Setting_CustID
		AND sporttype = 1
		AND bettype IN (1,3,7,8) -- load data when agent assign ugroup for member
END			