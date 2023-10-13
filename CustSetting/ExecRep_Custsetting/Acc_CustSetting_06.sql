/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
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
		
    Param's Explanation: 

    */

BEGIN
	SET NOCOUNT ON;
	--------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Declare Param

	DECLARE  @Batch			INT = 5000
	

	-- Declare Table Temp
	DECLARE @Tbl_Comm TABLE (
		SportType		SMALLINT ,
		BetType		SMALLINT ,
		Discount		DECIMAL (9,8)
	)

	CREATE TABLE #UserNoCom       (CustID  INT , RoleID INT)
	CREATE TABLE #Agent		(CustID  INT , RoleID INT)
	CREATE TABLE #AgentTmp		(CustID  INT)
	CREATE TABLE #Member		(CustID  INT)
	CREATE TABLE #MemberTmp		(CustID  INT)
	

	--------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Update Commission Call From Acc_CustomerUpd_Commission
	IF (@GroupType = 150)
	BEGIN
		IF NOT(dbo.f_CheckRepTable('custinfo') = 1 
		   AND dbo.f_CheckRepTable('customer') = 1 
		   AND dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 1  
		   AND dbo.f_CheckRepTable('CustDiscount3rd_Member') = 1  
		   )
   
		RETURN 

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

		-- Get Data Cust List
		IF @roleid = 4
		BEGIN
			INSERT INTO #Agent (CustID , RoleID)
			SELECT CustID , i.roleid
			FROM custInfo i WITH (NOLOCK)
			WHERE i.srecommend = @CustID AND i.roleid IN (3,2) AND i.Enabled = 1

			INSERT INTO #Member (CustID)
			SELECT CustID
			FROM custInfo i WITH (NOLOCK)
			WHERE i.srecommend = @CustID AND i.roleid = 1 AND i.Enabled = 1

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

			INSERT INTO #Member (CustID )
			SELECT CustID
			FROM custInfo i WITH (NOLOCK)
			WHERE i.mrecommend = @CustID AND i.roleid = 1 AND i.Enabled = 1

			-- 20190909@Winnie: customer list not give commission for downlines	
			INSERT INTO #UserNoCom (custid, roleid)
			SELECT a.CustID , b.roleid 
			FROM CustNoComm a WITH (NOLOCK)
			INNER JOIN custInfo b WITH(NOLOCK) ON a.custid=b.CustID
			WHERE b.mrecommend = @CustId
		END
		ELSE IF @roleid = 2
		BEGIN
			INSERT INTO #Member (CustID )
			SELECT CustID 
			FROM custInfo i WITH (NOLOCK)
			WHERE i.recommend = @CustID AND i.roleid = 1 AND i.Enabled = 1

			-- 20190909@Winnie: customer list not give commission for downlines	
			INSERT INTO #UserNoCom (custid, roleid)
			SELECT a.CustID , b.roleid 
			FROM CustNoComm a WITH (NOLOCK)
			INNER JOIN custInfo b WITH(NOLOCK) ON a.custid=b.CustID
			WHERE b.recommend = @CustId
		END

		-- Update Downline:
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
					SET cds.Discount = nc.Discount
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
					SET cds.Discount = nc.Discount
				FROM CustDiscount3rd_Agent cds WITH (ROWLOCK , UPDLOCK)
				INNER JOIN #AgentTmp a ON cds.CustID = a.CustID
				INNER JOIN @Tbl_Comm nc ON cds.SportType = nc.SportType AND cds.BetType = nc.BetType
				WHERE cds.Discount > nc.Discount
			
			END

		END
		IF (@Roleid IN (2,3,4))
		BEGIN
			-- Update related downline
			WHILE (1=1)
			BEGIN

				TRUNCATE TABLE #MemberTmp

				DELETE TOP (@Batch) m
				OUTPUT DELETED.CustID  INTO #MemberTmp (CustID)
				FROM #Member m

				IF @@rowcount = 0
					BREAK;

				-- Part 1: WITH SportType = 1 : Handble For Non MyanmarOdds Discount
				IF @RoleID = 4
				BEGIN
				
					-- Update SuperDiscount of Downline
					UPDATE cdm SET	
							cdm.SuperDiscount = nc.Discount 
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE c.srecommend = @CustId
					AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)
					AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1)  
					AND cdm.SportType = 1

					-- Compare MasterDiscount with SuperDiscount 
					UPDATE cdm SET 
						cdm.MasterDiscount = CASE 
										WHEN cdm.MasterDiscount > cdm.SuperDiscount THEN cdm.SuperDiscount  
										ELSE cdm.MasterDiscount
									   END
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE cdm.SportType = 1

					-- Compare AgentDiscount with MasterDiscount 
					UPDATE cdm SET 
						cdm.AgentDiscount = CASE 
										WHEN cdm.AgentDiscount > cdm.MasterDiscount THEN cdm.MasterDiscount
										ELSE cdm.AgentDiscount
									   END
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE cdm.SportType = 1


					-- Part 2: WITH SportType = 2 : Handble MyanmarOdds Discount
					UPDATE cdm
						SET	cdm.SuperDiscount  = nc.Discount
						,	cdm.MasterDiscount = nc.Discount
						,	cdm.AgentDiscount  = nc.Discount
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE cdm.SportType = 2
				END
				ELSE IF @RoleID = 3
				BEGIN
				
					-- Update MasterDiscount of Downline
					UPDATE cdm 	SET  cdm.MasterDiscount = nc.Discount 
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE c.mrecommend = @CustId
					AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)
					AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1) 
					AND cdm.SportType = 1

					-- Compare AgentDiscount with MasterDiscount 
					UPDATE cdm SET 
						cdm.AgentDiscount = CASE 
										WHEN cdm.AgentDiscount > cdm.MasterDiscount THEN cdm.MasterDiscount  
										ELSE cdm.AgentDiscount
									  END
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE cdm.SportType = 1

					-- Part 2: WITH SportType = 2 : Handble MyanmarOdds Discount
					UPDATE cdm
						SET	cdm.MasterDiscount = nc.Discount
						,	cdm.AgentDiscount  = nc.Discount
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE cdm.SportType = 2

				END
				IF @RoleID = 2
				BEGIN
				
					-- Update AgentDiscount of Downline
					UPDATE cdm
					SET  cdm.AgentDiscount = nc.Discount 
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN Customer c  WITH (NOLOCK) ON cdm.CustID = c.custid 
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE c.recommend = @CustId
					AND c.recommend NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 2)
					AND c.custid NOT IN (SELECT custid FROM #UserNoCom unc WHERE roleid = 1) 
					AND cdm.SportType = 1

					-- Compare PlayerDiscount with AgentDiscount 
					UPDATE cdm SET 
						cdm.PlayerDiscount = CASE 
										WHEN cdm.PlayerDiscount > cdm.AgentDiscount THEN cdm.AgentDiscount  
										ELSE cdm.PlayerDiscount
									  END
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE cdm.SportType = 1

					-- Part 2: WITH SportType = 2 : Handble MyanmarOdds Discount
					UPDATE cdm
						SET	cdm.AgentDiscount  = nc.Discount
					FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
					INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
					INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
					WHERE cdm.SportType = 2
				END

			

				-- Part 3: Compare PlayerDiscount with AgentDiscount, Handble For ALL (SportType IN 1,2)
				UPDATE cdm
					SET    
						cdm.PlayerDiscount = cdm.AgentDiscount
				FROM CustDiscount3rd_Member cdm WITH (ROWLOCK , UPDLOCK)
				INNER JOIN #MemberTmp mt ON cdm.CustID = mt.CustID
				INNER JOIN @Tbl_Comm nc ON cdm.SportType = nc.SportType AND cdm.BetType = nc.BetType
				WHERE  cdm.PlayerDiscount > cdm.AgentDiscount
			END
		END
	END
END