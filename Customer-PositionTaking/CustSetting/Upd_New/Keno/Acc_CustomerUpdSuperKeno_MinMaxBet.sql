ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperKeno_MinMaxBet]  
 @CustID   INT,  
 @Sporttype  INT = 202,  
 @Bettype  INT,  
  
 @MinBet   MONEY,  
 @MaxBet   MONEY,  
 @MaxPerMatch MONEY,  
  
@SubAccID       INT = 0,  
 @UserID   INT = 0,   
 @Language  VARCHAR(2) = 'E',  
 @IP    VARCHAR(15)='',  
 @ErrCode  INT  = 0  OUTPUT,  
 @ErrMsg   NVARCHAR(4000) = '' OUTPUT  
AS  
/*  
 Created: 20140225@Elodie  
 Task : Update super's minbet, maxbet, max per match for Keno  
 DB: DBCUST/CustDB  
  
 Revisions:  
    - 20141027@Logan:   Add currency when selecting Min Bet Global [Redmine: #25040]
    - 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)   
    - 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]	
 Param's Explanation:  
 * @ErrCode:  
  = 0: Update successfully.  
  > 0: Specific Error.  
    
 * @ErrMsg: Error description.  
*/  
BEGIN  
    SET NOCOUNT ON  
    ----- David @ 09 JUN 2015 -------------------
	DECLARE @tmp_GameType TABLE (GameTypeID INT, GameTypeName NVARCHAR(50), IsDisabled BIT, IBCBettypeID INT)

	BEGIN TRY		
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK)
	END TRY
	BEGIN CATCH		
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK)
	END CATCH
	----- /David @ 09 JUN 2015 -------------------

    DECLARE @startRun   DATETIME
          , @endRun     DATETIME
          , @duration   INT
          , @minbet_old MONEY
          , @maxbet_old MONEY
          , @maxpermatch_old MONEY
          , @currency   SMALLINT

    SET @startRun = GETDATE()

    SELECT @currency = currency
      FROM dbo.custInfo WITH(NOLOCK)
     WHERE custid = @CustID
       AND roleid = 4

	            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,4,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END


    IF @MinBet < 0  
        OR @MaxBet < 0  
        OR @MaxPerMatch <0   
    BEGIN  
        SELECT @ErrMsg =
                 CASE @Language   
                   WHEN 'E' THEN 'Wrong Min bet/ Max bet/ Max per match.'  
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](10003, @Language)
                 END
             , @ErrCode = 101  
        RETURN
    END

     IF((@MinBet <> 0 OR @MaxBet <> 0) AND @MinBet > @MaxBet)   
      or ((@MaxBet <> 0 OR @MaxPerMatch <> 0) AND @MaxBet > @MaxPerMatch)   
      or ((@MinBet <> 0 OR @MaxPerMatch <> 0) AND @MinBet > @MaxPerMatch)   
     BEGIN  
      SELECT  
       @ErrMsg = CASE @Language   
            WHEN 'E' THEN 'Min bet must be less than max bet and max bet must be less than max bet per match.'  
            ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) END,   
       @ErrCode = 102  
      RETURN  
     END  
  
     IF EXISTS (SELECT 1
                  FROM ProductBetSetting WITH(NOLOCK)
                 WHERE sporttype = @Sporttype
                   AND bettype = @bettype
                   AND Currency = @currency
                   AND MinBet > @MinBet
                   AND @MinBet <> 0
                   AND IsDep = 0
               )  
     BEGIN  
      SELECT  
       @ErrMsg = CASE @Language   
            WHEN 'E' THEN 'Min Bet must be greater than or equal to Min Bet limit.'  
            ELSE [dbo].[f_Get_MsgNamebyMsgID](10030, @Language) END,   
       @ErrCode = 103  
      RETURN  
     END  
  
     SELECT @minbet_old = cg.MinBet, @maxbet_old = cg.MaxBet, @maxpermatch_old = cg.MaxPerGameType  
     FROM CustGameType cg WITH(NOLOCK)  
      INNER JOIN @tmp_GameType gt ON cg.GameTypeID = gt.GameTypeID  
     WHERE custid = @CustID and gt.IBCBetTypeID = @bettype  
  
     --Check not change value  
     IF (@minbet_old = @MinBet AND @maxbet_old = @MaxBet AND @maxpermatch_old = @MaxPerMatch)  
      RETURN  
   
     UPDATE cg with (ROWLOCK, UPDLOCK)  
     SET MinBet = @MinBet,   
      MaxBet= @MaxBet,  
      MaxPerGameType = @MaxPerMatch  
     FROM CustGameType cg INNER JOIN @tmp_GameType gt ON cg.GameTypeID = gt.GameTypeID  
     WHERE custid=@CustID AND gt.IBCBetTypeID = @bettype  
   
     IF (@@error <> 0)  
     BEGIN  
      SELECT @ErrMsg = CASE @Language   
           WHEN 'E' THEN 'Update process is unsuccessful!'  
           ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language) END,   
        @ErrCode = 104  
      RETURN  
     END    
  
     DECLARE @LogSPData VARCHAR (MAX),  
       @TrackingValueDB VARCHAR(4000)  
    
     Select @LogSPData ='<Acc_CustomerUpdSuperKeno_MinMaxBet custid="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +  
     'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' +   
     'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
     'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +  
     'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +  
     'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +  
     'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +  
     'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +  
     'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +  
     'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +  
     'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +  
     'ErrMsg="'+ coalesce(cast(@ErrMsg as nvarchar(4000)),space(1)) + '" />'  
  
     SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperKeno_MinMaxBet custid="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +  
     'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' +   
     'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
     'MinB="'+ coalesce(cast(@MinBet_old as varchar(50)),space(1)) + '" ' +  
     'MaxB="'+ coalesce(cast(@MaxBet_old as varchar(50)),space(1)) + '" ' +  
     'MPM="'+ coalesce(cast(@MaxPerMatch_old as varchar(50)),space(1)) + '" ' +  
     'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +  
     'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +  
     'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +  
     'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +  
     'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +  
     'ErrMsg="'+ coalesce(cast(@ErrMsg as nvarchar(4000)),space(1)) + '" />'  
  
     set @endRun = getdate()  
     set @duration  = datediff (millisecond,@startRun,@endRun)  
  
     BEGIN TRY   
      EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP   
       @UserID = @UserID,  
       @CustID = @CustID,  
       @ActionID = 379,  
       @TrackingValue = @LogSPData,  
       @TrackingValue2 = @TrackingValueDB,  
       @duration = @duration  
     END TRY  
     BEGIN CATCH  
      Select @LogSPData ='<Acc_CustomerUpdSuperKeno_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +  
      'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' +   
      'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
      'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +  
      'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +  
      'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +  
      'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +  
      'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +  
      'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +  
      'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +  
      'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +  
      'ErrMsg="'+ ERROR_MESSAGE() + '" />'  
   
      EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP   
       @UserID = @UserID,  
       @CustID = @CustID,  
       @ActionID = 379,  
       @TrackingValue = @LogSPData,  
       @TrackingValue2 = @TrackingValueDB,  
       @duration = @duration  
     END CATCH  
END
