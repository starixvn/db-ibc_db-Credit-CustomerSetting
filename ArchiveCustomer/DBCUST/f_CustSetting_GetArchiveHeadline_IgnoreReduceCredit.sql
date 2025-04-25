/*<info serverAlias="DBCust-CustDB" selecters="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION	dbo.f_CustSetting_GetArchiveHeadline_IgnoreReduceCredit ()  
RETURNS TABLE
AS
/*
	Task: Return list Headline who ignore reduce credit when archived
	Created:	20250306@Eden
	Database:	DBCust-CustDB
	
	Revision:
		-20250306@Eden : Initial function [Redmine: #215533]

	Params Explanation:

	Ex:
	 SELECT * FROM dbo.f_CustSetting_GetArchiveHeadline_IgnoreReduceCredit ()
*/
RETURN
	SELECT 5453438 AS HeadlineID --K9
GO

