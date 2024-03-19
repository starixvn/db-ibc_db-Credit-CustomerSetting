/*<info serverAlias="DBCUST-CUSTDB" executers="bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[EAS_CustSetting_CustomerInfoSelect] 
	  @CustID		INT
AS
/*
	Created: 20180730@Elodie
	Task : Get User info for Ext-Nap
	DB: DBCUST/CustDB

	Revisions:
		- 20201023@Eden: Adjust new pt for 789y [Redmine: #143764]
		- 20230310@Tacy: NAP/Alpha - Split 789y site [RedmineID: #181596]
	Param's Explanation:
	
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @RoleId TINYINT 

	SELECT @RoleId = roleid FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @CustID

	IF @RoleId = 4
	BEGIN
		--CustSuperProfile
		SELECT c.username AS UserName
				, c.username2 AS UserName2
				, sp.firstname AS FirstName
				, sp.lastname AS LastName
				, sp.phone AS Phone
				, sp.mobilephone AS MobilePhone
				, sp.email AS Email
				, sp.fax AS Fax
				, c.currency AS Currency
				, c.site AS Site
				, s.SiteLabel
		FROM dbo.Customer c WITH (NOLOCK)
			INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
			INNER JOIN CustSuperProfile sp WITH (NOLOCK) ON c.custid = sp.custid
		WHERE c.custID = @CustID
	END
	ELSE IF @RoleId = 1
	BEGIN
		--CustSuperProfile
		SELECT c.username AS UserName
				, c.username2 AS UserName2
				, c.firstname AS FirstName
				, c.lastname AS LastName
				, c.phone AS Phone
				, c.mobilephone AS MobilePhone
				, c.email AS Email
				, c.fax AS Fax
				, c.currency AS Currency
				, ag.site AS Site
				, s.SiteLabel
		FROM dbo.Customer c WITH (NOLOCK)
			LEFT JOIN dbo.Customer ag WITH (NOLOCK) ON c.recommend = ag.custid
			LEFT JOIN Site s WITH (NOLOCK) ON s.site=ag.site
		WHERE c.custID = @CustID
	END
	ELSE
	BEGIN
		--CustSuperProfile
		SELECT c.username AS UserName
				, c.username2 AS UserName2
				, c.firstname AS FirstName
				, c.lastname AS LastName
				, c.phone AS Phone
				, c.mobilephone AS MobilePhone
				, c.email AS Email
				, c.fax AS Fax
				, c.currency AS Currency
				, c.site AS Site
				, s.SiteLabel
		FROM dbo.Customer c WITH (NOLOCK)
			INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
		WHERE c.custID = @CustID
	END
END
GO