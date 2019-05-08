/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_07] 
    @srecommend INT= 0,
    @mrecommend iNT = 0,
    @recommend INT = 0,
    @roleid INT,
    @mode  VARCHAR(50) = '',
    @updautomaster bit = 1,
    @updautosuper bit = 1,
    @sporttype INT = 0,
    @bettype INT = 0 
AS
/*
    Created: Johnson
    Date: 2013-10-30
    Task: Apply execrep when corrects pt on members
    DB: DBCUST/CustDB
    Original versions: Acc_CustomerUpdSuper_AutoPositiontaking
                Acc_CustomerUpdMaster_MaxPositiontaking
                Acc_CustomerUpdAgent_MaxPositiontaking                    
                Acc_CustomerUpdMasterVS_MaxPositiontaking
                Acc_CustomerUpdAgentVS_MaxPositiontaking                                        
                Acc_CustomerUpdSuperLiveCS_Positiontaking    
                Acc_CustomerUpdMasterLiveCS_MaxPositiontaking    
                Acc_CustomerUpdAgentLiveCS_MaxPositionTaking
                Acc_CustomerUpdSuperHR_Positiontaking
                Acc_CustomerUpdMasterHR_MaxPositiontaking
                Acc_CustomerUpdAgentHR_MaxPositiontaking                    
    Revision:
        - 20131104@Johnson: Add virtual sports, live casino, racing
        - 20131203@Johnson: Update virtual-sport for agent by @sporttype not hard code in sp
        - 20140314@Elodie: Add Keno product [Redmine:#13326]
        - 20140818@Logan: Exclude disabled members while updating Super, Master setting [Redmine:#19631]
		- 20150422@Elodie: Add Gold Deluxe product [Redmine:#34486]
	   - 20150610@Daniel: 
	      + Improve medthod check table existing in subscribers	
	      + Separate custDB to new server DBCUST  		
	   - 20150917@Johnson: check constraint n4 when update s4 [Redmine:#43808]     
	   - 20180125@Winnie: Hide inactive products [RedmineID: #86086]             
	   - 20190313@Johnson: enhance perf  [redmine:#109979]
    Parameter's Explanation:
*/ 
BEGIN
    SET NOCOUNT ON
    
	if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	     AND dbo.f_CheckRepTable('CustOverrideGame') = 1 
	     AND dbo.f_CheckRepTable('CustSettingGame') = 1 
	     AND dbo.f_CheckRepTable('CustSetting3rd') = 1 
	     AND dbo.f_CheckRepTable('CustOverride3rd') = 1 
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
        IF @mode = 'number'
        BEGIN
			INSERT INTO #tblCust(custid,mrecommend)
			SELECT custid,mrecommend
			FROM custinfo c WITH(NOLOCK) 
			WHERE c.srecommend = @srecommend
			   AND c.roleid = 1
			   AND c.Enabled = 1
		   
		   	INSERT INTO @tmpSAg(sporttype,bettype,spositiontaking,slivepositiontaking,minpositiontaking,minlivepositiontaking)  
			SELECT scs.sporttype, scs.bettype,spositiontaking,slivepositiontaking,minpositiontaking,minlivepositiontaking
			FROM custsetting3rd scs WITH(NOLOCK)
				INNER JOIN CustOverride3rd sco WITH(NOLOCK) ON scs.custid = sco.custid
														AND scs.sporttype = sco.sporttype
														AND scs.bettype = sco.bettype
			WHERE scs.custid = @srecommend
				AND scs.sporttype = 161
				
            --u = (i3 or i1)?(u3 or u1)
            --s1 = min(s4-m1-a1, u)        
            --v161
			UPDATE cs3 
                SET spositiontaking = case when scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking >
                                        (case when cs3.isautopositiontaking=1 then cs3.autopositiontaking else mcs3.autopositiontaking end) then (case when cs3.isautopositiontaking=1 then cs3.autopositiontaking else mcs3.autopositiontaking end) else scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking end 
            FROM (SELECT c.custid, c.mrecommend, scs3.*
				FROM #tblCust c
					CROSS JOIN @tmpSAg scs3 
				)scs3
			CROSS APPLY (SELECT TOP 1 isautopositiontaking,autopositiontaking
						FROM custsetting3rd mcs3 WITH(NOLOCK)
						WHERE  mcs3.custid = scs3.mrecommend
						   AND mcs3.sporttype = scs3.sporttype
						   AND mcs3.bettype = scs3.bettype
						)mcs3
			CROSS APPLY (SELECT TOP 1 spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking,autopositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = scs3.custid
						   AND cs3.sporttype = scs3.sporttype
						   AND cs3.bettype = scs3.bettype
						   AND (cs3.isautopositiontaking = 1
								OR mcs3.isautopositiontaking = 1)
						)cs3
			
			--check super min
            --s1=max(n4-m1-a1,s1)
			UPDATE cs
			   SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
			FROM (SELECT c.custid, sco.*
				FROM #tblCust c
					CROSS JOIN @tmpSAg sco 
			)sco		
			CROSS APPLY (SELECT TOP 1 spositiontaking, mpositiontaking, apositiontaking
						FROM custsetting3rd cs WITH(UPDLOCK,ROWLOCK)
						WHERE  cs.custid = sco.custid
						   AND cs.sporttype = sco.sporttype
						   AND cs.bettype = sco.bettype
						   AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
						)cs
			
            --v161 
			UPDATE cs3 
                SET slivepositiontaking = case when scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking >
                                        (case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) then (case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) else scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking end 
            FROM (SELECT c.custid, c.mrecommend, scs3.*
				FROM #tblCust c
					CROSS JOIN @tmpSAg scs3 
				)scs3
			CROSS APPLY (SELECT TOP 1 autolivepositiontaking,isautolivepositiontaking
						FROM custsetting3rd mcs3 WITH(NOLOCK)
						WHERE  mcs3.custid = scs3.mrecommend
						   AND mcs3.sporttype = scs3.sporttype
						   AND mcs3.bettype = scs3.bettype
						)mcs3
			CROSS APPLY (SELECT TOP 1 slivepositiontaking, mlivepositiontaking, alivepositiontaking, autolivepositiontaking, isautolivepositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = scs3.custid
						   AND cs3.sporttype = scs3.sporttype
						   AND cs3.bettype = scs3.bettype
						   AND (cs3.isautolivepositiontaking = 1
								OR mcs3.isautolivepositiontaking = 1)
						)cs3
			
			UPDATE cs3
			   SET slivepositiontaking = sco.minlivepositiontaking - cs3.mlivepositiontaking - cs3.alivepositiontaking
			FROM (SELECT c.custid, c.mrecommend, sco.*
				FROM #tblCust c
					CROSS JOIN @tmpSAg sco 
				)sco			
			CROSS APPLY (SELECT TOP 1 slivepositiontaking, mlivepositiontaking, alivepositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = sco.custid
						   AND cs3.sporttype = sco.sporttype
						   AND cs3.bettype = sco.bettype
						   AND cs3.alivepositiontaking + cs3.mlivepositiontaking + cs3.slivepositiontaking < sco.minlivepositiontaking
						)cs3    
        END       
        ELSE IF @mode = 'Keno' OR @mode = 'GoldDeluxe'
        BEGIN       
			INSERT INTO #tblCust(custid,mrecommend)
			SELECT custid,mrecommend
			FROM custinfo c WITH(NOLOCK) 
			WHERE c.srecommend = @srecommend
			   AND c.roleid = 1
			   AND c.Enabled = 1
		   
		   	INSERT INTO @tmpSAg(sporttype,bettype,spositiontaking,minpositiontaking)  
			SELECT scs.sporttype, scs.bettype,spositiontaking,minpositiontaking
			FROM CustSettingGame scs WITH(NOLOCK)
				INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON scs.custid = sco.custid
														AND scs.sporttype = sco.sporttype
														AND scs.bettype = sco.bettype
			WHERE scs.custid = @srecommend
				AND scs.sporttype=@sporttype 
				AND scs.bettype=@bettype 
				
            --u = (i3 or i1)?(u3 or u1)
            --s1 = min(s4-m1-a1, u)
			UPDATE cs 
            SET spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking >
                                         CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END THEN
                                        (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) 
                                    ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking 
                                END  
			FROM (SELECT c.custid, c.mrecommend, scs.*
				FROM #tblCust c
					CROSS JOIN @tmpSAg scs 
				)scs
			CROSS APPLY (SELECT TOP 1 autopositiontaking,isautopositiontaking
						FROM CustSettingGame mcs WITH(NOLOCK)
						WHERE  mcs.custid = scs.mrecommend
						   AND mcs.sporttype = scs.sporttype
						   AND mcs.bettype = scs.bettype
						)mcs
			CROSS APPLY (SELECT TOP 1 spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking,autopositiontaking
						FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
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
						FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
						WHERE  cs.custid = sco.custid
						   AND cs.sporttype = sco.sporttype
						   AND cs.bettype = sco.bettype
						   AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
						)cs
        END        
    END
    ELSE IF @roleid = 3
    BEGIN
        declare @mpos smallmoney
                ,@apos smallmoney
                ,@spos smallmoney
                ,@mapos1 smallmoney
                ,@mapos2 smallmoney
                ,@mapos smallmoney
                ,@maxmapos smallmoney

        IF @mode = 'number'
        BEGIN
			INSERT INTO #tblCust(custid,recommend)
			SELECT custid, recommend 
			FROM custinfo c WITH(NOLOCK)
			WHERE mrecommend = @mrecommend
			   AND c.roleid = 1
			   AND c.Enabled = 1
			
			INSERT INTO @tmpSAg(sporttype,bettype,spositiontaking,slivepositiontaking,minpositiontaking,minlivepositiontaking)
			SELECT scs.sporttype,scs.bettype,spositiontaking,slivepositiontaking,minpositiontaking,minlivepositiontaking
			FROM custsetting3rd scs WITH(NOLOCK)
				INNER JOIN custoverride3rd sco WITH(NOLOCK) ON scs.custid= sco.custid
														AND scs.sporttype = sco.sporttype
														AND scs.bettype = sco.bettype
			WHERE scs.custid = @srecommend
				AND scs.sporttype = 161
			
			INSERT INTO @tmpMAg(sporttype, bettype, mpositiontaking, mlivepositiontaking, autopositiontaking, autolivepositiontaking, 
				isautopositiontaking, isautolivepositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
			SELECT mcs.sporttype,mcs.bettype, mpositiontaking, mlivepositiontaking, autopositiontaking, autolivepositiontaking, 
				isautopositiontaking, isautolivepositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking
			FROM custsetting3rd mcs WITH(NOLOCK)
				INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mcs.custid= mco.custid
														AND mcs.sporttype = mco.sporttype
														AND mcs.bettype = mco.bettype
			WHERE mcs.custid = @mrecommend
				AND mcs.sporttype = 161
				
            --Update all agent and member accounts
            --Recal AUTO MPT m1=min(m3-a1,u2)
			UPDATE cs3 
                set mpositiontaking = case when mcs3.mpositiontaking-cs3.apositiontaking > case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
                                           then case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
                                            else mcs3.mpositiontaking-cs3.apositiontaking end
            FROM (SELECT c.custid, c.recommend, mcs3.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mcs3 
				WHERE bettype in (81,83,86,88)	
				)mcs3
			CROSS APPLY (SELECT TOP 1 isautompositiontaking, autompositiontaking
						FROM custsetting3rd acs3 WITH(NOLOCK)
						WHERE  acs3.custid = mcs3.recommend
						   AND acs3.sporttype = mcs3.sporttype
						   AND acs3.bettype = mcs3.bettype
						)acs3
			CROSS APPLY (SELECT TOP 1 isautompositiontaking,autompositiontaking,mpositiontaking,apositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = mcs3.custid
						   AND cs3.sporttype = mcs3.sporttype
						   AND cs3.bettype = mcs3.bettype
						   AND (acs3.isautompositiontaking = 1
								OR cs3.isautompositiontaking = 1
							   )
						)cs3
			
            UPDATE cs3 
				set mlivepositiontaking = case when mcs3.mlivepositiontaking-cs3.alivepositiontaking > case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
								then case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
							else mcs3.mlivepositiontaking-cs3.alivepositiontaking end
            FROM (SELECT c.custid, c.recommend, mcs3.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mcs3 
				WHERE bettype in (85,86,87,89,90)
				)mcs3
			CROSS APPLY (SELECT TOP 1 autolivempositiontaking, isautolivempositiontaking
						FROM custsetting3rd acs3 WITH(NOLOCK)
						WHERE  acs3.custid = mcs3.recommend
						   AND acs3.sporttype = mcs3.sporttype
						   AND acs3.bettype = mcs3.bettype
						)acs3
			CROSS APPLY (SELECT TOP 1 isautolivempositiontaking,autolivempositiontaking,alivepositiontaking,mlivepositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = mcs3.custid
						   AND cs3.sporttype = mcs3.sporttype
						   AND cs3.bettype = mcs3.bettype
						   AND (acs3.isautolivempositiontaking = 1 or cs3.isautolivempositiontaking = 1)
						)cs3
						
            --check master min/max
            --m1=n3-a1
			UPDATE cs3 
				SET mpositiontaking = mco3.minpositiontaking - cs3.apositiontaking
			FROM (SELECT c.custid, mco3.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mco3 
				WHERE bettype in (81,83,86,88)	
				)mco3		
			CROSS APPLY (SELECT TOP 1 mpositiontaking,apositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = mco3.custid
						   AND cs3.sporttype = mco3.sporttype
						   AND cs3.bettype = mco3.bettype
						   AND cs3.apositiontaking + cs3.mpositiontaking < mco3.minpositiontaking
					   )cs3
		
			UPDATE cs3 
				SET mlivepositiontaking = mco3.minlivepositiontaking-cs3.alivepositiontaking
			FROM (SELECT c.custid, mco3.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mco3 
				WHERE bettype in (85,86,87,89,90)	
				)mco3		
			CROSS APPLY (SELECT TOP 1 alivepositiontaking,mlivepositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = mco3.custid
						   AND cs3.sporttype = mco3.sporttype
						   AND cs3.bettype = mco3.bettype
						   AND cs3.alivepositiontaking+cs3.mlivepositiontaking<mco3.minlivepositiontaking
					   )cs3
						
            -- Update m1,a1 when m1+a1>l3
            -- m1=min(m3,l3)-a1   
			UPDATE cs3 
            SET @maxmapos = case when mcs3.mpositiontaking > mcs3.maxpositiontaking then mcs3.maxpositiontaking else mcs3.mpositiontaking end,
                @mpos = case when @maxmapos-cs3.apositiontaking < 0 then 0 else @maxmapos-cs3.apositiontaking end,
                mpositiontaking = @mpos,
                @apos = case when cs3.apositiontaking + @mpos > @maxmapos then @maxmapos-@mpos else cs3.apositiontaking end,
                apositiontaking = case when @apos<aco3.minpositiontaking then aco3.minpositiontaking else @apos end
            FROM (SELECT c.custid, c.recommend, mcs3.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mcs3 
				WHERE bettype in (81,83,86,88)
				)mcs3
			CROSS APPLY (SELECT TOP 1 minpositiontaking
						FROM custoverride3rd aco3 WITH(NOLOCK)
						WHERE  aco3.custid = mcs3.recommend
						   AND aco3.sporttype = mcs3.sporttype
						   AND aco3.bettype = mcs3.bettype
						)aco3
			CROSS APPLY (SELECT TOP 1 apositiontaking,mpositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = mcs3.custid
						   AND cs3.sporttype = mcs3.sporttype
						   AND cs3.bettype = mcs3.bettype
						   AND cs3.apositiontaking + cs3.mpositiontaking > mcs3.maxpositiontaking
						)cs3
			
			UPDATE cs3 
            SET @maxmapos = case when mcs3.mlivepositiontaking > mcs3.maxlivepositiontaking then mcs3.maxlivepositiontaking else mcs3.mlivepositiontaking end,
                @mpos = case when @maxmapos-cs3.alivepositiontaking < 0 then 0 else @maxmapos-cs3.alivepositiontaking end,
                mlivepositiontaking = @mpos,
                @apos = case when cs3.alivepositiontaking + @mpos > @maxmapos then @maxmapos - @mpos else cs3.alivepositiontaking end,
                alivepositiontaking = case when @apos < aco3.minlivepositiontaking then aco3.minlivepositiontaking else @apos end
            FROM (SELECT c.custid, c.recommend, mcs3.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mcs3 
				WHERE bettype in (85,86,87,89,90)
				)mcs3
			CROSS APPLY (SELECT TOP 1 minlivepositiontaking
						FROM custoverride3rd aco3 WITH(NOLOCK)
						WHERE  aco3.custid = mcs3.recommend
						   AND aco3.sporttype = mcs3.sporttype
						   AND aco3.bettype = mcs3.bettype
						)aco3
			CROSS APPLY (SELECT TOP 1 alivepositiontaking,mlivepositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = mcs3.custid
						   AND cs3.sporttype = mcs3.sporttype
						   AND cs3.bettype = mcs3.bettype
						   AND cs3.alivepositiontaking + cs3.mlivepositiontaking > mcs3.maxlivepositiontaking
						)cs3
			
            --recal autopos
            -- s1=min(s4-m1-a1,u)      
			UPDATE cs3 
            SET spositiontaking = case when scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking > 
                                    (case when cs3.isautopositiontaking = 1 then cs3.autopositiontaking else  mcs3.autopositiontaking end) then (case when cs3.isautopositiontaking = 1 then cs3.autopositiontaking else mcs3.autopositiontaking end ) else scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking end
            FROM (SELECT c.custid, mcs3.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mcs3		
				WHERE bettype in (81,83,86,88)			
				)mcs3
			CROSS APPLY (SELECT TOP 1 *
						FROM @tmpSAg scs3
						WHERE  scs3.sporttype = mcs3.sporttype
						   AND scs3.bettype = mcs3.bettype
						)scs3
			CROSS APPLY (SELECT TOP 1 isautopositiontaking,autopositiontaking,spositiontaking,mpositiontaking,apositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = mcs3.custid
						   AND cs3.sporttype = mcs3.sporttype
						   AND cs3.bettype = mcs3.bettype
						   AND (cs3.isautopositiontaking=1 or mcs3.isautopositiontaking = 1)
						)cs3
			
            UPDATE cs3 
            SET slivepositiontaking = case when scs3.slivepositiontaking - cs3.mlivepositiontaking-cs3.alivepositiontaking >
                        (case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) then (case when cs3.isautolivepositiontaking = 1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) else scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking end
            FROM (SELECT c.custid, mcs3.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mcs3		
				WHERE bettype in (85,86,87,89,90)		
				)mcs3
			CROSS APPLY (SELECT TOP 1 *
						FROM @tmpSAg scs3
						WHERE  scs3.sporttype = mcs3.sporttype
						   AND scs3.bettype = mcs3.bettype
						)scs3
			CROSS APPLY (SELECT TOP 1 isautolivepositiontaking,autolivepositiontaking,slivepositiontaking,mlivepositiontaking,alivepositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = mcs3.custid
						   AND cs3.sporttype = mcs3.sporttype
						   AND cs3.bettype = mcs3.bettype
						   AND (cs3.isautolivepositiontaking=1 or mcs3.isautolivepositiontaking=1)
						)cs3
			
            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
			UPDATE cs3
            SET spositiontaking = sco3.minpositiontaking-cs3.mpositiontaking-cs3.apositiontaking
            FROM (SELECT c.custid, sco3.*
				FROM #tblCust c
					CROSS JOIN @tmpSAg sco3	
				WHERE bettype in (81,83,86,88)			
				)sco3		
			CROSS APPLY (SELECT TOP 1 spositiontaking,mpositiontaking,apositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = sco3.custid
						   AND cs3.sporttype = sco3.sporttype
						   AND cs3.bettype = sco3.bettype
						   AND cs3.apositiontaking+ cs3.mpositiontaking + cs3.spositiontaking < sco3.minpositiontaking
						)cs3	
			
			UPDATE cs3
            SET slivepositiontaking = sco3.minlivepositiontaking - cs3.mlivepositiontaking-cs3.alivepositiontaking
            FROM (SELECT c.custid, sco3.*
				FROM #tblCust c
					CROSS JOIN @tmpSAg sco3	
				WHERE bettype in (85,86,87,89,90)			
				)sco3		
			CROSS APPLY (SELECT TOP 1 slivepositiontaking,mlivepositiontaking,alivepositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = sco3.custid
						   AND cs3.sporttype = sco3.sporttype
						   AND cs3.bettype = sco3.bettype
						   AND cs3.alivepositiontaking + cs3.mlivepositiontaking + cs3.slivepositiontaking < sco3.minlivepositiontaking
						)cs3	
			
            --update s1,m1,a1 in case s1+m1+a1>s4
            --s1=max(0,s4-m1-a1)
            --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
            --@maxmapos=min(m3,l3)
            --@mapos2=min(@mapos1,@maxmapos)
            --@mapos=max(@mapos2,n3)
            --m1=max(0,@mapos-a1)
            --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
            UPDATE cs3
            SET @spos = case when scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking<0 then 0 else scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking end,
                spositiontaking = @spos,
                @mapos1 = case when @spos + cs3.mpositiontaking+cs3.apositiontaking>scs3.spositiontaking then scs3.spositiontaking-@spos else cs3.mpositiontaking+cs3.apositiontaking end,
                @maxmapos = case when mcs3.mpositiontaking > mcs3.maxpositiontaking then mcs3.maxpositiontaking else mcs3.mpositiontaking end,
                @mapos2 = case when @mapos1 > @maxmapos then @maxmapos else @mapos1 end,
                @mapos = case when @mapos2 < mcs3.minpositiontaking then mcs3.minpositiontaking else @mapos2 end,
                @mpos = case when @mapos - cs3.apositiontaking < 0 then 0 else @mapos-cs3.apositiontaking end,
                mpositiontaking = @mpos,
                @apos = case when cs3.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs3.apositiontaking end,
                apositiontaking = case when @apos < aco3.minpositiontaking then aco3.minpositiontaking else @apos end
            FROM (SELECT c.custid, c.recommend, mcs3.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mcs3	
				WHERE bettype in (81,83,86,88)			
				)mcs3
			CROSS APPLY (SELECT TOP 1 *
						FROM @tmpSAg scs3
						WHERE  scs3.sporttype = mcs3.sporttype
						   AND scs3.bettype = mcs3.bettype
						)scs3
			CROSS APPLY (SELECT TOP 1 minpositiontaking
						FROM custoverride3rd as aco3 WITH(NOLOCK) 
						WHERE aco3.custid = mcs3.recommend
						   AND aco3.sporttype = mcs3.sporttype
						   AND aco3.bettype = mcs3.bettype
						)aco3			
			CROSS APPLY (SELECT TOP 1 spositiontaking,apositiontaking,mpositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = mcs3.custid
						   AND cs3.sporttype = mcs3.sporttype
						   AND cs3.bettype = mcs3.bettype
						   AND cs3.spositiontaking+cs3.apositiontaking + cs3.mpositiontaking > scs3.spositiontaking
						)cs3
			
            UPDATE cs3
            SET @spos = case when scs3.slivepositiontaking - cs3.mlivepositiontaking-cs3.alivepositiontaking < 0 then 0 else scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking end,
                slivepositiontaking = @spos,
                @mapos1 = case when @spos + cs3.mlivepositiontaking+ cs3.alivepositiontaking > scs3.slivepositiontaking then scs3.slivepositiontaking-@spos else cs3.mlivepositiontaking + cs3.alivepositiontaking end,
                @maxmapos = case when mcs3.mlivepositiontaking > mcs3.maxlivepositiontaking then mcs3.maxlivepositiontaking else mcs3.mlivepositiontaking end,
                @mapos2 = case when @mapos1 > @maxmapos then @maxmapos else @mapos1 end,
                @mapos = case when @mapos2 < mcs3.minlivepositiontaking then mcs3.minlivepositiontaking else @mapos2 end,
                @mpos = case when @mapos-cs3.alivepositiontaking < 0 then 0 else @mapos-cs3.alivepositiontaking end,
                mlivepositiontaking = @mpos,
                @apos = case when cs3.alivepositiontaking + @mpos > @mapos then @mapos - @mpos else cs3.alivepositiontaking end,
                alivepositiontaking = case when @apos < aco3.minlivepositiontaking then aco3.minlivepositiontaking else @apos end
			FROM (SELECT c.custid, c.recommend, mcs3.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mcs3	
				WHERE bettype in (85,86,87,89,90)			
				)mcs3
			CROSS APPLY (SELECT TOP 1 *
						FROM @tmpSAg scs3
						WHERE  scs3.sporttype = mcs3.sporttype
						   AND scs3.bettype = mcs3.bettype
						)scs3
			CROSS APPLY (SELECT TOP 1 minlivepositiontaking
						FROM custoverride3rd as aco3 WITH(NOLOCK) 
						WHERE aco3.custid = mcs3.recommend
						   AND aco3.sporttype = mcs3.sporttype
						   AND aco3.bettype = mcs3.bettype
						)aco3			
			CROSS APPLY (SELECT TOP 1 slivepositiontaking,mlivepositiontaking,alivepositiontaking
						FROM custsetting3rd cs3 WITH(UPDLOCK,ROWLOCK)
						WHERE  cs3.custid = mcs3.custid
						   AND cs3.sporttype = mcs3.sporttype
						   AND cs3.bettype = mcs3.bettype
						   AND cs3.slivepositiontaking + cs3.alivepositiontaking + cs3.mlivepositiontaking > scs3.slivepositiontaking
						)cs3			
        END
        
        ELSE IF @mode = 'Keno' OR @mode = 'GoldDeluxe'
        BEGIN
			INSERT INTO #tblCust(custid,recommend)
			SELECT custid, recommend 
			FROM custinfo c WITH(NOLOCK)
			WHERE mrecommend = @mrecommend
			   AND c.roleid = 1
			   AND c.Enabled = 1
			
			INSERT INTO @tmpSAg(sporttype,bettype,spositiontaking,minpositiontaking)
			SELECT scs.sporttype,scs.bettype,spositiontaking,minpositiontaking
			FROM CustSettingGame scs WITH(NOLOCK)
				INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON scs.custid= sco.custid
														AND scs.sporttype = sco.sporttype
														AND scs.bettype = sco.bettype
			WHERE scs.custid = @srecommend
				AND scs.sporttype = @sporttype
                and scs.bettype = @bettype
			
			INSERT INTO @tmpMAg(sporttype, bettype, mpositiontaking, autopositiontaking, 
				isautopositiontaking, minpositiontaking)
			SELECT mcs.sporttype,mcs.bettype, mpositiontaking, autopositiontaking, 
				isautopositiontaking, minpositiontaking
			FROM CustSettingGame mcs WITH(NOLOCK)
				INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mcs.custid= mco.custid
														AND mcs.sporttype = mco.sporttype
														AND mcs.bettype = mco.bettype
			WHERE mcs.custid = @mrecommend
				AND mcs.sporttype = @sporttype
                and mcs.bettype = @bettype
				
            --Recal AUTO MPT m1=min(m3-a1,u2)
			UPDATE cs
            SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END THEN
                                                CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END 
                                                ELSE mcs.mpositiontaking - cs.apositiontaking END
            FROM (SELECT c.custid, c.recommend, mcs.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mcs 				
				)mcs
			CROSS APPLY (SELECT TOP 1 isautompositiontaking, autompositiontaking
						FROM CustSettingGame acs WITH(NOLOCK)
						WHERE  acs.custid = mcs.recommend
						   AND acs.sporttype = mcs.sporttype
						   AND acs.bettype = mcs.bettype
						)acs
			CROSS APPLY (SELECT TOP 1 isautompositiontaking,autompositiontaking,mpositiontaking,apositiontaking
						FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
						WHERE  cs.custid = mcs.custid
						   AND cs.sporttype = mcs.sporttype
						   AND cs.bettype = mcs.bettype
						   AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)
						)cs
			
            --check master min/max
            --m1=n3-a1
			UPDATE cs 
				SET mpositiontaking = mco.minpositiontaking-cs.apositiontaking
			FROM (SELECT c.custid, mco.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mco 					
				)mco		
			CROSS APPLY (SELECT TOP 1 mpositiontaking,apositiontaking
						FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
						WHERE  cs.custid = mco.custid
						   AND cs.sporttype = mco.sporttype
						   AND cs.bettype = mco.bettype
						   AND cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
					   )cs
			
            -- Update m1,a1 when m1+a1>m3
            -- m1=m3-a1
			UPDATE cs
            SET @mpos = CASE WHEN mcs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE mcs.mpositiontaking - cs.apositiontaking END,
                cs.mpositiontaking = @mpos,
                @apos = CASE WHEN cs.apositiontaking + @mpos > mcs.mpositiontaking THEN mcs.mpositiontaking - @mpos ELSE cs.apositiontaking END ,
                cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END 
            FROM (SELECT c.custid, c.recommend, mcs.*
				FROM #tblCust c
					CROSS JOIN @tmpMAg mcs 				
				)mcs
			CROSS APPLY (SELECT TOP 1 minpositiontaking
						FROM CustOverrideGame aco WITH(NOLOCK)
						WHERE  aco.custid = mcs.recommend
						   AND aco.sporttype = mcs.sporttype
						   AND aco.bettype = mcs.bettype
						)aco
			CROSS APPLY (SELECT TOP 1 apositiontaking,mpositiontaking
						FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
						WHERE  cs.custid = mcs.custid
						   AND cs.sporttype = mcs.sporttype
						   AND cs.bettype = mcs.bettype
						   AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking   
						)cs
			  
            --recal autopos
            -- s1=min(s4-m1-a1,u)
			UPDATE cs
            SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END
                                        THEN CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END
                                        ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END 
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
						FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
						WHERE  cs.custid = mcs.custid
						   AND cs.sporttype = mcs.sporttype
						   AND cs.bettype = mcs.bettype
						   AND (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
						)cs
			            
            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
			UPDATE cs
                SET spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
            FROM (SELECT c.custid, sco.*
				FROM #tblCust c
					CROSS JOIN @tmpSAg sco 				
				)sco			
			CROSS APPLY (SELECT TOP 1 spositiontaking,mpositiontaking,apositiontaking
						FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
						WHERE  cs.custid = sco.custid
						   AND cs.sporttype = sco.sporttype
						   AND cs.bettype = sco.bettype
						   AND cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
						)cs
			      
            --update s1,m1,a1 in case s1+m1+a1>s4
            --s1=max(0,s4-m1-a1)
            --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
            --@maxmapos=min(m3,l3)
            --@mapos2=min(@mapos1,@maxmapos)
            --@mapos=max(@mapos2,n3)
            --m1=max(0,@mapos-a1)
            --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
			UPDATE cs
            SET @spos = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END,
                cs.spositiontaking = @spos,
                @mapos1 = CASE WHEN cs.mpositiontaking + cs.apositiontaking + @spos > scs.spositiontaking THEN scs.spositiontaking - @spos ELSE cs.mpositiontaking + cs.apositiontaking END,
                @mapos2 = CASE WHEN @mapos1 > mcs.mpositiontaking THEN mcs.mpositiontaking ELSE @mapos1 END,
                @mapos = CASE WHEN @mapos2 < mcs.minpositiontaking THEN mcs.minpositiontaking ELSE @mapos2 END,
                @mpos =  CASE WHEN @mapos - cs.apositiontaking < 0 THEN 0 ELSE @mapos - cs.apositiontaking END,
                cs.mpositiontaking = @mpos,
                @apos = CASE WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
                cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
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
						FROM custoverrideGame as aco WITH(NOLOCK) 
						WHERE aco.custid = mcs.recommend
						   AND aco.sporttype = mcs.sporttype
						   AND aco.bettype = mcs.bettype
						)aco			
			CROSS APPLY (SELECT TOP 1 spositiontaking,apositiontaking,mpositiontaking
						FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
						WHERE  cs.custid = mcs.custid
						   AND cs.sporttype = mcs.sporttype
						   AND cs.bettype = mcs.bettype
						   AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking 
						)cs
			
        END
    END
    ELSE IF @roleid = 2
    BEGIN		
		SELECT @mrecommend = mrecommend, @srecommend = srecommend
		FROM custinfo WITH(NOLOCK)
		WHERE custid = @recommend
		
		INSERT INTO #tblCust(custid)
		SELECT custid
		FROM custinfo WITH(NOLOCK)
		WHERE recommend = @recommend
			AND roleid = 1
		
			
        IF @mode = 'number'
        BEGIN   
			INSERT INTO @tmpSAg(sporttype, bettype, spositiontaking, slivepositiontaking,minpositiontaking,minlivepositiontaking,
				maxpositiontaking,maxlivepositiontaking)
			SELECT scs.sporttype, scs.bettype, spositiontaking, slivepositiontaking,minpositiontaking,minlivepositiontaking,
				maxpositiontaking,maxlivepositiontaking
			FROM custsetting3rd scs WITH(NOLOCK)
				INNER JOIN custoverride3rd sco WITH(NOLOCK) ON scs.custid = sco.custid
															AND scs.sporttype = sco.sporttype
															AND scs.bettype = sco.bettype
			WHERE scs.custid = @srecommend
				AND scs.sporttype = 161
				
			INSERT INTO @tmpMAg(sporttype,bettype,mpositiontaking,mlivepositiontaking,autopositiontaking,autolivepositiontaking,
				isautopositiontaking,isautolivepositiontaking,minpositiontaking,minlivepositiontaking,maxpositiontaking,maxlivepositiontaking)
			SELECT mcs.sporttype,mcs.bettype,mpositiontaking,mlivepositiontaking,autopositiontaking,autolivepositiontaking,
				isautopositiontaking,isautolivepositiontaking,minpositiontaking,minlivepositiontaking,maxpositiontaking,maxlivepositiontaking
			FROM custsetting3rd mcs WITH(NOLOCK)
				INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mcs.custid = mco.custid
															AND mcs.sporttype = mco.sporttype
															AND mcs.bettype = mco.bettype			
			WHERE mcs.custid = @mrecommend
				AND mcs.sporttype = 161
						
			INSERT INTO @tmpAg(sporttype, bettype, minpositiontaking, minlivepositiontaking,maxpositiontaking,maxlivepositiontaking
				,autompositiontaking,autolivempositiontaking,isautompositiontaking,isautolivempositiontaking)
			SELECT acs3.sporttype, acs3.bettype, minpositiontaking, minlivepositiontaking,maxpositiontaking,maxlivepositiontaking
				,autompositiontaking,autolivempositiontaking,isautompositiontaking,isautolivempositiontaking
			FROM custoverride3rd aco WITH(NOLOCK)
				INNER JOIN custsetting3rd acs3 WITH(NOLOCK) ON aco.custid = acs3.custid
															AND aco.sporttype = acs3.sporttype
															AND aco.bettype = acs3.bettype
			WHERE acs3.custid = @recommend
				AND acs3.sporttype = 161 				
						
            --Check min max a1: n2<=a1<=l2 => modify a1
            -- non-live (min)
			UPDATE cs3
			SET cs3.apositiontaking = aco3.minpositiontaking
			FROM( SELECT mb.custid, aco3.*
			FROM #tblCust mb 
				CROSS JOIN @tmpAg aco3		
				WHERE aco3.sporttype = 161 
					AND aco3.bettype in (81,83,86,88)		
			)aco3
			CROSS APPLY(SELECT TOP 1 apositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE aco3.custid = cs3.custid
							AND cs3.sporttype = aco3.sporttype
							AND cs3.bettype = aco3.bettype
							AND cs3.apositiontaking < aco3.minpositiontaking 
						)cs3
						
            -- live (min)
			UPDATE cs3
			SET cs3.alivepositiontaking = aco3.minlivepositiontaking
			FROM( SELECT mb.custid, aco3.*
			FROM #tblCust mb 
				CROSS JOIN @tmpAg aco3		
				WHERE aco3.sporttype = 161 
					AND aco3.bettype in (85,86,87,89,90)	
			)aco3
			CROSS APPLY(SELECT TOP 1 alivepositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE aco3.custid = cs3.custid
							AND cs3.sporttype = aco3.sporttype
							AND cs3.bettype = aco3.bettype
							AND cs3.alivepositiontaking < aco3.minlivepositiontaking
						)cs3
			
            -- non-live(max)
			UPDATE cs3
			SET cs3.apositiontaking = aco3.maxpositiontaking
			FROM( SELECT mb.custid, aco3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpAg aco3		
				WHERE aco3.sporttype = 161 
					AND aco3.bettype in (81,83,86,88)		
			)aco3
			CROSS APPLY(SELECT TOP 1 apositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE aco3.custid = cs3.custid
							AND cs3.sporttype = aco3.sporttype
							AND cs3.bettype = aco3.bettype
							AND cs3.apositiontaking > aco3.maxpositiontaking
						)cs3
			
            -- live(max)
			UPDATE cs3
			SET cs3.alivepositiontaking = aco3.maxlivepositiontaking
			FROM( SELECT mb.custid, aco3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpAg aco3		
				WHERE aco3.sporttype = 161 
					AND aco3.bettype in (85,86,87,89,90)	
			)aco3
			CROSS APPLY(SELECT TOP 1 alivepositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE aco3.custid = cs3.custid
							AND cs3.sporttype = aco3.sporttype
							AND cs3.bettype = aco3.bettype
							AND cs3.alivepositiontaking > aco3.maxlivepositiontaking
						)cs3
			
            --Check m1+a1: m1+a1>m3 => modify m1 set m1=m3-a1            
            -- non-live
			UPDATE cs3
			SET mpositiontaking = macs3.mpositiontaking - cs3.apositiontaking
			FROM( SELECT mb.custid, macs3.*
			FROM #tblCust mb 
				CROSS JOIN @tmpMAg macs3		
				WHERE sporttype = 161 
					AND bettype in (81,83,86,88)		
			)macs3
			CROSS APPLY(SELECT TOP 1 mpositiontaking,apositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE macs3.custid = cs3.custid
							AND cs3.sporttype = macs3.sporttype
							AND cs3.bettype = macs3.bettype
							AND cs3.apositiontaking + cs3.mpositiontaking > macs3.mpositiontaking
						)cs3
			
            -- live
			UPDATE cs3
			SET mlivepositiontaking = macs3.mlivepositiontaking - cs3.alivepositiontaking
			FROM( SELECT mb.custid, macs3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg macs3		
				WHERE sporttype = 161 
					AND bettype in (85,86,87,89,90) 		
			)macs3
			CROSS APPLY(SELECT TOP 1 mlivepositiontaking,alivepositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE macs3.custid = cs3.custid
							AND cs3.sporttype = macs3.sporttype
							AND cs3.bettype = macs3.bettype
							AND cs3.alivepositiontaking + cs3.mlivepositiontaking > macs3.mlivepositiontaking
						)cs3
						
            --Recal u2
            --Recal AUTO MPT m1=min(m3-a1,u2)
            -- non-live
			UPDATE cs3
			SET cs3.mpositiontaking = 
                    case when mcs3.mpositiontaking-cs3.apositiontaking > case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
                        then case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
                    else  mcs3.mpositiontaking-cs3.apositiontaking end
			FROM( SELECT mb.custid, mcs3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg mcs3		
				WHERE sporttype = 161 
					AND bettype in (81,83,86,88)		
			)mcs3
			CROSS APPLY (SELECT TOP 1 *
						FROM @tmpAg acs3
						WHERE acs3.sporttype = mcs3.sporttype
							AND acs3.bettype = mcs3.bettype
						)acs3
			CROSS APPLY(SELECT TOP 1 mpositiontaking,apositiontaking,isautompositiontaking,autompositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE mcs3.custid = cs3.custid
							AND cs3.sporttype = mcs3.sporttype
							AND cs3.bettype = mcs3.bettype
							AND (acs3.isautompositiontaking = 1 or cs3.isautompositiontaking = 1)
						)cs3
						
            -- live
			UPDATE cs3
			SET mlivepositiontaking =
                    case when mcs3.mlivepositiontaking-cs3.alivepositiontaking > case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
                        then case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
                    else  mcs3.mlivepositiontaking-cs3.alivepositiontaking end
			FROM( SELECT mb.custid, mcs3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg mcs3		
				WHERE sporttype = 161 
					AND bettype in (85,86,87,89,90)
			)mcs3
			CROSS APPLY (SELECT TOP 1 *
						FROM @tmpAg acs3
						WHERE acs3.sporttype = mcs3.sporttype
							AND acs3.bettype = mcs3.bettype
						)acs3
			CROSS APPLY(SELECT TOP 1 mlivepositiontaking,alivepositiontaking,isautolivempositiontaking,autolivempositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE mcs3.custid = cs3.custid
							AND cs3.sporttype = mcs3.sporttype
							AND cs3.bettype = mcs3.bettype
							AND (acs3.isautolivempositiontaking = 1 or cs3.isautolivempositiontaking = 1)
						)cs3
						
            --Check min max n3<=m1+a1<=l3 => modify m1
            -- non-live
			UPDATE cs3
            SET cs3.mpositiontaking = mco3.minpositiontaking - cs3.apositiontaking
			FROM( SELECT mb.custid, mco3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg mco3		
				WHERE sporttype = 161 
					AND bettype in (81,83,86,88) 
			)mco3			
			CROSS APPLY(SELECT TOP 1 mpositiontaking,apositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE mco3.custid = cs3.custid
							AND cs3.sporttype = mco3.sporttype
							AND cs3.bettype = mco3.bettype
							AND (cs3.mpositiontaking + cs3.apositiontaking < mco3.minpositiontaking)
						)cs3
			
            --Live(min)
			UPDATE cs3
            SET cs3.mlivepositiontaking = mco3.minlivepositiontaking - cs3.alivepositiontaking
			FROM( SELECT mb.custid, mco3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg mco3		
				WHERE sporttype = 161 
					AND bettype in (85,86,87,89,90)
			)mco3			
			CROSS APPLY(SELECT TOP 1 mlivepositiontaking,alivepositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE mco3.custid = cs3.custid
							AND cs3.sporttype = mco3.sporttype
							AND cs3.bettype = mco3.bettype
							AND (cs3.mlivepositiontaking + cs3.alivepositiontaking < mco3.minlivepositiontaking)
						)cs3
			
            --Nonlive(max)
			UPDATE cs3
            SET cs3.mpositiontaking = mco3.maxpositiontaking - cs3.apositiontaking
			FROM( SELECT mb.custid, mco3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg mco3		
				WHERE sporttype = 161 
					AND bettype in (81,83,86,88) 
			)mco3			
			CROSS APPLY(SELECT TOP 1 mpositiontaking,apositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE mco3.custid = cs3.custid
							AND cs3.sporttype = mco3.sporttype
							AND cs3.bettype = mco3.bettype
							AND (cs3.mpositiontaking + cs3.apositiontaking > mco3.maxpositiontaking)
						)cs3
			
            --Live(max)
			UPDATE cs3
            SET cs3.mlivepositiontaking = mco3.maxlivepositiontaking - cs3.alivepositiontaking
			FROM( SELECT mb.custid, mco3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg mco3		
				WHERE sporttype = 161 
					AND bettype in (85,86,87,89,90)
			)mco3			
			CROSS APPLY(SELECT TOP 1 mlivepositiontaking,alivepositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE mco3.custid = cs3.custid
							AND cs3.sporttype = mco3.sporttype
							AND cs3.bettype = mco3.bettype
							AND (cs3.mlivepositiontaking + cs3.alivepositiontaking > mco3.maxlivepositiontaking)
						)cs3
			
            --Recal u3,u1
            -- s1=min(s4-m1-a1,u)
            --Nonlive
			UPDATE cs3 
                SET spositiontaking = case when scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking >
                                        (case when cs3.isautopositiontaking=1 then cs3.autopositiontaking else mcs3.autopositiontaking end) then (case when cs3.isautopositiontaking=1 then cs3.autopositiontaking else mcs3.autopositiontaking end) else scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking end             
			FROM( SELECT mb.custid, mcs3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg mcs3		
				WHERE sporttype = 161 
					AND bettype in (81,83,86,88)
			)mcs3
			CROSS APPLY (SELECT TOP 1 *
						FROM @tmpSAg scs3
						WHERE scs3.sporttype = mcs3.sporttype
							AND scs3.bettype = mcs3.bettype
						)scs3
			CROSS APPLY(SELECT TOP 1 spositiontaking,mpositiontaking,apositiontaking,isautopositiontaking,autopositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE mcs3.custid = cs3.custid
							AND cs3.sporttype = mcs3.sporttype
							AND cs3.bettype = mcs3.bettype
							AND (cs3.isautopositiontaking=1 or mcs3.isautopositiontaking=1)
						)cs3
		 
            --Live
			UPDATE cs3 
                SET slivepositiontaking = case when scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking >
                                        (case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) then (case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) else scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking end             
			FROM( SELECT mb.custid, mcs3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg mcs3		
				WHERE sporttype = 161 
					AND bettype in (85,86,87,89,90)
			)mcs3
			CROSS APPLY (SELECT TOP 1 *
						FROM @tmpSAg scs3
						WHERE scs3.sporttype = mcs3.sporttype
							AND scs3.bettype = mcs3.bettype
						)scs3
			CROSS APPLY(SELECT TOP 1 slivepositiontaking,mlivepositiontaking,alivepositiontaking,isautolivepositiontaking,autolivepositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE mcs3.custid = cs3.custid
							AND cs3.sporttype = mcs3.sporttype
							AND cs3.bettype = mcs3.bettype
							AND (cs3.isautolivepositiontaking=1 or mcs3.isautolivepositiontaking=1)
						)cs3
						
            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
            --Nonlive(min)
			UPDATE cs3 
                SET spositiontaking = sco3.minpositiontaking-cs3.mpositiontaking-cs3.apositiontaking            
			FROM( SELECT mb.custid, sco3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpSAg sco3		
				WHERE sporttype = 161 
					AND bettype in (81,83,86,88)
			)sco3			
			CROSS APPLY(SELECT TOP 1 spositiontaking,mpositiontaking,apositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE sco3.custid = cs3.custid
							AND cs3.sporttype = sco3.sporttype
							AND cs3.bettype = sco3.bettype
							AND cs3.apositiontaking + cs3.mpositiontaking + cs3.spositiontaking<sco3.minpositiontaking
						)cs3
						
            --Live(min)
			UPDATE cs3 
                SET slivepositiontaking = sco3.minlivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking
			FROM( SELECT mb.custid, sco3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpSAg sco3		
				WHERE sporttype = 161 
					AND bettype in (85,86,87,89,90)
			)sco3			
			CROSS APPLY(SELECT TOP 1 slivepositiontaking,mlivepositiontaking,alivepositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE sco3.custid = cs3.custid
							AND cs3.sporttype = sco3.sporttype
							AND cs3.bettype = sco3.bettype
							AND cs3.alivepositiontaking+cs3.mlivepositiontaking+cs3.slivepositiontaking<sco3.minlivepositiontaking
						)cs3
						
            --Nonlive(max)
			UPDATE cs3 
                SET spositiontaking = sco3.maxpositiontaking-cs3.mpositiontaking-cs3.apositiontaking
			FROM( SELECT mb.custid, sco3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpSAg sco3		
				WHERE sporttype = 161 
					AND bettype in (81,83,86,88)
			)sco3			
			CROSS APPLY(SELECT TOP 1 spositiontaking,mpositiontaking,apositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE sco3.custid = cs3.custid
							AND cs3.sporttype = sco3.sporttype
							AND cs3.bettype = sco3.bettype
							AND cs3.apositiontaking+cs3.mpositiontaking+cs3.spositiontaking>sco3.maxpositiontaking
						)cs3
						
            --Live(max)
			UPDATE cs3 
                SET slivepositiontaking = sco3.maxlivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking
			FROM( SELECT mb.custid, sco3.*
				FROM #tblCust mb 
					CROSS JOIN @tmpSAg sco3		
				WHERE sporttype = 161 
					AND bettype in (85,86,87,89,90)
			)sco3			
			CROSS APPLY(SELECT TOP 1 slivepositiontaking,mlivepositiontaking,alivepositiontaking
						FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
						WHERE sco3.custid = cs3.custid
							AND cs3.sporttype = sco3.sporttype
							AND cs3.bettype = sco3.bettype
							AND cs3.alivepositiontaking+cs3.mlivepositiontaking+cs3.slivepositiontaking>sco3.maxlivepositiontaking
						)cs3
			
        END
              
        ELSE IF @mode = 'Keno' OR @mode = 'GoldDeluxe'
        BEGIN
			INSERT INTO @tmpSAg(sporttype, bettype, spositiontaking, minpositiontaking)
			SELECT scs.sporttype, scs.bettype, spositiontaking, minpositiontaking
			FROM CustSettingGame scs WITH(NOLOCK)
				INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON scs.custid = sco.custid
															AND scs.sporttype = sco.sporttype
															AND scs.bettype = sco.bettype
			WHERE scs.custid = @srecommend
				AND scs.sporttype = @sporttype
				AND scs.bettype = @bettype
				
			INSERT INTO @tmpMAg(sporttype,bettype,mpositiontaking,autopositiontaking,isautopositiontaking,minpositiontaking)
			SELECT mcs.sporttype,mcs.bettype,mpositiontaking,autopositiontaking,isautopositiontaking,minpositiontaking
			FROM CustSettingGame mcs WITH(NOLOCK)
				INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mcs.custid = mco.custid
															AND mcs.sporttype = mco.sporttype
															AND mcs.bettype = mco.bettype			
			WHERE mcs.custid = @mrecommend
				AND mcs.sporttype = @sporttype
				AND mcs.bettype = @bettype
						
			INSERT INTO @tmpAg(sporttype, bettype,minpositiontaking,autompositiontaking,isautompositiontaking)
			SELECT acs.sporttype, acs.bettype, minpositiontaking,autompositiontaking,isautompositiontaking
			FROM CustOverrideGame aco WITH(NOLOCK)
				INNER JOIN CustSettingGame acs WITH(NOLOCK) ON aco.custid = acs.custid
															AND aco.sporttype = acs.sporttype
															AND aco.bettype = acs.bettype
			WHERE acs.custid = @recommend
				AND acs.sporttype = @sporttype
				AND acs.bettype = @bettype
			
			UPDATE cs
			SET cs.apositiontaking = aco.minpositiontaking
			FROM( SELECT mb.custid, aco.*
				FROM #tblCust mb 
					CROSS JOIN @tmpAg aco							
			)aco
			CROSS APPLY(SELECT TOP 1 apositiontaking
						FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
						WHERE aco.custid = cs.custid
							AND cs.sporttype = aco.sporttype
							AND cs.bettype = aco.bettype
							AND cs.apositiontaking < aco.minpositiontaking 
						)cs
			
            --Check m1+a1: m1+a1>m3 => modify m1 set m1=m3-a1
			UPDATE cs
			SET mpositiontaking = macs.mpositiontaking - cs.apositiontaking
			FROM( SELECT mb.custid, macs.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg macs							
			)macs
			CROSS APPLY(SELECT TOP 1 mpositiontaking,apositiontaking
						FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
						WHERE macs.custid = cs.custid
							AND cs.sporttype = macs.sporttype
							AND cs.bettype = macs.bettype
							AND cs.apositiontaking + cs.mpositiontaking > macs.mpositiontaking 
						)cs
			
            --Recal um2
            --Recal AUTO MPT m1=min(m3-a1,um2)
			UPDATE cs
                SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking-cs.apositiontaking > (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)
                    THEN (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)
                ELSE  mcs.mpositiontaking-cs.apositiontaking END
			FROM( SELECT mb.custid, mcs.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg mcs							
			)mcs
			CROSS APPLY (SELECT TOP 1 *
						FROM @tmpAg acs
						WHERE acs.sporttype = mcs.sporttype
							AND acs.bettype = mcs.bettype
						)acs
			CROSS APPLY(SELECT TOP 1 mpositiontaking,apositiontaking,isautompositiontaking,autompositiontaking
						FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
						WHERE mcs.custid = cs.custid
							AND cs.sporttype = mcs.sporttype
							AND cs.bettype = mcs.bettype
							AND (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
						)cs
			
            --Check min max n3<=m1+a1<=m3 => modify m1
			UPDATE cs
                SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking            
			FROM( SELECT mb.custid, mco.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg mco							
			)mco			
			CROSS APPLY(SELECT TOP 1 mpositiontaking,apositiontaking
						FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
						WHERE mco.custid = cs.custid
							AND cs.sporttype = mco.sporttype
							AND cs.bettype = mco.bettype
							AND cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking
						)cs
			
			UPDATE cs
                SET cs.mpositiontaking = mcs.mpositiontaking - cs.apositiontaking           
			FROM( SELECT mb.custid, mcs.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg mcs							
			)mcs			
			CROSS APPLY(SELECT TOP 1 mpositiontaking,apositiontaking
						FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
						WHERE mcs.custid = cs.custid
							AND cs.sporttype = mcs.sporttype
							AND cs.bettype = mcs.bettype
							AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking
						)cs
			
            --Recal u3,u1
            -- s1=min(s4-m1-a1,u)
			UPDATE cs
                SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN
                                CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END  ELSE
                                scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
            FROM( SELECT mb.custid, mcs.*
				FROM #tblCust mb 
					CROSS JOIN @tmpMAg mcs							
			)mcs
			CROSS APPLY (SELECT TOP 1 *
						FROM @tmpSAg scs
						WHERE scs.sporttype = mcs.sporttype
							AND scs.bettype = mcs.bettype
						)scs
			CROSS APPLY(SELECT TOP 1 spositiontaking,mpositiontaking,apositiontaking,isautopositiontaking,autopositiontaking
						FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
						WHERE mcs.custid = cs.custid
							AND cs.sporttype = mcs.sporttype
							AND cs.bettype = mcs.bettype
							AND (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
						)cs
						
            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
			UPDATE cs
                SET spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
			FROM( SELECT mb.custid, sco.*
				FROM #tblCust mb 
					CROSS JOIN @tmpSAg sco							
			)sco			
			CROSS APPLY(SELECT TOP 1 spositiontaking,mpositiontaking,apositiontaking
						FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
						WHERE sco.custid = cs.custid
							AND cs.sporttype = sco.sporttype
							AND cs.bettype = sco.bettype
							AND cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
						)cs
						
            --check a1+m1+s1 > s4
			UPDATE cs
                SET cs.spositiontaking = scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
			FROM( SELECT mb.custid, scs.*
				FROM #tblCust mb 
					CROSS JOIN @tmpSAg scs							
			)scs			
			CROSS APPLY(SELECT TOP 1 spositiontaking,mpositiontaking,apositiontaking
						FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
						WHERE scs.custid = cs.custid
							AND cs.sporttype = scs.sporttype
							AND cs.bettype = scs.bettype
							AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
						)cs			
        END
        
    END
	DROP TABLE #tblCust
END
GO



