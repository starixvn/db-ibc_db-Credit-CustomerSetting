/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_GroupedPTMemberLstSelect]   
   @CustIDList VARCHAR(MAX) 
AS  
/*  
 Created: 20150505@Dominic  
 Task : Get setting modes of customers
 DB:  DBCUST/CustDB  
 Original:  
  
 Revisions: 
	- 20220614@Eden: DBCUST - modify sp syntax to adapt with the SQL Server upgrade to 2019 [Redmine: #171831] 

 Param's Explanation:  
 • @CustID: Comma seperated list of Member ID
   
 */  
BEGIN  
	SET NOCOUNT ON
	
	DECLARE @tblCust TABLE (CustID INT)
	INSERT INTO @tblCust (CustID)
	SELECT CONVERT(INT, value)
	FROM STRING_SPLIT(@CustIDList, ',')
	WHERE value <> ''
	
	SELECT cm.CustID
	FROM dbo.CustSettingMode3rd cm WITH(NOLOCK)
	INNER JOIN @tblCust c ON cm.CustID = c.CustID
	WHERE cm.IsGrouped = 1
	ORDER BY cm.CustID
	
END  
  

GO
