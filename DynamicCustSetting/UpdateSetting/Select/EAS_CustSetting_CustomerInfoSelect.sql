/*<info serverAlias="DBCUST-CUSTDB" executers="bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[EAS_CustSetting_CustomerInfoSelect] 
	  @CustID		INT
AS
/*
	Created: 20180730@Elodie
	Task : Get User info for Ext-Nap
	DB: DBCUST/CustDB
	Original:

	Param's Explanation:
	
	*/
BEGIN
	SET NOCOUNT ON
	--CustSuperProfile
	SELECT c.username AS UserName
			, c.username2 AS UserName2
			, CASE WHEN c.roleid = 4 THEN sp.firstname ELSE c.firstname END AS FirstName
			, CASE WHEN c.roleid = 4 THEN sp.lastname ELSE c.lastname END AS LastName
			, CASE WHEN c.roleid = 4 THEN sp.phone ELSE c.phone END AS Phone
			, CASE WHEN c.roleid = 4 THEN sp.mobilephone ELSE c.mobilephone END AS MobilePhone
			, CASE WHEN c.roleid = 4 THEN sp.email ELSE c.email END AS Email
			, CASE WHEN c.roleid = 4 THEN sp.fax ELSE c.fax END AS Fax
			, c.currency AS Currency
	FROM dbo.Customer c WITH (NOLOCK)
		INNER JOIN CustSuperProfile sp WITH (NOLOCK) ON c.custid = sp.custid
	WHERE c.custID = @CustID
END