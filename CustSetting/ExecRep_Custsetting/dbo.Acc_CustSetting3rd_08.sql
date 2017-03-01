ALTER PROCEDURE [dbo].[Acc_Custsetting3rd_08]
	@custid INT = 0,
	@mode VARCHAR(50) ='',
	@roleid INT,
	--super update pt on member
	--number game
	@v161spositiontaking_81 SMALLMONEY = 0,
	@v161spositiontaking_83 SMALLMONEY = 0,
	@v161spositiontaking_86 SMALLMONEY = 0,
	@v161spositiontaking_88 SMALLMONEY = 0,
	@v161slivepositiontaking_85 SMALLMONEY = 0,
	@v161slivepositiontaking_86 SMALLMONEY = 0,
	@v161slivepositiontaking_87 SMALLMONEY = 0,
	@v161slivepositiontaking_89 SMALLMONEY = 0,
	@v161slivepositiontaking_90 SMALLMONEY = 0,
	
	--horse racing
	@v151spositiontaking_31 SMALLMONEY = 0,
	@v151spositiontaking_32 SMALLMONEY = 0,
	@v151spositiontaking_41 SMALLMONEY = 0,
	@v151spositiontaking_42 SMALLMONEY = 0,
	@v151spositiontaking_51 SMALLMONEY = 0,
	@v151spositiontaking_52 SMALLMONEY = 0,
	@v152spositiontaking_41 SMALLMONEY = 0,
	@v152spositiontaking_42 SMALLMONEY = 0,
	@v152spositiontaking_51 SMALLMONEY = 0,
	@v152spositiontaking_52 SMALLMONEY = 0,
	@v153spositiontaking_51 SMALLMONEY = 0,
	@v153spositiontaking_52 SMALLMONEY = 0,
	
	---master update pt on member
	--number game
	@v161mpositiontaking_81 SMALLMONEY  = 0,
	@v161mpositiontaking_83 SMALLMONEY  = 0,
	@v161mpositiontaking_86 SMALLMONEY  = 0,
	@v161mpositiontaking_88 SMALLMONEY = 0,
	@v161mlivepositiontaking_85 SMALLMONEY  = 0,
	@v161mlivepositiontaking_86 SMALLMONEY  = 0,
	@v161mlivepositiontaking_87 SMALLMONEY  = 0,
	@v161mlivepositiontaking_89 SMALLMONEY = 0,
	@v161mlivepositiontaking_90 SMALLMONEY = 0,
	
	--horse racing
	@v151mpositiontaking_31 smallmoney  = 0,
	@v151mpositiontaking_32 smallmoney  = 0,
	@v151mpositiontaking_41 smallmoney  = 0,
	@v151mpositiontaking_42 smallmoney  = 0,
	@v151mpositiontaking_51 smallmoney = 0,
	@v151mpositiontaking_52 smallmoney = 0,
	@v152mpositiontaking_41 smallmoney = 0,
	@v152mpositiontaking_42 smallmoney = 0,
	@v152mpositiontaking_51 smallmoney = 0,
	@v152mpositiontaking_52 smallmoney = 0,
	@v153mpositiontaking_51 smallmoney = 0,
	@v153mpositiontaking_52 smallmoney = 0,
	
	--agent update pt on member
	--number game
	@v161apositiontaking_81 smallmoney = 0, 
	@v161apositiontaking_83 smallmoney = 0, 	
	@v161apositiontaking_86 smallmoney = 0, 
	@v161apositiontaking_88 smallmoney = 0, 
	@v161alivepositiontaking_85 smallmoney = 0,
	@v161alivepositiontaking_86 smallmoney = 0,
	@v161alivepositiontaking_87 smallmoney = 0,
	@v161alivepositiontaking_89 smallmoney = 0,
	@v161alivepositiontaking_90 smallmoney = 0,
	
	--horse racing	
	@v151apositiontaking_31 SMALLMONEY = 0,
	@v151apositiontaking_32 SMALLMONEY = 0,
	@v151apositiontaking_41 SMALLMONEY = 0,
	@v151apositiontaking_42 SMALLMONEY = 0,
	@v151apositiontaking_51 SMALLMONEY = 0,
	@v151apositiontaking_52 SMALLMONEY = 0,
	@v152apositiontaking_41 SMALLMONEY = 0,
	@v152apositiontaking_42 SMALLMONEY = 0,
	@v152apositiontaking_51 SMALLMONEY = 0,
	@v152apositiontaking_52 SMALLMONEY = 0,
	@v153apositiontaking_51 SMALLMONEY = 0,
	@v153apositiontaking_52 SMALLMONEY = 0,
			
	@UpdateMultiple BIT = 0,
	@UpdatePositiontakingv151_31 BIT = 1,
	@UpdatePositiontakingv151_41 BIT = 1,
	@UpdatePositiontakingv151_51 BIT = 1,
	@UpdatePositiontakingv152_41 BIT = 1,
	@UpdatePositiontakingv152_51 BIT = 1,
	@UpdatePositiontakingv153_51 BIT = 1
	
AS
	/*
		Created: Johnson
		Date: 2013-10-30
		Task: Apply execrep update pt on member
		DB: DBCUST/bodb02
		Original versions: Acc_CustomerUpdMember_Super
					Acc_CustomerUpdMember_Master
					Acc_CustomerUpdMember_PositionTaking
					Acc_CustomerUpdMemberHR_SAg
					Acc_CustomerUpdMemberHR_MAg
					Acc_CustomerUpdMemberHR_PositionTaking
					
		Revision:
			- 20131104@Johnson: Add live casino, racing
			- 20140221@Johnson: merge code correct pt after update pt on member for number game [RedmineId: #11562]
			- 20140313@Johnson: merge code correct pt after update pt on member for racing
			 - 20150610@Daniel: 
		    + Improve medthod check table existing in subscribers	
		    + Separate custDB to new server DBCUST  				
		Parameter's Explanation:
	*/ 
BEGIN
SET NOCOUNT ON
	if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	     AND dbo.f_CheckRepTable('CustSetting3rd') = 1 
	     AND dbo.f_CheckRepTable('CustOverride3rd') = 1 
     )
	   	RETURN  
	
	DECLARE @tmp_cs TABLE(custid int, sporttype smallint, bettype smallint,
		 spositiontaking smallmoney, mpositiontaking smallmoney, apositiontaking smallmoney,autopositiontaking smallmoney, autompositiontaking smallmoney, isautopositiontaking bit, isautompositiontaking bit,
		 slivepositiontaking smallmoney, mlivepositiontaking smallmoney, alivepositiontaking smallmoney, isautolivepositiontaking bit, isautomlivepositiontaking bit
		)
			
	DECLARE @tmp_sag TABLE(custid int, sporttype smallint, bettype smallint,
		spositiontaking smallmoney, slivepositiontaking smallmoney, minpositiontaking smallmoney, minlivepositiontaking smallmoney, maxpositiontaking smallmoney, maxlivepositiontaking smallmoney
	) 
	
	DECLARE @tmp_mag TABLE(custid int, sporttype smallint, bettype smallint,
		mpositiontaking smallmoney, mlivepositiontaking smallmoney, autopositiontaking smallmoney, isautopositiontaking bit, isautolivepositiontaking bit, 
		minpositiontaking smallmoney, minlivepositiontaking smallmoney, maxpositiontaking smallmoney, maxlivepositiontaking smallmoney
	)
	
	DECLARE @tmp_ag TABLE(custid int, sporttype smallint, bettype smallint,
		autompositiontaking smallmoney,	isautompositiontaking bit, isautolivempositiontaking bit, 
		minpositiontaking smallmoney, minlivepositiontaking smallmoney, maxpositiontaking smallmoney, maxlivepositiontaking smallmoney)
	
	DECLARE @srecommend int, @mrecommend int, @recommend int, 
			@mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney


	IF @mode = 'number'
	BEGIN	
		IF @roleid IN (3,4)
		BEGIN	
			SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend
			FROM custinfo WITH(NOLOCK)
			WHERE custid = @custid 
			
			INSERT INTO @tmp_cs(custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking,
							slivepositiontaking, mlivepositiontaking, alivepositiontaking)
			SELECT cs.custid, cs.sporttype, cs.bettype, cs.spositiontaking, cs.mpositiontaking, cs.apositiontaking
					, cs.slivepositiontaking, cs.mlivepositiontaking, cs.alivepositiontaking
			FROM custsetting3rd cs with(NOLOCK)			
			WHERE cs.custid = @custid and sporttype = 161
			
			INSERT INTO @tmp_sag(custid, sporttype, bettype, spositiontaking, slivepositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
			SELECT scs.custid, scs.sporttype, scs.bettype, spositiontaking, slivepositiontaking, sco.minpositiontaking, sco.minlivepositiontaking, sco.maxpositiontaking, sco.maxlivepositiontaking
			FROM custsetting3rd scs with(NOLOCK)
				INNER JOIN custoverride3rd sco WITH(NOLOCK) on scs.custid = sco.custid and scs.sporttype = sco.sporttype and scs.bettype = sco.bettype
			WHERE scs.custid = @srecommend and scs.sporttype = 161
			
			INSERT INTO @tmp_mag(custid, sporttype, bettype, mpositiontaking, mlivepositiontaking, isautopositiontaking, isautolivepositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
			SELECT mcs.custid, mcs.sporttype, mcs.bettype, mpositiontaking, mlivepositiontaking, isautopositiontaking, isautolivepositiontaking, mco.minpositiontaking, mco.minlivepositiontaking, mco.maxpositiontaking, mco.maxlivepositiontaking
			FROM custsetting3rd mcs WITH(NOLOCK)
				inner JOIN custoverride3rd mco WITH(NOLOCK) on mcs.custid = mco.custid and mcs.sporttype = mco.sporttype and mcs.bettype = mco.bettype
			WHERE mcs.custid = @mrecommend and mcs.sporttype = 161
			
			INSERT INTO @tmp_ag(custid, sporttype, bettype, isautompositiontaking, isautolivempositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
			SELECT cs.custid, cs.sporttype, cs.bettype, isautompositiontaking, isautolivempositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking
			FROM custoverride3rd co WITH(NOLOCK)
				INNER JOIN custsetting3rd cs WITH(NOLOCK) ON co.custid = cs.custid and co.sporttype = cs.sporttype and co.bettype = cs.bettype
			WHERE cs.custid = @recommend and cs.sporttype = 161 	
		
			IF @roleid = 4
			BEGIN
				update cs3
				set cs3.spositiontaking = case cs3.sporttype WHEN 161 THEN case cs3.bettype WHEN 81 THEN @v161spositiontaking_81 
																							WHEN 83 THEN @v161spositiontaking_83
																							WHEN 86 THEN @v161spositiontaking_86
																							WHEN 88 THEN @v161spositiontaking_88
																							ELSE 0 END
															ELSE cs3.spositiontaking END
				from @tmp_cs cs3
					inner JOIN @tmp_mag mcs3 on cs3.sporttype = mcs3.sporttype and cs3.bettype = mcs3.bettype
				where mcs3.isautopositiontaking = 0
				
				update cs3
				set cs3.slivepositiontaking = case cs3.sporttype WHEN 161 THEN case cs3.bettype WHEN 85 THEN @v161slivepositiontaking_85 
																								WHEN 86 THEN @v161slivepositiontaking_86 
																								WHEN 87 THEN @v161slivepositiontaking_87 
																								WHEN 89 THEN @v161slivepositiontaking_89
																								WHEN 90 THEN @v161slivepositiontaking_90
																								ELSE cs3.slivepositiontaking END 
																 ELSE cs3.slivepositiontaking END
				from @tmp_cs cs3
					inner JOIN @tmp_mag mcs3 on cs3.sporttype = mcs3.sporttype and cs3.bettype = mcs3.bettype
				where mcs3.isautolivepositiontaking = 0
				
				/*
				UPDATE cs3 with(rowlock,updlock)
				SET cs3.spositiontaking = case cs3.sporttype WHEN 161 THEN case cs3.bettype WHEN 81 THEN @v161spositiontaking_81 
																							WHEN 83 THEN @v161spositiontaking_83
																							WHEN 86 THEN @v161spositiontaking_86
																							WHEN 88 THEN @v161spositiontaking_88
																							ELSE 0 END
															ELSE cs3.spositiontaking END
				from custsetting3rd cs3 INNER JOIN custinfo c with(nolock) on cs3.custid = c.custid
					 INNER JOIN custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and cs3.sporttype = mcs3.sporttype and cs3.bettype = mcs3.bettype
				where cs3.custid =@custid and c.roleid = 1 and mcs3.isautopositiontaking = 0	
			
				UPDATE cs3 with (ROWLOCK, UPDLOCK)
				set
					cs3.slivepositiontaking = case cs3.sporttype WHEN 161 THEN case cs3.bettype WHEN 85 THEN @v161slivepositiontaking_85 
																								WHEN 86 THEN @v161slivepositiontaking_86 
																								WHEN 87 THEN @v161slivepositiontaking_87 
																								WHEN 89 THEN @v161slivepositiontaking_89
																								WHEN 90 THEN @v161slivepositiontaking_90
																								ELSE cs3.slivepositiontaking END 
																 ELSE cs3.slivepositiontaking END
				from custsetting3rd cs3 INNER JOIN custinfo c (nolock) on cs3.custid = c.custid
					INNER JOIN custsetting3rd mcs3 (nolock) on mcs3.custid = c.mrecommend and cs3.sporttype = mcs3.sporttype and cs3.bettype = mcs3.bettype
				where cs3.custid=@custid and c.roleid = 1 and mcs3.isautolivepositiontaking = 0		
				*/
			END
			ELSE IF @Roleid = 3
			BEGIN
				--don't update m1,s1 for member under agent was set im2=1
				UPDATE cs3
				SET mpositiontaking = CASE cs3.sporttype 	WHEN 161 THEN CASE cs3.bettype	WHEN 81 THEN @v161mpositiontaking_81 
																							WHEN 83 THEN @v161mpositiontaking_83 
																							WHEN 86 THEN @v161mpositiontaking_86 
																							WHEN 88 THEN @v161mpositiontaking_88 																			
																			ELSE 0 END					
										ELSE cs3.mpositiontaking END,

					spositiontaking =  CASE cs3.sporttype WHEN 161 THEN CASE cs3.bettype WHEN 81 THEN @v161spositiontaking_81 
																						WHEN 83 THEN @v161spositiontaking_83 
																						WHEN 86 THEN @v161spositiontaking_86 
																						WHEN 88 THEN @v161spositiontaking_88 																		
																		ELSE 0 END					
										ELSE cs3.spositiontaking END
				FROM @tmp_cs cs3
					INNER JOIN @tmp_ag acs3 ON cs3.sporttype = acs3.sporttype AND cs3.bettype = acs3.bettype 
				WHERE acs3.isautompositiontaking = 0
				
				--don't update m1,s1 for member under agent was set im2=1(live)
				UPDATE cs3
				SET	mlivepositiontaking = CASE cs3.sporttype 	WHEN 161 THEN CASE cs3.bettype WHEN 85 THEN @v161mlivepositiontaking_85 WHEN 86 THEN @v161mlivepositiontaking_86 WHEN 87 THEN @v161mlivepositiontaking_87 WHEN 89 THEN @v161mlivepositiontaking_89 WHEN 90 THEN @v161mlivepositiontaking_90 ELSE cs3.mlivepositiontaking END ELSE cs3.mlivepositiontaking END,
					slivepositiontaking = CASE cs3.sporttype 	WHEN 161 THEN CASE cs3.bettype WHEN 85 THEN @v161slivepositiontaking_85 WHEN 86 THEN @v161slivepositiontaking_86 WHEN 87 THEN @v161slivepositiontaking_87 WHEN 89 THEN @v161slivepositiontaking_89 WHEN 90 THEN @v161slivepositiontaking_90 ELSE cs3.slivepositiontaking END ELSE cs3.slivepositiontaking END				
				FROM @tmp_cs cs3
					INNER JOIN @tmp_ag acs3 ON cs3.sporttype = acs3.sporttype AND cs3.bettype = acs3.bettype 
				WHERE acs3.isautolivempositiontaking = 0 	
			
				/*
				--don't update m1,s1 for member under agent was set im2=1
				UPDATE cs3 WITH (ROWLOCK, UPDLOCK)
				SET
					mpositiontaking = CASE cs3.sporttype 	WHEN 161 THEN CASE cs3.bettype	WHEN 81 THEN @v161mpositiontaking_81 
																							WHEN 83 THEN @v161mpositiontaking_83 
																							WHEN 86 THEN @v161mpositiontaking_86 
																							WHEN 88 THEN @v161mpositiontaking_88 																			
																			ELSE 0 END					
										ELSE cs3.mpositiontaking END,

					spositiontaking =  CASE cs3.sporttype WHEN 161 THEN CASE cs3.bettype WHEN 81 THEN @v161spositiontaking_81 
																						WHEN 83 THEN @v161spositiontaking_83 
																						WHEN 86 THEN @v161spositiontaking_86 
																						WHEN 88 THEN @v161spositiontaking_88 																		
																		ELSE 0 END					
										ELSE cs3.spositiontaking END
				FROM Custsetting3rd cs3 INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
					INNER JOIN Custsetting3rd acs3 WITH(NOLOCK) ON acs3.custid = c.recommend AND cs3.sporttype = acs3.sporttype AND cs3.bettype = acs3.bettype 
				WHERE c.custid=@custid AND c.roleid = 1 AND acs3.isautompositiontaking = 0 
				
				--don't update m1,s1 for member under agent was set im2=1(live)
				UPDATE cs3 WITH (ROWLOCK, UPDLOCK)
				SET
					mlivepositiontaking = CASE cs3.sporttype 	WHEN 161 THEN CASE cs3.bettype WHEN 85 THEN @v161mlivepositiontaking_85 WHEN 86 THEN @v161mlivepositiontaking_86 WHEN 87 THEN @v161mlivepositiontaking_87 WHEN 89 THEN @v161mlivepositiontaking_89 WHEN 90 THEN @v161mlivepositiontaking_90 ELSE cs3.mlivepositiontaking END ELSE cs3.mlivepositiontaking END,
					slivepositiontaking = CASE cs3.sporttype 	WHEN 161 THEN CASE cs3.bettype WHEN 85 THEN @v161slivepositiontaking_85 WHEN 86 THEN @v161slivepositiontaking_86 WHEN 87 THEN @v161slivepositiontaking_87 WHEN 89 THEN @v161slivepositiontaking_89 WHEN 90 THEN @v161slivepositiontaking_90 ELSE cs3.slivepositiontaking END ELSE cs3.slivepositiontaking END
				FROM Custsetting3rd cs3 INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
					INNER JOIN Custsetting3rd acs3 WITH(NOLOCK) ON acs3.custid = c.recommend AND cs3.sporttype = acs3.sporttype AND cs3.bettype = acs3.bettype 
				WHERE c.custid=@custid AND c.roleid = 1 AND acs3.isautolivempositiontaking = 0 
				*/
			END
			
			--correct pt after update pt on member
			--check agent min/max
			--update a1=n2 when a1<n2
			update cs
			SET cs.apositiontaking = aco.minpositiontaking,
				cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking - aco.minpositiontaking ELSE cs.mpositiontaking END			
			from @tmp_cs cs
				inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
				inner join @tmp_ag aco on cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
			where cs.apositiontaking < aco.minpositiontaking
						
			update cs
			SET cs.alivepositiontaking = aco.minlivepositiontaking,
				cs.mlivepositiontaking = case when cs.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking then mcs.mlivepositiontaking - aco.minlivepositiontaking ELSE cs.mlivepositiontaking END			
			from @tmp_cs cs
				inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
				inner join @tmp_ag aco on cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
			where cs.bettype in (85,86,87,89,90) and cs.alivepositiontaking < aco.minlivepositiontaking
			
			--update a1=l2 when a1>l2	
			update cs
			SET apositiontaking = aco.maxpositiontaking
			from @tmp_cs cs
				inner join @tmp_ag aco ON cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
			where cs.apositiontaking > aco.maxpositiontaking
				
			update cs
			SET alivepositiontaking = aco.maxlivepositiontaking
			from @tmp_cs cs
				inner join @tmp_ag aco ON cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
			where cs.bettype in (85,86,87,89,90) and cs.alivepositiontaking > aco.maxlivepositiontaking
				
			--check master min/max
			--update m1=n3-a1 if a1+m1<n3
			update cs
			set cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
			from @tmp_cs cs
				inner join @tmp_mag mco on cs.sporttype = mco.sporttype and cs.bettype = mco.bettype
			where cs.apositiontaking + cs.mpositiontaking < mco.minpositiontaking
			
			update cs
			set cs.mlivepositiontaking = mco.minlivepositiontaking - cs.alivepositiontaking
			from @tmp_cs cs
				inner join @tmp_mag mco on cs.sporttype = mco.sporttype and cs.bettype = mco.bettype
			where cs.bettype in (85,86,87,89,90) and cs.alivepositiontaking + cs.mlivepositiontaking < mco.minlivepositiontaking
			
			--update m1,a1 when a1+m1>l3
			--update m1=if(min(m3,l3)-a1<0,0,min(m3,l3)-a1)
			--update a1=if(a1+m1>min(m3,l3),min(m3,l3)-m1,a1)
			Update cs
			set @maxmapos = case when mcs.mpositiontaking>mcs.maxpositiontaking then mcs.maxpositiontaking else mcs.mpositiontaking end,
				@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
				mpositiontaking = @mpos,
				@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
				apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end	
			from @tmp_cs cs
				inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
				inner join @tmp_ag aco on cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
			where cs.apositiontaking +cs.mpositiontaking > mcs.maxpositiontaking
			
			Update cs
			set @maxmapos = case when mcs.mlivepositiontaking>mcs.maxlivepositiontaking then mcs.maxlivepositiontaking else mcs.mlivepositiontaking end,
				@mpos = case when @maxmapos-cs.alivepositiontaking<0 then 0 else @maxmapos-cs.alivepositiontaking end,
				mlivepositiontaking = @mpos,
				@apos = case when cs.alivepositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.alivepositiontaking end,
				alivepositiontaking = case when @apos<aco.minlivepositiontaking then aco.minlivepositiontaking else @apos end	
			from @tmp_cs cs
				inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
				inner join @tmp_ag aco on cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
			where cs.bettype in (85,86,87,89,90) and cs.alivepositiontaking +cs.mlivepositiontaking > mcs.maxlivepositiontaking
						
			--check super min/max
			--update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
			update cs
			set spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
			from @tmp_cs cs
				inner JOIN @tmp_sag sco on cs.sporttype = sco.sporttype and cs.bettype = sco.bettype
			where cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking 			
			
			update cs
			set slivepositiontaking = sco.minlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
			from @tmp_cs cs
				inner JOIN @tmp_sag sco on cs.sporttype = sco.sporttype and cs.bettype = sco.bettype
			where cs.bettype in (85,86,87,89,90) and cs.alivepositiontaking + cs.mlivepositiontaking + cs.slivepositiontaking < sco.minlivepositiontaking 			
			
			--update s1,m1,a1 in case s1+m1+a1>s4
			--s1=max(0,s4-m1-a1)
			--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
			--@maxmapos=min(m3,l3)
			--@mapos2=min(@mapos1,@maxmapos)
			--@mapos=max(@mapos2,n3)
			--m1=max(0,@mapos-a1)
			--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
			update cs
			set @spos = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 then 0 else scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking end,
				spositiontaking = @spos,
				@mapos1 = case when @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else cs.mpositiontaking+cs.apositiontaking end,
				@maxmapos = case when mcs.mpositiontaking>mcs.maxpositiontaking then mcs.maxpositiontaking else mcs.mpositiontaking end,
				@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
				@mapos = case when @mapos2<mcs.minpositiontaking then mcs.minpositiontaking else @mapos2 end,
				@mpos = case when @mapos-cs.apositiontaking<0 then 0 else @mapos-cs.apositiontaking end,
				mpositiontaking = @mpos,
				@apos = case when cs.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs.apositiontaking end,
				apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end	
			from @tmp_cs cs
				inner join @tmp_sag scs on cs.sporttype = scs.sporttype and cs.bettype = scs.bettype 
				inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
				inner join @tmp_ag aco on  cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
			where cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
				
			update cs
			set @spos = case when scs.slivepositiontaking-cs.mlivepositiontaking-cs.alivepositiontaking<0 then 0 else scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking end,
				slivepositiontaking = @spos,
				@mapos1 = case when @spos+cs.mlivepositiontaking+cs.alivepositiontaking>scs.slivepositiontaking then scs.slivepositiontaking-@spos else cs.mlivepositiontaking+cs.alivepositiontaking end,
				@maxmapos = case when mcs.mlivepositiontaking>mcs.maxlivepositiontaking then mcs.maxlivepositiontaking else mcs.mlivepositiontaking end,
				@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
				@mapos = case when @mapos2<mcs.minlivepositiontaking then mcs.minlivepositiontaking else @mapos2 end,
				@mpos = case when @mapos-cs.alivepositiontaking<0 then 0 else @mapos-cs.alivepositiontaking end,
				mlivepositiontaking = @mpos,
				@apos = case when cs.alivepositiontaking + @mpos>@mapos then @mapos-@mpos else cs.alivepositiontaking end,
				alivepositiontaking = case when @apos<aco.minlivepositiontaking then aco.minlivepositiontaking else @apos end	
			from @tmp_cs cs
				inner join @tmp_sag scs on cs.sporttype = scs.sporttype and cs.bettype = scs.bettype 
				inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
				inner join @tmp_ag aco on  cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
			where cs.bettype in (85,86,87,89,90) and cs.slivepositiontaking + cs.mlivepositiontaking + cs.alivepositiontaking > scs.slivepositiontaking
			
			--update pt change on member	
			update cs
			SET cs.apositiontaking = t.apositiontaking,
				cs.mpositiontaking = t.mpositiontaking,
				cs.spositiontaking = t.spositiontaking,
				cs.alivepositiontaking = t.alivepositiontaking,
				cs.mlivepositiontaking = t.mlivepositiontaking,
				cs.slivepositiontaking = t.slivepositiontaking
			FROM @tmp_cs t
				INNER JOIN custsetting3rd cs WITH(UPDLOCK,ROWLOCK) ON t.custid = cs.custid and t.sporttype = cs.sporttype and t.bettype = cs.bettype
			WHERE cs.apositiontaking <> t.apositiontaking
					OR cs.mpositiontaking <> t.mpositiontaking
					OR cs.spositiontaking <> t.spositiontaking
					OR cs.alivepositiontaking <> t.alivepositiontaking
					OR cs.mlivepositiontaking <> t.mlivepositiontaking
					OR cs.slivepositiontaking <> t.slivepositiontaking
			
		END--end roleid = 3,4		
		ELSE IF @roleid = 2
		BEGIN
			UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK)
			SET 
				apositiontaking = CASE bettype 
								WHEN 81 then @v161apositiontaking_81
								WHEN 83 then @v161apositiontaking_83
								WHEN 86 then @v161apositiontaking_86
								WHEN 88 then @v161apositiontaking_88
								ELSE 0
								END,
				alivepositiontaking = CASE bettype
								WHEN 85 then @v161alivepositiontaking_85
								WHEN 86 then @v161alivepositiontaking_86
								WHEN 87 then @v161alivepositiontaking_87 
								WHEN 89 then @v161alivepositiontaking_89
								WHEN 90 then @v161alivepositiontaking_90
								ELSE 0
								END,
				mpositiontaking = CASE bettype 
								WHEN 81 then @v161mpositiontaking_81
								WHEN 83 then @v161mpositiontaking_83
								WHEN 86 then @v161mpositiontaking_86
								WHEN 88 then @v161mpositiontaking_88
								ELSE 0
								END, 
				mlivepositiontaking = CASE bettype
								WHEN 85 then @v161mlivepositiontaking_85
								WHEN 86 then @v161mlivepositiontaking_86
								WHEN 87 then @v161mlivepositiontaking_87 
								WHEN 89 then @v161mlivepositiontaking_89
								WHEN 90 then @v161mlivepositiontaking_90
								ELSE 0
								END,
				spositiontaking = CASE bettype 
								WHEN 81 then @v161spositiontaking_81
								WHEN 83 then @v161spositiontaking_83
								WHEN 86 then @v161spositiontaking_86
								WHEN 88 then @v161spositiontaking_88
								ELSE 0
								 END,
				slivepositiontaking = CASE bettype
								WHEN 85 then @v161slivepositiontaking_85
								WHEN 86 then @v161slivepositiontaking_86
								WHEN 87 then @v161slivepositiontaking_87 
								WHEN 89 then @v161slivepositiontaking_89
								WHEN 90 then @v161slivepositiontaking_90
								ELSE 0
								END			
			WHERE custid = @custid AND sporttype = 161
		END--end roleid = 2
	END--end mode = 'number'
	ELSE IF @mode = 'horse'
	BEGIN
		IF @roleid iN (3,4)
		BEGIN
			SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend
			FROM custinfo WITH(NOLOCK)
			WHERE custid = @custid 
			
			INSERT INTO @tmp_cs(custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, autopositiontaking, autompositiontaking, isautopositiontaking, isautompositiontaking)
			SELECT cs.custid, cs.sporttype, cs.bettype, cs.spositiontaking, cs.mpositiontaking, cs.apositiontaking, autopositiontaking, autompositiontaking, isautopositiontaking, isautompositiontaking					
			FROM custsetting3rd cs with(NOLOCK)			
			WHERE cs.custid = @custid and sporttype in (151,152,153)
			
			INSERT INTO @tmp_sag(custid, sporttype, bettype, spositiontaking, minpositiontaking, maxpositiontaking)
			SELECT scs.custid, scs.sporttype, scs.bettype, spositiontaking, sco.minpositiontaking, sco.maxpositiontaking
			FROM custsetting3rd scs with(NOLOCK)
				INNER JOIN custoverride3rd sco WITH(NOLOCK) on scs.custid = sco.custid and scs.sporttype = sco.sporttype and scs.bettype = sco.bettype
			WHERE scs.custid = @srecommend and scs.sporttype in (151,152,153)
			
			INSERT INTO @tmp_mag(custid, sporttype, bettype, mpositiontaking, autopositiontaking, isautopositiontaking, minpositiontaking, maxpositiontaking)
			SELECT mcs.custid, mcs.sporttype, mcs.bettype, mpositiontaking, autopositiontaking, isautopositiontaking, mco.minpositiontaking, mco.maxpositiontaking
			FROM custsetting3rd mcs WITH(NOLOCK)
				inner JOIN custoverride3rd mco WITH(NOLOCK) on mcs.custid = mco.custid and mcs.sporttype = mco.sporttype and mcs.bettype = mco.bettype
			WHERE mcs.custid = @mrecommend and mcs.sporttype in (151,152,153)
			
			INSERT INTO @tmp_ag(custid, sporttype, bettype, autompositiontaking, isautompositiontaking, minpositiontaking, maxpositiontaking)
			SELECT cs.custid, cs.sporttype, cs.bettype, autompositiontaking, isautompositiontaking, minpositiontaking, maxpositiontaking
			FROM custoverride3rd co WITH(NOLOCK)
				INNER JOIN custsetting3rd cs WITH(NOLOCK) ON co.custid = cs.custid and co.sporttype = cs.sporttype and co.bettype = cs.bettype
			WHERE cs.custid = @recommend and cs.sporttype in (151,152,153) 	
			
			IF @roleid = 4
			BEGIN
				update cs
				SET cs.spositiontaking = case when @UpdateMultiple = 1 
												AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
													OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
													OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
												then cs.spositiontaking 
											else case	
													when cs.bettype = 31 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 then @v151spositiontaking_31 
													when cs.bettype = 32 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 then @v151spositiontaking_32 
													when cs.bettype = 41 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 then @v151spositiontaking_41 
													when cs.bettype = 42 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 then @v151spositiontaking_42 
													when cs.bettype = 51 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 then @v151spositiontaking_51 
													when cs.bettype = 52 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 then @v151spositiontaking_52 
													when cs.bettype = 41 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 then @v152spositiontaking_41 
													when cs.bettype = 42 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 then @v152spositiontaking_42 
													when cs.bettype = 51 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 then @v152spositiontaking_51 
													when cs.bettype = 52 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 then @v152spositiontaking_52 
													when cs.bettype = 51 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 then @v153spositiontaking_51 
													when cs.bettype = 52 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 then @v153spositiontaking_52 
												else cs.spositiontaking end
											end
				from @tmp_cs cs
					inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
				where mcs.isautopositiontaking = 0
				/*
				update cs with (ROWLOCK, UPDLOCK)
				set
					cs.spositiontaking = case when @UpdateMultiple = 1 
												AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
													OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
													OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
												then cs.spositiontaking 
											else case	
													when cs.bettype = 31 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 then @v151spositiontaking_31 
													when cs.bettype = 32 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 then @v151spositiontaking_32 
													when cs.bettype = 41 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 then @v151spositiontaking_41 
													when cs.bettype = 42 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 then @v151spositiontaking_42 
													when cs.bettype = 51 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 then @v151spositiontaking_51 
													when cs.bettype = 52 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 then @v151spositiontaking_52 
													when cs.bettype = 41 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 then @v152spositiontaking_41 
													when cs.bettype = 42 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 then @v152spositiontaking_42 
													when cs.bettype = 51 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 then @v152spositiontaking_51 
													when cs.bettype = 52 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 then @v152spositiontaking_52 
													when cs.bettype = 51 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 then @v153spositiontaking_51 
													when cs.bettype = 52 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 then @v153spositiontaking_52 
												else cs.spositiontaking end
											end
				from CustSetting3rd cs  inner join customer c (nolock) on cs.custid = c.custid
					inner join CustSetting3rd scs (nolock) on scs.custid = c.mrecommend and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
				where cs.custid=@custid and cs.sporttype in (151,152,153) and c.roleid = 1 and scs.isautopositiontaking = 0
			*/
			END--end @roleid = 4
			ELSE IF @roleid = 3
			BEGIN
				update cs
				SET	
					mpositiontaking = CASE WHEN @UpdateMultiple = 1 
												AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
													OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
													OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))	
												THEN cs.mpositiontaking	
											ELSE CASE	WHEN cs.bettype = 31 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_31 
													WHEN cs.bettype = 32 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_32 
													WHEN cs.bettype = 41 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_41 
													WHEN cs.bettype = 42 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_42 
													WHEN cs.bettype = 51 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_51 
													WHEN cs.bettype = 52 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_52 
													WHEN cs.bettype = 41 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_41 
													WHEN cs.bettype = 42 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_42 
													WHEN cs.bettype = 51 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_51 
													WHEN cs.bettype = 52 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_52 
													WHEN cs.bettype = 51 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_51 
													WHEN cs.bettype = 52 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_52 
													ELSE cs.mpositiontaking END
											END,
					spositiontaking = CASE WHEN @UpdateMultiple = 1 
												AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
													OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
													OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
												THEN cs.spositiontaking 
											ELSE CASE WHEN cs.bettype = 31 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_31 
													WHEN cs.bettype = 32 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_32 
													WHEN cs.bettype = 41 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_41 
													WHEN cs.bettype = 42 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_42 
													WHEN cs.bettype = 51 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_51 
													WHEN cs.bettype = 52 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_52 
													WHEN cs.bettype = 41 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_41 
													WHEN cs.bettype = 42 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_42 
													WHEN cs.bettype = 51 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_51 
													WHEN cs.bettype = 52 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_52 
													WHEN cs.bettype = 51 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_51 
													WHEN cs.bettype = 52 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_52 
													ELSE cs.spositiontaking END
											END
				FROM @tmp_cs cs 
					INNER JOIN @tmp_ag acs ON  cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
				WHERE acs.isautompositiontaking = 0
				/*
				UPDATE cs WITH (ROWLOCK, UPDLOCK)
				SET
					mpositiontaking = CASE WHEN @UpdateMultiple = 1 
												AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
													OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
													OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))	
												THEN cs.mpositiontaking	
											ELSE CASE	WHEN cs.bettype = 31 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_31 
													WHEN cs.bettype = 32 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_32 
													WHEN cs.bettype = 41 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_41 
													WHEN cs.bettype = 42 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_42 
													WHEN cs.bettype = 51 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_51 
													WHEN cs.bettype = 52 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_52 
													WHEN cs.bettype = 41 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_41 
													WHEN cs.bettype = 42 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_42 
													WHEN cs.bettype = 51 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_51 
													WHEN cs.bettype = 52 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_52 
													WHEN cs.bettype = 51 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_51 
													WHEN cs.bettype = 52 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_52 
													ELSE cs.mpositiontaking END
											END,
					spositiontaking = CASE WHEN @UpdateMultiple = 1 
												AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
													OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
													OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
												THEN cs.spositiontaking 
											ELSE CASE WHEN cs.bettype = 31 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_31 
													WHEN cs.bettype = 32 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_32 
													WHEN cs.bettype = 41 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_41 
													WHEN cs.bettype = 42 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_42 
													WHEN cs.bettype = 51 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_51 
													WHEN cs.bettype = 52 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_52 
													WHEN cs.bettype = 41 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_41 
													WHEN cs.bettype = 42 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_42 
													WHEN cs.bettype = 51 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_51 
													WHEN cs.bettype = 52 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_52 
													WHEN cs.bettype = 51 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_51 
													WHEN cs.bettype = 52 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_52 
													ELSE cs.spositiontaking END
											END
				FROM CustSetting3rd cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
					INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
				WHERE c.custid=@custid AND c.roleid = 1 AND acs.isautompositiontaking = 0 AND cs.sporttype in (151,152,153)
				*/
			END--end @roleid = 3
			
			--correct pt after update pt on member
			--check agent min/max
			--update a1=n2 when a1<n2
			Update cs 
				set cs.apositiontaking = aco.minpositiontaking,
					cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
			from 
				@tmp_cs as cs 				
				inner join @tmp_mag as mcs on mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join @tmp_ag as aco on aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking<aco.minpositiontaking
			
			--update a1=l2 when a1>l2
			Update cs
			set apositiontaking = aco.maxpositiontaking
			from 
				@tmp_cs as cs				
				inner join @tmp_ag as aco on aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking>aco.maxpositiontaking				
			
			--Recal AUTO MPT 
			--Update m1=min(m3-a1,(im1?um1,um2))
			-----------------
			Update cs
				set mpositiontaking = 
					case when mcs.mpositiontaking-cs.apositiontaking > case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
						then case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
					else  mcs.mpositiontaking-cs.apositiontaking end
			from
				@tmp_cs as cs 				
				inner join @tmp_mag as mcs on mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join @tmp_ag as acs on acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
			where (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
			
			--check master min/max
			--update m1=n3-a1 if a1+m1<n3
			Update cs
				set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
			from 
				@tmp_cs as cs				
				inner join @tmp_mag as mco on mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
						
			--update m1,a1 when a1+m1>l3
			--update m1=if(min(m3,l3)-a1<0,0,min(m3,l3)-a1)
			--update a1=if(a1+m1>min(m3,l3),min(m3,l3)-m1,a1)
			Update cs
				set @maxmapos = case when mcs.mpositiontaking>mcs.maxpositiontaking then mcs.maxpositiontaking else mcs.mpositiontaking end,
					@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
					mpositiontaking = @mpos,
					@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
					apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				@tmp_cs as cs 				
				inner join @tmp_mag as mcs on mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype				
				inner join @tmp_ag as aco on aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking>mcs.maxpositiontaking				
			
			
			--recal autopos
			Update cs
				set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
										(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
			from
				@tmp_cs as cs 				
				inner join @tmp_mag as mcs on mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join @tmp_sag as scs on scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
			where (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
			
			--check super min/max
			--update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
			Update cs
				set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
			from 
				@tmp_cs as cs				
				inner join @tmp_sag as sco on sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
			
			--update s1,m1,a1 in case s1+m1+a1>s4
			--s1=max(0,s4-m1-a1)
			--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
			--@maxmapos=min(m3,l3)
			--@mapos2=min(@mapos1,@maxmapos)
			--@mapos=max(@mapos2,n3)
			--m1=max(0,@mapos-a1)
			--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
			Update cs
				set @spos = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 then 0 else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end,
					spositiontaking = @spos,
					@mapos1 = case when @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else cs.mpositiontaking+cs.apositiontaking end,
					@maxmapos = case when mcs.mpositiontaking>mcs.maxpositiontaking then mcs.maxpositiontaking else mcs.mpositiontaking end,
					@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
					@mapos = case when @mapos2<mcs.minpositiontaking then mcs.minpositiontaking else @mapos2 end,
					@mpos = case when @mapos-cs.apositiontaking<0 then 0 else @mapos-cs.apositiontaking end,
					mpositiontaking = @mpos,
					@apos = case when cs.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs.apositiontaking end,
					apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				@tmp_cs as cs 				
				inner join @tmp_sag as scs on scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
				inner join @tmp_mag as mcs on mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype				
				inner join @tmp_ag as aco on aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
			
			
			--update pt change on member	
			update cs
			SET cs.apositiontaking = t.apositiontaking,
				cs.mpositiontaking = t.mpositiontaking,
				cs.spositiontaking = t.spositiontaking
			FROM @tmp_cs t
				INNER JOIN custsetting3rd cs WITH(UPDLOCK,ROWLOCK) ON t.custid = cs.custid and t.sporttype = cs.sporttype and t.bettype = cs.bettype
			WHERE cs.apositiontaking <> t.apositiontaking
					OR cs.mpositiontaking <> t.mpositiontaking
					OR cs.spositiontaking <> t.spositiontaking					
			
		END--end @roleid in (3,4)
		ELSE IF @roleid = 2
		BEGIN	
			UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
			SET
				apositiontaking = CASE WHEN @UpdateMultiple = 1 
											AND (	(sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
												OR  (sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
												OR  (sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
											THEN apositiontaking	
										ELSE CASE WHEN bettype = 31 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151apositiontaking_31 
												WHEN bettype = 32 and sporttype = 151  and @UpdatePositiontakingv151_31 = 1 THEN @v151apositiontaking_32 
												WHEN bettype = 41 and sporttype = 151  and @UpdatePositiontakingv151_41 = 1 THEN @v151apositiontaking_41 
												WHEN bettype = 42 and sporttype = 151  and @UpdatePositiontakingv151_41 = 1 THEN @v151apositiontaking_42 
												WHEN bettype = 51 and sporttype = 151  and @UpdatePositiontakingv151_51 = 1 THEN @v151apositiontaking_51 
												WHEN bettype = 52 and sporttype = 151  and @UpdatePositiontakingv151_51 = 1 THEN @v151apositiontaking_52 
												WHEN bettype = 41 and sporttype = 152  and @UpdatePositiontakingv152_41 = 1 THEN @v152apositiontaking_41 
												WHEN bettype = 42 and sporttype = 152  and @UpdatePositiontakingv152_41 = 1 THEN @v152apositiontaking_42 
												WHEN bettype = 51 and sporttype = 152  and @UpdatePositiontakingv152_51 = 1 THEN @v152apositiontaking_51 
												WHEN bettype = 52 and sporttype = 152  and @UpdatePositiontakingv152_51 = 1 THEN @v152apositiontaking_52 
												WHEN bettype = 51 and sporttype = 153  and @UpdatePositiontakingv153_51 = 1 THEN @v153apositiontaking_51 
												WHEN bettype = 52 and sporttype = 153  and @UpdatePositiontakingv153_51 = 1 THEN @v153apositiontaking_52 
												ELSE apositiontaking END END,
				--Auto Master PT
				mpositiontaking = CASE WHEN @UpdateMultiple = 1 
											AND (	(sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
												OR  (sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
												OR  (sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
											THEN mpositiontaking
										ELSE CASE	WHEN bettype = 31 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_31 
													WHEN bettype = 32 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_32 
													WHEN bettype = 41 and sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_41 
													WHEN bettype = 42 and sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_42 
													WHEN bettype = 51 and sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_51 
													WHEN bettype = 52 and sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_52 
													WHEN bettype = 41 and sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_41 
													WHEN bettype = 42 and sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_42 
													WHEN bettype = 51 and sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_51 
													WHEN bettype = 52 and sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_52 
													WHEN bettype = 51 and sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_51 
													WHEN bettype = 52 and sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_52 
													ELSE mpositiontaking END END,	
								  
				spositiontaking = CASE WHEN @UpdateMultiple = 1 
											AND (	(sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
												OR  (sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
												OR  (sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
											THEN spositiontaking
										ELSE CASE	WHEN bettype = 31 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_31 
													WHEN bettype = 32 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_32 
													WHEN bettype = 41 and sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_41 
													WHEN bettype = 42 and sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_42 
													WHEN bettype = 51 and sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_51
													WHEN bettype = 52 and sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_52 
													WHEN bettype = 41 and sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_41 
													WHEN bettype = 42 and sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_42 
													WHEN bettype = 51 and sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_51 
													WHEN bettype = 52 and sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_52 
													WHEN bettype = 51 and sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_51 
													WHEN bettype = 52 and sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_52 
													ELSE spositiontaking END
										END
			WHERE custid=@custid and sporttype BETWEEN 151 AND 153
		END--end @roleid = 2
	END--end mode = 'horse'		
END