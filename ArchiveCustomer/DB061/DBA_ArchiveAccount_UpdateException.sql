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
	Param's Explanation:
*/
SET NOCOUNT ON

--update exception list
INSERT INTO bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception]
SELECT ag.custID, ag.username FROM customer ag WITH(NOLOCK)
	INNER JOIN custinfo mag WITH(NOLOCK) ON ag.mrecommend = mag.custID
	INNER JOIN custinfo sag WITH(NOLOCK) ON ag.srecommend = sag.custID
	LEFT JOIN bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] ce WITH (NOLOCK) ON ag.custid = ce.custid
WHERE ag.roleid = 2 AND ce.custid IS NULL
	AND 
	(
		sag.username LIKE '3rdSuper%'
		OR sag.username IN ('STAFF', 'SA-UUS', 'LC-RM', 'U3S',
			'OPS-RM', 'OPS-RMB', 'OPS-HKK', 'OPS-THB', 'OPS-IDD', 'OPS-US$', 'OPS-GBP'--CSD request internal use @20180424
		)
		OR sag.currency IN(20, 72)
		OR sag.username LIKE 'SuperTest%'
		OR sag.username LIKE 'STEST%'
		OR sag.username LIKE 'SIBC%'
		OR sag.username LIKE '%ACCSuper%'
		OR mag.username LIKE 'IBC%'
		OR mag.username IN ('M527','SA-RMB001','MBRM')
		OR ag.username IN (
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
		OR ag.site = 'cn88'--exclude cn88 cust
	)

--Exclude Phone betting customers
INSERT INTO bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception]
select DISTINCT ag.custid, ag.username 
from phonebettingCustomerList p with(nolock)
	inner join custinfo c with(nolock) on p.username=c.username
	inner join custinfo ag with (nolock) on ag.custid=c.recommend
	LEFT JOIN bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] ce WITH (NOLOCK) ON ag.custid = ce.custid
WHERE ce.custid IS NULL