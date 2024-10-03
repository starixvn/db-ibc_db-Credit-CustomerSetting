/*<info serverAlias="DBAGE-bodb02" executers="wsv_nap,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelSAgList]   
	@System			VARCHAR(50) = 'ACCOUNTING'
	,@DeniedList	NVARCHAR(MAX)=NULL
AS  

/*
	Created by: [Creator]
	Date: 
	Task: Bet Super List when creating master (can choose which super for master)
	DB: DBAGE/bodb02
	Original:  
	Revisions:
		-20090109@Henry: No need to get currency Name from Exchange since it is not used
		-20100720@Shifu: Get super list by System
		-20101119@Johnson: Get super list by group from Acc_CustGroup if system is not accounting
		-20120525@Dom: exclude licensee customer for accounting site
		-20130121@Dan: call to bodb_AGE for Acc_CustGroup
		- 20150904@Helen: commission setting for MO [Redmine #41470]
		- 20160630@Winnie: #48948 Hide_special_sites_from_unautorized_users	
		- 20180808@Helen: DB05.DBPOLICY migration - Move to DBCUST [Redmine:99462]
		- 20181122@Elodie: DB053/bodb_Age Migration [Redmine:#104770]
		- 20190201@Phillip: #105338 Build Customer Setting with Singbet Style
		- 20240419@Tacy: NAP - Permission controls on real currency [redmineID: #202523]
		- 20240725@Tacy: Remove linked-server/cross-db on NAP_UserControl [redmineID: #208402]

*/
BEGIN
	SET NOCOUNT ON  

	IF(@System = 'ACCOUNTING')
	BEGIN
		DECLARE @tmp TABLE (siteid INT,site NVARCHAR(50), SpecialGroup TINYINT )
		DECLARE @tmpExchange TABLE (exchangeID INT, Currency NVARCHAR(50), OfferSite TINYINT)

		IF ISNULL(@DeniedList,'')<>''
		BEGIN
			--get deny site
			INSERT INTO @tmp (siteid, site, SpecialGroup)
			SELECT vl.[ID], vl.[Name], vl.[Opt]
			FROM OPENJSON(@DeniedList) 
					WITH (  [KeyName]	VARCHAR(30),
							[Value]	NVARCHAR(MAX) AS JSON
						) AS js
			CROSS APPLY OPENJSON (js.[value])
					WITH (  [ID]	INT,
							[Name]	NVARCHAR(30),
							[Opt]	TINYINT
						) AS vl
			WHERE js.[KeyName]='Site'
	
			--get deny currency
			INSERT INTO  @tmpExchange (exchangeID, Currency, OfferSite)
			SELECT vl.[ID], vl.[Name], vl.[Opt]
			FROM OPENJSON(@DeniedList) 
					WITH (  [KeyName]	VARCHAR(30),
							[Value]	NVARCHAR(MAX) AS JSON
						) AS js
			CROSS APPLY OPENJSON (js.[value])
					WITH (  [ID]	INT,
							[Name]	NVARCHAR(30),
							[Opt]	TINYINT
						) AS vl
			WHERE js.[KeyName]='Exchange'
		END
	
		Select c.custid, c.username, c.currency as exchangeid, c.[site] AS siteName
		from customer as c with (NOLOCK) 
		where c.roleid=4 and c.custid>100 and c.[site] <> 'CN88'
			and c.srecommend NOT IN(SELECT custid from f_DepSuper_1 ('all'))
			AND site NOT IN (SELECT site FROM @tmp)
			AND c.currency NOT IN (SELECT exchangeID FROM @tmpExchange)
		order by c.username   
	END
	ELSE
	BEGIN
		SELECT c.custid, c.username, c.currency as exchangeid,c.[site] AS siteName
		FROM customer AS c WITH (NOLOCK) 	
		WHERE c.roleid = 4 
			AND c.custid>100  
			AND c.custid IN (SELECT custid FROM dbo.Acc_CustGroup WITH(NOLOCK) WHERE GroupName = @system)
			--AND c.currency IN (SELECT exchangeID FROM dbo.f_CurrencyBySystem(@System))
			--AND c.custid NOT IN (SELECT custid FROM dbo.f_GetDummySuper())
		ORDER BY c.username 
	END
END


