ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaster_DisableAutoMPT]
    @CustID int,-- MasterID
    @DisableAutoMPT bit = 0,
    @SubAccID int = 0, --Sub-AccountID
    @UserID int = 0,    
    @Language varchar(2) = 'E',
    @IP varchar(15)='',
    @ErrCode int = 0 OUTPUT,
    @ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20090701@Phuc
Task : Update Disable auto master PT
DB: DBCUST/CustDB

Revisions:
    - 20090723@Phuc: Write log subaccname instead of subaccid.
    - 20090818@Phuc: check page access AND check upline closed first(call Age_CustSubCheckPageAccess)
    - 20090917@Phuc: write log into DBLOG.
    - 20091203@Kiwi: Modify to retrieve data FROM CustSetting3rd.
    - 20100112@Kiwi: AmEND to write log in xml format.
    - 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
    - 20101006@Lukas: update isautolive PT ON custsetting3rd
    - 20101019@Henry: Record execution time
    - 20110606@Amy: Check Old/New value
    - 20110709@Johnson: Change to use new server BD053 instead DB052
    - 20120215@Johnson: Update PT for live casino
    - 20121128@Elodie: Get an error message FROM f_Get_MsgNameByMsgID function by language
    - 20130218@Dan: Change linked server DB053 to DBAGE; Write more log ON DBTXN server in case of DBLOG server failure
    - 20140819@Logan    1. Exclude disabled agents while updating Master Setting
                        2. Code aligning
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB)
	- 20151014@Helen: Customer Setting for Sportsbook 2- [Redmine: #44604]

Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
    SET NOCOUNT ON

    DECLARE @startRun DATETIME
    DECLARE @endRun   DATETIME
    DECLARE @duration INT
    SET @startRun = GETDATE()

    DECLARE  @Old_DisableAutoMPT BIT

    --Check disable user
    EXEC Acc_CustomerSelCheckEnable
        @custid = @custid
      , @ErrCode = @ErrCode OUTPUT
      , @ErrMsg = @ErrMsg OUTPUT

    IF @ErrCode <> 0 RETURN

    DECLARE @UplineClosed BIT
          , @RoleID INT
          , @srecommend INT
     
    SELECT @RoleID = roleid
         , @srecommend = srecommend
      FROM custinfo WITH(NOLOCK)
     WHERE custid = @CustID

    IF (@RoleID IS NULL OR @roleid <> 3) 
    BEGIN
        SELECT @ErrCode = 101
             , @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Account does not exist or invalid customer account'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](40019, @Language)
                 END    
        RETURN
    END

    SELECT @Old_DisableAutoMPT = DisableAutoMPT
      FROM CustMaster WITH(NOLOCK)
     WHERE custid = @CustID

    IF @Old_DisableAutoMPT = @DisableAutoMPT RETURN

    UPDATE CustMaster WITH(ROWLOCK, UPDLOCK)
       SET DisableAutoMPT = @DisableAutoMPT
     WHERE CustID = @CustID
     
    IF @DisableAutoMPT = 1
    BEGIN
        --Reset m2 of all agent under this master
        --m2=min(um2,m3-a2)
        
        UPDATE acs 
           SET mpositiontaking =
                 CASE
                   WHEN acs.autompositiontaking > mcs.mpositiontaking - acs.apositiontaking THEN mcs.mpositiontaking - acs.apositiontaking
                   ELSE acs.autompositiontaking
                 END
          FROM custsetting acs WITH(ROWLOCK, UPDLOCK) 
			INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = acs.custid
			INNER JOIN custsetting mcs WITH(NOLOCK) ON acs.sporttype = mcs.sporttype
												   AND acs.bettype = mcs.bettype
												   AND mcs.custid = @CustID
         WHERE ci.mrecommend = @CustID
           AND ci.roleid = 2
           AND ci.Enabled = 1
           AND acs.isautompositiontaking = 1


        UPDATE acs 
           SET mpositiontaking =
                 CASE
                   WHEN acs.autompositiontaking > mcs.mpositiontaking - acs.apositiontaking THEN mcs.mpositiontaking - acs.apositiontaking
                   ELSE acs.autompositiontaking
                 END
          FROM CustSetting3rd acs WITH(ROWLOCK, UPDLOCK) 
			INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = acs.custid
			INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON acs.sporttype = mcs.sporttype
													  AND acs.bettype = mcs.bettype
													  AND mcs.custid = @CustID
         WHERE ci.mrecommend = @CustID
           AND ci.roleid = 2
           AND ci.Enabled = 1
           AND acs.isautompositiontaking = 1


        UPDATE acs 
           SET mlivepositiontaking =
                 CASE
                   WHEN acs.autolivempositiontaking > mcs.mlivepositiontaking - acs.alivepositiontaking THEN mcs.mlivepositiontaking - acs.alivepositiontaking
                   ELSE acs.autolivempositiontaking
                 END      
          FROM custsetting acs WITH(ROWLOCK, UPDLOCK)
			INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = acs.custid
			INNER JOIN custsetting mcs WITH(NOLOCK) ON acs.sporttype = mcs.sporttype
												   AND acs.bettype = mcs.bettype
												   AND mcs.custid = @CustID
         WHERE ci.mrecommend = @CustID
           AND ci.roleid = 2
           AND ci.Enabled = 1
           AND acs.isautolivempositiontaking = 1


        UPDATE acs3 
           SET mlivepositiontaking =
                 CASE
                   WHEN acs3.autolivempositiontaking > mcs3.mlivepositiontaking - acs3.alivepositiontaking THEN mcs3.mlivepositiontaking - acs3.alivepositiontaking
                   ELSE acs3.autolivempositiontaking
                 END      
          FROM custsetting3rd acs3 WITH(ROWLOCK, UPDLOCK)
			INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = acs3.custid
			INNER JOIN custsetting3rd mcs3 WITH(NOLOCK) ON acs3.sporttype = mcs3.sporttype
													   AND acs3.bettype = mcs3.bettype
													   AND mcs3.custid = @CustID
         WHERE ci.mrecommend = @CustID
           AND ci.roleid = 2
           AND ci.Enabled = 1
           AND acs3.isautolivempositiontaking = 1


        UPDATE acs
           SET mpositiontaking =
                 CASE
                   WHEN acs.autompositiontaking > mcs.mpositiontaking - acs.apositiontaking THEN mcs.mpositiontaking - acs.apositiontaking
                   ELSE acs.autompositiontaking
                 END
          FROM CustSettingGame acs WITH(ROWLOCK, UPDLOCK)
			INNER JOIN CustInfo ci WITH(NOLOCK) ON acs.custid = ci.custid 
			INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid
													   AND mcs.sporttype = acs.sporttype
													   AND mcs.bettype = acs.bettype 
         WHERE ci.mrecommend = @custid
           AND ci.roleid = 2
           AND ci.Enabled = 1
           AND acs.isautompositiontaking = 1


        --Reset auto master PT of all agent under this master 
        UPDATE cs
           SET isautompositiontaking = 0
             , autompositiontaking = 0
          FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
			INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid 
         WHERE ci.mrecommend = @CustID
           AND ci.roleid IN (1, 2)
           AND ci.Enabled = 1
           AND cs.isautompositiontaking = 1


        UPDATE cs
           SET isautompositiontaking = 0
             , autompositiontaking = 0
          FROM CustSetting3rd cs WITH(ROWLOCK, UPDLOCK)
			INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid 
         WHERE ci.mrecommend = @CustID
           AND ci.roleid IN (1, 2)
           AND ci.Enabled = 1
           AND cs.isautompositiontaking = 1


         UPDATE cs
           SET isautolivempositiontaking = 0
             , autolivempositiontaking = 0
          FROM custsetting cs WITH(ROWLOCK, UPDLOCK)
			INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid 
         WHERE ci.mrecommend = @CustID
           AND ci.roleid IN (1, 2)
           AND ci.Enabled = 1
           AND cs.isautolivempositiontaking = 1


        UPDATE cs3
           SET isautolivempositiontaking = 0
             , autolivempositiontaking = 0
          FROM custsetting3rd cs3 WITH(ROWLOCK, UPDLOCK)
			INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs3.custid 
         WHERE ci.mrecommend = @CustID
           AND ci.roleid IN (1, 2)
           AND ci.Enabled = 1
           AND cs3.isautolivempositiontaking = 1


        UPDATE cs
           SET isautompositiontaking = 0
             , autompositiontaking = 0
          FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
			INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
         WHERE ci.mrecommend = @custid
           AND ci.roleid IN (1, 2)
           AND ci.Enabled = 1
           AND cs.isautompositiontaking = 1
        
        -- For sportbook2: CustPTSetting3rd_Member AND CustPTSetting3rd_Agent
        --Reset m2 of all agent under this master
        --m2=min(um2,m3-a2) -- isautompositiontaking = Islive = 0 
        BEGIN
        UPDATE acs 
           SET MasterPT =
                 CASE
                   WHEN acs.AutoMasterPT > mcs.MasterPT - acs.AgentPT THEN mcs.MasterPT - acs.AgentPT
                   ELSE acs.AutoMasterPT
                 END
          FROM CustPTSetting3rd_Agent acs WITH(ROWLOCK, UPDLOCK) 
			INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = acs.custid
			INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON acs.sporttype = mcs.sporttype
												   AND acs.bettype = mcs.bettype
												   AND mcs.custid = @CustID
         WHERE ci.mrecommend = @CustID
           AND ci.roleid = 2
           AND ci.Enabled = 1
           AND acs.IsAutoMasterPT = 1
        
        --Reset auto master PT of all agent under this master 
          UPDATE cs
           SET IsAutoMasterPT = 0
             , AutoMasterPT = 0
          FROM CustPTSetting3rd_Agent cs WITH(ROWLOCK, UPDLOCK)
			INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid 
         WHERE ci.mrecommend = @CustID
           AND ci.roleid = 2
           AND ci.Enabled = 1
           AND cs.IsAutoMasterPT = 1
         
          UPDATE cs
           SET IsAutoMasterPT = 0
             , AutoMasterPT = 0
          FROM CustPTSetting3rd_Member cs WITH(ROWLOCK, UPDLOCK)
			INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid 
         WHERE ci.mrecommend = @CustID
           AND ci.roleid = 1
           AND ci.Enabled = 1
           AND cs.IsAutoMasterPT = 1
           
                       
		 -- Update Group
		 UPDATE cs
           SET IsAutoMasterPT = 0
             , AutoMasterPT = 0
          FROM CustPTGroupSetting3rd_Member  cs WITH(ROWLOCK, UPDLOCK)
			INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.AgentID 
         WHERE ci.mrecommend = @CustID
           AND ci.roleid = 2
           AND ci.Enabled = 1
           AND cs.IsAutoMasterPT = 1
		
		END
    END

    DECLARE  @LogSPData varchar(8000)

    SELECT @LogSPData = '<Acc_CustomerUpdMaster_DisableAutoMPT CustID="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
    'DisableaMPT="'+ COALESCE(CAST(@DisableAutoMPT AS VARCHAR(50)),SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
    'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(4000)),SPACE(1)) + '" />'
     
    SET @endRun = GETDATE()
    SET @duration = DATEDIFF(MILLISECOND, @startRun, @endRun) 

    BEGIN TRY 
        EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
            @UserID = @UserID
          , @CustID = @CustID
          , @ActionID = 1113
          , @TrackingValue = @LogSPData
          , @duration = @duration
    END TRY

    BEGIN CATCH
        SELECT @LogSPData = '<Acc_CustomerUpdMaster_DisableAutoMPT CustID="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
        'DisableaMPT="'+ COALESCE(CAST(@DisableAutoMPT AS VARCHAR(50)),SPACE(1)) + '" ' +
        'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
        'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
        'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
        'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
        'ErrCode="'+ COALESCE(CAST(ERROR_NUMBER() AS VARCHAR(50)),SPACE(1)) + '" ' +
        'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)),SPACE(1)) + '" />'

        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
            @UserID = @UserID
          , @CustID = @CustID
          , @ActionID = 1113
          , @TrackingValue = @LogSPData
          , @duration = @duration
    END CATCH
END

GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_DisableAutoMPT] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_DisableAutoMPT] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_DisableAutoMPT] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_DisableAutoMPT] TO [bodbExtAccNet]
GO 
