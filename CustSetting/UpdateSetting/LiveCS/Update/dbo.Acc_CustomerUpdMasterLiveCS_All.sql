ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterLiveCS_All]
    @custid        INT,
    @srecommend INT,
    @v162spositiontaking_1101    SMALLMONEY,
    @v162mpositiontaking_1101    SMALLMONEY,
    
    @isauto_v162spositiontaking_1101 BIT,
    @auto_v162spositiontaking_1101    SMALLMONEY,
    @v162mpositiontaking_1101_min    SMALLMONEY,
    @v162discount_1101    SMALLMONEY,
    
    @v162UpdatePositiontaking_1101 BIT = 1,
    @v162UpdateMinPositiontaking_1101 BIT =1,
    @v162UpdateAutoPositiontaking_1101 BIT =1,
    @v162UpdateCommission_1101    BIT =1,
    
    @updateallmembers    BIT = 0,
    @newspositiontaking SMALLMONEY = 0,
    
    @SubAccID    INT = 0,
    @userid        INT,
    @IP            VARCHAR(50)= '',
    @Language    VARCHAR(20) = 'E',        
    @ErrCode    VARCHAR(300) = '' OUTPUT,
    @ErrMsg        NVARCHAR(4000) = '' OUTPUT
    

AS
    /*
        Created: Johnson
        Date: 04Jan2012
        DB: DBTXN/BODB02
        Task: Super edits live casino settings on master
        
        Revisions:
            - 20120329@Johnson: Check s3,n3 if not synchronized
            - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
            - 20130301@Johnson: change linked server DB053 to DBAGE
            - 20140724@Johnson: write log all parameters for tracking pt issue 
            - 20140725@Johnson:- comment code write log paramters
                                - call sp to check parameters before update pt
			- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID)
        Parameters Explanation:
    */
SET NOCOUNT ON

DECLARE @roleid TINYINT, @SyncLiveCasino BIT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000)
SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

---------------------------
-- ***Check Downline Belonging***
EXEC Age_CustomerSelCheckBelongingByCustID
    @SessionCustID = @Userid, 
    @Custid = @custid,
    @roleid = @roleid OUTPUT
    IF (@roleid = 0) RETURN
---------------------------

--Check disable user
EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
    select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
            @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
    return
END
--end

DECLARE @old_adiscount    SMALLMONEY

SELECT @old_adiscount = adiscount
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101

IF @v162UpdateCommission_1101 = 1
BEGIN
                                                                EXEC Acc_CustomerUpdMasterLiveCS_Commission
        @custid                = @custid, 
        @v162discount_1101    = @v162discount_1101, 
        @SubAccID            = @SubAccID, 
        @IP                    = @IP, 
        @UserID                = @UserID, 
        @Language            = @Language, 
        @ErrCode            = @ErrCode_Cur OUTPUT, 
        @ErrMsg                = @ErrMsg_Cur OUTPUT
    
    IF @ErrCode_Cur > 0
    BEGIN
        SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
            @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
        RETURN    
    END
    ELSE
        SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)        
END

-- check n3<= m3
IF @v162mpositiontaking_1101 < @v162mpositiontaking_1101_min
BEGIN
    SELECT @ErrMsg_Cur = case @Language 
                            when 'E' then 'Wrong position taking .<br>'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'
                    end , @ErrCode_Cur = 100
    
    SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
            @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
            
    RETURN    
END

SELECT @SyncLiveCasino = SyncLiveCasino 
FROM Custinfo WITH(NOLOCK)
WHERE custid = @custid 

--check min/max pt set by company if not synchronize
IF @SyncLiveCasino = 0
BEGIN
    --check n4<=s3+m3<=s4, s3<=s4 if i3 = 0, 
    --m3<=s4 and u3+m3>=n4 if i3 = 1    
    SELECT @ErrMsg_Cur = @ErrMsg_Cur + 'Min: ' + CAST(co.minpositiontaking AS VARCHAR(10)) + ' -Max: ' + CAST(cs.spositiontaking AS VARCHAR(10)) 
    FROM CustSettingGame cs WITH(NOLOCK)
        INNER JOIN CustOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype 
    WHERE cs.custid = @srecommend AND cs.sporttype = 162 AND cs.bettype = 1101
        AND ((@isauto_v162spositiontaking_1101 > 0 AND (@v162mpositiontaking_1101 + @auto_v162spositiontaking_1101 < co.minpositiontaking OR @v162mpositiontaking_1101 > cs.spositiontaking))
        OR (@isauto_v162spositiontaking_1101 = 0 AND (@v162spositiontaking_1101 + @v162mpositiontaking_1101 < minpositiontaking OR @v162spositiontaking_1101 + @v162mpositiontaking_1101 > cs.spositiontaking OR @v162spositiontaking_1101 > cs.spositiontaking)))

    IF @ErrMsg_Cur <> ''
    BEGIN    
        SELECT @ErrMsg = @ErrMsg +
                            CASE @Language 
                                WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrMsg_Cur
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrMsg_Cur
                        END, @ErrCode_Cur = 101
                    
        SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
            @ErrMsg = @ErrMsg + CHAR(7)
            
        RETURN
    END
END

--20140724@Johnson: tracking pt issue
--@20140725@Johnson: comment this code
/*
Declare    @TrackingValue varchar(4000)
     
SELECT @TrackingValue = '<Acc_CustomerUpdMasterLiveCS_All Custid="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'srecommend=' + COALESCE(CAST(@srecommend AS VARCHAR(50)),SPACE(1)) + '" ' + 

'v162spositiontaking_1101="' + COALESCE(CAST(@v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'v162mpositiontaking_1101="' + COALESCE(CAST(@v162mpositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'isauto_v162spositiontaking_1101="' + COALESCE(CAST(@isauto_v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'auto_v162spositiontaking_1101="' + COALESCE(CAST(@auto_v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'v162mpositiontaking_1101_min="' + COALESCE(CAST(@v162mpositiontaking_1101_min AS VARCHAR(50)),SPACE(1)) + '" ' + 

'v162UpdatePositiontaking_1101="' + COALESCE(CAST(@V162UpdatePositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'v162UpdateAutoPositiontaking_1101="' + COALESCE(CAST(@V162UpdateAutoPositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'v162UpdateMinPositiontaking_1101="' + COALESCE(CAST(@v162UpdateMinPositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +

'updateallmembers="' + COALESCE(CAST (@updateallmembers AS VARCHAR(3)), SPACE(1)) + '" ' +
'newspositiontaking="' + COALESCE(CAST (@newspositiontaking AS VARCHAR(30)), SPACE(1)) + '" ' +
'SyncLiveCasino="' + COALESCE(CAST (@SyncLiveCasino AS VARCHAR(30)), SPACE(1)) + '" ' +

'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
'SubAccID="'+ COALESCE(CAST(@SubAccID AS VARCHAR(30)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" />'


EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Tracking
        @UserID = @UserID,
        @CustID = @CustID,        
        @TrackingValue = @TrackingValue
--End tracking        
*/

IF @v162UpdatePositiontaking_1101 = 1 OR @v162UpdateAutoPositiontaking_1101 = 1
BEGIN
                EXEC Acc_CustomerUpdMasterLiveCS_CheckParam
        @custid        = @custid,
        @v162spositiontaking_1101    = @v162spositiontaking_1101,
        @v162mpositiontaking_1101    = @v162mpositiontaking_1101,    
        @isauto_v162spositiontaking_1101 = @isauto_v162spositiontaking_1101,
        @auto_v162spositiontaking_1101    = @auto_v162spositiontaking_1101,
        
        @Language    = @Language,    
        @ErrCode    = @ErrCode_cur OUTPUT,
        @ErrMsg        = @ErrMsg_Cur OUTPUT
    
    IF @ErrCode_cur >0 
    BEGIN
        SELECT @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7),
                @ErrCode = @ErrCode + CONVERT(VARCHAR(300),@ErrCode_cur) + CHAR(7)
            
        RETURN    
    END
END
        
IF @v162UpdateMinPositiontaking_1101 = 1
BEGIN
                                                                EXEC Acc_CustOverrideUpdLiveCS
        @custid        = @custid, 
        @UplineID    =  @srecommend ,
        @min_v162positiontaking_1101 = @v162mpositiontaking_1101_min, 
        @SubAccID    = @SubAccID, 
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
        SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)        
END

IF @v162UpdatePositiontaking_1101 = 1 OR @v162UpdateAutoPositiontaking_1101 = 1
BEGIN
                                                                EXEC Acc_CustomerUpdMasterLiveCS_Positiontaking 
        @custid        = @custid, 
        
        @v162spositiontaking_1101        = @v162spositiontaking_1101, 
        @v162mpositiontaking_1101        = @v162mpositiontaking_1101,
        @isauto_v162spositiontaking_1101 = @isauto_v162spositiontaking_1101, 
        @auto_v162spositiontaking_1101    = @auto_v162spositiontaking_1101,
        @v162UpdatePositiontaking_1101    = @v162UpdatePositiontaking_1101, 
        @v162UpdateAutoPositiontaking_1101 = @v162UpdateAutoPositiontaking_1101, 
        @updateallmembers                = @updateallmembers,
        @newspositiontaking                = @newspositiontaking,
        
        @SubAccID    = @SubAccID,  
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
        SELECT @ErrCode = @ErrCode + '-103' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)        

END

GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterLiveCS_All] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_All] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_All] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_All] TO [bodbExtAccNet]
GO 
