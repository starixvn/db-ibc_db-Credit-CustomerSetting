USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustSetting_03]    Script Date: 06/11/2015 01:53:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--STEP 1: DEPLOY THIS SP @ DBTRANS.CustDB -----
------------------------------------------------------
ALTER PROCEDURE [dbo].[Acc_CustSetting_03]
	@mrecommend INT		
	,@target VARCHAR(20)
AS
/*
Created: 
Task : Update member level when update l4
DB: DBCUST.custDB
Original: Acc_CustomerUpdSuper_MaxPositiontaking

Revisions:
   
     - 20150610@Daniel: 
		  + Improve medthod check table existing in subscribers	
		  + Separate custDB to new server DBCUST
						
Param's Explanation: 
*/
BEGIN	
	SET NOCOUNT ON
	
	IF (@target = 'REPLICATED' AND @@SERVERNAME = 'DBCUST') RETURN	-- run at all replicated servers
	IF (@target = 'DBTRANS' AND @@SERVERNAME <> 'DBCUST') RETURN -- run at dbcust only
	
     if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustSetting') = 1 
	   AND dbo.f_CheckRepTable('CustSetting3rd') = 1 
	   )
     RETURN
			
	UPDATE cs
	SET mpositiontaking = 0.2
		,apositiontaking = 0
		,mlivepositiontaking = CASE WHEN sporttype = 1 AND bettype IN (1,3,7,8) THEN 0.2 ELSE cs.mlivepositiontaking END
		,alivepositiontaking = 0
	FROM custSetting cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
	WHERE ci.mrecommend = @mrecommend
	AND NOT (cs.sporttype = 5 AND cs.bettype = 9999)


	UPDATE cs
	SET mpositiontaking = CASE WHEN bettype IN (81,83,86,88) THEN 0.2 ELSE mpositiontaking END
		,apositiontaking = 0
		,mlivepositiontaking = CASE WHEN bettype IN (85,86,87,89,90) THEN 0.2 ELSE cs.mlivepositiontaking END
		,alivepositiontaking = 0
	FROM custSetting3rd cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
	WHERE ci.mrecommend = @mrecommend
	AND cs.sporttype = 161
END
