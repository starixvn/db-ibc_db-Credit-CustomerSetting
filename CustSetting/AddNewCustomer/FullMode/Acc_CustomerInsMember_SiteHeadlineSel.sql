/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [Acc_CustomerInsMember_SiteHeadlineSel]
AS
/*
	Created by: Tacy
	Date: 20230109
	Task : Get Headline by Site
	DB: DBCUST/CustDB

	Revisions:
		- 20230109@Tacy: Initial SP [RedmineID: #181596]
		- 20230412@Tacy: Hardcode to show ZU01 headline [RedmineID: #181596]

	Example:	EXEC Acc_CustomerInsMember_SiteHeadlineSel
*/
BEGIN
	SET NOCOUNT ON ;

	;WITH tmp AS (
		SELECT  c.username headline, 
				CASE WHEN c.username='ZU01' THEN 'yUT' ELSE c.site END site				
		FROM CustGroupHeadline cgh WITH (NOLOCK)					
			INNER JOIN customer  c WITH (NOLOCK) ON c.custid=cgh.custid	
			INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
		WHERE (s.SiteLabel='789y' AND s.isActive=1
			AND c.currency NOT IN (20,72))
			OR c.username='ZU01'
	)
	SELECT Site, 
		STUFF ((SELECT ', ' + headline
                FROM tmp t1
				WHERE t1.site=t.site
                FOR XML PATH('')),1,1,'') as Headlines
	FROM tmp t
	GROUP BY site
END
GO
