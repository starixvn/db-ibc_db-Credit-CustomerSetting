/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberVS_Positiontaking]    Script Date: 11/28/2013 14:47:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentPTOnMemberMultiUpd] 
	  @CustIDList	VARCHAR(MAX)
	, @PT			VARCHAR(MAX)
	, @SubAccID		INT				= 0
	, @IP			VARCHAR(50)		= ''
	, @UserID		INT				= 0
	, @ErrCode		INT				= 0		OUTPUT
	, @MsgType		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(4000)	= ''	OUTPUT
AS
/*
		Created: Dominic
		Date: 2014-12-08
		Task: Agent multiple update member's PT
		DB: DBCUST/CustDB
        
        Revisions:
            - 20151016@Billy: Fix log xml structure and naming
			- 20151104@Billy: Change log PT value range from [0,90] to [0,0.9] and update log structure - [Redmine: #46781, #46788]

		Parameter's Explanation:	
		• @PT:
					<ROOT>
							<PT 
									SportType="1" 
									BetType="1" 
									IsLive="1" 
									AgentPT="10" 
							/>
					</ROOT>
	*/
BEGIN
	SET NOCOUNT ON
--******************************************VARIABLE DECLARATION*************************************** 
	--Logs
	DECLARE @StartRun	DATETIME
		, @EndRun		DATETIME
		, @Duration		INT
		, @Old_PT_XML	VARCHAR(MAX)
		, @New_PT_XML	VARCHAR(MAX)
	
	--Temp variables for PT adjustment		
	DECLARE @_AgentID			INT
		, @_MasterID			INT
		, @_SuperID			INT
		, @RepresentCustID	INT
		, @RoleID			INT
		, @NoMember INT = 0
		, @NoGroupedMember INT = 0
	
	--List of customers		
	DECLARE @tblCust TABLE (CustID INT)
	
	--Temp table variables being used for calculation
	DECLARE @NewPTTble TABLE (
					  SportType			SMALLINT
					, BetType			SMALLINT
					, IsLive			BIT
					, SuperPT			TINYINT
					, MasterPT			TINYINT
					, AgentPT			TINYINT
					, AgentPT_Max		TINYINT
					, AgentAPT_Max		TINYINT
					, IsAutoMasterPT	BIT
					, AutoMasterPT		TINYINT
					, IsAutoSuperPT		BIT
					, AutoSuperPT		TINYINT
					UNIQUE CLUSTERED (SportType, BetType, IsLive)
				)
	DECLARE @OldPTTble TABLE (
					SportType			SMALLINT
					, BetType			SMALLINT
					, IsLive			BIT
					, SuperPT			TINYINT
					, MasterPT			TINYINT
					, AgentPT			TINYINT
					, IsAutoMasterPT	BIT
					, AutoMasterPT		TINYINT
					, IsAutoSuperPT		BIT
					, AutoSuperPT		TINYINT
					UNIQUE CLUSTERED (SportType, BetType, IsLive)
				)

	--Super PT Setting Values		
	DECLARE @_SuperPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S4				TINYINT  ,
					M4				TINYINT  ,
					A4				TINYINT  ,
					IM4				BIT  ,
					UM4				TINYINT  ,
					IS4				BIT  ,
					US4				TINYINT  ,
					N4				TINYINT  ,
					L4				TINYINT  
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
				
	--Master PT Setting Values
	DECLARE @_MasterPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S3				TINYINT  ,
					M3				TINYINT  ,
					A3				TINYINT  ,
					IM3				BIT  ,
					UM3				TINYINT  ,
					IS3				BIT  ,
					US3				TINYINT  ,
					N3				TINYINT  ,
					L3				TINYINT  
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
				
	--Agent PT Setting Values
	DECLARE @_AgentPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S2				TINYINT  ,
					M2				TINYINT  ,
					A2				TINYINT  ,
					IM2				BIT  ,
					UM2				TINYINT  ,
					IS2				BIT  ,
					US2				TINYINT  ,
					N2				TINYINT  ,
					L2				TINYINT  
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)

	DECLARE @ProductID		TINYINT,
			@ProductName	VARCHAR(50),
			@SettingLevel	TINYINT

--******************************************PERMISSION CHECKING*************************************** 			
	--Check if XML is null or empty
	IF @PT IS NULL
		OR @PT = ''
		OR @CustIDList IS NULL
		OR @CustIDList = ''
		RETURN

	SET @StartRun = GETDATE()

	SELECT @ErrCode = 0
		, @MsgType = 0
		, @ErrMsg = ''


	--Parse affected Customer
	DECLARE @XML XML
	SET @XML = N'<root><r>' + REPLACE(@CustIDList, ',', '</r><r>') + '</r></root>'
	
	INSERT INTO @tblCust (CustID)
	SELECT r.value('.','INT')
	FROM @xml.nodes('//root/r') AS RECORDS(r)

	-- ***Check Downline Belonging***
	EXEC dbo.Acc_CustSetting_BelongingMultiCustCheck @SessionCustID = @Userid
		, @Custid = @CustIDList
		, @roleid = @roleid OUTPUT

	IF (@roleid = 0)
	BEGIN
		SET @MsgType = 101
		SET @ErrCode = 101
		SET @ErrMsg = 'Users are not in the same line!'
		RETURN
	END

			
	--Check disable user
	EXEC dbo.Acc_CustSetting_MultiCustEnableCheck @CustIDList = @CustIDList
		, @ErrCode = @ErrCode OUTPUT
		, @ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode > 0
		RETURN
	
--******************************************PREPARE SETTING FOR UPDATE*************************************** 		
	--Parse XML	
	INSERT @NewPTTble
	SELECT SportType
			,BetType
			,IsLive
			,0,0,AgentPT,0,0,0,0,0,0
	FROM dbo.f_DCS_PT_XMLParse(@PT)
			
	--Get line infor : SMA accounts
	SELECT TOP 1 @RepresentCustID=CustID
	FROM @tblCust
	
	SELECT @_SuperID = srecommend
			, @_MasterID = mrecommend
			, @_AgentID = recommend
	FROM custinfo ci WITH(NOLOCK)
	WHERE ci.custid = @RepresentCustID
	
	--Get another member settings used for PT calcualtion
	UPDATE main
	SET  main.SuperPT = cs.SuperPT
		, main.MasterPT = cs.MasterPT
		, main.IsAutoSuperPT =cs.IsAutoSuperPT
		, main.AutoSuperPT = cs.AutoSuperPT
		, main.IsAutoMasterPT = cs.IsAutoMasterPT
		, main.AutoMasterPT = cs.AutoMasterPT
	FROM @NewPTTble main
		INNER JOIN dbo.CustPTGroupSetting3rd_Member cs WITH (NOLOCK)
			ON cs.SportType=main.SportType
					AND cs.BetType=main.BetType
					AND cs.IsLive=main.IsLive
					AND cs.AgentID=@_AgentID
	
	--Backup old settings for logs
	INSERT @OldPTTble
	SELECT 
			cs.SportType 
			, cs.BetType 
			, cs.IsLive 
			, cs.SuperPT 
			, cs.MasterPT
			, cs.AgentPT  
			, cs.IsAutoMasterPT 
			, cs.AutoMasterPT 
			, cs.IsAutoSuperPT 
			, cs.AutoSuperPT
	FROM @NewPTTble main
		INNER JOIN dbo.CustPTGroupSetting3rd_Member cs WITH (NOLOCK)
			ON cs.SportType=main.SportType
					AND cs.BetType=main.BetType
					AND cs.IsLive=main.IsLive
					AND cs.AgentID=@_AgentID	
				
	--Get Super PT Setting Values
	INSERT @_SuperPTTbl(SportType,BetType,IsLive,S4,M4,A4
							,IM4,UM4,IS4,US4,N4,L4)	
	SELECT cs.SportType,cs.BetType,cs.IsLive,cs.SuperPT,cs.MasterPT,cs.AgentPT
							,cs.IsAutoMasterPT,cs.AutoMasterPT,cs.IsAutoSuperPT,cs.AutoSuperPT,MinPT,MaxPT 
	FROM dbo.CustPTSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN @NewPTTble mt 
			ON mt.SportType = cs.SportType
				AND mt.BetType = cs.BetType
				AND mt.IsLive = cs.IsLive
	WHERE cs.CustID = @_SuperID
	
	--Get master PT Setting Values
	INSERT @_MasterPTTbl(SportType,BetType,IsLive,S3,M3,A3
				,IM3,UM3,IS3,US3,N3,L3)	
	SELECT mcs.SportType,mcs.BetType,mcs.IsLive,mcs.SuperPT,mcs.MasterPT,mcs.AgentPT
				,mcs.IsAutoMasterPT,mcs.AutoMasterPT,mcs.IsAutoSuperPT,mcs.AutoSuperPT,MinPT,MaxPT 
	FROM dbo.CustPTSetting3rd_Agent mcs WITH(NOLOCK)
		INNER JOIN @NewPTTble mt 
			ON mt.SportType = mcs.SportType
				AND mt.BetType = mcs.BetType
				AND mt.IsLive = mcs.IsLive
	WHERE mcs.CustID = @_MasterID
	
	--Get Agent PT Setting Values
	INSERT @_AgentPTTbl(SportType,BetType,IsLive,S2,M2,A2
				,IM2,UM2,IS2,US2,N2,L2)	
	SELECT acs.SportType,acs.BetType,acs.IsLive,acs.SuperPT,acs.MasterPT,acs.AgentPT
				,acs.IsAutoMasterPT,acs.AutoMasterPT,acs.IsAutoSuperPT,acs.AutoSuperPT,MinPT,MaxPT 
	FROM dbo.CustPTSetting3rd_Agent acs WITH(NOLOCK)
		INNER JOIN @NewPTTble mt 
			ON mt.SportType = acs.SportType
				AND mt.BetType = acs.BetType
				AND mt.IsLive = acs.IsLive
	WHERE acs.CustID = @_AgentID	
	

--******************************************VALIDATE PT VALUES*************************************** 					
	--Check error		
	EXEC [dbo].Acc_CustSetting_MemberPTCheck 
						@CustID = @RepresentCustID
						, @RoleID		= 2
						, @AgentID		= @_AgentID
						, @MasterID		= @_MasterID
						, @SuperID		= @_SuperID
						, @PT			= @PT
						, @ErrCode		= @ErrCode	OUTPUT
						, @MsgType		= @MsgType	OUTPUT
						, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN		
	
--******************************************Correct PT SETTINGS*************************************** 	
	DECLARE @m3 SMALLMONEY,@us3 SMALLMONEY, @s4 SMALLMONEY
	DECLARE @n2 SMALLMONEY, @l2 SMALLMONEY
	DECLARE @im2 BIT, @um2 SMALLMONEY
	DECLARE @a1 SMALLMONEY, @m1 SMALLMONEY, @s1 SMALLMONEY, @i1 BIT, @u1 SMALLMONEY, @im1 BIT, @um1 SMALLMONEY
	DECLARE @temp1 SMALLMONEY, @temp2 SMALLMONEY, @temp3 SMALLMONEY
	DECLARE @s_new SMALLMONEY, @m_new SMALLMONEY, @a_new SMALLMONEY

	UPDATE cs
		SET @a1 = cs.AgentPT
			,@m1 = cs.MasterPT
			,@s1 = cs.SuperPT
			,@i1 = cs.IsAutoSuperPT
			,@u1 = cs.AutoSuperPT
			,@im1 = cs.IsAutoMasterPT
			,@um1 = cs.AutoMasterPT
			,@um2 = acs.UM2
			,@im2 = acs.IM2
			,@n2 = acs.N2
			,@l2 = acs.L2
			,@m3 = mcs.M3
			,@s4 = scs.S4
			--Adjust a1=min(a1,m3)
			,@a1 = CASE WHEN @a1 > @m3 THEN @m3 ELSE @a1 END
			--Adjust a1= if(im1=0 && im2=0 && m1+a1>m3) then m3-m1
			,@a1 = CASE WHEN @im1 = 0 AND @im2 = 0 AND @m1 + @a1 > @m3 THEN @m3 - @a1 ELSE @a1 END
			--Adjust PT: a1=max(a1,0)
			,@a1 = CASE WHEN @a1 < 0 THEN 0 ELSE @a1 END
			-- rule #1: a1 = max(a1,n2); m1 = (a1<n2) ? m3-n2 : m1 -- agent min
			,@a_new = CASE WHEN @a1 < @n2 THEN @n2 ELSE @a1 END
			,@m_new = CASE WHEN @a1 < @n2 AND @m1 +@n2 > mcs.m3 THEN mcs.m3-@n2 ELSE @m1 END
			,@a1 = @a_new
			,@m1 = @m_new
			-- rule #2: a1 = min(a1,l2) -- agent max                        
			,@a1 = CASE WHEN @a1 > @l2 THEN @l2 ELSE @a1 END			
            -- rule #3: m1 = min(m3-a1,u2) -- Recal AUTO MPT
			,@temp1 = CASE WHEN @im1 = 1 THEN @um1 ELSE @um2 END
			,@m1 = CASE 
						WHEN @im2 = 1 OR @im1 = 1 
						THEN CASE WHEN mcs.m3-@a1 > @temp1 THEN @temp1 ELSE mcs.m3-@a1 END 
						ELSE @m1 
					END
			-- rule #4: m1 = n3-a1 -- check master min/max
			,@m1 = CASE WHEN @a1+@m1 < mcs.n3 THEN mcs.n3-@a1 ELSE @m1 END			
            -- rule #5: UPDATE m1,a1 WHEN m1+a1>l3
			/*	@x1 = min(m3,l3) -- mpt max
				@x2 = max(@x1-a1,0) --mpt
				m1 = (a1+m1>l3) ? @x2 : m1
				@x3 = (a1+@x2 > @x1) ? @x1-@x2 : a1
				a1 = (a1+m1>l1) ? max(@x3, n2) : a1
			*/
			,@temp1 = CASE WHEN mcs.m3 > mcs.l3 THEN mcs.l3 ELSE mcs.m3 END
			,@temp2 = CASE WHEN @temp1-@a1 < 0 THEN 0 ELSE @temp1-@a1 END
			,@m_new = CASE WHEN @a1+@m1 > mcs.l3 THEN @temp2 ELSE @m1 END
			,@temp3 = CASE WHEN @a1+@temp2 > @temp1 THEN @temp1-@temp2 ELSE @a1 END
			,@a_new = CASE 
						WHEN @a1+@m1 > mcs.l3 
						THEN CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
						ELSE @a1 
					END	
			,@m1 = @m_new
			,@a1 = @a_new

			-- rule #6 s1 = min(s4-m1-a1, i1?u1:u3) --Recalculate auto pt
			/*
				@x1 = (i1=1) ? u1 : u3
				s1 = (s4-m1-a1 > @x1) ? @x1 : s4-m1-a1 
			*/
			,@temp1 = CASE WHEN @i1 = 1 THEN @u1 ELSE mcs.US3 END			
			,@s1 = CASE 
						WHEN @i1 = 1 OR mcs.IS3 = 1 
						THEN CASE WHEN scs.s4-@m1-@a1 > @temp1 THEN @temp1 ELSE scs.s4-@m1-@a1 END
						ELSE @s1
					END

            -- rule #7: s1 = max(n4-m1-a1,s1) --super min
			,@s1 = CASE WHEN @a1+@m1+@s1 < scs.n4 THEN scs.n4-@m1-@a1 ELSE @s1 END
            -- rule #8: UPDATE s1,m1,a1 IN case s1+m1+a1>s4
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
			,@temp1 = CASE WHEN scs.s4-@m1-@a1 < 0 THEN 0 ELSE scs.s4-@m1-@a1 END
			,@s_new = CASE WHEN @s1+@a1+@m1 > scs.s4 THEN @temp1 ELSE @s1 END
			,@temp1 = CASE WHEN @temp1+@m1+@a1 > scs.s4 THEN scs.s4-@temp1 ELSE @m1+@a1 END
			,@temp2 = CASE WHEN mcs.m3 > mcs.l3 THEN mcs.l3 ELSE mcs.m3 END
			,@temp2 = CASE WHEN @temp1 > @temp2 THEN @temp2 ELSE @temp1 END
			,@temp2 = CASE WHEN @temp2 < mcs.n3 THEN mcs.n3 ELSE @temp2 END
			,@temp3 = CASE WHEN @temp2-@a1 < 0 THEN 0 ELSE @temp2-@a1 END
			,@m_new = CASE WHEN @s1+@a1+@m1 > scs.s4 THEN @temp3 ELSE @m1 END
			,@temp3 = CASE WHEN @a1+@temp3 > @temp2 THEN @temp2-@temp3 ELSE @a1 END
			,@temp3 = CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
			,@a_new = CASE WHEN @s1+@a1+@m1 > scs.s4 THEN @temp3 ELSE @a1 END
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
	FROM @NewPTTble cs
		INNER JOIN @_SuperPTTbl scs
			ON scs.SportType = cs.SportType
				AND scs.BetType = cs.BetType
				AND scs.IsLive = cs.IsLive
		INNER JOIN @_MasterPTTbl mcs
			ON mcs.SportType = cs.SportType
				AND mcs.BetType = cs.BetType
				AND mcs.IsLive = cs.IsLive
		INNER JOIN @_AgentPTTbl acs
			ON acs.SportType = cs.SportType
				AND acs.BetType = cs.BetType
				AND acs.IsLive = cs.IsLive	
	
--***************************************UPDATE PT SETTINGS*******************************************	
	--**START UPDATING DB**--	
	--Get total members that are different from group
	IF NOT EXISTS (
		SELECT TOP 1 1
		FROM @NewPTTble npt
			INNER JOIN @OldPTTble opt
				ON npt.SportType=opt.SportType
				AND npt.BetType=opt.BetType
				AND npt.IsLive=opt.IsLive
		WHERE (
				npt.SuperPT <> opt.SuperPT
				OR npt.MasterPT <> opt.MasterPT
				OR npt.AgentPT <> opt.AgentPT
	))
		RETURN
	
	SELECT @NoMember = COUNT(1)
	FROM @tblCust
	
	SELECT @NoGroupedMember = COUNT(1)
	FROM dbo.CustSettingMode3rd m WITH(NOLOCK)
		INNER JOIN dbo.custinfo  ci WITH(NOLOCK)
			ON ci.CustID = m.CustID AND ci.RoleID = 1
	WHERE ci.recommend = @_AgentID AND m.Isgrouped = 1
	
	IF 	@NoMember = @NoGroupedMember
	BEGIN
		UPDATE grpt
		SET grpt.SuperPT=npt.SuperPT,
			grpt.MasterPT=npt.MasterPT,
			grpt.AgentPT=npt.AgentPT
		FROM dbo.CustPTGroupSetting3rd_Member grpt WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewPTTble npt 
				ON  npt.SportType=grpt.SportType
				AND npt.BetType=grpt.BetType
				AND npt.IsLive=grpt.IsLive
		WHERE grpt.AgentID=@_AgentID 
			AND (
				npt.SuperPT <> grpt.SuperPT
				OR npt.MasterPT <> grpt.MasterPT
				OR npt.AgentPT <> grpt.AgentPT
			)
	END
	ELSE
	BEGIN
		--Insert Individual Setting for affected custIDs
		INSERT INTO dbo.CustPTSetting3rd_Member
		SELECT
				cust.CustID,
				grpt.SportType,
				grpt.BetType,
				grpt.IsLive,
				grpt.SuperPT,
				grpt.MasterPT,
				grpt.AgentPT,
				grpt.IsAutoMasterPT,
				grpt.AutoMasterPT,
				grpt.IsAutoSuperPT,
				grpt.AutoSuperPT
		FROM @tblCust cust
			CROSS JOIN dbo.CustPTGroupSetting3rd_Member grpt WITH(NOLOCK)
			LEFT JOIN dbo.CustPTSetting3rd_Member mempt
				ON cust.CustID=mempt.CustID
					AND grpt.SportType=mempt.SportType
					AND grpt.BetType=mempt.BetType
					AND grpt.IsLive=mempt.IsLive
		WHERE grpt.AgentID=@_AgentID AND mempt.CustID IS NULL
		
		--Update Adjusted PT for indiviual setting
		UPDATE main
		SET main.SuperPT=npt.SuperPT,
			main.MasterPT=npt.MasterPT,
			main.AgentPT=npt.AgentPT
		FROM dbo.CustPTSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @tblCust cust ON main.CustID=cust.CustID
			INNER JOIN @NewPTTble npt ON  npt.SportType=main.SportType
				AND npt.BetType=main.BetType
				AND npt.IsLive=main.IsLive
		WHERE 
			npt.SuperPT <> main.SuperPT
			OR npt.MasterPT <> main.MasterPT
			OR npt.AgentPT <> main.AgentPT
		
		
		--Update setting mode for affected CustIDs
		UPDATE main
		SET main.IsGrouped=0
		FROM dbo.CustSettingMode3rd main WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @tblCust cust
				ON cust.CustID=main.CustID
	END
	
--***************************************WRITE LOGS*******************************************			
	--**START LOGGING**--

	-- Select ProductID and SettingLevel
	SELECT @ProductID = ProductID, @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM		ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@OldPTTble AS tmp
					ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType
					AND psd.IsLive = tmp.IsLive
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType = 1	-- Position Taking
		 ) iq

	-- Select ProductName
	SELECT @ProductName = p.ProductName
	FROM DBPRO.bodb02.dbo.Products AS p WITH(NOLOCK)
	WHERE p.ProductID = @ProductID

	-- Log old data
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustIDList						AS '@CustIDList',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	@ProductID								AS '@ProductID',
							isLive									AS '@isLive',
							CONVERT(DECIMAL(10,2), AgentPT	/100.0)	AS '@AgentPT'
					FROM @OldPTTble
					FOR XML PATH('PT'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTOnMemberMultiUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustIDList						AS '@CustIDList',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	SportType								AS '@SportType',
							isLive									AS '@isLive',
							CONVERT(DECIMAL(10,2), AgentPT	/100.0)	AS '@AgentPT'
					FROM @OldPTTble
					FOR XML PATH('PT'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTOnMemberMultiUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustIDList						AS '@CustIDList',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	BetType									AS '@BetType',
							isLive									AS '@isLive',
							CONVERT(DECIMAL(10,2), AgentPT	/100.0)	AS '@AgentPT'
					FROM @OldPTTble
					FOR XML PATH('PT'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTOnMemberMultiUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustIDList						AS '@CustIDList',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	SportType								AS '@SportType',
							BetType									AS '@BetType',
							isLive									AS '@isLive',
							CONVERT(DECIMAL(10,2), AgentPT	/100.0)	AS '@AgentPT'
					FROM @OldPTTble
					FOR XML PATH('PT'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTOnMemberMultiUpd'),
		TYPE
	)
	END
	SET @Old_PT_XML = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	-- Log new updated data
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustIDList						AS '@CustIDList',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	@ProductID								AS '@ProductID',
							isLive									AS '@isLive',
							CONVERT(DECIMAL(10,2), AgentPT	/100.0)	AS '@AgentPT'
					FROM dbo.f_DCS_PT_XMLParse(@PT)
					FOR XML PATH('PT'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTOnMemberMultiUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustIDList						AS '@CustIDList',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	SportType								AS '@SportType',
							isLive									AS '@isLive',
							CONVERT(DECIMAL(10,2), AgentPT	/100.0)	AS '@AgentPT'
					FROM dbo.f_DCS_PT_XMLParse(@PT)
					FOR XML PATH('PT'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTOnMemberMultiUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustIDList						AS '@CustIDList',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	BetType									AS '@BetType',
							isLive									AS '@isLive',
							CONVERT(DECIMAL(10,2), AgentPT	/100.0)	AS '@AgentPT'
					FROM dbo.f_DCS_PT_XMLParse(@PT)
					FOR XML PATH('PT'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTOnMemberMultiUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustIDList						AS '@CustIDList',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	SportType								AS '@SportType',
							BetType									AS '@BetType',
							isLive									AS '@isLive',
							CONVERT(DECIMAL(10,2), AgentPT	/100.0)	AS '@AgentPT'
					FROM dbo.f_DCS_PT_XMLParse(@PT)
					FOR XML PATH('PT'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTOnMemberMultiUpd'),
		TYPE
	)
	END
    SET @New_PT_XML = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')	

	SELECT @EndRun	= GETDATE()
		, @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDList		= @CustIDList
			, @SubAccID			= @SubAccID
			, @ActionID			= 450
			, @NewPT_XML		= @New_PT_XML
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDList		= @CustIDList
			, @SubAccID			= @SubAccID
			, @ActionID			= 450
			, @NewPT_XML		= @New_PT_XML
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTOnMemberMultiUpd] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTOnMemberMultiUpd] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTOnMemberMultiUpd] TO [bodbExtAccNet]