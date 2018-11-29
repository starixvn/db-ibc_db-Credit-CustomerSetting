/*<info serverAlias="DBAGE-bodb02" executers="bodbadminNet,bodbExtAccNet" isFunction="0"></info>*/
USE bodb02 
GO

ALTER PROC [dbo].[Acc_CustomerSelByUserName] 
	@Custid int = null,
	@UserName varchar(50) = null,
	@System varchar(50) = 'ACCOUNTING'
AS
/*
Created: 
Task : get user by system
DB: DBAGE/bodb02
Original:Accounting site

Revisions:	
	- 20100720@Shifu: get customer by System
	- 20100724@Henry: Enhance the performance
	- 20101119@Henry: if not accounting then get custid where super in Acc_CustSite depending on site
	- 20130121@Dan: change linked server DB06 to DBACC, call to DBAGE/bodb_AGE for Acc_CustGroup
	- 20181122@Elodie: DB053/bodb_Age Migration [Redmine:#104770]

Param's Explanation:
	@username: username want to get all info related
*/	
BEGIN
	SET NOCOUNT ON

	IF isnull(@System,'') = ''
	BEGIN
		RETURN
	END

	IF ISNULL(@UserName,'') <> '' 
	BEGIN
		EXEC @Custid = DBACC.bodb02.dbo.f_GetCustIDFromUsername @UserName
	END

	IF isnull(@Custid,0)<=0  
	BEGIN
		RETURN
	END


	IF(@System = 'ACCOUNTING')
	BEGIN
		Select	custid, isnull(fax,'') as fax, firstname, lastname, isnull(mobilephone,'') as mobilephone,
				isnull(phone,'') as phone, srecommend, roleid, username
			From Customer with (NOLOCK)
			WHERE Custid = @Custid
	END
	ELSE
	BEGIN	
		SELECT 	custid, isnull(fax,'') as fax, firstname, lastname, isnull(mobilephone,'') as mobilephone,
				isnull(phone,'') as phone, srecommend, roleid, username
			FROM	Customer with (NOLOCK)
			WHERE	
					custid = @Custid
					--AND srecommend NOT IN (SELECT custid FROM dbo.f_GetDummySuper())
					--AND Currency IN (SELECT exchangeId FROM dbo.f_CurrencyBySystem(@System))
					AND srecommend IN (SELECT CustID FROM dbo.Acc_CustGroup WHERE GroupName = @System )
				
	END
END