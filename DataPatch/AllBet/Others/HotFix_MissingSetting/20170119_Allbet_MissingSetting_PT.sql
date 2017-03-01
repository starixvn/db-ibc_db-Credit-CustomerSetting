/*
	Created: 20170208@Helen
	Task: Missing Allbet setting - [Redmine:68644]
	DB: DBCUST/CUSTDB
*/
CREATE TABLE #cust_missingsetting (custid INT, Roleid INT, srecommend INT, mrecommend INT, recommend INT)

INSERT INTO #cust_missingsetting (custid,Roleid,srecommend,mrecommend,recommend)
SELECT custid,Roleid,srecommend,mrecommend,recommend
FROM custInfo CI WITH (NOLOCK)
WHERE CI.custid IN (24499948,
23714160,
23714077,
23778555,
23714661,
23714129,
23714176,
24499896,
24499845,
23713930,
24499954,
23714100,
23714123,
23714566,
24499022,
23943934,
24499654,
23714138,
23714087,
24499707,
23714809,
24499493,
23714107,
24499591,
23714792,
23714092,
24499115,
24499458,
24499083,
23714542,
23714265,
24499635,
24908055,
23714088,
23715324,
24499121,
24499623,
24499304,
23714871,
23714705,
23714639,
23714937,
23714954,
23714571,
13044498,
13053168,
23714708,
24846893,
24856018,
24907927,
24908028,
23715144,
23719280,
23733083,
23729783,
4076665,
3987484,
3984944,
23715065,
116927,

25076282,25076227,25076292,25076260,25076217,25076252,25076279,25076272,25076464,25076266,25076331,25076249
)

DECLARE @maxPT TINYINT, @SportType SMALLINT = 211, @Bettype SMALLINT = 2401, @IsLive BIT = 0

/********************************************* Position Taking: SettingType = 1 ***********************************/
-- @RoleID = 2,3,4
/*
s4: 0
m4: 0
a4: 0
n4: 0
l4: Default Max PT
*/
SET @maxPT = (SELECT MAXPT FROM dbo.ProductSettingDetail dtl WITH (NOLOCK) WHERE SportType = 211 AND SettingType = 1)

INSERT INTO [dbo].[CustPTSetting3rd_Agent]([CustID],[SportType],[BetType],[IsLive],[SuperPT],[MasterPT],[AgentPT],[IsAutoMasterPT],[AutoMasterPT],[IsAutoSuperPT],[AutoSuperPT],[MinPT],[MaxPT])
SELECT custid, @SportType,@Bettype,@IsLive
	 , 0,0,0,0,0,0,0,0
	 , @maxPT
FROM #cust_missingsetting T WITH (NOLOCK)
WHERE T.Roleid IN (2,3,4) AND NOT EXISTS (SELECT 1 FROM [CustPTSetting3rd_Agent] T1 WITH (NOLOCK) WHERE T1.CustID = T.custid AND T1.SportType = @SportType)

--RoleID = 1
DECLARE @CustID INT, @MasterID INT, @SuperID INT, @AgentID INT

DECLARE @n2 SMALLMONEY, @l2 SMALLMONEY
DECLARE @im2 bit, @um2 SMALLMONEY
DECLARE @a1 SMALLMONEY, @m1 SMALLMONEY, @s1 SMALLMONEY, @i1 bit, @u1 SMALLMONEY, @im1 bit, @um1 SMALLMONEY
DECLARE @temp1 SMALLMONEY, @temp2 SMALLMONEY, @temp3 SMALLMONEY
DECLARE @s_new SMALLMONEY, @m_new SMALLMONEY, @a_new SMALLMONEY

DECLARE @MemberPTTbl TABLE (
		CustID		INT
	, [SportType]	SMALLINT
	, [BetType]		SMALLINT
	, [Islive]		BIT	
	, [SuperPT]		TINYINT	
	, [MasterPT]	TINYINT
	, [AgentPT]		TINYINT
	, [IsAutoMPT]	BIT
	, [AutoMPT]		TINYINT
	, [IsAutoSPT]	BIT
	, [AutoSPT]		TINYINT
	, Isfinished BIT
	, mrecommend INT
	, recommend INT
	, srecommend INT
)

--Get default PT settings	
--s1: s3
--m1: m2
--a1: a2
--is1: 0
--us1: 0
--im1: 0
--um1: 0
INSERT INTO @MemberPTTbl (CustID, SportType, BetType, Islive, SuperPT, MasterPT, AgentPT, IsAutoMPT, AutoMPT, IsAutoSPT, AutoSPT,recommend,mrecommend,srecommend,Isfinished)
SELECT T.custid	, acs.SportType	, acs.BetType	, acs.IsLive	, mcs.superPT	, acs.masterPT	, acs.agentPT
		, 0	, 0	, 0	, 0
		,t.recommend,t.mrecommend,t.srecommend
		, 0
FROM #cust_missingsetting T 
	INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK) ON T.recommend = acs.CustID AND acs.sporttype = @SportType AND acs.BetType = @Bettype
	INNER JOIN dbo.CustPTSetting3rd_Agent mcs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND acs.islive = mcs.islive AND mcs.custid = T.mrecommend
WHERE T.Roleid = 1	

--Correct PT
UPDATE cs
SET @a1 = cs.AgentPT
	,@m1 = cs.MasterPT
	,@s1 = cs.SuperPT
	,@n2 = acs.MinPT
	,@l2 = acs.MaxPT
	,@im2 = acs.IsAutoMasterPT
	,@um2 = acs.AutoMasterPT
	,@i1 = cs.IsAutoSPT
	,@u1 = cs.AutoSPT
	,@im1 = cs.IsAutoMPT
	,@um1 = cs.AutoMPT

	-- rule #1: s1 = min(s1,s4-m3) if i=0
	,@s1 = CASE WHEN @i1 = 0 AND m.IsAutoSuperPT = 0 AND s.SuperPT-m.MasterPT < @s1 THEN s.SuperPT-m.MasterPT ELSE @s1 END

	-- rule #2: a1 = max(a1,n2); m1 = (a1<n2) ? m3-n2 : m1 --agent min
	,@a_new = CASE WHEN @a1 < @n2 THEN @n2 ELSE @a1 END
	,@m_new = CASE WHEN @a1 < @n2 AND @m1+@n2 > m.MasterPT THEN m.MasterPT-@n2 ELSE @m1 END
	,@a1 = @a_new
	,@m1 = @m_new								

	-- rule #3: a1 = min(a1,l2) -- agent max         
	,@a1 = CASE WHEN @a1 > @l2 THEN @l2 ELSE @a1 END

	-- rule #4: m1 = min(m3-a1,u2) if master auto -- Recalculate AUTO MPT 
	,@temp1 = CASE WHEN @im1 = 1 THEN @um1 ELSE @um2 END			
	,@m1 = CASE 
				WHEN @im2 = 1 OR @im1 = 1 
				THEN CASE WHEN m.MasterPT-@a1 > @temp1 THEN @temp1 ELSE m.MasterPT-@a1 END 
				ELSE @m1 
			END		

	-- rule #5: m1 = max(m1,n3-a1) -- master min   
	,@m1 = CASE WHEN @m1 < m.MinPT-@a1 THEN m.MinPT-@a1 ELSE @m1 END
         
	-- rule #6: check master max 
	/*	@x1 = min(m3,l3) -- mpt max
		@x2 = max(@x1-a1,0) --mpt
		m1 = (a1+m1>l3) ? @x2 : m1
		@x3 = (a1+@x2 > @x1) ? @x1-@x2 : a1
		a1 = (a1+m1>l1) ? max(@x3, n2) : a1
	*/ 
	,@temp1 = CASE WHEN m.MasterPT > m.MaxPT THEN m.MaxPT ELSE m.MasterPT END
	,@temp2 = CASE WHEN @temp1-@a1 < 0 THEN 0 ELSE @temp1-@a1 END
	,@m_new = CASE WHEN @a1+@m1 > m.MaxPT THEN @temp2 ELSE @m1 END
	,@temp3 = CASE WHEN @a1+@temp2 > @temp1 THEN @temp1-@temp2 ELSE @a1 END
	,@a_new = CASE 
				WHEN @a1+@m1 > m.MaxPT 
				THEN CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
				ELSE @a1 
			END	
	
	,@m1 = @m_new
	,@a1 = @a_new
	-- rule #7: s1 = min(s4-m1-a1, i1?u1:u3) --Recalculate auto pt
	/*
		@x1 = (i1=1) ? u1 : u3
		s1 = (s4-m1-a1 > @x1) ? @x1 : s4-m1-a1 
	*/
	,@temp1 = CASE WHEN @i1 = 1 THEN @u1 ELSE m.AutoSuperPT END			
	,@s1 = CASE 
				WHEN @i1 = 1 OR m.IsAutoSuperPT = 1 
				THEN CASE WHEN s.SuperPT-@m1-@a1 > @temp1 THEN @temp1 ELSE s.SuperPT-@m1-@a1 END
				ELSE @s1
			END		

	-- rule #8: s1 = max(n4-m1-a1,s1) --super min
	,@s1 = CASE WHEN @a1+@m1+@s1 < s.MinPT THEN s.MinPT-@m1-@a1 ELSE @s1 END	

	-- rule #9: UPDATE s1,m1,a1 in case s1+m1+a1>s4
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
	,@temp1 = CASE WHEN s.SuperPT-@m1-@a1 < 0 THEN 0 ELSE s.SuperPT-@m1-@a1 END
	,@s_new = CASE WHEN @s1+@a1+@m1 > s.SuperPT THEN @temp1 ELSE @s1 END
	,@temp1 = CASE WHEN @temp1+@m1+@a1 > s.SuperPT THEN s.SuperPT-@temp1 ELSE @m1+@a1 END
	,@temp2 = CASE WHEN m.MasterPT > m.MaxPT THEN m.MaxPT ELSE m.MasterPT END
	,@temp2 = CASE WHEN @temp1 > @temp2 THEN @temp2 ELSE @temp1 END
	,@temp2 = CASE WHEN @temp2 < m.MinPT THEN m.MinPT ELSE @temp2 END
	,@temp3 = CASE WHEN @temp2-@a1 < 0 THEN 0 ELSE @temp2-@a1 END
	,@m_new = CASE WHEN @s1+@a1+@m1 > s.SuperPT THEN @temp3 ELSE @m1 END
	,@temp3 = CASE WHEN @a1+@temp3 > @temp2 THEN @temp2-@temp3 ELSE @a1 END
	,@temp3 = CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
	,@a_new = CASE WHEN @s1+@a1+@m1 > s.SuperPT THEN @temp3 ELSE @a1 END
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
FROM @MemberPTTbl cs 
	INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH(NOLOCK) 	ON cs.recommend = acs.custid AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype AND cs.IsLive = acs.IsLive
	INNER JOIN dbo.CustPTSetting3rd_Agent m WITH(NOLOCK) ON cs.mrecommend = m.custid AND cs.sporttype = m.sporttype 	AND cs.bettype = m.bettype 	AND cs.IsLive = m.IsLive
	INNER JOIN dbo.CustPTSetting3rd_Agent s WITH(NOLOCK) ON cs.srecommend = s.custid AND cs.sporttype = s.sporttype 	AND cs.bettype = s.bettype 	AND cs.IsLive = s.IsLive
WHERE cs.sporttype = @SportType AND cs.BetType = @Bettype

-- Process one by one based on rule in Acc_DynamicCustomerInfo_00
WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) @MemberPTTbl
	SET isfinished = 1
		,@custid = custid	
		,@AgentID = recommend
		,@SuperID = srecommend 
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	--If this is the first member,insert into Group Setting
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
	SELECT @AgentID,SportType,BetType,Islive,
		SuperPT,MasterPT,AgentPT,IsAutoMPT,AutoMPT,IsAutoSPT,AutoSPT
	FROM @MemberPTTbl
	WHERE CustID = @CustID AND NOT EXISTS(SELECT TOP 1 1 FROM dbo.CustPTGroupSetting3rd_Member WHERE AgentID = @AgentID)
		AND @SuperID IN (
				13869621,
				5340162,
				12262401,
				12141653,
				4138910,
				6379932,
				16112208,
				12141529,
				1539339,
				720475
				--UUS
				,17287861
				,18879367
				,14373244
				,18362423
				,18479460
				,18289591
			)

	IF @@ROWCOUNT<>0
	BEGIN
		INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped)
			SELECT @CustID,1
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT TOP 1 1
					FROM dbo.CustPTGroupSetting3rd_Member grp WITH (NOLOCK)
						JOIN @memberPTTbl tmp ON tmp.SportType = grp.SportType	AND tmp.BetType = grp.BetType AND tmp.Islive = grp.Islive
					WHERE grp.AgentID = @AgentID AND TMP.CustID = @CustID
							AND (
								tmp.SuperPT <> grp.SuperPT
								OR
								tmp.MasterPT <> grp.MasterPT
								OR
								tmp.AgentPT <> grp.AgentPT
								OR
								tmp.IsAutoMPT <> grp.IsAutoMasterPT
								OR
								tmp.AutoMPT <> grp.AutoMasterPT
								OR
								tmp.IsAutoSPT <> grp.IsAutoSuperPT
								OR
								tmp.AutoSPT <> grp.AutoSuperPT
							)
						)
			OR @SuperID NOT IN (
								13869621,
								5340162,
								12262401,
								12141653,
								4138910,
								6379932,
								16112208,
								12141529,
								1539339,
								720475
								--UUS
								,17287861
								,18879367
								,14373244
								,18362423
								,18479460
								,18289591
							)
		BEGIN
			--If this member's PT setting are diffrent from Group PT Setting
			INSERT INTO [dbo].[CustPTSetting3rd_Member]
				   ([CustID]
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
			SELECT 
			@CustID,SportType,BetType,Islive,
				SuperPT,MasterPT,AgentPT,IsAutoMPT,AutoMPT,IsAutoSPT,AutoSPT
			FROM @memberPTTbl
			WHERE CustID = @CustID
			
			--INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped)
			--SELECT @CustID,0
		END
		ELSE
		BEGIN
			INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped)
			SELECT @CustID,1
		END
	END
	waitfor delay '00:00:0.180'
END

DROP TABLE #cust_missingsetting