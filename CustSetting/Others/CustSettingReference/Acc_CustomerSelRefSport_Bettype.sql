/*<info serverAlias="DBTXN-bodb02" executers="bodbadminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE  [dbo].[Acc_CustomerSelRefSport_Bettype]
        @CustID                INT = NULL
    ,@RoleID                INT = 0 
    ,@isShowAll                BIT = 1 
AS 
/*
    Created by: Jamie
    Date: 20140916
    Task: Retrieve Customer Setting Reference 
    DB: DBTXN/bodb02 

    Revision: 
            - 20150606@Kathy: Change link server DBTXN.CustDB to DBCust.CustDB [Redmine:#36216]
            - 20150904@Helen: commission setting for MO [Redmine #41470]
            - 20160201@Percy: Support new Cricket [Redmine: #50027]
            - 20160923@Winnie: PH_AIO-_Phase_2 Hide parent(413,414,416) and using Sport_Bettype_Reference_Setting  [Redmine: #63076]
            - 20161010@Elodie: Intergrate NG2 product
            - 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
            - 20170801@Elodie: Add Keno Lottery Product - [Redmine #74313]
            - 20180125@Winnie: Hide inactive products [RedmineID: #86086]
            - 20180214@Vicky: Add VS Basketball Product - [Redmine #89284]
            - 20180529@Winnie: Alpha/EXT NAP - Super/Master/Agent/Member List: missing 6 new Keno bettypes in select SP [RedmineID: #96035]
            - 20180830@Elodie: Add Poker Games Product - [Redmine: #97675]
            - 20181218@Johnson: Add Happy 5 [Redmine: #104006]
            - 20181227@Johnson: Add range for VS Betradar(190-198) [Redmine: #104809]
            - 20190530@Elodie: Exclude data of CN88 site
            - 20190729@Eden: Use new table Sport_Bettype_Reference_Setting instead of Sport_Bettype_Reference for keno [Redmine: #116466]
            - 20190910@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
            - 20200713@Eden: Integrate 3 new bet types for Keno [Redmine: #137475]
            - 20200826@Elodie: Add NG Color Ball - [Redmine: #128220]
            - 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
            - 20210104@Winfred: Add Happy 5 Linked game [Redmine: #146965]
            - 20201209@winfred: get Disable Keno for customer list smartphone [redmine: #137130]
            - 20211112@Johnson: rollback code for revision 20201209@winfred [redmine:#163077]
            - 20220822@Tacy: hardcode show PT setting info for bettype: 3915, 3900 [RedmineID: #173861]
            - 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
            - 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
			- 20230814@Luke: Basketball AIO [Redmine: #191334]
			- 20231016@Luke: Offer 10 upcoming sports for Winter Sports [Redmine: #194661]

    Param's Explanation: 
            @CustID (Login account): =NULL: Admin ; =NOT NULL: SMA 
            @isShowAll: 0: Show Active Bettype, 1: Show ALL 

    Sample: EXEC [Acc_CustomerSelRefSport_Bettype] @CustID = 19096909 , @RoleID = 2 

*/
BEGIN
    SET NOCOUNT ON 
    DECLARE         @HideNG2                                BIT = 0 
                    --,@HideVS                                BIT = 0 
                    --,@HideLottery                        BIT = 0
                    ,@IsMyanmarOdds                        BIT = 0           -- MyanmarOdds
                    ,@srecommend                        INT        
                    ,@isIMBC                                BIT = 0
        
    CREATE TABLE #tempRef (Bettype INT,GroupTypeId INT)        

    DECLARE @SearchQuery varchar(1024)

    SELECT @SearchQuery = 'SELECT * 
    FROM OPENQUERY(DBAGE, 
    ''SELECT Bettype , GroupTypeId FROM bodb02.dbo.f_GroupBettype( )'')'

    INSERT INTO #tempRef
    EXECUTE(@SearchQuery)

    DELETE FROM #tempRef 
    WHERE bettype=GroupTypeId OR BetType IN (3915,3900)  

    IF @RoleID = 1 AND ISNULL(@CustID, 0) <> 0
            IF (SELECT [Site] FROM DBCUST.CustDB.dbo.Customer WITH (NOLOCK)
                                                WHERE custid = (SELECT recommend FROM DBCUST.CustDB.dbo.Customer WITH (NOLOCK)
                                                                                WHERE custid = @CustID)) = 'IMBC'
                    SELECT @isIMBC = 1
    ELSE
            IF (SELECT [Site] FROM DBCUST.CustDB.dbo.Customer WITH (NOLOCK)
                                                WHERE custid = @CustID) = 'IMBC'
                    SELECT @isIMBC = 1
        
    IF @RoleID BETWEEN 2 AND 4 
    BEGIN        
                    -- MyanmarOdds
                    SET @IsMyanmarOdds = CustDB.dbo.fn_IsMyanmarOdds(@srecommend)
                        
                    SELECT @HideNG2 = (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapIsHidden,4))
                    FROM DBCUST.CustDB.dbo.CustProductStatus WITH (NOLOCK)
                    WHERE CustID = @CustID        

                    --SELECT @HideVS = (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapIsHidden,10))
                    --FROM DBCUST.CustDB.dbo.CustProductStatus WITH (NOLOCK)
                    --WHERE CustID = @CustID
                        
                    --SELECT @HideLottery = (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapIsHidden,11))
                    --FROM DBCUST.CustDB.dbo.CustProductStatus WITH (NOLOCK)
                    --WHERE CustID = @CustID                

    END
        
    IF @RoleID = 1
    BEGIN
            SET @srecommend = (SELECT srecommend FROM DBCUST.CustDB.dbo.CustInfo WITH (NOLOCK) WHERE custid=@CustID)
            SET @IsMyanmarOdds = CustDB.dbo.fn_IsMyanmarOdds(@srecommend)
    END
    IF @RoleID = 0
            SET @IsMyanmarOdds = 1
                        
    ;WITH CTE AS (
            SELECT        Sporttype, Bettype, SporttypeRef, BettypeRef ,ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
            FROM        dbo.Sport_Bettype_Reference WITH (NOLOCK)
            WHERE        Sporttype NOT IN (
                                        CASE WHEN @IsMyanmarOdds = 0 AND Bettype IN (1,3,7,8) THEN 1 ELSE 0 END -- MyanmarOdds
                                    ,27, 50 -- Cricket
                                    ,220 --Lottery
                                    ,161,164,202
                            )
                            AND bettype NOT IN(SELECT Bettype FROM #tempRef)
                            AND isLicensee = 0 
                            AND isActive = CASE WHEN @isShowAll = 0 THEN 1 ELSE isActive END
                            AND SportType NOT BETWEEN 180 AND 186 --Virtual Sport
                            AND SportType NOT BETWEEN 190 AND 198 --Virtual Sport
            UNION ALL
            SELECT        Sporttype, Bettype, SporttypeRef, BettypeRef ,ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
            FROM Sport_Bettype_Reference WITH (NOLOCK)
            WHERE   Sporttype IN (27, 50)
                            AND [Site] IN (
                                        CASE WHEN ISNULL(@CustID, 0) = 0 THEN 'IMBC' END -- ALL
                                    ,CASE WHEN ISNULL(@CustID, 0) = 0 THEN 'ALL'  END -- ALL
                                    ,CASE WHEN ISNULL(@CustID, 0) <> 0 AND @isIMBC = 1 THEN 'IMBC' END -- IMBC only
                                    ,CASE WHEN ISNULL(@CustID, 0) <> 0 AND @isIMBC = 0 THEN 'ALL'  END -- MBC  only
                            )
                            AND isLicensee = 0
                            AND isActive = CASE WHEN @isShowAll = 0 THEN 1 ELSE isActive END
        
            UNION ALL 
            SELECT DISTINCT Sporttype, Bettype, SporttypeRefPT, BettypeRefPT ,ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
            FROM Sport_Bettype_Reference_Setting b WITH(NOLOCK)
            WHERE   bettype NOT IN (SELECT Bettype FROM #tempRef)
                            AND isLicensee = 0
                            AND isActive = CASE WHEN @isShowAll = 0 THEN 1 ELSE isActive END
                            AND (SportType<>SporttypeRefPT OR bettype <>BettypeRefPT)
                            AND NOT EXISTS (SELECT TOP 1 1 FROM Sport_Bettype_Reference a (NOLOCK) WHERE a.Sporttype=b.SportType AND a.Bettype=b.BetType)
                            AND (SportType<=99 -- Sportbook        
                                            OR b.SportType BETWEEN 213 AND 218 --NG2
                                            --OR (b.SportType BETWEEN 180 AND 186 OR b.SportType BETWEEN 190 AND 198) --Virtual Sport
                                            --OR b.SportType = 220 -- Lottery
                                            ) 
                            AND 1 = CASE WHEN @HideNG2 = 1 AND b.SportType BETWEEN 213 AND 218 THEN 0 ELSE 1 END
                            --AND 1 = CASE WHEN @HideVS = 1 AND (b.SportType BETWEEN 180 AND 186 OR b.SportType BETWEEN 190 AND 198) THEN 0 ELSE 1 END
                            --AND 1 = CASE WHEN @HideLottery = 1 AND b.SportType = 220 THEN 0 ELSE 1 END
                            AND b.Site <> 'CN88'
			--191334
            UNION ALL
            SELECT CONVERT(SMALLINT,2) AS Sporttype, 647 AS Bettype,  CONVERT(SMALLINT,2)  AS SporttypeRefPT, 9999 AS BettypeRefPT, ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
            UNION ALL
            SELECT CONVERT(SMALLINT,2)  AS Sporttype, 648 AS Bettype,  CONVERT(SMALLINT,2)  AS SporttypeRefPT, 9999 AS BettypeRefPT, ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
            UNION ALL
            SELECT CONVERT(SMALLINT,2)  AS Sporttype, 649 AS Bettype,  CONVERT(SMALLINT,2)  AS SporttypeRefPT, 9999 AS BettypeRefPT, ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
            UNION ALL
            SELECT CONVERT(SMALLINT,2)  AS Sporttype, 650 AS Bettype,  CONVERT(SMALLINT,2)  AS SporttypeRefPT, 9999 AS BettypeRefPT, ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
			
			--194661
			UNION ALL
            SELECT CONVERT(SMALLINT,58) AS Sporttype, 7 AS Bettype,  CONVERT(SMALLINT,99)  AS SporttypeRefPT, 1 AS BettypeRefPT, ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
			UNION ALL
            SELECT CONVERT(SMALLINT,58) AS Sporttype, 8 AS Bettype,  CONVERT(SMALLINT,99)  AS SporttypeRefPT, 3 AS BettypeRefPT, ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
			UNION ALL
            SELECT CONVERT(SMALLINT,58) AS Sporttype, 12 AS Bettype,  CONVERT(SMALLINT,99)  AS SporttypeRefPT, 2 AS BettypeRefPT, ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
			UNION ALL
            SELECT CONVERT(SMALLINT,58) AS Sporttype, 21 AS Bettype,  CONVERT(SMALLINT,99)  AS SporttypeRefPT, 20 AS BettypeRefPT, ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
    )
    SELECT Sporttype 
            , CASE WHEN Sporttype=6 and bettype=3900 THEN 4 ELSE bettype END Bettype
            , SporttypeRef, BettypeRef, IsMyanmarOdds
    FROM CTE
    ORDER BY Sporttype, Bettype, SporttypeRef, BettypeRef

    DROP TABLE #tempRef
END
GO