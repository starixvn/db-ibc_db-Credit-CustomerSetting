/*<info serverAlias="DBTP-bodb02,DBGLOB-CUSTDB" executers="" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240717@Helen
	 Task: check data - check row count [Redmine:#206823]
	 DB: DBGLOB-GLOBCUSTDB

	 Revision:
		- 20240717@Helen: check data - check row count [Redmine:#206823]

	SIT & LOCAL: CAN run DBCUST/CUSTDB for both steps
	PRO: STEP 1: Run at DBTP/bodb02, STEP 2: Run at DBGLOB/CUSTDB
*/
--------Step 1 (DBTP/bodb02): Get total custid in customer and Dep_Customer_Archived ---------
DECLARE @maxsubaccid INT, @custid_invalid_cnt INT, @listcust_temp INT
SET @maxsubaccid = (SELECT max(subaccid) FROM custSub WITH (NOLOCK))
SELECT @maxsubaccid

SELECT COUNT(1)
FROM custSub WITH (NOLOCK)
WHERE subaccid <= @maxsubaccid

--------Step 2 (DBGLOB/CUSTDB): Get total custid in  ---------
USE CUSTDB
GO
DECLARE @maxsubaccid INT
SET @maxsubaccid = XXX -- FROM step 1
SELECT COUNT(1) 
FROM CustSubMini WITH (NOLOCK)
WHERE subaccid <= @maxsubaccid 