/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_05]
    @srecommend INT = 0,
    @mrecommend INT =0,
    @recommend INT = 0,
    @roleid INT,
    @mode VARCHAR(50),
    --UPDATE auto pt ON master
    -- number game    
    @isauto_v161spositiontaking_81 bit = 0,
    @isauto_v161spositiontaking_83 bit = 0,    
    @isauto_v161spositiontaking_86 bit = 0,
    @isauto_v161spositiontaking_88 bit = 0,
    
    @isauto_v161slivepositiontaking_85 bit = 0,
    @isauto_v161slivepositiontaking_86 bit = 0,
    @isauto_v161slivepositiontaking_87 bit = 0,
    @isauto_v161slivepositiontaking_89 bit = 0,
    @isauto_v161slivepositiontaking_90 bit = 0,
    
    @old_isauto_v161spositiontaking_81 bit = 0,
    @old_isauto_v161spositiontaking_83 bit = 0,    
    @old_isauto_v161spositiontaking_86 bit = 0,
    @old_isauto_v161spositiontaking_88 bit = 0,
    
    @old_isauto_v161slivepositiontaking_85 bit = 0,
    @old_isauto_v161slivepositiontaking_86 bit = 0,
    @old_isauto_v161slivepositiontaking_87 bit = 0,
    @old_isauto_v161slivepositiontaking_89 bit = 0,
    @old_isauto_v161slivepositiontaking_90 bit = 0,
    
    @auto_v161spositiontaking_81 smallmoney = 0,
    @auto_v161spositiontaking_83 smallmoney = 0,    
    @auto_v161spositiontaking_86 smallmoney = 0,
    @auto_v161spositiontaking_88 smallmoney = 0,
    
    @auto_v161slivepositiontaking_85 smallmoney = 0,
    @auto_v161slivepositiontaking_86 smallmoney = 0,
    @auto_v161slivepositiontaking_87 smallmoney = 0,
    @auto_v161slivepositiontaking_89 smallmoney = 0,
    @auto_v161slivepositiontaking_90 smallmoney = 0,
    
    @old_auto_v161spositiontaking_81 smallmoney = 0,
    @old_auto_v161spositiontaking_83 smallmoney = 0,    
    @old_auto_v161spositiontaking_86 smallmoney = 0,
    @old_auto_v161spositiontaking_88 smallmoney = 0,
    
    @old_auto_v161slivepositiontaking_85 smallmoney = 0,
    @old_auto_v161slivepositiontaking_86 smallmoney = 0,
    @old_auto_v161slivepositiontaking_87 smallmoney = 0,
    @old_auto_v161slivepositiontaking_89 smallmoney = 0,
    @old_auto_v161slivepositiontaking_90 smallmoney = 0,
    
    --virtual sports
    @vs_sporttype INT = 0,
    @vs_bettype INT = 0,
    
    @vs_isauto_spositiontaking bit = 0,--is3
    @old_vs_isauto_spositiontaking bit = 0,--is3_old
    
    @vs_auto_spositiontaking smallmoney = 0,--us3
    
   
    --UPDATE auto pt ON agent
    --number game
    @isauto_v161mpositiontaking_81 bit = 0,
    @isauto_v161mpositiontaking_83 bit = 0,
    @isauto_v161mpositiontaking_86 bit = 0,
    @isauto_v161mpositiontaking_88 bit = 0,
    @isauto_v161mlivepositiontaking_85 bit = 0,
    @isauto_v161mlivepositiontaking_86 bit = 0,
    @isauto_v161mlivepositiontaking_87 bit = 0,
    @isauto_v161mlivepositiontaking_89 bit = 0,
    @isauto_v161mlivepositiontaking_90 bit = 0,
    
    @old_isauto_v161mpositiontaking_81 bit = 0,
    @old_isauto_v161mpositiontaking_83 bit = 0,
    @old_isauto_v161mpositiontaking_86 bit = 0,
    @old_isauto_v161mpositiontaking_88 bit = 0,
    @old_isauto_v161mlivepositiontaking_85 bit = 0,
    @old_isauto_v161mlivepositiontaking_86 bit = 0,
    @old_isauto_v161mlivepositiontaking_87 bit = 0,
    @old_isauto_v161mlivepositiontaking_89 bit = 0,
    @old_isauto_v161mlivepositiontaking_90 bit = 0,
    
    @auto_v161mpositiontaking_81 smallmoney = 0,
    @auto_v161mpositiontaking_83 smallmoney = 0,
    --@auto_v161mpositiontaking_85 smallmoney = 0,
    @auto_v161mpositiontaking_86 smallmoney = 0,
    @auto_v161mpositiontaking_88 smallmoney = 0,
    
    @auto_v161mlivepositiontaking_85 smallmoney = 0,
    @auto_v161mlivepositiontaking_86 smallmoney = 0,
    @auto_v161mlivepositiontaking_87 smallmoney = 0,
    @auto_v161mlivepositiontaking_89 smallmoney = 0,
    @auto_v161mlivepositiontaking_90 smallmoney = 0,
    
    @old_auto_v161mpositiontaking_81 smallmoney = 0,
    @old_auto_v161mpositiontaking_83 smallmoney = 0,
    --@old_auto_v161mpositiontaking_85 smallmoney = 0,
    @old_auto_v161mpositiontaking_86 smallmoney = 0,
    @old_auto_v161mpositiontaking_88 smallmoney = 0,
    
    @old_auto_v161mlivepositiontaking_85 smallmoney = 0,
    @old_auto_v161mlivepositiontaking_86 smallmoney = 0,
    @old_auto_v161mlivepositiontaking_87 smallmoney = 0,
    @old_auto_v161mlivepositiontaking_89 smallmoney = 0,
    @old_auto_v161mlivepositiontaking_90 smallmoney = 0,
        
    --virtual sports
    @vs_mpositiontaking_max smallmoney = 0, --m3
    @vs_auto_mpositiontaking smallmoney = 0, --um2
    
    @vs_isauto_mpositiontaking bit = 0, --im2
    @old_vs_isauto_mpositiontaking bit = 0, --old_im2   
    
    @updatepositiontakingv161 bit = 1,        
    @updateautopositiontakingvs bit = 1,    
    --Keno
    @IsAuto_KenoMPositionTaking BIT = 0,
    @Old_IsAuto_KenoMPositionTaking BIT = 0,
    @Auto_KenoMPositionTaking SMALLMONEY = 0,
    @IsAuto_KenoSPositionTaking BIT = 0,
    @Old_IsAuto_KenoSPositionTaking BIT = 0,
    @Auto_KenoSPositionTaking SMALLMONEY = 0,
    @KenoBetType INT = 0,
    @updateautopositiontakingv202 bit = 1,
    
	--GoldDeluxe
    @IsAuto_v255MPositionTaking_1701 BIT = 0,
    @Old_IsAuto_v255MPositionTaking_1701 BIT = 0,
    @Auto_v255MPositionTaking_1701 SMALLMONEY = 0,
    @IsAuto_v255SPositionTaking_1701 BIT = 0,
    @Old_IsAuto_v255SPositionTaking_1701 BIT = 0,
    @Auto_v255SPositionTaking_1701 SMALLMONEY = 0,    
    @UpdateAutoPositiontakingv255 BIT = 1,

    @updateallmembers bit = 0,
    @updatemultiple bit = 0,
    @newspositiontaking smallmoney =0 ,
    @newmpositiontaking smallmoney =0

AS
/*
    Created: Johnson
    Date: 2013-10-29
    Task: Apply execrep when UPDATE auto pt ON master , agent, member levels
    DB: DBCUST/custDB
    Original versions: Acc_CustomerUpdMaster_AutoPositiontaking
                Acc_CustomerUpdAgent_AutoPositiontaking                    
                Acc_CustomerUpdMasterVS_Positiontaking
                Acc_CustomerUpdAgentVS_PositionTaking
                Acc_CustomerUpdMasterLiveCS_Positiontaking
                Acc_CustomerUpdAgentLiveCS_PositionTaking
                Acc_CustomerUpdMasterHR_Positiontaking
                Acc_CustomerUpdAgentHR_PositionTaking
    Revision:
        - 20131104@Johnson: Add virtual sports, live casino, racing
        - 20140320@Patrick: Add more Keno product
        - 20140818@Logan: Exclude disabled members while updating Master setting [Redmine: #19631]
		- 20150422@Elodie: Add Gold Deluxe product [Redmine:#34486]
		- 20150610@Daniel: 
			+ Improve medthod check table existing in subscribers	
			+ Separate custDB to new server DBCUST   		
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20190924@Elodie: 3rd party products - Remove Inactive Products Phase 2 [Redmine: #118699]

    Parameter's Explanation:
*/
BEGIN
    SET NOCOUNT ON

	if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	   AND dbo.f_CheckRepTable('custsetting3rd') = 1 
	   AND dbo.f_CheckRepTable('CustOverride3rd') = 1 
	   AND dbo.f_CheckRepTable('CustSettingGame') = 1
	   AND dbo.f_CheckRepTable('CustOverrideGame') = 1	   
	   )
	RETURN   

    DECLARE
        @bettype int,
        @maxpos smallmoney,
        @autov161positiontaking smallmoney,
        @autov161livepositiontaking smallmoney,
        
        @old_autov161positiontaking smallmoney,
        @old_autov161livepositiontaking smallmoney,
        
        @isautov161positiontaking bit,
        @isautov161livepositiontaking bit,
        
        @old_isautov161positiontaking smallmoney,
        @old_isautov161livepositiontaking smallmoney
        
    --UPDATE min/max pt ON master
    IF @roleid = 3
    BEGIN
        IF @mode = 'number'
        BEGIN                
            DECLARE CUR CURSOR FOR 
                SELECT 81                                 as bettype,
                       @isauto_v161spositiontaking_81     as isautov161positiontaking,
                       0                                  as isautov161livepositiontaking,
                       @auto_v161spositiontaking_81       as autov161positiontaking,
                       0                                  as autov161livepositiontaking,
                       @old_auto_v161spositiontaking_81   as old_autov161positiontaking,
                       0                                  as old_autov161livepositiontaking,
                       @old_isauto_v161spositiontaking_81 as old_isautov161positiontaking,
                       0                                  as old_isauto_v161livepositiontaking
      UNION ALL SELECT 83 as bettype,
                         @isauto_v161spositiontaking_83     as isautov161positiontaking,
                         0                                  as isautov161livepositiontaking,
                         @auto_v161spositiontaking_83       as autov161positiontaking,
                         0                                  as autov161livepositiontaking,
                         @old_auto_v161spositiontaking_83   as old_autov161positiontaking,
                         0                                  as old_autov161livepositiontaking,
                         @old_isauto_v161spositiontaking_83 as old_isautov161positiontaking,
                         0                                  as old_isauto_v161livepositiontaking
      UNION ALL SELECT 88                                 as bettype,
                       @isauto_v161spositiontaking_88     as isautov161positiontaking,
                       0                                  as isautov161livepositiontaking,
                       @auto_v161spositiontaking_88       as autov161positiontaking,
                       0                                  as autov161livepositiontaking,
                       @old_auto_v161spositiontaking_88   as old_autov161positiontaking,
                       0                                  as old_autov161livepositiontaking,
                       @old_isauto_v161spositiontaking_88 as old_isautov161positiontaking,
                       0                                  as old_isauto_v161livepositiontaking
      UNION ALL SELECT 85                                     as bettype,
                       0                                      as isautov161positiontaking,
                       @isauto_v161slivepositiontaking_85     as isautov161livepositiontaking,
                       0                                      as autov161positiontaking,
                       @auto_v161slivepositiontaking_85       as autov161livepositiontaking,
                       0                                      as old_autov161positiontaking,
                       @old_auto_v161slivepositiontaking_85   as old_autov161livepositiontaking,
                       0                                      as old_isautov161positiontaking,
                       @old_isauto_v161slivepositiontaking_85 as old_isautov161livepositiontaking
      UNION ALL SELECT 86                                     as bettype,
                       @isauto_v161spositiontaking_86         as isautov161positiontaking,
                       @isauto_v161slivepositiontaking_86     as isautov161livepositiontaking,
                       @auto_v161spositiontaking_86           as autov161positiontaking,
                       @auto_v161slivepositiontaking_86       as autov161livepositiontaking,
                       @old_auto_v161spositiontaking_86       as old_autov161positiontaking,
                       @old_auto_v161slivepositiontaking_86   as old_autov161livepositiontaking,
                       @old_isauto_v161spositiontaking_86     as old_isautov161positiontaking,
                       @old_isauto_v161slivepositiontaking_86 as old_isautov161livepositiontaking
      UNION ALL SELECT 87                                     as bettype,
                       0                                      as isautov161positiontaking,
                       @isauto_v161slivepositiontaking_87     as isautov161livepositiontaking,
                       0                                      as autov161positiontaking,
                       @auto_v161slivepositiontaking_87       as autov161livepositiontaking,
                       0                                      as old_autov161positiontaking,
                       @old_auto_v161slivepositiontaking_87   as old_autov161livepositiontaking,
                       0                                      as old_isautov161positiontaking,
                       @old_isauto_v161slivepositiontaking_87 as old_isautov161livepositiontaking
      UNION ALL SELECT 89                                     as bettype,
                       0                                      as isautov161positiontaking,
                       @isauto_v161slivepositiontaking_89     as isautov161livepositiontaking,
                       0                                      as autov161positiontaking,
                       @auto_v161slivepositiontaking_89       as autov161livepositiontaking,
                       0                                      as old_autov161positiontaking,
                       @old_auto_v161slivepositiontaking_89   as old_autov161livepositiontaking,
                       0                                      as old_isautov161positiontaking,
                       @old_isauto_v161slivepositiontaking_89 as old_isautov161livepositiontaking
      UNION ALL SELECT 90                                     as bettype,
                       0                                      as isautov161positiontaking,
                       @isauto_v161slivepositiontaking_90     as isautov161livepositiontaking,
                       0                                      as autov161positiontaking,
                       @auto_v161slivepositiontaking_90       as autov161livepositiontaking,
                       0                                      as old_autov161positiontaking,
                       @old_auto_v161slivepositiontaking_90   as old_autov161livepositiontaking,
                       0                                      as old_isautov161positiontaking,
                       @old_isauto_v161slivepositiontaking_90 as old_isautov161livepositiontaking

            OPEN CUR

            FETCH NEXT FROM CUR INTO
                @bettype
              , @isautov161positiontaking, @isautov161livepositiontaking
              , @autov161positiontaking, @autov161livepositiontaking
              , @old_autov161positiontaking, @old_autov161livepositiontaking
              , @old_isautov161positiontaking, @old_isautov161livepositiontaking

            WHILE @@FETCH_STATUS = 0
            BEGIN
                --UPDATE Number game
                IF @bettype IN (81, 83, 86, 88) AND (@autov161positiontaking <> @old_autov161positiontaking or @isautov161positiontaking <> @old_isautov161positiontaking ) AND (@updatepositiontakingv161 = 1 or @updatemultiple=0)
                BEGIN
                    IF @isautov161positiontaking > 0
                    BEGIN
                        SELECT @maxpos = spositiontaking
                          FROM custsetting3rd WITH(NOLOCK)
                         WHERE custid = @srecommend
                           AND sporttype = 161
                           AND bettype = @bettype

                        UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
                           SET spositiontaking =
                                 CASE
                                   WHEN @maxpos - mpositiontaking - apositiontaking > @autov161positiontaking THEN @autov161positiontaking
                                   ELSE @maxpos - mpositiontaking - apositiontaking
                                 END
                          FROM custsetting3rd cs3
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs3.custid = c.custid
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs3.bettype = @bettype
                           AND cs3.sporttype = 161
                           AND cs3.isautopositiontaking = 0

                    END
                    ELSE IF @isautov161positiontaking <> @old_isautov161positiontaking
                    BEGIN
                        IF @updateallmembers = 1
                        BEGIN
                            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
                               SET spositiontaking =
                                     CASE
                                       WHEN mcs3.spositiontaking < @newspositiontaking THEN mcs3.spositiontaking
                                       ELSE @newspositiontaking END
                              FROM custsetting3rd cs3
                        INNER JOIN custInfo c WITH(NOLOCK) ON cs3.custid = c.custid
                        INNER JOIN custsetting3rd mcs3 WITH(NOLOCK) ON mcs3.custid = @mrecommend
                                                                   AND cs3.sporttype = mcs3.sporttype
                                                                   AND cs3.bettype = mcs3.bettype
                             WHERE c.mrecommend = @mrecommend
                               AND c.roleid = 1
                               AND c.Enabled = 1
                               AND cs3.bettype = @bettype
                               AND cs3.sporttype = 161
                               AND cs3.isautopositiontaking = 0
                        END
                    END                    
                END


                -- number game live        
                IF @bettype IN (85, 86, 87, 89, 90)
                   AND (@autov161livepositiontaking <> @old_autov161livepositiontaking
                        OR @isautov161livepositiontaking <> @old_isautov161livepositiontaking
                       )
                   AND (@updatepositiontakingv161 = 1
                        OR @updatemultiple = 0
                       )
                BEGIN
                    IF @isautov161livepositiontaking > 0
                    BEGIN
                        SELECT @maxpos = slivepositiontaking
                          FROM custsetting3rd WITH(NOLOCK)
                         WHERE custid = @srecommend
                           AND sporttype = 161
                           AND bettype = @bettype

                        UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
                           SET slivepositiontaking =
                                 CASE
                                   WHEN @maxpos - mlivepositiontaking - alivepositiontaking > @autov161livepositiontaking THEN @autov161livepositiontaking
                                   ELSE @maxpos - mlivepositiontaking - alivepositiontaking
                                 END
                          FROM custsetting3rd cs3
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs3.custid = c.custid
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs3.bettype = @bettype AND cs3.sporttype=161 AND cs3.isautolivepositiontaking=0

                    END
                    ELSE IF @isautov161livepositiontaking <> @old_isautov161livepositiontaking
                    BEGIN
                        IF @updateallmembers = 1
                        BEGIN
                            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
                               SET slivepositiontaking =
                                     CASE
                                       WHEN mcs.slivepositiontaking < @newspositiontaking THEN mcs.slivepositiontaking
                                       ELSE @newspositiontaking
                                     END
                              FROM custsetting3rd cs3
                        INNER JOIN custInfo c WITH(NOLOCK) ON cs3.custid = c.custid
                        INNER JOIN custsetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                                  AND cs3.sporttype = mcs.sporttype
                                                                  AND cs3.bettype = mcs.bettype
                             WHERE c.mrecommend = @mrecommend
                               AND c.roleid = 1
                               AND c.Enabled = 1
                               AND cs3.bettype = @bettype
                               AND cs3.sporttype = 161
                               AND cs3.isautolivepositiontaking = 0

                        END
                    END 
                END        -- END live

                FETCH NEXT FROM CUR INTO
                    @bettype
                  , @isautov161positiontaking, @isautov161livepositiontaking
                  , @autov161positiontaking, @autov161livepositiontaking
                  , @old_autov161positiontaking, @old_autov161livepositiontaking
                  , @old_isautov161positiontaking, @old_isautov161livepositiontaking

            END

            CLOSE CUR
            DEALLOCATE CUR
        END
        ELSE IF @mode = 'Keno'
        BEGIN
            IF @updateautopositiontakingv202 = 1
            BEGIN
                IF @IsAuto_KenoSPositionTaking > 0 --auto PT is used
                BEGIN
                    --UPDATE use Auto_SPT at master for all members only when:
                    --++(autoSPT at master changes AND isauto at master = 1 OR isauto at master changes FROM 0 to 1)
                    --++AND isauto at member = 0
                    SELECT @maxpos = spositiontaking 
                      FROM dbo.CustSettingGame WITH(NOLOCK) 
                     WHERE custid = @srecommend
                       AND bettype = @KenoBetType
                       AND sporttype = 202

                    UPDATE cs
                       SET cs.spositiontaking =
                             CASE
                               WHEN @maxpos - cs.mpositiontaking - cs.apositiontaking > @Auto_KenoSPositiontaking THEN @Auto_KenoSPositiontaking
                               ELSE @maxpos - cs.mpositiontaking - cs.apositiontaking
                             END
                      FROM dbo.CustSettingGame cs WITH(ROWLOCK, UPDLOCK) 
                INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                     WHERE ci.mrecommend = @mrecommend
                       AND ci.roleid = 1
                       AND ci.Enabled = 1
                       AND cs.bettype = @KenoBetType
                       AND cs.sporttype = 202
                       AND cs.isautopositiontaking = 0 -- only UPDATE members without AutoSPT at member
                END
                ELSE IF @IsAuto_KenoSPositionTaking <> @Old_IsAuto_KenoSPositionTaking  --auto PT is NOT used
                BEGIN
                    IF @Updateallmembers = 1
                    BEGIN
                        --UPDATE a specific SPT for all members only when:
                        --++ @updateallmembers = 1
                        --++ isauto at master = 0
                        --++ AND isauto at master change FROM 1 to 0
                        --++ AND isauto at member = 0
                        UPDATE cs
                           SET cs.spositiontaking =
                                 CASE
                                   WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking
                                   ELSE @newspositiontaking
                                 END
                          FROM dbo.CustSettingGame cs WITH(ROWLOCK, UPDLOCK) 
                    INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                    INNER JOIN dbo.CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                                   AND mcs.sporttype = cs.sporttype
                                                                   AND mcs.bettype = cs.bettype
                         WHERE ci.mrecommend = @mrecommend
                           AND ci.roleid = 1
                           AND ci.Enabled = 1
                           AND cs.bettype = @KenoBetType
                           AND cs.sporttype = 202
                           AND cs.isautopositiontaking = 0
                    END
                END
            END
            ELSE
            BEGIN
                UPDATE cs 
                   SET spositiontaking = b.spositiontaking
                  FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
            INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid
                                               AND ci.mrecommend = @mrecommend
                                               AND ci.roleid = 1
                                               AND ci.Enabled = 1
            INNER JOIN (SELECT 202 AS sporttype
                             , @KenoBetType AS bettype
                             , @IsAuto_KenoSPositionTaking AS isautopositiontaking
                             , @Old_IsAuto_KenoSPositionTaking AS oldisautopositiontaking
                             , @newspositiontaking AS spositiontaking
                       ) b ON b.bettype = cs.bettype
                          AND b.sporttype = cs.sporttype
                 WHERE b.isautopositiontaking = 0 --and b.oldisautopositiontaking = 0 
                   AND cs.isautopositiontaking = 0
            END
        END   
		ELSE IF @mode = 'GoldDeluxe'
        BEGIN
            IF @UpdateAutoPositiontakingv255 = 1
            BEGIN
                IF @IsAuto_v255SPositionTaking_1701 > 0 --auto PT is used
                BEGIN
                    --UPDATE use Auto_SPT at master for all members only when:
                    --++(autoSPT at master changes AND isauto at master = 1 OR isauto at master changes FROM 0 to 1)
                    --++AND isauto at member = 0
                    SELECT @maxpos = spositiontaking 
                      FROM dbo.CustSettingGame WITH(NOLOCK) 
                     WHERE custid = @srecommend
                       AND bettype = 1701
                       AND sporttype = 255

                    UPDATE cs
                       SET cs.spositiontaking =
                             CASE
                               WHEN @maxpos - cs.mpositiontaking - cs.apositiontaking > @Auto_v255SPositionTaking_1701 THEN @Auto_v255SPositionTaking_1701
                               ELSE @maxpos - cs.mpositiontaking - cs.apositiontaking
                             END
                      FROM dbo.CustSettingGame cs WITH(ROWLOCK, UPDLOCK) 
                INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                     WHERE ci.mrecommend = @mrecommend
                       AND ci.roleid = 1
                       AND ci.Enabled = 1
                       AND cs.bettype = 1701
                       AND cs.sporttype = 255
                       AND cs.isautopositiontaking = 0 -- only UPDATE members without AutoSPT at member
                END
                ELSE IF @IsAuto_v255SPositionTaking_1701 <> @Old_IsAuto_v255SPositionTaking_1701  --auto PT is NOT used
                BEGIN
                    IF @Updateallmembers = 1
                    BEGIN
                        --UPDATE a specific SPT for all members only when:
                        --++ @updateallmembers = 1
                        --++ isauto at master = 0
                        --++ AND isauto at master change FROM 1 to 0
                        --++ AND isauto at member = 0
                        UPDATE cs
                           SET cs.spositiontaking =
                                 CASE
                                   WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking
                                   ELSE @newspositiontaking
                                 END
                          FROM dbo.CustSettingGame cs WITH(ROWLOCK, UPDLOCK) 
                    INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                    INNER JOIN dbo.CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                                   AND mcs.sporttype = cs.sporttype
                                                                   AND mcs.bettype = cs.bettype
                         WHERE ci.mrecommend = @mrecommend
                           AND ci.roleid = 1
                           AND ci.Enabled = 1
                           AND cs.bettype = 1701
                           AND cs.sporttype = 255
                           AND cs.isautopositiontaking = 0
                    END
                END
            END
            ELSE
            BEGIN
               UPDATE cs 
               SET spositiontaking = @newspositiontaking
               FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
					INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid
													   AND ci.mrecommend = @mrecommend
													   AND ci.roleid = 1
													   AND ci.Enabled = 1					
				WHERE @IsAuto_v255SPositionTaking_1701 = 0
					AND cs.isautopositiontaking = 0
					AND cs.Sporttype = 255 AND cs.Bettype = 1701
            END
        END    
    END
    ELSE IF @roleid = 2
    BEGIN
        IF @mode = 'number'
        BEGIN
                    Declare CUR CURSOR FOR 
                        SELECT 81 as bettype    ,    @isauto_v161mpositiontaking_81 as isautov161positiontaking    ,                                    0 as isautov161livepositiontaking    ,     @auto_v161mpositiontaking_81 as autov161positiontaking    ,                                        0 as autov161livepositiontaking    ,        @old_auto_v161mpositiontaking_81  as old_autov161positiontaking    ,                                            0 as old_autov161livepositiontaking    ,      @old_isauto_v161mpositiontaking_81  as old_isautov161positiontaking     ,                                            0 as old_isautov161livepositiontaking    
            union all     SELECT 83 as bettype    ,    @isauto_v161mpositiontaking_83 as isautov161positiontaking    ,                                    0 as isautov161livepositiontaking    ,     @auto_v161mpositiontaking_83 as autov161positiontaking    ,                                        0 as autov161livepositiontaking    ,        @old_auto_v161mpositiontaking_83  as old_autov161positiontaking    ,                                            0 as old_autov161livepositiontaking    ,      @old_isauto_v161mpositiontaking_83  as old_isautov161positiontaking     ,                                            0 as old_isautov161livepositiontaking    
            union all      SELECT 85 as bettype    ,                                 0 as isautov161positiontaking    ,     @isauto_v161mlivepositiontaking_85 as isautov161livepositiontaking    ,                                0 as autov161positiontaking    ,       @auto_v161mlivepositiontaking_85 as autov161livepositiontaking    ,                                       0  as old_autov161positiontaking    ,       @old_auto_v161mlivepositiontaking_85 as old_autov161livepositiontaking    ,                                       0  as old_isautov161positiontaking     ,       @old_isauto_v161mlivepositiontaking_85 as old_isautov161livepositiontaking    
            union all     SELECT 86 as bettype    ,    @isauto_v161mpositiontaking_86 as isautov161positiontaking    ,     @isauto_v161mlivepositiontaking_86 as isautov161livepositiontaking    ,     @auto_v161mpositiontaking_86 as autov161positiontaking    ,       @auto_v161mlivepositiontaking_86 as autov161livepositiontaking    ,        @old_auto_v161mpositiontaking_86  as old_autov161positiontaking    ,       @old_auto_v161mlivepositiontaking_86 as old_autov161livepositiontaking    ,      @old_isauto_v161mpositiontaking_86  as old_isautov161positiontaking     ,       @old_isauto_v161mlivepositiontaking_86 as old_isautov161livepositiontaking    
            union all     SELECT 87 as bettype    ,                                0  as isautov161positiontaking    ,     @isauto_v161mlivepositiontaking_87 as isautov161livepositiontaking    ,                                0 as autov161positiontaking    ,       @auto_v161mlivepositiontaking_87 as autov161livepositiontaking    ,                                       0  as old_autov161positiontaking    ,       @old_auto_v161mlivepositiontaking_87 as old_autov161livepositiontaking    ,                                       0  as old_isautov161positiontaking     ,       @old_isauto_v161mlivepositiontaking_87 as old_isautov161livepositiontaking    
            union all     SELECT 88 as bettype    ,    @isauto_v161mpositiontaking_88 as isautov161positiontaking    ,                                    0 as isautov161livepositiontaking    ,     @auto_v161mpositiontaking_88 as autov161positiontaking    ,                                        0 as autov161livepositiontaking    ,        @old_auto_v161mpositiontaking_88  as old_autov161positiontaking    ,                                            0 as old_autov161livepositiontaking    ,      @old_isauto_v161mpositiontaking_88  as old_isautov161positiontaking     ,                                            0 as old_isautov161livepositiontaking    
            union all      SELECT 89 as bettype    ,                                 0 as isautov161positiontaking    ,     @isauto_v161mlivepositiontaking_89 as isautov161livepositiontaking    ,                                0 as autov161positiontaking    ,       @auto_v161mlivepositiontaking_89 as autov161livepositiontaking    ,                                       0  as old_autov161positiontaking    ,       @old_auto_v161mlivepositiontaking_89 as old_autov161livepositiontaking    ,                                       0  as old_isautov161positiontaking     ,       @old_isauto_v161mlivepositiontaking_89 as old_isautov161livepositiontaking
            union all      SELECT 90 as bettype    ,                                 0 as isautov161positiontaking    ,     @isauto_v161mlivepositiontaking_90 as isautov161livepositiontaking    ,                                0 as autov161positiontaking    ,       @auto_v161mlivepositiontaking_90 as autov161livepositiontaking    ,                                       0  as old_autov161positiontaking    ,       @old_auto_v161mlivepositiontaking_90 as old_autov161livepositiontaking    ,                                       0  as old_isautov161positiontaking     ,       @old_isauto_v161mlivepositiontaking_90 as old_isautov161livepositiontaking    
            
            OPEN CUR

            FETCH NEXT FROM CUR INTO
                @bettype, @isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking            
            
            
            --UPDATE use Auto_MPT at agent for all members only when:
            --(autoMPT at agent changes AND isauto at agent = 1
            --OR isauto at agent changes FROM 0 to 1)
            -- m1=min(m3-a1,u2)
            
            --UPDATE a specific MPT for all members only when:
            --@updateallmembers = 1
            --AND isauto at agent = 0
            --AND isauto at agent change FROM 1 to 0
            --m1=min(m2,@newmpositiontaking)
            
            WHILE @@FETCH_STATUS = 0
                BEGIN
                        --UPDATE Number game
                        IF @bettype IN (81,83,86,88) AND (@autov161positiontaking <> @old_autov161positiontaking or @isautov161positiontaking <> @old_isautov161positiontaking ) AND (@updatepositiontakingv161 = 1 or @updatemultiple=0)
                            BEGIN
                                IF @isautov161positiontaking >0 --Use AUTO MPT
                                    BEGIN                 
                                        --m1=min(m3-a1,u2)
                                        SELECT @maxpos = mpositiontaking
                                          FROM custsetting3rd WITH(NOLOCK)
                         WHERE custid = @mrecommend AND sporttype=161 AND bettype = @bettype
                                        UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
                                           SET mpositiontaking =
                                                 CASE
                                                   WHEN @maxpos - apositiontaking > @autov161positiontaking THEN @autov161positiontaking
                                                   ELSE @maxpos - apositiontaking END
                                          FROM custsetting3rd cs3  inner join custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
                         WHERE c.recommend = @recommend AND c.roleid = 1 AND cs3.bettype = @bettype AND cs3.sporttype=161
                            
                                    END
                                else IF @isautov161positiontaking <> @old_isautov161positiontaking --Not use AUTO MPT
                                    BEGIN
                                        IF @updateallmembers = 1 --All member
                                            BEGIN
                                                --m1=min(m2,@newmpositiontaking)
                                                UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
                                           SET mpositiontaking =
                                                 CASE
                                                   WHEN acs3.mpositiontaking<@newmpositiontaking THEN acs3.mpositiontaking
                                                   ELSE @newmpositiontaking END
                                                  FROM custsetting3rd  cs3 inner join custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
                                INNER JOIN custsetting3rd as acs3 WITH(NOLOCK) ON acs3.custid = @recommend AND cs3.sporttype=acs3.sporttype AND cs3.bettype=acs3.bettype
                             WHERE c.recommend = @recommend AND c.roleid = 1 AND cs3.bettype = @bettype AND cs3.sporttype=161
                                
                                            END
                                    END
                            END        
                
                        --UPDATE number game LIVE
                        IF @bettype IN (85, 86, 87, 89, 90) AND (@autov161livepositiontaking <> @old_autov161livepositiontaking or @isautov161livepositiontaking <> @old_isautov161livepositiontaking ) AND (@updatepositiontakingv161 = 1 or @updatemultiple=0)
                            BEGIN
                                IF @isautov161livepositiontaking >0 --Use AUTO_MPT
                                    BEGIN
                                        --m1=min(m3-a1,u2)
                                        SELECT @maxpos = mlivepositiontaking
                                          FROM custsetting3rd WITH(NOLOCK)
                         WHERE custid = @mrecommend AND sporttype=161 AND bettype = @bettype
                                        UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
                                           SET mlivepositiontaking =
                                                 CASE
                                                   WHEN @maxpos - alivepositiontaking > @autov161livepositiontaking THEN @autov161livepositiontaking
                                                   ELSE @maxpos - alivepositiontaking END
                                          FROM custsetting3rd cs3 inner join custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
                         WHERE c.recommend = @recommend AND c.roleid = 1 AND cs3.bettype = @bettype AND cs3.sporttype=161 
                            
                                    END
                                else IF @isautov161livepositiontaking <> @old_isautov161livepositiontaking --Not use AUTO_PT
                                    BEGIN
                                        IF @updateallmembers = 1--UPDATE all member
                                            BEGIN
                                                --m1=min(m2,@newmpositiontaking)
                                                UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
                                           SET mlivepositiontaking =
                                                 CASE
                                                   WHEN acs3.mlivepositiontaking<@newmpositiontaking THEN acs3.mlivepositiontaking
                                                   ELSE @newmpositiontaking END
                                                  FROM custsetting3rd cs3 inner join custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
                                INNER JOIN custsetting3rd as acs3 WITH(NOLOCK) ON acs3.custid = @recommend AND cs3.sporttype=acs3.sporttype AND cs3.bettype=acs3.bettype
                             WHERE c.recommend = @recommend AND c.roleid = 1 AND cs3.bettype = @bettype AND cs3.sporttype=161             
                                
                                            END
                                    END
                            END
                        FETCH NEXT FROM CUR INTO
                            @bettype, @isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking
                    END
            CLOSE CUR
            DEALLOCATE CUR
        END
        ELSE IF @mode = 'Keno'
        BEGIN
            IF @updateautopositiontakingv202 = 1
            BEGIN
                IF @IsAuto_KenoMPositionTaking > 0 --Use AUTO MPT
                BEGIN
                    --m1=min(m3-a1,u2)
                    SELECT @maxpos = mpositiontaking 
                    FROM dbo.CustSettingGame WITH(NOLOCK) 
                   
                         WHERE custid = @mrecommend AND bettype = @KenoBetType AND sporttype = 202
                        
                    UPDATE cs 
                       
                                           SET mpositiontaking =
                                                 CASE
                                                   WHEN @maxpos - apositiontaking > @Auto_KenoMPositionTaking
                                                THEN @Auto_KenoMPositionTaking
                                                   ELSE @maxpos - apositiontaking END
                    FROM dbo.CustSettingGame AS cs WITH(ROWLOCK, UPDLOCK) 
                        INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                   
                         WHERE ci.recommend = @recommend AND ci.roleid = 1
                        AND cs.bettype = @KenoBetType AND cs.sporttype = 202
                END
               
                                                   ELSE IF @IsAuto_KenoMPositionTaking <> @Old_IsAuto_KenoMPositionTaking --Not use AUTO MPT
                BEGIN
                    IF @updateallmembers = 1 --all member
                    BEGIN
                        --m1=min(m2,@newmpositiontaking)
                        UPDATE cs 
                           
                                           SET mpositiontaking =
                                                 CASE
                                                   WHEN acs.mpositiontaking < @newmpositiontaking
                                                    THEN acs.mpositiontaking
                                                   ELSE @newmpositiontaking END
                        FROM dbo.CustSettingGame AS cs WITH(ROWLOCK, UPDLOCK) 
                        INNER JOIN dbo.custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                        INNER JOIN dbo.CustSettingGame AS acs WITH(NOLOCK) 
                            ON acs.custid = @recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype
                       
                         WHERE c.recommend = @recommend AND c.roleid = 1
                            AND cs.bettype = @KenoBetType AND cs.sporttype = 202
                    END
                END
            END
            ELSE
            BEGIN
                UPDATE cs        
                SET mpositiontaking = b.mpositiontaking        
                FROM CustSettingGame as cs WITH(ROWLOCK, UPDLOCK)        
                    INNER JOIN custinfo ci(nolock) ON cs.custid = ci.custid AND ci.recommend = @recommend AND ci.roleid = 1        
                    INNER JOIN         
                    (        
                    SELECT 202 as sporttype, @KenoBettype as bettype, @IsAuto_KenoMPositionTaking as isautopositiontaking, @Old_IsAuto_KenoMPositionTaking as oldisautopositiontaking, @newmpositiontaking as mpositiontaking        
                    ) as b ON b.bettype = cs.bettype AND b.sporttype = cs.sporttype        
                WHERE b.isautopositiontaking = 0 -- AND b.oldisautopositiontaking = 0          
                AND cs.isautompositiontaking = 0 
            END
        END
		ELSE IF @mode = 'GoldDeluxe'
        BEGIN
            IF @UpdateAutoPositiontakingv255 = 1
            BEGIN
                IF @IsAuto_v255MPositionTaking_1701 > 0 --Use AUTO MPT
                BEGIN
                    --m1=min(m3-a1,u2)
                    SELECT @maxpos = mpositiontaking 
                    FROM dbo.CustSettingGame WITH(NOLOCK)                    
                    WHERE custid = @mrecommend AND bettype = 1701 AND sporttype = 255
                        
                    UPDATE cs 
                       
                    SET mpositiontaking = CASE WHEN @maxpos - apositiontaking > @Auto_v255MPositionTaking_1701 THEN @Auto_v255MPositionTaking_1701 ELSE @maxpos - apositiontaking END
					FROM dbo.CustSettingGame AS cs WITH(ROWLOCK, UPDLOCK) 
						INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid                   
					WHERE ci.recommend = @recommend AND ci.roleid = 1
						AND cs.bettype = 1701 AND cs.sporttype = 255
                END
               
                ELSE IF @IsAuto_v255MPositionTaking_1701 <> @Old_IsAuto_v255MPositionTaking_1701 --Not use AUTO MPT
                BEGIN
                    IF @updateallmembers = 1 --all member
                    BEGIN
                        --m1=min(m2,@newmpositiontaking)
                        UPDATE cs                            
                        SET mpositiontaking = CASE WHEN acs.mpositiontaking < @newmpositiontaking THEN acs.mpositiontaking ELSE @newmpositiontaking END
                        FROM dbo.CustSettingGame AS cs WITH(ROWLOCK, UPDLOCK) 
							INNER JOIN dbo.custinfo c WITH(NOLOCK) ON cs.custid = c.custid
							INNER JOIN dbo.CustSettingGame AS acs WITH(NOLOCK)  ON acs.custid = @recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype                       
                         WHERE c.recommend = @recommend AND c.roleid = 1
                            AND cs.bettype = 1701 AND cs.sporttype = 255
                    END
                END
            END
            ELSE
            BEGIN
                UPDATE cs        
                SET mpositiontaking = @newmpositiontaking       
                FROM CustSettingGame as cs WITH(ROWLOCK, UPDLOCK)        
                    INNER JOIN custinfo ci(nolock) ON cs.custid = ci.custid AND ci.recommend = @recommend AND ci.roleid = 1        
                WHERE @IsAuto_v255MPositionTaking_1701 = 0
					AND cs.isautompositiontaking = 0 
					AND cs.Sporttype = 255 AND cs.Bettype = 1701
            END
        END
    END
END

GO