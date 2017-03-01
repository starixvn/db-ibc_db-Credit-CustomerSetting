
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMasterLiveCS_CheckParam    Script Date: 8/21/2014 3:12:19 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMasterLiveCS_CheckParam    Script Date: 8/21/2014 2:58:08 PM ******/
CREATE PROCEDURE [dbo].[Acc_CustomerUpdMasterLiveCS_CheckParam]
    @custid        INT,
    @v162spositiontaking_1101    SMALLMONEY,
    @v162mpositiontaking_1101    SMALLMONEY,    
    @isauto_v162spositiontaking_1101 BIT,
    @auto_v162spositiontaking_1101    SMALLMONEY,
    
    @Language    VARCHAR(20) = 'E',    
    @ErrCode    VARCHAR(300) = '' OUTPUT,
    @ErrMsg        NVARCHAR(4000) = '' OUTPUT
 AS
    /*
        Created: Johnson
        Date: 2014-07-25
        Task: Check paramter before update live casino pt on master
        DB: DBTXN/CustDB
        
        Revisions:
            - 20140729@Logan: 1.Exclude disabled agents while updating SM's setting [Redmine: #19631]
                              2.Code aligning on modified parts
        
        Paramter's Explanation:        
    */
BEGIN
    SET NOCOUNT ON 
    
    DECLARE @roleid            TINYINT, 
        @SyncLiveCasino BIT,
        @UserName        VARCHAR(30), 
        @srecommend        INT, 
        @ErrType        VARCHAR(4000),        
        @ErrAcc            NVARCHAR(4000)
        
    SELECT @username = username , @srecommend = srecommend, @SyncLiveCasino = SyncLiveCasino 
    FROM CustInfo WITH(NOLOCK)
    WHERE custid = @custid
    
    IF (@v162spositiontaking_1101 < 0 OR @v162mpositiontaking_1101 < 0
        OR @v162spositiontaking_1101 + @v162mpositiontaking_1101 > 1
        OR @auto_v162spositiontaking_1101 < 0 OR @auto_v162spositiontaking_1101 > 1)
    BEGIN
            Select @ErrMsg =     case @Language 
                                WHEN 'E' THEN 'Wrong position taking.'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                        END, @ErrCode = 100
            RETURN
    END
    
    SELECT @ErrType = ''

    --check n4<=s3+m3<=s4, s3<=s4 if i3 = 0, 
    --m3<=s4 and u3+m3>=n4 if i3 = 1    
    SELECT @ErrType = @ErrType + 'Min: ' + CAST(co.minpositiontaking AS VARCHAR(10)) + ' -Max: ' + CAST(cs.spositiontaking AS VARCHAR(10)) + '<br>'
    FROM CustSettingGame cs WITH(NOLOCK)
        INNER JOIN CustOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype 
    WHERE cs.custid = @srecommend AND cs.sporttype = 162 AND cs.bettype = 1101
        AND ((@isauto_v162spositiontaking_1101 > 0 AND (@v162mpositiontaking_1101 + @auto_v162spositiontaking_1101 < co.minpositiontaking OR @v162mpositiontaking_1101 > cs.spositiontaking))
        OR (@isauto_v162spositiontaking_1101 = 0 AND (@v162spositiontaking_1101 + @v162mpositiontaking_1101 < minpositiontaking OR @v162spositiontaking_1101 + @v162mpositiontaking_1101 > cs.spositiontaking OR @v162spositiontaking_1101 > cs.spositiontaking)))

    IF @ErrType <> ''
    BEGIN    
        SELECT @ErrMsg =     CASE @Language 
                            WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    END, @ErrCode = 101
        RETURN
    END
    
    --a2+m2<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
      FROM CustSettingGame cs WITH(NOLOCK)
INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
     WHERE ci.mrecommend = @custid
       AND ci.roleid     = 2
       AND ci.Enabled    = 1
       AND cs.sporttype  = 162
       AND cs.bettype    = 1101
       AND cs.mpositiontaking + cs.apositiontaking > @v162mpositiontaking_1101

    IF @ErrAcc <> ''
    BEGIN        
        SELECT @ErrMsg = CASE @Language 
                           WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ') .'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                         END
             , @ErrCode = 102
        RETURN
    END

    --a1+m1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
      FROM CustSettingGame cs WITH(NOLOCK)
INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
     WHERE ci.mrecommend = @custid
       AND ci.roleid     = 1
       AND ci.Enabled    = 1
       AND cs.sporttype  = 162
       AND cs.bettype    = 1101
       AND cs.mpositiontaking + cs.apositiontaking > @v162mpositiontaking_1101 

    IF @ErrAcc <> ''
    BEGIN    
        SELECT @ErrMsg =
                 CASE @Language
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ').'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012,@Language) + ' (' + @ErrAcc + ').'
                 END
             , @ErrCode = 103
        RETURN
    END

    --m3>=u2
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
      FROM CustSettingGame cs WITH(NOLOCK)
INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
     WHERE ci.mrecommend = @custid
       AND ci.roleid     = 2
       AND ci.Enabled    = 1
       AND cs.sporttype  = 162
       AND cs.bettype    = 1101
       AND cs.isautompositiontaking = 1
       AND cs.autompositiontaking > @v162mpositiontaking_1101

    IF @ErrAcc <> ''
    BEGIN        
        SELECT @ErrMsg = CASE @Language 
                           WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                         END
             , @ErrCode = 104
        RETURN
    END    

    --check u3<=s4
    SELECT @ErrType = ''

    SELECT @ErrType = @ErrType + 'Max: ' + CAST (cs.spositiontaking AS VARCHAR(10)) + '<br>'
    FROM CustSettingGame cs WITH(NOLOCK)        
    WHERE custid = @srecommend AND sporttype = 162 AND bettype = 1101
        AND @auto_v162spositiontaking_1101 > spositiontaking 

    IF @ErrType <>''    
    BEGIN
        SELECT @ErrMsg =    @UserName + ': '+
                            CASE @Language 
                                WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            END    , @ErrCode = 105
        RETURN
    END

END


GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
