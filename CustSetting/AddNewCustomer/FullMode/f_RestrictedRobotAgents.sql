/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="vnteam" isFunction="1"></info>*/
USE CustDB
GO

ALTER FUNCTION [dbo].[f_RestrictedRobotAgents] (
	@xtype varchar(10) -- agent/master
)
RETURNS @restrictedtList TABLE (custid int)
AS
/*
	Creator: Viet	
	Date: 20180704
	Task: Get Restricted Master/Agent List
	DB: DBCUST/CustDB
*/
BEGIN 	
	IF @xtype = 'agent'
	BEGIN
		;WITH _ag (recommend) AS (
			SELECT 29801393 -- test agents, for qc to verify
			UNION ALL SELECT 19103670 -- test Agent, for qc to verify
			UNION ALL SELECT 19741775 -- test Agent, for qc to verify
			UNION ALL SELECT 28938022 -- test Agent, for qc to verify
			UNION ALL SELECT 28891851 -- test Agent, for qc to verify
			UNION ALL SELECT 29801621 -- test Agent, for qc to verify
			---------------------
			UNION ALL SELECT 29189968	-- SD68103Z		-- added by Viet @ 20180704, approved by Bill	
		)	
		INSERT INTO @restrictedtList (custid)
		SELECT recommend
		FROM _ag
	END

	IF @xtype = 'master'
	BEGIN
		;WITH _mag (mrecommend) AS (
			SELECT 19741652 -- test masters, for QC to verify
			UNION ALL SELECT 28099463 -- test master, for QC to verify
			UNION ALL SELECT 29801147 -- test master, for QC to verify
			------------------
			UNION ALL SELECT 29488489 -- DTF1903	-- added by Viet @ 20180704, approved by Bill
			UNION ALL SELECT 29488508 -- DTF1904	-- added by Viet @ 20180704, approved by Bill
			UNION ALL SELECT 28988011 -- OP29TZ		-- added by Viet @ 20180704, approved by Bill
			UNION ALL SELECT 30915916 -- SD38AH		-- added by Viet @ 20180704, approved by Bill
			UNION ALL SELECT 30919961 -- SU7CM		-- added by Viet @ 20180704, approved by Bill
			UNION ALL SELECT 29944587 -- TK15Z1		-- added by Viet @ 20180704, approved by Bill
			UNION ALL SELECT 28785174 -- TVVD08		-- added by Viet @ 20180704, approved by Bill
			UNION ALL SELECT 29371475 -- TY95H1		-- added by Viet @ 20180704, approved by Bill
			UNION ALL SELECT 30891589 -- TY95KE		-- added by Viet @ 20180704, approved by Bill
			UNION ALL SELECT 29399238 -- XTV27H6	-- added by Viet @ 20180704, approved by Bill
			UNION ALL SELECT 31162387 --OP29T1		-- added by Viet @ 20180704, approved by Bill
			UNION ALL SELECT 31124790 --SU7ZZ		-- added by Viet @ 20180704, approved by Bill
		)
		INSERT INTO @restrictedtList (custid)
		SELECT mrecommend
		FROM _mag
	END
	
	RETURN
END
GO

