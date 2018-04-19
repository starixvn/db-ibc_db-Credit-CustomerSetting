
CREATE PROCEDURE dbo.[DBA_CheckPTGame_for_Line_DCS]
     @srecommendList VARCHAR(MAX) 
    ,@SportType SMALLINT = 0
    ,@BetType   SMALLINT = 0
AS
/*
    Created: 20180411@Vicky
    Task : check DCS PT Setting for Credit Customer 
    DB: DB06/bodb02
    
    
    Param's Explanation:
    Exameple1: EXEC dbo.[DBA_CheckPTGame_for_Line_DCS] @srecommendList = '20', @SportType = 193, @BetType = 2801
    Exameple2:
			IF OBJECT_ID('tempdb..#supers') IS NOT NULL DROP TABLE #supers
			GO
			CREATE TABLE #supers (custid INT, isfinished BIT DEFAULT(0))
			DECLARE @srecommend VARCHAR(MAX)
			
			DECLARE @var_msg_index INT = 0, @var_msg_super_total INT = 0
			
			
			-------------------clear data-----------------------------------------------------------------------------
			IF OBJECT_ID('tempdb..##CheckPTResult_Credit') IS NOT NULL
			BEGIN
			    DELETE FROM ##CheckPTResult_Credit
			END
			----------------------------------------------------------------------------------------------------------
			    
			INSERT INTO #supers(custid)
			SELECT c.custid
			FROM customer c             WITH (NOLOCK) 
			    INNER JOIN site s       WITH (NOLOCK) ON c.site = s.site
			    INNER JOIN custsuper cs WITH (NOLOCK) ON c.custid = cs.custid
			WHERE c.username NOT LIKE '3rdSuper%'
			    AND cs.isinternal = 0
			    AND s.islicensee = 0
			
			SET @var_msg_super_total = (SELECT COUNT(*) FROM #supers )
			RAISERROR ('Total of supers: %d.', 0, 1, @var_msg_super_total) WITH NOWAIT
			
			WHILE (1 = 1)
			BEGIN
			    SET @srecommend = NULL
			    
			    UPDATE TOP (100) #Supers
			    SET isfinished = 1, @srecommend = COALESCE(@srecommend + ',', '') + CONVERT(VARCHAR(12),custid)   
			    WHERE isfinished = 0
			    
			    IF @@ROWCOUNT = 0 BREAK
			    
			    SET @var_msg_index = @var_msg_index + 1
			    RAISERROR ('Currently at order %d, SuperID: %s.', 0, 1, @var_msg_index, @srecommend) WITH NOWAIT
			    
			    exec dbo.[DBA_CheckPTGame_DCS] @srecommendList=@srecommend, @SportType = 193, @BetType = 2801
			    exec dbo.[DBA_CheckPTGame_DCS] @srecommendList=@srecommend, @SportType = 192, @BetType = 2701
			END
			
			SELECT * FROM ##CheckPTResult_Credit
*/
BEGIN
    SET NOCOUNT ON
    
    CREATE TABLE #SuperTemp(CustID INT PRIMARY KEY CLUSTERED)
    IF OBJECT_ID('tempdb..##CheckPTResult_Credit') IS NULL
    BEGIN
        CREATE TABLE ##CheckPTResult_Credit (RuleDesc VARCHAR(100), BetType INT, SportType INT, CustIdA INT, CustIdB INT, ValueA INT, ValueB INT, IsLive INT)
    END
    DECLARE @var_bitmapOrder SMALLINT
    
    
    INSERT INTO #SuperTemp (CustID)
    SELECT RTRIM(LTRIM(val)) FROM dbo.strSplit(@srecommendList,',')
    
   
    CREATE TABLE #MemberPT (CustID INT, recommend INT, mrecommend INT, srecommend INT, sporttype SMALLINT, bettype SMALLINT, IsLive BIT, SuperPT SMALLINT, MasterPT SMALLINT, AgentPT SMALLINT, IsAutoMasterPT BIT, AutoMasterPT SMALLINT, IsAutoSuperPT BIT, AutoSuperPT SMALLINT, IsGroup BIT)
    CREATE TABLE #AgentPT (CustID INT, recommend INT, mrecommend INT, srecommend INT, sporttype SMALLINT, bettype SMALLINT, IsLive BIT, SuperPT SMALLINT, MasterPT SMALLINT, AgentPT SMALLINT, IsAutoMasterPT BIT, AutoMasterPT SMALLINT, IsAutoSuperPT BIT, AutoSuperPT SMALLINT, MinPT SMALLINT, MaxPT SMALLINT)
    CREATE TABLE #MasterPT (CustID INT, recommend INT, mrecommend INT, srecommend INT, sporttype SMALLINT, bettype SMALLINT, IsLive BIT, SuperPT SMALLINT, MasterPT SMALLINT, AgentPT SMALLINT, IsAutoMasterPT BIT, AutoMasterPT SMALLINT, IsAutoSuperPT BIT, AutoSuperPT SMALLINT, MinPT SMALLINT, MaxPT SMALLINT)
    CREATE TABLE #SuperPT (CustID INT, recommend INT, mrecommend INT, srecommend INT, sporttype SMALLINT, bettype SMALLINT, IsLive BIT, SuperPT SMALLINT, MasterPT SMALLINT, AgentPT SMALLINT, IsAutoMasterPT BIT, AutoMasterPT SMALLINT, IsAutoSuperPT BIT, AutoSuperPT SMALLINT, MinPT SMALLINT, MaxPT SMALLINT)


    INSERT INTO #MemberPT (CustID, recommend,mrecommend,srecommend,SportType,BetType,IsLive,SuperPT,MasterPT,AgentPT,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT,IsGroup)
    SELECT cs.CustID,ci.recommend,ci.mrecommend,ci.srecommend, cs.SportType,cs.BetType,cs.IsLive,cs.SuperPT,cs.MasterPT,cs.AgentPT,cs.IsAutoMasterPT,cs.AutoMasterPT,cs.IsAutoSuperPT,cs.AutoSuperPT,0 IsGroup
    FROM CustInfo ci WITH (NOLOCK)
        INNER JOIN #SuperTemp s ON s.custid = ci.srecommend
        INNER JOIN CustPTSetting3rd_Member cs WITH (NOLOCK) ON ci.CustID = cs.CustID
    WHERE   ci.roleid = 1 AND cs.SportType = @SportType
    
    
    INSERT INTO #MemberPT (CustID, recommend,mrecommend,srecommend,SportType,BetType,IsLive,SuperPT,MasterPT,AgentPT,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT,IsGroup)
    SELECT ci.CustID,ci.recommend,ci.mrecommend,ci.srecommend, cs.SportType,cs.BetType,cs.IsLive,cs.SuperPT,cs.MasterPT,cs.AgentPT,cs.IsAutoMasterPT,cs.AutoMasterPT,cs.IsAutoSuperPT,cs.AutoSuperPT,1
    FROM CustInfo ci WITH (NOLOCK)
        INNER JOIN #SuperTemp s ON s.custid = ci.srecommend
        INNER JOIN CustSettingMode3rd csm WITH (NOLOCK) ON ci.custid = csm.CustID AND csm.IsGrouped = 1
        INNER JOIN CustPTGroupSetting3rd_Member cs WITH (NOLOCK) ON cs.AgentID = ci.recommend  
    WHERE  ci.roleid = 1 AND cs.SportType = @SportType

    
    INSERT INTO #AgentPT (CustID, recommend,mrecommend,srecommend,SportType,BetType,IsLive,SuperPT,MasterPT,AgentPT,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT, MinPT, MaxPT)            
    SELECT cs.CustID,ci.recommend,ci.mrecommend,ci.srecommend, cs.SportType,cs.BetType,cs.IsLive,cs.SuperPT,cs.MasterPT,cs.AgentPT,cs.IsAutoMasterPT,cs.AutoMasterPT,cs.IsAutoSuperPT,cs.AutoSuperPT,cs.MinPT,cs.MaxPT
    FROM CustInfo ci WITH (NOLOCK)
        INNER JOIN #SuperTemp s ON s.custid = ci.srecommend
        INNER JOIN CustPTSetting3rd_Agent cs WITH (NOLOCK) ON ci.CustID = cs.CustID
    WHERE   ci.roleid = 2 AND cs.SportType = @SportType

    
    INSERT INTO #MasterPT (CustID, recommend,mrecommend,srecommend,SportType,BetType,IsLive,SuperPT,MasterPT,AgentPT,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT,MinPT,MaxPT)         
    SELECT cs.CustID,ci.recommend,ci.mrecommend,ci.srecommend, cs.SportType,cs.BetType,cs.IsLive,cs.SuperPT,cs.MasterPT,cs.AgentPT,cs.IsAutoMasterPT,cs.AutoMasterPT,cs.IsAutoSuperPT,cs.AutoSuperPT,cs.MinPT,cs.MaxPT
    FROM CustInfo ci WITH (NOLOCK)
        INNER JOIN #SuperTemp s ON s.custid = ci.srecommend
        INNER JOIN CustPTSetting3rd_Agent cs WITH (NOLOCK) ON ci.CustID = cs.CustID
    WHERE   ci.roleid = 3 AND cs.SportType = @SportType 
    
    
    INSERT INTO #SuperPT (CustID, SportType,BetType,IsLive,SuperPT,MasterPT,AgentPT,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT,MinPT,MaxPT)          
    SELECT cs.CustID, cs.SportType,cs.BetType,cs.IsLive,cs.SuperPT,cs.MasterPT,cs.AgentPT,cs.IsAutoMasterPT,cs.AutoMasterPT,cs.IsAutoSuperPT,cs.AutoSuperPT,cs.MinPT,cs.MaxPT
    FROM CustInfo ci WITH (NOLOCK)
        INNER JOIN #SuperTemp s ON s.custid = ci.srecommend
        INNER JOIN CustPTSetting3rd_Agent cs WITH (NOLOCK) ON ci.CustID = cs.CustID
    WHERE ci.roleid = 4 AND cs.SportType = @SportType
    

    CREATE CLUSTERED INDEX CIX_MemberPT ON #MemberPT(CustID, sporttype, bettype)
    CREATE CLUSTERED INDEX CIX_AgentPT ON #AgentPT(CustID, sporttype, bettype)
    CREATE CLUSTERED INDEX CIX_MasterPT ON #MasterPT(CustID, sporttype, bettype)
    CREATE CLUSTERED INDEX CIX_SuperPT ON #SuperPT(CustID, sporttype, bettype)

    DECLARE @var_total_member INT, @var_total_sma INT
    SELECT @var_total_member = count(*) FROM #MemberPT
    SELECT @var_total_sma = count(*) FROM #SuperPT
    RAISERROR ('Total member %d, sma: %d.', 0, 1, @var_total_member, @var_total_sma) WITH NOWAIT
    
    --------------------------------check rule-----------------------------------------------------------------------------------------
    ---- 1. S1 < 0 OR M1 < 0 OR A1 < 0  
    BEGIN  
        ----PRINT '1. S1 < 0 OR M1 < 0 OR A1 < 0 '  
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)   
        SELECT '1. S1 < 0 OR M1 < 0 OR A1 < 0', cs.BetType, cs.SportType, cs.CustId, cs.CustId,  
             CASE 
                WHEN cs.SuperPT < 0 THEN cs.SuperPT
                WHEN cs.MasterPT < 0 THEN cs.MasterPT
                WHEN cs.AgentPT < 0 THEN cs.AgentPT
                ELSE 0  
             END,  
             0,   
             cs.Islive  
        FROM #MemberPT cs 
        WHERE cs.SuperPT < 0 OR cs.MasterPT < 0 OR cs.AgentPT < 0
        
    END  

    ----2. S4 > MaxPT OR M4 > MaxPT OR A4 > MaxPT  
    BEGIN  
        ----PRINT '2. S4 > 90 OR M4 > 90 OR A4 > 90 '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '2. S4 > MaxPT OR M4 > MaxPT OR A4 > MaxPT', cs.BetType, cs.SportType, cs.CustId, cs.CustId,  
             CASE 
                WHEN cs.SuperPT > ps.MaxPT THEN cs.SuperPT
                WHEN cs.MasterPT > ps.MaxPT THEN cs.MasterPT
                WHEN cs.AgentPT > ps.MaxPT THEN cs.AgentPT   
                ELSE ps.MaxPT   
             END,  
             ps.MaxPT,  
             cs.Islive
        FROM #SuperPT cs 
            INNER JOIN ProductSettingDetail ps ON cs.SportType = ps.SportType AND cs.Bettype = ps.Bettype AND cs.IsLive = ps.IsLive AND ps.Settingtype = 1
        WHERE cs.SuperPT > ps.MaxPT OR cs.MasterPT > ps.MaxPT OR cs.AgentPT > ps.MaxPT
        
    END  

    ----3. S4 < M4   
    BEGIN   
        ----PRINT '3. S4 < M4 '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '3. S4 < M4', cs.BetType, cs.SportType, cs.CustId, cs.CustId
            , cs.SuperPT
            , cs.MasterPT
            , cs.IsLive  
        FROM #SuperPT cs 
        WHERE cs.SuperPT < cs.MasterPT

    END  

    
    ----4. S4 < A4  
    BEGIN  
        ----PRINT '4. S4 < A4 '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '4. S4 < A4', cs.BetType, cs.SportType, cs.CustId, cs.CustId, cs.SuperPT, cs.AgentPT, cs.IsLive  
        FROM #SuperPT cs
        WHERE cs.SuperPT < cs.AgentPT
    END  
    
    
    ----5. S4 < N4   
    BEGIN   
        ----PRINT '5. S4 < N4 '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '5. S4 < N4', cs.BetType, cs.SportType, cs.CustId, cs.CustId, cs.SuperPT, cs.MinPT, cs.IsLive  
        FROM #SuperPT cs  
        WHERE cs.superPT < cs.MinPT

    END  
    

    ----6. S4 < US3   
    BEGIN   
        ----PRINT '6. S4 < US3   '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '6. S4 < US3', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.SuperPT , cs.AutoSuperPT, cs.IsLive  
        FROM #MasterPT cs 
            JOIN #SuperPT scs ON scs.CustID = cs.srecommend  AND scs.SportType = cs.SportType  
                                            AND scs.BetType = cs.BetType 
                                            AND scs.IsLive = cs.IsLive  
        WHERE scs.SuperPT < cs.AutoSuperPT
        
    END  
    
    ----7. S4 < US1   
    BEGIN   
        ----PRINT '7. S4 < US1'
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '7. S4 < US1', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.SuperPT, cs.AutoSuperPT, scs.IsLive
        FROM #MemberPT cs
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND scs.SportType = cs.SportType  
                                            AND scs.BetType = cs.BetType 
                                            AND scs.IsLive = cs.IsLive 
        WHERE scs.SuperPT < cs.AutoSuperPT
        
    END  

    ----8. S4 < S3 + M3   
    BEGIN   
        ----PRINT '8. S4 < S3 + M3   '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '8. S4 < S3 + M3', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.SuperPT, cs.SuperPT + cs.MasterPT, scs.IsLive  
        FROM #MasterPT cs
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND scs.SportType = cs.SportType  AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive 
        WHERE scs.SuperPT < cs.SuperPT + cs.MasterPT
        
    END  

    ----9. S4 < S1 + M1 + A1   
    BEGIN   
        ----PRINT '9. S4 < S1 + M1 + A1   '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '9. S4 < S1 + M1 + A1', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.SuperPT, cs.SuperPT + cs.MasterPT + cs.AgentPT, scs.IsLive  
        FROM #MemberPT cs
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND  scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive 
        WHERE scs.SuperPT < cs.SuperPT + cs.MasterPT + cs.AgentPT

    END  

    ----10. N4 > S1 + M1 + A1   
    BEGIN 
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '10. N4 > S1 + M1 + A1', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.MinPT, cs.SuperPT + cs.MasterPT + cs.AgentPT, scs.IsLive  
        FROM #MemberPT cs
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive  
        WHERE scs.MinPT > cs.SuperPT + cs.MasterPT + cs.AgentPT
          
    END  


    -----------------------------------------------------------------------  
    ----11. M4 < A4  
    BEGIN   
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '11. M4 < A4', cs.BetType, cs.SportType, cs.CustId, cs.CustId, cs.MasterPT, cs.AgentPT, cs.IsLive  
        FROM #SuperPT cs 
        WHERE cs.MasterPT < cs.AgentPT
        
    END
    
    
    ----12. M4 < M3   
    BEGIN  
        ----PRINT '12. M4 < M3'
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '12. M4 < M3', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.MasterPT, cs.MasterPT, scs.IsLive  
        FROM #MasterPT cs
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive   
        WHERE scs.MasterPT < cs.MasterPT
         
    END
    
    
    ----13. M4 < N3   
    BEGIN  
        ----PRINT '13. M4 < N3'
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '13. M4 < N3', scs.BetType, scs.SportType, scs.CustId, cs.CustId, scs.MasterPT , cs.MinPT, scs.IsLive  
        FROM #MasterPT cs
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive   
        WHERE scs.MasterPT < cs.MinPT


    END
    
    
    ----14. M4 < UM2   
    BEGIN  
        ----PRINT '14. M4 < UM2 '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '14. M4 < UM2', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.MasterPT, cs.AutoMasterPT, scs.IsLive  
        FROM #AgentPT cs
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive   
        WHERE scs.MasterPT < cs.AutoMasterPT
        
    END  

    
    ----15. M4 < UM1   
    BEGIN  
        ----PRINT '15. M4 < UM1   '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '15. M4 < UM1', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.MasterPT, cs.AutoMasterPT, scs.IsLive  
        FROM #MemberPT cs
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND  scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive  
        WHERE scs.MasterPT < cs.AutoMasterPT
            
    END  

    
    ----16. M4 < M1 + A1   
    BEGIN  
        ----PRINT '16. M4 < M1 + A1 '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '16. M4 < M1 + A1', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.MasterPT , cs.MasterPT + cs.AgentPT, scs.IsLive  
        FROM #MemberPT cs
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND  scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive  
        WHERE scs.MasterPT < cs.MasterPT + cs.AgentPT
    END  


    ----17. M3 < N3   
    BEGIN  
        ----PRINT '17. M3 < N3   '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '17. M3 < N3', cs.BetType, cs.SportType, cs.CustId, cs.CustId, cs.MasterPT, cs.MinPT, cs.IsLive  
        FROM #MasterPT cs
        WHERE cs.MasterPT < cs.MinPT
        
    END  

  
    ----18. M3 < M2 + A2   
    BEGIN   
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '18. M3 < M2 + A2', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.MasterPT, cs.MasterPT + cs.AgentPT, cs.IsLive  
        FROM #AgentPT cs
            INNER JOIN #MasterPT scs ON cs.mrecommend = scs.Custid AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive  
        WHERE scs.MasterPT < cs.MasterPT + cs.AgentPT
        
    END  

    ----19. M3 < M1 + A1   
    BEGIN   
        ----PRINT '19. M3 < M1 + A1   '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '19. M3 < M1 + A1', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.MasterPT, cs.MasterPT + cs.AgentPT, cs.IsLive  
        FROM #MemberPT cs
            INNER JOIN #MasterPT scs ON scs.CustID = cs.mrecommend AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive  
        WHERE scs.MasterPT < cs.MasterPT + cs.AgentPT
        
    END  

     
    ----20. N3 > M1 + A1   
    BEGIN  
        ----PRINT '20. N3 > M1 + A1   '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '20. N3 > M1 + A1', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.MinPT, cs.MasterPT + cs.AgentPT, cs.IsLive  
        FROM #MemberPT cs
            INNER JOIN #MasterPT scs ON scs.CustID = cs.mrecommend AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive  
        WHERE scs.MinPT > cs.MasterPT + cs.AgentPT
        
    END    


    ----21. A4 < A2  
    BEGIN   
        ----PRINT '21. A4 < A2  '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLIve)  
        SELECT '21. A4 < A2', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.AgentPT, cs.AgentPT, scs.IsLive  
        FROM #AgentPT cs
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive  
        WHERE scs.AgentPT < cs.AgentPT
          
    END   


    ----22. A4 < A1  
    BEGIN  
        ----PRINT '22. A4 < A1  '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '22. A4 < A1', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.AgentPT, cs.AgentPT, scs.IsLive  
        FROM #MemberPT cs
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive  
        WHERE scs.AgentPT < cs.AgentPT
            
    END   

    
    ----23. A2 < N2  
    BEGIN   
        ----PRINT '23. A2 < N2  '   
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '23. A2 < N2', cs.BetType, cs.SportType, cs.CustId, cs.CustId, cs.AgentPT, cs.MinPT, cs.IsLive
        FROM #AgentPT  cs
        WHERE cs.AgentPT < cs.MinPT
          
    END   

    
    ----24. N2 > A1  
    BEGIN  
        ----PRINT '24. N2 > A1  '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '24. N2 > A1', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.MinPT, cs.AgentPT, cs.IsLive   
        FROM #MemberPT cs
            INNER JOIN #AgentPT scs ON scs.CustID = cs.recommend AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive  
        WHERE   scs.MinPT > cs.AgentPT

          
    END  


    ---- 25. L4 < S1 + M1 + A1   
    BEGIN   
        ----PRINT '25. L4 < S1 + M1 + A1   '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '25. L4 < S1 + M1 + A1', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.MaxPT, cs.SuperPT + cs.MasterPT + cs.AgentPT, cs.IsLive  
        FROM #MemberPT cs
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive  
        WHERE scs.MaxPT < cs.SuperPT + cs.MasterPT + cs.AgentPT

          
    END  


    ---- 26. L3 < M1 +A1  
    BEGIN  
        ----PRINT '26. L3 < M1 +A1  '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '26. L3 < M1 +A1', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.MaxPT, cs.MasterPT + cs.AgentPT, cs.IsLive  
        FROM #MemberPT cs
            INNER JOIN #MasterPT scs ON scs.CustID = cs.mrecommend AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive  
        WHERE scs.MaxPT < cs.MasterPT + cs.AgentPT
        
    END    
    
    
    ---- 27. L2 < A1   
    BEGIN  
        ----PRINT '27. L2 < A1   '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '27. L2 < A1', cs.BetType, cs.SportType, scs.CustId, cs.CustId, scs.MaxPT, cs.AgentPT, cs.IsLive  
        FROM #MemberPT cs
            INNER JOIN #AgentPT scs ON scs.CustID = cs.recommend AND scs.SportType = cs.SportType AND scs.BetType = cs.BetType AND scs.IsLive = cs.IsLive  
        WHERE  scs.MaxPT < cs.AgentPT

    END  


    ---- 28. MIN(S4-M1-A1, (IS1?US1,US3)) > S1  
    BEGIN   
        ----PRINT '28. MIN(S4-M1-A1, (IS1?US1,US3)) > S1  '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '28. MIN(S4-M1-A1, (IS1?US1,US3)) > S1 ', cs.BetType, cs.SportType   
                ,CASE WHEN scs.SuperPT - cs.MasterPT - cs.AgentPT > (CASE WHEN cs.IsAutoSuperPT = 1 THEN cs.AutoSuperPT ELSE mcs.AutoSuperPT END)     
                  THEN ( CASE WHEN cs.IsAutoSuperPT = 1   
                      THEN cs.CustId   
                      ELSE mcs.CustId   
                    END)  
                  ELSE scs.CustId  
                 END   
                ,cs.CustId      
                ,CASE WHEN scs.SuperPT - cs.MasterPT - cs.AgentPT > (CASE WHEN cs.IsAutoSuperPT = 1 THEN cs.AutoSuperPT ELSE mcs.AutoSuperPT END)     
                  THEN ( CASE WHEN cs.IsAutoSuperPT = 1   
                      THEN cs.AutoSuperPT   
                      ELSE mcs.AutoSuperPT   
                    END)  
                  ELSE scs.SuperPT - cs.MasterPT - cs.AgentPT
                 END   
                ,cs.SuperPT  
                ,cs.IsLive  
        FROM #MemberPT cs WITH (NOLOCK)  
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND scs.SportType = cs.SportType  AND scs.bettype = cs.bettype  AND scs.IsLive = cs.IsLive  
            INNER JOIN #MasterPT mcs ON mcs.CustID = cs.mrecommend AND mcs.SportType = cs.SportType AND mcs.bettype = cs.bettype AND mcs.IsLive = cs.IsLive                                
        
        WHERE (cs.IsAutoSuperPT = 1 OR mcs.IsAutoSuperPT = 1)  
            AND cs.SuperPT < CASE WHEN scs.SuperPT - cs.MasterPT - cs.AgentPT > (CASE WHEN cs.IsAutoSuperPT = 1 THEN cs.AutoSuperPT ELSE mcs.AutoSuperPT END)     
                    THEN ( CASE WHEN cs.IsAutoSuperPT = 1   
                        THEN cs.AutoSuperPT   
                        ELSE mcs.AutoSuperPT   
                      END)  
                    ELSE scs.SuperPT - cs.MasterPT - cs.AgentPT  
                   END   
                   
    END   

    
    ---- 29. MIN (M4-A1, M3-A1,(IM1?UM1,UM2)) > M1 
    BEGIN   
        ----PRINT '29. MIN (M4-A1, M3-A1,(IM1?UM1,UM2)) > M1   '
        INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
        SELECT '29. MIN (M4-A1, M3-A1,(IM1?UM1,UM2)) > M1', cs.BetType, cs.SportType   
        ,CASE WHEN scs.MasterPT > mcs.MasterPT   
           THEN CASE WHEN mcs.MasterPT - cs.AgentPT > (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)   
             THEN (CASE WHEN cs.IsAutoMasterPT = 1   
               THEN cs.CustId  
               ELSE acs.CustId   
               END  
                )  
             ELSE mcs.CustId  
           END  
         ELSE   
           CASE WHEN scs.MasterPT - cs.AgentPT > (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)   
             THEN (CASE WHEN cs.IsAutoMasterPT = 1   
               THEN cs.CustId  
               ELSE acs.CustId   
              END  
              )  
             ELSE scs.CustId  
           END  
         END  
        ,cs.CustId  
        ,CASE WHEN scs.MasterPT > mcs.MasterPT   
           THEN CASE WHEN mcs.MasterPT - cs.AgentPT > (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)   
             THEN (CASE WHEN cs.IsAutoMasterPT = 1   
               THEN cs.AutoMasterPT  
               ELSE acs.AutoMasterPT   
                END  
                )  
             ELSE mcs.MasterPT - cs.AgentPT  
           END  
         ELSE   
           CASE WHEN scs.MasterPT - cs.AgentPT > (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)   
             THEN (CASE WHEN cs.IsAutoMasterPT = 1   
               THEN cs.AutoMasterPT  
               ELSE acs.AutoMasterPT   
              END  
              )  
             ELSE scs.MasterPT - cs.AgentPT  
           END  
         END  
        ,cs.MasterPT  
        ,cs.IsLive  
        FROM #MemberPT cs 
            INNER JOIN #SuperPT scs ON scs.CustID = cs.srecommend AND scs.SportType = cs.SportType AND scs.bettype = cs.bettype AND scs.IsLive = cs.IsLive
            INNER JOIN #MasterPT mcs ON mcs.CustId = cs.mrecommend AND mcs.SportType = cs.SportType AND mcs.bettype = cs.bettype AND mcs.IsLive = cs.IsLive
            INNER JOIN #AgentPT acs ON acs.CustId = cs.recommend  AND acs.SportType = cs.SportType AND acs.bettype = cs.bettype AND acs.IsLive = cs.IsLive               
                   
        WHERE ( acs.IsAutoMasterPT = 1 OR cs.IsAutoMasterPT = 1 )  
            AND cs.MasterPT < CASE WHEN scs.MasterPT > mcs.MasterPT   
                     THEN CASE  WHEN mcs.MasterPT - cs.AgentPT > (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)   
                       THEN (CASE WHEN cs.IsAutoMasterPT = 1   
                         THEN cs.AutoMasterPT  
                         ELSE acs.AutoMasterPT
                          END  
                          )  
                       ELSE mcs.MasterPT - cs.AgentPT  
                       END  
                    ELSE   
                      CASE WHEN scs.MasterPT - cs.AgentPT > (CASE WHEN cs.IsAutoMasterPT = 1 THEN cs.AutoMasterPT ELSE acs.AutoMasterPT END)   
                        THEN (CASE WHEN cs.IsAutoMasterPT = 1   
                          THEN cs.AutoMasterPT  
                          ELSE acs.AutoMasterPT   
                         END  
                         )  
                        ELSE scs.MasterPT - cs.AgentPT  
                        END  
                    END  

    END   

    
    ---- 33. PT setting of member exists in both Individual and group PT   
    BEGIN   
         ----PRINT ' 30. PT setting of member exists in both Individual and group PT'
         INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
         SELECT DISTINCT '33. PT setting of member exists in both Individual and group PT',NULL,NULL,M.CustID,M.CustID,NULL,NULL,NULL
         FROM #MemberPT M
         WHERE EXISTS (SELECT 1 FROM CustPTSetting3rd_Member M1 WITH (NOLOCK) WHERE M1.CustID = M.CustID)
               AND EXISTS (SELECT 1 FROM CustSettingMode3rd csm WITH (NOLOCK) WHERE csm.CustID = M.CustID AND csm.IsGrouped = 1)    
    END 

    
    ---- 34. IsGrouped Flag = 0 but not exists in Individual PT table
    BEGIN   
         ----PRINT '31. IsGrouped Flag = 0 but not exists in Individual PT table'
         INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
         SELECT DISTINCT '34. IsGrouped Flag = 0 but not exists in Individual PT table',NULL,NULL,M.CustID,M.CustID,NULL,NULL,NULL
         FROM #MemberPT M
         WHERE EXISTS (SELECT 1 FROM CustSettingMode3rd csm WITH (NOLOCK) WHERE csm.CustID = M.CustID AND csm.IsGrouped = 0)    
               AND NOT EXISTS (SELECT 1 FROM CustPTSetting3rd_Member M1 WITH (NOLOCK) WHERE M1.CustID = M.CustID)
               
    END  

    
    ---- 35. IsGrouped Flag = 1 but not exists in Group PT table
    BEGIN   
         ----PRINT '32. IsGrouped Flag = 1 but not exists in Group PT table'
         INSERT INTO ##CheckPTResult_Credit (RuleDesc, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB, IsLive)  
         SELECT DISTINCT '35. IsGrouped Flag = 1 but not exists in Group PT table',NULL,NULL,M.CustID,M.CustID,NULL,NULL,NULL
         FROM #MemberPT M
         WHERE EXISTS (SELECT 1 FROM CustSettingMode3rd csm WITH (NOLOCK) WHERE csm.CustID = M.CustID AND csm.IsGrouped = 1)    
                AND NOT EXISTS (SELECT 1 FROM CustPTGroupSetting3rd_Member M1 WITH (NOLOCK) WHERE M1.AgentID = M.recommend)
               
    END  

END
GO
GRANT EXECUTE ON [dbo].[DBA_CheckPTGame_for_Line_DCS] TO [vnteam] AS [dbo]
GO


