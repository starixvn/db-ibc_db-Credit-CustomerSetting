ALTER PROCEDURE [dbo].[Acc_Custsetting_08]
	@custid INT = 0,
	@roleid INT,
		
	--super update pt on member	
	@spositiontaking_1 SMALLMONEY = 0,
	@spositiontaking_2 SMALLMONEY = 0,
	@spositiontaking_3 SMALLMONEY = 0,
	@spositiontaking_4 SMALLMONEY = 0,
	@spositiontaking_5 SMALLMONEY = 0,
	@spositiontaking_6 SMALLMONEY = 0,
	@spositiontaking_7 SMALLMONEY = 0,
	@spositiontaking_8 SMALLMONEY = 0,
	@spositiontaking_9 SMALLMONEY = 0,
	@spositiontaking_10 SMALLMONEY = 0,
	@spositiontaking_9999 SMALLMONEY = 0,
	
	@slivepositiontaking_1 SMALLMONEY = 0,
	@slivepositiontaking_3 SMALLMONEY = 0,
	@slivepositiontaking_7 SMALLMONEY = 0,
	@slivepositiontaking_8 SMALLMONEY = 0,
	
	@v2spositiontaking_1 SMALLMONEY = 0,
	@v2spositiontaking_2 SMALLMONEY = 0,
	@v2spositiontaking_3 SMALLMONEY = 0,
	@v2spositiontaking_7 SMALLMONEY = 0,
	@v2spositiontaking_8 SMALLMONEY = 0,
--	@v2spositiontaking_9 SMALLMONEY = 0,
	@v2spositiontaking_20 SMALLMONEY = 0,

	@v3spositiontaking_1 SMALLMONEY = 0,
	@v3spositiontaking_2 SMALLMONEY = 0,
	@v3spositiontaking_3 SMALLMONEY = 0,
	@v3spositiontaking_20 SMALLMONEY = 0,

	@v5spositiontaking_1 SMALLMONEY = 0,
	@v5spositiontaking_2 SMALLMONEY = 0,
	@v5spositiontaking_3 SMALLMONEY = 0,
	@v5spositiontaking_20 SMALLMONEY = 0,
	@v5spositiontaking_9999 SMALLMONEY = 0,

	@v8spositiontaking_1 SMALLMONEY = 0,
	@v8spositiontaking_3 SMALLMONEY = 0,
	@v8spositiontaking_20 SMALLMONEY = 0,

	@v10spositiontaking_1 SMALLMONEY = 0,
	@v10spositiontaking_2 SMALLMONEY = 0,
	@v10spositiontaking_3 SMALLMONEY = 0,
	@v10spositiontaking_20 SMALLMONEY = 0,

	@v11spositiontaking_1 SMALLMONEY = 0,
	@v11spositiontaking_20 SMALLMONEY = 0,

	@v99spositiontaking_1 SMALLMONEY = 0,
	@v99spositiontaking_2 SMALLMONEY = 0,
	@v99spositiontaking_3 SMALLMONEY = 0,
	@v99spositiontaking_20 SMALLMONEY = 0,

	-- mixed sports
	@v99spositiontaking_9 SMALLMONEY = 0,

	-- HR Fixed Odds
	@v154spositiontaking_20 SMALLMONEY = 0,
	
	--master update pt on member
	@mpositiontaking_1 SMALLMONEY = 0,
	@mpositiontaking_2 SMALLMONEY  = 0,
	@mpositiontaking_3 SMALLMONEY  = 0,
	@mpositiontaking_4 SMALLMONEY  = 0,
	@mpositiontaking_5 SMALLMONEY  = 0,
	@mpositiontaking_6 SMALLMONEY  = 0,
	@mpositiontaking_7 SMALLMONEY  = 0,
	@mpositiontaking_8 SMALLMONEY  = 0,
	@mpositiontaking_9 SMALLMONEY  = 0,
	@mpositiontaking_10 SMALLMONEY  = 0,
	@mpositiontaking_9999 SMALLMONEY  = 0,
	@mlivepositiontaking_1 SMALLMONEY  = 0,
	@mlivepositiontaking_3 SMALLMONEY  = 0,
	@mlivepositiontaking_7 SMALLMONEY  = 0,
	@mlivepositiontaking_8 SMALLMONEY  = 0,
	
	@v2mpositiontaking_1 SMALLMONEY  = 0,
	@v2mpositiontaking_2 SMALLMONEY  = 0,
	@v2mpositiontaking_3 SMALLMONEY  = 0,
	@v2mpositiontaking_7 SMALLMONEY  = 0,
	@v2mpositiontaking_8 SMALLMONEY  = 0,
--	@v2mpositiontaking_9 SMALLMONEY  = 0,
	@v2mpositiontaking_20 SMALLMONEY  = 0,

	@v3mpositiontaking_1 SMALLMONEY  = 0,
	@v3mpositiontaking_2 SMALLMONEY  = 0,
	@v3mpositiontaking_3 SMALLMONEY  = 0,
	@v3mpositiontaking_20 SMALLMONEY  = 0,

	@v5mpositiontaking_1 SMALLMONEY  = 0,
	@v5mpositiontaking_2 SMALLMONEY  = 0,
	@v5mpositiontaking_3 SMALLMONEY  = 0,
	@v5mpositiontaking_20 SMALLMONEY  = 0,
	@v5mpositiontaking_9999 SMALLMONEY  = 0,

	@v8mpositiontaking_1 SMALLMONEY  = 0,
	@v8mpositiontaking_3 SMALLMONEY  = 0,
	@v8mpositiontaking_20 SMALLMONEY  = 0,

	@v10mpositiontaking_1 SMALLMONEY  = 0,
	@v10mpositiontaking_2 SMALLMONEY  = 0,
	@v10mpositiontaking_3 SMALLMONEY  = 0,
	@v10mpositiontaking_20 SMALLMONEY  = 0,

	@v11mpositiontaking_1 SMALLMONEY  = 0,
	@v11mpositiontaking_20 SMALLMONEY  = 0,

	@v99mpositiontaking_1 SMALLMONEY  = 0,
	@v99mpositiontaking_2 SMALLMONEY  = 0,
	@v99mpositiontaking_3 SMALLMONEY  = 0,
	@v99mpositiontaking_20 SMALLMONEY  = 0,

	-- mixed sports
	@v99mpositiontaking_9 SMALLMONEY  = 0,
	
	-- HR Fixed Odds
	@v154mpositiontaking_20 SMALLMONEY = 0,

	--agent update pt on member
	@apositiontaking_1 SMALLMONEY = 0,
	@apositiontaking_2 SMALLMONEY = 0,
	@apositiontaking_3 SMALLMONEY = 0,
	@apositiontaking_4 SMALLMONEY = 0,
	@apositiontaking_5 SMALLMONEY = 0,
	@apositiontaking_6 SMALLMONEY = 0,
	@apositiontaking_7 SMALLMONEY = 0,
	@apositiontaking_8 SMALLMONEY = 0,
	@apositiontaking_9 SMALLMONEY = 0,
	@apositiontaking_10 SMALLMONEY = 0,
	@apositiontaking_9999 SMALLMONEY = 0,
	
	@alivepositiontaking_1 SMALLMONEY = 0,
	@alivepositiontaking_3 SMALLMONEY = 0,
	@alivepositiontaking_7 SMALLMONEY = 0,
	@alivepositiontaking_8 SMALLMONEY = 0,
	
	@v2apositiontaking_1 SMALLMONEY = 0,
	@v2apositiontaking_2 SMALLMONEY = 0,
	@v2apositiontaking_3 SMALLMONEY = 0,
	@v2apositiontaking_7 SMALLMONEY = 0,
	@v2apositiontaking_8 SMALLMONEY = 0,
	--@v2apositiontaking_9 SMALLMONEY = 0,
	@v2apositiontaking_20 SMALLMONEY = 0,
	
	@v3apositiontaking_1 SMALLMONEY = 0,
	@v3apositiontaking_2 SMALLMONEY = 0,
	@v3apositiontaking_3 SMALLMONEY = 0,
	@v3apositiontaking_20 SMALLMONEY = 0,

	@v5apositiontaking_1 SMALLMONEY = 0,
	@v5apositiontaking_2 SMALLMONEY = 0,
	@v5apositiontaking_3 SMALLMONEY = 0,
	@v5apositiontaking_20 SMALLMONEY = 0,
	@v5apositiontaking_9999 SMALLMONEY = 0,

	@v8apositiontaking_1 SMALLMONEY = 0,
	@v8apositiontaking_3 SMALLMONEY = 0,
	@v8apositiontaking_20 SMALLMONEY = 0,

	@v10apositiontaking_1 SMALLMONEY = 0,
	@v10apositiontaking_2 SMALLMONEY = 0,
	@v10apositiontaking_3 SMALLMONEY = 0,
	@v10apositiontaking_20 SMALLMONEY = 0,

	@v11apositiontaking_1 SMALLMONEY = 0,
	@v11apositiontaking_20 SMALLMONEY = 0,

	@v99apositiontaking_1 SMALLMONEY = 0,
	@v99apositiontaking_2 SMALLMONEY = 0,
	@v99apositiontaking_3 SMALLMONEY = 0,
	@v99apositiontaking_9 SMALLMONEY = 0,
	@v99apositiontaking_20 SMALLMONEY = 0,
	
	@v154apositiontaking_20 SMALLMONEY = 0,
	-- Outright PT for sports
	
	@v2spositiontaking_10 SMALLMONEY  = 0,
	@v3spositiontaking_10 SMALLMONEY  = 0,
	@v5spositiontaking_10 SMALLMONEY  = 0,
	@v8spositiontaking_10 SMALLMONEY  = 0,
	@v10spositiontaking_10 SMALLMONEY  = 0,
	@v11spositiontaking_10 SMALLMONEY  = 0,
	@v99spositiontaking_10 SMALLMONEY  = 0,
	
	@v2mpositiontaking_10 SMALLMONEY  = 0,
	@v3mpositiontaking_10 SMALLMONEY  = 0,
	@v5mpositiontaking_10 SMALLMONEY  = 0,
	@v8mpositiontaking_10 SMALLMONEY  = 0,
	@v10mpositiontaking_10 SMALLMONEY  = 0,
	@v11mpositiontaking_10 SMALLMONEY  = 0,
	@v99mpositiontaking_10 SMALLMONEY  = 0,
	
	@v2apositiontaking_10 SMALLMONEY  = 0,
	@v3apositiontaking_10 SMALLMONEY  = 0,
	@v5apositiontaking_10 SMALLMONEY  = 0,
	@v8apositiontaking_10 SMALLMONEY  = 0,
	@v10apositiontaking_10 SMALLMONEY  = 0,
	@v11apositiontaking_10 SMALLMONEY  = 0,
	@v99apositiontaking_10 SMALLMONEY  = 0,
		
	@UpdateMultiple BIT = 0,
	@UpdatePositiontaking BIT = 1,
	@UpdatePositiontakingv2 BIT = 1,
	@UpdatePositiontakingv3 BIT = 1,
	@UpdatePositiontakingv5 BIT = 1,
	@UpdatePositiontakingv8 BIT = 1,
	@UpdatePositiontakingv10 BIT = 1,
	@UpdatePositiontakingv11 BIT = 1,
	@UpdatePositiontakingv99 BIT = 1,
	@UpdatePositiontakingv99MP BIT = 1,
	@UpdatePositiontakingv154 BIT = 1
	
AS
	/*
		Created: Johnson
		Date: 2013-10-30
		Task: Apply execrep update pt on member
		DB: DBCUST/custDB
		Original versions: Acc_CustomerUpdMember_Super
					Acc_CustomerUpdMember_Master
					Acc_CustomerUpdMember_PositionTaking
		
		Revision:
			- 20131104@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
			- 20140219@Johnson: merge code correct pt after update pt on member
			- 20140630@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]

			- 20150508@Johnson: fix bug update multiple members affect to HR Fixed Odds [Redmined:#35151]
		  - 20150610@Daniel: 
		   + Improve medthod check table existing in subscribers	
		   + Separate custDB to new server DBCUST      			
		  - 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
		Parameter's Explanation:
	*/ 
BEGIN
SET NOCOUNT ON

     if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustSetting') = 1 
	   AND dbo.f_CheckRepTable('CustOverride') = 1 
	   )
     RETURN

	
	IF @roleid IN (3,4)
	BEGIN
			DECLARE @tmp_cs TABLE(custid int, sporttype smallint, bettype smallint,
				 spositiontaking smallmoney, mpositiontaking smallmoney, apositiontaking smallmoney, isautopositiontaking bit, isautompositiontaking bit,
				 slivepositiontaking smallmoney, mlivepositiontaking smallmoney, alivepositiontaking smallmoney, isautolivepositiontaking bit, isautomlivepositiontaking bit)
			
			DECLARE @tmp_sag TABLE(custid int, sporttype smallint, bettype smallint,
				spositiontaking smallmoney, slivepositiontaking smallmoney, minpositiontaking smallmoney, minlivepositiontaking smallmoney, maxpositiontaking smallmoney, maxlivepositiontaking smallmoney
			) 
			
			DECLARE @tmp_mag TABLE(custid int, sporttype smallint, bettype smallint,
				mpositiontaking smallmoney, mlivepositiontaking smallmoney, isautopositiontaking bit, isautolivepositiontaking bit, 
				minpositiontaking smallmoney, minlivepositiontaking smallmoney, maxpositiontaking smallmoney, maxlivepositiontaking smallmoney
			)
			
			DECLARE @tmp_ag TABLE(custid int, sporttype smallint, bettype smallint,
				isautompositiontaking bit, isautolivempositiontaking bit, minpositiontaking smallmoney, minlivepositiontaking smallmoney, maxpositiontaking smallmoney, maxlivepositiontaking smallmoney)
			
			DECLARE @srecommend int, @mrecommend int, @recommend int, 
					@mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney

			
			SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend
			FROM custinfo WITH(NOLOCK)
			WHERE custid = @custid 
			
			INSERT INTO @tmp_cs(custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking,
								slivepositiontaking, mlivepositiontaking, alivepositiontaking)
			SELECT cs.custid, cs.sporttype, cs.bettype, cs.spositiontaking, cs.mpositiontaking, cs.apositiontaking
					, cs.slivepositiontaking, cs.mlivepositiontaking, cs.alivepositiontaking
			FROM custsetting cs with(NOLOCK)			
			WHERE cs.custid = @custid
			
			INSERT INTO @tmp_sag(custid, sporttype, bettype, spositiontaking, slivepositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
			SELECT scs.custid, scs.sporttype, scs.bettype, spositiontaking, slivepositiontaking, sco.minpositiontaking, sco.minlivepositiontaking, sco.maxpositiontaking, sco.maxlivepositiontaking
			FROM custsetting scs with(NOLOCK)
				INNER JOIN custoverride sco WITH(NOLOCK) on scs.custid = sco.custid and scs.sporttype = sco.sporttype and scs.bettype = sco.bettype
			WHERE scs.custid = @srecommend
			
			INSERT INTO @tmp_mag(custid, sporttype, bettype, mpositiontaking, mlivepositiontaking, isautopositiontaking, isautolivepositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
			SELECT mcs.custid, mcs.sporttype, mcs.bettype, mpositiontaking, mlivepositiontaking, isautopositiontaking, isautolivepositiontaking, mco.minpositiontaking, mco.minlivepositiontaking, mco.maxpositiontaking, mco.maxlivepositiontaking
			FROM custsetting mcs WITH(NOLOCK)
				inner JOIN custoverride mco WITH(NOLOCK) on mcs.custid = mco.custid and mcs.sporttype = mco.sporttype and mcs.bettype = mco.bettype
			WHERE mcs.custid = @mrecommend	
			
			INSERT INTO @tmp_ag(custid, sporttype, bettype, isautompositiontaking, isautolivempositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
			SELECT cs.custid, cs.sporttype, cs.bettype, cs.isautompositiontaking, cs.isautolivempositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking
			FROM custoverride co WITH(NOLOCK)
				INNER JOIN custsetting cs WITH(NOLOCK) ON cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype
			WHERE cs.custid = @recommend 
			
			IF @roleid = 4
			BEGIN
				--don't update s1 for member under master was set i3=1(normal)
				UPDATE cs		
				SET
					cs.spositiontaking = 
									CASE WHEN (@UpdateMultiple = 1 
											AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
												OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
												OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
												OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
												OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
												OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
												OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
												OR (cs.sporttype=99 AND cs.bettype<>9 AND @UpdatePositiontakingv99 = 0) 
												OR (cs.sporttype=99 AND cs.bettype=9 AND @UpdatePositiontakingv99MP = 0) 
												OR (cs.sporttype = 154 AND cs.bettype = 20 AND @UpdatePositiontakingv154 = 0) )) 
											THEN cs.spositiontaking 
									ELSE CASE cs.sporttype 	
											WHEN 1 THEN case cs.bettype WHEN 1 THEN @spositiontaking_1 WHEN 2 THEN @spositiontaking_2 WHEN 3 THEN @spositiontaking_3 WHEN 4 THEN @spositiontaking_4 WHEN 5 THEN @spositiontaking_5 WHEN 6 THEN @spositiontaking_6 WHEN 7 THEN @spositiontaking_7 WHEN 8 THEN @spositiontaking_8 WHEN 9 THEN @spositiontaking_9 WHEN 10 THEN @spositiontaking_10 WHEN 9999 THEN @spositiontaking_9999 ELSE 0 END
											
											WHEN 2 THEN case cs.bettype WHEN 1 THEN @v2spositiontaking_1 WHEN 2 THEN @v2spositiontaking_2 WHEN 3 THEN @v2spositiontaking_3 WHEN 7 THEN @v2spositiontaking_7 WHEN 8 THEN @v2spositiontaking_8 /*WHEN 9 THEN @v2spositiontaking_9*/ WHEN 20 THEN @v2spositiontaking_20  WHEN 10 THEN @v2spositiontaking_10 ELSE 0 END
											
											WHEN 3 THEN case cs.bettype WHEN 1 THEN @v3spositiontaking_1 WHEN 2 THEN @v3spositiontaking_2 WHEN 3 THEN @v3spositiontaking_3 WHEN 20 THEN @v3spositiontaking_20  WHEN 10 THEN @v3spositiontaking_10 ELSE 0 END
											
											WHEN 5 THEN case cs.bettype WHEN 1 THEN @v5spositiontaking_1 WHEN 2 THEN @v5spositiontaking_2 WHEN 3 THEN @v5spositiontaking_3 WHEN 20 THEN @v5spositiontaking_20 WHEN 9999 THEN @v5spositiontaking_9999 WHEN 10 THEN @v5spositiontaking_10  ELSE 0 END
											
											WHEN 8 THEN case cs.bettype WHEN 1 THEN @v8spositiontaking_1 WHEN 3 THEN @v8spositiontaking_3 WHEN 20 THEN @v8spositiontaking_20 WHEN 10 THEN @v8spositiontaking_10  ELSE 0 END
											
											WHEN 10 THEN case cs.bettype WHEN 1 THEN @v10spositiontaking_1 WHEN 2 THEN @v10spositiontaking_2 WHEN 3 THEN @v10spositiontaking_3 WHEN 20 THEN @v10spositiontaking_20  WHEN 10 THEN @v10spositiontaking_10 ELSE 0 END
											
											WHEN 11 THEN case cs.bettype WHEN 1 THEN @v11spositiontaking_1 WHEN 20 THEN @v11spositiontaking_20  WHEN 10 THEN @v11spositiontaking_10  ELSE 0 END
											
											WHEN 99 THEN case cs.bettype WHEN 1 THEN @v99spositiontaking_1 WHEN 2 THEN @v99spositiontaking_2 WHEN 3 THEN @v99spositiontaking_3 WHEN 9 THEN @v99spositiontaking_9 WHEN 20 THEN @v99spositiontaking_20  WHEN 10 THEN @v99spositiontaking_10  ELSE 0 END
											
											WHEN 154 THEN CASE cs.bettype WHEN 20 THEN @v154spositiontaking_20 ELSE 0 END
											ELSE cs.spositiontaking END
									END
				FROM @tmp_cs cs	
					INNER JOIN @tmp_mag scs ON cs.sporttype = scs.sporttype AND cs.bettype = scs.bettype						
				WHERE scs.isautopositiontaking = 0 						
				
				--don't update s1 for member under master was set i3=1(live)
				UPDATE cs
				SET cs.slivepositiontaking = 
										CASE WHEN (@UpdateMultiple = 1 
											AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
												OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
												OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
												OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
												OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
												OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
												OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
												OR (cs.sporttype=99 AND @UpdatePositiontakingv99 = 0)
												OR (cs.sporttype = 154 AND @UpdatePositiontakingv154 = 0)
												)) 
											THEN cs.slivepositiontaking 		
										ELSE case cs.sporttype WHEN 1 THEN case cs.bettype 
																					WHEN 1 THEN @slivepositiontaking_1 
																					WHEN 3 THEN @slivepositiontaking_3 
																					WHEN 7 THEN @slivepositiontaking_7 
																					WHEN 8 THEN @slivepositiontaking_8 
																					ELSE cs.slivepositiontaking END 
																	ELSE cs.slivepositiontaking END
										END
				FROM @tmp_cs cs
					INNER JOIN @tmp_mag scs ON cs.sporttype = scs.sporttype AND cs.bettype = scs.bettype
				WHERE scs.isautolivepositiontaking = 0								
					
				/*
				--don't update s1 for member under master was set i3=1(normal)
				UPDATE cs WITH (ROWLOCK, UPDLOCK)
				SET
					cs.spositiontaking = 
									CASE WHEN (@UpdateMultiple = 1 
											AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
												OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
												OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
												OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
												OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
												OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
												OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
												OR (cs.sporttype=99 AND cs.bettype<>9 AND @UpdatePositiontakingv99 = 0) 
												OR (cs.sporttype=99 AND cs.bettype=9 AND @UpdatePositiontakingv99MP = 0) 
												OR (cs.sporttype = 154 AND cs.bettype = 20 AND @UpdatePositiontakingv154 = 0) )) 
											THEN cs.spositiontaking 
									ELSE CASE cs.sporttype 	
											WHEN 1 THEN case cs.bettype WHEN 1 THEN @spositiontaking_1 WHEN 2 THEN @spositiontaking_2 WHEN 3 THEN @spositiontaking_3 WHEN 4 THEN @spositiontaking_4 WHEN 5 THEN @spositiontaking_5 WHEN 6 THEN @spositiontaking_6 WHEN 7 THEN @spositiontaking_7 WHEN 8 THEN @spositiontaking_8 WHEN 9 THEN @spositiontaking_9 WHEN 10 THEN @spositiontaking_10 ELSE 0 END
											WHEN 2 THEN case cs.bettype WHEN 1 THEN @v2spositiontaking_1 WHEN 2 THEN @v2spositiontaking_2 WHEN 3 THEN @v2spositiontaking_3 WHEN 7 THEN @v2spositiontaking_7 WHEN 8 THEN @v2spositiontaking_8 WHEN 20 THEN @v2spositiontaking_20  ELSE 0 END
											WHEN 3 THEN case cs.bettype WHEN 1 THEN @v3spositiontaking_1 WHEN 2 THEN @v3spositiontaking_2 WHEN 3 THEN @v3spositiontaking_3 WHEN 20 THEN @v3spositiontaking_20 ELSE 0 END
											WHEN 5 THEN case cs.bettype WHEN 1 THEN @v5spositiontaking_1 WHEN 2 THEN @v5spositiontaking_2 WHEN 3 THEN @v5spositiontaking_3 WHEN 20 THEN @v5spositiontaking_20 ELSE 0 END
											WHEN 8 THEN case cs.bettype WHEN 1 THEN @v8spositiontaking_1 WHEN 3 THEN @v8spositiontaking_3 WHEN 20 THEN @v8spositiontaking_20 ELSE 0 END
											WHEN 10 THEN case cs.bettype WHEN 1 THEN @v10spositiontaking_1 WHEN 2 THEN @v10spositiontaking_2 WHEN 3 THEN @v10spositiontaking_3 WHEN 20 THEN @v10spositiontaking_20 ELSE 0 END
											WHEN 11 THEN case cs.bettype WHEN 1 THEN @v11spositiontaking_1 WHEN 20 THEN @v11spositiontaking_20 ELSE 0 END
											WHEN 99 THEN case cs.bettype WHEN 1 THEN @v99spositiontaking_1 WHEN 2 THEN @v99spositiontaking_2 WHEN 3 THEN @v99spositiontaking_3 WHEN 9 THEN @v99spositiontaking_9 WHEN 20 THEN @v99spositiontaking_20 ELSE 0 END
											WHEN 154 THEN CASE cs.bettype WHEN 20 THEN @v154spositiontaking_20 ELSE 0 END
											ELSE cs.spositiontaking END
									END
				FROM Custsetting cs INNER JOIN custinfo c (nolock) on cs.custid = c.custid
					INNER JOIN custsetting scs (nolock) on scs.custid = c.mrecommEND and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
				WHERE cs.custid=@custid and c.roleid = 1 and scs.isautopositiontaking = 0
				
				--don't update s1 for member under master was set i3=1(live)
				UPDATE cs with (ROWLOCK, UPDLOCK)
				SET
					cs.slivepositiontaking = 
										CASE WHEN (@UpdateMultiple = 1 
											AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
												OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
												OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
												OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
												OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
												OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
												OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
												OR (cs.sporttype=99 AND @UpdatePositiontakingv99 = 0)
												OR (cs.sporttype = 154 AND @UpdatePositiontakingv154 = 0)
												)) 
											THEN cs.slivepositiontaking 		
										ELSE case cs.sporttype WHEN 1 THEN case cs.bettype 
																					WHEN 1 THEN @slivepositiontaking_1 
																					WHEN 3 THEN @slivepositiontaking_3 
																					WHEN 7 THEN @slivepositiontaking_7 
																					WHEN 8 THEN @slivepositiontaking_8 
																					ELSE cs.slivepositiontaking END 
																	ELSE cs.slivepositiontaking END
										END
				FROM Custsetting cs INNER JOIN custinfo c (nolock) on cs.custid = c.custid
					INNER JOIN custsetting scs (nolock) on scs.custid = c.mrecommEND and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
				where cs.custid=@custid and c.roleid = 1 and scs.isautolivepositiontaking = 0
				*/
			END--end roleid = 4
		ELSE IF @roleid = 3
		BEGIN
			--don't update m1,s1 for member under agent was set im2=1
			update cs
			set	mpositiontaking = 
						CASE WHEN (@UpdateMultiple = 1 
								AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
									OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
									OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
									OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
									OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
									OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
									OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
									OR (cs.sporttype=99 AND cs.bettype<>9 AND @UpdatePositiontakingv99 = 0) 
									OR (cs.sporttype=99 AND cs.bettype=9 AND @UpdatePositiontakingv99MP = 0)
									OR (cs.sporttype = 154 AND @UpdatePositiontakingv154 = 0)
									)) 
							THEN
								cs.mpositiontaking		
						ELSE CASE cs.sporttype
				 			WHEN 1 THEN CASE cs.bettype WHEN 1 THEN @mpositiontaking_1 WHEN 2 THEN @mpositiontaking_2 WHEN 3 THEN @mpositiontaking_3 WHEN 4 THEN @mpositiontaking_4 WHEN 5 THEN @mpositiontaking_5 WHEN 6 THEN @mpositiontaking_6 WHEN 7 THEN @mpositiontaking_7 WHEN 8 THEN @mpositiontaking_8 WHEN 9 THEN @mpositiontaking_9 WHEN 10 THEN @mpositiontaking_10 WHEN 9999 THEN @mpositiontaking_9999 ELSE 0 END
				 			
							WHEN 2 THEN CASE cs.bettype WHEN 1 THEN @v2mpositiontaking_1 WHEN 2 THEN @v2mpositiontaking_2 WHEN 3 THEN @v2mpositiontaking_3 WHEN 7 THEN @v2mpositiontaking_7 WHEN 8 THEN @v2mpositiontaking_8 /*WHEN 9 THEN @v2mpositiontaking_9*/ WHEN 20 THEN @v2mpositiontaking_20 WHEN 10 THEN @v2mpositiontaking_10  ELSE 0 END
							
							WHEN 3 THEN CASE cs.bettype WHEN 1 THEN @v3mpositiontaking_1 WHEN 2 THEN @v3mpositiontaking_2 WHEN 3 THEN @v3mpositiontaking_3 WHEN 20 THEN @v3mpositiontaking_20 WHEN 10 THEN @v3mpositiontaking_10 ELSE 0 END
							
							WHEN 5 THEN CASE cs.bettype WHEN 1 THEN @v5mpositiontaking_1 WHEN 2 THEN @v5mpositiontaking_2 WHEN 3 THEN @v5mpositiontaking_3 WHEN 20 THEN @v5mpositiontaking_20 WHEN 9999 THEN @v5mpositiontaking_9999 WHEN 10 THEN @v5mpositiontaking_10 ELSE 0 END
							
							WHEN 8 THEN CASE cs.bettype WHEN 1 THEN @v8mpositiontaking_1 WHEN 3 THEN @v8mpositiontaking_3 WHEN 20 THEN @v8mpositiontaking_20 WHEN 10 THEN @v8mpositiontaking_10 ELSE 0 END
							
							WHEN 10 THEN CASE cs.bettype WHEN 1 THEN @v10mpositiontaking_1 WHEN 2 THEN @v10mpositiontaking_2 WHEN 3 THEN @v10mpositiontaking_3 WHEN 20 THEN @v10mpositiontaking_20 WHEN 10 THEN @v10mpositiontaking_10 ELSE 0 END
							
							WHEN 11 THEN CASE cs.bettype WHEN 1 THEN @v11mpositiontaking_1 WHEN 20 THEN @v11mpositiontaking_20 WHEN 10 THEN @v11mpositiontaking_10  ELSE 0 END
							
							WHEN 99 THEN CASE cs.bettype WHEN 1 THEN @v99mpositiontaking_1 WHEN 2 THEN @v99mpositiontaking_2 WHEN 3 THEN @v99mpositiontaking_3 WHEN 20 THEN @v99mpositiontaking_20 WHEN 9 THEN @v99mpositiontaking_9 WHEN 10 THEN @v99mpositiontaking_10 ELSE 0 END

							WHEN 154 THEN CASE cs.bettype WHEN 20 THEN @v154mpositiontaking_20 ELSE 0 END 
							
							ELSE cs.mpositiontaking END
						END,
			spositiontaking =  
						CASE WHEN (@UpdateMultiple = 1 
								AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
									OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
									OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
									OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
									OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
									OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
									OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
									OR (cs.sporttype=99 AND cs.bettype<>9 AND @UpdatePositiontakingv99 = 0) 
									OR (cs.sporttype = 154 AND @UpdatePositiontakingv154 = 0)
									OR (cs.sporttype=99 AND cs.bettype=9 AND @UpdatePositiontakingv99MP = 0) )) 
								THEN			
									cs.spositiontaking
							ELSE CASE cs.sporttype 
								WHEN 1 THEN 
										CASE cs.bettype 
												WHEN 1 THEN @spositiontaking_1 WHEN 2 THEN @spositiontaking_2 WHEN 3 THEN @spositiontaking_3 WHEN 4 THEN @spositiontaking_4 WHEN 5 THEN @spositiontaking_5 WHEN 6 THEN @spositiontaking_6 WHEN 7 THEN @spositiontaking_7 WHEN 8 THEN @spositiontaking_8 WHEN 9 THEN @spositiontaking_9 WHEN 10 THEN @spositiontaking_10 WHEN 9999 THEN @spositiontaking_9999 ELSE 0 END
								WHEN 2 THEN 
										CASE cs.bettype 
												WHEN 1 THEN @v2spositiontaking_1 WHEN 2 THEN @v2spositiontaking_2 WHEN 3 THEN @v2spositiontaking_3 WHEN 7 THEN @v2spositiontaking_7 WHEN 8 THEN @v2spositiontaking_8 /*WHEN 9 THEN @v2spositiontaking_9*/ WHEN 20 THEN @v2spositiontaking_20 WHEN 10 THEN @v2spositiontaking_10 ELSE 0 END
												
								WHEN 3 THEN 
										CASE cs.bettype WHEN 1 THEN @v3spositiontaking_1 WHEN 2 THEN @v3spositiontaking_2 WHEN 3 THEN @v3spositiontaking_3 WHEN 20 THEN @v3spositiontaking_20  WHEN 10 THEN @v3spositiontaking_10  ELSE 0 END
								WHEN 5 THEN 
										CASE cs.bettype WHEN 1 THEN @v5spositiontaking_1 WHEN 2 THEN @v5spositiontaking_2 WHEN 3 THEN @v5spositiontaking_3 WHEN 20 THEN @v5spositiontaking_20 WHEN 9999 THEN @v5spositiontaking_9999  WHEN 10 THEN @v5spositiontaking_10  ELSE 0 END
								WHEN 8 THEN 
										CASE cs.bettype WHEN 1 THEN @v8spositiontaking_1 WHEN 3 THEN @v8spositiontaking_3 WHEN 20 THEN @v8spositiontaking_20  WHEN 10 THEN @v8spositiontaking_10  ELSE 0 END
								WHEN 10 THEN 
										CASE cs.bettype WHEN 1 THEN @v10spositiontaking_1 WHEN 2 THEN @v10spositiontaking_2 WHEN 3 THEN @v10spositiontaking_3 WHEN 20 THEN @v10spositiontaking_20  WHEN 10 THEN @v10spositiontaking_10  ELSE 0 END
								WHEN 11 THEN 
										CASE cs.bettype WHEN 1 THEN @v11spositiontaking_1 WHEN 20 THEN @v11spositiontaking_20  WHEN 10 THEN @v11spositiontaking_10  ELSE 0 END
								WHEN 99 THEN 
										CASE cs.bettype WHEN 1 THEN @v99spositiontaking_1 WHEN 2 THEN @v99spositiontaking_2 WHEN 3 THEN @v99spositiontaking_3 WHEN 20 THEN @v99spositiontaking_20 WHEN 9 THEN @v99spositiontaking_9  WHEN 10 THEN @v99spositiontaking_10  ELSE 0 END

								WHEN 154 then CASE cs.bettype WHEN 20 then @v154spositiontaking_20 ELSE 0 END 
								ELSE cs.spositiontaking END
							END
			FROM @tmp_cs cs
				INNER JOIN @tmp_ag acs ON cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
			WHERE acs.isautompositiontaking = 0 
			
			--don't update m1,s1 for member under agent was set im2=1(live)
			update cs
			set mlivepositiontaking = 
								CASE WHEN (@UpdateMultiple = 1 
									AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
										OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
										OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
										OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
										OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
										OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
										OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
										OR (cs.sporttype=99 AND @UpdatePositiontakingv99 = 0)
										OR (cs.sporttype=154 AND @UpdatePositiontakingv154 = 0))) 
									THEN cs.mlivepositiontaking	
								ELSE CASE cs.sporttype 	
									WHEN 1 THEN CASE cs.bettype 
											WHEN 1 THEN @mlivepositiontaking_1 
											WHEN 3 THEN @mlivepositiontaking_3 
											WHEN 7 THEN @mlivepositiontaking_7 
											WHEN 8 THEN @mlivepositiontaking_8 
											ELSE cs.mlivepositiontaking 
											END ELSE cs.mlivepositiontaking END END,
				slivepositiontaking = 
								CASE WHEN (@UpdateMultiple = 1 
									AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
										OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
										OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
										OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
										OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
										OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
										OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
										OR (cs.sporttype=99 AND @UpdatePositiontakingv99 = 0)
										OR (cs.sporttype=154 AND @UpdatePositiontakingv154 = 0) 
										)) 
									THEN cs.slivepositiontaking
								ELSE CASE cs.sporttype 	
									WHEN 1 THEN CASE cs.bettype 
											WHEN 1 THEN @slivepositiontaking_1 
											WHEN 3 THEN @slivepositiontaking_3 
											WHEN 7 THEN @slivepositiontaking_7 
											WHEN 8 THEN @slivepositiontaking_8 
											ELSE cs.slivepositiontaking END 
									ELSE cs.slivepositiontaking END END
			FROM @tmp_cs cs
				INNER JOIN @tmp_ag acs ON cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
			WHERE acs.isautolivempositiontaking = 0 
			
			/*	
			--don't update m1,s1 for member under agent was set im2=1
			UPDATE cs WITH (ROWLOCK, UPDLOCK)
				SET
					mpositiontaking = 
								CASE WHEN (@UpdateMultiple = 1 
										AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
											OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
											OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
											OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
											OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
											OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
											OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
											OR (cs.sporttype=99 AND cs.bettype<>9 AND @UpdatePositiontakingv99 = 0) 
											OR (cs.sporttype=99 AND cs.bettype=9 AND @UpdatePositiontakingv99MP = 0)
											OR (cs.sporttype = 154 AND @UpdatePositiontakingv154 = 0)
											)) 
									THEN
										cs.mpositiontaking		
								ELSE CASE cs.sporttype
						 			WHEN 1 THEN CASE cs.bettype WHEN 1 THEN @mpositiontaking_1 WHEN 2 THEN @mpositiontaking_2 WHEN 3 THEN @mpositiontaking_3 WHEN 4 THEN @mpositiontaking_4 WHEN 5 THEN @mpositiontaking_5 WHEN 6 THEN @mpositiontaking_6 WHEN 7 THEN @mpositiontaking_7 WHEN 8 THEN @mpositiontaking_8 WHEN 9 THEN @mpositiontaking_9 WHEN 10 THEN @mpositiontaking_10 ELSE 0 END
									WHEN 2 THEN CASE cs.bettype WHEN 1 THEN @v2mpositiontaking_1 WHEN 2 THEN @v2mpositiontaking_2 WHEN 3 THEN @v2mpositiontaking_3 WHEN 7 THEN @v2mpositiontaking_7 WHEN 8 THEN @v2mpositiontaking_8 WHEN 20 THEN @v2mpositiontaking_20 ELSE 0 END
									WHEN 3 THEN CASE cs.bettype WHEN 1 THEN @v3mpositiontaking_1 WHEN 2 THEN @v3mpositiontaking_2 WHEN 3 THEN @v3mpositiontaking_3 WHEN 20 THEN @v3mpositiontaking_20 ELSE 0 END
									WHEN 5 THEN CASE cs.bettype WHEN 1 THEN @v5mpositiontaking_1 WHEN 2 THEN @v5mpositiontaking_2 WHEN 3 THEN @v5mpositiontaking_3 WHEN 20 THEN @v5mpositiontaking_20 ELSE 0 END
									WHEN 8 THEN CASE cs.bettype WHEN 1 THEN @v8mpositiontaking_1 WHEN 3 THEN @v8mpositiontaking_3 WHEN 20 THEN @v8mpositiontaking_20 ELSE 0 END
									WHEN 10 THEN CASE cs.bettype WHEN 1 THEN @v10mpositiontaking_1 WHEN 2 THEN @v10mpositiontaking_2 WHEN 3 THEN @v10mpositiontaking_3 WHEN 20 THEN @v10mpositiontaking_20 ELSE 0 END
									WHEN 11 THEN CASE cs.bettype WHEN 1 THEN @v11mpositiontaking_1 WHEN 20 THEN @v11mpositiontaking_20 ELSE 0 END
									WHEN 99 THEN CASE cs.bettype WHEN 1 THEN @v99mpositiontaking_1 WHEN 2 THEN @v99mpositiontaking_2 WHEN 3 THEN @v99mpositiontaking_3 WHEN 20 THEN @v99mpositiontaking_20 WHEN 9 THEN @v99mpositiontaking_9 ELSE 0 END

									WHEN 154 THEN CASE cs.bettype WHEN 20 THEN @v154mpositiontaking_20 ELSE 0 END 
									ELSE cs.mpositiontaking END
								END,
					spositiontaking =  
								CASE WHEN (@UpdateMultiple = 1 
										AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
											OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
											OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
											OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
											OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
											OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
											OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
											OR (cs.sporttype=99 AND cs.bettype<>9 AND @UpdatePositiontakingv99 = 0) 
											OR (cs.sporttype = 154 AND @UpdatePositiontakingv154 = 0)
											OR (cs.sporttype=99 AND cs.bettype=9 AND @UpdatePositiontakingv99MP = 0) )) 
										THEN			
											cs.spositiontaking
									ELSE CASE cs.sporttype 
										WHEN 1 THEN CASE cs.bettype WHEN 1 THEN @spositiontaking_1 WHEN 2 THEN @spositiontaking_2 WHEN 3 THEN @spositiontaking_3 WHEN 4 THEN @spositiontaking_4 WHEN 5 THEN @spositiontaking_5 WHEN 6 THEN @spositiontaking_6 WHEN 7 THEN @spositiontaking_7 WHEN 8 THEN @spositiontaking_8 WHEN 9 THEN @spositiontaking_9 WHEN 10 THEN @spositiontaking_10 ELSE 0 END
										WHEN 2 THEN CASE cs.bettype WHEN 1 THEN @v2spositiontaking_1 WHEN 2 THEN @v2spositiontaking_2 WHEN 3 THEN @v2spositiontaking_3 WHEN 7 THEN @v2spositiontaking_7 WHEN 8 THEN @v2spositiontaking_8 WHEN 20 THEN @v2spositiontaking_20 ELSE 0 END
										WHEN 3 THEN CASE cs.bettype WHEN 1 THEN @v3spositiontaking_1 WHEN 2 THEN @v3spositiontaking_2 WHEN 3 THEN @v3spositiontaking_3 WHEN 20 THEN @v3spositiontaking_20 ELSE 0 END
										WHEN 5 THEN CASE cs.bettype WHEN 1 THEN @v5spositiontaking_1 WHEN 2 THEN @v5spositiontaking_2 WHEN 3 THEN @v5spositiontaking_3 WHEN 20 THEN @v5spositiontaking_20 ELSE 0 END
										WHEN 8 THEN CASE cs.bettype WHEN 1 THEN @v8spositiontaking_1 WHEN 3 THEN @v8spositiontaking_3 WHEN 20 THEN @v8spositiontaking_20 ELSE 0 END
										WHEN 10 THEN CASE cs.bettype WHEN 1 THEN @v10spositiontaking_1 WHEN 2 THEN @v10spositiontaking_2 WHEN 3 THEN @v10spositiontaking_3 WHEN 20 THEN @v10spositiontaking_20 ELSE 0 END
										WHEN 11 THEN CASE cs.bettype WHEN 1 THEN @v11spositiontaking_1 WHEN 20 THEN @v11spositiontaking_20 ELSE 0 END
										WHEN 99 THEN CASE cs.bettype WHEN 1 THEN @v99spositiontaking_1 WHEN 2 THEN @v99spositiontaking_2 WHEN 3 THEN @v99spositiontaking_3 WHEN 20 THEN @v99spositiontaking_20 WHEN 9 THEN @v99spositiontaking_9 ELSE 0 END

										WHEN 154 then CASE cs.bettype WHEN 20 then @v154spositiontaking_20 ELSE 0 END 
										ELSE cs.spositiontaking END
									END
				FROM Custsetting cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
					INNER JOIN Custsetting acs WITH(NOLOCK) ON acs.custid = c.recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
				WHERE c.custid=@custid AND c.roleid = 1 AND acs.isautompositiontaking = 0 

			--don't update m1,s1 for member under agent was set im2=1(live)
			UPDATE cs WITH (ROWLOCK, UPDLOCK)
			SET
				mlivepositiontaking = 
								CASE WHEN (@UpdateMultiple = 1 
									AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
										OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
										OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
										OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
										OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
										OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
										OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
										OR (cs.sporttype=99 AND @UpdatePositiontakingv99 = 0)
										OR (cs.sporttype=154 AND @UpdatePositiontakingv154 = 0))) 
									THEN cs.mlivepositiontaking	
								ELSE CASE cs.sporttype 	
									WHEN 1 THEN CASE cs.bettype 
											WHEN 1 THEN @mlivepositiontaking_1 
											WHEN 3 THEN @mlivepositiontaking_3 
											WHEN 7 THEN @mlivepositiontaking_7 
											WHEN 8 THEN @mlivepositiontaking_8 
											ELSE cs.mlivepositiontaking 
											END ELSE cs.mlivepositiontaking END END,
				slivepositiontaking = 
								CASE WHEN (@UpdateMultiple = 1 
									AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
										OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
										OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
										OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
										OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
										OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
										OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
										OR (cs.sporttype=99 AND @UpdatePositiontakingv99 = 0)
										OR (cs.sporttype=154 AND @UpdatePositiontakingv154 = 0) 
										)) 
									THEN cs.slivepositiontaking
								ELSE CASE cs.sporttype 	
									WHEN 1 THEN CASE cs.bettype 
											WHEN 1 THEN @slivepositiontaking_1 
											WHEN 3 THEN @slivepositiontaking_3 
											WHEN 7 THEN @slivepositiontaking_7 
											WHEN 8 THEN @slivepositiontaking_8 
											ELSE cs.slivepositiontaking END 
									ELSE cs.slivepositiontaking END END
			FROM Custsetting cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
				INNER JOIN Custsetting acs WITH(NOLOCK) ON acs.custid = c.recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
			WHERE c.custid=@custid AND c.roleid = 1 AND acs.isautolivempositiontaking = 0 
			*/
		END-- end roleid = 3
		
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
		where cs.sporttype = 1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking < aco.minlivepositiontaking
		
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
		where cs.sporttype = 1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking > aco.maxlivepositiontaking
				
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
		where cs.sporttype = 1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking + cs.mlivepositiontaking < mco.minlivepositiontaking
		
		
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
		where cs.sporttype = 1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking +cs.mlivepositiontaking > mcs.maxlivepositiontaking
				
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
		where cs.sporttype = 1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking + cs.mlivepositiontaking + cs.slivepositiontaking < sco.minlivepositiontaking 			
		
		
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
		where cs.sporttype = 1 and cs.bettype in (1,3,7,8) and cs.slivepositiontaking + cs.mlivepositiontaking + cs.alivepositiontaking > scs.slivepositiontaking
			
		--update pt change on member
		update cs
		SET cs.apositiontaking = t.apositiontaking,
			cs.mpositiontaking = t.mpositiontaking,
			cs.spositiontaking = t.spositiontaking,
			cs.alivepositiontaking = t.alivepositiontaking,
			cs.mlivepositiontaking = t.mlivepositiontaking,
			cs.slivepositiontaking = t.slivepositiontaking
		FROM @tmp_cs t
			INNER JOIN custsetting cs WITH(UPDLOCK,ROWLOCK) ON t.custid = cs.custid and t.sporttype = cs.sporttype and t.bettype = cs.bettype
		WHERE cs.apositiontaking <> t.apositiontaking
				OR cs.mpositiontaking <> t.mpositiontaking
				OR cs.spositiontaking <> t.spositiontaking
				OR cs.alivepositiontaking <> t.alivepositiontaking
				OR cs.mlivepositiontaking <> t.mlivepositiontaking
				OR cs.slivepositiontaking <> t.slivepositiontaking
				
	END -- end process roleid in 3,4
	ELSE IF @roleid = 2
	BEGIN				
		UPDATE custsetting WITH (ROWLOCK, UPDLOCK)
		SET
			apositiontaking = CASE WHEN (@UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0)  OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND bettype<>9 AND @UpdatePositiontakingv99 = 0) OR (sporttype=99 AND bettype=9 AND @UpdatePositiontakingv99MP = 0) OR (sporttype=154  AND @UpdatePositiontakingv154 = 0))) THEN apositiontaking ELSE CASE sporttype WHEN 1 THEN CASE bettype WHEN 1 THEN @apositiontaking_1 WHEN 2 THEN @apositiontaking_2 WHEN 3 THEN @apositiontaking_3 WHEN 4 THEN @apositiontaking_4 WHEN 5 THEN @apositiontaking_5 WHEN 6 THEN @apositiontaking_6 WHEN 7 THEN @apositiontaking_7 WHEN 8 THEN @apositiontaking_8 WHEN 9 THEN @apositiontaking_9 WHEN 10 THEN @apositiontaking_10 WHEN 9999 THEN @apositiontaking_9999 ELSE 0 END
							WHEN 2 THEN CASE bettype WHEN 1 THEN @v2apositiontaking_1 WHEN 2 THEN @v2apositiontaking_2 WHEN 3 THEN @v2apositiontaking_3 WHEN 7 THEN @v2apositiontaking_7 WHEN 8 THEN @v2apositiontaking_8 WHEN 20 THEN @v2apositiontaking_20 WHEN 10 THEN @v2apositiontaking_10 ELSE 0 END
							WHEN 3 THEN CASE bettype WHEN 1 THEN @v3apositiontaking_1 WHEN 2 THEN @v3apositiontaking_2 WHEN 3 THEN @v3apositiontaking_3 WHEN 20 THEN @v3apositiontaking_20  WHEN 10 THEN @v3apositiontaking_10 ELSE 0 END
							WHEN 5 THEN CASE bettype WHEN 1 THEN @v5apositiontaking_1 WHEN 2 THEN @v5apositiontaking_2 WHEN 3 THEN @v5apositiontaking_3 WHEN 20 THEN @v5apositiontaking_20 WHEN 9999 THEN @v5apositiontaking_9999  WHEN 10 THEN @v5apositiontaking_10  ELSE 0 END
							WHEN 8 THEN CASE bettype WHEN 1 THEN @v8apositiontaking_1 WHEN 3 THEN @v8apositiontaking_3 WHEN 20 THEN @v8apositiontaking_20  WHEN 10 THEN @v8apositiontaking_10  ELSE 0 END
							WHEN 10 THEN CASE bettype WHEN 1 THEN @v10apositiontaking_1 WHEN 2 THEN @v10apositiontaking_2 WHEN 3 THEN @v10apositiontaking_3 WHEN 20 THEN @v10apositiontaking_20  WHEN 10 THEN @v10apositiontaking_10   ELSE 0 END
							WHEN 11 THEN CASE bettype WHEN 1 THEN @v11apositiontaking_1 WHEN 20 THEN @v11apositiontaking_20  WHEN 10 THEN @v11apositiontaking_10  ELSE 0 END
							WHEN 99 THEN CASE bettype WHEN 1 THEN @v99apositiontaking_1 WHEN 2 THEN @v99apositiontaking_2 WHEN 3 THEN @v99apositiontaking_3 WHEN 9 THEN @v99apositiontaking_9 WHEN 20 THEN @v99apositiontaking_20  WHEN 10 THEN @v99apositiontaking_10  ELSE 0 END
							WHEN 154 THEN CASE bettype WHEN 20 THEN @v154apositiontaking_20 ELSE 0 END					
							ELSE apositiontaking END END,
			alivepositiontaking = CASE WHEN (@UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0)  OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND @UpdatePositiontakingv99 = 0) OR (sporttype=154  AND @UpdatePositiontakingv154 = 0))) THEN alivepositiontaking ELSE CASE sporttype 	WHEN 1 THEN CASE bettype WHEN 1 THEN @alivepositiontaking_1 WHEN 3 THEN @alivepositiontaking_3 WHEN 7 THEN @alivepositiontaking_7 WHEN 8 THEN @alivepositiontaking_8 ELSE alivepositiontaking END ELSE alivepositiontaking END END,
			
			--Auto Master PT
			mpositiontaking = CASE WHEN (@UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0)  OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND bettype<>9 AND @UpdatePositiontakingv99 = 0) OR (sporttype=99 AND bettype=9 AND @UpdatePositiontakingv99MP = 0) OR (sporttype=154  AND @UpdatePositiontakingv154 = 0))) THEN mpositiontaking ELSE CASE sporttype WHEN 1 THEN CASE bettype WHEN 1 THEN @mpositiontaking_1 WHEN 2 THEN @mpositiontaking_2 WHEN 3 THEN @mpositiontaking_3 WHEN 4 THEN @mpositiontaking_4 WHEN 5 THEN @mpositiontaking_5 WHEN 6 THEN @mpositiontaking_6 WHEN 7 THEN @mpositiontaking_7 WHEN 8 THEN @mpositiontaking_8 WHEN 9 THEN @mpositiontaking_9 WHEN 10 THEN @mpositiontaking_10 WHEN 9999 THEN @mpositiontaking_9999 ELSE 0 END
							WHEN 2 THEN CASE bettype WHEN 1 THEN @v2mpositiontaking_1 WHEN 2 THEN @v2mpositiontaking_2 WHEN 3 THEN @v2mpositiontaking_3 WHEN 7 THEN @v2mpositiontaking_7 WHEN 8 THEN @v2mpositiontaking_8 WHEN 20 THEN @v2mpositiontaking_20  WHEN 10 THEN @v2mpositiontaking_10  ELSE 0 END
							WHEN 3 THEN CASE bettype WHEN 1 THEN @v3mpositiontaking_1 WHEN 2 THEN @v3mpositiontaking_2 WHEN 3 THEN @v3mpositiontaking_3 WHEN 20 THEN @v3mpositiontaking_20  WHEN 10 THEN @v3mpositiontaking_10  ELSE 0 END
							WHEN 5 THEN CASE bettype WHEN 1 THEN @v5mpositiontaking_1 WHEN 2 THEN @v5mpositiontaking_2 WHEN 3 THEN @v5mpositiontaking_3 WHEN 20 THEN @v5mpositiontaking_20 WHEN 9999 THEN @v5mpositiontaking_9999  WHEN 10 THEN @v5mpositiontaking_10  ELSE 0 END
							WHEN 8 THEN CASE bettype WHEN 1 THEN @v8mpositiontaking_1 WHEN 3 THEN @v8mpositiontaking_3 WHEN 20 THEN @v8mpositiontaking_20  WHEN 10 THEN @v8mpositiontaking_10  ELSE 0 END
							WHEN 10 THEN CASE bettype WHEN 1 THEN @v10mpositiontaking_1 WHEN 2 THEN @v10mpositiontaking_2 WHEN 3 THEN @v10mpositiontaking_3 WHEN 20 THEN @v10mpositiontaking_20  WHEN 10 THEN @v10mpositiontaking_10  ELSE 0 END
							WHEN 11 THEN CASE bettype WHEN 1 THEN @v11mpositiontaking_1 WHEN 20 THEN @v11mpositiontaking_20  WHEN 10 THEN @v11mpositiontaking_10  ELSE 0 END
							WHEN 99 THEN CASE bettype WHEN 1 THEN @v99mpositiontaking_1 WHEN 2 THEN @v99mpositiontaking_2 WHEN 3 THEN @v99mpositiontaking_3 WHEN 9 THEN @v99mpositiontaking_9 WHEN 20 THEN @v99mpositiontaking_20  WHEN 10 THEN @v99mpositiontaking_10  ELSE 0 END
							WHEN 154 THEN CASE bettype WHEN 20 THEN @v154mpositiontaking_20 ELSE 0 END																	
							ELSE mpositiontaking END END,
			mlivepositiontaking = CASE WHEN ( @UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0) OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND @UpdatePositiontakingv99 = 0)OR (sporttype=154  AND @UpdatePositiontakingv154 = 0))) THEN mlivepositiontaking ELSE CASE sporttype 	WHEN 1 THEN CASE bettype WHEN 1 THEN @mlivepositiontaking_1 WHEN 3 THEN @mlivepositiontaking_3 WHEN 7 THEN @mlivepositiontaking_7 WHEN 8 THEN @mlivepositiontaking_8 ELSE mlivepositiontaking END ELSE mlivepositiontaking END END,
			
			spositiontaking = CASE WHEN (@UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0)  OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND bettype<>9  AND  @UpdatePositiontakingv99 = 0) OR (sporttype=99 AND bettype=9  AND  @UpdatePositiontakingv99MP = 0) OR (sporttype=154  AND @UpdatePositiontakingv154 = 0))) THEN spositiontaking ELSE CASE sporttype WHEN 1 THEN CASE bettype WHEN 1 THEN @spositiontaking_1 WHEN 2 THEN @spositiontaking_2 WHEN 3 THEN @spositiontaking_3 WHEN 4 THEN @spositiontaking_4 WHEN 5 THEN @spositiontaking_5 WHEN 6 THEN @spositiontaking_6 WHEN 7 THEN @spositiontaking_7 WHEN 8 THEN @spositiontaking_8 WHEN 9 THEN @spositiontaking_9 WHEN 10 THEN @spositiontaking_10 WHEN 9999 THEN @spositiontaking_9999 ELSE 0 END
							WHEN 2 THEN CASE bettype WHEN 1 THEN @v2spositiontaking_1 WHEN 2 THEN @v2spositiontaking_2 WHEN 3 THEN @v2spositiontaking_3 WHEN 7 THEN @v2spositiontaking_7 WHEN 8 THEN @v2spositiontaking_8 WHEN 20 THEN @v2spositiontaking_20 WHEN 10 THEN @v2spositiontaking_10  ELSE 0 END
							WHEN 3 THEN CASE bettype WHEN 1 THEN @v3spositiontaking_1 WHEN 2 THEN @v3spositiontaking_2 WHEN 3 THEN @v3spositiontaking_3 WHEN 20 THEN @v3spositiontaking_20 WHEN 10 THEN @v3spositiontaking_10  ELSE  0 END
							WHEN 5 THEN CASE bettype WHEN 1 THEN @v5spositiontaking_1 WHEN 2 THEN @v5spositiontaking_2 WHEN 3 THEN @v5spositiontaking_3 WHEN 20 THEN @v5spositiontaking_20 WHEN 9999 THEN @v5spositiontaking_9999 WHEN 10 THEN @v5spositiontaking_10  ELSE 0 END
							WHEN 8 THEN CASE bettype WHEN 1 THEN @v8spositiontaking_1 WHEN 3 THEN @v8spositiontaking_3 WHEN 20 THEN @v8spositiontaking_20 WHEN 10 THEN @v8spositiontaking_10  ELSE 0 END
							WHEN 10 THEN CASE bettype WHEN 1 THEN @v10spositiontaking_1 WHEN 2 THEN @v10spositiontaking_2 WHEN 3 THEN @v10spositiontaking_3 WHEN 20 THEN @v10spositiontaking_20 WHEN 10 THEN @v10spositiontaking_10  ELSE 0 END
							WHEN 11 THEN CASE bettype WHEN 1 THEN @v11spositiontaking_1 WHEN 20 THEN @v11spositiontaking_20 WHEN 10 THEN @v11spositiontaking_10  ELSE 0 END
							WHEN 99 THEN CASE bettype WHEN 1 THEN @v99spositiontaking_1 WHEN 2 THEN @v99spositiontaking_2 WHEN 3 THEN @v99spositiontaking_3 WHEN 9 THEN @v99spositiontaking_9  WHEN 20 THEN @v99spositiontaking_20 WHEN 10 THEN @v99spositiontaking_10  ELSE 0 END
							WHEN 154 THEN CASE bettype WHEN 20 THEN @v154spositiontaking_20 ELSE 0 END									
							ELSE spositiontaking END END,
			slivepositiontaking = CASE WHEN ( @UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0) OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND @UpdatePositiontakingv99 = 0) OR (sporttype=154  AND @UpdatePositiontakingv154 = 0))) THEN slivepositiontaking ELSE CASE sporttype 	WHEN 1 THEN CASE bettype WHEN 1 THEN @slivepositiontaking_1 WHEN 3 THEN @slivepositiontaking_3 WHEN 7 THEN @slivepositiontaking_7 WHEN 8 THEN @slivepositiontaking_8 ELSE slivepositiontaking END ELSE slivepositiontaking END END
		WHERE custid=@custid
	END
END