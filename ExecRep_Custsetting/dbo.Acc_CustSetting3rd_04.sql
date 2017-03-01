ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_04] 
    @srecommend INT = 0,
    @mrecommend INT =0,
    @recommend INT = 0,
    @mode varchar(50)='',
    @sporttype INT = 0,
    @bettype INT = 0,
    @custid INT = 0,
    @roleid INT
 AS
    /*
        Created: Johnson
        Date: 2013-10-29
        Task: Apply execrep WHEN UPDATE min/max pt ON master AND agent
        DB: DBCUST/CustDB
        Original versions: Acc_CustomerUpdMaster_MinMaxPositiontaking
                Acc_CustomerUpdAgent_MinMaxPositiontaking
    
        Revision:
            - 20131029@Lukas: add racing product
            - 20131030@Elodie: add virtual sports
            - 20131030@Lukas: add Live casino product
            - 20131112@Johnson: merge code sp Acc_CustSetting3rd_00 into Acc_CustSetting3rd_04 for super level
            - 20131203@Johnson: UPDATE virtual-sport for super by @sporttype not hard code IN sp
            - 20140227@Elodie: Add Keno sport [Redmine:#11658]
            - 20140729@Logan: 1.Exclude disabled agents, members while updating SM's setting [Redmine: #19631]
                              2.Code aligning ON modified parts
			- 20150424@Kathy: Add Gold Deluxe product [Redmine:#34486]      
			- 20150610@Daniel: 
			  + Improve medthod check table existing in subscribers	
			  + Separate custDB to new server DBCUST   
			- 20151009@Elodie: Hot fix a1 is not updated to n2 when super edit master min pt [Redmine:#45332]  
        Parameter's Explanation:        
    */ 
BEGIN
    SET NOCOUNT ON 

	if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	    AND dbo.f_CheckRepTable('CustSettingGame') = 1 
	    AND dbo.f_CheckRepTable('CustOverrideGame') = 1 
	    AND dbo.f_CheckRepTable('CustSetting3rd') = 1 
	    AND dbo.f_CheckRepTable('CustOverride3rd') = 1 
	    )
	   RETURN
    
     
    declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney
    
    --UPDATE min pt ON super
    IF @roleid = 4
    BEGIN        
        IF @mode = 'horse'
        BEGIN
            --s1=min(s1,s4-m3) if i=0
            UPDATE cs
               SET cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.srecommend = @srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs.sporttype
                                                  AND scs.bettype = cs.bettype
             WHERE cs.isautopositiontaking = 0
               AND mcs.isautopositiontaking = 0 
               AND scs.spositiontaking - mcs.mpositiontaking < cs.spositiontaking
               AND cs.sporttype BETWEEN 151 AND 153


            --check agent min
            --a1=max(a1,n2)
            UPDATE cs
               SET apositiontaking = aco.minpositiontaking
                 , cs.mpositiontaking =
                     CASE
                       WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking
                       ELSE cs.mpositiontaking
                     END
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.srecommend = @srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.apositiontaking < aco.minpositiontaking
               AND cs.sporttype BETWEEN 151 AND 153


            --check agent max
            --a1=min(a1,l2)
            UPDATE cs 
               SET apositiontaking = aco.maxpositiontaking
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.srecommend = @srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.apositiontaking > aco.maxpositiontaking
               AND cs.sporttype BETWEEN 151 AND 153


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
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend
                                                  AND acs.sporttype = cs.sporttype
                                                  AND acs.bettype = cs.bettype
             WHERE c.srecommend = @srecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND (acs.isautompositiontaking = 1
                    OR cs.isautompositiontaking = 1)
               AND cs.sporttype BETWEEN 151 AND 153


            --check master min
            --m1=max(m1,n3-a1)
            UPDATE cs
               SET mpositiontaking = mco.minpositiontaking - cs.apositiontaking
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                            AND mb.srecommend = @srecommend
                                            AND mb.roleid = 1
                                            AND mb.Enabled = 1
        INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                                   AND mco.sporttype = cs.sporttype
                                                   AND mco.bettype = cs.bettype
             WHERE cs.apositiontaking + cs.mpositiontaking < mco.minpositiontaking
               AND cs.sporttype BETWEEN 151 AND 153


            --check master max
            UPDATE cs
               SET @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mpos = CASE
                             WHEN @maxmapos - cs.apositiontaking < 0 THEN 0
                             ELSE @maxmapos - cs.apositiontaking
                           END
                 , mpositiontaking = @mpos
                 , @apos = CASE
                             WHEN cs.apositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                             ELSE cs.apositiontaking
                           END
                 , apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.srecommend = @srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                                   AND mco.sporttype = cs.sporttype
                                                   AND mco.bettype = cs.bettype
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.apositiontaking + cs.mpositiontaking > mco.maxpositiontaking
               AND cs.sporttype BETWEEN 151 AND 153


            --recal autopos
            UPDATE cs
               SET spositiontaking =
                     CASE
                       WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking >
                              (CASE
                                 WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                                 ELSE mcs.autopositiontaking
                               END
                              )
                         THEN (CASE
                                 WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                                 ELSE mcs.autopositiontaking
                               END
                              )
                       ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
                     END 
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs.sporttype
                                                  AND scs.bettype=cs.bettype
             WHERE c.srecommend = @srecommend
               AND c.roleid     = 1
               AND c.Enabled    = 1
               AND (cs.isautopositiontaking = 1
                    OR mcs.isautopositiontaking = 1
                   )
               AND cs.sporttype BETWEEN 151 AND 153

            
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
             WHERE cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
               AND cs.sporttype BETWEEN 151 AND 153


            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
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
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > @maxmapos THEN @maxmapos
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking
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
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.srecommend = @srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs.sporttype
                                                  AND scs.bettype = cs.bettype
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                                   AND mco.sporttype = cs.sporttype
                                                   AND mco.bettype = cs.bettype
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.spositiontaking + cs.apositiontaking + cs.mpositiontaking > scs.spositiontaking
               AND cs.sporttype BETWEEN 151 AND 153


            RETURN

        END--end mode = horse
        
        IF @mode = 'number'
        BEGIN
            DECLARE @_srecommend INT
            SELECT @_srecommend = @srecommend

            --s1=min(s1,s4-m3) if i=0
            
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET cs3.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @_srecommend
                                                  AND scs.sporttype = cs3.sporttype
                                                  AND scs.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (81, 83, 86, 88)
               AND cs3.isautopositiontaking = 0
               AND mcs.isautopositiontaking = 0
               AND scs.spositiontaking - mcs.mpositiontaking < cs3.spositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET cs3.slivepositiontaking = scs.slivepositiontaking - mcs.mlivepositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @_srecommend
                                                  AND scs.sporttype = cs3.sporttype
                                                  AND scs.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.isautolivepositiontaking = 0
               AND mcs.isautolivepositiontaking = 0
               AND scs.slivepositiontaking - mcs.mlivepositiontaking < cs3.slivepositiontaking


            --check agent min
            --a1=max(a1,n2)    
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET apositiontaking = aco.minpositiontaking
                 , cs3.mpositiontaking =
                     CASE
                       WHEN cs3.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking
                       ELSE cs3.mpositiontaking
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (81, 83, 86, 88)
               AND cs3.apositiontaking < aco.minpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET cs3.alivepositiontaking = aco.minlivepositiontaking
                 , cs3.mlivepositiontaking =
                     CASE
                       WHEN cs3.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking THEN mcs.mlivepositiontaking - aco.minlivepositiontaking
                       ELSE cs3.mlivepositiontaking
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.alivepositiontaking < aco.minlivepositiontaking


            --check agent max
            --a1=min(a1,l2)    
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET apositiontaking = aco.maxpositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (81, 83, 86, 88)
               AND cs3.apositiontaking > aco.maxpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET alivepositiontaking = aco.maxlivepositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.alivepositiontaking > aco.maxlivepositiontaking


            --Recal AUTO MPT m1=min(m3-a1,u2)
            
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK) 
               SET mpositiontaking =
                     CASE
                       WHEN mcs.mpositiontaking - cs3.apositiontaking >
                              CASE
                                WHEN cs3.isautompositiontaking = 1 THEN cs3.autompositiontaking
                                ELSE acs.autompositiontaking
                              END
                         THEN CASE
                                WHEN cs3.isautompositiontaking = 1 THEN cs3.autompositiontaking
                                ELSE acs.autompositiontaking
                              END
                       ELSE mcs.mpositiontaking - cs3.apositiontaking
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custsetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend
                                                  AND acs.sporttype = cs3.sporttype
                                                  AND acs.bettype = cs3.bettype
             WHERE c.srecommend = @_srecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs3.sporttype = 161
               AND cs3.bettype IN (81, 83, 86, 88)
               AND (acs.isautompositiontaking = 1
                    OR cs3.isautompositiontaking = 1
                   )

    
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK) 
               SET mlivepositiontaking =
                     CASE
                       WHEN mcs.mlivepositiontaking - cs3.alivepositiontaking >
                              CASE
                                WHEN cs3.isautolivempositiontaking = 1 THEN cs3.autolivempositiontaking
                                ELSE acs.autolivempositiontaking
                              END
                         THEN CASE
                                WHEN cs3.isautolivempositiontaking = 1 THEN cs3.autolivempositiontaking
                                ELSE acs.autolivempositiontaking
                              END
                       ELSE mcs.mlivepositiontaking - cs3.alivepositiontaking
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custsetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend
                                                   AND acs.sporttype = cs3.sporttype
                                                   AND acs.bettype = cs3.bettype
             WHERE c.srecommend = @_srecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND (acs.isautolivempositiontaking = 1
                    OR cs3.isautolivempositiontaking = 1
                   )    


            --check master min
            --m1=max(m1,n3-a1)
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET mpositiontaking = mco.minpositiontaking - cs3.apositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                                    AND mco.sporttype = cs3.sporttype
                                                    AND mco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (81, 83, 86, 88)
               AND cs3.apositiontaking + cs3.mpositiontaking < mco.minpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET mlivepositiontaking = mco.minlivepositiontaking-cs3.alivepositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                                   AND mco.sporttype = cs3.sporttype
                                                   AND mco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.alivepositiontaking + cs3.mlivepositiontaking < mco.minlivepositiontaking


            --check master max   
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mpos =
                     CASE
                       WHEN @maxmapos - cs3.apositiontaking < 0 THEN 0
                       ELSE @maxmapos - cs3.apositiontaking
                     END
                 , mpositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN cs3.apositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                       ELSE cs3.apositiontaking
                     END
                 , apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                                   AND mco.sporttype = cs3.sporttype
                                                   AND mco.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (81, 83, 86, 88)
               AND cs3.apositiontaking + cs3.mpositiontaking > mco.maxpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
                       ELSE mcs.mlivepositiontaking
                     END
                 , @mpos =
                     CASE
                       WHEN @maxmapos - cs3.alivepositiontaking < 0 THEN 0
                       ELSE @maxmapos - cs3.alivepositiontaking
                     END
                 , mlivepositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN cs3.alivepositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                       ELSE cs3.alivepositiontaking
                     END
                 , alivepositiontaking =
                     CASE
                       WHEN @apos < aco.minlivepositiontaking THEN aco.minlivepositiontaking
                       ELSE @apos
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                                   AND mco.sporttype = cs3.sporttype
                                                   AND mco.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.alivepositiontaking + cs3.mlivepositiontaking > mco.maxlivepositiontaking


            --recal autopos   
                
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET spositiontaking =
                     CASE
                       WHEN scs.spositiontaking - cs3.mpositiontaking - cs3.apositiontaking >
                              CASE
                                WHEN cs3.isautopositiontaking = 1 THEN cs3.autopositiontaking
                                ELSE mcs.autopositiontaking
                              END
                         THEN CASE
                                WHEN cs3.isautopositiontaking = 1 THEN cs3.autopositiontaking
                                ELSE mcs.autopositiontaking
                              END
                       ELSE scs.spositiontaking - cs3.mpositiontaking - cs3.apositiontaking
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @_srecommend
                                                  AND scs.sporttype = cs3.sporttype
                                                  AND scs.bettype=cs3.bettype
             WHERE c.srecommend = @_srecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs3.sporttype = 161
               AND cs3.bettype IN (81, 83, 89, 88)
               AND (cs3.isautopositiontaking = 1
                    OR mcs.isautopositiontaking = 1
                   )


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET slivepositiontaking =
                     CASE
                       WHEN scs.slivepositiontaking - cs3.mlivepositiontaking - cs3.alivepositiontaking >
                              CASE
                                WHEN cs3.isautolivepositiontaking = 1 THEN cs3.autolivepositiontaking
                                ELSE mcs.autolivepositiontaking
                              END
                         THEN CASE
                                WHEN cs3.isautolivepositiontaking = 1 THEN cs3.autolivepositiontaking
                                ELSE mcs.autolivepositiontaking
                              END
                       ELSE scs.slivepositiontaking - cs3.mlivepositiontaking - cs3.alivepositiontaking
                     END 
              FROM custsetting3rd cs3
        INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @_srecommend
                                                  AND scs.sporttype = cs3.sporttype
                                                  AND scs.bettype = cs3.bettype
             WHERE c.srecommend = @_srecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND (cs3.isautolivepositiontaking = 1
                    OR mcs.isautolivepositiontaking = 1
                   )    


            --check super min
            --s1=max(n4-m1-a1,s1)    
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET spositiontaking = sco.minpositiontaking - cs3.mpositiontaking - cs3.apositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd sco WITH(NOLOCK) ON sco.custid = @_srecommend
                                                   AND sco.sporttype = cs3.sporttype
                                                   AND sco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (81, 83, 86, 88)
               AND cs3.apositiontaking + cs3.mpositiontaking + cs3.spositiontaking < sco.minpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET slivepositiontaking = sco.minlivepositiontaking - cs3.mlivepositiontaking - cs3.alivepositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd sco WITH(NOLOCK) ON sco.custid = @_srecommend
                                                   AND sco.sporttype = cs3.sporttype
                                                   AND sco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.alivepositiontaking + cs3.mlivepositiontaking + cs3.slivepositiontaking < sco.minlivepositiontaking

            

            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
            --s1=max(0,s4-m1-a1)
            --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
            --@maxmapos=min(m3,l3)
            --@mapos2=min(@mapos1,@maxmapos)
            --@mapos=max(@mapos2,n3)
            --m1=max(0,@mapos-a1)
            --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET @spos =
                     CASE
                       WHEN scs.spositiontaking - cs3.mpositiontaking - cs3.apositiontaking < 0 THEN 0
                       ELSE scs.spositiontaking - cs3.mpositiontaking - cs3.apositiontaking
                     END
                 , spositiontaking = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + cs3.mpositiontaking + cs3.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos
                       ELSE cs3.mpositiontaking + cs3.apositiontaking
                     END
                 , @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > @maxmapos THEN @maxmapos
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - cs3.apositiontaking < 0 THEN 0
                       ELSE @mapos - cs3.apositiontaking
                     END
                 , mpositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN cs3.apositiontaking + @mpos > @mapos THEN @mapos - @mpos
                       ELSE cs3.apositiontaking
                     END
                 , apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @_srecommend
                                                  AND scs.sporttype = cs3.sporttype
                                                  AND scs.bettype = cs3.bettype
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                                   AND mco.sporttype = cs3.sporttype
                                                   AND mco.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (81, 83, 86, 88)
               AND cs3.spositiontaking + cs3.apositiontaking + cs3.mpositiontaking > scs.spositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET @spos =
                     CASE
                       WHEN scs.slivepositiontaking - cs3.mlivepositiontaking - cs3.alivepositiontaking < 0 THEN 0
                       ELSE scs.slivepositiontaking - cs3.mlivepositiontaking - cs3.alivepositiontaking
                     END
                 , slivepositiontaking = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + cs3.mlivepositiontaking + cs3.alivepositiontaking > scs.slivepositiontaking THEN scs.slivepositiontaking - @spos
                       ELSE cs3.mlivepositiontaking + cs3.alivepositiontaking
                     END
                 , @maxmapos =
                     CASE
                       WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
                       ELSE mcs.mlivepositiontaking
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > @maxmapos THEN @maxmapos
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mco.minlivepositiontaking THEN mco.minlivepositiontaking
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - cs3.alivepositiontaking < 0 THEN 0
                       ELSE @mapos - cs3.alivepositiontaking
                     END
                 , mlivepositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN cs3.alivepositiontaking + @mpos > @mapos THEN @mapos - @mpos
                       ELSE cs3.alivepositiontaking
                     END
                 , alivepositiontaking =
                     CASE
                       WHEN @apos < aco.minlivepositiontaking THEN aco.minlivepositiontaking
                       ELSE @apos
                     END
               FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.srecommend = @_srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @_srecommend
                                                  AND scs.sporttype = cs3.sporttype
                                                  AND scs.bettype = cs3.bettype
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                                   AND mco.sporttype = cs3.sporttype
                                                   AND mco.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.slivepositiontaking + cs3.alivepositiontaking + cs3.mlivepositiontaking > scs.slivepositiontaking

            RETURN
        END--end mode = 'number'

        if @mode = 'finance'
        BEGIN
            --s1=min(s1,s4-m3) if i=0
            UPDATE cs
               SET cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.srecommend = @srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs.sporttype
                                                  AND scs.bettype = cs.bettype
             WHERE cs.isautopositiontaking = 0
               AND mcs.isautopositiontaking = 0 
               AND scs.spositiontaking - mcs.mpositiontaking < cs.spositiontaking
               AND cs.sporttype = 201


            --check agent min
            --a1=max(a1,n2)
            UPDATE cs 
                SET apositiontaking = aco.minpositiontaking,
                    cs.mpositiontaking = CASE WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking-aco.minpositiontaking ELSE cs.mpositiontaking END
            FROM 
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK) 
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.srecommend=@srecommend AND mb.roleid=1
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype
                INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype
            WHERE cs.apositiontaking<aco.minpositiontaking
                and cs.sporttype = 201

            --check agent max
            --a1=min(a1,l2)
            UPDATE cs
                SET apositiontaking = aco.maxpositiontaking
            FROM 
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK) 
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.srecommend=@srecommend AND roleid=1
                INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype
            WHERE cs.apositiontaking>aco.maxpositiontaking
                and cs.sporttype = 201


            --Recal AUTO MPT m1=min(m3-a1,um2)
            UPDATE cs 
                SET mpositiontaking = 
                    CASE WHEN mcs.mpositiontaking-cs.apositiontaking > (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)
                    then (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)
                    else  mcs.mpositiontaking-cs.apositiontaking END
            from
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK) 
                INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype
                INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend AND acs.sporttype=cs.sporttype AND acs.bettype=cs.bettype
            where
                c.srecommend = @srecommend
                and c.roleid = 1
                and (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1)
                and cs.sporttype = 201

           

            --check master min
            --m1=max(m1,n3-a1)
            UPDATE cs
                SET mpositiontaking = mco.minpositiontaking-cs.apositiontaking
            FROM 
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK) 
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.srecommend=@srecommend AND mb.roleid=1
                INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend  AND mco.sporttype=cs.sporttype AND mco.bettype=cs.bettype
            WHERE cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
                and cs.sporttype = 201

            --check master max
            UPDATE cs 
                SET @maxmapos = CASE WHEN mcs.mpositiontaking>mco.maxpositiontaking THEN mco.maxpositiontaking ELSE mcs.mpositiontaking END,
                    @mpos = CASE WHEN @maxmapos-cs.apositiontaking<0 THEN 0 ELSE @maxmapos-cs.apositiontaking END,
                    mpositiontaking = @mpos,
                    @apos = CASE WHEN cs.apositiontaking + @mpos>@maxmapos THEN @maxmapos-@mpos ELSE cs.apositiontaking END,
                    apositiontaking = CASE WHEN @apos<aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
            FROM 
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.srecommend=@srecommend AND mb.roleid=1
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype
                INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend  AND mco.sporttype=cs.sporttype AND mco.bettype=cs.bettype
                INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype
            WHERE cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
                and cs.sporttype = 201

            --recal autopos
            UPDATE cs
                SET spositiontaking = CASE WHEN scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
                                        (CASE WHEN cs.isautopositiontaking=1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN (CASE WHEN cs.isautopositiontaking=1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) ELSE scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking END 
            from
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK) 
                INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype
                INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype
            where
                c.srecommend = @srecommend
                and c.roleid = 1
                and (cs.isautopositiontaking=1 OR mcs.isautopositiontaking=1)
                and cs.sporttype = 201

            
            --check super min
            --s1=max(n4-m1-a1,s1)
            UPDATE cs
                SET spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
            FROM 
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK) 
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.srecommend=@srecommend AND mb.roleid=1
                INNER JOIN CustOverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend  AND sco.sporttype=cs.sporttype AND sco.bettype=cs.bettype
            WHERE cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
                and cs.sporttype = 201

            
            UPDATE cs
                SET @spos = CASE WHEN scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 THEN 0 ELSE scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking END,
                    spositiontaking = @spos,
                    @mapos1 = CASE WHEN @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking THEN scs.spositiontaking-@spos ELSE cs.mpositiontaking+cs.apositiontaking END,
                    @maxmapos = CASE WHEN mcs.mpositiontaking>mco.maxpositiontaking THEN mco.maxpositiontaking ELSE mcs.mpositiontaking END,
                    @mapos2 = CASE WHEN @mapos1>@maxmapos THEN @maxmapos ELSE @mapos1 END,
                    @mapos = CASE WHEN @mapos2<mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
                    @mpos = CASE WHEN @mapos-cs.apositiontaking<0 THEN 0 ELSE @mapos-cs.apositiontaking END,
                    mpositiontaking = @mpos,
                    @apos = CASE WHEN cs.apositiontaking + @mpos>@mapos THEN @mapos-@mpos ELSE cs.apositiontaking END,
                    apositiontaking = CASE WHEN @apos<aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
            FROM 
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.srecommend=@srecommend AND mb.roleid=1
                INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend  AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype
                INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend  AND mco.sporttype=cs.sporttype AND mco.bettype=cs.bettype
                INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype
            WHERE cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
                and cs.sporttype = 201
                
            RETURN
        END--end mode = 'finance'
        
        IF @mode = 'virtual-sports'
        BEGIN
            --s1=min(s1,s4-m3) if i=0
            UPDATE cs
               SET cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.srecommend = @srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs.sporttype
                                                  AND scs.bettype = cs.bettype
             WHERE cs.isautopositiontaking = 0
               AND mcs.isautopositiontaking = 0 
               AND scs.spositiontaking - mcs.mpositiontaking < cs.spositiontaking
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype

            --check agent min
            --a1=max(a1,n2)
            UPDATE cs
               SET apositiontaking = aco.minpositiontaking
                 , cs.mpositiontaking =
                     CASE
                       WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking
                       ELSE cs.mpositiontaking
                     END
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.srecommend = @srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.apositiontaking < aco.minpositiontaking
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype


            --check agent max
            --a1=min(a1,l2)
            UPDATE cs
               SET apositiontaking = aco.maxpositiontaking
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.srecommend = @srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.apositiontaking > aco.maxpositiontaking
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype


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
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend
                                                  AND acs.sporttype = cs.sporttype
                                                  AND acs.bettype = cs.bettype
             WHERE c.srecommend = @srecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND (acs.isautompositiontaking = 1
                    OR cs.isautompositiontaking = 1
                   )
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype


            --check master min
            --m1=max(m1,n3-a1)
            UPDATE cs
               SET mpositiontaking = mco.minpositiontaking - cs.apositiontaking
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.srecommend = @srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                                   AND mco.sporttype = cs.sporttype
                                                   AND mco.bettype = cs.bettype
             WHERE cs.apositiontaking + cs.mpositiontaking < mco.minpositiontaking
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype


            --check master max
            UPDATE cs
               SET @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mpos =
                     CASE
                       WHEN @maxmapos - cs.apositiontaking < 0 THEN 0
                       ELSE @maxmapos - cs.apositiontaking
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
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.srecommend = @srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                                   AND mco.sporttype = cs.sporttype 
                                                   AND mco.bettype = cs.bettype
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype=cs.bettype
             WHERE cs.apositiontaking + cs.mpositiontaking > mco.maxpositiontaking
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype

            --recal autopos
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
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype
        INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs.sporttype
                                                  AND scs.bettype = cs.bettype
             WHERE c.srecommend = @srecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND (cs.isautopositiontaking = 1
                    OR mcs.isautopositiontaking = 1
                   )
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype

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
             WHERE cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype


            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
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
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > @maxmapos THEN @maxmapos
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking
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
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.srecommend = @srecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs.sporttype
                                                  AND scs.bettype = cs.bettype
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                                   AND mco.sporttype = cs.sporttype
                                                   AND mco.bettype = cs.bettype
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.spositiontaking + cs.apositiontaking + cs.mpositiontaking > scs.spositiontaking
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype

            RETURN

        END-- END mode = 'virtual-sports'


        IF @mode = 'LiveCasino'
        BEGIN        
            --s1=min(s1,s4-m3) if i=0 & syncLC = 1
            UPDATE cs
               SET cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype
        INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                   AND scs.sporttype = cs.sporttype
                                                   AND scs.bettype = cs.bettype
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101
               AND (mcs.isautopositiontaking = 0
                    OR cs.isautopositiontaking = 0
                   )
               AND scs.spositiontaking - mcs.mpositiontaking < cs.spositiontaking


            --check agent min
            --a1=max(a1,n2)
            --m1=min(m3-n2,m1)
            UPDATE cs
               SET cs.apositiontaking = aco.minpositiontaking
                 , cs.mpositiontaking =
                     CASE
                       WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking
                       ELSE cs.mpositiontaking
                     END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
        INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend
                                                    AND aco.sporttype = cs.sporttype
                                                    AND aco.bettype = cs.bettype
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101
               AND cs.apositiontaking < aco.minpositiontaking


            --Recal AUTO MPT m1=min(m3-a1,u2)
            UPDATE cs
               SET cs.mpositiontaking =
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
              FROM CustSettingGame cs WITH(NOLOCK)
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype
        INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend
                                                   AND acs.sporttype = cs.sporttype
                                                   AND acs.bettype = cs.bettype
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101
               AND (cs.isautompositiontaking = 1
                    OR acs.isautompositiontaking = 1
                   )


            --check master min
            --m1=max(m1,n3-a1)
            UPDATE cs
               SET cs.mpositiontaking =
                     CASE
                       WHEN cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking THEN mco.minpositiontaking - cs.apositiontaking
                       ELSE cs.mpositiontaking
                     END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend
                                                    AND mco.sporttype = cs.sporttype
                                                    AND mco.bettype = cs.bettype
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101


            --recal autopos
            UPDATE cs
               SET cs.spositiontaking =
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
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype 
        INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                   AND scs.sporttype = cs.sporttype
                                                   AND scs.bettype = cs.bettype 
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101 
               AND (cs.isautopositiontaking = 1
                    OR mcs.isautopositiontaking = 1
                   )


            --check super min
            --s1=max(n4-m1-a1,s1)
            UPDATE cs
               SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
        INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend
                                                    AND sco.sporttype = cs.sporttype
                                                    AND sco.bettype = cs.bettype
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101 
               AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking


            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
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
                 , cs.spositiontaking = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
                       ELSE cs.mpositiontaking + cs.apositiontaking
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > mcs.mpositiontaking THEN mcs.mpositiontaking
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - cs.apositiontaking < 0 THEN 0
                       ELSE @mapos - cs.apositiontaking
                     END
                 , cs.mpositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN @mpos + cs.apositiontaking > @mapos THEN @mapos - @mpos
                       ELSE cs.apositiontaking
                     END
                 , cs.apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype 
        INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend
                                                    AND mco.sporttype = cs.sporttype
                                                    AND mco.bettype = cs.bettype
        INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend
                                                    AND aco.sporttype = cs.sporttype
                                                    AND aco.bettype = cs.bettype 
        INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                   AND scs.sporttype = cs.sporttype
                                                   AND scs.bettype = cs.bettype 
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101
               AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking > scs.spositiontaking

            RETURN

        END--end mode = 'LiveCasino'        

        IF @mode = 'Keno' OR @mode = 'GoldDeluxe'
        BEGIN        
            --s1=min(s1,s4-m3) if i=0
            UPDATE cs
               SET cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
              FROM CustSettingGame cs 
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype
        INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                   AND scs.sporttype = cs.sporttype
                                                   AND scs.bettype = cs.bettype
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype
               AND (mcs.isautopositiontaking = 0
                    OR cs.isautopositiontaking = 0
                   )
               AND scs.spositiontaking - mcs.mpositiontaking < cs.spositiontaking


            --check agent min
            --a1=max(a1,n2)
            --m1=min(m3-n2,m1)
            UPDATE cs
               SET cs.apositiontaking = aco.minpositiontaking
                 , cs.mpositiontaking =
                     CASE
                       WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking
                       ELSE cs.mpositiontaking
                     END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
        INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend
                                                    AND aco.sporttype = cs.sporttype
                                                    AND aco.bettype = cs.bettype
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype
               AND cs.apositiontaking < aco.minpositiontaking


            --Recal AUTO MPT m1=min(m3-a1,u2)
            UPDATE cs
               SET cs.mpositiontaking =
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
              FROM CustSettingGame cs WITH(NOLOCK)
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype
        INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend
                                                   AND acs.sporttype = cs.sporttype
                                                   AND acs.bettype = cs.bettype
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype
               AND (cs.isautompositiontaking = 1
                    OR acs.isautompositiontaking = 1
                   )


            --check master min
            --m1=max(m1,n3-a1)
            UPDATE cs
               SET cs.mpositiontaking =
                     CASE
                       WHEN cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking THEN mco.minpositiontaking - cs.apositiontaking
                       ELSE cs.mpositiontaking
                     END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend
                                                    AND mco.sporttype = cs.sporttype
                                                    AND mco.bettype = cs.bettype
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype 


            --recal autopos
            UPDATE cs
               SET cs.spositiontaking =
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
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype 
        INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                   AND scs.sporttype = cs.sporttype
                                                   AND scs.bettype = cs.bettype 
              WHERE ci.srecommend = @srecommend
                AND ci.roleid = 1
                AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype 
               AND (cs.isautopositiontaking = 1
                    OR mcs.isautopositiontaking = 1
                   )


            --check super min
            --s1=max(n4-m1-a1,s1)
            UPDATE cs
               SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
        INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend
                                                    AND sco.sporttype = cs.sporttype
                                                    AND sco.bettype = cs.bettype
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype 
               AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking


            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
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
                 , cs.spositiontaking = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
                       ELSE cs.mpositiontaking + cs.apositiontaking
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > mcs.mpositiontaking THEN mcs.mpositiontaking
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - cs.apositiontaking < 0 THEN 0
                       ELSE @mapos - cs.apositiontaking
                     END
                 , cs.mpositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN @mpos + cs.apositiontaking > @mapos THEN @mapos - @mpos
                       ELSE cs.apositiontaking
                     END
                 , cs.apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype 
        INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend
                                                    AND mco.sporttype = cs.sporttype
                                                    AND mco.bettype = cs.bettype
        INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend
                                                    AND aco.sporttype = cs.sporttype
                                                    AND aco.bettype = cs.bettype 
        INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                   AND scs.sporttype = cs.sporttype
                                                   AND scs.bettype = cs.bettype 
             WHERE ci.srecommend = @srecommend
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype
               AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking > scs.spositiontaking


            RETURN

        END--end mode = 'Keno'
    END

    
    --UPDATE min/max pt ON master
    ELSE IF @roleid = 3
    BEGIN    
        IF @mode = 'number'
        BEGIN
            --check agent min/max
            --a1=max(a1,n2)            
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET apositiontaking = aco.minpositiontaking
                 , cs3.mpositiontaking =
                     CASE
                       WHEN cs3.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking
                       ELSE cs3.mpositiontaking
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.apositiontaking < aco.minpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET alivepositiontaking = aco.minlivepositiontaking
                 , cs3.mlivepositiontaking =
                     CASE
                       WHEN cs3.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking THEN mcs.mlivepositiontaking - aco.minlivepositiontaking
                       ELSE cs3.mlivepositiontaking
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.alivepositiontaking < aco.minlivepositiontaking


            --a1=min(a1,l2)             
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET apositiontaking = aco.maxpositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.apositiontaking > aco.maxpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET alivepositiontaking = aco.maxlivepositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.alivepositiontaking > aco.maxlivepositiontaking


            -- UPDATE m2,a2 WHEN m2+a2>l3
            -- m2=max(min(m3,l3)-a2,0)
            -- a2=min(min(m3,l3)-m2,a2,n2)
            --v161
            UPDATE c3d WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mpos =
                     CASE
                       WHEN @maxmapos - c3d.apositiontaking < 0 THEN 0
                       ELSE @maxmapos - c3d.apositiontaking
                     END
                 , mpositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN c3d.apositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                       ELSE c3d.apositiontaking
                     END
                 , apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM custsetting3rd c3d
        INNER JOIN custinfo mb WITH(NOLOCK) ON c3d.custid    = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid     = 2
                                           AND mb.Enabled    = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid    = @mrecommend
                                                  AND mcs.sporttype = c3d.sporttype
                                                  AND mcs.bettype   = c3d.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid    = @mrecommend
                                                   AND mco.sporttype = c3d.sporttype
                                                   AND mco.bettype   = c3d.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid    = mb.recommend
                                                   AND aco.sporttype = c3d.sporttype
                                                   AND aco.bettype   = c3d.bettype
             WHERE c3d.sporttype = 161
               AND c3d.apositiontaking + c3d.mpositiontaking > mco.maxpositiontaking


            UPDATE c3d WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
                       ELSE mcs.mlivepositiontaking
                     END
                 , @mpos =
                     CASE
                       WHEN @maxmapos - c3d.alivepositiontaking < 0 THEN 0
                       ELSE @maxmapos - c3d.alivepositiontaking
                     END
                 , mlivepositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN c3d.alivepositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                       ELSE c3d.alivepositiontaking
                     END
                 , alivepositiontaking =
                     CASE
                       WHEN @apos < aco.minlivepositiontaking THEN aco.minlivepositiontaking
                       ELSE @apos
                     END
              FROM custsetting3rd c3d
        INNER JOIN custinfo mb WITH(NOLOCK) ON c3d.custid    = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid     = 2
                                           AND mb.Enabled    = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid    = @mrecommend
                                                  AND mcs.sporttype = c3d.sporttype
                                                  AND mcs.bettype   = c3d.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid    = @mrecommend
                                                   AND mco.sporttype = c3d.sporttype
                                                   AND mco.bettype   = c3d.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid    = mb.recommend
                                                   AND aco.sporttype = c3d.sporttype
                                                   AND aco.bettype   = c3d.bettype
             WHERE c3d.sporttype = 161
               AND c3d.bettype IN (85, 86, 87, 89, 90)
               AND c3d.alivepositiontaking + c3d.mlivepositiontaking > mco.maxlivepositiontaking


            --um2=min(m3,l3) if um2>l3
            --v161
            UPDATE c3d WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , autompositiontaking = @maxmapos
              FROM custsetting3rd c3d
        INNER JOIN custinfo mb WITH(NOLOCK) ON c3d.custid    = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid     = 2
                                           AND mb.Enabled    = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid    = @mrecommend
                                                  AND mcs.sporttype = c3d.sporttype
                                                  AND mcs.bettype   = c3d.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid    = @mrecommend
                                                   AND mco.sporttype = c3d.sporttype
                                                   AND mco.bettype   = c3d.bettype
             WHERE c3d.sporttype = 161
               AND c3d.isautompositiontaking = 1
               AND c3d.autompositiontaking > mco.maxpositiontaking


            UPDATE c3d WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
                       ELSE mcs.mlivepositiontaking
                     END
                 , autolivempositiontaking = @maxmapos
              FROM custsetting3rd c3d
        INNER JOIN custinfo mb WITH(NOLOCK) ON c3d.custid    = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid     = 2
                                           AND mb.Enabled    = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid    = @mrecommend
                                                  AND mcs.sporttype = c3d.sporttype
                                                  AND mcs.bettype   = c3d.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid    = @mrecommend
                                                   AND mco.sporttype = c3d.sporttype
                                                   AND mco.bettype   = c3d.bettype
             WHERE c3d.sporttype = 161
               AND c3d.bettype IN (85, 86, 87, 89, 90)
               AND c3d.isautolivempositiontaking = 1
               AND c3d.autolivempositiontaking > mco.maxlivepositiontaking


            --Recal AUTO MPT m1=min(m3-a1,u2)
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK) 
               SET mpositiontaking =
                     CASE
                       WHEN mcs.mpositiontaking - cs3.apositiontaking >
                              CASE
                                WHEN cs3.isautompositiontaking = 1 THEN cs3.autompositiontaking
                                ELSE acs.autompositiontaking
                              END
                         THEN CASE
                                WHEN cs3.isautompositiontaking = 1 THEN cs3.autompositiontaking
                                ELSE acs.autompositiontaking
                              END
                       ELSE mcs.mpositiontaking - cs3.apositiontaking
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custsetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend
                                                  AND acs.sporttype = cs3.sporttype
                                                  AND acs.bettype = cs3.bettype
             WHERE c.mrecommend = @mrecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs3.sporttype = 161
               AND (acs.isautompositiontaking = 1
                    OR cs3.isautompositiontaking = 1
                   )


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK) 
               SET mlivepositiontaking =
                     CASE
                       WHEN mcs.mlivepositiontaking - cs3.alivepositiontaking >
                              CASE
                                WHEN cs3.isautolivempositiontaking = 1 THEN cs3.autolivempositiontaking
                                ELSE acs.autolivempositiontaking
                              END
                         THEN CASE
                                WHEN cs3.isautolivempositiontaking = 1 THEN cs3.autolivempositiontaking
                                ELSE acs.autolivempositiontaking
                              END
                       ELSE mcs.mlivepositiontaking - cs3.alivepositiontaking
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custsetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend
                                                  AND acs.sporttype = cs3.sporttype
                                                  AND acs.bettype = cs3.bettype
             WHERE c.mrecommend = @mrecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND (acs.isautolivempositiontaking = 1
                    OR cs3.isautolivempositiontaking = 1
                   )


            --check master min/max
            --m1=n3-a1
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET mpositiontaking = mco.minpositiontaking - cs3.apositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                                   AND mco.sporttype = cs3.sporttype
                                                   AND mco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.apositiontaking + cs3.mpositiontaking < mco.minpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET mlivepositiontaking = mco.minlivepositiontaking - cs3.alivepositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                                   AND mco.sporttype = cs3.sporttype
                                                   AND mco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.alivepositiontaking + cs3.mlivepositiontaking < mco.minlivepositiontaking


            -- UPDATE m1,a1 WHEN m1+a1>l3
            -- m1=min(m3,l3)-a1
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mpos =
                     CASE
                       WHEN @maxmapos - cs3.apositiontaking < 0 THEN 0
                       ELSE @maxmapos - cs3.apositiontaking
                     END
                 , mpositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN cs3.apositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                       ELSE cs3.apositiontaking
                     END
                 , apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                                   AND mco.sporttype = cs3.sporttype
                                                   AND mco.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.apositiontaking + cs3.mpositiontaking > mco.maxpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
                       ELSE mcs.mlivepositiontaking
                     END
                 , @mpos =
                     CASE
                       WHEN @maxmapos - cs3.alivepositiontaking < 0 THEN 0
                       ELSE @maxmapos - cs3.alivepositiontaking
                     END
                 , mlivepositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN cs3.alivepositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                       ELSE cs3.alivepositiontaking
                     END
                 , alivepositiontaking =
                     CASE
                       WHEN @apos < aco.minlivepositiontaking THEN aco.minlivepositiontaking
                       ELSE @apos
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                                   AND mco.sporttype = cs3.sporttype
                                                   AND mco.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.alivepositiontaking + cs3.mlivepositiontaking > mco.maxlivepositiontaking


            --recal autopos
            -- s1=min(s4-m1-a1,u)
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET spositiontaking =
                     CASE
                       WHEN scs.spositiontaking - cs3.mpositiontaking - cs3.apositiontaking >
                              CASE
                                WHEN cs3.isautopositiontaking = 1 THEN cs3.autopositiontaking
                                ELSE mcs.autopositiontaking
                              END
                         THEN CASE
                                WHEN cs3.isautopositiontaking = 1 THEN cs3.autopositiontaking
                                ELSE mcs.autopositiontaking
                              END
                       ELSE scs.spositiontaking - cs3.mpositiontaking - cs3.apositiontaking
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs3.sporttype
                                                  AND scs.bettype = cs3.bettype
             WHERE c.mrecommend = @mrecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs3.sporttype = 161
               AND (cs3.isautopositiontaking = 1
                    OR mcs.isautopositiontaking = 1
                   )


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK) 
               SET slivepositiontaking =
                     CASE
                       WHEN scs.slivepositiontaking - cs3.mlivepositiontaking - cs3.alivepositiontaking >
                              CASE
                                WHEN cs3.isautolivepositiontaking = 1 THEN cs3.autolivepositiontaking
                                ELSE mcs.autolivepositiontaking
                              END
                         THEN CASE
                                WHEN cs3.isautolivepositiontaking = 1 THEN cs3.autolivepositiontaking
                                ELSE mcs.autolivepositiontaking
                              END
                       ELSE scs.slivepositiontaking - cs3.mlivepositiontaking - cs3.alivepositiontaking
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs3.sporttype
                                                  AND scs.bettype = cs3.bettype
             WHERE c.mrecommend = @mrecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND (cs3.isautolivepositiontaking = 1
                    OR mcs.isautolivepositiontaking = 1
                   )    


            --check super min/max WHEN a1+m1+s1<n4
            -- s1=n4-m1-a1
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET spositiontaking = sco.minpositiontaking - cs3.mpositiontaking - cs3.apositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend
                                                   AND sco.sporttype = cs3.sporttype
                                                   AND sco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.apositiontaking + cs3.mpositiontaking + cs3.spositiontaking < sco.minpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET slivepositiontaking = sco.minlivepositiontaking - cs3.mlivepositiontaking-cs3.alivepositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend
                                                   AND sco.sporttype = cs3.sporttype
                                                   AND sco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.alivepositiontaking + cs3.mlivepositiontaking + cs3.slivepositiontaking < sco.minlivepositiontaking


            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
            --s1=max(0,s4-m1-a1)
            --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
            --@maxmapos=min(m3,l3)
            --@mapos2=min(@mapos1,@maxmapos)
            --@mapos=max(@mapos2,n3)
            --m1=max(0,@mapos-a1)
            --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET @spos =
                     CASE
                       WHEN scs.spositiontaking - cs3.mpositiontaking - cs3.apositiontaking < 0 THEN 0
                       ELSE scs.spositiontaking - cs3.mpositiontaking - cs3.apositiontaking
                     END
                 , spositiontaking = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + cs3.mpositiontaking + cs3.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos
                       ELSE cs3.mpositiontaking + cs3.apositiontaking
                     END
                 , @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > @maxmapos THEN @maxmapos
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - cs3.apositiontaking < 0 THEN 0
                       ELSE @mapos - cs3.apositiontaking
                     END
                 , mpositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN cs3.apositiontaking + @mpos > @mapos THEN @mapos - @mpos
                       ELSE cs3.apositiontaking
                     END
                 , apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs3.sporttype
                                                  AND scs.bettype = cs3.bettype
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                                   AND mco.sporttype = cs3.sporttype
                                                   AND mco.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
            WHERE cs3.spositiontaking + cs3.apositiontaking + cs3.mpositiontaking > scs.spositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET @spos =
                     CASE
                       WHEN scs.slivepositiontaking - cs3.mlivepositiontaking - cs3.alivepositiontaking < 0 THEN 0
                       ELSE scs.slivepositiontaking - cs3.mlivepositiontaking - cs3.alivepositiontaking
                     END
                 , slivepositiontaking = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + cs3.mlivepositiontaking + cs3.alivepositiontaking > scs.slivepositiontaking THEN scs.slivepositiontaking - @spos
                       ELSE cs3.mlivepositiontaking + cs3.alivepositiontaking
                     END
                 , @maxmapos =
                     CASE
                       WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
                       ELSE mcs.mlivepositiontaking
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > @maxmapos THEN @maxmapos
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mco.minlivepositiontaking THEN mco.minlivepositiontaking
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - cs3.alivepositiontaking < 0 THEN 0
                       ELSE @mapos - cs3.alivepositiontaking
                     END
                 , mlivepositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN cs3.alivepositiontaking + @mpos > @mapos THEN @mapos - @mpos
                       ELSE cs3.alivepositiontaking
                     END
                 , alivepositiontaking =
                     CASE
                       WHEN @apos < aco.minlivepositiontaking THEN aco.minlivepositiontaking
                       ELSE @apos
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs3.sporttype
                                                  AND scs.bettype = cs3.bettype
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
                --INNER JOIN custoverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend  AND sco.sporttype = cs3.sporttype AND sco.bettype = cs3.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                                   AND mco.sporttype = cs3.sporttype
                                                   AND mco.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = 161
               AND cs3.bettype IN (85, 86, 87, 89, 90)
               AND cs3.slivepositiontaking + cs3.alivepositiontaking + cs3.mlivepositiontaking > scs.slivepositiontaking

        END

        
        IF @mode = 'horse'
        BEGIN
            --check agent min/max
            --a1=max(a1,n2)
            UPDATE cs
               SET apositiontaking = aco.minpositiontaking
                 , cs.mpositiontaking =
                     CASE
                       WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking
                       ELSE cs.mpositiontaking
                     END
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.apositiontaking < aco.minpositiontaking
               AND cs.sporttype IN (151, 152, 153)


            --a1=min(a1,l2) 
            UPDATE cs WITH(ROWLOCK, UPDLOCK)
               SET apositiontaking = aco.maxpositiontaking
              FROM CustSetting3rd cs 
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.apositiontaking > aco.maxpositiontaking
               AND cs.sporttype IN (151, 152, 153)


            -- UPDATE m2,a2 WHEN m2+a2>l3
            -- m2=max(min(m3,l3)-a2,0)
            -- a2=min(min(m3,l3)-m2,a2,n2)
            UPDATE cs
               SET @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mpos =
                     CASE
                       WHEN @maxmapos - cs.apositiontaking < 0 THEN 0
                       ELSE @maxmapos - cs.apositiontaking
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
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid     = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid     = 2
                                           AND mb.Enabled    = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid    = @mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype   = cs.bettype
        INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid    = @mrecommend
                                                   AND mco.sporttype = cs.sporttype
                                                   AND mco.bettype   = cs.bettype
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid    = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype   = cs.bettype
             WHERE cs.apositiontaking + cs.mpositiontaking > mco.maxpositiontaking
               AND cs.sporttype IN (151, 152, 153)


            --um2=min(m3,l3) if um2>l3
            UPDATE cs WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , autompositiontaking = @maxmapos
              FROM custsetting3rd cs
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid     = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid     = 2
                                           AND mb.Enabled    = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid    = @mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype   = cs.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid    = @mrecommend
                                                   AND mco.sporttype = cs.sporttype
                                                   AND mco.bettype   = cs.bettype
             WHERE cs.isautompositiontaking = 1
               AND cs.autompositiontaking > mco.maxpositiontaking
               AND cs.sporttype IN (151, 152, 153)


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
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend
                                                  AND acs.sporttype = cs.sporttype
                                                  AND acs.bettype = cs.bettype
             WHERE c.mrecommend = @mrecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND (acs.isautompositiontaking = 1
                    OR cs.isautompositiontaking = 1)
               AND cs.sporttype IN (151,152,153)

            --check master min/max
            --m1=n3-a1
            UPDATE cs
               SET mpositiontaking = mco.minpositiontaking - cs.apositiontaking
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                                   AND mco.sporttype = cs.sporttype
                                                   AND mco.bettype = cs.bettype
             WHERE cs.apositiontaking + cs.mpositiontaking < mco.minpositiontaking
               AND cs.sporttype IN (151, 152, 153)


            -- UPDATE m1,a1 WHEN m1+a1>l3
            -- m1=min(m3,l3)-a1
            UPDATE cs
               SET @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mpos =
                     CASE
                       WHEN @maxmapos - cs.apositiontaking < 0 THEN 0
                       ELSE @maxmapos - cs.apositiontaking
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
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                                   AND mco.sporttype = cs.sporttype
                                                   AND mco.bettype = cs.bettype
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.apositiontaking + cs.mpositiontaking > mco.maxpositiontaking
               AND cs.sporttype IN (151, 152, 153)


            --recal autopos
            -- s1=min(s4-m1-a1,u)
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
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs.sporttype
                                                  AND scs.bettype = cs.bettype
             WHERE c.mrecommend = @mrecommend
               AND c.roleid = 1
               AND c.Enabled = 1
               AND (cs.isautopositiontaking = 1
                    OR mcs.isautopositiontaking = 1
                   )
               AND cs.sporttype IN (151, 152, 153)


            --check super min/max WHEN a1+m1+s1<n4
            -- s1=n4-m1-a1
            UPDATE cs
               SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustOverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend
                                                   AND sco.sporttype = cs.sporttype
                                                   AND sco.bettype = cs.bettype
             WHERE cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
               AND cs.sporttype IN (151, 152, 153)


            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
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
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > @maxmapos THEN @maxmapos
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking
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
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs.sporttype
                                                  AND scs.bettype = cs.bettype
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                                   AND mco.sporttype = cs.sporttype
                                                   AND mco.bettype = cs.bettype
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.spositiontaking + cs.apositiontaking + cs.mpositiontaking > scs.spositiontaking
               AND cs.sporttype IN (151, 152, 153)

        END
        
        IF @mode = 'virtual-sports'
        BEGIN
            --check agent min/max
            --a1=max(a1,n2)
            UPDATE cs
               SET apositiontaking = aco.minpositiontaking
                 , cs.mpositiontaking =
                     CASE
                       WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking
                       ELSE cs.mpositiontaking
                     END
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.apositiontaking < aco.minpositiontaking
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype


            --a1=min(a1,l2) 
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK) 
               SET apositiontaking = aco.maxpositiontaking
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = @sporttype
               AND cs3.apositiontaking > aco.maxpositiontaking


            -- UPDATE m2,a2 WHEN m2+a2>l3
            -- m2=max(min(m3,l3)-a2,0)
            -- a2=min(min(m3,l3)-m2,a2,n2)
            UPDATE c3d WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mpos =
                     CASE
                       WHEN @maxmapos - c3d.apositiontaking < 0 THEN 0
                       ELSE @maxmapos - c3d.apositiontaking
                     END
                 , mpositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN c3d.apositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                       ELSE c3d.apositiontaking
                     END
                 , apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM custsetting3rd c3d
        INNER JOIN custinfo mb WITH(NOLOCK) ON c3d.custid    = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid     = 2
                                           AND mb.Enabled    = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid    = @mrecommend
                                                  AND mcs.sporttype = c3d.sporttype
                                                  AND mcs.bettype   = c3d.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid    = @mrecommend
                                                   AND mco.sporttype = c3d.sporttype
                                                   AND mco.bettype   = c3d.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid    = mb.recommend
                                                   AND aco.sporttype = c3d.sporttype
                                                   AND aco.bettype   = c3d.bettype
             WHERE c3d.sporttype = @sporttype
               AND c3d.apositiontaking + c3d.mpositiontaking > mco.maxpositiontaking


            --um2=min(m3,l3) if um2>l3
            UPDATE c3d WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , autompositiontaking = @maxmapos
              FROM custsetting3rd c3d
        INNER JOIN custinfo mb WITH(NOLOCK) ON c3d.custid    = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid     = 2
                                           AND mb.Enabled    = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid    = @mrecommend
                                                  AND mcs.sporttype = c3d.sporttype
                                                  AND mcs.bettype   = c3d.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid    = @mrecommend
                                                   AND mco.sporttype = c3d.sporttype
                                                   AND mco.bettype   = c3d.bettype
             WHERE c3d.sporttype = @sporttype
               AND c3d.isautompositiontaking = 1
               AND c3d.autompositiontaking > mco.maxpositiontaking

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
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                                          AND c.mrecommend = @mrecommend
                                          AND c.roleid = 1
                                          AND c.Enabled = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend
                                                  AND acs.sporttype = cs.sporttype
                                                  AND acs.bettype = cs.bettype
             WHERE (acs.isautompositiontaking = 1
                    OR cs.isautompositiontaking = 1
                   )
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype


            --check master min/max
            --m1=n3-a1
            UPDATE cs
               SET mpositiontaking = mco.minpositiontaking - cs.apositiontaking
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                                   AND mco.sporttype = cs.sporttype
                                                   AND mco.bettype = cs.bettype
             WHERE cs.apositiontaking + cs.mpositiontaking < mco.minpositiontaking
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype


            -- UPDATE m1,a1 WHEN m1+a1>l3
            -- m1=min(m3,l3)-a1
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                       ELSE mcs.mpositiontaking
                     END
                 , @mpos =
                     CASE
                       WHEN @maxmapos - cs3.apositiontaking < 0 THEN 0
                       ELSE @maxmapos - cs3.apositiontaking
                     END
                 , mpositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN cs3.apositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                       ELSE cs3.apositiontaking
                     END
                 , apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM custsetting3rd cs3
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                  AND mcs.sporttype = cs3.sporttype
                                                  AND mcs.bettype = cs3.bettype
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                                   AND mco.sporttype = cs3.sporttype
                                                   AND mco.bettype = cs3.bettype
        INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                                   AND aco.sporttype = cs3.sporttype
                                                   AND aco.bettype = cs3.bettype
             WHERE cs3.sporttype = @sporttype
               AND cs3.apositiontaking + cs3.mpositiontaking > mco.maxpositiontaking


            --recal autopos
            -- s1=min(s4-m1-a1,u)
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
               FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                                          AND c.mrecommend = @mrecommend
                                          AND c.roleid = 1
                                          AND c.Enabled = 1
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs.sporttype
                                                  AND scs.bettype = cs.bettype
             WHERE (cs.isautopositiontaking = 1
                    OR mcs.isautopositiontaking = 1
                   )
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype
            
            --check super min/max WHEN a1+m1+s1<n4
            -- s1=n4-m1-a1
            UPDATE cs
               SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
              FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
        INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                           AND mb.mrecommend = @mrecommend
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN CustOverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend
                                                   AND sco.sporttype = cs.sporttype
                                                   AND sco.bettype = cs.bettype
             WHERE cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype


            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
            --s1=max(0,s4-m1-a1)
            --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)    
            --@mapos2=min(@mapos1,m3)
            --@mapos=max(@mapos2,n3)
            --m1=max(0,@mapos-a1)
            --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
            UPDATE cs
               SET @spos =
                     CASE
                       WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0
                       ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
                     END
                 , cs.spositiontaking = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos
                       ELSE cs.mpositiontaking + cs.apositiontaking
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 < mcs.mpositiontaking THEN @mapos1
                       ELSE mcs.mpositiontaking
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - cs.apositiontaking < 0 THEN 0
                       ELSE @mapos - cs.apositiontaking
                     END
                 , cs.mpositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos
                       ELSE cs.apositiontaking
                     END
                 , cs.apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM CustSetting3rd cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid  = ci.custid
                                           AND ci.mrecommend = @mrecommend
                                           AND ci.roleid = 1
                                           AND ci.Enabled = 1
        INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                  AND scs.sporttype = cs.sporttype
                                                  AND scs.bettype = cs.bettype
        INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                  AND mcs.sporttype = cs.sporttype
                                                  AND mcs.bettype = cs.bettype
        INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = ci.mrecommend
                                                   AND mco.sporttype = cs.sporttype
                                                   AND mco.bettype = cs.bettype
        INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = ci.recommend
                                                   AND aco.sporttype = cs.sporttype
                                                   AND aco.bettype = cs.bettype
             WHERE cs.sporttype = @sporttype
               AND cs.bettype = @bettype
               AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking

        END

        IF @mode = 'LiveCasino'
        BEGIN                        
            --check agent min/max
            --a1=max(a1,n2)
            UPDATE cs
               SET cs.apositiontaking = aco.minpositiontaking
                 , cs.mpositiontaking =
                     CASE
                       WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking
                       ELSE cs.mpositiontaking
                     END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend
                                                AND cs.sporttype = aco.sporttype
                                                AND cs.bettype = aco.bettype
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101
               AND cs.apositiontaking < aco.minpositiontaking


            --Recal AUTO MPT m1=min(m3-a1,u2)
            UPDATE cs
               SET cs.mpositiontaking =
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
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype 
        INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend
                                                   AND acs.sporttype = cs.sporttype
                                                   AND acs.bettype = cs.bettype 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101 
               AND (acs.isautompositiontaking = 1
                    OR cs.isautompositiontaking = 1
                   ) 


            --check master min/max
            --m1=n3-a1
            UPDATE cs
               SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype
        INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @custid
                                                    AND mco.sporttype = cs.sporttype
                                                    AND mco.bettype = cs.bettype
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101 
               AND cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking


            --recal autopos
            -- s1=min(s4-m1-a1,u)
            UPDATE cs
               SET cs.spositiontaking =
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
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
        INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                   AND scs.sporttype = cs.sporttype
                                                   AND scs.bettype = cs.bettype 
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101
               AND (cs.isautopositiontaking = 1
                    OR mcs.isautopositiontaking = 1
                   )


            --check super min/max WHEN a1+m1+s1<n4
            -- s1=n4-m1-a1
            UPDATE cs
               SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend
                                                    AND sco.sporttype = cs.sporttype
                                                    AND sco.bettype = cs.bettype 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101 
               AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking < sco.minpositiontaking


            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
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
                 , cs.spositiontaking = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos
                       ELSE cs.mpositiontaking + cs.apositiontaking
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 < mcs.mpositiontaking THEN @mapos1
                       ELSE mcs.mpositiontaking
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - cs.apositiontaking < 0 THEN 0
                       ELSE @mapos - cs.apositiontaking
                     END
                 , cs.mpositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos
                       ELSE cs.apositiontaking
                     END
                 , cs.apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                   AND scs.sporttype = cs.sporttype
                                                   AND scs.bettype = cs.bettype
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype 
        INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend
                                                    AND mco.sporttype = cs.sporttype
                                                    AND mco.bettype = cs.bettype
        INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend
                                                    AND aco.sporttype = cs.sporttype
                                                    AND aco.bettype = cs.bettype
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101 
               AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking

        END
        
        IF @mode = 'Keno' OR @mode = 'GoldDeluxe'
        BEGIN                        
            --check agent min/max
            --a1=max(a1,n2)
            UPDATE cs
               SET cs.apositiontaking = aco.minpositiontaking
                 , cs.mpositiontaking =
                     CASE
                       WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking
                       ELSE cs.mpositiontaking
                     END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend
                                                AND cs.sporttype = aco.sporttype
                                                AND cs.bettype = aco.bettype
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype
               AND cs.apositiontaking < aco.minpositiontaking


            --Recal AUTO MPT m1=min(m3-a1,u2)
            UPDATE cs
               SET cs.mpositiontaking =
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
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype 
        INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend
                                                   AND acs.sporttype = cs.sporttype
                                                   AND acs.bettype = cs.bettype 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype 
               AND (acs.isautompositiontaking = 1
                    OR cs.isautompositiontaking = 1
                   )


            --check master min/max
            --m1=n3-a1
            UPDATE cs
               SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype 
        INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @custid
                                                    AND mco.sporttype = cs.sporttype
                                                    AND mco.bettype = cs.bettype
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype 
               AND cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking 


            --recal autopos
            -- s1=min(s4-m1-a1,u)
            UPDATE cs
               SET cs.spositiontaking =
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
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                   AND scs.sporttype = cs.sporttype
                                                   AND scs.bettype = cs.bettype 
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype
               AND (cs.isautopositiontaking = 1
                    OR mcs.isautopositiontaking = 1
                   )


            --check super min/max WHEN a1+m1+s1<n4
            -- s1=n4-m1-a1
            UPDATE cs
               SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend
                                                    AND sco.sporttype = cs.sporttype
                                                    AND sco.bettype = cs.bettype 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype 
               AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking < sco.minpositiontaking    


            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
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
                 , cs.spositiontaking = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos
                       ELSE cs.mpositiontaking + cs.apositiontaking
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 < mcs.mpositiontaking THEN @mapos1
                       ELSE mcs.mpositiontaking
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - cs.apositiontaking < 0 THEN 0
                       ELSE @mapos - cs.apositiontaking
                     END
                 , cs.mpositiontaking = @mpos
                 , @apos =
                     CASE
                       WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos
                       ELSE cs.apositiontaking
                     END
                 , cs.apositiontaking =
                     CASE
                       WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                       ELSE @apos
                     END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
        INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend
                                                   AND scs.sporttype = cs.sporttype
                                                   AND scs.bettype = cs.bettype
        INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend
                                                   AND mcs.sporttype = cs.sporttype
                                                   AND mcs.bettype = cs.bettype
        INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend
                                                    AND mco.sporttype = cs.sporttype
                                                    AND mco.bettype = cs.bettype
        INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend
                                                    AND aco.sporttype = cs.sporttype
                                                    AND aco.bettype = cs.bettype
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @sporttype
               AND cs.bettype = @bettype 
               AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking

        END--end Keno
    END
    ELSE IF @roleid = 2
    BEGIN
        IF @mode = 'number'
        BEGIN            
            --check agent min/max
            -- UPDATE a1 WHEN a1<n2
            -- a1=n2
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET 
                apositiontaking = aco.minpositiontaking,
                cs3.mpositiontaking = CASE WHEN cs3.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking-aco.minpositiontaking ELSE cs3.mpositiontaking END
            FROM 
                custsetting3rd cs3 INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=cs3.sporttype AND mcs.bettype=cs3.bettype
                INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs3.sporttype AND aco.bettype=cs3.bettype
            WHERE cs3.sporttype = 161 AND cs3.bettype IN (81,83,86,88) AND cs3.apositiontaking<aco.minpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET 
                alivepositiontaking = aco.minlivepositiontaking,
                cs3.mlivepositiontaking = CASE WHEN cs3.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking THEN mcs.mlivepositiontaking-aco.minlivepositiontaking ELSE cs3.mlivepositiontaking END
            FROM 
                custsetting3rd cs3 INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=cs3.sporttype AND mcs.bettype=cs3.bettype
                INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs3.sporttype AND aco.bettype=cs3.bettype
            WHERE cs3.sporttype=161 AND cs3.bettype IN (85,86,87,89,90) AND cs3.alivepositiontaking<aco.minlivepositiontaking

            -- UPDATE a1 WHEN a1>l2
            -- a1=l2
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET 
                apositiontaking = aco.maxpositiontaking
            FROM 
                custsetting3rd cs3 INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs3.sporttype AND aco.bettype=cs3.bettype
            WHERE cs3.sporttype = 161 AND cs3.bettype IN (81,83,86,88) AND cs3.apositiontaking>aco.maxpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET 
                alivepositiontaking = aco.maxlivepositiontaking
            FROM 
                custsetting3rd cs3 INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs3.sporttype AND aco.bettype=cs3.bettype
            WHERE cs3.sporttype=161 AND cs3.bettype IN (85,86,87,89,90) AND cs3.alivepositiontaking>aco.maxlivepositiontaking

            --Recal AUTO MPT 
            --UPDATE m1=min(m3-a1,u2)
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK) 
            SET mpositiontaking = 
                    CASE WHEN mcs.mpositiontaking-cs3.apositiontaking > CASE WHEN cs3.isautompositiontaking = 1 THEN cs3.autompositiontaking ELSE acs.autompositiontaking END
                        then CASE WHEN cs3.isautompositiontaking = 1 THEN cs3.autompositiontaking ELSE acs.autompositiontaking END
                    else  mcs.mpositiontaking-cs3.apositiontaking END
            from
                custsetting3rd cs3
                INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
                INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=cs3.sporttype AND mcs.bettype=cs3.bettype
                INNER JOIN custsetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend AND acs.sporttype=cs3.sporttype AND acs.bettype=cs3.bettype
            where
                c.recommend = @recommend
                and c.roleid = 1
                and cs3.sporttype = 161
                and cs3.bettype IN (81,83,86,88)
            and (acs.isautompositiontaking = 1 OR cs3.isautompositiontaking = 1)
                
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK) 
            SET mlivepositiontaking =
                    CASE WHEN mcs.mlivepositiontaking-cs3.alivepositiontaking > CASE WHEN cs3.isautolivempositiontaking = 1 THEN cs3.autolivempositiontaking ELSE acs.autolivempositiontaking END
                        then CASE WHEN cs3.isautolivempositiontaking = 1 THEN cs3.autolivempositiontaking ELSE acs.autolivempositiontaking END
                    else  mcs.mlivepositiontaking-cs3.alivepositiontaking END
            from
                custsetting3rd cs3
                INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
                INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=cs3.sporttype AND mcs.bettype=cs3.bettype
                INNER JOIN custsetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend AND acs.sporttype=cs3.sporttype AND acs.bettype=cs3.bettype
            where
                c.recommend = @recommend
                and c.roleid = 1
                and cs3.sporttype = 161
                and cs3.bettype IN (85,86,87,89,90)
                and (acs.isautolivempositiontaking = 1 OR cs3.isautolivempositiontaking = 1)

            --check master min/max
            -- UPDATE m1 WHEN m1+a1<n3
            -- m1=n3-a1
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET 
                mpositiontaking = mco.minpositiontaking-cs3.apositiontaking
            FROM 
                custsetting3rd cs3 INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs3.sporttype AND mco.bettype=cs3.bettype
            WHERE cs3.sporttype = 161 AND cs3.bettype IN (81,83,86,88) AND cs3.apositiontaking+cs3.mpositiontaking<mco.minpositiontaking


            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET 
                mlivepositiontaking = mco.minlivepositiontaking-cs3.alivepositiontaking
            FROM 
                custsetting3rd cs3 INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs3.sporttype AND mco.bettype=cs3.bettype
            WHERE cs3.sporttype=161 AND cs3.bettype IN (85,86,87,89,90) AND cs3.alivepositiontaking+cs3.mlivepositiontaking<mco.minlivepositiontaking

            -- UPDATE m1,a1 WHEN m1+a1>l3
            -- m1=min(m3,l3)-a1
            -- a1=max(iif(m1+a1>min(m3,l3),min(m3,l3)-m1,a1),n2)
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET 
                @maxmapos = CASE WHEN mcs.mpositiontaking>mco.maxpositiontaking THEN mco.maxpositiontaking ELSE mcs.mpositiontaking END,
                @mpos = CASE WHEN @maxmapos-cs3.apositiontaking<0 THEN 0 ELSE @maxmapos-cs3.apositiontaking END,
                mpositiontaking = @mpos,
                @apos = CASE WHEN cs3.apositiontaking + @mpos>@maxmapos THEN @maxmapos-@mpos ELSE cs3.apositiontaking END,
                apositiontaking = CASE WHEN @apos<aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
            FROM 
                custsetting3rd cs3 INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=cs3.sporttype AND mcs.bettype=cs3.bettype
                INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs3.sporttype AND mco.bettype=cs3.bettype
                INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs3.sporttype AND aco.bettype=cs3.bettype
            WHERE cs3.sporttype = 161  AND cs3.bettype IN (81,83,86,88) AND  cs3.apositiontaking+cs3.mpositiontaking>mco.maxpositiontaking

            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET 
                @maxmapos = CASE WHEN mcs.mlivepositiontaking>mco.maxlivepositiontaking THEN mco.maxlivepositiontaking ELSE mcs.mlivepositiontaking END,
                @mpos = CASE WHEN @maxmapos-cs3.alivepositiontaking<0 THEN 0 ELSE @maxmapos-cs3.alivepositiontaking END,
                mlivepositiontaking = @mpos,
                @apos = CASE WHEN cs3.alivepositiontaking + @mpos>@maxmapos THEN @maxmapos-@mpos ELSE cs3.alivepositiontaking END,
                alivepositiontaking = CASE WHEN @apos<aco.minlivepositiontaking THEN aco.minlivepositiontaking ELSE @apos END
            FROM 
                custsetting3rd cs3 INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=cs3.sporttype AND mcs.bettype=cs3.bettype
                INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs3.sporttype AND mco.bettype=cs3.bettype
                INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs3.sporttype AND aco.bettype=cs3.bettype
            WHERE cs3.sporttype=161 AND cs3.bettype IN (85,86,87,89,90) AND cs3.alivepositiontaking+cs3.mlivepositiontaking>mco.maxlivepositiontaking

            --s1=min(s4-m1-a1,u)
            --recal autopos
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK) 
                SET spositiontaking = CASE WHEN scs.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking >
                                        (CASE WHEN cs3.isautopositiontaking=1 THEN cs3.autopositiontaking ELSE mcs.autopositiontaking END) THEN (CASE WHEN cs3.isautopositiontaking=1 THEN cs3.autopositiontaking ELSE mcs.autopositiontaking END) ELSE scs.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking END 
            from
                custsetting3rd cs3
                INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
                INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=cs3.sporttype AND mcs.bettype=cs3.bettype
                INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype=cs3.sporttype AND scs.bettype=cs3.bettype
            where
                c.recommend = @recommend
                and c.roleid = 1
                and cs3.sporttype = 161
                and cs3.bettype IN (81,83,86,88)
                and (cs3.isautopositiontaking=1 OR mcs.isautopositiontaking=1)

            UPDATE cs3 WITH(ROWLOCK, UPDLOCK) 
                SET slivepositiontaking = CASE WHEN scs.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking >
                                        (CASE WHEN cs3.isautolivepositiontaking=1 THEN cs3.autolivepositiontaking ELSE mcs.autolivepositiontaking END) THEN (CASE WHEN cs3.isautolivepositiontaking=1 THEN cs3.autolivepositiontaking ELSE mcs.autolivepositiontaking END) ELSE scs.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking END 
            from
                custsetting3rd cs3
                INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
                INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=cs3.sporttype AND mcs.bettype=cs3.bettype
                INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype=cs3.sporttype AND scs.bettype=cs3.bettype
            where
                c.recommend = @recommend
                and c.roleid = 1
                and cs3.sporttype = 161
                and cs3.bettype IN (85,86,87,89,90)
                and (cs3.isautolivepositiontaking=1 OR mcs.isautolivepositiontaking=1)    
                
            --check super min/max
            --UPDATE s1 WHEN s1+m1+a1<n4
            --s1=n4-m1-a1 
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET 
                spositiontaking = sco.minpositiontaking-cs3.mpositiontaking-cs3.apositiontaking
            FROM 
                custsetting3rd cs3 INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custoverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend  AND sco.sporttype=cs3.sporttype AND sco.bettype=cs3.bettype
            WHERE cs3.sporttype = 161 AND cs3.bettype IN (81,83,86,88) AND cs3.apositiontaking+cs3.mpositiontaking+cs3.spositiontaking<sco.minpositiontaking

            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET 
                slivepositiontaking = sco.minlivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking
            FROM 
                custsetting3rd cs3 INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custoverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend  AND sco.sporttype=cs3.sporttype AND sco.bettype=cs3.bettype
            WHERE cs3.sporttype=161 AND cs3.bettype IN (85,86,87,89,90) AND cs3.alivepositiontaking+cs3.mlivepositiontaking+cs3.slivepositiontaking<sco.minlivepositiontaking

            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
            --s1=max(0,s4-m1-a1)
            --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
            --@maxmapos=min(m3,l3)
            --@mapos2=min(@mapos1,@maxmapos)
            --@mapos=max(@mapos2,n3)
            --m1=max(0,@mapos-a1)
            --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
            --v161
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET 
                @spos = CASE WHEN scs.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking<0 THEN 0 ELSE scs.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking END,
                spositiontaking = @spos,
                @mapos1 = CASE WHEN @spos+cs3.mpositiontaking+cs3.apositiontaking>scs.spositiontaking THEN scs.spositiontaking-@spos ELSE cs3.mpositiontaking+cs3.apositiontaking END,
                @maxmapos = CASE WHEN mcs.mpositiontaking>mco.maxpositiontaking THEN mco.maxpositiontaking ELSE mcs.mpositiontaking END,
                @mapos2 = CASE WHEN @mapos1>@maxmapos THEN @maxmapos ELSE @mapos1 END,
                @mapos = CASE WHEN @mapos2<mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
                @mpos = CASE WHEN @mapos-cs3.apositiontaking<0 THEN 0 ELSE @mapos-cs3.apositiontaking END,
                mpositiontaking = @mpos,
                @apos = CASE WHEN cs3.apositiontaking + @mpos>@mapos THEN @mapos-@mpos ELSE cs3.apositiontaking END,
                apositiontaking = CASE WHEN @apos<aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
            FROM 
                custsetting3rd cs3 INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend  AND scs.sporttype=cs3.sporttype AND scs.bettype=cs3.bettype
                INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=cs3.sporttype AND mcs.bettype=cs3.bettype
                INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs3.sporttype AND mco.bettype=cs3.bettype
                INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs3.sporttype AND aco.bettype=cs3.bettype
            WHERE cs3.sporttype = 161 AND cs3.bettype IN  (81,83,86,88) AND  cs3.spositiontaking+cs3.apositiontaking+cs3.mpositiontaking>scs.spositiontaking

            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET 
                @spos = CASE WHEN scs.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking<0 THEN 0 ELSE scs.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking END,
                slivepositiontaking = @spos,
                @mapos1 = CASE WHEN @spos+cs3.mlivepositiontaking+cs3.alivepositiontaking>scs.slivepositiontaking THEN scs.slivepositiontaking-@spos ELSE cs3.mlivepositiontaking+cs3.alivepositiontaking END,
                @maxmapos = CASE WHEN mcs.mlivepositiontaking>mco.maxlivepositiontaking THEN mco.maxlivepositiontaking ELSE mcs.mlivepositiontaking END,
                @mapos2 = CASE WHEN @mapos1>@maxmapos THEN @maxmapos ELSE @mapos1 END,
                @mapos = CASE WHEN @mapos2<mco.minlivepositiontaking THEN mco.minlivepositiontaking ELSE @mapos2 END,
                @mpos = CASE WHEN @mapos-cs3.alivepositiontaking<0 THEN 0 ELSE @mapos-cs3.alivepositiontaking END,
                mlivepositiontaking = @mpos,
                @apos = CASE WHEN cs3.alivepositiontaking + @mpos>@mapos THEN @mapos-@mpos ELSE cs3.alivepositiontaking END,
                alivepositiontaking = CASE WHEN @apos<aco.minlivepositiontaking THEN aco.minlivepositiontaking ELSE @apos END
            FROM 

                custsetting3rd cs3 INNER JOIN custinfo mb WITH(NOLOCK) ON cs3.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend  AND scs.sporttype=cs3.sporttype AND scs.bettype=cs3.bettype
                INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=cs3.sporttype AND mcs.bettype=cs3.bettype
                INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs3.sporttype AND mco.bettype=cs3.bettype
                INNER JOIN custoverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs3.sporttype AND aco.bettype=cs3.bettype
            WHERE cs3.sporttype=161 AND cs3.bettype IN (85,86,87,89,90) AND cs3.slivepositiontaking+cs3.alivepositiontaking+cs3.mlivepositiontaking>scs.slivepositiontaking
        END
        
        IF @mode = 'horse'
        BEGIN                        
            --check agent min/max
            -- UPDATE a1 WHEN a1<n2
            -- a1=n2
            UPDATE cs
                SET apositiontaking = aco.minpositiontaking,
                    cs.mpositiontaking = CASE WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking-aco.minpositiontaking ELSE cs.mpositiontaking END
            FROM 
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype
                INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype
            WHERE cs.apositiontaking < aco.minpositiontaking
                and cs.sporttype IN ( 151,152,153)
            
            -- UPDATE a1 WHEN a1>l2
            -- a1=l2
            UPDATE cs
                SET apositiontaking = aco.maxpositiontaking
            FROM 
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype
            WHERE cs.apositiontaking > aco.maxpositiontaking
                and cs.sporttype IN ( 151,152,153)

            --Recal AUTO MPT 
            --UPDATE m1=min(m3-a1,u2)
            UPDATE cs
                SET mpositiontaking = 
                    CASE WHEN mcs.mpositiontaking-cs.apositiontaking > (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)
                        then (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)
                    else  mcs.mpositiontaking-cs.apositiontaking END
            from
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype
                INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend AND acs.sporttype=cs.sporttype AND acs.bettype=cs.bettype
            where
                c.recommend = @recommend
                and c.roleid = 1
                and (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1)
                and cs.sporttype IN ( 151,152,153)                
            
            --check master min/max
            -- UPDATE m1 WHEN m1+a1<n3
            -- m1=n3-a1
            UPDATE cs
                SET mpositiontaking = mco.minpositiontaking-cs.apositiontaking
            FROM 
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs.sporttype AND mco.bettype=cs.bettype
            WHERE cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
                and cs.sporttype IN ( 151,152,153)
            
            -- UPDATE m1,a1 WHEN m1+a1>l3
            -- m1=min(m3,l3)-a1
            -- a1=max(iif(m1+a1>min(m3,l3),min(m3,l3)-m1,a1),n2)
            UPDATE cs 
                SET @maxmapos = CASE WHEN mcs.mpositiontaking>mco.maxpositiontaking THEN mco.maxpositiontaking ELSE mcs.mpositiontaking END,
                    @mpos = CASE WHEN @maxmapos-cs.apositiontaking<0 THEN 0 ELSE @maxmapos-cs.apositiontaking END,
                    mpositiontaking = @mpos,
                    @apos = CASE WHEN cs.apositiontaking + @mpos>@maxmapos THEN @maxmapos-@mpos ELSE cs.apositiontaking END,
                    apositiontaking = CASE WHEN @apos<aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
            FROM 
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype
                INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs.sporttype AND mco.bettype=cs.bettype
                INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype
            WHERE cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
                and cs.sporttype IN ( 151,152,153)
            
            --s1=min(s4-m1-a1,u)
            --recal autopos
            UPDATE cs 
                SET spositiontaking = CASE WHEN scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
                                        (CASE WHEN cs.isautopositiontaking=1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN (CASE WHEN cs.isautopositiontaking=1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) ELSE scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking END 
            from
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype
                INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype
            where
                c.recommend = @recommend
                and c.roleid = 1
                and (cs.isautopositiontaking=1 OR mcs.isautopositiontaking=1)
                and cs.sporttype IN ( 151,152,153)

            --check super min/max
            --UPDATE s1 WHEN s1+m1+a1<n4
            --s1=n4-m1-a1 
            UPDATE cs
                SET spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
            FROM 
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN CustOverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend  AND sco.sporttype=cs.sporttype AND sco.bettype=cs.bettype
            WHERE cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
                and cs.sporttype IN ( 151,152,153)

            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
            --s1=max(0,s4-m1-a1)
            --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
            --@maxmapos=min(m3,l3)
            --@mapos2=min(@mapos1,@maxmapos)
            --@mapos=max(@mapos2,n3)
            --m1=max(0,@mapos-a1)
            --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
            UPDATE cs
                SET @spos = CASE WHEN scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 THEN 0 ELSE scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking END,
                    spositiontaking = @spos,
                    @mapos1 = CASE WHEN @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking THEN scs.spositiontaking-@spos ELSE cs.mpositiontaking+cs.apositiontaking END,
                    @maxmapos = CASE WHEN mcs.mpositiontaking>mco.maxpositiontaking THEN mco.maxpositiontaking ELSE mcs.mpositiontaking END,
                    @mapos2 = CASE WHEN @mapos1>@maxmapos THEN @maxmapos ELSE @mapos1 END,
                    @mapos = CASE WHEN @mapos2<mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
                    @mpos = CASE WHEN @mapos-cs.apositiontaking<0 THEN 0 ELSE @mapos-cs.apositiontaking END,
                    mpositiontaking = @mpos,
                    @apos = CASE WHEN cs.apositiontaking + @mpos>@mapos THEN @mapos-@mpos ELSE cs.apositiontaking END,
                    apositiontaking = CASE WHEN @apos<aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
            FROM 
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend  AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype
                INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs.sporttype AND mco.bettype=cs.bettype
                INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype
            WHERE cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
                and cs.sporttype IN ( 151,152,153)
        END
        
        IF @mode = 'virtual-sports'
        BEGIN
            --check agent min/max  
            -- UPDATE a1 WHEN a1<n2  
            -- a1=n2  
            UPDATE cs  
            SET apositiontaking = aco.minpositiontaking,  
                cs.mpositiontaking = CASE WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking-aco.minpositiontaking ELSE cs.mpositiontaking END  
            FROM   
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)  
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1  
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype  
                INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype  
            WHERE cs.apositiontaking < aco.minpositiontaking  
                and cs.sporttype = @sporttype  
              
              
            -- UPDATE a1 WHEN a1>l2  
            -- a1=l2  
            UPDATE cs  
            SET apositiontaking = aco.maxpositiontaking  
            FROM   
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)  
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1  
                INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype  
            WHERE cs.apositiontaking > aco.maxpositiontaking  
                and cs.sporttype = @sporttype  
              
            --Recal AUTO MPT   
            --UPDATE m1=min(m3-a1,u2)  
            UPDATE cs  
            SET mpositiontaking =   
                CASE WHEN mcs.mpositiontaking-cs.apositiontaking > (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)  
                then (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)  
                else  mcs.mpositiontaking-cs.apositiontaking END  
            FROM  
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)  
                INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid  
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype  
                INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend AND acs.sporttype=cs.sporttype AND acs.bettype=cs.bettype  
            WHERE  
                c.recommend = @recommend  
                and c.roleid = 1  
                and (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1)  
                and cs.sporttype = @sporttype                                
              
            --check master min/max  
            -- UPDATE m1 WHEN m1+a1<n3  
            -- m1=n3-a1  
            UPDATE cs  
            SET mpositiontaking = mco.minpositiontaking-cs.apositiontaking  
            FROM   
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)  
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1  
                INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs.sporttype AND mco.bettype=cs.bettype  
            WHERE cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking  
                and cs.sporttype = @sporttype  
                                          
            -- UPDATE m1,a1 WHEN m1+a1>l3  
            -- m1=min(m3,l3)-a1  
            -- a1=max(iif(m1+a1>min(m3,l3),min(m3,l3)-m1,a1),n2)  
            UPDATE cs   
            SET @maxmapos = CASE WHEN mcs.mpositiontaking>mco.maxpositiontaking THEN mco.maxpositiontaking ELSE mcs.mpositiontaking END,  
                @mpos = CASE WHEN @maxmapos-cs.apositiontaking<0 THEN 0 ELSE @maxmapos-cs.apositiontaking END,  
                mpositiontaking = @mpos,  
                @apos = CASE WHEN cs.apositiontaking + @mpos>@maxmapos THEN @maxmapos-@mpos ELSE cs.apositiontaking END,  
                apositiontaking = CASE WHEN @apos<aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END  
            FROM   
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)  
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1  
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype  
                INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs.sporttype AND mco.bettype=cs.bettype  
                INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype  
            WHERE cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking  
             AND cs.sporttype = @sporttype                     
              
            --s1=min(s4-m1-a1,u)  
            --recal autopos  
            UPDATE cs   
            SET spositiontaking = CASE WHEN scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >  
                (CASE WHEN cs.isautopositiontaking=1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN (CASE WHEN cs.isautopositiontaking=1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) ELSE scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking END   
            FROM  
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)  
                INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid  
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype  
                INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype  
            WHERE  
                c.recommend = @recommend  
                and c.roleid = 1  
                and (cs.isautopositiontaking=1 OR mcs.isautopositiontaking=1)  
                and cs.sporttype = @sporttype  
                               
            --check super min/max  
            --UPDATE s1 WHEN s1+m1+a1<n4  
            --s1=n4-m1-a1   
            UPDATE cs  
            SET spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking  
            FROM   
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)  
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1  
                INNER JOIN CustOverride3rd sco WITH(NOLOCK) ON sco.custid = @srecommend  AND sco.sporttype=cs.sporttype AND sco.bettype=cs.bettype  
            WHERE cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking  
                and cs.sporttype = @sporttype  
              
            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4  
            --s1=max(0,s4-m1-a1)  
            --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)  
            --@maxmapos=min(m3,l3)  
            --@mapos2=min(@mapos1,@maxmapos)  
            --@mapos=max(@mapos2,n3)  
            --m1=max(0,@mapos-a1)  
            --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)  
            UPDATE cs  
            SET @spos = CASE WHEN scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 THEN 0 ELSE scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking END,  
                spositiontaking = @spos,  
                @mapos1 = CASE WHEN @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking THEN scs.spositiontaking-@spos ELSE cs.mpositiontaking+cs.apositiontaking END,  
                @maxmapos = CASE WHEN mcs.mpositiontaking>mco.maxpositiontaking THEN mco.maxpositiontaking ELSE mcs.mpositiontaking END,  
                @mapos2 = CASE WHEN @mapos1>@maxmapos THEN @maxmapos ELSE @mapos1 END,  
                @mapos = CASE WHEN @mapos2<mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,  
                @mpos = CASE WHEN @mapos-cs.apositiontaking<0 THEN 0 ELSE @mapos-cs.apositiontaking END,  
                mpositiontaking = @mpos,  
                @apos = CASE WHEN cs.apositiontaking + @mpos>@mapos THEN @mapos-@mpos ELSE cs.apositiontaking END,  
                apositiontaking = CASE WHEN @apos<aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END  
            FROM   
                CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)  
                INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1  
                INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend  AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype  
                INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype  
                INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=cs.sporttype AND mco.bettype=cs.bettype  
                INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype  
            WHERE cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking  
                and cs.sporttype = @sporttype  
        END
        IF @mode = 'LiveCasino'
        BEGIN    
            SELECT    @recommend = custid,
                    @srecommend = srecommend
            FROM custinfo WITH(NOLOCK)
            WHERE custid = @custid

            --check agent min/max
            -- UPDATE a1 WHEN a1<n2
            -- a1=n2
            UPDATE csg WITH(ROWLOCK, UPDLOCK) 
            SET 
                apositiontaking = aco.minpositiontaking,
                mpositiontaking = CASE WHEN csg.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking-aco.minpositiontaking ELSE csg.mpositiontaking END
            FROM custsettingGame csg 
                INNER JOIN custinfo mb WITH(NOLOCK) ON csg.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1 AND mb.SyncLiveCasino = 1
                INNER JOIN custsettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=csg.sporttype AND mcs.bettype=csg.bettype
                INNER JOIN custoverridegame aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=csg.sporttype AND aco.bettype=csg.bettype
            WHERE csg.apositiontaking < aco.minpositiontaking
                AND csg.sporttype = 162 AND csg.bettype = 1101


            --Recal AUTO MPT 
            --UPDATE m1=min(m3-a1,u2)
            UPDATE custsettingGame WITH(ROWLOCK, UPDLOCK) 
            SET mpositiontaking = 
                    CASE WHEN mcs.mpositiontaking-custsettingGame.apositiontaking > CASE WHEN custsettingGame.isautompositiontaking = 1 THEN custsettingGame.autompositiontaking ELSE acs.autompositiontaking END
                        then CASE WHEN custsettingGame.isautompositiontaking = 1 THEN custsettingGame.autompositiontaking ELSE acs.autompositiontaking END
                    else  mcs.mpositiontaking-custsettingGame.apositiontaking END
            from
                custsettingGame
                INNER JOIN custinfo c WITH(NOLOCK) ON custsettingGame.custid = c.custid
                INNER JOIN custsettingGame mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=custsettingGame.sporttype AND mcs.bettype=custsettingGame.bettype
                INNER JOIN custsettingGame acs WITH(NOLOCK) ON acs.custid = c.recommend AND acs.sporttype=custsettingGame.sporttype AND acs.bettype=custsettingGame.bettype
            where
                c.recommend = @recommend
                and c.roleid = 1 AND c.SyncLiveCasino = 1
                and custsettingGame.sporttype = 162 AND custsettingGame.bettype = 1101
            and (acs.isautompositiontaking = 1 OR custsettingGame.isautompositiontaking = 1)


            --check master min/max
            -- UPDATE m1 WHEN m1+a1<n3
            -- m1=n3-a1
            UPDATE custsettingGame WITH(ROWLOCK, UPDLOCK)
               SET 
                mpositiontaking = mco.minpositiontaking-custsettingGame.apositiontaking
            FROM 
                custsettingGame 
                INNER JOIN custinfo mb WITH(NOLOCK) ON custsettingGame.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1 AND mb.SyncLiveCasino = 1
                INNER JOIN custoverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=custsettingGame.sporttype AND mco.bettype=custsettingGame.bettype
            WHERE custsettingGame.apositiontaking+custsettingGame.mpositiontaking<mco.minpositiontaking
                and custsettingGame.sporttype = 162 AND custsettingGame.bettype = 1101
            

            --s1=min(s4-m1-a1,u)
            --recal autopos
            UPDATE custsettingGame WITH(ROWLOCK, UPDLOCK) 
                SET spositiontaking = CASE WHEN scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking >
                                        (CASE WHEN custsettingGame.isautopositiontaking=1 THEN custsettingGame.autopositiontaking ELSE mcs.autopositiontaking END) THEN (CASE WHEN custsettingGame.isautopositiontaking=1 THEN custsettingGame.autopositiontaking ELSE mcs.autopositiontaking END) ELSE scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking END 
            from
                custsettingGame
                INNER JOIN custinfo c WITH(NOLOCK) ON custsettingGame.custid = c.custid
                INNER JOIN custsettingGame mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=custsettingGame.sporttype AND mcs.bettype=custsettingGame.bettype
                INNER JOIN custsettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype=custsettingGame.sporttype AND scs.bettype=custsettingGame.bettype
            where
                c.recommend = @recommend
                and c.roleid = 1 AND c.SyncLiveCasino = 1
                and custsettingGame.sporttype = 162 AND custsettingGame.bettype = 1101
                and (custsettingGame.isautopositiontaking=1 OR mcs.isautopositiontaking=1)

            --check super min/max
            --UPDATE s1 WHEN s1+m1+a1<n4
            --s1=n4-m1-a1 
            UPDATE custsettingGame WITH(ROWLOCK, UPDLOCK)
               SET 
                spositiontaking = sco.minpositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking
            FROM 
                custsettingGame INNER JOIN custinfo mb WITH(NOLOCK) ON custsettingGame.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1 AND mb.SyncLiveCasino = 1
                INNER JOIN custoverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend  AND sco.sporttype=custsettingGame.sporttype AND sco.bettype=custsettingGame.bettype
            WHERE custsettingGame.apositiontaking+custsettingGame.mpositiontaking+custsettingGame.spositiontaking<sco.minpositiontaking
                and custsettingGame.sporttype = 162 AND custsettingGame.bettype = 1101

            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
            --s1=max(0,s4-m1-a1)
            --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
            --@maxmapos=min(m3,l3)
            --@mapos2=min(@mapos1,@maxmapos)
            --@mapos=max(@mapos2,n3)
            --m1=max(0,@mapos-a1)
            --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
            UPDATE custsettingGame WITH(ROWLOCK, UPDLOCK)
               SET 
                @spos = CASE WHEN scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking<0 THEN 0 ELSE scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking END,
                spositiontaking = @spos,
                @mapos1 = CASE WHEN @spos+custsettingGame.mpositiontaking+custsettingGame.apositiontaking>scs.spositiontaking THEN scs.spositiontaking-@spos ELSE custsettingGame.mpositiontaking+custsettingGame.apositiontaking END,
                --@maxmapos = CASE WHEN mcs.mpositiontaking>mco.maxpositiontaking THEN mco.maxpositiontaking ELSE mcs.mpositiontaking END,
                @mapos2 = CASE WHEN @mapos1>@maxmapos THEN @maxmapos ELSE @mapos1 END,
                @mapos = CASE WHEN @mapos2<mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
                @mpos = CASE WHEN @mapos-custsettingGame.apositiontaking<0 THEN 0 ELSE @mapos-custsettingGame.apositiontaking END,
                mpositiontaking = @mpos,
                @apos = CASE WHEN custsettingGame.apositiontaking + @mpos>@mapos THEN @mapos-@mpos ELSE custsettingGame.apositiontaking END,
                apositiontaking = CASE WHEN @apos<aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
            FROM 
                custsettingGame INNER JOIN custinfo mb WITH(NOLOCK) ON custsettingGame.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1 AND mb.SyncLiveCasino = 1
                INNER JOIN custsettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend  AND scs.sporttype=custsettingGame.sporttype AND scs.bettype=custsettingGame.bettype
                INNER JOIN custsettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=custsettingGame.sporttype AND mcs.bettype=custsettingGame.bettype
                INNER JOIN custoverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=custsettingGame.sporttype AND mco.bettype=custsettingGame.bettype
                INNER JOIN custoverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=custsettingGame.sporttype AND aco.bettype=custsettingGame.bettype
            WHERE custsettingGame.spositiontaking+custsettingGame.apositiontaking+custsettingGame.mpositiontaking>scs.spositiontaking
                and custsettingGame.sporttype = 162 AND custsettingGame.bettype = 1101
        END        

        IF @mode = 'Keno' OR @mode = 'GoldDeluxe'
        BEGIN    
            SELECT    @recommend = custid,
                    @srecommend = srecommend
            FROM custinfo WITH(NOLOCK)
            WHERE custid = @custid

            --check agent min/max
            -- UPDATE a1 WHEN a1<n2
            -- a1=n2
            UPDATE csg WITH(ROWLOCK, UPDLOCK) 
            SET 
                apositiontaking = aco.minpositiontaking,
                mpositiontaking = CASE WHEN csg.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking-aco.minpositiontaking ELSE csg.mpositiontaking END
            FROM custsettingGame csg 
                INNER JOIN custinfo mb WITH(NOLOCK) ON csg.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custsettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=csg.sporttype AND mcs.bettype=csg.bettype
                INNER JOIN custoverridegame aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=csg.sporttype AND aco.bettype=csg.bettype
            WHERE csg.apositiontaking < aco.minpositiontaking
                AND csg.sporttype = @sporttype AND csg.bettype = @bettype

            --Recal AUTO MPT 
            --UPDATE m1=min(m3-a1,u2)
            UPDATE custsettingGame WITH(ROWLOCK, UPDLOCK) 
            SET mpositiontaking = 
                    CASE WHEN mcs.mpositiontaking-custsettingGame.apositiontaking > CASE WHEN custsettingGame.isautompositiontaking = 1 THEN custsettingGame.autompositiontaking ELSE acs.autompositiontaking END
                        then CASE WHEN custsettingGame.isautompositiontaking = 1 THEN custsettingGame.autompositiontaking ELSE acs.autompositiontaking END
                    else  mcs.mpositiontaking-custsettingGame.apositiontaking END
            from
                custsettingGame
                INNER JOIN custinfo c WITH(NOLOCK) ON custsettingGame.custid = c.custid
                INNER JOIN custsettingGame mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=custsettingGame.sporttype AND mcs.bettype=custsettingGame.bettype
                INNER JOIN custsettingGame acs WITH(NOLOCK) ON acs.custid = c.recommend AND acs.sporttype=custsettingGame.sporttype AND acs.bettype=custsettingGame.bettype
            where
                c.recommend = @recommend
                and c.roleid = 1 
                and custsettingGame.sporttype = @sporttype AND custsettingGame.bettype = @bettype
            and (acs.isautompositiontaking = 1 OR custsettingGame.isautompositiontaking = 1)

            --check master min/max
            -- UPDATE m1 WHEN m1+a1<n3
            -- m1=n3-a1
            UPDATE custsettingGame WITH(ROWLOCK, UPDLOCK)
               SET 
                mpositiontaking = mco.minpositiontaking-custsettingGame.apositiontaking
            FROM 
                custsettingGame 
                INNER JOIN custinfo mb WITH(NOLOCK) ON custsettingGame.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1 
                INNER JOIN custoverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=custsettingGame.sporttype AND mco.bettype=custsettingGame.bettype
            WHERE custsettingGame.apositiontaking+custsettingGame.mpositiontaking<mco.minpositiontaking
                and custsettingGame.sporttype = @sporttype AND custsettingGame.bettype = @bettype

            --s1=min(s4-m1-a1,u)
            --recal autopos
            UPDATE custsettingGame WITH(ROWLOCK, UPDLOCK) 
                SET spositiontaking = CASE WHEN scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking >
                                        (CASE WHEN custsettingGame.isautopositiontaking=1 THEN custsettingGame.autopositiontaking ELSE mcs.autopositiontaking END) THEN (CASE WHEN custsettingGame.isautopositiontaking=1 THEN custsettingGame.autopositiontaking ELSE mcs.autopositiontaking END) ELSE scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking END 
            from
                custsettingGame
                INNER JOIN custinfo c WITH(NOLOCK) ON custsettingGame.custid = c.custid
                INNER JOIN custsettingGame mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend AND mcs.sporttype=custsettingGame.sporttype AND mcs.bettype=custsettingGame.bettype
                INNER JOIN custsettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype=custsettingGame.sporttype AND scs.bettype=custsettingGame.bettype
            where
                c.recommend = @recommend
                and c.roleid = 1 
                and custsettingGame.sporttype = @sporttype AND custsettingGame.bettype = @bettype
                and (custsettingGame.isautopositiontaking=1 OR mcs.isautopositiontaking=1)

            --check super min/max
            --UPDATE s1 WHEN s1+m1+a1<n4
            --s1=n4-m1-a1 
            UPDATE custsettingGame WITH(ROWLOCK, UPDLOCK)
               SET 
                spositiontaking = sco.minpositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking
            FROM 
                custsettingGame INNER JOIN custinfo mb WITH(NOLOCK) ON custsettingGame.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
                INNER JOIN custoverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend  AND sco.sporttype=custsettingGame.sporttype AND sco.bettype=custsettingGame.bettype
            WHERE custsettingGame.apositiontaking+custsettingGame.mpositiontaking+custsettingGame.spositiontaking<sco.minpositiontaking
                and custsettingGame.sporttype = @sporttype AND custsettingGame.bettype = @bettype

            --UPDATE s1,m1,a1 IN CASE s1+m1+a1>s4
            --s1=max(0,s4-m1-a1)
            --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
            --@maxmapos=min(m3,l3)
            --@mapos2=min(@mapos1,@maxmapos)
            --@mapos=max(@mapos2,n3)
            --m1=max(0,@mapos-a1)
            --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
            UPDATE custsettingGame WITH(ROWLOCK, UPDLOCK)
               SET 
                @spos = CASE WHEN scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking<0 THEN 0 ELSE scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking END,
                spositiontaking = @spos,
                @mapos1 = CASE WHEN @spos+custsettingGame.mpositiontaking+custsettingGame.apositiontaking>scs.spositiontaking THEN scs.spositiontaking-@spos ELSE custsettingGame.mpositiontaking+custsettingGame.apositiontaking END,
                --@maxmapos = CASE WHEN mcs.mpositiontaking>mco.maxpositiontaking THEN mco.maxpositiontaking ELSE mcs.mpositiontaking END,
                @mapos2 = CASE WHEN @mapos1>@maxmapos THEN @maxmapos ELSE @mapos1 END,
                @mapos = CASE WHEN @mapos2<mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
                @mpos = CASE WHEN @mapos-custsettingGame.apositiontaking<0 THEN 0 ELSE @mapos-custsettingGame.apositiontaking END,
                mpositiontaking = @mpos,
                @apos = CASE WHEN custsettingGame.apositiontaking + @mpos>@mapos THEN @mapos-@mpos ELSE custsettingGame.apositiontaking END,
                apositiontaking = CASE WHEN @apos<aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
            FROM 
                custsettingGame INNER JOIN custinfo mb WITH(NOLOCK) ON custsettingGame.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1 
                INNER JOIN custsettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend  AND scs.sporttype=custsettingGame.sporttype AND scs.bettype=custsettingGame.bettype
                INNER JOIN custsettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend  AND mcs.sporttype=custsettingGame.sporttype AND mcs.bettype=custsettingGame.bettype
                INNER JOIN custoverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend  AND mco.sporttype=custsettingGame.sporttype AND mco.bettype=custsettingGame.bettype
                INNER JOIN custoverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend  AND aco.sporttype=custsettingGame.sporttype AND aco.bettype=custsettingGame.bettype
            WHERE custsettingGame.spositiontaking+custsettingGame.apositiontaking+custsettingGame.mpositiontaking>scs.spositiontaking
                and custsettingGame.sporttype = @sporttype AND custsettingGame.bettype = @bettype

        END
    END
    
END

GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting3rd_04] TO [vnteam]
GO 
