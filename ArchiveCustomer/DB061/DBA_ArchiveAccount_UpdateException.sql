/*<info serverAlias="DBACC-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount_UpdateException]
AS
/*
	Created: 20160815@Daniel
	Task: Archive Acc - Update exception list
	DB: DBACC/bodb02
	Original:

	Revisions:
		20180514@Daniel: Update more exception requests from CSD, exclude UUS/YNG cust, phone betting cust
		20190402@Daniel: add exception for CN88 customers
		20190913@Daniel: Rename SP for correct English
		20220505@Eden: Exclude internal usage account from Archiving credit accounts process [#RM:172372]
	Param's Explanation:
*/
SET NOCOUNT ON

--update exception list : Super level
;WITH TMP_Super AS(
	SELECT sag.custID, sag.username
	FROM customer sag WITH(NOLOCK)
	WHERE sag.roleid = 4  
		AND 
		(
			sag.username LIKE '3rdSuper%'
			OR sag.username IN ('STAFF', 'SA-UUS', 'LC-RM', 'U3S',
				'OPS-RM', 'OPS-RMB', 'OPS-HKK', 'OPS-THB', 'OPS-IDD', 'OPS-US$', 'OPS-GBP'--CSD request internal use @20180424
				,'superAuNova01','IDRTEST','Myanmar','M7666B','StarixSCYENS01','IT-INR1','TD88' --#172372
			)
			OR sag.currency IN(20, 72)
			OR sag.username LIKE 'SuperTest%'
			OR sag.username LIKE 'STEST%'
			OR sag.username LIKE 'SIBC%'
			OR sag.username LIKE '%ACCSuper%'
			OR sag.site = 'cn88'--exclude cn88 cust
		)
	UNION -- All Super contain headline
	SELECT sag.custid,sag.username		
	FROM CustGroupHeadline gl WITH(nolock)		
		INNER JOIN custinfo ci WITH(nolock) ON gl.CustID = ci.custid
		INNER JOIN custinfo sag WITH(NOLOCK) ON sag.custid = ci.srecommend
	WHERE GroupID > 0 
		AND ci.roleid in (1,2,3,4)
	UNION -- All Super contain phone betting accounts
	SELECT sag.custid,sag.username
	FROM phonebettingCustomerList p WITH(NOLOCK)
		INNER JOIN custinfo c WITH(NOLOCK) ON p.username = c.username
		INNER JOIN custinfo sag WITH(NOLOCK) ON sag.custid = c.srecommend
)
INSERT INTO bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception](CustID,Remark)
SELECT t.custid,t.username
FROM TMP_Super t
	LEFT JOIN  bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] ce WITH (NOLOCK) ON t.CustID = ce.custid
WHERE ce.custid IS NULL

--update exception list: Master level
INSERT INTO bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception](CustID,Remark)
SELECT mag.custID, mag.username 
FROM customer mag WITH(NOLOCK)
	LEFT JOIN bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] ce WITH (NOLOCK) ON mag.custid = ce.custid
WHERE mag.roleid = 3 
	AND ce.custid IS NULL
	AND 
	(	mag.username LIKE 'IBC%'
		OR mag.username IN ('M527','SA-RMB001','MBRM')
	)
	AND mag.srecommend NOT IN ( SELECT custID FROM bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] WITH (NOLOCK))

--Delete Accounts whose uplines exist in [Task_Cust_ArchiveAcc_Exception]
DELETE ce
FROM bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] ce WITH (ROWLOCK,UPDLOCK)
	INNER JOIN custinfo ci WITH(NOLOCK) ON ce.CustID = ci.custid
WHERE ci.roleid IN(1,2,3)
	AND ci.srecommend IN ( SELECT custID FROM bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] WITH (NOLOCK))

DELETE ce
FROM bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] ce WITH (ROWLOCK,UPDLOCK)
	INNER JOIN custinfo ci WITH(NOLOCK) ON ce.CustID = ci.custid 
WHERE ci.roleid IN(1,2)
	AND ci.mrecommend IN ( SELECT custID FROM bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] WITH (NOLOCK))

--update exception list: Agent level
INSERT INTO bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception](CustID,Remark)
SELECT ag.custID, ag.username 
FROM customer ag WITH(NOLOCK)
	LEFT JOIN bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] ce WITH (NOLOCK) ON ag.custid = ce.custid
WHERE ag.roleid = 2 
	AND ce.custid IS NULL
	AND ag.srecommend NOT IN ( SELECT custID FROM bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] WITH (NOLOCK))
	AND ag.mrecommend NOT IN ( SELECT custID FROM bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] WITH (NOLOCK))
	AND 
	(	ag.username IN (
			'FB'
			,'AXR312'
			,'AA0312'
			,'A7HK'
			,'WEB339'
			,'6666ahk'
			,'hc88807'
			,'C527A','C527B'
			,'M63IRMB01'
			,'6001111'
			,'xxch60011100'
			,'BBC'
			,'caa'
			,'cc30'
			,'2005RM'
			,'exp'
			,'PHIRM'
			,'exp us'
			,'BERHK'
			,'HKACC'
			,'EXPHK'
			,'exp eu'
			,'THIRMB'
			,'8RM'
			,'WS-$US'
			,'wssd','wsrmb','wshk','wsrm'
			,'MMRODDS', 'wseuro' --request by Jacky @20160805
			,'SVVM1A1' --VIP super SVV @20170306 (Jane)
			) --internal hedging accounts
		OR ag.username like '999rm%' 
		OR ag.username like 'isn%' 
		OR ag.username like '6hk%' 
		OR ag.username like 'G33M%'
		OR ag.username LIKE 'XYZ%'
		OR ag.username LIKE 'M008IS%'
		OR ag.username LIKE 'CASH%'
		OR ag.username LIKE 'CSDTEST%'--request by Jacky @20160805
	)