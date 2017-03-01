SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustSetting_DCSSettingInsert] 
	@CustID				INT
	, @SuperID			INT
	, @MasterID			INT
	, @AgentID			INT
	, @RoleID			TINYINT
	, @ProductID		TINYINT = NULL
	, @ErrCode			INT				= 0		OUTPUT
AS
/*
	Created: 20150916@Dominic
	Task : Insert Settings Into DCS Structure
	DB:  DBCUST/CustDB
	Original:

	
	Revision

	*/
BEGIN
	SELECT @ErrCode = 0
	
	/********************************************* Position Taking: SettingType = 1 ***********************************/
	SELECT * INTO #SportBettypeFilter1
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,1)
	
	BEGIN TRY
		IF @RoleID = 4
		BEGIN
			--s4: 0
			--m4: 0
			--a4: 0
			--n4: 0
			--l4: Default Max PT
			INSERT INTO [dbo].[CustPTSetting3rd_Agent]
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
			   ,[AutoSuperPT]
			   ,[MinPT]
			   ,[MaxPT])
			SELECT 
				@Custid
				,dtl.SportType
				,dtl.BetType
				,dtl.IsLive
				,0,0,0,0,0,0,0,0
				,dtl.MaxPT
			FROM dbo.ProductSettingDetail dtl WITH (NOLOCK)
				INNER JOIN #SportBettypeFilter1 ft 
					ON dtl.SportType = ft.SportType
						AND dtl.BetType = ft.BetType
						AND dtl.IsLive = ft.IsLive
		END
		ELSE IF @RoleID = 3
		BEGIN
			--s3: 0
			--m3: 0
			--is3: 0
			--us3: 0
			--n3: 0
			--l3: Default Max PT
			INSERT INTO [dbo].[CustPTSetting3rd_Agent]
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
			   ,[AutoSuperPT]
			   ,[MinPT]
			   ,[MaxPT])
			SELECT 
				@CustID
				,dtl.SportType
				,dtl.BetType
				,dtl.IsLive
				,0,0,0,0,0,0,0,0
				,dtl.MaxPT
			FROM dbo.ProductSettingDetail dtl WITH (NOLOCK)
				INNER JOIN CustPTSetting3rd_Agent spt 
					ON dtl.SportType = spt.SportType
						AND dtl.BetType = spt.BetType
						AND dtl.IsLive = spt.IsLive
			WHERE dtl.SettingType = 1 AND spt.CustID = @SuperID
		END
		ELSE IF @RoleID = 2
		BEGIN
			--m2: 0
			--a2: 0
			--im2: 0
			--um2: 0
			--n2: 0
			--l2: Default Max PT
			INSERT INTO [dbo].[CustPTSetting3rd_Agent]
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
			   ,[AutoSuperPT]
			   ,[MinPT]
			   ,[MaxPT])
			SELECT 
			@custid,dtl.SportType,dtl.BetType,dtl.IsLive,
				0,0,0,0,0,0,0,0
				,dtl.MaxPT
			FROM dbo.ProductSettingDetail dtl WITH (NOLOCK)
			INNER JOIN CustPTSetting3rd_Agent mpt 
				ON dtl.SportType = mpt.SportType
					AND dtl.BetType = mpt.BetType
					AND dtl.IsLive = mpt.IsLive
			WHERE dtl.SettingType = 1 AND mpt.custid = @MasterID
		END
		ELSE
		BEGIN --RoleID = 1
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
			)
			
			--Get default PT settings	
			--s1: s3
			--m1: m2
			--a1: a2
			--is1: 0
			--us1: 0
			--im1: 0
			--um1: 0
			INSERT INTO @MemberPTTbl (
				CustID
				, SportType
				, BetType
				, Islive
				, SuperPT
				, MasterPT
				, AgentPT
				, IsAutoMPT
				, AutoMPT
				, IsAutoSPT
				, AutoSPT
				)
			SELECT @CustID
				, acs.SportType
				, acs.BetType
				, acs.IsLive
				, mcs.superPT
				, acs.masterPT
				, acs.agentPT
				, 0
				, 0
				, 0
				, 0
			FROM dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK)
			INNER JOIN dbo.CustPTSetting3rd_Agent mcs WITH (NOLOCK)
				ON acs.sporttype = mcs.sporttype
					AND acs.bettype = mcs.bettype
					AND acs.islive = mcs.islive
					AND mcs.custid = @MasterID
			WHERE acs.custid = @AgentID
			
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
				INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH(NOLOCK) 
					ON @AgentID = acs.custid 
						AND cs.sporttype = acs.sporttype 
						AND cs.bettype = acs.bettype 
						AND cs.IsLive = acs.IsLive
				INNER JOIN dbo.CustPTSetting3rd_Agent m WITH(NOLOCK) 
					ON @MasterID = m.custid 
						AND cs.sporttype = m.sporttype 
						AND cs.bettype = m.bettype 
						AND cs.IsLive = m.IsLive
				INNER JOIN dbo.CustPTSetting3rd_Agent s WITH(NOLOCK)  
					ON @SuperID = s.custid 
						AND cs.sporttype = s.sporttype 
						AND cs.bettype = s.bettype 
						AND cs.IsLive = s.IsLive
						
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
			SELECT 
				@AgentID,SportType,BetType,Islive,
				SuperPT,MasterPT,AgentPT,IsAutoMPT,AutoMPT,IsAutoSPT,AutoSPT
			FROM @MemberPTTbl
			WHERE NOT EXISTS(SELECT TOP 1 1 FROM dbo.CustPTGroupSetting3rd_Member WITH(NOLOCK) WHERE AgentID = @AgentID)
			
			IF @@ROWCOUNT<>0
			BEGIN
				INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped)
					SELECT @CustID,1
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT TOP 1 1
							FROM dbo.CustPTGroupSetting3rd_Member grp
							JOIN @memberPTTbl tmp ON tmp.SportType = grp.SportType
													AND tmp.BetType = grp.BetType
													AND tmp.Islive = grp.Islive
							WHERE grp.AgentID = @AgentID
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
							))
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
					
					INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped)
						SELECT @CustID,0
				END
				ELSE
				BEGIN
					INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped)
						SELECT @CustID,1
				END
			END
			 
		END
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 1
		IF @RoleID = 1
		BEGIN
			DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
			DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
		END
		ELSE --SMA
		BEGIN
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID
		END
		RETURN
	END CATCH
	/********************************************* Bet Limit : SettingType = 2 ****************************************/
	
	SELECT * INTO #SportBettypeFilter2
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,2)
	
	BEGIN TRY
		IF @RoleID = 4
		BEGIN
			IF EXISTS(
				SELECT TOP 1 1
				FROM #SportBettypeFilter2
			)
			BEGIN
				--Min: 0
				--Max: 0
				--Max Per Match: 0
				INSERT INTO [dbo].[CustBetSetting3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch])
				SELECT
					@CustID
					,dtl.SportType
					,dtl.BetType
					,0
					,0
					,0
				FROM #SportBettypeFilter2
			END
		END
		ELSE IF @RoleID = 3
		BEGIN
			--Min: super.minbet
			--Max: super.maxbet
			--Max Per Match: super.maxpermatch
			INSERT INTO [dbo].[CustBetSetting3rd_Agent]
			   ([CustID]
			   ,[SportType]
			   ,[BetType]
			   ,[MinBet]
			   ,[MaxBet]
			   ,[MaxPerMatch])
			SELECT
				@CustID
				,SportType
				,BetType
				,MinBet
				,MaxBet
				,MaxPerMatch
			FROM dbo.CustBetSetting3rd_Agent WITH (NOLOCK)
			WHERE custid = @SuperID
		END
		ELSE IF @RoleID = 2
		BEGIN
			--Min: max(master.minbet; super.minbet)
			--Max: min(master.maxbet; super.maxbet)
			--Max Per Match: min(master.maxpermatch; super.maxpermatch)
			DECLARE @BetlimitAgent TABLE(
					SportType SMALLINT,
					BetType SMALLINT,
					MinBet MONEY,
					MaxBet MONEY,
					MaxPerMatch MONEY
				)
			INSERT INTO @BetlimitAgent
			SELECT SportType,BetType,
					 Max(case when MinBet = 0 then NULL else MinBet end) MinBet,
					 Min(case when MaxBet = 0 then NULL else MaxBet end) MaxBet,
					 Min(case when MaxPerMatch = 0 then NULL else MaxPerMatch end) MaxPerMatch
			FROM dbo.CustBetSetting3rd_Agent smcs WITH (NOLOCK)
			WHERE smcs.custid = @SuperID 
					OR smcs.custid = @MasterID
			GROUP BY SportType,BetType
			
			INSERT INTO [dbo].[CustBetSetting3rd_Agent]
			   ([CustID]
			   ,[SportType]
			   ,[BetType]
			   ,[MinBet]
			   ,[MaxBet]
			   ,[MaxPerMatch])
			SELECT
				@CustID
				,SportType
				,BetType
				,ISNULL(MinBet,0)
				,ISNULL(MaxBet,0)
				,ISNULL(MaxPerMatch,0)
			FROM @BetlimitAgent
		END
		ELSE
		BEGIN
			--Min: max(agent.minbet; master.minbet; super.minbet)
			--Max: min(agent.maxbet; master.maxbet; super.maxbet)
			--Max Per Match: min(agent.maxpermatch; master.maxpermatch; super.maxpermatch)
			
			DECLARE @BetlimitMember TABLE(
					SportType SMALLINT,
					BetType SMALLINT,
					MinBet MONEY,
					MaxBet MONEY,
					MaxPerMatch MONEY
				)
			INSERT INTO @BetlimitMember
			SELECT SportType,BetType,
					 Max(case when MinBet = 0 then NULL else MinBet end) MinBet,
					 Min(case when MaxBet = 0 then NULL else MaxBet end) MaxBet,
					 Min(case when MaxPerMatch = 0 then NULL else MaxPerMatch end) MaxPerMatch
			FROM dbo.CustBetSetting3rd_Agent  WITH (NOLOCK)
			WHERE custid = @SuperID 
					OR custid = @MasterID
					OR custid = @AgentID
			GROUP BY SportType,BetType
			
			INSERT INTO [dbo].[CustBetSetting3rd_Member]
			   ([CustID]
			   ,[SportType]
			   ,[BetType]
			   ,[MinBet]
			   ,[MaxBet]
			   ,[MaxPerMatch])
			SELECT
				@CustID
				,SportType
				,BetType
				,ISNULL(MinBet,0)
				,ISNULL(MaxBet,0)
				,ISNULL(MaxPerMatch,0)
			FROM @BetlimitMember
		END
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 2
		IF @RoleID = 1
		BEGIN
			DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
			DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
			DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
		END
		ELSE --SMA
		BEGIN
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID		
			DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
		END
		RETURN
	END CATCH
	
	/********************************************* Commision : SettingType = 3 ****************************************/
	SELECT * INTO #SportBettypeFilter3
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,3)
	
	BEGIN TRY
		IF @RoleID = 4
		BEGIN
			IF EXISTS(
				SELECT TOP 1 1
				FROM #SportBettypeFilter3
			)
			BEGIN
				INSERT INTO [dbo].[CustDiscount3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[Discount])
				SELECT 
					@CustID
					,SportType
					,BetType
					,0 -- 0 zero by default
				FROM #SportBettypeFilter3 ft 
			END
		END
		ELSE IF @RoleID = 3
		BEGIN
			INSERT INTO [dbo].[CustDiscount3rd_Agent]
			   ([CustID]
			   ,[SportType]
			   ,[BetType]
			   ,[Discount])
			SELECT 
				@CustID
				,SportType
				,BetType
				,0 -- 0 zero by default
			FROM CustDiscount3rd_Agent WITH(NOLOCK) 
			WHERE CustID = @SuperID
		END
		ELSE IF @RoleID = 2
		BEGIN
			INSERT INTO [dbo].[CustDiscount3rd_Agent]
			   ([CustID]
			   ,[SportType]
			   ,[BetType]
			   ,[Discount])
			SELECT 
				@CustID
				,SportType
				,BetType
				,0 -- 0 zero by default
			FROM CustDiscount3rd_Agent WITH(NOLOCK) 
			WHERE CustID = @MasterID
		END
		ELSE
		BEGIN
			--super.discount: super.discount
			--master.discount: master.discount
			--agent.discount: agent.discount
			--playerdiscount: 0
			INSERT INTO [dbo].[CustDiscount3rd_Member]
			   ([CustID]
			   ,[SportType]
			   ,[BetType]
			   ,[PlayerDiscount]
			   ,[AgentDiscount]
			   ,[MasterDiscount]
			   ,[SuperDiscount])
			SELECT 
				@CustID
				,acs.SportType
				,acs.BetType
				,0
				,acs.Discount
				,mcs.Discount
				,scs.Discount
			FROM dbo.CustDiscount3rd_Agent acs WITH (NOLOCK)
			JOIN dbo.CustDiscount3rd_Agent mcs WITH (NOLOCK)
						ON acs.sporttype = mcs.sporttype
						AND acs.bettype = mcs.bettype
						AND mcs.custid = @MasterID
			JOIN dbo.CustDiscount3rd_Agent scs WITH (NOLOCK)
						ON acs.sporttype = scs.sporttype
						AND acs.bettype = scs.bettype
						AND scs.custid = @SuperID
			WHERE acs.custid=@AgentID
		END
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 3
		IF @RoleID = 1
		BEGIN
			DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
			DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
			DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID	
			DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
		END
		ELSE --SMA
		BEGIN
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
			DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
			DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
		END
		RETURN
	END CATCH
	/********************************************* Product Status: SettingType = 4 ************************************/
	--Get sporttype/Bettype for this setting type
	SELECT DISTINCT psd.SportType,psd.Bettype,psd.IsLive, psd.SettingType,psd.IsDisabled,psd.IsHidden,psd.IsSync,pbs.bitmapOrder 
	INTO #SportBettypeFilter4
	FROM dbo.ProductSettingDetail psd WITH(NOLOCK)  
		INNER JOIN ProductStatusProfile pbs WITH (NOLOCK) ON pbs.[SportType] = psd.[SportType]	AND pbs.[BetType] = psd.[BetType]
	WHERE psd.ProductID = @ProductID AND PSD.SettingType = 4
	BEGIN TRY
		IF @RoleID = 4
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter4)
			BEGIN
				--Get from default status values
				--Sync: default status setting
				--Hide: default status setting
				--Enable/Disable: default status setting
									
				DECLARE @xmlStrDisabled XML
				DECLARE @xmlStrHidden XML
				DECLARE @xmlStrSync XML
				
				SET @xmlStrDisabled = (
						SELECT (
								SELECT ft.bitmapOrder	AS '@b'
									, ft.IsDisabled	AS '@s'
								FROM #SportBettypeFilter4 ft 	
								FOR XML PATH('r')
									, TYPE
								)
						FOR XML PATH('root')
							, TYPE
						)
						
				SET @xmlStrHidden = (
						SELECT (
								SELECT ft.bitmapOrder	AS '@b'
									, ft.IsHidden	AS '@s'
								FROM #SportBettypeFilter4 ft 	
								FOR XML PATH('r')
									, TYPE
								)
						FOR XML PATH('root')
							, TYPE
						)
						
				SET @xmlStrDisabled = (
					SELECT (
							SELECT ft.bitmapOrder	AS '@b'
								, ft.IsSync	AS '@s'
							FROM #SportBettypeFilter4 ft 	
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)
							
				INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced)
				SELECT	@CustID
						, dbo.f_GenerateProductStatus_multiple (0, CONVERT(VARCHAR(MAX),@xmlStrDisabled))	
						, dbo.f_GenerateProductStatus_multiple (0, CONVERT(VARCHAR(MAX),@xmlStrHidden))
						, dbo.f_GenerateProductStatus_multiple (0, CONVERT(VARCHAR(MAX),@xmlStrSync))
					
			END
		END
		ELSE IF @RoleID IN (3,2,1)
		BEGIN
			--Get from Super
			--Sync: upline status
			--Enable/Disable: upline status
			DECLARE @UplineID INT
			IF @RoleID = 3
				SET @UplineID = @SuperID
			ELSE IF @RoleID = 2
				SET @UplineID = @MasterID
			ELSE IF @RoleID = 1
				SET @UplineID = @AgentID		
			
			INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced)
			SELECT @CustID, cs.bitmapIsDisabled,cs.bitmapIsHidden,cs.bitmapHasSynced
			FROM [dbo].[CustProductStatus] cs WITH (NOLOCK)
			WHERE cs.CustID = @UplineID
			
		END
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 4
		IF @RoleID = 1
		BEGIN
			DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
			DELETE FROM CustSettingMode3rd WHERE CustID = @CustID			
			DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID		
			DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
		END
		ELSE --SMA
		BEGIN
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID		
			DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID	
			DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
		END
		DELETE FROM CustProductStatus WHERE CustID = @CustID
		
		RETURN
	END CATCH
	DROP TABLE #SportBettypeFilter1
	DROP TABLE #SportBettypeFilter2
	DROP TABLE #SportBettypeFilter3
	DROP TABLE #SportBettypeFilter4

END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DCSSettingInsert] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DCSSettingInsert] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DCSSettingInsert] TO [bodbExtAccNet]