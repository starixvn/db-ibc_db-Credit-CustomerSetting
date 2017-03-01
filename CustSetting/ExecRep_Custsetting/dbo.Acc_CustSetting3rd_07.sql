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
    
    IF @roleid = 4
    BEGIN            
        IF @mode = 'number'
        BEGIN
            --u = (i3 or i1)?(u3 or u1)
            --s1 = min(s4-m1-a1, u)        
            --v161
             
            Update custsetting3rd 
                set spositiontaking = case when scs3.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking >
                                        (case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs3.autopositiontaking end) then (case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs3.autopositiontaking end) else scs3.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking end 
            from
                custsetting3rd 
                inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
                inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = c.mrecommend and mcs3.sporttype=custsetting3rd.sporttype and mcs3.bettype=custsetting3rd.bettype
                inner join custsetting3rd as scs3 with (NOLOCK) on scs3.custid = @srecommend and scs3.sporttype=custsetting3rd.sporttype and scs3.bettype=custsetting3rd.bettype
            where
                c.srecommend = @srecommend
                and c.roleid = 1
                AND c.Enabled = 1
                AND custsetting3rd.sporttype = 161
                and (custsetting3rd.isautopositiontaking=1 or mcs3.isautopositiontaking=1)
			
			--check super min
            --s1=max(n4-m1-a1,s1)
            UPDATE cs
               SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
            FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
				INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
												   AND mb.srecommend = @srecommend
												   AND mb.roleid = 1
												   AND mb.Enabled = 1
				INNER JOIN CustOverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend
														   AND sco.sporttype = cs.sporttype
														   AND sco.bettype = cs.bettype
			WHERE cs.sporttype = 161
				AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
			       
            --v161 
            Update custsetting3rd
                set slivepositiontaking = case when scs3.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking >
                                        (case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs3.autolivepositiontaking end) then (case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs3.autolivepositiontaking end) else scs3.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking end 
            from
                custsetting3rd
                inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
                inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = c.mrecommend and mcs3.sporttype=custsetting3rd.sporttype and mcs3.bettype=custsetting3rd.bettype
                inner join custsetting3rd as scs3 with (NOLOCK) on scs3.custid = @srecommend and scs3.sporttype=custsetting3rd.sporttype and scs3.bettype=custsetting3rd.bettype
            where
                c.srecommend = @srecommend
                and c.roleid = 1
                AND c.Enabled = 1
                and (custsetting3rd.isautolivepositiontaking=1 or mcs3.isautolivepositiontaking=1)
			
			UPDATE cs
			   SET slivepositiontaking = sco.minlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
			FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
				INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
												   AND mb.srecommend = @srecommend
												   AND mb.roleid = 1
												   AND mb.Enabled = 1
				INNER JOIN CustOverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend
														   AND sco.sporttype = cs.sporttype
														   AND sco.bettype = cs.bettype
			WHERE cs.sporttype = 161
				AND cs.alivepositiontaking + cs.mlivepositiontaking + cs.slivepositiontaking < sco.minlivepositiontaking
				                
	                              
        END
        ELSE IF @mode = 'virtual-sports'
        BEGIN
            -- Auto PT: update s1 
            -- if is1=1 then s1=min(s4-m1-a1), us1)
            -- else is3=1 then s1=min(s4-m1-a1), us3)
            Update cs
                set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
                                        (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
            from
                CustSetting3rd as cs with(ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
            where
                c.srecommend = @srecommend
                AND c.Enabled = 1
                and c.roleid = 1 and cs.sporttype=@sporttype and cs.bettype=@bettype 
                and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
			
			--check super min
            --s1=max(n4-m1-a1,s1)
            UPDATE cs
               SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
            FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
				INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
												   AND mb.srecommend = @srecommend
												   AND mb.roleid = 1
												   AND mb.Enabled = 1
				INNER JOIN CustOverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend
														   AND sco.sporttype = cs.sporttype
														   AND sco.bettype = cs.bettype
			WHERE cs.sporttype=@sporttype 
				AND cs.bettype=@bettype 
				AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
			                      

        END
        ELSE IF @mode = 'LiveCasino'
        BEGIN            
            --u = (i3 or i1)?(u3 or u1)
            --s1 = min(s4-m1-a1, u)
            UPDATE cs 
            SET spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking >
                                         CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END THEN
                                        (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) 
                                    ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking 
                                END                            
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON ci.custid = cs.custid
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
                INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
            WHERE ci.srecommend = @srecommend AND roleid = 1 AND ci.SyncLiveCasino = 1
                AND ci.Enabled = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101 
                AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)     
            
            --check super min
            --s1=max(n4-m1-a1,s1)
            UPDATE cs
               SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
            FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
				INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
												   AND mb.srecommend = @srecommend
												   AND mb.roleid = 1
												   AND mb.Enabled = 1
				INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend
														   AND sco.sporttype = cs.sporttype
														   AND sco.bettype = cs.bettype
			WHERE cs.sporttype=162 
				AND cs.bettype=1101 
				AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
			
        END        		
        ELSE IF @mode = 'horse'
        BEGIN
            Update cs
                set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
                                        (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
            from
                CustSetting3rd as cs with(ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
            where
                c.srecommend = @srecommend 
                and c.roleid = 1 and cs.sporttype between 151 and 153
                AND c.Enabled = 1
                and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
			
			--check super min
            --s1=max(n4-m1-a1,s1)
            UPDATE cs
               SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
            FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
				INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
												   AND mb.srecommend = @srecommend
												   AND mb.roleid = 1
												   AND mb.Enabled = 1
				INNER JOIN CustOverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend
														   AND sco.sporttype = cs.sporttype
														   AND sco.bettype = cs.bettype
			WHERE cs.sporttype between 151 and 153				
				AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
			                
        END
        ELSE IF @mode = 'Keno' OR @mode = 'GoldDeluxe'
        BEGIN            
            --u = (i3 or i1)?(u3 or u1)
            --s1 = min(s4-m1-a1, u)
            UPDATE cs 
            SET spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking >
                                         CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END THEN
                                        (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) 
                                    ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking 
                                END                            
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON ci.custid = cs.custid
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
                INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
            WHERE ci.srecommend = @srecommend AND ci.roleid = 1
                AND ci.Enabled = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
                AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)     
			
			--check super min
            --s1=max(n4-m1-a1,s1)
            UPDATE cs
               SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
            FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
				INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
												   AND mb.srecommend = @srecommend
												   AND mb.roleid = 1
												   AND mb.Enabled = 1
				INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend
														   AND sco.sporttype = cs.sporttype
														   AND sco.bettype = cs.bettype
			WHERE  cs.sporttype = @sporttype 
				AND cs.bettype = @bettype 			
				AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
			                          
            
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
            --Update all agent and member accounts

            
            --Phuc remove @20081125 
            /*
            -- Update m2,a2 when m2+a2>m3(normal)
            -- m2=m3-a2,a2=max(iif(m3<m2+a2,m3-m2,a2),n2)

            Update custsetting with (ROWLOCK, UPDLOCK) set 
                @mpos = case when mcs.mpositiontaking-custsetting.apositiontaking<0 then 0 else mcs.mpositiontaking-custsetting.apositiontaking end,
                mpositiontaking = @mpos,
                @apos = case when mcs.mpositiontaking-@mpos-custsetting.apositiontaking<0 then mcs.mpositiontaking-@mpos else custsetting.apositiontaking end,
                apositiontaking = case when aco.minpositiontaking > @apos then aco.minpositiontaking else @apos end 
            from 
                custsetting inner join customer as a with (NOLOCK) on custsetting.custid = a.custid and a.mrecommend = @mrecommend and a.roleid = 2
                inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
                inner join custoverride as aco with (NOLOCK) on aco.custid = custsetting.custid  and aco.sporttype=custsetting.sporttype and aco.bettype=custsetting.bettype
            where 
                custsetting.mpositiontaking+custsetting.apositiontaking > mcs.mpositiontaking

            -- Update m2,a2 when m2+a2>m3(live)
            -- m2=m3-a2,a2=max(iif(m3<m2+a2,m3-m2,a2),n2)
            Update custsetting with (ROWLOCK, UPDLOCK) set 
                @mpos = case when mcs.mlivepositiontaking-custsetting.alivepositiontaking<0 then 0 else mcs.mlivepositiontaking-custsetting.alivepositiontaking end,
                mlivepositiontaking = @mpos,
                @apos = case when mcs.mlivepositiontaking-@mpos-custsetting.alivepositiontaking<0 then mcs.mlivepositiontaking-@mpos else custsetting.alivepositiontaking end,
                alivepositiontaking = case when aco.minlivepositiontaking > @apos then aco.minlivepositiontaking else @apos end 
            from 
                custsetting inner join customer as a with (NOLOCK) on custsetting.custid = a.custid and a.mrecommend = @mrecommend and a.roleid = 2
                inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
                inner join custoverride as aco with (NOLOCK) on aco.custid = custsetting.custid  and aco.sporttype=custsetting.sporttype and aco.bettype=custsetting.bettype
            where 
                custsetting.sporttype=1 and custsetting.bettype in (1,3,7,8) 
                and custsetting.mlivepositiontaking+custsetting.alivepositiontaking > mcs.mlivepositiontaking
            */

            --Recal AUTO MPT m1=min(m3-a1,u2)
            update cs3 with(rowlock,updlock)
                set mpositiontaking = case when mcs3.mpositiontaking-cs3.apositiontaking > case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
                                           then case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
                                            else mcs3.mpositiontaking-cs3.apositiontaking end
            from custsetting3rd cs3 
                inner join custinfo c with(nolock) on cs3.custid = c.custid
                inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
                inner join custsetting3rd acs3 with(nolock) on acs3.custid = c.recommend and acs3.sporttype = cs3.sporttype and acs3.bettype = mcs3.bettype
            where
                c.mrecommend = @mrecommend
                and c.roleid = 1
                AND c.Enabled = 1
                and (acs3.isautompositiontaking = 1 or cs3.isautompositiontaking = 1)
                and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

            
            update cs3 with(rowlock,updlock)
                set mlivepositiontaking = case when mcs3.mlivepositiontaking-cs3.alivepositiontaking > case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
                                                then case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
                                            else mcs3.mlivepositiontaking-cs3.alivepositiontaking end
            from custsetting3rd cs3
                inner join custinfo c with(nolock) on cs3.custid = c.custid
                inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
                inner join custsetting3rd acs3 with(nolock) on acs3.custid = c.recommend and acs3.sporttype = cs3.sporttype and acs3.bettype = cs3.bettype
            where c.mrecommend = @mrecommend
                and c.roleid = 1
                AND c.Enabled = 1
                and (acs3.isautolivempositiontaking = 1 or cs3.isautolivempositiontaking = 1)
                and cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90)

            --check master min/max
            --m1=n3-a1
            update cs3 with(rowlock,updlock)
            set mpositiontaking = mco3.minpositiontaking - cs3.apositiontaking
            from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1
                                    inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
            where cs3.apositiontaking + cs3.mpositiontaking < mco3.minpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)


            update cs3 with(rowlock,updlock)
            set mlivepositiontaking = mco3.minlivepositiontaking-cs3.alivepositiontaking
            from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1 AND mb.Enabled = 1
                inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
            where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking+cs3.mlivepositiontaking<mco3.minlivepositiontaking

            -- Update m1,a1 when m1+a1>l3
            -- m1=min(m3,l3)-a1            
            update cs3 with(rowlock,updlock)
            set @maxmapos = case when mcs3.mpositiontaking > mco3.maxpositiontaking then mco3.maxpositiontaking else mcs3.mpositiontaking end,
                @mpos = case when @maxmapos-cs3.apositiontaking < 0 then 0 else @maxmapos-cs3.apositiontaking end,
                mpositiontaking = @mpos,
                @apos = case when cs3.apositiontaking + @mpos > @maxmapos then @maxmapos-@mpos else cs3.apositiontaking end,
                apositiontaking = case when @apos<aco3.minpositiontaking then aco3.minpositiontaking else @apos end
            from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid=1 AND mb.Enabled = 1
                inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = @mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
                inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
                inner join custoverride3rd aco3 with(nolock) on aco3.custid = mb.recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
            where cs3.apositiontaking + cs3.mpositiontaking > mco3.maxpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

            update cs3 with(rowlock,updlock)
            set @maxmapos = case when mcs3.mlivepositiontaking > mco3.maxlivepositiontaking then mco3.maxlivepositiontaking else mcs3.mlivepositiontaking end,
                @mpos = case when @maxmapos-cs3.alivepositiontaking < 0 then 0 else @maxmapos-cs3.alivepositiontaking end,
                mlivepositiontaking = @mpos,
                @apos = case when cs3.alivepositiontaking + @mpos > @maxmapos then @maxmapos - @mpos else cs3.alivepositiontaking end,
                alivepositiontaking = case when @apos < aco3.minlivepositiontaking then aco3.minlivepositiontaking else @apos end
            from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1 AND mb.Enabled = 1
                inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = @mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
                inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
                inner join custoverride3rd aco3 with(nolock) on aco3.custid = mb.recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
            where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking + cs3.mlivepositiontaking > mco3.maxlivepositiontaking

            --recal autopos
            -- s1=min(s4-m1-a1,u)            
            update cs3 with(rowlock,updlock)
            set spositiontaking = case when scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking > 
                                    (case when cs3.isautopositiontaking = 1 then cs3.autopositiontaking else  mcs3.autopositiontaking end) then (case when cs3.isautopositiontaking = 1 then cs3.autopositiontaking else mcs3.autopositiontaking end ) else scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking end
            from custsetting3rd cs3 
                inner join custinfo c with(nolock) on cs3.custid = c.custid
                inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
                inner join custsetting3rd scs3 with(nolock) on scs3.custid = @srecommend and scs3.sporttype = cs3.sporttype and scs3.bettype = cs3.bettype
            where c.mrecommend = @mrecommend
                and c.roleid = 1
                AND c.Enabled = 1
                and (cs3.isautopositiontaking=1 or mcs3.isautopositiontaking = 1)
                and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

            
            update cs3 with(rowlock,updlock)
            set slivepositiontaking = case when scs3.slivepositiontaking - cs3.mlivepositiontaking-cs3.alivepositiontaking >
                        (case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) then (case when cs3.isautolivepositiontaking = 1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) else scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking end
            from custsetting3rd cs3
                inner join custinfo c with(nolock) on cs3.custid = c.custid
                inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
                inner join custsetting3rd scs3 with(nolock) on scs3.custid = @srecommend and scs3.sporttype = cs3.sporttype and scs3.bettype = cs3.bettype
            where c.mrecommend = @mrecommend
                and c.roleid = 1
                AND c.Enabled = 1
                and (cs3.isautolivepositiontaking=1 or mcs3.isautolivepositiontaking=1)
                and cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90)


            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
            update cs3 with(rowlock,updlock)
            set spositiontaking = sco3.minpositiontaking-cs3.mpositiontaking-cs3.apositiontaking
            from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1 AND mb.Enabled = 1
                inner join custoverride3rd sco3 with(nolock) on sco3.custid = @srecommend and sco3.sporttype = cs3.sporttype and sco3.bettype = cs3.bettype
            where cs3.apositiontaking+ cs3.mpositiontaking + cs3.spositiontaking < sco3.minpositiontaking
                and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)
            
            update cs3 with(rowlock,updlock)
            set slivepositiontaking = sco3.minlivepositiontaking - cs3.mlivepositiontaking-cs3.alivepositiontaking
            from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1
                inner join custoverride3rd sco3 with(nolock) on sco3.custid = @srecommend and sco3.sporttype = cs3.sporttype and sco3.bettype = cs3.bettype
            where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking + cs3.mlivepositiontaking + cs3.slivepositiontaking < sco3.minlivepositiontaking

            --update s1,m1,a1 in case s1+m1+a1>s4
            --s1=max(0,s4-m1-a1)
            --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
            --@maxmapos=min(m3,l3)
            --@mapos2=min(@mapos1,@maxmapos)
            --@mapos=max(@mapos2,n3)
            --m1=max(0,@mapos-a1)
            --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)            
            update cs3 with(rowlock,updlock)
            set @spos = case when scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking<0 then 0 else scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking end,
                spositiontaking = @spos,
                @mapos1 = case when @spos + cs3.mpositiontaking+cs3.apositiontaking>scs3.spositiontaking then scs3.spositiontaking-@spos else cs3.mpositiontaking+cs3.apositiontaking end,
                @maxmapos = case when mcs3.mpositiontaking > mco3.maxpositiontaking then mco3.maxpositiontaking else mcs3.mpositiontaking end,
                @mapos2 = case when @mapos1 > @maxmapos then @maxmapos else @mapos1 end,
                @mapos = case when @mapos2 < mco3.minpositiontaking then mco3.minpositiontaking else @mapos2 end,
                @mpos = case when @mapos - cs3.apositiontaking < 0 then 0 else @mapos-cs3.apositiontaking end,
                mpositiontaking = @mpos,
                @apos = case when cs3.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs3.apositiontaking end,
                apositiontaking = case when @apos < aco3.minpositiontaking then aco3.minpositiontaking else @apos end
            from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1 AND mb.Enabled = 1
                inner join custsetting3rd scs3 with(nolock) on scs3.custid = @srecommend and scs3.sporttype = cs3.sporttype and scs3.bettype = cs3.bettype
                inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = @mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
                inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
                inner join custoverride3rd aco3 with(nolock) on aco3.custid = mb.recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
            where cs3.spositiontaking+cs3.apositiontaking + cs3.mpositiontaking > scs3.spositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

            
            update cs3 with(rowlock,updlock)
            set @spos = case when scs3.slivepositiontaking - cs3.mlivepositiontaking-cs3.alivepositiontaking < 0 then 0 else scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking end,
                slivepositiontaking = @spos,
                @mapos1 = case when @spos + cs3.mlivepositiontaking+ cs3.alivepositiontaking > scs3.slivepositiontaking then scs3.slivepositiontaking-@spos else cs3.mlivepositiontaking + cs3.alivepositiontaking end,
                @maxmapos = case when mcs3.mlivepositiontaking > mco3.maxlivepositiontaking then mco3.maxlivepositiontaking else mcs3.mlivepositiontaking end,
                @mapos2 = case when @mapos1 > @maxmapos then @maxmapos else @mapos1 end,
                @mapos = case when @mapos2 < mco3.minlivepositiontaking then mco3.minlivepositiontaking else @mapos2 end,
                @mpos = case when @mapos-cs3.alivepositiontaking < 0 then 0 else @mapos-cs3.alivepositiontaking end,
                mlivepositiontaking = @mpos,
                @apos = case when cs3.alivepositiontaking + @mpos > @mapos then @mapos - @mpos else cs3.alivepositiontaking end,
                alivepositiontaking = case when @apos < aco3.minlivepositiontaking then aco3.minlivepositiontaking else @apos end

            from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1 AND mb.Enabled = 1
                inner join custsetting3rd scs3 with(nolock) on scs3.custid = @srecommend and scs3.sporttype = cs3.sporttype and scs3.bettype = cs3.bettype
                inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = @mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
                inner join custoverride3rd sco3 with(nolock) on sco3.custid = @srecommend and sco3.sporttype = cs3.sporttype and sco3.bettype = cs3.bettype
                inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
                inner join custoverride3rd aco3 with(nolock) on aco3.custid = mb.recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
            where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.slivepositiontaking + cs3.alivepositiontaking + cs3.mlivepositiontaking > scs3.slivepositiontaking
        END
        ELSE IF @mode = 'virtual-sports'
        BEGIN
                --Recal AUTO MPT m1=min(m3-a1,u2)
            UPDATE cs 
                set mpositiontaking = 
                    case when mcs.mpositiontaking-cs.apositiontaking > case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
                        then case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
                    else  mcs.mpositiontaking-cs.apositiontaking end
            from
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid and c.mrecommend = @mrecommend and c.roleid =1 AND c.Enabled = 1
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
            where cs.sporttype = @sporttype
                and cs.bettype = @bettype
                and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
                 
                
            --check master min/max
            --m1=n3-a1
            Update cs
                set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
            from 
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1 AND mb.Enabled = 1
                inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
            where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
                and cs.sporttype = @sporttype 
                and cs.bettype = @bettype
            
            -- Update m1,a1 when m1+a1>l3
            -- m1=min(m3,l3)-a1
            UPDATE cs
            SET @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
                @mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
                mpositiontaking = @mpos,
                @apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
                apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
            FROM 
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1 AND mb.Enabled = 1
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
                inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
            WHERE cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
                and cs.sporttype = @sporttype AND cs.bettype = @bettype        
            
            --recal autopos
            -- s1=min(s4-m1-a1,u)
            Update cs 
                set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
                                        (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
            from
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid and c.mrecommend = @mrecommend and c.roleid = 1 AND c.Enabled = 1
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
            where (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
                and cs.sporttype = @sporttype and cs.bettype = @bettype
            
            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
            Update cs
                set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
            from 
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1 AND mb.Enabled = 1
                inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
            where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
                and cs.sporttype = @sporttype and cs.bettype = @bettype
            
            
            --update s1,m1,a1 in case s1+m1+a1>s4
            --s1=max(0,s4-m1-a1)
            --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)    
            --@mapos2=min(@mapos1,m3)
            --@mapos=max(@mapos2,n3)
            --m1=max(0,@mapos-a1)
            --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
            Update cs 
                set @spos = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 then 0 else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end,
                    spositiontaking = @spos,
                    @mapos1 = case when @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else cs.mpositiontaking+cs.apositiontaking end,
                    @mapos2 = CASE WHEN @mapos1 > mcs.mpositiontaking THEN mcs.mpositiontaking ELSE @mapos1 END,
                    @mapos = CASE WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
                    @mpos =  CASE WHEN @mapos - cs.apositiontaking < 0 THEN 0 ELSE @mapos - cs.apositiontaking END,
                    cs.mpositiontaking = @mpos,
                    @apos = CASE WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
                    cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
            from 
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1 AND mb.Enabled = 1
                inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
                inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
            where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
                and cs.sporttype = @sporttype and cs.bettype = @bettype
        END
        ELSE IF @mode = 'LiveCasino'
        BEGIN
            --Recal AUTO MPT m1=min(m3-a1,u2)
            UPDATE cs
            SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END THEN
                                                CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END 
                                                ELSE mcs.mpositiontaking - cs.apositiontaking END
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
            WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND ci.Enabled = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101
                AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)

            --check master min/max
            --m1=n3-a1
            UPDATE cs
            SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking 
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
            WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND ci.Enabled = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101
                 AND cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking

            -- Update m1,a1 when m1+a1>m3
            -- m1=m3-a1
            UPDATE cs
            SET @mpos = CASE WHEN mcs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE mcs.mpositiontaking - cs.apositiontaking END,
                cs.mpositiontaking = @mpos,
                @apos = CASE WHEN cs.apositiontaking + @mpos > mcs.mpositiontaking THEN mcs.mpositiontaking - @mpos ELSE cs.apositiontaking END ,
                cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END 
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
                INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
            WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND ci.Enabled = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101 
                AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking        
            
                
            --recal autopos
            -- s1=min(s4-m1-a1,u)
            UPDATE cs
            SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END
                                        THEN CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END
                                        ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END 
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
            WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND ci.Enabled = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101
                AND (mcs.isautopositiontaking = 1 OR cs.isautopositiontaking = 1)
            
            
            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
            UPDATE cs
            SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking 
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype
            WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND ci.Enabled = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101
                AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking < sco.minpositiontaking 
                    

                
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
                @mapos = CASE WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
                @mpos =  CASE WHEN @mapos - cs.apositiontaking < 0 THEN 0 ELSE @mapos - cs.apositiontaking END,
                cs.mpositiontaking = @mpos,
                @apos = CASE WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
                cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
                INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
                INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
                INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
            WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND ci.Enabled = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101
                AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking 
            
        END        		       
        ELSE IF @mode = 'horse'
        BEGIN
            --Recal AUTO MPT m1=min(m3-a1,u2)
            Update cs 
                set mpositiontaking = 
                    case when mcs.mpositiontaking-cs.apositiontaking > case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
                        then case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
                    else  mcs.mpositiontaking-cs.apositiontaking end
            from
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
            where
                c.mrecommend = @mrecommend
                and c.roleid = 1
                AND c.Enabled = 1
                and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
                and cs.sporttype in (151,152,153)

            --check master min/max
            --m1=n3-a1
            Update cs
                set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
            from 
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1 AND mb.Enabled = 1
                inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
            where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
                and cs.sporttype in (151,152,153)

            -- Update m1,a1 when m1+a1>l3
            -- m1=min(m3,l3)-a1
            Update cs
                set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
                    @mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
                    mpositiontaking = @mpos,
                    @apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
                    apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
            from 
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1 AND mb.Enabled = 1
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
                inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
            where cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
                and cs.sporttype in (151,152,153)

            --recal autopos
            -- s1=min(s4-m1-a1,u)
            Update cs 
                set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
                                        (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
            from
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
            where
                c.mrecommend = @mrecommend
                and c.roleid = 1
                AND c.Enabled = 1
                and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
                and cs.sporttype in (151,152,153)

            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
            Update cs
                set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
            from 
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1 AND mb.Enabled = 1
                inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
            where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
                and cs.sporttype in (151,152,153)

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
                    @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
                    @mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
                    @mapos = case when @mapos2<mco.minpositiontaking then mco.minpositiontaking else @mapos2 end,
                    @mpos = case when @mapos-cs.apositiontaking<0 then 0 else @mapos-cs.apositiontaking end,
                    mpositiontaking = @mpos,
                    @apos = case when cs.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs.apositiontaking end,
                    apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
            from 
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1 AND mb.Enabled = 1
                inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
                inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
            where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
                and cs.sporttype in (151,152,153)

        END
        ELSE IF @mode = 'Keno' OR @mode = 'GoldDeluxe'
        BEGIN
            --Recal AUTO MPT m1=min(m3-a1,u2)
            UPDATE cs
            SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END THEN
                                                CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END 
                                                ELSE mcs.mpositiontaking - cs.apositiontaking END
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
            WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.Enabled = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype
                AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)

            --check master min/max
            --m1=n3-a1
            UPDATE cs
            SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking 
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
            WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.Enabled = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype
                 AND cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking

            -- Update m1,a1 when m1+a1>m3
            -- m1=m3-a1
            UPDATE cs
            SET @mpos = CASE WHEN mcs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE mcs.mpositiontaking - cs.apositiontaking END,
                cs.mpositiontaking = @mpos,
                @apos = CASE WHEN cs.apositiontaking + @mpos > mcs.mpositiontaking THEN mcs.mpositiontaking - @mpos ELSE cs.apositiontaking END ,
                cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END 
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
                INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
            WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.Enabled = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
                AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking        
            
                
            --recal autopos
            -- s1=min(s4-m1-a1,u)
            UPDATE cs
            SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END
                                        THEN CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END
                                        ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END 
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
            WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.Enabled = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype
                AND (mcs.isautopositiontaking = 1 OR cs.isautopositiontaking = 1)
            
            
            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
            UPDATE cs
            SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking 
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype
            WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.Enabled = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype
                AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking < sco.minpositiontaking 
                    
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
                @mapos = CASE WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
                @mpos =  CASE WHEN @mapos - cs.apositiontaking < 0 THEN 0 ELSE @mapos - cs.apositiontaking END,
                cs.mpositiontaking = @mpos,
                @apos = CASE WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
                cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
                INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
                INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
                INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
            WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.Enabled = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype
                AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking 
            
        END
    END
    ELSE IF @roleid = 2
    BEGIN
        IF @mode = 'number'
        BEGIN                        
            --Check min max a1: n2<=a1<=l2 => modify a1
            -- non-live (min)
            update cs3
            set cs3.apositiontaking = aco3.minpositiontaking
            from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join custoverride3rd aco3 with(nolock) on aco3.custid = @recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
            where cs3.apositiontaking < aco3.minpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

            -- live (min)
            update cs3
            set cs3.alivepositiontaking = aco3.minlivepositiontaking
            from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join custoverride3rd aco3 with(nolock) on aco3.custid = @recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
            where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking < aco3.minlivepositiontaking

            -- non-live(max)
            update cs3
            set cs3.apositiontaking = aco3.maxpositiontaking
            from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.roleid = 1 and mb.recommend = @recommend
                inner join custoverride3rd aco3 with(nolock) on aco3.custid = @recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
            where cs3.sporttype = 161 and cs3.bettype in (81,83,86,88) and cs3.apositiontaking > aco3.maxpositiontaking

            -- live(max)
            update cs3
            set cs3.alivepositiontaking = aco3.maxlivepositiontaking
            from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join custoverride3rd aco3 with(nolock) on aco3.custid = @recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
            where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking > aco3.maxlivepositiontaking

            --Check m1+a1: m1+a1>m3 => modify m1 set m1=m3-a1            
            -- non-live
            update cs3
            set mpositiontaking = macs3.mpositiontaking - cs3.apositiontaking
            from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join custsetting3rd macs3 with(nolock) on macs3.custid = mb.mrecommend and macs3.sporttype = cs3.sporttype and macs3.bettype = cs3.bettype
            where cs3.apositiontaking + cs3.mpositiontaking > macs3.mpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88) 

            -- live
            update cs3
            set mlivepositiontaking = macs3.mlivepositiontaking - cs3.alivepositiontaking
            from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join custsetting3rd macs3 with(nolock) on macs3.custid = mb.mrecommend and macs3.sporttype = cs3.sporttype and macs3.bettype = cs3.bettype
            where cs3.alivepositiontaking + cs3.mlivepositiontaking > macs3.mlivepositiontaking and cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) 

            --Recal u2
            --Recal AUTO MPT m1=min(m3-a1,u2)
            -- non-live
            Update cs3 with (ROWLOCK, UPDLOCK) 
                set cs3.mpositiontaking = 
                    case when mcs3.mpositiontaking-cs3.apositiontaking > case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
                        then case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
                    else  mcs3.mpositiontaking-cs3.apositiontaking end
            from
                custsetting3rd cs3
                inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid
                inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = mb.mrecommend and mcs3.sporttype=cs3.sporttype and mcs3.bettype=cs3.bettype
                inner join custsetting3rd as acs3 with (NOLOCK) on acs3.custid = mb.recommend and acs3.sporttype=cs3.sporttype and acs3.bettype=cs3.bettype
            where
                mb.recommend = @recommend
                and mb.roleid = 1    
                and (acs3.isautompositiontaking = 1 or cs3.isautompositiontaking = 1)
                and cs3.sporttype = 161
                and cs3.bettype in (81,83,86,88) 

            -- live
            Update cs3 with (ROWLOCK, UPDLOCK) 
                set mlivepositiontaking =
                    case when mcs3.mlivepositiontaking-cs3.alivepositiontaking > case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
                        then case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
                    else  mcs3.mlivepositiontaking-cs3.alivepositiontaking end
            from
                custsetting3rd cs3
                inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid
                inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = mb.mrecommend and mcs3.sporttype=cs3.sporttype and mcs3.bettype=cs3.bettype
                inner join custsetting3rd as acs3 with (NOLOCK) on acs3.custid = mb.recommend and acs3.sporttype=cs3.sporttype and acs3.bettype=cs3.bettype
            where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90)
                and mb.recommend = @recommend
                and mb.roleid = 1
                and (acs3.isautolivempositiontaking = 1 or cs3.isautolivempositiontaking = 1)

            --Check min max n3<=m1+a1<=l3 => modify m1
            -- non-live
            update cs3
            set cs3.mpositiontaking = mco3.minpositiontaking - cs3.apositiontaking
            from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join custoverride3rd mco3 with(nolock) on mco3.custid = mb.mrecommend and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype
            where cs3.mpositiontaking + cs3.apositiontaking < mco3.minpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88) 

            --Live(min)
            update cs3
                set cs3.mlivepositiontaking = mco3.minlivepositiontaking - cs3.alivepositiontaking
            from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join custoverride3rd mco3 with(nolock) on mco3.custid = mb.mrecommend and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype 
            where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) and cs3.mlivepositiontaking + cs3.alivepositiontaking < mco3.minlivepositiontaking

            --Nonlive(max)
            update cs3
                set cs3.mpositiontaking = mco3.maxpositiontaking - cs3.apositiontaking
            from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join custoverride3rd mco3 with(nolock) on mco3.custid = mb.mrecommend and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype 
            where cs3.mpositiontaking + cs3.apositiontaking > mco3.maxpositiontaking and cs3.sporttype = 161  and cs3.bettype in (81,83,86,88)

            --Live(max)
            update cs3
                set cs3.mlivepositiontaking = mco3.maxlivepositiontaking - cs3.alivepositiontaking
            from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join custoverride3rd mco3 with(nolock) on mco3.custid = mb.mrecommend and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype 
            where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) and cs3.mlivepositiontaking + cs3.alivepositiontaking > mco3.maxlivepositiontaking

            --Recal u3,u1
            -- s1=min(s4-m1-a1,u)
            --Nonlive
            Update cs3 with (ROWLOCK, UPDLOCK) 
                set spositiontaking = case when scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking >
                                        (case when cs3.isautopositiontaking=1 then cs3.autopositiontaking else mcs3.autopositiontaking end) then (case when cs3.isautopositiontaking=1 then cs3.autopositiontaking else mcs3.autopositiontaking end) else scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking end 
            from
                custsetting3rd cs3
                inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid
                inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = mb.mrecommend and mcs3.sporttype=cs3.sporttype and mcs3.bettype=cs3.bettype
                inner join custsetting3rd as scs3 with (NOLOCK) on scs3.custid = mb.srecommend and scs3.sporttype=cs3.sporttype and scs3.bettype=cs3.bettype
            where
                mb.recommend = @recommend
                and mb.roleid = 1
                and (cs3.isautopositiontaking=1 or mcs3.isautopositiontaking=1)
                and cs3.sporttype = 161
                and cs3.bettype in (81,83,86,88)
                
            --Live
            Update cs3 with (ROWLOCK, UPDLOCK) 
                set slivepositiontaking = case when scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking >
                                        (case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) then (case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) else scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking end 
            from
                custsetting3rd cs3
                inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid 
                inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = mb.mrecommend and mcs3.sporttype=cs3.sporttype and mcs3.bettype=cs3.bettype
                inner join custsetting3rd as scs3 with (NOLOCK) on scs3.custid = mb.srecommend and scs3.sporttype=cs3.sporttype and scs3.bettype=cs3.bettype
            where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) 
                and mb.recommend = @recommend 
                and mb.roleid = 1
                and (cs3.isautolivepositiontaking=1 or mcs3.isautolivepositiontaking=1)

            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
            --Nonlive(min)
            Update cs3 with (ROWLOCK, UPDLOCK) set 
                spositiontaking = sco3.minpositiontaking-cs3.mpositiontaking-cs3.apositiontaking
            from 
                custsetting3rd cs3 inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
                inner join custoverride3rd as sco3 with (NOLOCK) on sco3.custid = mb.srecommend  and sco3.sporttype=cs3.sporttype and sco3.bettype=cs3.bettype
            where cs3.apositiontaking + cs3.mpositiontaking + cs3.spositiontaking<sco3.minpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

            --Live(min)
            Update cs3 with (ROWLOCK, UPDLOCK) set 
                slivepositiontaking = sco3.minlivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking
            from 
                custsetting3rd cs3 inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
                inner join custoverride3rd as sco3 with (NOLOCK) on sco3.custid = mb.srecommend  and sco3.sporttype=cs3.sporttype and sco3.bettype=cs3.bettype
            where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking+cs3.mlivepositiontaking+cs3.slivepositiontaking<sco3.minlivepositiontaking

            --Nonlive(max)
            Update cs3 with (ROWLOCK, UPDLOCK) set 
                spositiontaking = sco3.maxpositiontaking-cs3.mpositiontaking-cs3.apositiontaking
            from 
                custsetting3rd cs3 inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
                inner join custoverride3rd as sco3 with (NOLOCK) on sco3.custid = mb.srecommend  and sco3.sporttype=cs3.sporttype and sco3.bettype=cs3.bettype
            where cs3.apositiontaking+cs3.mpositiontaking+cs3.spositiontaking>sco3.maxpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

            --Live(max)
            Update cs3 with (ROWLOCK, UPDLOCK) set 
                slivepositiontaking = sco3.maxlivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking
            from 
                custsetting3rd cs3 inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
                inner join custoverride3rd as sco3 with (NOLOCK) on sco3.custid = mb.srecommend  and sco3.sporttype=cs3.sporttype and sco3.bettype=cs3.bettype
            where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking+cs3.mlivepositiontaking+cs3.slivepositiontaking>sco3.maxlivepositiontaking
        END
        ELSE IF @mode = 'virtual-sports'
        BEGIN
            --Check min max a1: n2<=a1<=l2 => modify a1
            --Nonlive(min)

            update cs 
                set apositiontaking = aco.minpositiontaking 
            from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join CustOverride3rd aco with(nolock) on aco.custid = @recommend and aco.sporttype = cs.sporttype and aco.bettype = cs.bettype 
            where cs.apositiontaking < aco.minpositiontaking 
                and cs.sporttype = @sporttype
                and cs.bettype = @bettype


            --Nonlive(max)
            update cs 
                set apositiontaking = aco.maxpositiontaking 
            from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join CustOverride3rd aco with(nolock) on aco.custid = @recommend and aco.sporttype = cs.sporttype and aco.bettype = cs.bettype 
            where cs.apositiontaking > aco.maxpositiontaking 
                and cs.sporttype = @sporttype
                and cs.bettype = @bettype


            --Check m1+a1: m1+a1>m3 => modify m1 set m1=m3-a1
            --Nonlive
            update cs 
                set mpositiontaking = macs.mpositiontaking - cs.apositiontaking
            from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join CustSetting3rd macs with(nolock) on macs.custid = mb.mrecommend and macs.sporttype = cs.sporttype and macs.bettype = cs.bettype 
            where cs.apositiontaking + cs.mpositiontaking > macs.mpositiontaking 
                and cs.sporttype = @sporttype
                and cs.bettype = @bettype


            --Recal um2
            --Recal AUTO MPT m1=min(m3-a1,um2)
            --Nonlive
            Update cs
                set mpositiontaking = 
                    case when mcs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
                        then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
                    else  mcs.mpositiontaking-cs.apositiontaking end
            from
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = mb.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
            where
                mb.recommend = @recommend
                and mb.roleid = 1
                and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
                and cs.sporttype = @sporttype
                and cs.bettype = @bettype

            --Check min max n3<=m1+a1<=l3 => modify m1
            --Nonlive(min)
            update cs
                set cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
            from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join CustOverride3rd mco with(nolock) on mco.custid = mb.mrecommend and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype 
            where cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking
                and cs.sporttype = @sporttype
                and cs.bettype = @bettype

            --Nonlive(max)
            update cs
                set cs.mpositiontaking = mco.maxpositiontaking - cs.apositiontaking
            from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join CustOverride3rd mco with(nolock) on mco.custid = mb.mrecommend and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype 
            where cs.mpositiontaking + cs.apositiontaking > mco.maxpositiontaking
                and cs.sporttype = @sporttype
                and cs.bettype = @bettype

            --Recal u3,u1
            -- s1=min(s4-m1-a1,u)
            --Nonlive
            Update cs
                set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
                                        (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
            from
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = mb.srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
            where
                mb.recommend = @recommend
                and mb.roleid = 1
                and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
                and cs.sporttype = @sporttype
                and cs.bettype = @bettype

            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
            --Nonlive(min)
            Update cs
                set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
            from 
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
                inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = mb.srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
            where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
                and cs.sporttype = @sporttype
                and cs.bettype = @bettype

            --Nonlive(max)
            Update cs
                set spositiontaking = sco.maxpositiontaking-cs.mpositiontaking-cs.apositiontaking
            from 
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
                inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = mb.srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
            where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking>sco.maxpositiontaking
                and cs.sporttype = @sporttype
                and cs.bettype = @bettype


        END
        ELSE IF @mode = 'LiveCasino'
        BEGIN
            UPDATE cs
            SET cs.apositiontaking = aco.minpositiontaking
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend AND cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype
            WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101 
                AND cs.apositiontaking < aco.minpositiontaking 
            
            --Check m1+a1: m1+a1>m3 => modify m1 set m1=m3-a1
            UPDATE cs
            SET cs.mpositiontaking = mcs.mpositiontaking - cs.apositiontaking
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
            WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101
                AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking 

            --Recal um2
            --Recal AUTO MPT m1=min(m3-a1,um2)
            UPDATE cs
            SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking-cs.apositiontaking > (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)
                    THEN (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)
                ELSE  mcs.mpositiontaking-cs.apositiontaking END
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = @recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
            WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101 
                AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)
            
            --Check min max n3<=m1+a1<=m3 => modify m1
            UPDATE cs
            SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
            FROM CustSettingGame cs
                INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
            WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101 
                AND cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking
            
            UPDATE cs
            SET cs.mpositiontaking = mcs.mpositiontaking - cs.apositiontaking
            FROM CustSettingGame cs
                INNER JOIN custInfo ci WITH(NOLOCK) ON cs.CustID = ci.custid
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
            WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101 
                AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking
            
            --Recal u3,u1
            -- s1=min(s4-m1-a1,u)
            UPDATE cs
            SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN
                                CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END  ELSE
                                scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = ci.srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype         
            WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1            
                AND cs.sporttype = 162 AND cs.bettype = 1101 
                AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)

            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
            UPDATE cs
            SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking 
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = ci.srecommend AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype 
            WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101 
                AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking < sco.minpositiontaking
            
            --check a1+m1+s1 > s4
            UPDATE cs
            SET cs.spositiontaking = scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
            FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = ci.srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
            WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
                AND cs.sporttype = 162 AND cs.bettype = 1101 
                AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
            
        END		
        ELSE IF @mode = 'Keno' OR @mode = 'GoldDeluxe'
        BEGIN
            UPDATE cs
            SET cs.apositiontaking = aco.minpositiontaking
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend AND cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype
            WHERE ci.recommend = @recommend AND ci.roleid = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
                AND cs.apositiontaking < aco.minpositiontaking 
            
            --Check m1+a1: m1+a1>m3 => modify m1 set m1=m3-a1
            UPDATE cs
            SET cs.mpositiontaking = mcs.mpositiontaking - cs.apositiontaking
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
            WHERE ci.recommend = @recommend AND ci.roleid = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype
                AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking 

            --Recal um2
            --Recal AUTO MPT m1=min(m3-a1,um2)
            UPDATE cs
            SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking-cs.apositiontaking > (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)
                    THEN (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)
                ELSE  mcs.mpositiontaking-cs.apositiontaking END
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = @recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
            WHERE ci.recommend = @recommend AND ci.roleid = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
                AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)
            
            --Check min max n3<=m1+a1<=m3 => modify m1
            UPDATE cs
            SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
            WHERE ci.recommend = @recommend AND ci.roleid = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
                AND cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking
            
            UPDATE cs
            SET cs.mpositiontaking = mcs.mpositiontaking - cs.apositiontaking
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN custInfo ci WITH(NOLOCK) ON cs.CustID = ci.custid
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
            WHERE ci.recommend = @recommend AND ci.roleid = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
                AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking
            
            --Recal u3,u1
            -- s1=min(s4-m1-a1,u)
            UPDATE cs
            SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN
                                CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END  ELSE
                                scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = ci.srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
                INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype         
            WHERE ci.recommend = @recommend AND ci.roleid = 1         
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
                AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)

            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
            UPDATE cs
            SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking 
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = ci.srecommend AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype 
            WHERE ci.recommend = @recommend AND ci.roleid = 1
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
                AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking < sco.minpositiontaking
            
            --check a1+m1+s1 > s4
            UPDATE cs
            SET cs.spositiontaking = scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
            FROM CustSettingGame cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = ci.srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
            WHERE ci.recommend = @recommend AND ci.roleid = 1 
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
                AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
            
        END
        ELSE IF @mode = 'horse'
        BEGIN
            update cs 
                set apositiontaking = aco.minpositiontaking 
            from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join CustOverride3rd aco with(nolock) on aco.custid = @recommend and aco.sporttype = cs.sporttype and aco.bettype = cs.bettype 
            where cs.apositiontaking < aco.minpositiontaking 
                and cs.sporttype in (151,152,153)


            --Nonlive(max)
            update cs 
                set apositiontaking = aco.maxpositiontaking 
            from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join CustOverride3rd aco with(nolock) on aco.custid = @recommend and aco.sporttype = cs.sporttype and aco.bettype = cs.bettype 
            where cs.apositiontaking > aco.maxpositiontaking 
                and cs.sporttype in (151,152,153)


            --Check m1+a1: m1+a1>m3 => modify m1 set m1=m3-a1
            --Nonlive
            update cs 
                set mpositiontaking = macs.mpositiontaking - cs.apositiontaking
            from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join CustSetting3rd macs with(nolock) on macs.custid = mb.mrecommend and macs.sporttype = cs.sporttype and macs.bettype = cs.bettype 
            where cs.apositiontaking + cs.mpositiontaking > macs.mpositiontaking 
                and cs.sporttype in (151,152,153)


            --Recal um2
            --Recal AUTO MPT m1=min(m3-a1,um2)
            --Nonlive
            Update cs
                set mpositiontaking = 
                    case when mcs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
                        then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
                    else  mcs.mpositiontaking-cs.apositiontaking end
            from
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = mb.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
            where
                mb.recommend = @recommend
                and mb.roleid = 1
                and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
                and cs.sporttype in (151,152,153)

            --Check min max n3<=m1+a1<=l3 => modify m1
            --Nonlive(min)
            update cs
                set cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
            from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join CustOverride3rd mco with(nolock) on mco.custid = mb.mrecommend and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype 
            where cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking
                and cs.sporttype in (151,152,153)

            --Nonlive(max)
            update cs
                set cs.mpositiontaking = mco.maxpositiontaking - cs.apositiontaking
            from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
                inner join CustOverride3rd mco with(nolock) on mco.custid = mb.mrecommend and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype 
            where cs.mpositiontaking + cs.apositiontaking > mco.maxpositiontaking
                and cs.sporttype in (151,152,153)

            --Recal u3,u1
            -- s1=min(s4-m1-a1,u)
            --Nonlive
            Update cs
                set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
                                        (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
            from
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
                inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = mb.srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
            where
                mb.recommend = @recommend
                and mb.roleid = 1
                and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
                and cs.sporttype in (151,152,153)

            --check super min/max when a1+m1+s1<n4
            -- s1=n4-m1-a1
            --Nonlive(min)
            Update cs
                set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
            from 
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
                inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = mb.srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
            where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
                and cs.sporttype in (151,152,153)


            --Nonlive(max)
            Update cs
                set spositiontaking = sco.maxpositiontaking-cs.mpositiontaking-cs.apositiontaking
            from 
                CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
                inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = mb.srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
            where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking>sco.maxpositiontaking
                and cs.sporttype in (151,152,153)

        END
    END
END

