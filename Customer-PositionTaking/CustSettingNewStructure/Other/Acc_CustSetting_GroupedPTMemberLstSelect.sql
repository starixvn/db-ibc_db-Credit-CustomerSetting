SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_GroupedPTMemberLstSelect]   
   @CustIDList VARCHAR(MAX) 
AS  
/*  
 Created: 20150505@Dominic  
 Task : Get setting modes of customers
 DB:  DBCUST/CustDB  
 Original:  
  
 Param's Explanation:  
 • @CustID: Comma seperated list of Member ID
   
 */  
BEGIN  
	SET NOCOUNT ON
	
	DECLARE @tblCust TABLE (CustID INT)
	INSERT INTO @tblCust (CustID)
	SELECT CONVERT(INT, val)
	FROM dbo.strSplit(@CustIDList, ',')
	
	SELECT cm.CustID
	FROM dbo.CustSettingMode3rd cm WITH(NOLOCK)
	INNER JOIN @tblCust c ON cm.CustID = c.CustID
	WHERE cm.IsGrouped = 1
	ORDER BY cm.CustID
	
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_GroupedPTMemberLstSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_GroupedPTMemberLstSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_GroupedPTMemberLstSelect] TO [bodbExtAccNet]