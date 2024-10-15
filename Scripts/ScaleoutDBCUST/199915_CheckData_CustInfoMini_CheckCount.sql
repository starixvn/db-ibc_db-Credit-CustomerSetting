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
DECLARE @maxcustid INT, @custid_invalid_cnt INT, @listcust_temp INT
SET @maxcustid = (SELECT max(custid) from vw_Customer WITH (NOLOCK))
SELECT @maxcustid

;WITH cte
AS
(
SELECT custid 
FROM vw_Customer WITH (NOLOCK)
WHERE custid <= @maxcustid
UNION ALL
SELECT custid
FROM Dep_Customer_Archived WITH (NOLOCK)
WHERE custid <= @maxcustid
)

SELECT @listcust_temp =  COUNT(1) FROM cte

SELECT @listcust_temp 
--122267243
SET @custid_invalid_cnt = (SELECT COUNT(1)
FROM vw_Customer c WITH (NOLOCK)
	INNER JOIN Dep_Customer_Archived a WITH (NOLOCK) ON c.custid = a.CustID
WHERE c.custid <= @maxcustid -- 149901709
)

SELECT @custid_invalid_cnt

SELECT @listcust_temp - @custid_invalid_cnt AS total_customers

--------Step 2 (DBGLOB/CUSTDB): Get total custid in  ---------
USE CUSTDB
GO
DECLARE @maxcustid INT
SET @maxcustid = xxx -- FROM step 1
SELECT COUNT(1) 
FROM CustInfoMini WITH (NOLOCK)
WHERE custid <= @maxcustid 