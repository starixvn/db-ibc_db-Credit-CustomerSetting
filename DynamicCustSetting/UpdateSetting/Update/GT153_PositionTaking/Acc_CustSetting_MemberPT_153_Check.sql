/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_MemberPT_153_Check] 
	  @CustID			INT 
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @PT				VARCHAR(MAX)
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(4000)	= ''	OUTPUT
	, @GroupID TINYINT = 1
	, @GroupType SMALLINT = 153
	, @SettingStatus TINYINT = 0
AS
/*
	Created: 20231101@Eden
	Task : Check Member's PT when SMA update member
	DB: DBCUST/CustDB
	Original:

	Revision:
	- 20231101@Eden: DCS Sportsbook Credit[redmine: #193083]
	- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 

	Param's Explanation:
	- @PT:
				<ROOT>
						<PT 
								SportType="1" 
								BetType="1" 
								IsLive="1" 
								SuperPT="10"
								MasterPT="10"
								AgentPT="10" 
								IsAutoSuperPT="1"
								AutoSuperPT="10"
								IsAutoMasterPT="1"
								AutoMasterPT="10"
								
						/>
				</ROOT>
*/
BEGIN
	SET NOCOUNT ON
	
--******************************************VARIABLE DECLARATION*************************************** 
	DECLARE @ErrInfo	XML
		
	SELECT @ErrCode = 0
		, @ErrMsg = ''
		, @MsgType = 0
		
	SELECT @ErrInfo = ''
		
	DECLARE @NewPTTble TABLE (
		  SportType			SMALLINT
		, BetType			SMALLINT
		, IsLive			BIT
		, SuperPT			SMALLMONEY
		, MasterPT			SMALLMONEY
		, AgentPT			SMALLMONEY
		, AgentPT_Max		SMALLMONEY
		, AgentAPT_Max		SMALLMONEY
		, IsAutoMasterPT	BIT
		, AutoMasterPT		SMALLMONEY
		, IsAutoSuperPT		BIT
		, AutoSuperPT		SMALLMONEY
		, Old_IsAutoMasterPT BIT
		, [ProductID] [tinyint]
		, [SettingLevel] [tinyint]
		)

	DECLARE @UplinePT TABLE (
		 CustID		int
		,SportType	smallint
		,BetType	smallint
		,IsLive		bit
		,IsAutoMasterPT	bit
		,IsAutoSuperPT	bit
		,SuperPT		smallmoney
		,MasterPT		smallmoney
		,AgentPT		smallmoney
		,AutoSuperPT	smallmoney
		,AutoMasterPT	smallmoney
		,MinPT			smallmoney
		,MaxPT			smallmoney
		)
		
	DECLARE @IsGrouped BIT = 0

--******************************************PARSE INPUT SETTINGS*************************************** 	
	INSERT @NewPTTble( SportType			
		, BetType			
		, IsLive			
		, SuperPT			
		, MasterPT			
		, AgentPT			
		, AgentPT_Max		
		, AgentAPT_Max		
		, IsAutoMasterPT	
		, AutoMasterPT		
		, IsAutoSuperPT		
		, AutoSuperPT		
		, Old_IsAutoMasterPT)
	SELECT SportType 
		, BetType 
		, IsLive 
		, SuperPT 
		, MasterPT 
		, AgentPT 
		, 0 
		, 0 
		, IsAutoMasterPT 
		, AutoMasterPT 
		, IsAutoSuperPT 
		, AutoSuperPT 
		, NULL Old_IsAutoMasterPT
	FROM dbo.f_DCS_PT_XMLParse(@PT)

	DECLARE  @SiteID SMALLINT,
		@Currency SMALLINT	
	
	SELECT  @siteID = s.siteID,
			@Currency = c.currency
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid
	
	CREATE TABLE #ProductSettingDetail_MemCheck(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		[MaxPT]	[smallmoney],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_MemCheck(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewPTTble t
		INNER JOIN #ProductSettingDetail_MemCheck ps 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer

	UPDATE t
	SET t.SettingLevel = ps.SettingLevel,
		t.ProductID = ps.ProductID
	FROM @NewPTTble t
		INNER JOIN #ProductSettingDetail_MemCheck ps 
			ON ps.BetType = t.BetType 
			AND ps.SportType = t.SportType 
			AND ps.IsLive = t.IsLive


--******************************************START CHECKING SETTINGS*************************************** 	
	--Get member's PT Setting Mode
	SELECT @IsGrouped=IsGrouped
	FROM dbo.CustSettingMode3rd WITH(NOLOCK)
	WHERE CustID=@CustID

	IF @AgentID IN(-4,-3)
	BEGIN
		SET @IsGrouped = 0

		IF @AgentID = -4 --Super edit super direct member
		BEGIN
			UPDATE t
			SET  t.IsAutoSuperPT = 0
				,t.AutoSuperPT = 0
				,t.MasterPT = 0
				,t.IsAutoMasterPT = 0
				,t.AutoMasterPT = 0
				,t.AgentPT = 0
			FROM @NewPTTble t
		END
		ELSE -- Super/master edit master direct member
		BEGIN
			UPDATE t
			SET t.IsAutoMasterPT = 0
				,t.AutoMasterPT = 0
				,t.AgentPT = 0
			FROM @NewPTTble t
		END
	END
			
	IF @RoleID = 2 --When Agent update members
	BEGIN
		--Get member's setting to be adjusted
		IF @IsGrouped = 1
		BEGIN
			--Get Grouped setting values
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
							AND cs.AgentID=@AgentID
		END
		ELSE
		BEGIN
			--Get individual setting values
			UPDATE main
			SET  main.SuperPT = cs.SuperPT
				, main.MasterPT = cs.MasterPT
				, main.IsAutoSuperPT =cs.IsAutoSuperPT
				, main.AutoSuperPT = cs.AutoSuperPT
				, main.IsAutoMasterPT = cs.IsAutoMasterPT
				, main.AutoMasterPT = cs.AutoMasterPT
			FROM @NewPTTble main
				INNER JOIN dbo.CustPTSetting3rd_Member cs WITH (NOLOCK)
					ON cs.SportType=main.SportType
							AND cs.BetType=main.BetType
							AND cs.IsLive=main.IsLive
							AND cs.CustID=@CustID
		END
	
		--Check range: 0 <= PT <= Defaul Max PT 	
		SELECT @ErrInfo = (
							SELECT pdt.SportType,pdt.BetType,pdt.IsLive, mempt.ProductID, mempt.SettingLevel
							FROM @NewPTTble mempt
								INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
									ON pdt.SportType=mempt.SportType
										AND pdt.BetType=mempt.BetType
										AND pdt.IsLive=mempt.IsLive
							WHERE mempt.AgentPT < 0 OR mempt.AgentPT > pdt.MaxPT
							FOR XML RAW('Row'), TYPE
						)	

		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 101
                    , @MsgType = 5                                    
            RETURN
        END	
		
		--Check n2<=a1<=a2
		SELECT @ErrInfo = (
							SELECT pdt.SportType,pdt.BetType,pdt.IsLive,apt.MinPT,apt.AgentPT AS MaxPT, mempt.ProductID, mempt.SettingLevel
							FROM @NewPTTble mempt
								INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH (NOLOCK)
									ON apt.SportType=mempt.SportType
											AND apt.BetType=mempt.BetType
											AND apt.IsLive=mempt.IsLive
											AND apt.CustID=@AgentID
								INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
									ON pdt.SportType = mempt.SportType
										AND pdt.BetType = mempt.BetType
										AND pdt.IsLive = mempt.IsLive
							WHERE mempt.AgentPT > apt.AgentPT OR mempt.AgentPT < apt.MinPT
							FOR XML RAW('Row'), TYPE
		)
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20033" Msg="The position taking violates Agent Min/Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 102
                    , @MsgType = 4                                    
            RETURN
        END	
		
		--Check a1<=min(a2,a4)
		SELECT @ErrInfo = (
						SELECT pdt.SportType,pdt.BetType,pdt.IsLive,
								CASE 
										WHEN spt.AgentPT > apt.AgentPT THEN apt.AgentPT
										ELSE spt.AgentPT
								END AS MaxPT, mempt.ProductID, mempt.SettingLevel
						FROM @NewPTTble mempt
							INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
								ON spt.SportType=mempt.SportType
										AND spt.BetType=mempt.BetType
										AND spt.IsLive=mempt.IsLive
										AND spt.CustID=@SuperID
							INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH (NOLOCK)
								ON apt.SportType=mempt.SportType
										AND apt.BetType=mempt.BetType
										AND apt.IsLive=mempt.IsLive
										AND apt.CustID=@AgentID
							INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
								ON pdt.SportType = mempt.SportType
									AND pdt.BetType = mempt.BetType
									AND pdt.IsLive = mempt.IsLive
						WHERE  mempt.AgentPT > CASE WHEN spt.AgentPT > apt.AgentPT THEN apt.AgentPT
													ELSE spt.AgentPT
												END
						FOR XML RAW('Row'), TYPE
				)
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20034" Msg="The position taking violates Agent Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 103
                    , @MsgType = 3                                    
            RETURN
        END	
		
		--Get min(a4,a2,l2)
		UPDATE main
		SET AgentPT_Max = CASE
								WHEN apt.AgentPT <= apt.MaxPT AND apt.AgentPT <= spt.AgentPT THEN apt.AgentPT
								WHEN apt.MaxPT <= apt.AgentPT AND apt.MaxPT <= spt.AgentPT THEN apt.MaxPT
								ELSE spt.AgentPT
						END
		FROM @NewPTTble main
			INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH (NOLOCK)
				ON apt.SportType=main.SportType
						AND apt.BetType=main.BetType
						AND apt.IsLive=main.IsLive
						AND apt.CustID=@AgentID 
			INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
				ON spt.SportType=main.SportType
						AND spt.BetType=main.BetType
						AND spt.IsLive=main.IsLive
						AND spt.CustID=@SuperID
				
		--Get iff(im,a2:iif(i1|i3,m3-m1,min(m3-m1,s4-s1-m1)))
		UPDATE main
		SET AgentAPT_Max = CASE 
								WHEN (
										apt.IsAutoMasterPT = 1
										OR main.IsAutoMasterPT = 1
										)
									THEN apt.AgentPT
								ELSE CASE 
										WHEN NOT (
												main.IsAutoSuperPT = 0
												AND mpt.IsAutoSuperPT = 0
												)
											THEN mpt.MasterPT - main.MasterPT
										ELSE CASE 
												WHEN mpt.MasterPT - main.MasterPT <= spt.SuperPT - main.SuperPT - main.MasterPT
													THEN mpt.MasterPT - main.MasterPT
												ELSE spt.SuperPT - main.SuperPT - main.MasterPT
												END
										END
								END
		FROM @NewPTTble main
			INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH (NOLOCK)
				ON apt.SportType=main.SportType
						AND apt.BetType=main.BetType
						AND apt.IsLive=main.IsLive
						AND apt.CustID=@AgentID 
			INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
				ON mpt.SportType=main.SportType
						AND mpt.BetType=main.BetType
						AND mpt.IsLive=main.IsLive
						AND mpt.CustID=@MasterID
			INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
				ON spt.SportType=main.SportType
						AND spt.BetType=main.BetType
						AND spt.IsLive=main.IsLive
						AND spt.CustID=@SuperID
		
		--Get a1_max
		UPDATE @NewPTTble
		SET AgentPT_Max = CASE WHEN AgentPT_Max <= AgentAPT_Max THEN AgentPT_Max ELSE AgentAPT_Max END
		
		
		--check a1 <= min(a4,a2,l2, im2=1|im1=1 ? a2 : is1=1|is3=1 ? m3-m1 : min(m3-m1, s4-s1-m1))
		SELECT @ErrInfo = ''
		SELECT @ErrInfo = (
							SELECT pdt.SportType,pdt.BetType,pdt.IsLive,mempt.AgentPT_Max AS MaxPT, mempt.ProductID, mempt.SettingLevel
							FROM @NewPTTble mempt 
								INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
									ON pdt.SportType = mempt.SportType
										AND pdt.BetType = mempt.BetType
										AND pdt.IsLive = mempt.IsLive
							WHERE mempt.AgentPT > mempt.AgentPT_Max
							FOR XML RAW('Row'), TYPE)
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20034" Msg="The position taking violates Agent Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 104
                    , @MsgType = 3                                    
            RETURN
        END	
	END
	ELSE IF @RoleID=3 --When Master update members
	BEGIN
		--Get member's setting to be adjusted
		IF @IsGrouped = 1
		BEGIN
			--Get grouped setting values
			UPDATE main
			SET  main.SuperPT = cs.SuperPT
				, main.AgentPT = cs.AgentPT
				, main.IsAutoSuperPT =cs.IsAutoSuperPT
				, main.AutoSuperPT = cs.AutoSuperPT
				, main.Old_IsAutoMasterPT = cs.IsAutoMasterPT
			FROM @NewPTTble main
				INNER JOIN dbo.CustPTGroupSetting3rd_Member cs WITH (NOLOCK)
					ON cs.SportType=main.SportType
							AND cs.BetType=main.BetType
							AND cs.IsLive=main.IsLive
							AND cs.AgentID=@AgentID
		END
		ELSE
		BEGIN
			--Get individual setting values
			UPDATE main
			SET  main.SuperPT = cs.SuperPT
				, main.AgentPT = cs.AgentPT
				, main.IsAutoSuperPT =cs.IsAutoSuperPT
				, main.AutoSuperPT = cs.AutoSuperPT
				, main.Old_IsAutoMasterPT = cs.IsAutoMasterPT
			FROM @NewPTTble main
				INNER JOIN dbo.CustPTSetting3rd_Member cs WITH (NOLOCK)
					ON cs.SportType=main.SportType
							AND cs.BetType=main.BetType
							AND cs.IsLive=main.IsLive
							AND cs.CustID=@CustID
		END
		
		
		--Check range : 
		SELECT @ErrInfo = (
					SELECT pdt.SportType,pdt.BetType,pdt.IsLive, mempt.ProductID, mempt.SettingLevel
					FROM @NewPTTble mempt
						INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
							ON pdt.SportType = mempt.SportType
								AND pdt.BetType = mempt.BetType
								AND pdt.IsLive = mempt.IsLive
					WHERE mempt.MasterPT < 0 OR mempt.MasterPT > pdt.MaxPT
						OR mempt.AutoMasterPT < 0 OR mempt.AutoMasterPT > pdt.MaxPT
					FOR XML RAW('Row'), TYPE)	
					
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 105
                    , @MsgType = 5                                    
            RETURN
        END	
		
		IF EXISTS(SELECT 1
				FROM @NewPTTble mempt
				WHERE IsAutoMasterPT = 1 
					AND Old_IsAutoMasterPT = 0 	
				)
			AND EXISTS (SELECT 1 FROM CustMaster WITH(NOLOCK) 
						WHERE custid = @MasterID
							AND DisableAutoMPT = 1)
		BEGIN
			SELECT @ErrCode = 120,
				   @ErrMsg = '<Root MsgID="20044" Msg="You are not allowed to have Auto PT, please contact your upline." />',
				   @MsgType = 5
			RETURN					
		END			
		
		--if im1=1 then um1<=l3
		SELECT @ErrInfo = (
					SELECT pdt.SportType,pdt.BetType,pdt.IsLive,
							mpt.MaxPT, mempt.ProductID, mempt.SettingLevel
					FROM @NewPTTble mempt
						INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
							ON mpt.SportType=mempt.SportType
									AND mpt.BetType=mempt.BetType
									AND mpt.IsLive=mempt.IsLive
									AND mpt.CustID=@MasterID
						INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
							ON pdt.SportType = mempt.SportType
								AND pdt.BetType = mempt.BetType
								AND pdt.IsLive = mempt.IsLive
					WHERE mempt.IsAutoMasterPT = 1
							AND mempt.AutoMasterPT > mpt.MaxPT
					FOR XML RAW('Row'), TYPE)
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 106
                    , @MsgType = 3                                    
            RETURN
        END	
		
		--if im1=1 then um1<=min(m3,m4)
		SELECT @ErrInfo =(
				SELECT pdt.SportType,pdt.BetType,pdt.IsLive,
						CASE WHEN mpt.MasterPT < spt.MasterPT THEN mpt.MasterPT ELSE spt.MasterPT END AS MaxPT
						, mempt.ProductID, mempt.SettingLevel
				FROM @NewPTTble mempt
					INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
						ON mpt.SportType=mempt.SportType
								AND mpt.BetType=mempt.BetType
								AND mpt.IsLive=mempt.IsLive
								AND mpt.CustID=@MasterID
					INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
						ON spt.SportType=mempt.SportType
								AND spt.BetType=mempt.BetType
								AND spt.IsLive=mempt.IsLive
								AND spt.CustID=@SuperID
					INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
						ON pdt.SportType = mempt.SportType
							AND pdt.BetType = mempt.BetType
							AND pdt.IsLive = mempt.IsLive
				WHERE mempt.IsAutoMasterPT = 1 
					AND mempt.AutoMasterPT > CASE WHEN mpt.MasterPT < spt.MasterPT THEN mpt.MasterPT ELSE spt.MasterPT END
				FOR XML RAW('Row'), TYPE)	
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 107
                    , @MsgType = 3                                    
            RETURN
        END	
		
		--if im1=1 then um1>= max(n3 - a1,0)
		SELECT @ErrInfo =(
			SELECT pdt.SportType,pdt.BetType,pdt.IsLive,
					CASE WHEN mpt.MinPT + (-1)*mempt.AgentPT < 0 THEN 0 ELSE mpt.MinPT - mempt.AgentPT END AS MinPT
					, mempt.ProductID, mempt.SettingLevel
			FROM @NewPTTble mempt
				INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
					ON mpt.SportType=mempt.SportType
							AND mpt.BetType=mempt.BetType
							AND mpt.IsLive=mempt.IsLive
							AND mpt.CustID=@MasterID
				INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
					ON pdt.SportType = mempt.SportType
						AND pdt.BetType = mempt.BetType
						AND pdt.IsLive = mempt.IsLive
			WHERE mempt.IsAutoMasterPT=1 
				AND mempt.AutoMasterPT<CASE WHEN mpt.MinPT + (-1)*mempt.AgentPT < 0 THEN 0 ELSE mpt.MinPT - mempt.AgentPT END
			FOR XML RAW('Row'), TYPE)
			
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20032" Msg="The position taking violates Master Min PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 108
                    , @MsgType = 2                                    
            RETURN
        END	
		
		--m1<=min(m3,m4)
		SELECT @ErrInfo = (
				SELECT pdt.SportType,pdt.BetType,pdt.IsLive,
						CASE WHEN mpt.MasterPT < spt.MasterPT THEN mpt.MasterPT ELSE spt.MasterPT END AS MaxPT
						, mempt.ProductID, mempt.SettingLevel
				FROM @NewPTTble mempt
					INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
						ON mpt.SportType=mempt.SportType
								AND mpt.BetType=mempt.BetType
								AND mpt.IsLive=mempt.IsLive
								AND mpt.CustID=@MasterID
					INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
						ON spt.SportType=mempt.SportType
								AND spt.BetType=mempt.BetType
								AND spt.IsLive=mempt.IsLive
								AND spt.CustID=@SuperID
					INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
						ON pdt.SportType = mempt.SportType
							AND pdt.BetType = mempt.BetType
							AND pdt.IsLive = mempt.IsLive	
				WHERE mempt.MasterPT>CASE WHEN mpt.MasterPT < spt.MasterPT THEN mpt.MasterPT ELSE spt.MasterPT END
				FOR XML RAW('Row'), TYPE)
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 109
                    , @MsgType = 3                                    
            RETURN
        END	
			
			
		--m1<=l3
		SELECT @ErrInfo = (
							SELECT pdt.SportType,pdt.BetType,pdt.IsLive,mpt.MaxPT, mempt.ProductID, mempt.SettingLevel
							FROM @NewPTTble mempt
								INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
									ON mpt.SportType=mempt.SportType
											AND mpt.BetType=mempt.BetType
											AND mpt.IsLive=mempt.IsLive
											AND mpt.CustID=@MasterID
								INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
									ON pdt.SportType = mempt.SportType
										AND pdt.BetType = mempt.BetType
										AND pdt.IsLive = mempt.IsLive	
							WHERE mempt.MasterPT>mpt.MaxPT
							FOR XML RAW('Row'), TYPE)
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 110
                    , @MsgType = 3                                    
            RETURN
        END	

		-----------get Upline PT----------
		INSERT INTO @UplinePT(
			 CustID			
			,SportType		
			,BetType		
			,IsLive			
			,IsAutoMasterPT	
			,IsAutoSuperPT	
			,SuperPT		
			,MasterPT		
			,AgentPT		
			,AutoSuperPT	
			,AutoMasterPT	
			,MinPT			
			,MaxPT			
		)
		SELECT  ISNULL(a.CustID,@AgentID)
			,t.SportType 
		    ,t.BetType  
		    ,t.IsLive
			,ISNULL(a.IsAutoMasterPT,0)
			,ISNULL(a.IsAutoSuperPT,0)
			,ISNULL(a.SuperPT,0)
			,ISNULL(a.MasterPT,0)
			,ISNULL(a.AgentPT,0)
			,ISNULL(a.AutoSuperPT,0)
			,ISNULL(a.AutoMasterPT,0)
			,ISNULL(a.MinPT,0)
			,ISNULL(a.MaxPT,100) 
		FROM @NewPTTble t
			LEFT JOIN dbo.CustPTSetting3rd_Agent a WITH (NOLOCK)
				ON t.SportType = a.SportType
				AND t.BetType = a.BetType
				AND t.IsLive = a.IsLive
				AND a.custid = @AgentID
		
		--if im1=0 and im2=0 then m1<=m3-a1
		SELECT @ErrInfo = (
							SELECT pdt.SportType,pdt.BetType,pdt.IsLive,
									mpt.MasterPT - mempt.AgentPT AS MaxPT
									, mempt.ProductID, mempt.SettingLevel
							FROM @NewPTTble mempt
								INNER JOIN @UplinePT apt 
									ON apt.SportType=mempt.SportType
											AND apt.BetType=mempt.BetType
											AND apt.IsLive=mempt.IsLive
											AND apt.CustID=@AgentID
								INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
									ON mpt.SportType=mempt.SportType
											AND mpt.BetType=mempt.BetType
											AND mpt.IsLive=mempt.IsLive
											AND mpt.CustID=@MasterID
								INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
									ON pdt.SportType = mempt.SportType
										AND pdt.BetType = mempt.BetType
										AND pdt.IsLive = mempt.IsLive	
							WHERE mempt.MasterPT > mpt.MasterPT - mempt.AgentPT 
									AND mempt.IsAutoMasterPT = 0 
									AND apt.IsAutoMasterPT = 0
							FOR XML RAW('Row'), TYPE)
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 111
                    , @MsgType = 3                                    
            RETURN
        END	
			
		--if im2=0 and im1=0 then m1>=max(n3 - a1,0)	
		SELECT @ErrInfo = (
							SELECT pdt.SportType,pdt.BetType,pdt.IsLive,
								CASE WHEN mpt.MinPT + (-1)*mempt.AgentPT < 0 THEN 0 ELSE mpt.MinPT - mempt.AgentPT END  AS MinPT
								, mempt.ProductID, mempt.SettingLevel
							FROM @NewPTTble mempt
								INNER JOIN @UplinePT apt 
									ON apt.SportType=mempt.SportType
											AND apt.BetType=mempt.BetType
											AND apt.IsLive=mempt.IsLive
											AND apt.CustID=@AgentID
								INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
									ON mpt.SportType=mempt.SportType
											AND mpt.BetType=mempt.BetType
											AND mpt.IsLive=mempt.IsLive
											AND mpt.CustID=@MasterID
								INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
									ON pdt.SportType = mempt.SportType
										AND pdt.BetType = mempt.BetType
										AND pdt.IsLive = mempt.IsLive	
							WHERE mempt.MasterPT < CASE WHEN mpt.MinPT + (-1)*mempt.AgentPT < 0 THEN 0 ELSE mpt.MinPT - mempt.AgentPT END 
								AND mempt.IsAutoMasterPT = 0 and apt.IsAutoMasterPT = 0	
							FOR XML RAW('Row'), TYPE)
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20032" Msg="The position taking violates Master Min PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 112
                    , @MsgType = 2                                    
            RETURN
        END	
		
	END
	ELSE IF @RoleID = 4 --When Super update members
	BEGIN
		--Get member's setting to be adjusted
		IF @IsGrouped = 1
		BEGIN
			--Get grouped setting values
			UPDATE main
			SET  main.MasterPT = cs.MasterPT
				, main.AgentPT = cs.AgentPT
				, main.IsAutoMasterPT =cs.IsAutoMasterPT
				, main.AutoMasterPT = cs.AutoMasterPT
			FROM @NewPTTble main
				INNER JOIN dbo.CustPTGroupSetting3rd_Member cs WITH (NOLOCK)
					ON cs.SportType=main.SportType
							AND cs.BetType=main.BetType
							AND cs.IsLive=main.IsLive
							AND cs.AgentID=@AgentID
		END
		ELSE
		BEGIN
			--Get individual setting values
			UPDATE main
			SET  main.MasterPT = cs.MasterPT
				, main.AgentPT = cs.AgentPT
				, main.IsAutoMasterPT =cs.IsAutoMasterPT
				, main.AutoMasterPT = cs.AutoMasterPT
			FROM @NewPTTble main
				INNER JOIN dbo.CustPTSetting3rd_Member cs WITH (NOLOCK)
					ON cs.SportType=main.SportType
							AND cs.BetType=main.BetType
							AND cs.IsLive=main.IsLive
							AND cs.CustID=@CustID
		END
		
		--Check range
		SELECT @ErrInfo = (
							SELECT pdt.SportType,pdt.BetType,pdt.IsLive, mempt.ProductID, mempt.SettingLevel
							FROM @NewPTTble mempt
								INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
									ON pdt.SportType = mempt.SportType
										AND pdt.BetType = mempt.BetType
										AND pdt.IsLive = mempt.IsLive	
							WHERE mempt.SuperPT < 0 OR mempt.SuperPT > pdt.MaxPT
								OR mempt.AutoSuperPT < 0 OR mempt.AutoSuperPT > pdt.MaxPT
							FOR XML RAW('Row'), TYPE)
			
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 113
                    , @MsgType = 5                                    
            RETURN
        END	
		
		
		--if is1=1 then us1<=l4
		SELECT @ErrInfo = (
			SELECT pdt.SportType,pdt.BetType,pdt.IsLive,spt.MaxPT, mempt.ProductID, mempt.SettingLevel
			FROM @NewPTTble mempt
				INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
					ON spt.SportType=mempt.SportType
							AND spt.BetType=mempt.BetType
							AND spt.IsLive=mempt.IsLive
							AND spt.CustID=@SuperID
				INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
					ON pdt.SportType = mempt.SportType
						AND pdt.BetType = mempt.BetType
						AND pdt.IsLive = mempt.IsLive
			WHERE mempt.IsAutoSuperPT = 1 AND mempt.AutoSuperPT > spt.MaxPT
			FOR XML RAW('Row'), TYPE)
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20028" Msg="The position taking violates Super Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 114
                    , @MsgType = 3                                    
            RETURN
        END	
			
		--if is1=1 then us1<=s4
		SELECT @ErrInfo = (
							SELECT pdt.SportType,pdt.BetType,pdt.IsLive,spt.SuperPT AS MaxPT, mempt.ProductID, mempt.SettingLevel
							FROM @NewPTTble mempt
								INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
									ON spt.SportType=mempt.SportType
											AND spt.BetType=mempt.BetType
											AND spt.IsLive=mempt.IsLive
											AND spt.CustID=@SuperID
								INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
									ON pdt.SportType = mempt.SportType
										AND pdt.BetType = mempt.BetType
										AND pdt.IsLive = mempt.IsLive
							WHERE mempt.IsAutoSuperPT = 1 AND mempt.AutoSuperPT > spt.SuperPT 
							FOR XML RAW('Row'), TYPE)
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20028" Msg="The position taking violates Super Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 115
                    , @MsgType = 3                                    
            RETURN
        END	
		
		--if is1=1 then us1>=max(n4-m1-a1,0)
		SELECT @ErrInfo = (
							SELECT pdt.SportType,pdt.BetType,pdt.IsLive,
									CASE WHEN spt.MinPT-mempt.MasterPT-mempt.AgentPT > 0 
																THEN spt.MinPT-mempt.MasterPT-mempt.AgentPT 
																ELSE 0
																END	 AS MinPT
									, mempt.ProductID, mempt.SettingLevel
							FROM @NewPTTble mempt
								INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
									ON spt.SportType=mempt.SportType
											AND spt.BetType=mempt.BetType
											AND spt.IsLive=mempt.IsLive
											AND spt.CustID=@SuperID
								INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
									ON pdt.SportType = mempt.SportType
										AND pdt.BetType = mempt.BetType
										AND pdt.IsLive = mempt.IsLive
							WHERE mempt.IsAutoSuperPT = 1 
								AND mempt.AutoSuperPT < CASE WHEN spt.MinPT > mempt.MasterPT+mempt.AgentPT 
																THEN spt.MinPT-mempt.MasterPT-mempt.AgentPT 
																ELSE 0
																END	
							FOR XML RAW('Row'), TYPE)
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20029" Msg="The position taking violates Super Min PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 116
                    , @MsgType = 2                                    
            RETURN
        END		
		
		
		--s1<=s4
		SELECT @ErrInfo = (
							SELECT pdt.SportType,pdt.BetType,pdt.IsLive,spt.SuperPT AS MaxPT, mempt.ProductID, mempt.SettingLevel
							FROM @NewPTTble mempt
								INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
									ON spt.SportType=mempt.SportType
											AND spt.BetType=mempt.BetType
											AND spt.IsLive=mempt.IsLive
											AND spt.CustID=@SuperID
								INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
									ON pdt.SportType = mempt.SportType
										AND pdt.BetType = mempt.BetType
										AND pdt.IsLive = mempt.IsLive
							WHERE mempt.SuperPT > spt.SuperPT
							FOR XML RAW('Row'), TYPE)
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20028" Msg="The position taking violates Super Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 117
                    , @MsgType = 3                                    
            RETURN
        END	

		-----------get Upline PT----------
		INSERT INTO @UplinePT(
			 CustID			
			,SportType		
			,BetType		
			,IsLive			
			,IsAutoMasterPT	
			,IsAutoSuperPT	
			,SuperPT		
			,MasterPT		
			,AgentPT		
			,AutoSuperPT	
			,AutoMasterPT	
			,MinPT			
			,MaxPT			
		)
		SELECT  ISNULL(a.CustID,@MasterID)
			,t.SportType 
			,t.BetType  
			,t.IsLive
			,ISNULL(a.IsAutoMasterPT,0)
			,ISNULL(a.IsAutoSuperPT,0)
			,ISNULL(a.SuperPT,0)
			,ISNULL(a.MasterPT,0)
			,ISNULL(a.AgentPT,0)
			,ISNULL(a.AutoSuperPT,0)
			,ISNULL(a.AutoMasterPT,0)
			,ISNULL(a.MinPT,0)
			,ISNULL(a.MaxPT,100) 
		FROM @NewPTTble t
			LEFT JOIN dbo.CustPTSetting3rd_Agent a WITH (NOLOCK)
				ON t.SportType = a.SportType
				AND t.BetType = a.BetType
				AND t.IsLive = a.IsLive
				AND a.custid = @MasterID
		
		--if is1=0 AND is3=0 then s1<=max(min(s4,l4) - m3,max(n4-m1-a1,0))
		SELECT @ErrInfo = (
							SELECT pdt.SportType,pdt.BetType,pdt.IsLive,
									CASE 
										WHEN CASE 
												WHEN spt.SuperPT < spt.MaxPT
													THEN spt.SuperPT
												ELSE spt.MaxPT
												END - mpt.MasterPT > CASE 
												WHEN spt.MinPT - mempt.MasterPT - mempt.AgentPT > 0
													THEN spt.MinPT - mempt.MasterPT - mempt.AgentPT
												ELSE 0
												END
											THEN CASE 
													WHEN spt.SuperPT < spt.MaxPT
														THEN spt.SuperPT
													ELSE spt.MaxPT
													END - mpt.MasterPT
										ELSE CASE 
												WHEN spt.MinPT - mempt.MasterPT - mempt.AgentPT > 0
													THEN spt.MinPT - mempt.MasterPT - mempt.AgentPT
												ELSE 0
												END
									END AS MaxPT
									, mempt.ProductID, mempt.SettingLevel
							FROM @NewPTTble mempt
								INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
									ON spt.SportType=mempt.SportType
											AND spt.BetType=mempt.BetType
											AND spt.IsLive=mempt.IsLive
											AND spt.CustID=@SuperID
								INNER JOIN @UplinePT mpt 
									ON mpt.SportType=mempt.SportType
											AND mpt.BetType=mempt.BetType
											AND mpt.IsLive=mempt.IsLive
											AND mpt.CustID=@MasterID
								INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
									ON pdt.SportType = mempt.SportType
										AND pdt.BetType = mempt.BetType
										AND pdt.IsLive = mempt.IsLive
							WHERE mempt.IsAutoSuperPT = 0 AND mpt.IsAutoSuperPT = 0
								AND mempt.SuperPT >  
									CASE 
										WHEN CASE 
												WHEN spt.SuperPT < spt.MaxPT
													THEN spt.SuperPT
												ELSE spt.MaxPT
												END - mpt.MasterPT > CASE 
												WHEN spt.MinPT > mempt.MasterPT + mempt.AgentPT 
													THEN spt.MinPT - mempt.MasterPT - mempt.AgentPT
												ELSE 0
												END
											THEN CASE 
													WHEN spt.SuperPT < spt.MaxPT
														THEN spt.SuperPT
													ELSE spt.MaxPT
													END - mpt.MasterPT
										ELSE CASE 
												WHEN spt.MinPT > mempt.MasterPT + mempt.AgentPT 
													THEN spt.MinPT - mempt.MasterPT - mempt.AgentPT
												ELSE 0
												END
									END
							FOR XML RAW('Row'), TYPE)
		
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20028" Msg="The position taking violates Super Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 118
                    , @MsgType = 3                                    
            RETURN
        END	
		
		--if is1=0 AND is3=0 then s1>=max(n4-m1-a1,0)
		SELECT @ErrInfo = (
							SELECT pdt.SportType,pdt.BetType,pdt.IsLive,
									CASE 
										WHEN spt.MinPT - mempt.MasterPT - mempt.AgentPT > 0
											THEN spt.MinPT - mempt.MasterPT - mempt.AgentPT
										ELSE 0
									END  AS MinPT
									, mempt.ProductID, mempt.SettingLevel
							FROM @NewPTTble mempt
								INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
									ON spt.SportType=mempt.SportType
											AND spt.BetType=mempt.BetType
											AND spt.IsLive=mempt.IsLive
											AND spt.CustID=@SuperID
								INNER JOIN @UplinePT mpt 
									ON mpt.SportType=mempt.SportType
											AND mpt.BetType=mempt.BetType
											AND mpt.IsLive=mempt.IsLive
											AND mpt.CustID=@MasterID
								INNER JOIN #ProductSettingDetail_MemCheck pdt WITH (NOLOCK)
									ON pdt.SportType = mempt.SportType
										AND pdt.BetType = mempt.BetType
										AND pdt.IsLive = mempt.IsLive
							WHERE mempt.IsAutoSuperPT = 0 AND mpt.IsAutoSuperPT = 0
								AND mempt.SuperPT < CASE 
														WHEN spt.MinPT > mempt.MasterPT + mempt.AgentPT
															THEN spt.MinPT - mempt.MasterPT - mempt.AgentPT
														ELSE 0
													END 
							FOR XML RAW('Row'), TYPE)
								
		IF @ErrInfo IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20029" Msg="The position taking violates Super Min PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
                    , @ErrCode = 119
                    , @MsgType = 2                                    
            RETURN
        END	
	END
	DROP TABLE #ProductSettingDetail_MemCheck
END
GO
