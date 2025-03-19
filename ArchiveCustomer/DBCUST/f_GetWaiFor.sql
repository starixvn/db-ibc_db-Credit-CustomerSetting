/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[f_GetWaiFor] ()  
RETURNS VARCHAR(20)  
/*  
 Created: 20241121@Helios
 Revision:        
  - 20241121@Helios: ScaleOut Apply DeleteInHouse - Extend more table - Remove Code Old Structure [RedmineID: #201061]  
*/   
AS  
BEGIN  
	RETURN '00:00:00.280'
END  