ALTER PROCEDURE dbo.DBA_CustSetting_SetupGroupSetting  
	@srecommend INT
AS
/*  
	Created By: Dominic  
	Created Date: 20151027  
	Description: This SP is used to setup Group PT for a specific super. Plz be noted that that this SP
		is applied for super that do not have any data in dbo.CustPTSetting3rd_Member  

	Param explaination:  
		@agentID: recommend    
  
*/
BEGIN
	SET NOCOUNT ON
		
	create table #tempData (recommend int, custid int, cs1 bigint, cs2 int)
	create table #tempGroup(recommend int, cs1 bigint, cs2 int, memberCNT int, repCustID int)

	;WITH _s as (
		SELECT c.recommend, c.custid	
			,rdSetting = CAST(DENSE_RANK() OVER(ORDER BY sporttype, bettype, islive, superPT, masterPT, agentPT, isAutoMasterPT, AutoMasterPT, isAutoSuperPT, AutoSuperPT) as INT)
			,rdProduct = CAST(DENSE_RANK() OVER(ORDER BY sporttype, bettype, islive) as INT)
		FROM dbo.custinfo c WITH(NOLOCK)
			INNER JOIN dbo.CustPTSetting3rd_Member pt WITH(NOLOCK) ON c.custid = pt.custid		
		WHERE srecommend = @srecommend
			AND roleid = 1
	)
	INSERT INTO #tempdata (recommend, custid, cs1, cs2)
	SELECT recommend, custid, SUM(CONVERT(bigint,rdSetting) + POWER(2, rdProduct%10+1)), CHECKSUM_AGG(CHECKSUM(HASHBYTES('SHA1', CONVERT(nvarchar(max), rdSetting))))
	FROM _s
	group by recommend, custid

	INSERT INTO #tempGroup(recommend, cs1, cs2, memberCNT, repCustID)
	SELECT recommend, cs1, cs2, memberCnt, repCustID
	FROM (
		SELECT recommend, cs1, cs2, rn = ROW_NUMBER() OVER (partition by recommend ORDER BY count(1) desc), memberCnt = count(1), repCustID = max(custid)
		FROM #tempdata
		GROUP BY recommend, cs1, cs2
	) x
	WHERE rn = 1

	--Insert settings of PT Group
	INSERT INTO [dbo].[CustPTGroupSetting3rd_Member]
	   ([AgentID]
	   ,[SportType]
	   ,[BetType]
	   ,[IsLive]
	   ,[SuperPT]
	   ,[MasterPT]
	   ,[AgentPT]
	   ,[IsAutoMasterPT]
	   ,[AutoMasterPT]
	   ,[IsAutoSuperPT]
	   ,[AutoSuperPT])
	SELECT tmp.recommend
	  ,[SportType]
	  ,[BetType]
	  ,[IsLive]
	  ,[SuperPT]
	  ,[MasterPT]
	  ,[AgentPT]
	  ,[IsAutoMasterPT]
	  ,[AutoMasterPT]
	  ,[IsAutoSuperPT]
	  ,[AutoSuperPT]
	FROM [dbo].[CustPTSetting3rd_Member] mb
		INNER JOIN #tempGroup tmp ON mb.CustID = tmp.repCustID
		
	
	--Update group mode	
	UPDATE main
	SET IsGrouped = 1
	FROM dbo.CustSettingMode3rd main WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #tempData tmp1 WITH(NOLOCK)
		ON tmp1.custid = main.CustID
	INNER JOIN #tempGroup tmp2 WITH(NOLOCK)
		ON tmp1.cs1 = tmp2.cs1
			AND tmp1.cs2 = tmp2.cs2
			AND tmp1.recommend = tmp2.recommend
	
	--Delete individual settings		
	DELETE cs
	FROM dbo.CustPTSetting3rd_Member cs
	INNER JOIN #tempData tmp1 WITH(NOLOCK)
		ON tmp1.custid = cs.CustID
	INNER JOIN dbo.CustSettingMode3rd m WITH(NOLOCK)
		ON cs.CustID = m.CustID
	WHERE m.IsGrouped = 1
			

	DROP TABLE #tempdata
	DROP TABLE #tempGroup
END
	
	