USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMasterVS_Positiontaking]    Script Date: 6/6/2015 6:03:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMasterVS_Positiontaking    Script Date: 8/28/2014 2:05:04 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMasterVS_Positiontaking    Script Date: 8/21/2014 3:12:18 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMasterVS_Positiontaking    Script Date: 8/21/2014 2:58:06 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterVS_Positiontaking]
    @custid        INT,    
    
    @sporttype    INT,
    @bettype    INT,
    
    @s3            SMALLMONEY = 0,
    @m3            SMALLMONEY = 0,
    @us3        SMALLMONEY = 0,
    @is3        BIT = 0,
    @n3            SMALLMONEY = 0,
    
    @updateallmembers BIT = 0,    
    @s1        SMALLMONEY = 0,
    
    @UpdatePositiontaking        BIT = 0,
    @UpdateAutoPositiontaking    BIT = 0,
    @UpdateMinPositiontaking    BIT = 0,    
    
    @SubAccID    INT = 0,
    @userid        INT,
    @IP            VARCHAR(50)= '',
    @Language    VARCHAR(20) = 'E',        
    @ErrCode    VARCHAR(300) = '' OUTPUT,
    @ErrMsg        NVARCHAR(4000) = '' OUTPUT
 AS
    /*
        Created: Johnson
        Date: 2012-08-14
        Task: Update setting virtual sports for master
        DB: DBCUST/CustDB
        
        Revisons:
            - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
            - 20130205@Lukas: fix bug - do not apply new s1 from popup when uncheck auto PT
            - 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
            - 20131101@Johnson: apply execrep when update min pt, auto pt 
                            and check total downlines before UPDATEs 
            - 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)
            - 20140728@Logan: 1.Exclude disabled agents while updating master's settings
                              2.Code aligning            
			- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines, Acc_CustomerSelCheckEnable to DBCUST.CustDB, Use temp table for sports, bettype table, 
																Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID)
			- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
			
        Parameter's Explanation:
    */
SET NOCOUNT ON 
-----------------------------
    DECLARE @startRun    DATETIME,
            @endRun        DATETIME,
            @duration    INT,
            
            @s3_old        SMALLMONEY,
            @m3_old        SMALLMONEY,
            @us3_old    SMALLMONEY,
            @is3_old    BIT,
            @n3_old        SMALLMONEY,                        
            
            @srecommend    INT,
            @roleid        TINYINT, 
            @UserName    NVARCHAR(20),
            @ErrCode_Cur INT, 
            @ErrMsg_Cur NVARCHAR(4000), 
            @ErrAcc        NVARCHAR(4000),
            @ErrType    NVARCHAR(4000)
            
    SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''
        
    SET @startRun = GETDATE()
    
    Select @UserName  = username, @srecommend = srecommend 
    from custinfo with (NOLOCK) 
    where CustID = @CustID

	
	----- Elodie @ 01 JUN 2015 -------------------
	DECLARE @tmp_Sports TABLE (SportType TINYINT, SportName NVARCHAR(50))
	DECLARE @tmp_Bettype TABLE (TypeID INT, TypeNamee NVARCHAR(50))
	
	BEGIN TRY
		INSERT INTO @tmp_Sports (SportType, SportName)
		SELECT SportType, SportName FROM DBAGE.bodb02.dbo.Sports WITH (NOLOCK)		
	END TRY
	BEGIN CATCH
		INSERT INTO @tmp_Sports (SportType, SportName)
		SELECT SportType, SportName FROM DBTXN.bodb02.dbo.Sports WITH (NOLOCK)	
	END CATCH

	BEGIN TRY			
		INSERT INTO @tmp_Bettype (TypeID, TypeNamee)
		SELECT TypeID, TypeNamee FROM DBAGE.bodb02.dbo.Bettype WITH (NOLOCK)
	END TRY
	BEGIN CATCH		
		INSERT INTO @tmp_Bettype (TypeID, TypeNamee)
		SELECT TypeID, TypeNamee FROM DBTXN.bodb02.dbo.Bettype WITH (NOLOCK)
	END CATCH
----- /Elodie @ 01 JUN 2015 -------------------

    ---------------------------
    -- ***Check Downline Belonging***
    EXEC Age_CustomerSelCheckBelongingByCustID
        @SessionCustID = @Userid, 
        @Custid = @custid,
        @roleid = @roleid OUTPUT
        IF (@roleid = 0) RETURN
    ---------------------------

	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
    --Check disable user
    EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
    IF @ErrCode_Cur > 0
    BEGIN
        select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
        return
    END
    --end
    
    ---- Johnson@20131104: Checking total downlines before UPDATEs 
    EXEC Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
        @roleid=3,
        @isExecRep=1,
        @isUpdatePT = 1,
        @Sporttype = 1,
        @Language='E',
        @ErrMsg=@ErrMsg_Cur output,
        @ErrCode=@ErrCode_Cur output
    IF @ErrCode_Cur > 0
    BEGIN
        select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
        return
    END  
        
    --Get old values for tracking 
    SELECT @s3_old        = mcs.spositiontaking,
            @m3_old        = mcs.mpositiontaking,
            @us3_old    = mcs.autopositiontaking,
            @is3_old    = mcs.isautopositiontaking,
            @n3_old        = mco.minpositiontaking
    FROM custsetting3rd mcs WITH(NOLOCK)
        INNER JOIN custoverride3rd mco WITH(NOLOCK) ON mcs.custid = mco.custid AND mcs.sporttype = mco.sporttype AND mcs.bettype = mco.bettype
    WHERE mcs.custid = @custid AND mcs.sporttype = @sporttype AND mcs.bettype = @bettype
    
    IF @UpdateMinPositiontaking = 1
    BEGIN
        --check min(m3,m4)>=n3
        select @ErrAcc = ''        
        select top 100 @ErrAcc = @ErrAcc + username + ', '
        from 
            customer as c with (NOLOCK) 
            inner join custsetting3rd as cs with (NOLOCK) on c.custid = cs.custid        
            inner join (
                    select     @sporttype as sporttype, @bettype as bettype, @n3 as minpositiontaking                    
                ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
            inner join custsetting3rd as scs with (NOLOCK) on scs.custid = c.srecommend and scs.sporttype = b.sporttype and scs.bettype = b.bettype
        where cs.custid = @custid and 
                (@m3<b.minpositiontaking or scs.mpositiontaking < b.minpositiontaking)
        group by username
        
        if @ErrAcc<>''
        BEGIN
            select @ErrCode = 109
            Select @ErrMsg =     case @Language 
                                when 'E' then 'Current account position taking violates new minimum position taking setting' + ' ('+@ErrAcc+').'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](30004,@Language) + ' ('+@ErrAcc+').'
                        end
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
                    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
                                
            RETURN
        END
    END
    
    IF @UpdatePositiontaking = 1 OR @UpdateAutoPositiontaking = 1
    BEGIN 
        IF (@s3 < 0 OR @m3 < 0
            OR @s3 + @m3 > 0.9
            OR @us3 < 0 OR @us3 > 0.9)
        BEGIN
            Select @ErrMsg_Cur = case @Language 
                                    WHEN 'E' THEN 'Wrong position taking.'
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                            END, @ErrCode_Cur = 100
                        
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
        
            RETURN
        END
        
        --check n4<=s3+m3<=l4 if i3 = 0, 
        --m3<=l4 and u3+m3>=n4 if i3 = 1
        SELECT @ErrType = ''
        
        SELECT @ErrType = 'Min: '+ CAST((co.minpositiontaking) AS VARCHAR(10))+ '-Max: '+ CAST((co.maxpositiontaking) AS VARCHAR(10))+ '<br>'
        FROM custoverride3rd as co WITH (NOLOCK) 
            INNER JOIN (
                            SELECT @bettype as bettype, 
                                    @sporttype as sporttype, 
                                    @s3 as spositiontaking, 
                                    @m3 as mpositiontaking, 
                                    @is3 as isauto_spositiontaking, 
                                    @us3 as auto_spositiontaking 
                        ) as b ON co.sporttype = b.sporttype AND co.bettype = b.bettype
        WHERE co.custid = @srecommend AND (    
                        ((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
                        (b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking))
                    )
        IF @ErrType <>''
        BEGIN
            SELECT @ErrMsg_Cur = CASE @Language 
                                    WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                        END, @ErrCode_Cur = 101
                        
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
        
            RETURN
        END
        
        --n3<=m3<=l3
        select @ErrType = ''
        select @ErrType = @ErrType + s.SportName + ' - ' + typenamee 
            + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
        from custoverride3rd as co with (NOLOCK) inner join
            (
                select @bettype as bettype, @sporttype as sporttype, @s3 as spositiontaking, @m3 as mpositiontaking, @is3 as isauto_spositiontaking, @n3 as minpositiontaking
            ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
            INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
            INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        where co.custid = @custid and (    
                            (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<b.minpositiontaking)        
                        )
        if @ErrType <>''
        BEGIN
            select @ErrCode_cur = 102
            Select @ErrMsg_Cur = @UserName + ': '+
                        case @Language 
                                when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                        end
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
                    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
            RETURN            
        END
                    
        --m2+a2<=m3
        SELECT @ErrAcc = ''
        
        SELECT top 100 @ErrAcc = @ErrAcc + username + ', '
          FROM custinfo ci WITH(NOLOCK) 
    INNER JOIN CustSetting3rd cs with(NOLOCK) on ci.custid = cs.custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype
         WHERE ci.mrecommend = @custid
           AND ci.roleid     = 2
           AND ci.Enabled    = 1
           AND cs.mpositiontaking + cs.apositiontaking > @m3
      GROUP BY username
        
        IF @ErrAcc <> ''
        BEGIN            
            SELECT @ErrMsg_cur = CASE @Language 
                                   WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                                 END
                 , @ErrCode_Cur = 103

            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
                 , @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

            RETURN    
        END

        --m1+a1<=m3
        SELECT @ErrAcc = ''
        
        SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
          FROM custinfo ci WITH(NOLOCK) 
    INNER JOIN CustSetting3rd cs WITH(NOLOCK) ON ci.custid = cs.custid
                                             AND cs.sporttype = @sporttype
                                             AND cs.bettype = @bettype
         WHERE ci.mrecommend = @custid
           AND ci.roleid     = 1
           AND ci.Enabled    = 1
           AND cs.mpositiontaking + cs.apositiontaking > @m3
      GROUP BY username

        IF @ErrAcc <> ''
        BEGIN            
            SELECT @ErrMsg_Cur =
                     CASE @Language 
                       WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') .'
                       ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
                     END
                 , @ErrCode_Cur = 104

            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
                 , @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

            RETURN    
        END
        
        --check m3<=m4
        SELECT @ErrType = ''
        SELECT @ErrType = 'Max: '+ CAST((scs.mpositiontaking) AS VARCHAR(10)) + '<br>'
        FROM CustSetting3rd as scs WITH (NOLOCK)
        WHERE custid = @srecommend AND sporttype = @sporttype AND bettype = @bettype
            AND scs.mpositiontaking < @m3
        
        IF @ErrType <>''
        BEGIN            
            SELECT @ErrMsg_Cur = CASE @Language                                     
                                    when 'E' then 'Wrong position taking (max for master set by company).' + '<br>' + @ErrType
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20003,@Language) + '<br>' + @ErrType
                            END, @ErrCode_Cur = 105
                            
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
                    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
                    
            RETURN    
        END
        
        --m3>=u2
        SELECT @ErrAcc = ''
        
        SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
          FROM custinfo ci WITH(NOLOCK)
    INNER JOIN CustSetting3rd cs WITH(NOLOCK) ON ci.custid = cs.custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype
         WHERE ci.mrecommend = @custid
           AND ci.roleid     = 2
           AND ci.Enabled    = 1
           AND cs.autompositiontaking > @m3
           and cs.isautompositiontaking = 1
      GROUP BY username

        IF @ErrAcc <> ''
        BEGIN        
            SELECT @ErrMsg_Cur = CASE @Language 
                                   WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                                 END
                 , @ErrCode_Cur = 106

            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
                 , @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

            RETURN    
        END
        
        --u3<=s4
        SELECT @ErrType = ''
        SELECT @ErrType = 'Max: '+ CAST((cs.spositiontaking) AS VARCHAR(10)) + '<br>'
        FROM CustSetting3rd AS cs WITH (NOLOCK)
        WHERE cs.custid = @srecommend AND cs.sporttype = @sporttype AND cs.bettype = @bettype
            AND cs.spositiontaking < @us3
            
        IF @ErrType <>''
        BEGIN
            SELECT @ErrMsg_Cur = CASE @Language 
                                    WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                                END, @ErrCode_Cur = 107
                                
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
                    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
                    
            RETURN    
        END
        
        --u3>=Max(0, N4-M4)        
        SELECT @ErrType = ''
        SELECT @ErrType = 'Min: '+ CAST((case when co.minpositiontaking - cs.mpositiontaking > 0 then co.minpositiontaking - cs.mpositiontaking else 0 end) AS VARCHAR(10))+ '<br>'
        FROM CustSetting3rd AS cs WITH (NOLOCK)
            JOIN custoverride3rd as co WITH (NOLOCK) ON co.custid=cs.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype
        WHERE cs.custid = @srecommend AND cs.sporttype = @sporttype AND cs.bettype = @bettype
            AND (@is3 >0 and @us3< case when co.minpositiontaking - cs.mpositiontaking > 0 then co.minpositiontaking - cs.mpositiontaking else 0 end)
        
        IF @ErrType <>''
        BEGIN
            SELECT @ErrMsg_Cur = CASE @Language 
                                    WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                                END, @ErrCode_Cur = 111
            
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
                    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
                    
            RETURN
        END    
                        
        
        --s3<=s4,s3+m3<=s4
        SELECT @ErrType = ''
        SELECT @ErrType = 'Max: '+ CAST((cs.spositiontaking) AS VARCHAR(10))+ '<br>'
        FROM CustSetting3rd AS cs WITH (NOLOCK)
        WHERE custid = @srecommend AND sporttype = @sporttype AND bettype = @bettype
            AND (spositiontaking < @s3 OR @s3 + @m3 > spositiontaking)
        
        IF @ErrType <>''
        BEGIN
            SELECT @ErrMsg_Cur = CASE @Language 
                                    WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                                END, @ErrCode_Cur = 108
            
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
                    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
                    
            RETURN
        END
        
        --s3>=Max(0, N4-M4)        
        SELECT @ErrType = ''
        SELECT @ErrType = 'Min: '+ CAST((case when co.minpositiontaking - cs.mpositiontaking > 0 then co.minpositiontaking - cs.mpositiontaking else 0 end) AS VARCHAR(10))+ '<br>'
        FROM CustSetting3rd AS cs WITH (NOLOCK)
            JOIN custoverride3rd as co WITH (NOLOCK) ON co.custid=cs.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype
        WHERE cs.custid = @srecommend AND cs.sporttype = @sporttype AND cs.bettype = @bettype
            AND (@is3 = 0 and 
            @s3< case when co.minpositiontaking - cs.mpositiontaking > 0 then co.minpositiontaking - cs.mpositiontaking else 0 end)
        
        IF @ErrType <>''
        BEGIN
            SELECT @ErrMsg_Cur = CASE @Language 
                                    WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                                END, @ErrCode_Cur = 110
            
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
                    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
                    
            RETURN
        END        
    END    
    -- end check param
    
    -- update min PT
    IF @UpdateMinPositiontaking = 1
    BEGIN                
                                EXEC Acc_CustOverrideUpdVS
            @custid        = @custid, 
            @sporttype    = @sporttype,
            @bettype    = @bettype,
            
            @positiontaking_min = @n3,
            @UpdateMinPos = 1,
            @UpdateMaxPos = 0,
            
            @SubAccID    = @SubAccID, 
            @WriteLog    = 0,
            @IP            = @IP, 
            @UserID        = @UserID, 
            @Language    = @Language, 
            @ErrCode    = @ErrCode_Cur OUTPUT, 
            @ErrMsg        = @ErrMsg_Cur OUTPUT
        
        IF @ErrCode_Cur > 0
        BEGIN
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
            RETURN    
        END
        ELSE
        BEGIN
            SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), 
                    @ErrMsg = @ErrMsg + CHAR(7)                    
        END
    END    
        
    DECLARE @maxpos SMALLMONEY
    -- update PT    
    IF @UpdatePositiontaking = 1 
    BEGIN 
        UPDATE CustSetting3rd WITH(UPDLOCK,ROWLOCK)
        SET spositiontaking = @s3, mpositiontaking = @m3
        WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype 

        IF (@@error <> 0)
        BEGIN
            SELECT @ErrMsg_Cur = CASE @Language 
                                    WHEN 'E' THEN 'Update process is unsuccessful !'
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                                END    , @ErrCode_Cur = 300
                                                 
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)                
            RETURN        
        END        
    END            
    
    IF @UpdateAutoPositiontaking = 1 
    BEGIN
        --Update Master Agent account (autopositiontaking field)
        UPDATE CustSetting3rd WITH(UPDLOCK,ROWLOCK)
        SET autopositiontaking = @us3, isautopositiontaking = @is3
        WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype
        
        IF @@Error <> 0
        BEGIN            
            SELECT @ErrMsg_cur =  
                CASE @Language 
                    WHEN 'E' THEN 'Error updating auto position taking'
                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                END    ,  @ErrCode_Cur = 301
                
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
            RETURN                        
        END        
        
        --20131101@Johnson: apply execrep when update auto pt
                                EXEC dbo.Acc_CustSetting3rd_05
            @srecommend = @srecommend,
            @mrecommend = @custid,
            @roleid = 3,
            @mode = 'virtual-sports',
            
            @vs_sporttype = @sporttype,
            @vs_bettype = @bettype,
            
            @vs_isauto_spositiontaking = @is3,--is3
            @old_vs_isauto_spositiontaking = @is3_old,--is3_old
            
            @vs_auto_spositiontaking = @us3,--us3
                
            @updateallmembers = @updateallmembers,            
            @updateautopositiontakingvs = 1,
            @newspositiontaking = @s1
            
        /*            
        IF @is3 >0 --auto PT is used
        BEGIN
            --Update use Auto_SPT at master for all members only when:
                --(autoSPT at master changes AND isauto at master = 1
                --OR isauto at master changes from 0 to 1)
                --AND isauto at member = 0
            
            
            SELECT @maxpos = spositiontaking 
            FROM CustSetting3rd with (NOLOCK) 
            WHERE custid = @srecommend and sporttype= @sporttype and bettype = @bettype
            
            UPDATE cs
            SET cs.spositiontaking = CASE WHEN @maxpos - cs.mpositiontaking - cs.apositiontaking > @us3 THEN @us3 ELSE @maxpos - cs.mpositiontaking - cs.apositiontaking END
            FROM CustSetting3rd cs WITH(NOLOCK)
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
            WHERE ci.mrecommend = @custid AND ci.roleid = 1 
                AND cs.sporttype = @sporttype AND cs.bettype = @bettype
                AND cs.isautopositiontaking = 0 -- only update members without AutoSPT at member
        
            IF @@Error <> 0
            BEGIN                    
                SELECT @ErrMsg_Cur =  
                    CASE @Language 
                        WHEN 'E' THEN 'Error updating auto position taking'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                    END    , @ErrCode_Cur = 302
                
                SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
                RETURN    
            END
        END
        ELSE IF @is3 <> @is3_old  --auto PT is NOT used
        BEGIN
            IF @Updateallmembers = 1
            BEGIN
            --Update a specific SPT for all members only when:
                        -- @updateallmembers = 1
                        -- isauto at master = 0
                        --AND isauto at master change from 1 to 0
                        --AND isauto at member = 0
                            
                SELECT @maxpos = spositiontaking 
                FROM CustSetting3rd with (NOLOCK) 
                WHERE custid = @srecommend and sporttype= @sporttype and bettype = @bettype
            
                UPDATE cs
                SET cs.spositiontaking = CASE WHEN @s1 > @maxpos - mcs.mpositiontaking THEN @maxpos - mcs.mpositiontaking ELSE @s1 END
                FROM CustSetting3rd cs
                    INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                    INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @custid AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
                WHERE ci.mrecommend = @custid AND ci.roleid = 1
                    AND cs.sporttype = @sporttype AND cs.bettype = @bettype
                    AND cs.isautopositiontaking = 0
                
                IF @@Error <> 0
                BEGIN
                    SELECT @ErrMsg_Cur =  
                        CASE @Language 
                            WHEN 'E' THEN 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        END    ,  @ErrCode_Cur =303
                    
                    SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
                            @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
                    RETURN            
                END
            END
        END    */        
    END
    
    --apply new value position taking for super on members
    IF @UpdatePositiontaking=1 AND @UpdateAutoPositiontaking = 0 AND
        @Updateallmembers = 1 AND @is3=0
    BEGIN
                                EXEC dbo.Acc_CustSetting3rd_05
            @srecommend = @srecommend,
            @mrecommend = @custid,
            @roleid = 3,
            @mode = 'virtual-sports',
            
            @vs_sporttype = @sporttype,
            @vs_bettype = @bettype,
            
            @vs_isauto_spositiontaking = @is3,--is3
            @old_vs_isauto_spositiontaking = @is3_old,--is3_old
                                    
            @updateautopositiontakingvs = 0,
            @newspositiontaking = @s1
        /*
        UPDATE cs 
        SET spositiontaking = b.spositiontaking
        FROM CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            INNER JOIN custinfo ci (nolock) on ci.custid = cs.custid and ci.mrecommend = @custid and ci.roleid = 1
            INNER JOIN 
                (
                    select @sporttype as sporttype, @bettype as bettype, @is3 as isautopositiontaking, @is3_old as oldisautopositiontaking, @s1 as spositiontaking
                ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
        WHERE b.isautopositiontaking = 0 --and b.oldisautopositiontaking = 0 
            and cs.isautopositiontaking = 0
        
        IF (@@error <> 0)
        BEGIN        
            SELECT @ErrMsg_Cur = CASE @Language 
                                    WHEN 'E' THEN 'Update process is unsuccessful !'
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                                END, @ErrCode_Cur = 305             
            
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
                            @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)        
            RETURN                
        END
        */
    END
    
    IF @UpdateAutoPositiontaking = 1 OR @UpdatePositiontaking = 1
    BEGIN
                                EXEC dbo.Acc_CustSetting3rd_07
            @srecommend = @srecommend , 
            @mrecommend = @custid,
            @roleid = 3,
            @mode = 'virtual-sports',
            
            @sporttype = @sporttype,
            @bettype = @bettype
             
            IF (@@error <> 0)
            BEGIN        
                SELECT @ErrMsg_Cur = CASE @Language 
                                        WHEN 'E' THEN 'Update process is unsuccessful !'
                                        ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                                    END, @ErrCode_Cur = 304             
                
                SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
                                @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)        
                RETURN                
            END
            ELSE
            BEGIN
                SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), 
                            @ErrMsg = @ErrMsg + CHAR(7)
            END
        /*
        EXEC dbo.Acc_CustomerUpdMasterVS_MaxPositiontaking @sporttype = @sporttype, @bettype = @bettype, @srecommend = @srecommend , @mrecommend = @custid
        
        IF (@@error <> 0)
        BEGIN        
            SELECT @ErrMsg_Cur = CASE @Language 
                                    WHEN 'E' THEN 'Update process is unsuccessful !'
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                                END, @ErrCode_Cur = 304             
            
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
                            @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)        
            RETURN                
        END
        ELSE
        BEGIN
            SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), 
                        @ErrMsg = @ErrMsg + CHAR(7)
        END*/
    END

    
    DECLARE @LogSPData VARCHAR(MAX),
        @TrackingValueDB VARCHAR(4000)
     
    SELECT @LogSPData = '<Acc_CustomerUpdMasterVS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
    'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
    'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
    's3="' + COALESCE(CAST(@s3 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'm3="' + COALESCE(CAST(@m3 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'is3="' + COALESCE(CAST(@is3 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'us3="' + COALESCE(CAST(@us3 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'n3="' + COALESCE(CAST(@n3 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'UpdatePositiontaking="' + COALESCE(CAST(@UpdatePositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
    'UpdateAutoPositiontaking="' + COALESCE(CAST(@UpdateAutoPositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
    'UpdateMinPositiontaking="' + COALESCE(CAST(@UpdateMinPositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
    'updateallmembers="' + COALESCE(CAST (@updateallmembers AS VARCHAR(3)), SPACE(1)) + '" ' +
    's1="' + COALESCE(CAST (@s1 AS VARCHAR(30)), SPACE(1)) + '" ' +    
    'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />' 
    
    SELECT @TrackingValueDB = '<Acc_CustomerUpdMasterVS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
    'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
    'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
    's3="' + COALESCE(CAST(@s3_old AS VARCHAR(50)),SPACE(1)) + '" ' +
    'm3="' + COALESCE(CAST(@m3_old AS VARCHAR(50)),SPACE(1)) + '" ' +
    'is3="' + COALESCE(CAST(@is3_old AS VARCHAR(50)),SPACE(1)) + '" ' +
    'us3="' + COALESCE(CAST(@us3_old AS VARCHAR(50)),SPACE(1)) + '" ' +
    'n3="' + COALESCE(CAST(@n3_Old AS VARCHAR(50)),SPACE(1)) + '" ' +
    'UpdatePositiontaking="' + COALESCE(CAST(@UpdatePositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
    'UpdateAutoPositiontaking="' + COALESCE(CAST(@UpdateAutoPositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
    'UpdateMinPositiontaking="' + COALESCE(CAST(@UpdateMinPositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
    'updateallmembers="' + COALESCE(CAST (@updateallmembers AS VARCHAR(3)), SPACE(1)) + '" ' +
    's1="' + COALESCE(CAST (@s1 AS VARCHAR(30)), SPACE(1)) + '" ' +    
    'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />' 
        
        
    SET @endRun = GETDATE()
    SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

    --Log customer info 
    BEGIN TRY
        EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 433,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END TRY
    BEGIN CATCH
        SELECT @LogSPData = '<Acc_CustomerUpdMasterVS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
        'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
        'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
        's3="' + COALESCE(CAST(@s3 AS VARCHAR(50)),SPACE(1)) + '" ' +
        'm3="' + COALESCE(CAST(@m3 AS VARCHAR(50)),SPACE(1)) + '" ' +
        'is3="' + COALESCE(CAST(@is3 AS VARCHAR(50)),SPACE(1)) + '" ' +
        'us3="' + COALESCE(CAST(@us3 AS VARCHAR(50)),SPACE(1)) + '" ' +
        'n3="' + COALESCE(CAST(@n3 AS VARCHAR(50)),SPACE(1)) + '" ' +
        'UpdatePositiontaking="' + COALESCE(CAST(@UpdatePositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
        'UpdateAutoPositiontaking="' + COALESCE(CAST(@UpdateAutoPositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
        'UpdateMinPositiontaking="' + COALESCE(CAST(@UpdateMinPositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
        'updateallmembers="' + COALESCE(CAST (@updateallmembers AS VARCHAR(3)), SPACE(1)) + '" ' +
        's1="' + COALESCE(CAST (@s1 AS VARCHAR(30)), SPACE(1)) + '" ' +    
        'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
        'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
        'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
        'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
        'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
        'ErrMsg="'+ ERROR_MESSAGE() + '" />' 
        
        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 433,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END CATCH

GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterVS_Positiontaking] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterVS_Positiontaking] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterVS_Positiontaking] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterVS_Positiontaking] TO [bodbExtAccNet]
GO 
