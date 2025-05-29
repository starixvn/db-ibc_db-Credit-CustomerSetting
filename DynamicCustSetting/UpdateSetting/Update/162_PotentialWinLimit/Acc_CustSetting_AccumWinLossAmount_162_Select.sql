/*<info serverAlias="DBSIC-bodb02" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_AccumWinLoss_162_Select] 
	@CustID INT    
AS
/*
    Created by: 20250513@Johnson	
    Task: Get acummulated win loss amount 
    DB: DBCUST.CustDB
    
    Revisions:
        - 20250513@Johnson: initial sp [redmine: #226060]
        
    Parameter's explaination:
*/  
BEGIN
    SET NOCOUNT ON

    SELECT CustID, Sporttype, Bettype,AccumToWin,AccumWinLoss
    FROM CustWinLimitBet WITH(NOLOCK)
    WHERE CustID = @CustID
END 