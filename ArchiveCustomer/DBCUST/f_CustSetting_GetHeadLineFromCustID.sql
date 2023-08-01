/*<info serverAlias="DBCust-CustDB" selecters="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION	dbo.f_CustSetting_GetHeadLineFromCustID (@CustID INT)  
RETURNS TABLE
AS
/*
	Created: 20230613@Eden
	Database: DBCust-CustDB
	
	Revision:
		-20230613@Eden : Initial function [Redmine: #183447]

	Param's Explanation:

	Ex:
	 SELECT * FROM dbo.f_CustSetting_GetHeadLineFromCustID (43494323)
*/
RETURN
	SELECT sp.custid,
		hl.custid AS HeadlineID
	FROM CustGroupHeadline hl WITH(NOLOCK)
		INNER JOIN custAccount sp WITH(NOLOCK)
			ON hl.groupID = sp.groupID
	WHERE sp.custid = @CustID
GO