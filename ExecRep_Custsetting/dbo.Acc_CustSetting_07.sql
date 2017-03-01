
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Acc_CustSetting_07    Script Date: 8/21/2014 3:12:20 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustSetting_07    Script Date: 8/21/2014 2:58:13 PM ******/
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
            

        Parameter's Explanation:
    */ 
BEGIN
   
    SET NOCOUNT ON

     if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustSetting') = 1 
	   AND dbo.f_CheckRepTable('CustOverride') = 1 
	   )
     RETURN
        
    IF @roleid = 4
    BEGIN                
        --u = (i3 or i1)?(u3 or u1)
        --s1 = min(s4-m1-a1, u)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
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
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
         WHERE c.srecommend = @srecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (cs.isautopositiontaking = 1
                OR mcs.isautopositiontaking = 1)
		
		  --check super min
            --s1=max(n4-m1-a1,s1)
            UPDATE cs
               SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
            FROM CustSetting cs WITH(ROWLOCK, UPDLOCK)
				INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
												   AND mb.srecommend = @srecommend
												   AND mb.roleid = 1
												   AND mb.Enabled = 1
				INNER JOIN CustOverride sco WITH(NOLOCK) ON sco.custid = @srecommend
														   AND sco.sporttype = cs.sporttype
														   AND sco.bettype = cs.bettype
			WHERE cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking
			                


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
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
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
         WHERE c.srecommend = @srecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (cs.isautolivepositiontaking = 1
                OR mcs.isautolivepositiontaking = 1
               )
		
		UPDATE cs
           SET slivepositiontaking = sco.minlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
        FROM CustSetting cs WITH(ROWLOCK, UPDLOCK)
			INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
											   AND mb.srecommend = @srecommend
											   AND mb.roleid = 1
											   AND mb.Enabled = 1
			INNER JOIN CustOverride sco WITH(NOLOCK) ON sco.custid = @srecommend
													   AND sco.sporttype = cs.sporttype
													   AND sco.bettype = cs.bettype
		WHERE cs.alivepositiontaking + cs.mlivepositiontaking + cs.slivepositiontaking < sco.minlivepositiontaking
			                
              
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
        --Phuc remove @20081125 
        /*
        -- UPDATE m2,a2 when m2+a2>m3(normal)
        -- m2=m3-a2,a2=max(iif(m3<m2+a2,m3-m2,a2),n2)

        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            @mpos =
                 CASE
                   WHEN mcs.mpositiontaking - cs.apositiontaking<0 THEN 0
                            ELSE mcs.mpositiontaking - cs.apositiontaking end,
            mpositiontaking = @mpos,
            @apos =
                 CASE
                   WHEN mcs.mpositiontaking-@mpos-cs.apositiontaking<0 THEN mcs.mpositiontaking-@mpos
                            ELSE cs.apositiontaking end,
            apositiontaking =
                 CASE
                   WHEN aco.minpositiontaking > @apos THEN aco.minpositiontaking
                            ELSE @apos end 
          FROM 
            custsetting cs
    INNER JOIN customer as a WITH(NOLOCK) ON cs.custid = a.custid AND a.mrecommend = @mrecommend AND a.roleid = 2
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
    INNER JOIN custoverride as aco WITH(NOLOCK) ON aco.custid = cs.custid  AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
         WHERE 
            cs.mpositiontaking+cs.apositiontaking > mcs.mpositiontaking

        -- UPDATE m2,a2 when m2+a2>m3(live)
        -- m2=m3-a2,a2=max(iif(m3<m2+a2,m3-m2,a2),n2)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            @mpos =
                 CASE
                   WHEN mcs.mlivepositiontaking - cs.alivepositiontaking<0 THEN 0
                            ELSE mcs.mlivepositiontaking - cs.alivepositiontaking end,
            mlivepositiontaking = @mpos,
            @apos =
                 CASE
                   WHEN mcs.mlivepositiontaking-@mpos-cs.alivepositiontaking<0 THEN mcs.mlivepositiontaking-@mpos
                            ELSE cs.alivepositiontaking end,
            alivepositiontaking =
                 CASE
                   WHEN aco.minlivepositiontaking > @apos THEN aco.minlivepositiontaking
                            ELSE @apos end 
          FROM 
            custsetting cs
    INNER JOIN customer as a WITH(NOLOCK) ON cs.custid = a.custid AND a.mrecommend = @mrecommend AND a.roleid = 2
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
    INNER JOIN custoverride as aco WITH(NOLOCK) ON aco.custid = cs.custid  AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
         WHERE 
            cs.sporttype=1 AND cs.bettype in (1,3,7,8) 
           AND cs.mlivepositiontaking+cs.alivepositiontaking > mcs.mlivepositiontaking
        */

        --Recal AUTO MPT m1=min(m3-a1,u2)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
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
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting acs WITH(NOLOCK) ON acs.custid = c.recommend
                                           AND acs.sporttype = cs.sporttype
                                           AND acs.bettype = cs.bettype
         WHERE c.mrecommend = @mrecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (acs.isautompositiontaking = 1
                OR cs.isautompositiontaking = 1
               )


        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
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
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting acs WITH(NOLOCK) ON acs.custid = c.recommend
                                           AND acs.sporttype = cs.sporttype
                                           AND acs.bettype = cs.bettype
         WHERE c.mrecommend = @mrecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (acs.isautolivempositiontaking = 1
                OR cs.isautolivempositiontaking = 1
               )


        --check master min/max
        --m1=n3-a1
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET mpositiontaking = mco.minpositiontaking - cs.apositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
         WHERE cs.apositiontaking + cs.mpositiontaking < mco.minpositiontaking

        
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET mlivepositiontaking = mco.minlivepositiontaking - cs.alivepositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking + cs.mlivepositiontaking < mco.minlivepositiontaking


        -- UPDATE m1,a1 when m1+a1>l3
        -- m1=min(m3,l3)-a1
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET @maxmapos =
                 CASE
                   WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
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
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.apositiontaking + cs.mpositiontaking > mco.maxpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET @maxmapos =
                 CASE
                   WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
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
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking + cs.mlivepositiontaking > mco.maxlivepositiontaking


        --recal autopos
        -- s1=min(s4-m1-a1,u)
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
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
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
         WHERE c.mrecommend = @mrecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (cs.isautopositiontaking = 1
                OR mcs.isautopositiontaking = 1
               )


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET slivepositiontaking =
                 CASE
                   WHEN scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking >
                          CASE
                            WHEN cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking end THEN (case when cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking end)
                            ELSE scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking end 
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
         WHERE c.mrecommend = @mrecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (cs.isautolivepositiontaking = 1
                OR mcs.isautolivepositiontaking = 1
               )


        --check super min/max when a1+m1+s1<n4
        -- s1=n4-m1-a1
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride sco WITH(NOLOCK) ON sco.custid = @srecommend
                                            AND sco.sporttype = cs.sporttype
                                            AND sco.bettype = cs.bettype
         WHERE cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking

        
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET slivepositiontaking = sco.minlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride sco WITH(NOLOCK) ON sco.custid = @srecommend
                                            AND sco.sporttype = cs.sporttype
                                            AND sco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking + cs.mlivepositiontaking + cs.slivepositiontaking < sco.minlivepositiontaking


        --UPDATE s1,m1,a1 in case s1+m1+a1>s4
        --s1=max(0,s4-m1-a1)
        --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
        --@maxmapos=min(m3,l3)
        --@mapos2=min(@mapos1,@maxmapos)
        --@mapos=max(@mapos2,n3)
        --m1=max(0,@mapos-a1)
        --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
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
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
    INNER JOIN custoverride as aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                               AND aco.sporttype = cs.sporttype
                                               AND aco.bettype = cs.bettype
         WHERE cs.spositiontaking + cs.apositiontaking + cs.mpositiontaking > scs.spositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
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
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride sco WITH(NOLOCK) ON sco.custid = @srecommend
                                            AND sco.sporttype = cs.sporttype
                                            AND sco.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.slivepositiontaking + cs.alivepositiontaking + cs.mlivepositiontaking > scs.slivepositiontaking

    END
    ELSE IF @roleid = 2
    BEGIN                
        --Check min max a1: n2<=a1<=l2 => modify a1
        --Nonlive(min)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET apositiontaking = aco.minpositiontaking 
          FROM custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) ON cs.custid = mb.custid AND mb.recommend = @recommend AND mb.roleid = 1
    INNER JOIN custoverride aco with(nolock) ON aco.custid = @recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype 
         WHERE cs.apositiontaking < aco.minpositiontaking 

        --Live(min)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET alivepositiontaking = aco.minlivepositiontaking 
          FROM custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) ON cs.custid = mb.custid AND mb.recommend = @recommend AND mb.roleid = 1
    INNER JOIN custoverride aco with(nolock) ON aco.custid = @recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype 
         WHERE cs.sporttype=1 AND cs.bettype in (1,3,7,8) AND cs.alivepositiontaking < aco.minlivepositiontaking 

        --Nonlive(max)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET apositiontaking = aco.maxpositiontaking 
          FROM custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) ON cs.custid = mb.custid AND mb.recommend = @recommend AND mb.roleid = 1
    INNER JOIN custoverride aco with(nolock) ON aco.custid = @recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype 
         WHERE cs.apositiontaking > aco.maxpositiontaking 

        --Live(max)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET alivepositiontaking = aco.maxlivepositiontaking 
          FROM custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) ON cs.custid = mb.custid AND mb.recommend = @recommend AND mb.roleid = 1
    INNER JOIN custoverride aco with(nolock) ON aco.custid = @recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype 
         WHERE cs.sporttype=1 AND cs.bettype in (1,3,7,8) AND cs.alivepositiontaking > aco.maxlivepositiontaking 

        --Check m1+a1: m1+a1>m3 => modify m1
        --SET m1=m3-a1
        --Nonlive
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET mpositiontaking = macs.mpositiontaking - cs.apositiontaking
          FROM custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) ON cs.custid = mb.custid AND mb.recommend = @recommend AND mb.roleid = 1
    INNER JOIN custsetting macs with(nolock) ON macs.custid = mb.mrecommend AND macs.sporttype = cs.sporttype AND macs.bettype = cs.bettype 
         WHERE cs.apositiontaking + cs.mpositiontaking > macs.mpositiontaking 
        --Live
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET mlivepositiontaking = macs.mlivepositiontaking - cs.alivepositiontaking
          FROM custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) ON cs.custid = mb.custid AND mb.recommend = @recommend AND mb.roleid = 1
    INNER JOIN custsetting macs with(nolock) ON macs.custid = mb.mrecommend AND macs.sporttype = cs.sporttype AND macs.bettype = cs.bettype 
         WHERE cs.sporttype=1 AND cs.bettype in (1,3,7,8) AND cs.alivepositiontaking + cs.mlivepositiontaking > macs.mlivepositiontaking 

        
        --Recal u2
        --Recal AUTO MPT m1=min(m3-a1,u2)
        --Nonlive
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET mpositiontaking = 
                case when mcs.mpositiontaking - cs.apositiontaking >
                 CASE
                   WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking
                            ELSE acs.autompositiontaking end
                    then
                 CASE
                   WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking
                            ELSE acs.autompositiontaking end
                else  mcs.mpositiontaking - cs.apositiontaking end
          FROM
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
    INNER JOIN custsetting as acs WITH(NOLOCK) ON acs.custid = mb.recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype
         WHERE
            mb.recommend = @recommend
           AND mb.roleid = 1
           AND (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
        --Live    
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET mlivepositiontaking =
                case when mcs.mlivepositiontaking - cs.alivepositiontaking >
                 CASE
                   WHEN cs.isautolivempositiontaking = 1 THEN cs.autolivempositiontaking
                            ELSE acs.autolivempositiontaking end
                    then
                 CASE
                   WHEN cs.isautolivempositiontaking = 1 THEN cs.autolivempositiontaking
                            ELSE acs.autolivempositiontaking end
                else  mcs.mlivepositiontaking - cs.alivepositiontaking end
          FROM
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
    INNER JOIN custsetting as acs WITH(NOLOCK) ON acs.custid = mb.recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype
         WHERE cs.sporttype=1 AND cs.bettype in (1,3,7,8)
           AND mb.recommend = @recommend
           AND mb.roleid = 1
           AND (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1)

        --Check min max n3<=m1+a1<=l3 => modify m1
        --Nonlive(min)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
          FROM custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) ON cs.custid = mb.custid AND mb.recommend = @recommend AND mb.roleid = 1
    INNER JOIN custoverride mco with(nolock) ON mco.custid = mb.mrecommend AND cs.sporttype = mco.sporttype AND cs.bettype = mco.bettype 
         WHERE cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking

        --Live(min)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET cs.mlivepositiontaking = mco.minlivepositiontaking - cs.alivepositiontaking
          FROM custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) ON cs.custid = mb.custid AND mb.recommend = @recommend AND mb.roleid = 1
    INNER JOIN custoverride mco with(nolock) ON mco.custid = mb.mrecommend AND cs.sporttype = mco.sporttype AND cs.bettype = mco.bettype 
         WHERE cs.sporttype=1 AND cs.bettype in (1,3,7,8) AND cs.mlivepositiontaking + cs.alivepositiontaking < mco.minlivepositiontaking
        --Nonlive(max)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET cs.mpositiontaking = mco.maxpositiontaking - cs.apositiontaking
          FROM custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) ON cs.custid = mb.custid AND mb.recommend = @recommend AND mb.roleid = 1
    INNER JOIN custoverride mco with(nolock) ON mco.custid = mb.mrecommend AND cs.sporttype = mco.sporttype AND cs.bettype = mco.bettype 
         WHERE cs.mpositiontaking + cs.apositiontaking > mco.maxpositiontaking

        --Live(max)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET cs.mlivepositiontaking = mco.maxlivepositiontaking - cs.alivepositiontaking
          FROM custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) ON cs.custid = mb.custid AND mb.recommend = @recommend AND mb.roleid = 1
    INNER JOIN custoverride mco with(nolock) ON mco.custid = mb.mrecommend AND cs.sporttype = mco.sporttype AND cs.bettype = mco.bettype 
         WHERE cs.sporttype=1 AND cs.bettype in (1,3,7,8) AND cs.mlivepositiontaking + cs.alivepositiontaking > mco.maxlivepositiontaking
        
        --Recal u3,u1
        -- s1=min(s4-m1-a1,u)
        --Nonlive
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET spositiontaking =
                 CASE
                   WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking >
                          CASE
                            WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                            ELSE mcs.autopositiontaking end THEN (case when cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                            ELSE mcs.autopositiontaking end)
                            ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking end 
          FROM
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = mb.srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
         WHERE
            mb.recommend = @recommend
           AND mb.roleid = 1
           AND (cs.isautopositiontaking = 1 or mcs.isautopositiontaking = 1)

        --Live
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET slivepositiontaking =
                 CASE
                   WHEN scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking >
                          CASE
                            WHEN cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking end THEN (case when cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking end)
                            ELSE scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking end 
          FROM
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid 
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = mb.srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
         WHERE cs.sporttype=1 AND cs.bettype in (1,3,7,8) 
           AND mb.recommend = @recommend 
           AND mb.roleid = 1
           AND (cs.isautolivepositiontaking = 1 or mcs.isautolivepositiontaking = 1)

        --check super min/max when a1+m1+s1<n4
        -- s1=n4-m1-a1
        --Nonlive(min)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
          FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
    INNER JOIN custoverride as sco WITH(NOLOCK) ON sco.custid = mb.srecommend  AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype
         WHERE cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking

        --Live(min)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            slivepositiontaking = sco.minlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
          FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
    INNER JOIN custoverride as sco WITH(NOLOCK) ON sco.custid = mb.srecommend  AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype
         WHERE cs.sporttype=1 AND cs.bettype in (1,3,7,8) AND cs.alivepositiontaking+cs.mlivepositiontaking+cs.slivepositiontaking<sco.minlivepositiontaking

        --Nonlive(max)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            spositiontaking = sco.maxpositiontaking - cs.mpositiontaking - cs.apositiontaking
          FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
    INNER JOIN custoverride as sco WITH(NOLOCK) ON sco.custid = mb.srecommend  AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype
         WHERE cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking>sco.maxpositiontaking

        --Live(max)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            slivepositiontaking = sco.maxlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
          FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid AND mb.recommend=@recommend AND mb.roleid=1
    INNER JOIN custoverride as sco WITH(NOLOCK) ON sco.custid = mb.srecommend  AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype
         WHERE cs.sporttype=1 AND cs.bettype in (1,3,7,8) AND cs.alivepositiontaking+cs.mlivepositiontaking+cs.slivepositiontaking>sco.maxlivepositiontaking
    
    END    
END



GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
