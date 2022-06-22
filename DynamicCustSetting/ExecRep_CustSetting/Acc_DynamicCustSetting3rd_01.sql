/*<info serverAlias="DBCUST-CustDB" executers="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_01]
	@SuperID INT
	,@SportBettypeXML NVARCHAR(MAX) = ''
AS
/*
    Created: Elodie
    Date: 20150901
    Task: Update member level when update l4
    DB: DBCUST/CustDB
    Original versions: Acc_CustSetting3rd_01
        
    Revision:
		- 20220622@Elodie:  Run by batch [RedmineID: #174131]
		
    Parameter's Explanation:        

*/
BEGIN
	SET NOCOUNT ON

	IF dbo.f_CheckRepTable('custinfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 0 RETURN	
	
	DECLARE @tmpSportBettype TABLE(sporttype SMALLINT, bettype SMALLINT, islive BIT)
	DECLARE @BatchNo INT = 5000, @SettingRow TINYINT
	CREATE TABLE #Agent(custid INT, srecommend INT, mrecommend INT, recommend INT)
	CREATE TABLE #Member(custid INT, srecommend INT, mrecommend INT, recommend INT)
	CREATE TABLE #AgentTmpBatch(custid INT, srecommend INT, mrecommend INT, recommend INT)
	CREATE TABLE #MemberTmpBatch(custid INT, srecommend INT, mrecommend INT, recommend INT)

	-- declare variable table to keep super's settings 
	DECLARE @temp_sag TABLE (custid int, bettype smallint, sporttype smallint, islive bit, s4 smallmoney
		UNIQUE CLUSTERED (custid, sporttype, bettype, islive)
	)
	
	-- declare variable table to keep master's settings 
	DECLARE @temp_mag TABLE (custid int, bettype smallint, sporttype smallint, islive bit, m3 smallmoney, i3 bit, n3 smallmoney, l3 smallmoney
		UNIQUE CLUSTERED (custid, sporttype, bettype, islive)
	)

	DECLARE @a1 smallmoney, @m1 smallmoney, @s1 smallmoney, @i1 bit, @n2 smallmoney
	DECLARE @temp1 smallmoney, @temp2 smallmoney, @temp3 smallmoney
	DECLARE @s_new smallmoney, @m_new smallmoney, @a_new smallmoney
	---------------------------------

	INSERT INTO @tmpSportBettype (sporttype, bettype, islive)
	SELECT SportType,Bettype,IsLive
	FROM dbo.f_DCS_PT_XMLParse(@SportBetTypeXML)

	INSERT INTO @temp_sag (custid, bettype, sporttype, islive, s4)
	SELECT scs.custid, scs.bettype, scs.sporttype, scs.IsLive, scs.SuperPT
	FROM dbo.CustPTSetting3rd_Agent scs WITH(NOLOCK)
		INNER JOIN @tmpSportBettype tmp ON tmp.sporttype = scs.SportType AND tmp.bettype = scs.BetType AND tmp.islive = scs.IsLive
	WHERE scs.custid = @SuperID

	INSERT INTO @temp_mag (custid, bettype, sporttype, islive, m3, i3, n3, l3)
	SELECT mcs.custid, mcs.bettype, mcs.sporttype, mcs.IsLive, mcs.MasterPT, mcs.IsAutoSuperPT, mcs.MinPT, mcs.MaxPT
	FROM dbo.custinfo c WITH(NOLOCK)
		INNER JOIN dbo.CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON c.custid = mcs.custid
		INNER JOIN @tmpSportBettype tmp ON tmp.sporttype = mcs.SportType AND tmp.bettype = mcs.BetType AND tmp.islive = mcs.IsLive
	WHERE c.srecommend = @SuperID AND c.roleid = 3

	SELECT @SettingRow = COUNT(1) FROM @tmpSportBettype
	IF @SettingRow = 0 RETURN
	SELECT @BatchNo = @BatchNo / @SettingRow

	INSERT INTO #Agent(custid, srecommend, mrecommend, recommend)
	SELECT custid, srecommend, mrecommend, recommend
	FROM custInfo c WITH(NOLOCK) 
	WHERE srecommend = @SuperID AND roleid = 2 AND Enabled = 1	
			
	INSERT INTO #Member(custid, srecommend, mrecommend, recommend)
	SELECT custid, srecommend, mrecommend, recommend
	FROM custInfo c WITH(NOLOCK) 
	WHERE srecommend = @SuperID AND roleid = 1 AND Enabled = 1

	--*** START: update PT on member ***-----------------------	
	WHILE 1 = 1
	BEGIN
		TRUNCATE TABLE #MemberTmpBatch
		DELETE TOP (@BatchNo) a
		OUTPUT deleted.custid INTO #MemberTmpBatch(custid)
		FROM #Member a

		IF @@ROWCOUNT = 0 
			BREAK;

		UPDATE cs
		SET @a1 = cs.AgentPT
			,@m1 = cs.MasterPT
			,@s1 = cs.SuperPT
			,@n2 = acs.MinPT			
			,@i1 = cs.IsAutoSuperPT			
			
			-- rule #1: s1 = min(s1,s4-m3) if i=0
			,@s1 = CASE WHEN @i1 = 0 AND m.i3 = 0 AND s.s4-m.m3 < @s1 THEN s.s4-m.m3 ELSE @s1 END

			-- rule #2: UPDATE s1,m1,a1 in case s1+m1+a1>s4
			/* -- explanation
				@x1 = (s4-m1-a1 < 0) ? 0 : s4-m1-a1
				s1 = (s1+a1+m1 > s4) ? @x1 : s1
				@x1 = (@x1+m1+a1 > s4) ? s4-@x1 : m1+a1
				@x2 = (m3 > l3) ? l3 : m3
				@x2 = (@x1 > @x2) ? @x2 : @x1
				@x2 = (@x2 < n3) ? n3 : @x2
				@x3 = (@x2-a1 < 0) ? 0 : @x2-a1
				m1 = (s1+a1+m1 > s4) ? @x3 : m1
				@x3 = (a1+@x3>@x2) ? @x2-@x3 : a1
				@x3 =  (@x3 < n2) ? n2 : @x3
				a1 = (s1+a1+m1 > s4) ? @x3 : a1				
			*/             
			,@temp1 = CASE WHEN s.s4-@m1-@a1 < 0 THEN 0 ELSE s.s4-@m1-@a1 END
			,@s_new = CASE WHEN @s1+@a1+@m1 > s.s4 THEN @temp1 ELSE @s1 END
			,@temp1 = CASE WHEN @temp1+@m1+@a1 > s.s4 THEN s.s4-@temp1 ELSE @m1+@a1 END
			,@temp2 = CASE WHEN m.m3 > m.l3 THEN m.l3 ELSE m.m3 END
			,@temp2 = CASE WHEN @temp1 > @temp2 THEN @temp2 ELSE @temp1 END
			,@temp2 = CASE WHEN @temp2 < m.n3 THEN m.n3 ELSE @temp2 END
			,@temp3 = CASE WHEN @temp2-@a1 < 0 THEN 0 ELSE @temp2-@a1 END
			,@m_new = CASE WHEN @s1+@a1+@m1 > s.s4 THEN @temp3 ELSE @m1 END
			,@temp3 = CASE WHEN @a1+@temp3 > @temp2 THEN @temp2-@temp3 ELSE @a1 END
			,@temp3 = CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
			,@a_new = CASE WHEN @s1+@a1+@m1 > s.s4 THEN @temp3 ELSE @a1 END
			,@s1 = @s_new
			,@m1 = @m_new
			,@a1 = @a_new
		
			--PT values must be in [0,100]
			,@s1 = CASE WHEN @s1 < 0 THEN 0 ELSE @s1 END
			,@s1 = CASE WHEN @s1 > 100 THEN 100 ELSE @s1 END
			,@m1 = CASE WHEN @m1 < 0 THEN 0 ELSE @m1 END
			,@m1 = CASE WHEN @m1 > 100 THEN 100 ELSE @m1 END
			,@a1 = CASE WHEN @a1 < 0 THEN 0 ELSE @a1 END
			,@a1 = CASE WHEN @a1 > 100 THEN 100 ELSE @a1 END	
			--------------------------------	
			-- done apply all rule, then update to destination table
			,cs.AgentPT = @a1
			,cs.MasterPT = @m1
			,cs.SuperPT = @s1								       
		FROM #MemberTmpBatch c WITH(NOLOCK)
			INNER JOIN dbo.CustPTSetting3rd_Member cs WITH(ROWLOCK, UPDLOCK) ON c.custid = cs.custid
			INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH(NOLOCK) on c.recommend = acs.custid AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype AND cs.IsLive = acs.IsLive
			INNER JOIN @temp_mag m ON c.mrecommend = m.custid AND cs.sporttype = m.sporttype AND cs.bettype = m.bettype AND cs.IsLive = m.IsLive
			INNER JOIN @temp_sag s ON c.srecommend = s.custid AND cs.sporttype = s.sporttype AND cs.bettype = s.bettype AND cs.IsLive = s.IsLive
		
	END
	--*** END: update PT on member ***-------------------------	
	
	--*** START: update PT group on member ***-----------------------	
	WHILE 1 = 1
	BEGIN
		TRUNCATE TABLE #AgentTmpBatch
		DELETE TOP (@BatchNo) a
		OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
		FROM #Agent a

		IF @@ROWCOUNT = 0 
			BREAK

		UPDATE cs
		SET @a1 = cs.AgentPT
			,@m1 = cs.MasterPT
			,@s1 = cs.SuperPT
			,@n2 = acs.MinPT			
			,@i1 = cs.IsAutoSuperPT			
			
			-- rule #1: s1 = min(s1,s4-m3) if i=0
			,@s1 = CASE WHEN @i1 = 0 AND m.i3 = 0 AND s.s4-m.m3 < @s1 THEN s.s4-m.m3 ELSE @s1 END

			-- rule #2: UPDATE s1,m1,a1 in case s1+m1+a1>s4
			/* -- explanation
				@x1 = (s4-m1-a1 < 0) ? 0 : s4-m1-a1
				s1 = (s1+a1+m1 > s4) ? @x1 : s1
				@x1 = (@x1+m1+a1 > s4) ? s4-@x1 : m1+a1
				@x2 = (m3 > l3) ? l3 : m3
				@x2 = (@x1 > @x2) ? @x2 : @x1
				@x2 = (@x2 < n3) ? n3 : @x2
				@x3 = (@x2-a1 < 0) ? 0 : @x2-a1
				m1 = (s1+a1+m1 > s4) ? @x3 : m1
				@x3 = (a1+@x3>@x2) ? @x2-@x3 : a1
				@x3 =  (@x3 < n2) ? n2 : @x3
				a1 = (s1+a1+m1 > s4) ? @x3 : a1				
			*/             
			,@temp1 = CASE WHEN s.s4-@m1-@a1 < 0 THEN 0 ELSE s.s4-@m1-@a1 END
			,@s_new = CASE WHEN @s1+@a1+@m1 > s.s4 THEN @temp1 ELSE @s1 END
			,@temp1 = CASE WHEN @temp1+@m1+@a1 > s.s4 THEN s.s4-@temp1 ELSE @m1+@a1 END
			,@temp2 = CASE WHEN m.m3 > m.l3 THEN m.l3 ELSE m.m3 END
			,@temp2 = CASE WHEN @temp1 > @temp2 THEN @temp2 ELSE @temp1 END
			,@temp2 = CASE WHEN @temp2 < m.n3 THEN m.n3 ELSE @temp2 END
			,@temp3 = CASE WHEN @temp2-@a1 < 0 THEN 0 ELSE @temp2-@a1 END
			,@m_new = CASE WHEN @s1+@a1+@m1 > s.s4 THEN @temp3 ELSE @m1 END
			,@temp3 = CASE WHEN @a1+@temp3 > @temp2 THEN @temp2-@temp3 ELSE @a1 END
			,@temp3 = CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
			,@a_new = CASE WHEN @s1+@a1+@m1 > s.s4 THEN @temp3 ELSE @a1 END
			,@s1 = @s_new
			,@m1 = @m_new
			,@a1 = @a_new
		
			--PT values must be in [0,100]
			,@s1 = CASE WHEN @s1 < 0 THEN 0 ELSE @s1 END
			,@s1 = CASE WHEN @s1 > 100 THEN 100 ELSE @s1 END
			,@m1 = CASE WHEN @m1 < 0 THEN 0 ELSE @m1 END
			,@m1 = CASE WHEN @m1 > 100 THEN 100 ELSE @m1 END
			,@a1 = CASE WHEN @a1 < 0 THEN 0 ELSE @a1 END
			,@a1 = CASE WHEN @a1 > 100 THEN 100 ELSE @a1 END	
			--------------------------------	
			-- done apply all rule, then update to destination table
			,cs.AgentPT = @a1
			,cs.MasterPT = @m1
			,cs.SuperPT = @s1								       
		FROM #AgentTmpBatch c WITH(NOLOCK)
			INNER JOIN dbo.CustPTGroupSetting3rd_Member cs WITH(ROWLOCK, UPDLOCK) ON c.custid = cs.AgentID
			INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH(NOLOCK) on c.recommend = acs.custid AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype AND cs.IsLive = acs.IsLive
			INNER JOIN @temp_mag m ON c.mrecommend = m.custid AND cs.sporttype = m.sporttype AND cs.bettype = m.bettype AND cs.IsLive = m.IsLive
			INNER JOIN @temp_sag s ON c.srecommend = s.custid AND cs.sporttype = s.sporttype AND cs.bettype = s.bettype AND cs.IsLive = s.IsLive
	END
	--*** END: update PT group on member ***-------------------------	
END




