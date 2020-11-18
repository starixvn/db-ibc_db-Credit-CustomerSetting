/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_CustomerInfoSelect] 
	  @CustID		INT
AS
/*
	Created: 20150622@Dominic
	Task : Get User infor
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20201023@Eden: Adjust new pt for 789y [Redmine: #143764]

	Param's Explanation:
	
	*/
BEGIN
	--Cusinfo
	SELECT c.username AS UserName
			, c.username2 AS UserName2
			, c.firstname AS FirstName
			, c.lastname AS LastName
			, c.phone AS Phone
			, c.mobilephone AS MobilePhone
			, c.email AS Email
			, c.fax AS Fax
			, c.currency AS Currency
			, ISNULL(NULLIF(c.site,''), ag.site) AS Site
	FROM dbo.Customer c WITH (NOLOCK)
		LEFT JOIN dbo.Customer ag WITH (NOLOCK) ON c.recommend = ag.custid
	WHERE c.custID = @CustID	
END

GO
