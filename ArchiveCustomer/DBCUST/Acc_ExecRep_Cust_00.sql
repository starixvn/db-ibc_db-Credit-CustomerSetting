/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [Acc_ExecRep_Cust_00]
	@CustIDs VARCHAR(MAX)
AS 
/*
	Created by: Daniel
	Date: 2015-01-12
	Task: For archive Acc (New) - update/delete part in stage 1,2,3 
	DB: DBCUST/CustDB
	Original: Acc_ExecRep_Cust_01
	Revision:
		- 20180126@Daniel: add pre-stage - close agents and downnlines (@Type = -1)
		- 20180822@Daniel: Remove table custVirtuaRate
		- 20190917@Daniel: Remove unused tables P2PGameSetting, P2PGroupComm for clean up inactive product (#117439 - P2)
		- 20190925@Daniel: Remove SP Recompile & involve more setting tables
		- 20191217@Daniel: Remove delete custsearch due to perf issue
		- 20200922@Helen: Remove old table [Redmine:130032]
		- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
		- 20201201@Eden: NAP/Alpha & EXT - Apply color for archived accounts [Redmine:145018]
		- 20210316@Helen: backup CustSub and delete for stage 4 [RedmineID: #130032]
		- 20210203@Eden: NAP/Alpha & EXT - Mark ClosedReason = 4 for satisfied archiving accounts of stage 1 [RedmineID: #149450]
		- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
		- 20210923@Eden: Include newly created tables into Archive Credit Dormant Account process [redmine: #162050]
		- 20220907@Eden: Scale out DBTrans [RedmineID: #158293]
		- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20230524@Eden: Change batch update delete data to 5000 [Redmine: #181595]
		- 20230529@Eden: Archiving credit accounts for additional tables [Redmine: #188850]
		- 20230529@Eden: Check permission of KL Environment [Redmine: #199968]
		- 20240724@Elodie: Replace SiteDB [RedmineID: #207738]
		- 20231019@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]
		- 20241030@Helios: ScaleOut Apply DeleteInHouse - Extend more table - Remove Code Old Structure [RedmineID: #201061]
		- 20250102@Eden: Archiving direct member [redmine: #215533] 

	Param's Explanation:
		@Type: 
			+ -1-Stage 1: update closed = 1 for whole agent line
			+ 0 -Stage 2: update enable = 0 & credit = 0 for whole agent line
			+ 1 -Stage 3: Delete cust setting for members under agent
			+ 2 -Stage 4: Delete cust info for members under agent
			
 --test rep---
*/
BEGIN
	IF NOT (
				@@SERVERNAME IN ('DBTRANS','SITDBTRANS','TESTDBTRANS','DB66')  
				OR  @@SERVERNAME LIKE 'DBGRP%'   -- PRO
				OR  @@SERVERNAME LIKE 'SITDBGRP%'  --SIT 
				OR  @@SERVERNAME LIKE 'DBSITEC%'   -- PRO
				OR  @@SERVERNAME LIKE 'SITDBSITEC%'  --SIT 
				OR  @@SERVERNAME LIKE 'TESTSITEDB%'  --Local
			)
	BEGIN
		RETURN
	END

	CREATE TABLE #temp_DirectMember (custid INT PRIMARY KEY)

	INSERT INTO #temp_DirectMember(custid)
	SELECT value 
	FROM STRING_SPLIT(@CustIDs,',')
	WHERE value <> 0

	BEGIN
			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalCreditSports WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (SELECT custid FROM  #temp_DirectMember)

				IF @@ROWCOUNT < 5000
					BREAK
			END

			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalDebitSports WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (SELECT custid FROM  #temp_DirectMember)

				IF @@ROWCOUNT < 5000
					BREAK
			END

			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalCreditCasino WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (SELECT custid FROM  #temp_DirectMember)

				IF @@ROWCOUNT < 5000
					BREAK
			END

			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalDebitCasino WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (SELECT custid FROM  #temp_DirectMember)

				IF @@ROWCOUNT < 5000
					BREAK
			END

			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalCreditOthers WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (SELECT custid FROM  #temp_DirectMember)

				IF @@ROWCOUNT < 5000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalDebitOthers WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (SELECT custid FROM  #temp_DirectMember)

				IF @@ROWCOUNT < 5000
					BREAK
			END

			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalCreditTransfer WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (SELECT custid FROM  #temp_DirectMember)

				IF @@ROWCOUNT < 5000
					BREAK
			END


			WHILE (1=1)
			BEGIN
				DELETE TOP(5000) bodb02.dbo.BalDebitTransfer WITH(ROWLOCK,UPDLOCK) 
				WHERE custid IN (SELECT custid FROM  #temp_DirectMember)

				IF @@ROWCOUNT < 5000
					BREAK
			END

		END -- END of DBTRANS - delete balance tables

		DROP TABLE #temp_DirectMember
END
GO