/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,wsv_alp,bodbAdminNet,wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_07]
    @srecommend INT= 0,
    @mrecommend iNT = 0,
    @recommend INT = 0,
    @roleid INT
AS
    /*
        Created: Johnson
        Date: 2013-10-30
        Task: Apply execrep when corrects pt ON members
        DB: DBTXN/bodb02
        Original versions: Acc_CustomerUpdSuper_AutoPositiontaking
                    Acc_CustomerUpdMaster_MaxPositiontaking
                    Acc_CustomerUpdAgent_MaxPositiontaking
            
        Revision:
            - 20140818@Logan:   Exclude disabled members while updating Super, Master Setting [Redmine: #19631]
		  - 20150610@Daniel: 
		   + Improve medthod check table existing in subscribers	
		   + Separate custDB to new server DBCUST
		  - 20150917@Johnson: check constraint n4 when update s4 [Redmine:#43808]                  
          - 20190313@Johnson: enhance perf  [redmine:#109979]

        Parameter's Explanation:
    */ 
BEGIN
   
    SET NOCOUNT ON

     if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustSetting') = 1 
	   AND dbo.f_CheckRepTable('CustOverride') = 1 
	   )
    RETURN
	
	CREATE TABLE #tblCust(custid INT, recommend INT, mrecommend INT)
	
	DECLARE @tmpAg TABLE (
						sporttype INT, 
						bettype INT, 
						autompositiontaking SMALLMONEY,
						autolivempositiontaking SMALLMONEY,
						isautompositiontaking BIT,
						isautolivempositiontaking BIT,
						minpositiontaking SMALLMONEY, 
						minlivepositiontaking SMALLMONEY,
						maxpositiontaking SMALLMONEY,
						maxlivepositiontaking SMALLMONEY)
		
	DECLARE @tmpMAg TABLE(
						sporttype INT, 
						bettype INT, 
						mpositiontaking SMALLMONEY,
						mlivepositiontaking SMALLMONEY,
						autopositiontaking SMALLMONEY,
						autolivepositiontaking SMALLMONEY,
						isautopositiontaking BIT,
						isautolivepositiontaking BIT,
						minpositiontaking SMALLMONEY,
						minlivepositiontaking SMALLMONEY,
						maxpositiontaking SMALLMONEY,
						maxlivepositiontaking SMALLMONEY
						)
	
	DECLARE @tmpSAg TABLE(
						sporttype INT, 
						bettype INT, 
						spositiontaking SMALLMONEY,
						slivepositiontaking SMALLMONEY,
						minpositiontaking SMALLMONEY,
						minlivepositiontaking SMALLMONEY,
						maxpositiontaking SMALLMONEY,
						maxlivepositiontaking SMALLMONEY
						)	
							
							
    IF @roleid = 4
    BEGIN                
		INSERT INTO #tblCust(custid,mrecommend)
		SELECT custid,mrecommend
		FROM custinfo c WITH(NOLOCK) 
		WHERE c.srecommend = @srecommend
           AND c.roleid = 1
           AND c.Enabled = 1
		  
		INSERT INTO @tmpSAg(sporttype,bettype,spositiontaking,slivepositiontaking,minpositiontaking,minlivepositiontaking)  
		SELECT scs.sporttype, scs.bettype,spositiontaking,slivepositiontaking,minpositiontaking,minlivepositiontaking
		FROM custsetting scs WITH(NOLOCK)
			INNER JOIN CustOverride sco WITH(NOLOCK) ON scs.custid = sco.custid
													AND scs.sporttype = sco.sporttype
													AND scs.bettype = sco.bettype
		WHERE scs.custid = @srecommend
		
        --u = (i3 or i1)?(u3 or u1)
        --s1 = min(s4-m1-a1, u)
		UPDATE cs 
           SET spositiontaking =
                 CASE
                   WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking >
                          CASE
                            WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                            ELSE mcs.autopositiontaking
                          END
                     THEN CASE
                            WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                            ELSE mcs.autopositiontaking
                          END
                   ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
                 END
		FROM (SELECT c.custid, c.mrecommend, scs.*
			FROM #tblCust c
				CROSS JOIN @tmpSAg scs 
			)scs
		CROSS APPLY (SELECT TOP 1 autopositiontaking,isautopositiontaking
					FROM custsetting mcs WITH(NOLOCK)
					WHERE  mcs.custid = scs.mrecommend
					   AND mcs.sporttype = scs.sporttype
					   AND mcs.bettype = scs.bettype
					)mcs
		CROSS APPLY (SELECT TOP 1 spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking,autopositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = scs.custid
					   AND cs.sporttype = scs.sporttype
					   AND cs.bettype = scs.bettype
					   AND (cs.isautopositiontaking = 1
							OR mcs.isautopositiontaking = 1)
					)cs
		
		 --check super min
		--s1=max(n4-m1-a1,s1)
		UPDATE cs
		   SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
		FROM (SELECT c.custid, c.mrecommend, sco.*
			FROM #tblCust c
				CROSS JOIN @tmpSAg sco 
		)sco		
		CROSS APPLY (SELECT TOP 1 spositiontaking, mpositiontaking, apositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = sco.custid
					   AND cs.sporttype = sco.sporttype
					   AND cs.bettype = sco.bettype
					   AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
					)cs
		--live	
		UPDATE cs 
           SET slivepositiontaking =
                 CASE
                   WHEN scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking >
                          CASE
                            WHEN cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking
                          END
                     THEN CASE
                            WHEN cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking
                          END
                   ELSE scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
                 END
		FROM (SELECT c.custid, c.mrecommend, scs.*
			FROM #tblCust c
				CROSS JOIN @tmpSAg scs 
			WHERE sporttype = 1	
				AND bettype IN (1, 3, 7, 8)	
			)scs
		CROSS APPLY (SELECT TOP 1 autolivepositiontaking,isautolivepositiontaking
					FROM custsetting mcs WITH(NOLOCK)
					WHERE  mcs.custid = scs.mrecommend
					   AND mcs.sporttype = scs.sporttype
					   AND mcs.bettype = scs.bettype
					)mcs
		CROSS APPLY (SELECT TOP 1 slivepositiontaking, mlivepositiontaking, alivepositiontaking, autolivepositiontaking, isautolivepositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = scs.custid
					   AND cs.sporttype = scs.sporttype
					   AND cs.bettype = scs.bettype
					   AND (cs.isautolivepositiontaking = 1
							OR mcs.isautolivepositiontaking = 1
						   )
					)cs
		
		UPDATE cs
		   SET slivepositiontaking = sco.minlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
		FROM (SELECT c.custid, c.mrecommend, sco.*
			FROM #tblCust c
				CROSS JOIN @tmpSAg sco 
			WHERE sporttype = 1	
				AND bettype IN (1, 3, 7, 8)
		)sco		
		CROSS APPLY (SELECT TOP 1 slivepositiontaking, mlivepositiontaking, alivepositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = sco.custid
					   AND cs.sporttype = sco.sporttype
					   AND cs.bettype = sco.bettype
					   AND cs.alivepositiontaking + cs.mlivepositiontaking + cs.slivepositiontaking < sco.minlivepositiontaking
					)cs
		 
    END
    ELSE IF @roleid = 3
    BEGIN
        --UPDATE all agent AND member accounts
        DECLARE @mpos SMALLMONEY
              , @apos SMALLMONEY
              , @spos SMALLMONEY
              , @mapos1 SMALLMONEY
              , @mapos2 SMALLMONEY
              , @mapos SMALLMONEY
              , @maxmapos SMALLMONEY
        
		INSERT INTO #tblCust(custid,recommend)
        SELECT custid, recommend 
		FROM custinfo c WITH(NOLOCK)
		WHERE mrecommend = @mrecommend
           AND c.roleid = 1
           AND c.Enabled = 1
		
		INSERT INTO @tmpSAg(sporttype,bettype,spositiontaking,slivepositiontaking,minpositiontaking,minlivepositiontaking)
		SELECT scs.sporttype,scs.bettype,spositiontaking,slivepositiontaking,minpositiontaking,minlivepositiontaking
		FROM custsetting scs WITH(NOLOCK)
			INNER JOIN custoverride sco WITH(NOLOCK) ON scs.custid= sco.custid
													AND scs.sporttype = sco.sporttype
													AND scs.bettype = sco.bettype
		WHERE scs.custid = @srecommend
		
		INSERT INTO @tmpMAg(sporttype, bettype, mpositiontaking, mlivepositiontaking, autopositiontaking, autolivepositiontaking, 
			isautopositiontaking, isautolivepositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
		SELECT mcs.sporttype,mcs.bettype, mpositiontaking, mlivepositiontaking, autopositiontaking, autolivepositiontaking, 
			isautopositiontaking, isautolivepositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking
		FROM custsetting mcs WITH(NOLOCK)
			INNER JOIN custoverride mco WITH(NOLOCK) ON mcs.custid= mco.custid
													AND mcs.sporttype = mco.sporttype
													AND mcs.bettype = mco.bettype
		WHERE mcs.custid = @mrecommend
		
		--Recal AUTO MPT m1=min(m3-a1,u2)
		UPDATE cs
		SET mpositiontaking = 
                 CASE
                   WHEN mcs.mpositiontaking - cs.apositiontaking >
                          CASE
                            WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking
                            ELSE acs.autompositiontaking
                          END
                     THEN CASE
                            WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking
                            ELSE acs.autompositiontaking
                          END
                   ELSE mcs.mpositiontaking - cs.apositiontaking
                 END
		FROM (SELECT c.custid, c.recommend, mcs.*
			FROM #tblCust c
				CROSS JOIN @tmpMAg mcs 
			)mcs
		CROSS APPLY (SELECT TOP 1 isautompositiontaking, autompositiontaking
					FROM custsetting acs WITH(NOLOCK)
					WHERE  acs.custid = mcs.recommend
					   AND acs.sporttype = mcs.sporttype
					   AND acs.bettype = mcs.bettype
					)acs
		CROSS APPLY (SELECT TOP 1 isautompositiontaking,autompositiontaking,mpositiontaking,apositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = mcs.custid
					   AND cs.sporttype = mcs.sporttype
					   AND cs.bettype = mcs.bettype
					   AND (acs.isautompositiontaking = 1
							OR cs.isautompositiontaking = 1
						   )
					)cs
		
		UPDATE cs 
           SET mlivepositiontaking =
                 CASE
                   WHEN mcs.mlivepositiontaking - cs.alivepositiontaking >
                          CASE
                            WHEN cs.isautolivempositiontaking = 1 THEN cs.autolivempositiontaking
                            ELSE acs.autolivempositiontaking end
                     THEN CASE
                            WHEN cs.isautolivempositiontaking = 1 THEN cs.autolivempositiontaking
                            ELSE acs.autolivempositiontaking
                          END
                   ELSE mcs.mlivepositiontaking - cs.alivepositiontaking
                 END
		FROM (SELECT c.custid, c.recommend, mcs.*
			FROM #tblCust c
				CROSS JOIN @tmpMAg mcs 
			WHERE mcs.sporttype = 1
			AND mcs.bettype IN (1, 3, 7, 8)
			)mcs
		CROSS APPLY (SELECT TOP 1 autolivempositiontaking, isautolivempositiontaking
					FROM custsetting acs WITH(NOLOCK)
					WHERE  acs.custid = mcs.recommend
					   AND acs.sporttype = mcs.sporttype
					   AND acs.bettype = mcs.bettype
					)acs
		CROSS APPLY (SELECT TOP 1 isautolivempositiontaking,autolivempositiontaking,alivepositiontaking,mlivepositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = mcs.custid
					   AND cs.sporttype = mcs.sporttype
					   AND cs.bettype = mcs.bettype
					   AND (acs.isautolivempositiontaking = 1
							OR cs.isautolivempositiontaking = 1
						   )
					)cs
		
        --check master min/max
        --m1=n3-a1
		UPDATE cs 
           SET mpositiontaking = mco.minpositiontaking - cs.apositiontaking
		FROM (SELECT c.custid, mco.*
			FROM #tblCust c
				CROSS JOIN @tmpMAg mco 
			)mco		
		CROSS APPLY (SELECT TOP 1 mpositiontaking,apositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = mco.custid
					   AND cs.sporttype = mco.sporttype
					   AND cs.bettype = mco.bettype
					   AND cs.apositiontaking + cs.mpositiontaking < mco.minpositiontaking
				   )cs
		
        UPDATE cs 
           SET mlivepositiontaking = mco.minlivepositiontaking - cs.alivepositiontaking
		FROM (SELECT c.custid, mco.*
			FROM #tblCust c
				CROSS JOIN @tmpMAg mco 
			 WHERE mco.sporttype = 1
				AND mco.bettype IN (1, 3, 7, 8)	
			)mco		
		CROSS APPLY (SELECT TOP 1 alivepositiontaking,mlivepositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = mco.custid
					   AND cs.sporttype = mco.sporttype
					   AND cs.bettype = mco.bettype
					   AND cs.alivepositiontaking + cs.mlivepositiontaking < mco.minlivepositiontaking
				   )cs
		
        -- UPDATE m1,a1 when m1+a1>l3
        -- m1=min(m3,l3)-a1
		UPDATE cs
           SET @maxmapos =
                 CASE
                   WHEN mcs.mpositiontaking > mcs.maxpositiontaking THEN mcs.maxpositiontaking
                   ELSE mcs.mpositiontaking
                 END
             , @mpos =
                 CASE
                   WHEN @maxmapos - cs.apositiontaking < 0 THEN 0
                   ELSE @maxmapos-cs.apositiontaking
                 END
             , mpositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.apositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                   ELSE cs.apositiontaking
                 END
             , apositiontaking =
                 CASE
                   WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                   ELSE @apos
                 END
		FROM (SELECT c.custid, c.recommend, mcs.*
			FROM #tblCust c
				CROSS JOIN @tmpMAg mcs 
			)mcs
		CROSS APPLY (SELECT TOP 1 minpositiontaking
					FROM custoverride aco WITH(NOLOCK)
					WHERE  aco.custid = mcs.recommend
					   AND aco.sporttype = mcs.sporttype
					   AND aco.bettype = mcs.bettype
					)aco
		CROSS APPLY (SELECT TOP 1 apositiontaking,mpositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = mcs.custid
					   AND cs.sporttype = mcs.sporttype
					   AND cs.bettype = mcs.bettype
					   AND cs.apositiontaking + cs.mpositiontaking > mcs.maxpositiontaking
					)cs
		
		UPDATE cs 
           SET @maxmapos =
                 CASE
                   WHEN mcs.mlivepositiontaking > mcs.maxlivepositiontaking THEN mcs.maxlivepositiontaking
                   ELSE mcs.mlivepositiontaking
                 END
             , @mpos =
                 CASE
                   WHEN @maxmapos - cs.alivepositiontaking < 0 THEN 0
                   ELSE @maxmapos - cs.alivepositiontaking
                 END
             , mlivepositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.alivepositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                   ELSE cs.alivepositiontaking
                 END
             , alivepositiontaking =
                 CASE
                   WHEN @apos < aco.minlivepositiontaking THEN aco.minlivepositiontaking
                   ELSE @apos end
		FROM (SELECT c.custid, c.recommend, mcs.*
			FROM #tblCust c
				CROSS JOIN @tmpMAg mcs
			WHERE mcs.sporttype = 1
				AND mcs.bettype IN (1, 3, 7, 8)			
			)mcs
		CROSS APPLY (SELECT TOP 1 minlivepositiontaking
					FROM custoverride aco WITH(NOLOCK)
					WHERE  aco.custid = mcs.recommend
					   AND aco.sporttype = mcs.sporttype
					   AND aco.bettype = mcs.bettype
					)aco
		CROSS APPLY (SELECT TOP 1 alivepositiontaking,mlivepositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = mcs.custid
					   AND cs.sporttype = mcs.sporttype
					   AND cs.bettype = mcs.bettype
					   AND cs.alivepositiontaking + cs.mlivepositiontaking > mcs.maxlivepositiontaking
					)cs
		
        --recal autopos
        -- s1=min(s4-m1-a1,u)
        --lock esc
		UPDATE cs 
           SET spositiontaking =
                 CASE
                   WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking >
                          CASE
                            WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                            ELSE mcs.autopositiontaking
                          END
                     THEN CASE
                            WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                            ELSE mcs.autopositiontaking
                          END
                   ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
                 END
		FROM (SELECT c.custid, mcs.*
			FROM #tblCust c
				CROSS JOIN @tmpMAg mcs					
			)mcs
		CROSS APPLY (SELECT TOP 1 *
					FROM @tmpSAg scs
					WHERE  scs.sporttype = mcs.sporttype
					   AND scs.bettype = mcs.bettype
					)scs
		CROSS APPLY (SELECT TOP 1 isautopositiontaking,autopositiontaking,spositiontaking,mpositiontaking,apositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = mcs.custid
					   AND cs.sporttype = mcs.sporttype
					   AND cs.bettype = mcs.bettype
					   AND (cs.isautopositiontaking = 1
							OR mcs.isautopositiontaking = 1
						   )
					)cs
					
		UPDATE cs 
           SET slivepositiontaking =
                 CASE
                   WHEN scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking >
                          CASE
                            WHEN cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking end THEN (case when cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking end)
                            ELSE scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking end 
		FROM (SELECT c.custid, mcs.*
			FROM #tblCust c
				CROSS JOIN @tmpMAg mcs
			WHERE mcs.sporttype = 1
				AND mcs.bettype IN (1, 3, 7, 8)			
			)mcs
		CROSS APPLY (SELECT TOP 1 *
					FROM @tmpSAg scs
					WHERE  scs.sporttype = mcs.sporttype
					   AND scs.bettype = mcs.bettype
					)scs
		CROSS APPLY (SELECT TOP 1 isautolivepositiontaking,autolivepositiontaking,slivepositiontaking,mlivepositiontaking,alivepositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = mcs.custid
					   AND cs.sporttype = mcs.sporttype
					   AND cs.bettype = mcs.bettype
					   AND (cs.isautolivepositiontaking = 1
							OR mcs.isautolivepositiontaking = 1
						   )
					)cs
		
        --check super min/max when a1+m1+s1<n4
        -- s1=n4-m1-a1
		UPDATE cs
           SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
		FROM (SELECT c.custid, sco.*
			FROM #tblCust c
				CROSS JOIN @tmpSAg sco			
			)sco		
		CROSS APPLY (SELECT TOP 1 spositiontaking,mpositiontaking,apositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = sco.custid
					   AND cs.sporttype = sco.sporttype
					   AND cs.bettype = sco.bettype
					   AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
					)cs				
				
        UPDATE cs
           SET slivepositiontaking = sco.minlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking         
		FROM (SELECT c.custid, sco.*
			FROM #tblCust c
				CROSS JOIN @tmpSAg sco
			 WHERE sco.sporttype = 1
				AND sco.bettype IN (1, 3, 7, 8)			
			)sco		
		CROSS APPLY (SELECT TOP 1 slivepositiontaking,mlivepositiontaking,alivepositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = sco.custid
					   AND cs.sporttype = sco.sporttype
					   AND cs.bettype = sco.bettype
					   AND cs.alivepositiontaking + cs.mlivepositiontaking + cs.slivepositiontaking < sco.minlivepositiontaking
					)cs
	
        --UPDATE s1,m1,a1 in case s1+m1+a1>s4
        --s1=max(0,s4-m1-a1)
        --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
        --@maxmapos=min(m3,l3)
        --@mapos2=min(@mapos1,@maxmapos)
        --@mapos=max(@mapos2,n3)
        --m1=max(0,@mapos-a1)
        --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)	      
		UPDATE cs 
           SET @spos =
                 CASE
                   WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0
                   ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
                 END
             , spositiontaking = @spos
             , @mapos1 =
                 CASE
                   WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos
                   ELSE cs.mpositiontaking + cs.apositiontaking
                 END
             , @maxmapos =
                 CASE
                   WHEN mcs.mpositiontaking > mcs.maxpositiontaking THEN mcs.maxpositiontaking
                   ELSE mcs.mpositiontaking
                 END
             , @mapos2 =
                 CASE
                   WHEN @mapos1 > @maxmapos THEN @maxmapos
                   ELSE @mapos1
                 END
             , @mapos =
                 CASE
                   WHEN @mapos2 < mcs.minpositiontaking THEN mcs.minpositiontaking
                   ELSE @mapos2
                 END
             , @mpos =
                 CASE
                   WHEN @mapos - cs.apositiontaking < 0 THEN 0
                   ELSE @mapos - cs.apositiontaking
                 END
             , mpositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos
                   ELSE cs.apositiontaking
                 END
             , apositiontaking =
                 CASE
                   WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                   ELSE @apos
                 END
		FROM (SELECT c.custid, c.recommend, mcs.*
			FROM #tblCust c
				CROSS JOIN @tmpMAg mcs					
			)mcs
		CROSS APPLY (SELECT TOP 1 *
					FROM @tmpSAg scs
					WHERE  scs.sporttype = mcs.sporttype
					   AND scs.bettype = mcs.bettype
					)scs
		CROSS APPLY (SELECT TOP 1 minpositiontaking
					FROM custoverride as aco WITH(NOLOCK) 
					WHERE aco.custid = mcs.recommend
					   AND aco.sporttype = mcs.sporttype
					   AND aco.bettype = mcs.bettype
					)aco			
		CROSS APPLY (SELECT TOP 1 spositiontaking,apositiontaking,mpositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = mcs.custid
					   AND cs.sporttype = mcs.sporttype
					   AND cs.bettype = mcs.bettype
					   AND cs.spositiontaking + cs.apositiontaking + cs.mpositiontaking > scs.spositiontaking
					)cs
			
		UPDATE cs 
           SET @spos =
                 CASE
                   WHEN scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking < 0 THEN 0
                   ELSE scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
                 END
             , slivepositiontaking = @spos
             , @mapos1 =
                 CASE
                   WHEN @spos + cs.mlivepositiontaking + cs.alivepositiontaking > scs.slivepositiontaking THEN scs.slivepositiontaking - @spos
                   ELSE cs.mlivepositiontaking + cs.alivepositiontaking
                 END
             , @maxmapos =
                 CASE
                   WHEN mcs.mlivepositiontaking > mcs.maxlivepositiontaking THEN mcs.maxlivepositiontaking
                   ELSE mcs.mlivepositiontaking
                 END
             , @mapos2 =
                 CASE
                   WHEN @mapos1 > @maxmapos THEN @maxmapos
                   ELSE @mapos1
                 END
             , @mapos =
                 CASE
                   WHEN @mapos2 < mcs.minlivepositiontaking THEN mcs.minlivepositiontaking
                   ELSE @mapos2
                 END
             , @mpos =
                 CASE
                   WHEN @mapos - cs.alivepositiontaking < 0 THEN 0
                   ELSE @mapos - cs.alivepositiontaking
                 END
             , mlivepositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.alivepositiontaking + @mpos > @mapos THEN @mapos - @mpos
                   ELSE cs.alivepositiontaking
                 END
             , alivepositiontaking =
                 CASE
                   WHEN @apos < aco.minlivepositiontaking THEN aco.minlivepositiontaking
                   ELSE @apos
                 END
		FROM (SELECT c.custid, c.recommend, mcs.*
			FROM #tblCust c
				CROSS JOIN @tmpMAg mcs	
			WHERE mcs.sporttype = 1
				AND mcs.bettype IN (1, 3, 7, 8)			
			)mcs
		CROSS APPLY (SELECT TOP 1 *
					FROM @tmpSAg scs
					WHERE  scs.sporttype = mcs.sporttype
					   AND scs.bettype = mcs.bettype
					)scs
		CROSS APPLY (SELECT TOP 1 minlivepositiontaking
					FROM custoverride as aco WITH(NOLOCK) 
					WHERE aco.custid = mcs.recommend
					   AND aco.sporttype = mcs.sporttype
					   AND aco.bettype = mcs.bettype
					)aco			
		CROSS APPLY (SELECT TOP 1 slivepositiontaking,mlivepositiontaking,alivepositiontaking
					FROM custsetting cs WITH(UPDLOCK,ROWLOCK)
					WHERE  cs.custid = mcs.custid
					   AND cs.sporttype = mcs.sporttype
					   AND cs.bettype = mcs.bettype
					   AND cs.slivepositiontaking + cs.alivepositiontaking + cs.mlivepositiontaking > scs.slivepositiontaking
					)cs	
    END
    ELSE IF @roleid = 2
    BEGIN                
        --Check min max a1: n2<=a1<=l2 => modify a1
        --Nonlive(min)
		
		SELECT @mrecommend = mrecommend, @srecommend = srecommend 
		FROM custinfo ci (NOLOCK)
		WHERE custid = @recommend
		
		INSERT INTO #tblCust(custid)
		SELECT custid 		
		FROM custinfo ci (NOLOCK)
		WHERE recommend = @recommend
			AND roleid = 1

		INSERT INTO @tmpAg(sporttype,bettype, autompositiontaking, autolivempositiontaking,
			isautompositiontaking, isautolivempositiontaking, minpositiontaking, minlivepositiontaking,
			maxpositiontaking, maxlivepositiontaking)
		SELECT aco.sporttype, aco.bettype, autompositiontaking, autolivempositiontaking,
			isautompositiontaking, isautolivempositiontaking, minpositiontaking, minlivepositiontaking,
			maxpositiontaking, maxlivepositiontaking
		FROM custoverride aco WITH(NOLOCK)
			INNER JOIN custsetting acs WITH(NOLOCK) ON aco.custid = acs.custid
													AND aco.sporttype = acs.sporttype
													AND aco.bettype = acs.bettype
		WHERE aco.custid = @recommend
				
		INSERT INTO @tmpMAg(sporttype,bettype, mpositiontaking, mlivepositiontaking, autopositiontaking, autolivepositiontaking, 
			isautopositiontaking, isautolivepositiontaking,  minpositiontaking, minlivepositiontaking)
		SELECT mcs.sporttype, mcs.bettype, mpositiontaking, mlivepositiontaking, autopositiontaking, autolivepositiontaking, 
			isautopositiontaking, isautolivepositiontaking,  minpositiontaking, minlivepositiontaking
		FROM custsetting mcs WITH(NOLOCK)
			INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = mcs.custid
													AND mco.sporttype = mcs.sporttype
													AND mco.bettype = mcs.bettype
		WHERE mco.custid = @mrecommend
		
		INSERT INTO @tmpSAg(sporttype,bettype, spositiontaking, slivepositiontaking,minpositiontaking,minlivepositiontaking,
				maxpositiontaking, maxlivepositiontaking)
		SELECT scs.sporttype,scs.bettype, spositiontaking, slivepositiontaking ,minpositiontaking,minlivepositiontaking,
				maxpositiontaking, maxlivepositiontaking
		FROM custsetting scs WITH(NOLOCK)
			INNER JOIN custoverride sco WITH(NOLOCK) ON scs.custid = sco.custid
													AND sco.sporttype = scs.sporttype
													AND sco.bettype = scs.bettype
		WHERE scs.custid = @srecommend
		
		UPDATE cs 
           SET apositiontaking = aco.minpositiontaking
		FROM( SELECT mb.custid, aco.*
			FROM #tblCust mb 
				CROSS JOIN @tmpAg aco			
			)aco
			CROSS APPLY(SELECT TOP 1 apositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE aco.custid = cs.custid
							AND cs.sporttype = aco.sporttype
							AND cs.bettype = aco.bettype
							AND cs.apositiontaking < aco.minpositiontaking 
						)cs
		
		UPDATE cs 
           SET alivepositiontaking = aco.minlivepositiontaking
		FROM ( SELECT mb.custid, aco.*
			FROM #tblCust mb 
				CROSS JOIN @tmpAg aco
			WHERE aco.sporttype=1 
				AND aco.bettype in (1,3,7,8)
			)aco
			CROSS APPLY(SELECT TOP 1 alivepositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE aco.custid = cs.custid
							AND cs.sporttype = aco.sporttype
							AND cs.bettype = aco.bettype
							AND cs.alivepositiontaking < aco.minlivepositiontaking 
						)cs

		UPDATE cs 
           SET apositiontaking = aco.maxpositiontaking
		FROM( SELECT mb.custid, aco.*
			FROM #tblCust mb 
				CROSS JOIN @tmpAg aco			
			)aco
			CROSS APPLY(SELECT TOP 1 apositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE aco.custid = cs.custid
							AND cs.sporttype = aco.sporttype
							AND cs.bettype = aco.bettype
							AND cs.apositiontaking > aco.maxpositiontaking  
						)cs

		UPDATE cs 
           SET alivepositiontaking = aco.maxlivepositiontaking		
		FROM( SELECT mb.custid, aco.*
			FROM #tblCust mb
				CROSS JOIN @tmpAg aco
			WHERE aco.sporttype=1 
				AND aco.bettype in (1,3,7,8)
			)aco
			CROSS APPLY(SELECT TOP 1 alivepositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE aco.custid = cs.custid
							AND cs.sporttype = aco.sporttype
							AND cs.bettype = aco.bettype
							AND cs.alivepositiontaking > aco.maxlivepositiontaking   
						)cs
					
        --Check m1+a1: m1+a1>m3 => modify m1
        --SET m1=m3-a1
        --Nonlive
		UPDATE cs 
           SET mpositiontaking = macs.mpositiontaking - cs.apositiontaking		
		FROM( SELECT mb.custid, macs.*
			FROM #tblCust mb 
				CROSS JOIN @tmpMAg macs						
			)macs
			CROSS APPLY(SELECT TOP 1 mpositiontaking,apositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE macs.custid = cs.custid
							AND cs.sporttype = macs.sporttype
							AND cs.bettype = macs.bettype
							AND cs.apositiontaking + cs.mpositiontaking > macs.mpositiontaking  
						)cs
					  
		UPDATE cs 
           SET mlivepositiontaking = macs.mlivepositiontaking - cs.alivepositiontaking		
		FROM( SELECT mb.custid, macs.*
			FROM #tblCust mb
				CROSS JOIN @tmpMAg macs
			WHERE  macs.sporttype=1 
				AND macs.bettype in (1,3,7,8)		
			)macs
			CROSS APPLY(SELECT TOP 1 mlivepositiontaking,alivepositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE macs.custid = cs.custid
							AND cs.sporttype = macs.sporttype
							AND cs.bettype = macs.bettype
							AND cs.alivepositiontaking + cs.mlivepositiontaking > macs.mlivepositiontaking
						)cs
			
        --Recal u2
        --Recal AUTO MPT m1=min(m3-a1,u2)		
        --Nonlive
		UPDATE cs 
           SET  mpositiontaking = 
                case when mcs.mpositiontaking - cs.apositiontaking >
                 CASE
                   WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking
                            ELSE acs.autompositiontaking end
                    then
                 CASE
                   WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking
                            ELSE acs.autompositiontaking end
                else  mcs.mpositiontaking - cs.apositiontaking end		
		FROM( SELECT mb.custid, mcs.*
			FROM #tblCust mb 
				CROSS JOIN @tmpMAg mcs							
			)mcs			
			CROSS APPLY(SELECT TOP 1 *
						FROM @tmpAg acs
						WHERE acs.sporttype = mcs.sporttype
							AND acs.bettype = mcs.bettype							
						)acs
			CROSS APPLY(SELECT TOP 1 isautompositiontaking,autompositiontaking,mpositiontaking,apositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE cs.custid = mcs.custid 
							AND cs.sporttype = mcs.sporttype
							AND cs.bettype = mcs.bettype
							AND (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1)
						)cs			
		
        --Live 
		UPDATE cs 
           SET  mlivepositiontaking =
                case when mcs.mlivepositiontaking - cs.alivepositiontaking >
                 CASE
                   WHEN cs.isautolivempositiontaking = 1 THEN cs.autolivempositiontaking
                            ELSE acs.autolivempositiontaking end
                    then
                 CASE
                   WHEN cs.isautolivempositiontaking = 1 THEN cs.autolivempositiontaking
                            ELSE acs.autolivempositiontaking end
                else  mcs.mlivepositiontaking - cs.alivepositiontaking end		
		FROM( SELECT mb.custid, mcs.*
			FROM #tblCust mb
				CROSS JOIN @tmpMAg mcs
			WHERE mcs.sporttype=1 
				AND mcs.bettype in (1,3,7,8)		
			)mcs			
			CROSS APPLY(SELECT TOP 1 *
						FROM @tmpAg acs
						WHERE acs.sporttype = mcs.sporttype
							AND acs.bettype = mcs.bettype							
						)acs
			CROSS APPLY(SELECT TOP 1 isautolivempositiontaking,autolivempositiontaking,mlivepositiontaking,alivepositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE cs.custid = mcs.custid 
							AND cs.sporttype = mcs.sporttype
							AND cs.bettype = mcs.bettype
							AND (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1)
						)cs	
	
        --Check min max n3<=m1+a1<=l3 => modify m1
        --Nonlive(min)
		UPDATE cs 
           SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
		FROM( SELECT mb.custid, mco.*
			FROM #tblCust mb 
				CROSS JOIN @tmpMAg mco					
			)mco					
			CROSS APPLY(SELECT TOP 1 mpositiontaking,apositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE cs.custid = mco.custid 
							AND cs.sporttype = mco.sporttype
							AND cs.bettype = mco.bettype
							AND cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking
						)cs
		
        --Live(min)
		UPDATE cs 
           SET cs.mlivepositiontaking = mco.minlivepositiontaking - cs.alivepositiontaking
		FROM( SELECT mb.custid, mco.*
			FROM #tblCust mb
				CROSS JOIN @tmpMAg mco
			WHERE mco.sporttype=1 
				AND mco.bettype in (1,3,7,8)	
			)mco					
			CROSS APPLY(SELECT TOP 1 mlivepositiontaking,alivepositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE cs.custid = mco.custid 
							AND cs.sporttype = mco.sporttype
							AND cs.bettype = mco.bettype
							AND cs.mlivepositiontaking + cs.alivepositiontaking < mco.minlivepositiontaking
						)cs
				 
        --Nonlive(max)
		UPDATE cs 
           SET cs.mpositiontaking = mco.maxpositiontaking - cs.apositiontaking
		FROM( SELECT mb.custid, mco.*
			FROM #tblCust mb
				CROSS JOIN @tmpMAg mco								
			)mco					
			CROSS APPLY(SELECT TOP 1 mpositiontaking,apositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE cs.custid = mco.custid 
							AND cs.sporttype = mco.sporttype
							AND cs.bettype = mco.bettype
							AND cs.mpositiontaking + cs.apositiontaking > mco.maxpositiontaking
						)cs

        --Live(max)
		UPDATE cs 
           SET cs.mlivepositiontaking = mco.maxlivepositiontaking - cs.alivepositiontaking
		FROM( SELECT mb.custid, mco.*
			FROM #tblCust mb
				CROSS JOIN @tmpMAg mco
			WHERE  mco.sporttype=1 
				AND mco.bettype in (1,3,7,8)	
			)mco					
			CROSS APPLY(SELECT TOP 1 mlivepositiontaking,alivepositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE cs.custid = mco.custid 
							AND cs.sporttype = mco.sporttype
							AND cs.bettype = mco.bettype
							AND cs.mlivepositiontaking + cs.alivepositiontaking > mco.maxlivepositiontaking
						)cs
			
        --Recal u3,u1
        -- s1=min(s4-m1-a1,u)
        --Nonlive
		UPDATE cs 
           SET spositiontaking =
                 CASE
                   WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking >
                          CASE
                            WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                            ELSE mcs.autopositiontaking end THEN (case when cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                            ELSE mcs.autopositiontaking end)
                            ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking end     	
		FROM( SELECT mb.custid, mcs.*
			FROM #tblCust mb
				CROSS JOIN @tmpMAg mcs							
			)mcs			
			CROSS APPLY(SELECT TOP 1 *
						FROM @tmpSAg scs
						WHERE scs.sporttype = mcs.sporttype
							AND scs.bettype = mcs.bettype							
						)scs			
			CROSS APPLY(SELECT TOP 1 isautopositiontaking, autopositiontaking,spositiontaking,mpositiontaking,apositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE cs.custid = mcs.custid 
							AND cs.sporttype = mcs.sporttype
							AND cs.bettype = mcs.bettype
							AND (cs.isautopositiontaking = 1 or mcs.isautopositiontaking = 1)
						)cs	
				
        --Live
		UPDATE cs 
          SET slivepositiontaking =
                 CASE
                   WHEN scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking >
                          CASE
                            WHEN cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking end THEN (case when cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking end)
                            ELSE scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking end          
		FROM( SELECT mb.custid, mcs.*
			FROM #tblCust mb
				CROSS JOIN @tmpMAg mcs	
			WHERE mcs.sporttype=1 
				AND mcs.bettype in (1,3,7,8) 		
			)mcs			
			CROSS APPLY(SELECT TOP 1 *
						FROM @tmpSAg scs
						WHERE scs.sporttype = mcs.sporttype
							AND scs.bettype = mcs.bettype							
						)scs			
			CROSS APPLY(SELECT TOP 1 isautolivepositiontaking,autolivepositiontaking,slivepositiontaking,mlivepositiontaking,alivepositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE cs.custid = mcs.custid 
							AND cs.sporttype = mcs.sporttype
							AND cs.bettype = mcs.bettype
							AND (cs.isautolivepositiontaking = 1 or mcs.isautolivepositiontaking = 1)
						)cs	
		
		
        --check super min/max when a1+m1+s1<n4
        -- s1=n4-m1-a1
        --Nonlive(min)
		UPDATE cs
		SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking		
		FROM( SELECT mb.custid, sco.*
			FROM #tblCust mb 
				CROSS JOIN @tmpSAg sco						
			)sco									
			CROSS APPLY(SELECT TOP 1 spositiontaking,mpositiontaking,apositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE cs.custid = sco.custid 
							AND cs.sporttype = sco.sporttype
							AND cs.bettype = sco.bettype
							AND cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
						)cs	
		
        --Live(min)
		UPDATE cs
		SET slivepositiontaking = sco.minlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
		FROM( SELECT mb.custid, sco.*
			FROM #tblCust mb
				CROSS JOIN @tmpSAg sco
			WHERE	
				 sco.sporttype=1 
				AND sco.bettype in (1,3,7,8)	
			)sco									
			CROSS APPLY(SELECT TOP 1 slivepositiontaking,mlivepositiontaking,alivepositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE cs.custid = sco.custid 
							AND cs.sporttype = sco.sporttype
							AND cs.bettype = sco.bettype
							AND cs.alivepositiontaking+cs.mlivepositiontaking+cs.slivepositiontaking<sco.minlivepositiontaking
						)cs	
		
		--Nonlive(max)
		UPDATE cs
		SET spositiontaking = sco.maxpositiontaking - cs.mpositiontaking - cs.apositiontaking
		FROM( SELECT mb.custid, sco.*
			FROM #tblCust mb
				CROSS JOIN @tmpSAg sco							
			)sco									
			CROSS APPLY(SELECT TOP 1 spositiontaking,mpositiontaking,apositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE cs.custid = sco.custid 
							AND cs.sporttype = sco.sporttype
							AND cs.bettype = sco.bettype
							AND cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking>sco.maxpositiontaking
						)cs	
				
        --Live(max)
		UPDATE cs
		SET slivepositiontaking = sco.maxlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
		FROM( SELECT mb.custid, sco.*
			FROM #tblCust mb
				CROSS JOIN @tmpSAg sco
			WHERE
				 sco.sporttype=1 
				AND sco.bettype in (1,3,7,8)	
			)sco									
			CROSS APPLY(SELECT TOP 1 slivepositiontaking,mlivepositiontaking,alivepositiontaking
						FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
						WHERE cs.custid = sco.custid 
							AND cs.sporttype = sco.sporttype
							AND cs.bettype = sco.bettype
							AND cs.alivepositiontaking+cs.mlivepositiontaking+cs.slivepositiontaking>sco.maxlivepositiontaking
						)cs	
    END 
	
	DROP TABLE #tblCust	
END
GO 
