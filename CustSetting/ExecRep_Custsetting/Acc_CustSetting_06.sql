/*<info serverAlias="DBCUST-CustDB" executers="wsv_alp,wsv_nap,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_06]

    @CustId				INT
  , @RoleId				INT
  , @JsonComm			VARCHAR(MAX)
  , @GroupType			SMALLINT

AS

/*
    Created: Kathy
    Date: 20131029
    Task : Update commission [Redmine:#3244]
    DB: DBTXN.bodb02
    Original: 
    Revisions:
        - 20131029: Update Sportbook's commission for all level. Refer to:
            + Acc_CustomerUpdSuper_Commission
            + Acc_CustomerUpdMaster_Commission
            + Acc_CustomerUpdAgent_Commission
            + Acc_CustomerUpdMember_Commission
        
        - 20131105@Elodie: Add HR Fixed Odds [Redmine:#6505]
        - 20140708@Johnson: Add bettype Others for soccer & tennis [Redmine #16903]
        - 20140729@Logan:   1.Exclude disabled agents while updating SM's setting [Redmine: #19631]
                            2.Code aligning on modified parts
		- 20141113@Johnson: Hardcode agent list not give commission for downlines [Redmine #25787]                      
		- 20150610@Daniel: 
			+ Improve medthod check table existing in subscribers	
			+ Separate custDB to new server DBCUST   
		- 20150616@Johnson: Add more hard customers not give commission [Redmine: #34798]
		- 20150904@Helen: commission setting for MO [Redmine #41470]
		- 20151111@Helen: Add more hard customers not give commission [Redmine: #47068]
	    - 20151222@Johnson: Add more customers not give commission [Redmine: #49494]		
	    - 20160125@Helen: Add more customers not give commission [Redmine: #51057]		
		- 20160608@Elodie: Add more customers not give commission [Redmine: #58999]		
		- 20160621@Winnie: Add more customers not give commission [Redmine: #58999]		
		- 20160901@Winnie: Add more customer ALHKD not give commission [Redmine: #58999]	
		- 20160909@Winnie: Create the table CustNoComm to save customers not give commission [Redmine: #63736]
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086] 
		- 20190829@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
		- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]	
		- 20230310@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083] 
		- 20241205@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969]  
		
    Param's Explanation: 

    */

BEGIN
	SET NOCOUNT ON;
	--------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Declare Param
	
	DECLARE  
	  @Batch		INT = 2000
	DECLARE @AgentID INT

	-- Declare Table Temp
	DECLARE @Tbl_Comm TABLE (
		SportType		SMALLINT ,
		BetType		SMALLINT ,
		Discount		DECIMAL (9,8)
	)

	CREATE TABLE #UserNoCom       (CustID  INT , RoleID INT)
	CREATE TABLE #Agent		(CustID  INT , RoleID INT)
	CREATE TABLE #AgentTmp		(CustID  INT)
	CREATE TABLE #Member		(CustID  INT , uGroup VARCHAR(5) )
	CREATE TABLE #MemberTmp		(CustID  INT , uGroup VARCHAR(5) )
	

	--------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Update Commission Call From Acc_CustomerUpd_Commission
	IF (@GroupType = 150)
	BEGIN
		IF NOT (dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
			AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT	
		)
		RETURN;
	     
		-- Parse Data Json
		INSERT INTO @Tbl_Comm  ( SportType , BetType , Discount)
		SELECT Comm.SportType , Comm.BetType , Comm.Discount
		FROM OPENJSON(@JsonComm )
		WITH 
			(
				SportType		SMALLINT,
				BetType		SMALLINT,
				Discount		DECIMAL (9,8)
			) AS Comm

		-- UPDATE Main Discount Role Member
		IF @RoleID = 1
		BEGIN
			SELECT @AgentID = recommend from custinfo WITH(NOLOCK) WHERE custid = @CustId

			-- Update Main Discount Of Member
			UPDATE cdm
			SET cdm.PlayerDiscount = nc.Discount,
				cdm.AgentDiscount = CASE WHEN @AgentID IN(-3,-4) THEN nc.Discount ELSE cdm.AgentDiscount END, 
				cdm.MasterDiscount = CASE WHEN @AgentID = -4 THEN nc.Discount ELSE cdm.MasterDiscount END,
				cdm.RepUpdateTime = dbo.f_GetDateTime2()
			FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
				INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
			WHERE cdm.CustID = @custid
		END

		-- UPDATE Main Discount Role Super/Master/Agent
		IF @RoleID IN (2,3,4)
		BEGIN
			
			-- Update Discount Values Of main Super or Master or Agent
			UPDATE cda
				SET cda.Discount = nc.Discount,
					RepUpdateTime = dbo.f_GetDateTime2()
			FROM CustDiscount3rd_Agent cda WITH (ROWLOCK , UPDLOCK)
			INNER JOIN @Tbl_Comm nc ON cda.SportType = nc.SportType AND cda.BetType = nc.BetType
			WHERE cda.CustID = @custid
		
		END

		-- Get Data Cust List For Update Downline
		IF @roleid = 4
		BEGIN
			INSERT INTO #Agent (CustID , RoleID)
			SELECT CustID , i.roleid
			FROM custInfo i WITH (NOLOCK)
			WHERE i.srecommend = @CustID AND i.roleid IN (3,2) AND i.Enabled = 1

			INSERT INTO #Member (CustID , uGroup)
			SELECT i.CustID , c.ugroup
			FROM custInfo i WITH (NOLOCK)
			INNER JOIN Customer c WITH (NOLOCK) ON i.custid = c.custid
			WHERE i.srecommend = @CustID AND i.roleid = 1 AND i.Enabled = 1

			UPDATE m
				SET m.uGroup = CASE 
							WHEN m.uGroup IN ('a', 'hka', 'dea') THEN 'a'
							WHEN m.uGroup IN ('b', 'hkb', 'deb') THEN 'b'
							WHEN m.uGroup IN ('c', 'hkc', 'dec') THEN 'c'
							WHEN m.uGroup IN ('d', 'hkd', 'ded') THEN 'd'
							END
			FROM #Member m

			-- 20190909@Winnie: customer list not give commission for downlines	
			INSERT INTO #UserNoCom (custid, roleid)
			SELECT a.CustID , b.roleid 
			FROM CustNoComm a WITH (NOLOCK)
			INNER JOIN custInfo b WITH(NOLOCK) ON a.custid=b.CustID
			WHERE b.srecommend = @CustId
		END
		ELSE IF @roleid = 3
		BEGIN
			INSERT INTO #Agent (CustID , RoleID)
			SELECT CustID , i.roleid
			FROM custInfo i WITH (NOLOCK)
			WHERE i.mrecommend = @CustID AND i.roleid = 2 AND i.Enabled = 1

			INSERT INTO #Member (CustID , uGroup)
			SELECT i.CustID , c.ugroup
			FROM custInfo i WITH (NOLOCK)
			INNER JOIN Customer c WITH (NOLOCK) ON i.custid = c.custid
			WHERE i.mrecommend = @CustID AND i.roleid = 1 AND i.Enabled = 1

			UPDATE m
				SET m.uGroup = CASE 
							WHEN m.uGroup IN ('a', 'hka', 'dea') THEN 'a'
							WHEN m.uGroup IN ('b', 'hkb', 'deb') THEN 'b'
							WHEN m.uGroup IN ('c', 'hkc', 'dec') THEN 'c'
							WHEN m.uGroup IN ('d', 'hkd', 'ded') THEN 'd'
							END
			FROM #Member m

			-- 20190909@Winnie: customer list not give commission for downlines	
			INSERT INTO #UserNoCom (custid, roleid)
			SELECT a.CustID , b.roleid 
			FROM CustNoComm a WITH (NOLOCK)
			INNER JOIN custInfo b WITH(NOLOCK) ON a.custid=b.CustID
			WHERE b.mrecommend = @CustId
		END
		ELSE IF @roleid = 2
		BEGIN
			INSERT INTO #Member (CustID , uGroup)
			SELECT i.CustID , c.ugroup
			FROM custInfo i WITH (NOLOCK)
			INNER JOIN Customer c WITH (NOLOCK) ON i.custid = c.custid
			WHERE i.recommend = @CustID AND i.roleid = 1 AND i.Enabled = 1

			UPDATE m
				SET m.uGroup = CASE 
							WHEN m.uGroup IN ('a', 'hka', 'dea') THEN 'a'
							WHEN m.uGroup IN ('b', 'hkb', 'deb') THEN 'b'
							WHEN m.uGroup IN ('c', 'hkc', 'dec') THEN 'c'
							WHEN m.uGroup IN ('d', 'hkd', 'ded') THEN 'd'
							END
			FROM #Member m

			-- 20190909@Winnie: customer list not give commission for downlines	
			INSERT INTO #UserNoCom (custid, roleid)
			SELECT a.CustID , b.roleid 
			FROM CustNoComm a WITH (NOLOCK)
			INNER JOIN custInfo b WITH(NOLOCK) ON a.custid=b.CustID
			WHERE b.recommend = @CustId
		END

		-- Start Update Downline
		IF (@Roleid = 4)
		BEGIN
			-- Update related downline Role Master
			WHILE (1=1)
			BEGIN
				TRUNCATE TABLE #AgentTmp
				DELETE TOP (@Batch) a
				OUTPUT DELETED.CustID  INTO #AgentTmp (CustID)
				FROM #Agent a
				WHERE a.RoleID = 3

				IF @@rowcount = 0
					BREAK;

				--SELECT 'Update Master' AS Note , cds.* , nc.Discount
				UPDATE cds
					SET cds.Discount = nc.Discount,
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustDiscount3rd_Agent cds WITH (ROWLOCK , UPDLOCK)
				INNER JOIN #AgentTmp a ON cds.CustID = a.CustID
				INNER JOIN @Tbl_Comm nc ON cds.SportType = nc.SportType AND cds.BetType = nc.BetType
				WHERE cds.Discount > nc.Discount
					
			END
		END
		IF (@Roleid IN (3,4))
		BEGIN
			-- Update related downline
			WHILE (1=1)
			BEGIN
			
				TRUNCATE TABLE #AgentTmp

				DELETE TOP (@Batch) a
				OUTPUT DELETED.CustID  INTO #AgentTmp (CustID)
				FROM #Agent a
				WHERE a.RoleID = 2

				IF @@rowcount = 0
					BREAK;

				UPDATE cds
					SET cds.Discount = nc.Discount,
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustDiscount3rd_Agent cds WITH (ROWLOCK , UPDLOCK)
				INNER JOIN Customer c  WITH (NOLOCK) ON cds.CustID = c.custid 
				INNER JOIN #AgentTmp a ON cds.CustID = a.CustID
				INNER JOIN @Tbl_Comm nc ON cds.SportType = nc.SportType AND cds.BetType = nc.BetType
				WHERE cds.Discount > nc.Discount
				AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)  -- to exclude Agent exits in CustNoComm
			
			END

		END
		IF (@Roleid IN (2,3,4))
		BEGIN
			-- Update Member Related downline
			WHILE (1=1)
			BEGIN

				TRUNCATE TABLE #MemberTmp

				DELETE TOP (@Batch) m
				OUTPUT DELETED.CustID , DELETED.uGroup  INTO #MemberTmp (CustID , uGroup)
				FROM #Member m

				IF @@rowcount = 0
					BREAK;

				-- Part 1: WITH SportType = 1 : Handble For Non MyanmarOdds Discount
				IF @RoleID = 4
				BEGIN
				
					-- Update SuperDiscount of Downline

						-- Update Group Discount Follow uGroup
						UPDATE cdm SET	
								cdm.SuperDiscount = nc.Discount,
								RepUpdateTime = dbo.f_GetDateTime2()
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType --AND cdm.BetType = nc.BetType
						WHERE c.srecommend = @CustId
						AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)	-- to exclude Agent exits in CustNoComm
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm
						AND nc.SportType = 1 AND cdm.BetType = 1
						AND mt.uGroup = CASE 
											WHEN nc.BetType = 1 THEN 'a'
											WHEN nc.BetType = 3 THEN 'b'
											WHEN nc.BetType = 7 THEN 'c'
											WHEN nc.BetType = 8 THEN 'd'
											END
					
						-- Update 1X2 Discount , Others Discount
						UPDATE cdm SET	
								cdm.SuperDiscount = nc.Discount,
								RepUpdateTime = dbo.f_GetDateTime2()
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
						WHERE c.srecommend = @CustId
						AND nc.SportType = 1 AND nc.BetType IN (4,5)
						AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)	-- to exclude Agent exits in CustNoComm
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm


					-- Compare MasterDiscount with SuperDiscount 

						-- Update Group Discount Follow uGroup
						UPDATE cdm SET 
							cdm.MasterDiscount = CASE 
											WHEN cdm.MasterDiscount > cdm.SuperDiscount THEN cdm.SuperDiscount  
											ELSE cdm.MasterDiscount
										   END,
							RepUpdateTime = dbo.f_GetDateTime2()
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType --AND cdm.BetType = nc.BetType
						WHERE cdm.SportType = 1 AND cdm.BetType = 1
						AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)	-- to exclude Agent exits in CustNoComm
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm
						AND mt.uGroup = CASE 
											WHEN nc.BetType = 1 THEN 'a'
											WHEN nc.BetType = 3 THEN 'b'
											WHEN nc.BetType = 7 THEN 'c'
											WHEN nc.BetType = 8 THEN 'd'
											END

						-- Update 1X2 Discount , Others Discount
						UPDATE cdm SET 
							cdm.MasterDiscount = CASE 
											WHEN cdm.MasterDiscount > cdm.SuperDiscount THEN cdm.SuperDiscount  
											ELSE cdm.MasterDiscount
										   END,
							RepUpdateTime = dbo.f_GetDateTime2()   
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
						WHERE cdm.SportType = 1 AND cdm.BetType IN (4,5)
						AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)	-- to exclude Agent exits in CustNoComm
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm



					-- Compare AgentDiscount with MasterDiscount
					
						-- Update Group Discount Follow uGroup
						UPDATE cdm SET 
							cdm.AgentDiscount = CASE 
											WHEN cdm.AgentDiscount > cdm.MasterDiscount THEN cdm.MasterDiscount
											ELSE cdm.AgentDiscount
										   END,
							RepUpdateTime = dbo.f_GetDateTime2()   
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType --AND cdm.BetType = nc.BetType
						WHERE cdm.SportType = 1 AND cdm.BetType = 1
						AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)	-- to exclude Agent exits in CustNoComm
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm
						AND mt.uGroup = CASE 
											WHEN nc.BetType = 1 THEN 'a'
											WHEN nc.BetType = 3 THEN 'b'
											WHEN nc.BetType = 7 THEN 'c'
											WHEN nc.BetType = 8 THEN 'd'
											END
						
						-- Update 1X2 Discount , Others Discount
						UPDATE cdm SET 
							cdm.AgentDiscount = CASE 
											WHEN cdm.AgentDiscount > cdm.MasterDiscount THEN cdm.MasterDiscount
											ELSE cdm.AgentDiscount
										   END,
							RepUpdateTime = dbo.f_GetDateTime2()
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
						WHERE cdm.SportType = 1 AND  cdm.BetType IN (4,5)
						AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)	-- to exclude Agent exits in CustNoComm
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm


					-- Part 2: WITH SportType = 2 : Handble MyanmarOdds Discount
					UPDATE cdm
						SET	cdm.SuperDiscount  = nc.Discount
						,	cdm.MasterDiscount = nc.Discount
						,	cdm.AgentDiscount  = nc.Discount
						,	RepUpdateTime = dbo.f_GetDateTime2()
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE cdm.SportType = 2 AND cdm.BetType = 1

				END
				ELSE IF @RoleID = 3
				BEGIN
				
					-- Update MasterDiscount of Downline

						-- Update Group Discount Follow uGroup
						UPDATE cdm 	
						SET  cdm.MasterDiscount = nc.Discount,
							 RepUpdateTime = dbo.f_GetDateTime2()
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType --AND cdm.BetType = nc.BetType
						WHERE c.mrecommend = @CustId
						AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)	-- to exclude Agent exits in CustNoComm
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm
						AND cdm.SportType = 1 AND cdm.BetType = 1 
						AND mt.uGroup = CASE 
											WHEN nc.BetType = 1 THEN 'a'
											WHEN nc.BetType = 3 THEN 'b'
											WHEN nc.BetType = 7 THEN 'c'
											WHEN nc.BetType = 8 THEN 'd'
											END

						-- Update 1X2 Discount , Others Discount
						UPDATE cdm 	
						SET  cdm.MasterDiscount = nc.Discount,
							 RepUpdateTime = dbo.f_GetDateTime2()
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
						WHERE c.mrecommend = @CustId
						AND cdm.SportType = 1 AND cdm.BetType IN (4,5)
						AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)	-- to exclude Agent exits in CustNoComm
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm

					-- Compare AgentDiscount with MasterDiscount 
					
						-- Update Group Discount Follow uGroup
						UPDATE cdm SET 
							cdm.AgentDiscount = CASE 
											WHEN cdm.AgentDiscount > cdm.MasterDiscount THEN cdm.MasterDiscount  
											ELSE cdm.AgentDiscount
										  END,
							RepUpdateTime = dbo.f_GetDateTime2()	  
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType --AND cdm.BetType = nc.BetType
						WHERE cdm.SportType = 1 AND cdm.BetType = 1
						AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)	-- to exclude Agent exits in CustNoComm
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm
						AND mt.uGroup = CASE 
											WHEN nc.BetType = 1 THEN 'a'
											WHEN nc.BetType = 3 THEN 'b'
											WHEN nc.BetType = 7 THEN 'c'
											WHEN nc.BetType = 8 THEN 'd'
											END

						-- Update 1X2 Discount , Others Discount
						UPDATE cdm SET 
							cdm.AgentDiscount = CASE 
											WHEN cdm.AgentDiscount > cdm.MasterDiscount THEN cdm.MasterDiscount  
											ELSE cdm.AgentDiscount
										  END,
							RepUpdateTime = dbo.f_GetDateTime2()
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
						WHERE cdm.SportType = 1 AND cdm.BetType IN (4,5)
						AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)	-- to exclude Agent exits in CustNoComm
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm


					-- Part 2: WITH SportType = 2 : Handble MyanmarOdds Discount
					UPDATE cdm
						SET	cdm.MasterDiscount = nc.Discount
						,	cdm.AgentDiscount  = nc.Discount
						,	RepUpdateTime = dbo.f_GetDateTime2()
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE cdm.SportType = 2 AND cdm.BetType = 1

				END
				IF @RoleID = 2
				BEGIN
				
					-- Update AgentDiscount of Downline

						-- Update Group Discount Follow uGroup
						UPDATE cdm
						SET  cdm.AgentDiscount = nc.Discount,
							 RepUpdateTime = dbo.f_GetDateTime2()
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType --AND cdm.BetType = nc.BetType
						WHERE c.recommend = @CustId
						AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)	-- to exclude Agent exits in CustNoComm
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm
						AND cdm.SportType = 1 AND cdm.BetType = 1
						AND mt.uGroup = CASE 
											WHEN nc.BetType = 1 THEN 'a'
											WHEN nc.BetType = 3 THEN 'b'
											WHEN nc.BetType = 7 THEN 'c'
											WHEN nc.BetType = 8 THEN 'd'
											END
					
						-- Update 1X2 Discount , Others Discount
						UPDATE cdm
						SET  cdm.AgentDiscount = nc.Discount,
							 RepUpdateTime = dbo.f_GetDateTime2()
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
						WHERE c.recommend = @CustId
						AND cdm.SportType = 1 AND cdm.BetType IN (4,5)
						AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)	-- to exclude Agent exits in CustNoComm
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm


					-- Part 2: WITH SportType = 2 : Handble MyanmarOdds Discount
					UPDATE cdm
						SET	cdm.AgentDiscount  = nc.Discount,
							RepUpdateTime = dbo.f_GetDateTime2()
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE cdm.SportType = 2 AND cdm.BetType = 1
				END

			

				-- Part 3: Compare PlayerDiscount with AgentDiscount, Handble For ALL (SportType IN 1,2)
				-- Compare PlayerDiscount with AgentDiscount 
					
						-- Update Group Discount Follow uGroup
						UPDATE cdm SET 
							cdm.PlayerDiscount = CASE 
											WHEN cdm.PlayerDiscount > cdm.AgentDiscount THEN cdm.AgentDiscount  
											ELSE cdm.PlayerDiscount
										  END,
							RepUpdateTime = dbo.f_GetDateTime2()
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType --AND cdm.BetType = nc.BetType
						WHERE cdm.SportType = 1 AND cdm.BetType = 1
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm
						AND mt.uGroup = CASE 
											WHEN nc.BetType = 1 THEN 'a'
											WHEN nc.BetType = 3 THEN 'b'
											WHEN nc.BetType = 7 THEN 'c'
											WHEN nc.BetType = 8 THEN 'd'
											END
						
					
						-- Update 1X2 Discount , Others Discount
						UPDATE cdm SET 
							cdm.PlayerDiscount = CASE 
											WHEN cdm.PlayerDiscount > cdm.AgentDiscount THEN cdm.AgentDiscount  
											ELSE cdm.PlayerDiscount
										  END,
							RepUpdateTime = dbo.f_GetDateTime2()
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
						WHERE cdm.SportType = 1 AND cdm.BetType IN (4,5)
						AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)	-- to exclude Member exits in CustNoComm
				
						-- Update MO
						UPDATE cdm
							SET	cdm.AgentDiscount  = nc.Discount,
								RepUpdateTime = dbo.f_GetDateTime2()
						FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
						INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
						INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
						WHERE cdm.SportType = 2 AND cdm.BetType  = 1
			END
		END
	END
END