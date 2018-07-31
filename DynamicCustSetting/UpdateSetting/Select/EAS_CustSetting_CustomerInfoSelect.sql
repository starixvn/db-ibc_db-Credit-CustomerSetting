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
		FROM dbo.Customer c WITH (NOLOCK)
			INNER JOIN CustSuperProfile sp WITH (NOLOCK) ON c.custid = sp.custid
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
		FROM dbo.Customer c WITH (NOLOCK)
		WHERE c.custID = @CustID
	END
END