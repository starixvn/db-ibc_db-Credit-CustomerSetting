/*<info serverAlias="DBACC-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount_DisabledAgents_NoBal_GenScript]
AS
/*
	Created: 20191206@Daniel
	Task: Archive Acc - Gen script batch run sp to archive disabled agents with no balances
	DB: DBACC/bodb02
	Original:

	Revisions:
		20191206@Daniel: Created

*/
IF (1 = 0)-- dummy code to trick ssis load result set
BEGIN 
	SELECT CONVERT(varchar(30), NULL) Super
	,CONVERT(varchar(30), NULL) Master
	,CONVERT(varchar(30), NULL) Agent
	,CONVERT(int, NULL) recommend
END

SET NOCOUNT ON

--update exception list
EXEC dbo.DBA_ArchiveAccount_UpdateException

SELECT s.username Super, m.username Master, a.username Agent, a.custid recommend
FROM custinfo a with(nolock)
	inner join custagent ca with (nolock) on a.custid = ca.custid
	inner join customer m with (nolock) on a.mrecommend = m.custid
	inner join customer s with (nolock) on a.srecommend = s.custid
	left join dbo.bettrans b WITH (NOLOCK) on a.custid = b.recommend and b.ruben = 1
	left join(
		select recommend, count(1) MemCnt from customer with (nolock) where roleid = 1 group by recommend) mem on a.custid = mem.recommend
WHERE a.enabled = 0
	and a.credit = 0
	and a.srecommend NOT IN (select custid FROM dbo.Dep_CustSuper with (nolock))
	and ca.isInternal = 0
	and a.custid NOT IN(
		select distinct recommend FROM customer with (nolock) 
		where custid IN(select custid from bodb_report.dbo.Task_Cust_ArchiveAcc_Exception with (nolock))
	)
	and isnull(memCnt, 0) = 0
GROUP BY s.username, m.username, a.custid, a.username, memCnt, a.custid
having ISNULL(SUM(CASE WHEN b.custid = b.recommend THEN winlost-actual_stake ELSE awinlost+comm-playercomm END), 0) = 0
	and ISNULL(SUM(CASE WHEN b.custid <> b.recommend THEN winlost-actual_stake+playercomm ELSE 0 END), 0) = 0