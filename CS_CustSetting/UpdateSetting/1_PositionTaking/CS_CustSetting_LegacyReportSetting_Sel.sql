/*<info serverAlias="DBCUST-CUSTDB" executers="bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustSetting_LegacyReportSetting_Sel
	@RoleId TINYINT,
	@CustIDs VARCHAR(4000),
	@IsTest BIT = 0
AS
/*
	Created: 20190227@Johnson
	Task : Select PT info when update PT
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20190227@Johnson: Initial SP [Redmine:#105338]
		
	Param's Explanation:
		• @RoleId: roleid of list custid			
			
	Example: 		
		CS_CustSetting_LegacyReportSetting_Sel @roleid = 4, @CustIDs = '34109295', @istest = 1
		CS_CustSetting_LegacyReportSetting_Sel @roleid = 3, @CustIDs = '34109319', @istest = 1
		CS_CustSetting_LegacyReportSetting_Sel @roleid = 2, @CustIDs = '34109329', @istest = 1
		CS_CustSetting_LegacyReportSetting_Sel @roleid = 1, @CustIDs = '34109340', @istest = 1
		
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @tblCust TABLE(CustID INT)
	DECLARE @isEditablePT BIT, 
			@ProductID TINYINT = 1,
			@agentID INT,
			@today DATETIME
			
	CREATE TABLE #PTResult (custid INT, sporttype INT, bettype INT, superPT SMALLMONEY DEFAULT(0), masterPT SMALLMONEY DEFAULT(0), agentPT SMALLMONEY DEFAULT(0), extraPT SMALLMONEY DEFAULT(0))
	
	SELECT @IsEditablePT = IsEditablePT FROM dbo.f_CS_GetEditablePTDate(@ProductID)
	
	INSERT INTO @tblCust(custid)
	SELECT val FROM dbo.strSplit(@CustIDs,',')
	
	--get sport/bettype offer for cn88
	SELECT t.* INTO #SportBettypeFilter1
	FROM dbo.f_CS_SportBetTypeSettingSelect(NULL,1, @IsTest) t

	IF @roleid = 4
	BEGIN
		SELECT @today = GETDATE()
		
		--get extra pt
		INSERT INTO #PTResult(custid,sporttype,bettype,extraPT)
		SELECT e.superid as custid, s.sporttype, s.bettype, e.ExtraPT*100
		FROM Acc_GroupExtraPTSetting e WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter1 s ON e.productID = s.productID
		WHERE superID IN (SELECT custid FROM @tblCust)
			 AND e.Sporttype = 0		--- General Sporttype of SB & other products
			 AND SubProduct = '' 	--- General SubProduct of SB & other products 
			 AND @today BETWEEN FromDate AND ToDate
			
	END
	ELSE IF @roleid = 3
	BEGIN
		INSERT INTO #PTResult(custid,sporttype,bettype,superPT)
		SELECT t.custid, cs.sporttype, cs.bettype, CASE WHEN @isEditablePT = 1 THEN cs.superPT2 ELSE cs.superPT END
		FROM @tblCust t
			CROSS APPLY dbo.f_CS_GetPT_Agent(t.custid) cs
			INNER JOIN #SportBettypeFilter1 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive			
	END
	ELSE IF @roleid = 2
	BEGIN
		INSERT INTO #PTResult(custid,sporttype,bettype,masterPT,agentPT)
		SELECT t.custid, cs.sporttype, cs.bettype, 
			CASE WHEN @isEditablePT = 1 THEN cs.masterPT2 ELSE cs.masterPT END,
			CASE WHEN @isEditablePT = 1 THEN cs.agentPT2 ELSE cs.agentPT END
		FROM @tblCust t
			CROSS APPLY dbo.f_CS_GetPT_Agent(t.custid) cs
			INNER JOIN #SportBettypeFilter1 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive			
	END
	ELSE IF @roleid = 1
	BEGIN
		SELECT @AgentID = recommend 
		FROM dbo.custinfo ci (NOLOCK)
		WHERE custid IN (SELECT top 1 custid FROM @tblCust)
		
		INSERT INTO #PTResult(custid,sporttype,bettype,agentPT)
		SELECT t.custid, cs.sporttype, cs.bettype,
			CASE WHEN @isEditablePT = 1 THEN cs.agentPT2 ELSE cs.agentPT END
		FROM @tblCust t
			CROSS APPLY dbo.f_CS_GetPTGroup_Member(@AgentID) cs
			INNER JOIN #SportBettypeFilter1 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive			
	END
	
	SELECT * FROM #PTResult
END