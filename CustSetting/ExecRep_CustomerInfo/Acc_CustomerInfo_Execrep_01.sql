/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_01]
	@custid INT =0,
	@srecommend INT = 0,
	@mrecommend INT = 0,
	@recommend INT = 0,
	@mode NVARCHAR(50) = ''
AS
	/*
		Created: Johnson
		Date: 2013-11-12
		Task: Apply execrep when correct pt on member when create new member
		DB: DBCUST/CustDB
		Original versions: Acc_CustomerUpdMember_MinMaxPositiontaking
						Acc_CustomerUpdMemberHR_MinMaxPositiontaking
						Acc_CustomerUpdMemberVS_MinMaxPositiontaking
						
		Revisions:	
			- 20140318@Elodie: Add Keno product [Redmine:#13156]
			- 20150422@Elodie: Add Gold Deluxe product [Redmine:#34486]
			- 20170601@Elodie: Migrate Inspired VS to DCS structure [Redmine: #77274]

		  - 20150610@Daniel: 
			  + Improve medthod check table existing in subscribers
		  - 20180125@Winnie: Hide inactive products [RedmineID: #86086]  	
		  - 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
		  - 20230801@Johnson: adjust DCS products setting from LiteMode	[Redmine:#179159]
		  - 20240308@Johnson: HF wrong PT on group [redmine: #202053]
		  - 20231010@Eden: DCS Sportsbook Credit[redmine: #193083]
		  - 20240327@Johnson: HF wrong PT on group [redmine: #202119]
		  - 20241202@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
		  - 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969]  
		Parameter's Explanation:
	*/	
BEGIN
	SET NOCOUNT ON
	
	IF NOT (dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
		AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT	
	)
	RETURN;
				
	DECLARE @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney

	IF @mode = 'SportBook' OR @mode = 'LiteMode'
	BEGIN		
		--Get setting mode
		DECLARE @SettingMode BIT
		
		SELECT @SettingMode = IsGrouped
		FROM dbo.CustSettingMode3rd (NOLOCK)
		WHERE CustID = @CustID
		
		IF @SettingMode = 0
		BEGIN
			--check agent min/max
			--update a1=n2 when a1<n2
			UPDATE cs 
			SET 
				cs.AgentPT = aco.MinPT,
				cs.MasterPT = CASE WHEN cs.MasterPT + aco.MinPT > mcs.MasterPT THEN mcs.MasterPT-aco.MinPT ELSE cs.MasterPT END,
				RepUpdateTime = dbo.f_GetDateTime2()
			FROM 
				CustPTSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK)			
				INNER JOIN CustPTSetting3rd_Agent as mcs with (NOLOCK) on mcs.custid = @mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype AND mcs.IsLive = cs.IsLive
				INNER JOIN CustPTSetting3rd_Agent as aco with (NOLOCK) on aco.custid = @recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype AND mcs.IsLive = cs.IsLive
			WHERE cs.custid = @custid AND cs.AgentPT<aco.MinPT
			
			--Recal AUTO MPT 
			--Update m1=min(m4-a1,m3-a1,(im1?um1,um2))
			--if @updautomaster = 1
			--begin
			UPDATE cs
				SET MasterPT = 
					CASE WHEN scs.MasterPT > mcs.MasterPT THEN
							CASE WHEN mcs.MasterPT-cs.AgentPT > (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)
							THEN (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)
							ELSE  mcs.MasterPT-cs.AgentPT END
						ELSE 
							CASE WHEN scs.MasterPT-cs.AgentPT > (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)
							THEN (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)
							ELSE  scs.MasterPT-cs.AgentPT END
						END,
					RepUpdateTime = dbo.f_GetDateTime2()
			FROM
				CustPTSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK)					
				INNER JOIN CustPTSetting3rd_Agent as mcs with (NOLOCK) on mcs.custid = @mrecommend AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype AND mcs.IsLive = cs.IsLive
				INNER JOIN CustPTSetting3rd_Agent as scs with (NOLOCK) on scs.custid = @srecommend AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype AND scs.IsLive = cs.IsLive
				INNER JOIN CustPTSetting3rd_Agent as acs with (NOLOCK) on acs.custid = @recommend AND acs.sporttype=cs.sporttype AND acs.bettype=cs.bettype AND acs.IsLive = cs.IsLive
			WHERE
				cs.custid = @custid			
				AND (acs.IsAutoMasterPT = 1 or cs.IsAutoMasterPT = 1)
				
				
			--check master min/max
			--update m1=n3-a1 if a1+m1<n3
			UPDATE cs 
			SET 
				MasterPT = mco.MinPT-cs.AgentPT,
				RepUpdateTime = dbo.f_GetDateTime2()
			FROM 
				CustPTSetting3rd_Member cs with (ROWLOCK, UPDLOCK)			
				INNER JOIN CustPTSetting3rd_Agent as mco WITH (NOLOCK) on mco.custid = @mrecommend  AND mco.sporttype=cs.sporttype AND mco.bettype=cs.bettype AND mco.IsLive = cs.IsLive
			WHERE cs.custid = @custid 
				AND cs.AgentPT+cs.MasterPT<mco.MinPT
			
			--recal autopos
			--if @updautosuper = 1 
			--begin
			UPDATE cs
				SET SuperPT = CASE WHEN scs.SuperPT-cs.MasterPT-cs.AgentPT >
										(CASE WHEN cs.IsAutoSuperPT=1 THEN cs.AutoSuperPT ELSE mcs.AutoSuperPT END) 
									THEN (CASE WHEN cs.IsAutoSuperPT=1 THEN cs.AutoSuperPT ELSE mcs.AutoSuperPT END) 
									ELSE scs.SuperPT-cs.MasterPT-cs.AgentPT END ,
					RepUpdateTime = dbo.f_GetDateTime2()				
			FROM
				CustPTSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK) 			
				INNER JOIN CustPTSetting3rd_Agent as mcs WITH (NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype AND mcs.IsLive = cs.IsLive
				INNER JOIN CustPTSetting3rd_Agent as scs WITH (NOLOCK) ON scs.custid = @srecommend AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype AND scs.IsLive = cs.IsLive
			where
				cs.custid = @custid			
				AND (cs.IsAutoSuperPT=1 OR mcs.IsAutoSuperPT=1)

			--check super min/max
			--update s1 when s1+m1+a1<n4 
			UPDATE cs
			SET SuperPT = sco.MinPT-cs.MasterPT-cs.AgentPT,
				RepUpdateTime = dbo.f_GetDateTime2()
			FROM 
				CustPTSetting3rd_Member cs with (ROWLOCK, UPDLOCK)			
				INNER JOIN CustPTSetting3rd_Agent as sco with (NOLOCK) on sco.custid = @srecommend  AND sco.sporttype=cs.sporttype AND sco.bettype=cs.bettype AND sco.IsLive = cs.IsLive
			WHERE cs.custid = @custid 
				AND cs.AgentPT+cs.MasterPT+cs.SuperPT<sco.MinPT

			--update s1,m1,a1 in case s1+m1+a1>s4
			--s1=max(0,s4-m1-a1)
			--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
			--@maxmapos=min(m3,l3)
			--@mapos2=min(@mapos1,@maxmapos)
			--@mapos=max(@mapos2,n3)
			--m1=max(0,@mapos-a1)
			--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
			UPDATE cs
			SET 
				@spos = CASE WHEN scs.SuperPT-cs.MasterPT-cs.AgentPT<0 THEN 0 ELSE scs.SuperPT-cs.MasterPT-cs.AgentPT END,
				SuperPT = @spos,
				@mapos1 = CASE WHEN @spos+cs.MasterPT+cs.AgentPT>scs.SuperPT THEN scs.SuperPT-@spos ELSE cs.MasterPT+cs.AgentPT END,
				@maxmapos = CASE WHEN mcs.MasterPT>mcs.MaxPT THEN mcs.MaxPT ELSE mcs.MasterPT END,
				@mapos2 = CASE WHEN @mapos1>@maxmapos THEN @maxmapos ELSE @mapos1 END,
				@mapos = CASE WHEN @mapos2<mcs.MinPT THEN mcs.MinPT ELSE @mapos2 END,
				@mpos = CASE WHEN @mapos-cs.AgentPT<0 THEN 0 else @mapos-cs.AgentPT END,
				MasterPT = @mpos,
				@apos = CASE WHEN cs.AgentPT + @mpos>@mapos THEN @mapos-@mpos ELSE cs.AgentPT END,
				AgentPT = CASE WHEN @apos<aco.MinPT THEN aco.MinPT ELSE @apos END,
				RepUpdateTime = dbo.f_GetDateTime2()
			FROM 
				CustPTSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK)  			
				INNER JOIN CustPTSetting3rd_Agent as scs WITH (NOLOCK) on scs.custid = @srecommend  AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype AND scs.IsLive = cs.IsLive
				INNER JOIN CustPTSetting3rd_Agent as mcs WITH (NOLOCK) on mcs.custid = @mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype AND mcs.IsLive = cs.IsLive			
				INNER JOIN CustPTSetting3rd_Agent as aco WITH (NOLOCK) on aco.custid = @recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype AND aco.IsLive = cs.IsLive
			WHERE cs.custid = @custid 
				AND cs.SuperPT+cs.AgentPT+cs.MasterPT>scs.SuperPT
			
			--check to group PT
			IF EXISTS (SELECT TOP 1 1
						FROM dbo.CustPTGroupSetting3rd_Member grp WITH(NOLOCK)
						WHERE grp.AgentID = @recommend
						)
				AND NOT EXISTS(SELECT TOP 1 1
								FROM dbo.CustPTGroupSetting3rd_Member grp WITH(NOLOCK) 
								JOIN CustPTSetting3rd_Member cs WITH(NOLOCK) ON cs.SportType = grp.SportType
														AND cs.BetType = grp.BetType
														AND cs.Islive = grp.Islive
								WHERE grp.AgentID = @recommend
								AND cs.custid = @custid
								AND (
									cs.SuperPT <> grp.SuperPT
									OR
									cs.MasterPT <> grp.MasterPT
									OR
									cs.AgentPT <> grp.AgentPT
									OR
									cs.IsAutoMasterPT <> grp.IsAutoMasterPT
									OR
									cs.AutoMasterPT <> grp.AutoMasterPT
									OR
									cs.IsAutoSuperPT <> grp.IsAutoSuperPT
									OR
									cs.AutoSuperPT <> grp.AutoSuperPT
								))
						AND @srecommend IN (
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
				UPDATE cs 
				SET IsGrouped = 1,
					RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.CustSettingMode3rd cs WITH(ROWLOCK)
				WHERE CustID = @CustID
				
				DELETE CustPTSetting3rd_Member WITH(ROWLOCK) 
				OUTPUT DELETED.custid,DELETED.Sporttype,DELETED.Bettype,DELETED.IsLive,dbo.f_GetDateTime2()
				INTO CustPTSetting3rd_Member_Del_Inhouse(custid,SportType,Bettype,IsLive,RepUpdateTime)
				WHERE custid = @custid
			END	
		END
		ELSE
		BEGIN 
			--check agent min/max
			--update a1=n2 when a1<n2
			UPDATE cs 
			SET 
				cs.AgentPT = aco.MinPT,
				cs.MasterPT = CASE WHEN cs.MasterPT + aco.MinPT > mcs.MasterPT THEN mcs.MasterPT-aco.MinPT ELSE cs.MasterPT END,
				RepUpdateTime = dbo.f_GetDateTime2()
			FROM 
				CustPTGroupSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK)			
				INNER JOIN CustPTSetting3rd_Agent as mcs with (NOLOCK) on mcs.custid = @mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype AND mcs.IsLive = cs.IsLive
				INNER JOIN CustPTSetting3rd_Agent as aco with (NOLOCK) on aco.custid = @recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype AND mcs.IsLive = cs.IsLive
			WHERE cs.AgentID = @recommend AND cs.AgentPT<aco.MinPT
			
			--Recal AUTO MPT 
			--Update m1=min(m4-a1,m3-a1,(im1?um1,um2))
			--if @updautomaster = 1
			--begin
			UPDATE cs
				SET MasterPT = 
					CASE WHEN scs.MasterPT > mcs.MasterPT THEN
							CASE WHEN mcs.MasterPT-cs.AgentPT > (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)
							THEN (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)
							ELSE  mcs.MasterPT-cs.AgentPT END
						ELSE 
							CASE WHEN scs.MasterPT-cs.AgentPT > (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)
							THEN (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)
							ELSE  scs.MasterPT-cs.AgentPT END
						END,
					RepUpdateTime = dbo.f_GetDateTime2()	
			FROM
				CustPTGroupSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK)					
				INNER JOIN CustPTSetting3rd_Agent as mcs with (NOLOCK) on mcs.custid = @mrecommend AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype AND mcs.IsLive = cs.IsLive
				INNER JOIN CustPTSetting3rd_Agent as scs with (NOLOCK) on scs.custid = @srecommend AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype AND scs.IsLive = cs.IsLive
				INNER JOIN CustPTSetting3rd_Agent as acs with (NOLOCK) on acs.custid = @recommend AND acs.sporttype=cs.sporttype AND acs.bettype=cs.bettype AND acs.IsLive = cs.IsLive
			WHERE
				cs.AgentID = @recommend		
				AND (acs.IsAutoMasterPT = 1 or cs.IsAutoMasterPT = 1)			
				
			--check master min/max
			--update m1=n3-a1 if a1+m1<n3
			UPDATE cs 
			SET 
				MasterPT = mco.MinPT-cs.AgentPT,
				RepUpdateTime = dbo.f_GetDateTime2()
			FROM 
				CustPTGroupSetting3rd_Member cs with (ROWLOCK, UPDLOCK)			
				INNER JOIN CustPTSetting3rd_Agent as mco WITH (NOLOCK) on mco.custid = @mrecommend  AND mco.sporttype=cs.sporttype AND mco.bettype=cs.bettype AND mco.IsLive = cs.IsLive
			WHERE cs.AgentID = @recommend	 
				AND cs.AgentPT+cs.MasterPT<mco.MinPT
			
			--recal autopos
			--if @updautosuper = 1 
			--begin
			UPDATE cs
				SET SuperPT = CASE WHEN scs.SuperPT-cs.MasterPT-cs.AgentPT >
										(CASE WHEN cs.IsAutoSuperPT=1 THEN cs.AutoSuperPT ELSE mcs.AutoSuperPT END) 
									THEN (CASE WHEN cs.IsAutoSuperPT=1 THEN cs.AutoSuperPT ELSE mcs.AutoSuperPT END) 
									ELSE scs.SuperPT-cs.MasterPT-cs.AgentPT END,
					RepUpdateTime = dbo.f_GetDateTime2()					
			FROM
				CustPTGroupSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK) 			
				INNER JOIN CustPTSetting3rd_Agent as mcs WITH (NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype AND mcs.IsLive = cs.IsLive
				INNER JOIN CustPTSetting3rd_Agent as scs WITH (NOLOCK) ON scs.custid = @srecommend AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype AND scs.IsLive = cs.IsLive
			where
				cs.AgentID = @recommend		
				AND (cs.IsAutoSuperPT=1 OR mcs.IsAutoSuperPT=1)

			--check super min/max
			--update s1 when s1+m1+a1<n4 
			UPDATE cs
			SET SuperPT = sco.MinPT-cs.MasterPT-cs.AgentPT,
				RepUpdateTime = dbo.f_GetDateTime2()
			FROM 
				CustPTGroupSetting3rd_Member cs with (ROWLOCK, UPDLOCK)			
				INNER JOIN CustPTSetting3rd_Agent as sco with (NOLOCK) on sco.custid = @srecommend  AND sco.sporttype=cs.sporttype AND sco.bettype=cs.bettype AND sco.IsLive = cs.IsLive
			WHERE cs.AgentID = @recommend 
				AND cs.AgentPT+cs.MasterPT+cs.SuperPT<sco.MinPT

			--update s1,m1,a1 in case s1+m1+a1>s4
			--s1=max(0,s4-m1-a1)
			--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
			--@maxmapos=min(m3,l3)
			--@mapos2=min(@mapos1,@maxmapos)
			--@mapos=max(@mapos2,n3)
			--m1=max(0,@mapos-a1)
			--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
			UPDATE cs
			SET 
				@spos = CASE WHEN scs.SuperPT-cs.MasterPT-cs.AgentPT<0 THEN 0 ELSE scs.SuperPT-cs.MasterPT-cs.AgentPT END,
				SuperPT = @spos,
				@mapos1 = CASE WHEN @spos+cs.MasterPT+cs.AgentPT>scs.SuperPT THEN scs.SuperPT-@spos ELSE cs.MasterPT+cs.AgentPT END,
				@maxmapos = CASE WHEN mcs.MasterPT>mcs.MaxPT THEN mcs.MaxPT ELSE mcs.MasterPT END,
				@mapos2 = CASE WHEN @mapos1>@maxmapos THEN @maxmapos ELSE @mapos1 END,
				@mapos = CASE WHEN @mapos2<mcs.MinPT THEN mcs.MinPT ELSE @mapos2 END,
				@mpos = CASE WHEN @mapos-cs.AgentPT<0 THEN 0 else @mapos-cs.AgentPT END,
				MasterPT = @mpos,
				@apos = CASE WHEN cs.AgentPT + @mpos>@mapos THEN @mapos-@mpos ELSE cs.AgentPT END,
				AgentPT = CASE WHEN @apos<aco.MinPT THEN aco.MinPT ELSE @apos END,
				RepUpdateTime = dbo.f_GetDateTime2()
			FROM 
				CustPTGroupSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK)  			
				INNER JOIN CustPTSetting3rd_Agent as scs WITH (NOLOCK) on scs.custid = @srecommend  AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype AND scs.IsLive = cs.IsLive
				INNER JOIN CustPTSetting3rd_Agent as mcs WITH (NOLOCK) on mcs.custid = @mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype AND mcs.IsLive = cs.IsLive			
				INNER JOIN CustPTSetting3rd_Agent as aco WITH (NOLOCK) on aco.custid = @recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype AND aco.IsLive = cs.IsLive
			WHERE cs.AgentID = @recommend
				AND cs.SuperPT+cs.AgentPT+cs.MasterPT>scs.SuperPT
		END
	END
	ELSE IF @Mode = 'Direct'
	BEGIN	
		DECLARE @PT_VirtualUpline TABLE (
			 IsAutoMasterPT	bit
			,IsAutoSuperPT	bit
			,SuperPT		smallmoney
			,MasterPT		smallmoney
			,AgentPT		smallmoney
			,AutoSuperPT	smallmoney
			,AutoMasterPT	smallmoney
			,MinPT			smallmoney
			,MaxPT			smallmoney
		)
		INSERT INTO @PT_VirtualUpline(IsAutoMasterPT,IsAutoSuperPT,SuperPT	,MasterPT,AgentPT,AutoSuperPT,AutoMasterPT,MinPT,MaxPT)
		SELECT 0,0,0,0,0,0,0,0,0

		IF @recommend = -3 -- Master direct member
		BEGIN
			--check master min/max
			--update m1=n3-a1 if a1+m1<n3
			UPDATE cs 
			SET MasterPT = mco.MinPT-cs.AgentPT,
				RepUpdateTime = dbo.f_GetDateTime2()
			FROM CustPTSetting3rd_Member cs with (ROWLOCK, UPDLOCK)			
				INNER JOIN CustPTSetting3rd_Agent as mco WITH (NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs.sporttype AND mco.bettype=cs.bettype AND mco.IsLive = cs.IsLive
			WHERE cs.custid = @custid 
				AND cs.AgentPT+cs.MasterPT<mco.MinPT
			
			--recal autopos
			--if @updautosuper = 1 
			--begin
			UPDATE cs
			SET SuperPT = CASE WHEN scs.SuperPT-cs.MasterPT-cs.AgentPT >
									(CASE WHEN cs.IsAutoSuperPT=1 THEN cs.AutoSuperPT ELSE mcs.AutoSuperPT END) 
								THEN (CASE WHEN cs.IsAutoSuperPT=1 THEN cs.AutoSuperPT ELSE mcs.AutoSuperPT END) 
							ELSE scs.SuperPT-cs.MasterPT-cs.AgentPT END ,
				RepUpdateTime = dbo.f_GetDateTime2()
			FROM CustPTSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK) 			
				INNER JOIN CustPTSetting3rd_Agent as mcs WITH (NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype AND mcs.IsLive = cs.IsLive
				INNER JOIN CustPTSetting3rd_Agent as scs WITH (NOLOCK) ON scs.custid = @srecommend AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype AND scs.IsLive = cs.IsLive
			where
				cs.custid = @custid			
				AND (cs.IsAutoSuperPT=1 OR mcs.IsAutoSuperPT=1)
		END

		--check super min/max
		--update s1 when s1+m1+a1<n4 
		UPDATE cs
		SET SuperPT = sco.MinPT-cs.MasterPT-cs.AgentPT,
			RepUpdateTime = dbo.f_GetDateTime2()
		FROM CustPTSetting3rd_Member cs with (ROWLOCK, UPDLOCK)			
			INNER JOIN CustPTSetting3rd_Agent as sco with (NOLOCK) on sco.custid = @srecommend  AND sco.sporttype=cs.sporttype AND sco.bettype=cs.bettype AND sco.IsLive = cs.IsLive
		WHERE cs.custid = @custid 
			AND cs.AgentPT+cs.MasterPT+cs.SuperPT<sco.MinPT

		--update s1,m1,a1 in case s1+m1+a1>s4
		--s1=max(0,s4-m1-a1)
		--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
		--@maxmapos=min(m3,l3)
		--@mapos2=min(@mapos1,@maxmapos)
		--@mapos=max(@mapos2,n3)
		--m1=max(0,@mapos-a1)
		UPDATE cs
		SET 
			@spos = CASE WHEN scs.SuperPT-cs.MasterPT-cs.AgentPT<0 THEN 0 ELSE scs.SuperPT-cs.MasterPT-cs.AgentPT END,
			SuperPT = @spos,
			@mapos1 = CASE WHEN @spos+cs.MasterPT+cs.AgentPT>scs.SuperPT THEN scs.SuperPT-@spos ELSE cs.MasterPT+cs.AgentPT END,
			@maxmapos = CASE WHEN mcs.MasterPT>mcs.MaxPT THEN mcs.MaxPT ELSE mcs.MasterPT END,
			@mapos2 = CASE WHEN @mapos1>@maxmapos THEN @maxmapos ELSE @mapos1 END,
			@mapos = CASE WHEN @mapos2<mcs.MinPT THEN mcs.MinPT ELSE @mapos2 END,
			@mpos = CASE WHEN @mapos-cs.AgentPT<0 THEN 0 else @mapos-cs.AgentPT END,
			MasterPT = @mpos,
			RepUpdateTime = dbo.f_GetDateTime2()
		FROM 
			CustPTSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK)  			
			INNER JOIN CustPTSetting3rd_Agent as scs WITH (NOLOCK) on scs.custid = @srecommend  AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype AND scs.IsLive = cs.IsLive
			CROSS JOIN @PT_VirtualUpline as mcs 			
		WHERE cs.custid = @custid 
			AND cs.SuperPT+cs.AgentPT+cs.MasterPT>scs.SuperPT
	END
END
GO