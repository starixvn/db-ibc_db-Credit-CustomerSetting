ALTER PROCEDURE [dbo].[Acc_CustSetting_04] 
	@srecommend int = 0
	,@mrecommend int = 0
	,@recommend int = 0
	,@roleid int
AS
/*
        Created: Johnson
        Date: 2013-10-29
        Task: Apply execrep WHEN UPDATE min/max pt ON master AND agent
        DB: DBCUST/custDB
        Original versions: Acc_CustomerUpdMaster_MinMaxPositiontaking
                        Acc_CustomerUpdAgent_MinMaxPositiontaking
        
        Revision:
			- 20131112@Johnson: merge code sp Acc_CustSetting_00 into Acc_CustSetting_04 for super level
			- 20140729@Logan:   1.Exclude disabled agents while updating SM's setting [Redmine: #19631]
								2.Code aligning on modified parts
			- 20150610@Daniel: 
				+ Improve medthod check table existing in subscribers	
				+ Separate custDB to new server DBCUST  
			- 20150716@Viet: rewrite SP
			                              
        Parameter's Explanation:        
    */
BEGIN
	SET NOCOUNT ON

	IF dbo.f_CheckRepTable('custinfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustSetting') = 0 RETURN
	IF dbo.f_CheckRepTable('CustOverride') = 0 RETURN		

	DECLARE @_srecommend int, @_mrecommend int, @_recommend int
	
	-- declare variable table to keep super's settings (custoverride & custsetting data)
	DECLARE @temp_sag TABLE (custid int, bettype smallint, sporttype smallint,
		a4 smallmoney, m4 smallmoney, s4 smallmoney, a4live smallmoney, m4live smallmoney, s4live smallmoney,
		n4 smallmoney, l4 smallmoney, n4live smallmoney, l4live smallmoney
		UNIQUE CLUSTERED (custid, sporttype, bettype)
	)
	
	-- declare variable table to keep master's settings (custoverride & custsetting data)
	DECLARE @temp_mag TABLE (custid int, bettype smallint, sporttype smallint,
		a3 smallmoney, m3 smallmoney, s3 smallmoney, a3live smallmoney, m3live smallmoney, s3live smallmoney,
		u3 smallmoney, i3 bit, u3live smallmoney, i3live bit, n3 smallmoney, l3 smallmoney, n3live smallmoney, l3live smallmoney,
		UNIQUE CLUSTERED (custid, sporttype, bettype)
	)
	DECLARE @a2 smallmoney, @m2 smallmoney, @s2 smallmoney, @n2 smallmoney, @l2 smallmoney
	DECLARE @im2 bit, @um2 smallmoney
	DECLARE @a2live smallmoney, @m2live smallmoney, @s2live smallmoney, @n2live smallmoney, @l2live smallmoney 
	DECLARE @im2live smallmoney, @um2live smallmoney
	DECLARE @a1 smallmoney, @m1 smallmoney, @s1 smallmoney, @i1 bit, @u1 smallmoney, @im1 bit, @um1 smallmoney
	DECLARE @a1live smallmoney, @m1live smallmoney, @s1live smallmoney, @i1live bit, @u1live smallmoney, @im1live bit, @um1live smallmoney
	DECLARE @temp1 smallmoney, @temp2 smallmoney, @temp3 smallmoney, @updateLIVE bit
	DECLARE @s_new smallmoney, @m_new smallmoney, @a_new smallmoney
	---------------------------------

	SELECT @_srecommend = @srecommend, @_mrecommend = @mrecommend, @_recommend = @recommend
	
	INSERT INTO @temp_sag (custid, bettype, sporttype, a4, m4, s4, 
		a4live, m4live, s4live, 
		n4, l4, n4live, l4live
	)
	SELECT scs.custid, scs.bettype, scs.sporttype, scs.apositiontaking, scs.mpositiontaking, scs.spositiontaking, 
		scs.alivepositiontaking, scs.mlivepositiontaking, scs.slivepositiontaking,		
		sco.minpositiontaking, sco.maxpositiontaking, sco.minlivepositiontaking, sco.maxlivepositiontaking
	FROM dbo.custsetting scs WITH(NOLOCK)
		INNER JOIN dbo.custoverride sco WITH(NOLOCK) 
			ON scs.custid = sco.custid AND scs.bettype = sco.bettype AND scs.sporttype = sco.sporttype
	WHERE scs.custid = @_srecommend

	IF @roleid = 4
	BEGIN
		INSERT INTO @temp_mag (custid, bettype, sporttype, a3, m3, s3, 
			a3live, m3live, s3live, 
			u3, i3, u3live, i3live, 
			n3, l3, n3live, l3live
		)
		SELECT mcs.custid, mcs.bettype, mcs.sporttype, mcs.apositiontaking, mcs.mpositiontaking, mcs.spositiontaking,
			mcs.alivepositiontaking, mcs.mlivepositiontaking, mcs.slivepositiontaking,
			mcs.autopositiontaking, mcs.isautopositiontaking, mcs.autolivepositiontaking, mcs.isautolivepositiontaking,
			mco.minpositiontaking, mco.maxpositiontaking, mco.minlivepositiontaking, mco.maxlivepositiontaking
		FROM dbo.custinfo c WITH(NOLOCK)
			INNER JOIN dbo.custsetting mcs WITH(NOLOCK) ON c.custid = mcs.custid
			INNER JOIN dbo.custoverride mco WITH(NOLOCK) ON c.custid = mco.custid AND mcs.bettype = mco.bettype AND mcs.sporttype = mco.sporttype			
		WHERE c.srecommend = @_srecommend AND c.roleid = 3
			
		--*** START: update PT on member ***-----------------------	
		UPDATE cs
		SET @a1 = cs.apositiontaking
			,@a1live = cs.alivepositiontaking
			,@m1 = cs.mpositiontaking
			,@m1live = cs.mlivepositiontaking
			,@s1 = cs.spositiontaking
			,@s1live = cs.slivepositiontaking					
			,@n2 = aco.minpositiontaking
			,@n2live = aco.minlivepositiontaking
			,@l2 = aco.maxpositiontaking
			,@l2live = aco.maxlivepositiontaking
			,@im2 = acs.isautompositiontaking
			,@im2live = acs.isautolivempositiontaking
			,@um2 = acs.autompositiontaking
			,@um2live = acs.autolivempositiontaking
			,@i1 = cs.isautopositiontaking
			,@i1live = cs.isautolivepositiontaking
			,@u1 = cs.autopositiontaking
			,@u1live = cs.autolivepositiontaking
			,@im1 = cs.isautompositiontaking
			,@im1live = cs.isautolivempositiontaking
			,@um1 = cs.autompositiontaking
			,@um1live = cs.autolivempositiontaking
			,@updateLIVE = CASE WHEN cs.sporttype = 1 and cs.bettype IN (1,3,7,8) THEN 1 ELSE 0 END
			
			-- rule #1: s1=min(s1,s4-m3) if i=0
			,@s1 = CASE WHEN @i1 = 0 AND m.i3 = 0 AND s.s4-m.m3 < @s1 THEN s.s4-m.m3 ELSE @s1 END
			,@s1live = CASE 
							WHEN @updateLIVE = 1 AND @i1live = 0 AND m.i3live = 0 AND s.s4live-m.m3live < @s1live 
							THEN s.s4live-m.m3live 
							ELSE @s1live 
						END

			-- rule #2: a1=max(a1,n2); m1 = (a1<@n2) ? m3-n2 : m1 --agent min
			,@a_new = CASE WHEN @a1 < @n2 THEN @n2 ELSE @a1 END
			,@m_new = CASE WHEN @a1 < @n2 AND @m1+@n2 > m.m3 THEN m.m3-@n2 ELSE @m1 END
			,@a1 = @a_new
			,@m1 = @m_new
					
			,@a_new = CASE WHEN @updateLIVE = 1 AND @a1live < @n2live THEN @n2live ELSE @a1live END
			,@m_new = CASE WHEN @updateLIVE = 1 AND @a1live < @n2live AND @m1live+@n2live > m.m3live THEN m.m3live-@n2live ELSE @m1live END			
			,@a1live = @a_new
			,@m1live = @m_new

			-- rule #3: a1=min(a1,l2) -- agent max
			,@a1 = CASE WHEN @a1 > @l2 THEN @l2 ELSE @a1 END
			,@a1live = CASE WHEN @updateLIVE = 1 AND @a1live > @l2live THEN @l2live ELSE @a1live END
			
			-- rule #4: m1=min(m3-a1,u2) if master auto -- Recalculate AUTO MPT 
			,@temp1 = CASE WHEN @im1 = 1 THEN @um1 ELSE @um2 END			
			,@m1 = CASE 
						WHEN @im2 = 1 OR @im1 = 1 
						THEN CASE WHEN m.m3-@a1 > @temp1 THEN @temp1 ELSE m.m3-@a1 END 
						ELSE @m1 
					END		
			,@temp1 = CASE WHEN @im1live = 1 THEN @um1live ELSE @um2live END
			,@m1live = CASE 
						WHEN @im2live = 1 OR @im1live = 1 
						THEN CASE WHEN m.m3live-@a1live > @temp1 THEN @temp1 ELSE m.m3live-@a1live END 
						ELSE @m1live 
					END
					
			-- rule #5: m1=max(m1,n3-a1) -- master min
			,@m1 = CASE WHEN @m1 < m.n3-@a1 THEN m.n3-@a1 ELSE @m1 END
			,@m1live = CASE WHEN @updateLIVE = 1 AND @m1live < m.n3live-@a1live THEN m.n3live-@a1live ELSE @m1live END

			-- rule #6: check master max 
			/*	@x1 = min(m3,l3) -- mpt max
				@x2 = max(@x1-a1,0) --mpt
				m1 = (a1+m1>l3) ? @x2 : m1
				@x3 = (a1+@x2 > @x1) ? @x1-@x2 : a1
				a1 = (a1+m1>l1) ? max(@x3, n2) : a1
			*/
			,@temp1 = CASE WHEN m.m3 > m.l3 THEN m.l3 ELSE m.m3 END
			,@temp2 = CASE WHEN @temp1-@a1 < 0 THEN 0 ELSE @temp1-@a1 END
			,@m_new = CASE WHEN @a1+@m1 > m.l3 THEN @temp2 ELSE @m1 END
			,@temp3 = CASE WHEN @a1+@temp2 > @temp1 THEN @temp1-@temp2 ELSE @a1 END
			,@a_new = CASE 
						WHEN @a1+@m1 > m.l3 
						THEN CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
						ELSE @a1 
					END	
				
			,@m1 = @m_new
			,@a1 = @a_new

			,@temp1 = CASE WHEN m.m3live > m.l3live THEN m.l3live ELSE m.m3live END
			,@temp2 = CASE WHEN @temp1-@a1live < 0 THEN 0 ELSE @temp1-@a1live END
			,@m_new = CASE WHEN @updateLIVE = 1 AND @a1live+@m1live > m.l3live THEN @temp2 ELSE @m1live END
			,@temp3 = CASE WHEN @a1live+@temp2 > @temp1 THEN @temp1-@temp2 ELSE @a1live END
			,@a_new = CASE 
						WHEN @updateLIVE = 1 AND @a1live+@m1live > m.l3live 
						THEN CASE WHEN @temp3 < @n2live THEN @n2live ELSE @temp3 END
						ELSE @a1live 
					END		
			
			,@m1live = @m_new
			,@a1live = @a_new
		
			-- rule #7: s1 = min(s4-m1-a1, i1?u1:u3) --Recalculate auto pt
			/*
				@x1 = (i1=1) ? u1 : u3
				s1 = (s4-m1-a1 > @x1) ? @x1 : s4-m1-a1 
			*/
			,@temp1 = CASE WHEN @i1 = 1 THEN @u1 ELSE m.u3 END			
			,@s1 = CASE 
						WHEN @i1 = 1 OR m.i3 = 1 
						THEN CASE WHEN s.s4-@m1-@a1 > @temp1 THEN @temp1 ELSE s.s4-@m1-@a1 END
						ELSE @s1
					END			

			,@temp1 = CASE WHEN @i1live = 1 THEN @u1live ELSE m.u3live END			
			,@s1live = CASE 
						WHEN @i1live = 1 OR m.i3live = 1 
						THEN CASE WHEN s.s4live-@m1live-@a1live > @temp1 THEN @temp1 ELSE s.s4live-@m1live-@a1live END
						ELSE @s1live
					END		
					
			-- rule #8) s1 = max(n4-m1-a1,s1) --super min
			,@s1 = CASE WHEN @a1+@m1+@s1 < s.n4 THEN s.n4-@m1-@a1 ELSE @s1 END		
			,@s1live = CASE WHEN @updateLIVE = 1 AND @a1live+@m1live+@s1live < s.n4live THEN s.n4live-@m1live-@a1live ELSE @s1live END
					
			-- rule #9) UPDATE s1,m1,a1 IN case s1+m1+a1>s4
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
			
			,@temp1 = CASE WHEN s.s4live-@m1live-@a1live < 0 THEN 0 ELSE s.s4live-@m1live-@a1live END
			,@s_new = CASE WHEN @updateLIVE = 1 AND @s1live+@a1live+@m1live > s.s4live THEN @temp1 ELSE @s1live END
			,@temp1 = CASE WHEN @temp1+@m1live+@a1live > s.s4live THEN s.s4live-@temp1 ELSE @m1live+@a1live END
			,@temp2 = CASE WHEN m.m3live > m.l3live THEN m.l3live ELSE m.m3live END
			,@temp2 = CASE WHEN @temp1 > @temp2 THEN @temp2 ELSE @temp1 END
			,@temp2 = CASE WHEN @temp2 < m.n3live THEN m.n3live ELSE @temp2 END
			,@temp3 = CASE WHEN @temp2-@a1live < 0 THEN 0 ELSE @temp2-@a1live END
			,@m_new = CASE WHEN @updateLIVE = 1 AND @s1live+@a1live+@m1live > s.s4live THEN @temp3 ELSE @m1live END
			,@temp3 = CASE WHEN @a1live+@temp3 > @temp2 THEN @temp2-@temp3 ELSE @a1live END
			,@temp3 = CASE WHEN @temp3 < @n2live THEN @n2live ELSE @temp3 END
			,@a_new = CASE WHEN @updateLIVE = 1 AND @s1live+@a1live+@m1live > s.s4live THEN @temp3 ELSE @a1live END
			,@s1live = @s_new
			,@m1live = @m_new
			,@a1live = @a_new
								
			--------------------------------	
			-- done apply all rule, then update to destination table
			,cs.apositiontaking = @a1
			,cs.mpositiontaking = @m1
			,cs.spositiontaking = @s1
			,cs.alivepositiontaking = @a1live
			,cs.mlivepositiontaking = @m1live
			,cs.slivepositiontaking = @s1live
		FROM dbo.custinfo c WITH(NOLOCK)
			INNER JOIN dbo.custsetting cs WITH(ROWLOCK, UPDLOCK) ON c.custid = cs.custid
			INNER JOIN dbo.custsetting acs WITH(NOLOCK) on c.recommend = acs.custid AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype
			INNER JOIN dbo.custoverride aco WITH(NOLOCK) on acs.custid = aco.custid AND cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype
			INNER JOIN @temp_mag m ON c.mrecommend = m.custid AND cs.sporttype = m.sporttype AND cs.bettype = m.bettype
			INNER JOIN @temp_sag s ON c.srecommend = s.custid AND cs.sporttype = s.sporttype AND cs.bettype = s.bettype
		WHERE c.srecommend = @_srecommend AND c.roleid = 1 and c.enabled = 1
		--*** END: update PT on member ***-----------------------						
	END
	ELSE --@roleid in (2,3)
	BEGIN
		INSERT INTO @temp_mag (custid, bettype, sporttype, a3, m3, s3, 
			a3live, m3live, s3live, 
			u3, i3, u3live, i3live, 
			n3, l3, n3live, l3live
		)
		SELECT mcs.custid, mcs.bettype, mcs.sporttype, mcs.apositiontaking, mcs.mpositiontaking, mcs.spositiontaking,
			mcs.alivepositiontaking, mcs.mlivepositiontaking, mcs.slivepositiontaking,
			mcs.autopositiontaking, mcs.isautopositiontaking, mcs.autolivepositiontaking, mcs.isautolivepositiontaking,
			mco.minpositiontaking, mco.maxpositiontaking, mco.minlivepositiontaking, mco.maxlivepositiontaking
		FROM dbo.custsetting mcs WITH(NOLOCK)
			INNER JOIN dbo.custoverride mco WITH(NOLOCK) ON mcs.custid = mco.custid AND mcs.bettype = mco.bettype AND mcs.sporttype = mco.sporttype			
		WHERE mcs.custid = @_mrecommend
		
		declare @agList as table (custid int)
		
		IF @roleid = 2
		BEGIN
			INSERT INTO @agList (custid)
			SELECT @_recommend
		END
		ELSE IF @roleid = 3
		BEGIN
			INSERT INTO @agList (custid)
			SELECT ag.custid
			FROM dbo.custinfo ag WITH(NOLOCK)
			WHERE mrecommend = @_mrecommend AND roleid = 2
			
			--update a2, m2, um2
			--*** START: update PT on agent ***-----------------------	
			UPDATE acs
			SET @a2 = acs.apositiontaking
				,@a2live = acs.alivepositiontaking
				,@m2 = acs.mpositiontaking
				,@m2live = acs.mlivepositiontaking			
				,@um2 = acs.autompositiontaking
				,@um2live = acs.autolivempositiontaking				
				,@im2 = acs.isautompositiontaking
				,@im2live = acs.isautolivempositiontaking 
				,@n2 = aco.minpositiontaking
				,@n2live = aco.minlivepositiontaking					
				,@updateLIVE = CASE WHEN acs.sporttype = 1 and acs.bettype IN (1,3,7,8) THEN 1 ELSE 0 END
								
				-- rule #1: UPDATE m2,a2 WHEN m2+a2>l3
				/*
					@x1 = min(m3,l3) -- mpt max
					@x2 = max(@x1-a2,0) --mpt
					m2 = (a2+m2>l3) ? @x2 : m2
					@x3 = (a2+@x2 > @x1) ? @x1-@x2 : a2
					a2 = (a2+m2>l2) ? max(@x3, n2) : a2
				*/
				,@temp1 = CASE WHEN m.m3 > m.l3 THEN m.l3 ELSE m.m3 END
				,@temp2 = CASE WHEN @temp1-@a2 < 0 THEN 0 ELSE @temp1-@a2 END
				,@m_new = CASE WHEN @a2+@m2 > m.l3 THEN @temp2 ELSE @m2 END
				,@temp3 = CASE WHEN @a2+@temp2 > @temp1 THEN @temp1-@temp2 ELSE @a2 END
				,@a_new = CASE 
							WHEN @a2+@m2 > m.l3 
							THEN CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
							ELSE @a2 
						END		
				,@m2 = @m_new
				,@a2 = @a_new
				
				,@temp1 = CASE WHEN m.m3live > m.l3live THEN m.l3live ELSE m.m3live END
				,@temp2 = CASE WHEN @temp1-@a2live < 0 THEN 0 ELSE @temp1-@a2live END
				,@m_new = CASE WHEN @updateLIVE = 1 AND @a2live+@m2live > m.l3live THEN @temp2 ELSE @m2live END
				,@temp3 = CASE WHEN @a2live+@temp2 > @temp1 THEN @temp1-@temp2 ELSE @a2live END
				,@a_new = CASE 
							WHEN @updateLIVE = 1 AND @a2live+@m2live > m.l3live 
							THEN CASE WHEN @temp3 < @n2live THEN @n2live ELSE @temp3 END
							ELSE @a2live 
						END
				,@m2live = @m_new
				,@a2live = @a_new
					
				-- rule #2: um2=min(m3,l3) if um2>l3
				,@temp1 = CASE WHEN m.m3 > m.l3 THEN m.l3 ELSE m.m3 END -- min(m3,l3)
				,@um2 = CASE WHEN @im2 = 1 AND @um2 > m.l3 THEN @temp1 ELSE @um2 END
								
				,@temp1 = CASE WHEN m.m3live > m.l3live THEN m.l3live ELSE m.m3live END -- min(m3,l3)
				,@um2live = CASE WHEN @updateLIVE = 1 AND @im2live = 1 AND @um2live > m.l3live THEN @temp1 ELSE @um2live END
					
				--------------------------------	
				-- done apply all rule, then update to destination table
				,acs.apositiontaking = @a2
				,acs.mpositiontaking = @m2
				,acs.autompositiontaking = @um2
				,acs.alivepositiontaking = @a2live
				,acs.mlivepositiontaking = @m2live
				,acs.autolivempositiontaking = @um2live
			FROM dbo.custinfo ag WITH(NOLOCK)
				INNER JOIN dbo.custsetting acs WITH(ROWLOCK, UPDLOCK) on ag.custid = acs.custid
				INNER JOIN dbo.custoverride aco WITH(NOLOCK) on acs.custid = aco.custid AND acs.sporttype = aco.sporttype AND acs.bettype = aco.bettype
				INNER JOIN @temp_mag m ON ag.mrecommend = m.custid AND acs.sporttype = m.sporttype AND acs.bettype = m.bettype
				INNER JOIN @temp_sag s ON ag.srecommend = s.custid AND acs.sporttype = s.sporttype AND acs.bettype = s.bettype			
			WHERE ag.custid IN (SELECT custid from @agList) AND ag.enabled = 1
			--*** END: update PT on agent ***-----------------------			
		END		
				
		--*** START: update PT on member ***-----------------------	
		UPDATE cs
		SET @a1 = cs.apositiontaking
			,@a1live = cs.alivepositiontaking
			,@m1 = cs.mpositiontaking
			,@m1live = cs.mlivepositiontaking
			,@s1 = cs.spositiontaking
			,@s1live = cs.slivepositiontaking	
			,@i1 = cs.isautopositiontaking
			,@i1live = cs.isautolivepositiontaking
			,@u1 = cs.autopositiontaking
			,@u1live = cs.autolivepositiontaking			
			,@im1 = cs.isautompositiontaking
			,@im1live = cs.isautolivempositiontaking
			,@um1 = cs.autompositiontaking
			,@um1live = cs.autolivempositiontaking			
			,@im2 = acs.isautompositiontaking
			,@im2live = acs.isautolivempositiontaking	
			,@um2 = acs.autompositiontaking
			,@um2live = acs.autolivempositiontaking
			,@n2 = aco.minpositiontaking
			,@n2live = aco.minlivepositiontaking
			,@l2 = aco.maxpositiontaking
			,@l2live = aco.maxlivepositiontaking
			,@updateLIVE = CASE WHEN cs.sporttype = 1 and cs.bettype IN (1,3,7,8) THEN 1 ELSE 0 END
							
			-- rule #1: a1=max(a1,n2); m1 = (a1<@n2) ? m3-n2 : m1 -- agent min
			,@a_new = CASE WHEN @a1 < @n2 THEN @n2 ELSE @a1 END
			,@m_new = CASE WHEN @a1 < @n2 AND @m1 +@n2 > m.m3 THEN m.m3-@n2 ELSE @m1 END
			,@a1 = @a_new
			,@m1 = @m_new
			
			,@a_new = CASE WHEN @updateLIVE = 1 AND @a1live < @n2live THEN @n2live ELSE @a1live END
			,@m_new = CASE WHEN @updateLIVE = 1 AND @a1live < @n2live AND @m1live +@n2live > m.m3live THEN m.m3live-@n2live ELSE @m1live END
			,@a1live = @a_new
			,@m1live = @m_new
			
			-- rule #2: a1=min(a1,l2) -- agent max
			,@a1 = CASE WHEN @a1 > @l2 THEN @l2 ELSE @a1 END			
			,@a1live = CASE WHEN @updateLIVE = 1 AND @a1live > @l2live THEN @l2live ELSE @a1live END
		
		
			-- rule #3: m1=min(m3-a1,u2) -- Recal AUTO MPT
			,@temp1 = CASE WHEN @im1 = 1 THEN @um1 ELSE @um2 END
			,@m1 = CASE 
						WHEN @im2 = 1 OR @im1 = 1 
						THEN CASE WHEN m.m3-@a1 > @temp1 THEN @temp1 ELSE m.m3-@a1 END 
						ELSE @m1 
					END
			
			,@temp1 = CASE WHEN @im1live = 1 THEN @um1live ELSE @um2live END
			,@m1live = CASE 
						WHEN @im2live = 1 OR @im1live = 1 
						THEN CASE WHEN m.m3live-@a1live > @temp1 THEN @temp1 ELSE m.m3live-@a1live END 
						ELSE @m1live 
					END
			
			-- rule #4: m1 = n3-a1 -- check master min/max
			,@m1 = CASE WHEN @a1+@m1 < m.n3 THEN m.n3-@a1 ELSE @m1 END			
			,@m1live = CASE WHEN @updateLIVE = 1 AND @a1live+@m1live < m.n3live THEN m.n3live-@a1live ELSE @m1live END

			-- rule #5: UPDATE m1,a1 WHEN m1+a1>l3
			/*	@x1 = min(m3,l3) -- mpt max
				@x2 = max(@x1-a1,0) --mpt
				m1 = (a1+m1>l3) ? @x2 : m1
				@x3 = (a1+@x2 > @x1) ? @x1-@x2 : a1
				a1 = (a1+m1>l1) ? max(@x3, n2) : a1
			*/
			,@temp1 = CASE WHEN m.m3 > m.l3 THEN m.l3 ELSE m.m3 END
			,@temp2 = CASE WHEN @temp1-@a1 < 0 THEN 0 ELSE @temp1-@a1 END
			,@m_new = CASE WHEN @a1+@m1 > m.l3 THEN @temp2 ELSE @m1 END
			,@temp3 = CASE WHEN @a1+@temp2 > @temp1 THEN @temp1-@temp2 ELSE @a1 END
			,@a_new = CASE 
						WHEN @a1+@m1 > m.l3 
						THEN CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
						ELSE @a1 
					END	
			,@m1 = @m_new
			,@a1 = @a_new
					
			,@temp1 = CASE WHEN m.m3live > m.l3live THEN m.l3live ELSE m.m3live END
			,@temp2 = CASE WHEN @temp1-@a1live < 0 THEN 0 ELSE @temp1-@a1live END
			,@m_new = CASE WHEN @updateLIVE = 1 AND @a1live+@m1live > m.l3live THEN @temp2 ELSE @m1live END
			,@temp3 = CASE WHEN @a1live+@temp2 > @temp1 THEN @temp1-@temp2 ELSE @a1live END
			,@a_new = CASE 
						WHEN @updateLIVE = 1 AND @a1live+@m1live > m.l3live 
						THEN CASE WHEN @temp3 < @n2live THEN @n2live ELSE @temp3 END
						ELSE @a1live 
					END	
			,@m1live = @m_new
			,@a1live = @a_new					
		
			-- rule #6 s1 = min(s4-m1-a1, i1?u1:u3) --Recalculate auto pt
			/*
				@x1 = (i1=1) ? u1 : u3
				s1 = (s4-m1-a1 > @x1) ? @x1 : s4-m1-a1 
			*/
			,@temp1 = CASE WHEN @i1 = 1 THEN @u1 ELSE m.u3 END			
			,@s1 = CASE 
						WHEN @i1 = 1 OR m.i3 = 1 
						THEN CASE WHEN s.s4-@m1-@a1 > @temp1 THEN @temp1 ELSE s.s4-@m1-@a1 END
						ELSE @s1
					END		

			,@temp1 = CASE WHEN @i1live = 1 THEN @u1live ELSE m.u3live END			
			,@s1live = CASE 
						WHEN @i1live = 1 OR m.i3live = 1 
						THEN CASE WHEN s.s4live-@m1live-@a1live > @temp1 THEN @temp1 ELSE s.s4live-@m1live-@a1live END
						ELSE @s1live
					END		
		
			-- rule #7: s1 = max(n4-m1-a1,s1) --super min
			,@s1 = CASE WHEN @a1+@m1+@s1 < s.n4 THEN s.n4-@m1-@a1 ELSE @s1 END
			,@s1live = CASE WHEN @updateLIVE = 1 AND @a1live+@m1live+@s1live < s.n4live THEN s.n4live-@m1live-@a1live ELSE @s1live END
		
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
			
			,@temp1 = CASE WHEN s.s4live-@m1live-@a1live < 0 THEN 0 ELSE s.s4live-@m1live-@a1live END
			,@s_new = CASE WHEN @updateLIVE = 1 AND @s1live+@a1live+@m1live > s.s4live THEN @temp1 ELSE @s1live END
			,@temp1 = CASE WHEN @temp1+@m1live+@a1live > s.s4live THEN s.s4live-@temp1 ELSE @m1live+@a1live END
			,@temp2 = CASE WHEN m.m3live > m.l3live THEN m.l3live ELSE m.m3live END
			,@temp2 = CASE WHEN @temp1 > @temp2 THEN @temp2 ELSE @temp1 END
			,@temp2 = CASE WHEN @temp2 < m.n3live THEN m.n3live ELSE @temp2 END
			,@temp3 = CASE WHEN @temp2-@a1live < 0 THEN 0 ELSE @temp2-@a1live END
			,@m_new = CASE WHEN @updateLIVE = 1 AND @s1live+@a1live+@m1live > s.s4live THEN @temp3 ELSE @m1live END
			,@temp3 = CASE WHEN @a1live+@temp3 > @temp2 THEN @temp2-@temp3 ELSE @a1live END
			,@temp3 = CASE WHEN @temp3 < @n2live THEN @n2live ELSE @temp3 END
			,@a_new = CASE WHEN @updateLIVE = 1 AND @s1live+@a1live+@m1live > s.s4live THEN @temp3 ELSE @a1live END		
			,@s1live = @s_new
			,@m1live = @m_new
			,@a1live = @a_new			
		
			--------------------------------	
			-- done apply all rule, then update to destination table
			,cs.apositiontaking = @a1
			,cs.mpositiontaking = @m1
			,cs.spositiontaking = @s1
			,cs.alivepositiontaking = @a1live
			,cs.mlivepositiontaking = @m1live
			,cs.slivepositiontaking = @s1live
		FROM dbo.custinfo c WITH(NOLOCK)
			INNER JOIN dbo.custsetting cs WITH(ROWLOCK, UPDLOCK) ON c.custid = cs.custid
			INNER JOIN dbo.custsetting acs WITH(NOLOCK) on c.recommend = acs.custid AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype
			INNER JOIN dbo.custoverride aco WITH(NOLOCK) on acs.custid = aco.custid AND cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype
			INNER JOIN @temp_mag m ON c.mrecommend = m.custid AND cs.sporttype = m.sporttype AND cs.bettype = m.bettype
			INNER JOIN @temp_sag s ON c.srecommend = s.custid AND cs.sporttype = s.sporttype AND cs.bettype = s.bettype
		WHERE c.recommend IN (select custid FROM @agList) AND c.roleid = 1 and c.enabled = 1			
		--*** END: update PT on member ***-----------------------		
	END	
END