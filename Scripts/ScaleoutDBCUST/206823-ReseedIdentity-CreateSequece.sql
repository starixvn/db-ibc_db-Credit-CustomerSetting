/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240717@Helen
	 Task: Reseed & create sequence [Redmine:#206823]
	 DB: DBGLOB-GLOBCUSTDB

	 Revision:
		- 20240717@Helen: Reseed identity & Sequence [Redmine:#206823]
*/
USE CUSTDB
GO

DECLARE @max_customer int, @max_custsub int
DECLARE @max_customer_Reseed int, @max_custsub_Reseed INT
DECLARE @max_customer_Sequence int, @max_custsub_Sequence INT
DECLARE @MAXVALUE_customer_4_sequence INT, @MAXVALUE_custsub_4_sequence INT

SELECT @max_customer = max(custid) from customer with (nolock)
SELECT @max_custsub = max(subaccid) from custsub with (nolock)

 SELECT @max_customer_Reseed = @max_customer + 30000
	, @max_custsub_Reseed = @max_custsub + 3000
	, @max_customer_Sequence = @max_customer + 1 
	, @max_custsub_Sequence = @max_custsub + 1
	, @MAXVALUE_customer_4_sequence = @max_customer + 30000 - 30
	, @MAXVALUE_custsub_4_sequence = @max_custsub + 3000 - 30

DBCC CHECKIDENT ('Customer', RESEED, @max_customer_Reseed);

DBCC CHECKIDENT ('CustSub', RESEED, @max_custsub_Reseed);

-- USE FOR TRIGGER
SELECT @max_customer_Reseed AS max_customer_4_trigger, @max_custsub_Reseed AS max_custsub_4_trigger

-- USE FOR SEQUENCE
SELECT @max_customer_Sequence AS max_customer_4_sequence, @max_custsub_Sequence AS max_custsub_4_sequence
SELECT @MAXVALUE_customer_4_sequence AS MAXVALUE_customer_4_sequence, @MAXVALUE_custsub_4_sequence AS MAXVALUE_custsub_4_sequence

USE GlobCustDB
GO
-- Nhớ USE GlobCustDB trước khi làm: Ịn vô dùm, ko dùng param được, thông cảm nha. Mãi yêu!!!!
CREATE SEQUENCE seq_CustinfoMini START WITH @max_customer_Sequence INCREMENT by 1   MAXVALUE	@MAXVALUE_customer_4_sequence
CREATE SEQUENCE seq_CustSubMini START WITH @max_custsub_Sequence   INCREMENT by 1   MAXVALUE	@MAXVALUE_custsub_4_sequence

/*
CREATE SEQUENCE seq_CustinfoMini START WITH 136860011 INCREMENT by 1 
CREATE SEQUENCE seq_CustSubMini START WITH 1978760 INCREMENT by 1 
*/