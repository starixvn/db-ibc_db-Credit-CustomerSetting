SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_CustomerInfoSelect] 
	  @CustID		INT
AS
/*
	Created: 20150622@Dominic
	Task : Get User infor
	DB: DBCUST/CustDB
	Original:

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
	FROM dbo.Customer c WITH (NOLOCK)
	WHERE c.custID = @CustID	
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CustomerInfoSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CustomerInfoSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CustomerInfoSelect] TO [bodbExtAccNet]