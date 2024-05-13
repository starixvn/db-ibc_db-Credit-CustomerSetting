/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_MasterPTOnMember_153_MultiUpd] 
	  @CustIDList		VARCHAR(MAX)
	, @PT				VARCHAR(MAX)
	, @SubAccID			INT				= 0
	, @IP				VARCHAR(50)		= ''
	, @UserID			INT				= 0
	, @isCountPT		BIT				= 1
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(4000)	= ''	OUTPUT
	, @SettingStatus TINYINT = 0
	, @GroupType	SMALLINT = 153
	, @GroupID			TINYINT = 1 -- default SB
AS
/*      
    Created: 20231101@Eden
	Task : Master multiple update grouped member's PT, only for members with isGroupPT = 1
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20231101@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960] 

	Parameter's Explanation:	
	- @PT:  [
			{"SportType": "9914","BetType": "915","IsLive": "0","MasterPT": "38","AutoMasterPT": "38","IsAutoMasterPT": "1"},
			{"SportType": "9914","BetType": "917","IsLive": "0","MasterPT": "38","AutoMasterPT": "38","IsAutoMasterPT": "1"},
			{"SportType": "9913","BetType": "917","IsLive": "1","MasterPT": "38","AutoMasterPT": "38","IsAutoMasterPT": "1"},
			{"SportType": "9915","BetType": "918","IsLive": "0","MasterPT": "38","AutoMasterPT": "38","IsAutoMasterPT": "1"},
			{"SportType": "9913","BetType": "915","IsLive": "1","MasterPT": "38","AutoMasterPT": "38","IsAutoMasterPT": "1"},
			{"SportType": "9913","BetType": "916","IsLive": "1","MasterPT": "38","AutoMasterPT": "38","IsAutoMasterPT": "1"},
			{"SportType": "9914","BetType": "916","IsLive": "0","MasterPT": "38","AutoMasterPT": "38","IsAutoMasterPT": "1"}
		]
*/
BEGIN
	SET NOCOUNT ON
	EXEC Acc_CustSetting_PT_JsonParse @PTSetting = @PT OUTPUT

--******************************************VARIABLE DECLARATION*************************************** 	
	--Logs
	DECLARE @StartRun	DATETIME
		, @EndRun		DATETIME
		, @Duration		INT
	    , @Old_PT_XML	VARCHAR(MAX)
        , @New_PT_XML   VARCHAR(MAX)
		
	--Temp variables for PT adjustment	
	DECLARE @_AgentID		INT
		, @_MasterID		INT
		, @_SuperID			INT
		, @RepresentCustID	INT
		, @RoleID			INT
		, @NoMember			INT = 0
		, @NoGroupedMember	INT = 0
	
	--List of customers	
	DECLARE @tblCust TABLE (CustID INT)
	
	--Temp table variables being used for calculation
	DECLARE @NewPTTble TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, IsLive			BIT
			, SuperPT			SMALLMONEY
			, MasterPT			SMALLMONEY
			, AgentPT			SMALLMONEY
			, IsAutoMasterPT	BIT
			, AutoMasterPT		SMALLMONEY
			, IsAutoSuperPT		BIT
			, AutoSuperPT		SMALLMONEY
			, SettingLevel		TINYINT
			, ProductID			TINYINT
			, Child_DisplayOrder TINYINT
		)
	DECLARE @OldPTTble TABLE (
		   SportType			SMALLINT
			, BetType			SMALLINT
			, IsLive			BIT
			, SuperPT			SMALLMONEY
			, MasterPT			SMALLMONEY
			, AgentPT			SMALLMONEY
			, IsAutoMasterPT	BIT
			, AutoMasterPT		SMALLMONEY
			, IsAutoSuperPT		BIT
			, AutoSuperPT		SMALLMONEY
			, SettingLevel		TINYINT
			, ProductID			TINYINT
			, Child_DisplayOrder TINYINT
		)
		
	--Super PT Setting Values		
	DECLARE @_SuperPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S4				SMALLMONEY  ,
					M4				SMALLMONEY  ,
					A4				SMALLMONEY  ,
					IM4				BIT  ,
					UM4				SMALLMONEY  ,
					IS4				BIT  ,
					US4				SMALLMONEY  ,
					N4				SMALLMONEY  ,
					L4				SMALLMONEY  
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
				
	--Master PT Setting Values
	DECLARE @_MasterPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S3				SMALLMONEY  ,
					M3				SMALLMONEY  ,
					A3				SMALLMONEY  ,
					IM3				BIT  ,
					UM3				SMALLMONEY  ,
					IS3				BIT  ,
					US3				SMALLMONEY  ,
					N3				SMALLMONEY  ,
					L3				SMALLMONEY  
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
				
	--Agent PT Setting Values
	DECLARE @_AgentPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S2				SMALLMONEY  ,
					M2				SMALLMONEY  ,
					A2				SMALLMONEY  ,
					IM2				BIT  ,
					UM2				SMALLMONEY  ,
					IS2				BIT  ,
					US2				SMALLMONEY  ,
					N2				SMALLMONEY  ,
					L2				SMALLMONEY  
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)

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
		
	--Check limit PT update	
	DECLARE @isLimit BIT = 0, @isCancel BIT = 0, @LastUpdated DATE
	IF @GroupID = 3  -- Apply for 3rd products
	BEGIN
		IF @isCountPT = 1
		BEGIN
			EXEC dbo.Age_LimitPTCheck_MultiCust	  @Actorid	= @UserID, 
			  @custIdList			=	@CustIDList,
			  @UpdatePT				=	@PT,
			  @SettingStatus		=   @SettingStatus,
			  @isLimit				=	@isLimit OUTPUT,
			  @isCancel				=	@isCancel OUTPUT,
			  @LastUpdated			=	@LastUpdated OUTPUT

			IF @isCancel > 0	
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="10078" Msg="'+ CAST (@LastUpdated AS VARCHAR(10)) +'"> </Root>'
				  , @ErrCode = 10078
				  , @MsgType = 6   
					RETURN
			END
		END
	END

--******************************************PREPARE SETTING FOR UPDATE*************************************** 	
	--Parse XML
	INSERT @NewPTTble(
		 SportType			
		, BetType			
		, IsLive			
		, SuperPT			
		, MasterPT			
		, AgentPT			
		, IsAutoMasterPT	
		, AutoMasterPT		
		, IsAutoSuperPT		
		, AutoSuperPT	
	)
	SELECT SportType
			,BetType
			,IsLive
			,0
			,MasterPT
			,0
			,IsAutoMasterPT
			,AutoMasterPT
			,0
			,0	
	FROM dbo.f_DCS_PT_XMLParse(@PT)

	--Get line infor : SMA accounts
	SELECT TOP 1 @RepresentCustID=CustID
	FROM @tblCust
	
	DECLARE  @SiteID SMALLINT,
		@Currency SMALLINT	
	
	SELECT  @siteID = s.siteID,
			@Currency = c.currency,
			@_SuperID = c.srecommend,
			@_MasterID = c.mrecommend,
			@_AgentID = c.recommend
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @RepresentCustID
	
	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		Child_DisplayOrder TINYINT,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,Child_DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)
	
	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewPTTble t
		INNER JOIN #ProductSettingDetail ps
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@_AgentID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer

	IF NOT EXISTS( SELECT 1 FROM @NewPTTble)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

		RETURN
	END
	
	UPDATE tmp
	SET tmp.SettingLevel = psd.SettingLevel,
		tmp.ProductID = psd.ProductID,
		tmp.Child_DisplayOrder = psd.Child_DisplayOrder
	FROM @NewPTTble tmp
		INNER JOIN #ProductSettingDetail psd
			ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType
					AND psd.IsLive = tmp.IsLive

	--Get another member settings used for PT calcualtion
	UPDATE main
	SET main.SuperPT = cs.SuperPT
		, main.AgentPT = cs.AgentPT
		, main.IsAutoSuperPT = cs.IsAutoSuperPT
		, main.AutoSuperPT = cs.AutoSuperPT
	FROM @NewPTTble main
		INNER JOIN dbo.CustPTGroupSetting3rd_Member cs WITH (NOLOCK)
			ON cs.SportType = main.SportType
				AND cs.BetType = main.BetType
				AND cs.IsLive = main.IsLive
				AND cs.AgentID = @_AgentID
			
	--Backup old settings for logs
	INSERT @OldPTTble(
		 SportType			
		, BetType			
		, IsLive			
		, SuperPT			
		, MasterPT			
		, AgentPT			
		, IsAutoMasterPT	
		, AutoMasterPT		
		, IsAutoSuperPT		
		, AutoSuperPT	
		, Child_DisplayOrder
	)
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
			, main.Child_DisplayOrder
	FROM @NewPTTble main
		INNER JOIN dbo.CustPTGroupSetting3rd_Member cs WITH (NOLOCK)
			ON cs.SportType=main.SportType
					AND cs.BetType=main.BetType
					AND cs.IsLive=main.IsLive
					AND cs.AgentID=@_AgentID	
	ORDER BY main.Child_DisplayOrder
	
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
	EXEC [dbo].Acc_CustSetting_MemberPT_153_Check 
						@CustID = @RepresentCustID
						, @RoleID		= 3
						, @AgentID		= @_AgentID
						, @MasterID	= @_MasterID
						, @SuperID		= @_SuperID
						, @PT			= @PT
						, @ErrCode		= @ErrCode	OUTPUT
						, @MsgType		= @MsgType  OUTPUT
						, @ErrMsg		= @ErrMsg	OUTPUT
						, @GroupID = @GroupID
						, @GroupType = @GroupType
						, @SettingStatus = @SettingStatus
	IF @ErrCode <> 0
		RETURN		

--******************************************ADJUST PT SETTINGS*************************************** 	
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
			--Adjust: m1=m1+a1>min(m3,m4)?min(m3,m4)-a1:m1
			,@temp1 = CASE WHEN M3 < M4 THEN M3 ELSE M4 END
			,@m1 = CASE WHEN @m1 > @temp1 - @a1 THEN @temp1 - @a1 ELSE @m1 END
			--Adjust: m1=m1+a1<n3?n3-a1:m1
			,@m1 = CASE WHEN N3 - @a1 > @m1 THEN N3 - @a1 ELSE @m1 END
			--Adjust : m1=m1>0?m1:0
			,@m1 = CASE WHEN @m1 > 0 THEN @m1 ELSE 0 END
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
	IF NOT EXISTS (SELECT TOP 1 1
	FROM @NewPTTble npt
		INNER JOIN @OldPTTble opt
			ON npt.SportType=opt.SportType
			AND npt.BetType=opt.BetType
			AND npt.IsLive=opt.IsLive
	WHERE (
		npt.SuperPT <> opt.SuperPT
		OR npt.MasterPT <> opt.MasterPT
		OR npt.AgentPT <> opt.AgentPT
		OR npt.IsAutoMasterPT <> opt.IsAutoMasterPT
		OR npt.AutoMasterPT <> opt.AutoMasterPT
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
			grpt.AgentPT=npt.AgentPT,
			grpt.IsAutoMasterPT=npt.IsAutoMasterPT,
			grpt.AutoMasterPT=npt.AutoMasterPT
		FROM dbo.CustPTGroupSetting3rd_Member grpt WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewPTTble npt ON  npt.SportType=grpt.SportType
						AND npt.BetType=grpt.BetType
						AND npt.IsLive=grpt.IsLive
		WHERE grpt.AgentID=@_AgentID 
			AND (
				npt.SuperPT <> grpt.SuperPT
				OR npt.MasterPT <> grpt.MasterPT
				OR npt.AgentPT <> grpt.AgentPT
				OR npt.IsAutoMasterPT <> grpt.IsAutoMasterPT
				OR npt.AutoMasterPT <> grpt.AutoMasterPT
			)
	END
	ELSE
	BEGIN
		--Insert Individual Setting for affected custIDs
		INSERT INTO dbo.CustPTSetting3rd_Member(					
					   [CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[IsLive]
					   ,[IsAutoMasterPT]
					   ,[IsAutoSuperPT]
					   ,[SuperPT]
					   ,[MasterPT]
					   ,[AgentPT]
					   ,[AutoSuperPT]
					   ,[AutoMasterPT]
					)
		SELECT
			cust.CustID,
			grpt.SportType,
			grpt.BetType,
			grpt.IsLive,						
			grpt.IsAutoMasterPT,
			grpt.IsAutoSuperPT,
			grpt.SuperPT,
			grpt.MasterPT,
			grpt.AgentPT,
			grpt.AutoSuperPT,
			grpt.AutoMasterPT
		FROM @tblCust cust
			CROSS JOIN dbo.CustPTGroupSetting3rd_Member grpt WITH(NOLOCK)
			LEFT JOIN dbo.CustPTSetting3rd_Member mempt WITH(NOLOCK)
				ON cust.CustID=mempt.CustID
					AND grpt.SportType=mempt.SportType
					AND grpt.BetType=mempt.BetType
					AND grpt.IsLive=mempt.IsLive
		WHERE grpt.AgentID=@_AgentID AND mempt.CustID IS NULL
		
		--Update Adjusted PT for indiviual setting
		UPDATE main
		SET main.SuperPT=npt.SuperPT,
			main.MasterPT=npt.MasterPT,
			main.AgentPT=npt.AgentPT,
			main.IsAutoMasterPT=npt.IsAutoMasterPT,
			main.AutoMasterPT=npt.AutoMasterPT
		FROM dbo.CustPTSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @tblCust cust ON main.CustID=cust.CustID
			INNER JOIN @NewPTTble npt ON  npt.SportType=main.SportType
						AND npt.BetType=main.BetType
						AND npt.IsLive=main.IsLive
		WHERE 
			npt.SuperPT <> main.SuperPT
			OR npt.MasterPT <> main.MasterPT
			OR npt.AgentPT <> main.AgentPT
			OR npt.IsAutoMasterPT <> main.IsAutoMasterPT
			OR npt.AutoMasterPT <> main.AutoMasterPT
		
		
		--Update setting mode for affected CustIDs
		UPDATE main
		SET main.IsGrouped=0
		FROM dbo.CustSettingMode3rd main WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @tblCust cust
				ON cust.CustID=main.CustID
	END	

--***************************************WRITE LOGS*******************************************		
	--**START LOGGING**--
	-- Log old data
	SET @xml = (
		SELECT	@CustIDList						AS '@CustIDList',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	@GroupID									AS '@GroupID',
							ProductID									AS '@ProductID',
							SportType									AS '@SportType',
							BetType										AS '@BetType',
							isLive										AS '@isLive',
							dbo.f_FomatNumericToChar(MasterPT		/100.0)	AS '@MasterPT',
							IsAutoMasterPT								AS '@IsAutoMasterPT',
							dbo.f_FomatNumericToChar(AutoMasterPT	/100.0)	AS '@AutoMasterPT',
							t.SettingLevel									AS '@SettingLevel'
					FROM @OldPTTble t
					ORDER BY Child_DisplayOrder
					FOR XML PATH('PT'),
					TYPE
				)
		FOR XML PATH('ROOT'),
		TYPE
	)
	
	SET @Old_PT_XML = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	-- Log new updated data
	SET @xml = (
		SELECT	@CustIDList						AS '@CustIDList',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	@GroupID									AS '@GroupID',
							ProductID									AS '@ProductID',
							SportType									AS '@SportType',
							BetType										AS '@BetType',
							isLive										AS '@isLive',
							dbo.f_FomatNumericToChar(MasterPT		/100.0)	AS '@MasterPT',
							IsAutoMasterPT								AS '@IsAutoMasterPT',
							dbo.f_FomatNumericToChar(AutoMasterPT	/100.0)	AS '@AutoMasterPT',
							t.SettingLevel									AS '@SettingLevel'
					FROM @NewPTTble t
					ORDER BY Child_DisplayOrder
					FOR XML PATH('PT'),
					TYPE
				)
		FOR XML PATH('ROOT'),
		TYPE
	)

    SET @New_PT_XML = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @Old_PT_XML = LogStr 
	FROM f_CustSetting_FormatLog (@Old_PT_XML)
	SELECT @New_PT_XML = LogStr 
	FROM f_CustSetting_FormatLog (@New_PT_XML)

	SELECT @EndRun	= GETDATE()
		, @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	DECLARE @ActionID INT

	SELECT @ActionID = CASE WHEN @GroupID = 1 THEN 514 -- SB
								ELSE 526 -- 3rdProducts
							END
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDList		= @CustIDList
			, @SubAccID			= @SubAccID
			, @ActionID			= @ActionID
			, @NewPT_XML		= @New_PT_XML
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDList		= @CustIDList
			, @SubAccID			= @SubAccID
			, @ActionID			= @ActionID
			, @NewPT_XML		= @New_PT_XML
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END CATCH

	DROP TABLE #ProductSettingDetail

--***************************************UPDATE CUSTOMERS LIMIT PT***************************************
	IF @isLimit > 0
	BEGIN
		EXEC dbo.Age_LimitPTUpd_MultiCust 
			  @Actorid			= @UserID
			, @CustIDList		= @CustIDList
			, @UpdatePT			= @PT
			, @SettingStatus		= @SettingStatus
			, @ErrCode			= @ErrCode OUTPUT
			, @ErrMsg			= @ErrMsg OUTPUT
		IF @ErrCode > 0
			RETURN
	END
END
