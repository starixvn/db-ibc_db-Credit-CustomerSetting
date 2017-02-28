USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustSetting3rd_19]    Script Date: 06/11/2015 06:28:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_19]
	@srecommend INT	
	,@maxcustid INT
	,@target VARCHAR(20)
AS
/*  

Created:   
Date: 
Task: 
DB: DBCUST/CustDB  

Revisions:  
	- 20150610@Daniel: 
	    + Improve medthod check table existing in subscribers	
	    + Separate custDB to new server DBCUST   
	
Parameter's Explanation:  

*/

BEGIN
	SET NOCOUNT ON 	
	
	IF (@target = 'REPLICATED' AND @@SERVERNAME = 'DBTRANS') RETURN	-- run at all replicated servers
	IF (@target = 'DBTRANS' AND @@SERVERNAME <> 'DBTRANS') RETURN -- run at dbtrans only
	
	if NOT(dbo.f_CheckRepTable('CustGameType') = 1 
	     AND dbo.f_CheckRepTable('CustSettingGame') = 1 
	     AND dbo.f_CheckRepTable('LCS_CustGameType') = 1 
	     AND dbo.f_CheckRepTable('LCS_StakeLevel') = 1 
     )
	   	RETURN  	
		
	DECLARE @StakeLevelList_1701 VARCHAR(50)= ''
			,@StakeLevelList_1702 VARCHAR(50)= ''
			,@StakeLevelList_1701_new VARCHAR(50)= ''
			,@StakeLevelList_1702_new VARCHAR(50)= ''
			,@currency INT
			,@custid INT
			,@uplineID INT
			,@roleid INT
			,@syncLiveCasino BIT
	
	CREATE TABLE #tmpCust (custid INT, syncLiveCasino BIT, roleid INT, UplineID INT)
	
	SELECT @currency = currency 
	FROM custinfo WITH(NOLOCK) 
	WHERE custid = @srecommend 
	
	INSERT INTO #tmpCust(custid,syncLiveCasino,roleid,UplineID)
	SELECT custid, syncLiveCasino, roleid, 
		CASE WHEN roleid = 3 THEN srecommend
			WHEN roleid = 2 THEN mrecommend
			WHEN roleid = 1 THEN recommend  ELSE 0 END
	FROM custinfo ci WITH(NOLOCK) 
	WHERE ci.srecommend = @srecommend
		AND ci.custid <= @maxcustid
	
	WHILE (1=1)
	BEGIN
		SELECT TOP (1) @custid = custid
			,@roleid = roleid
			,@syncLiveCasino = syncLiveCasino
			,@UplineID = uplineID
		FROM #tmpCust		
		ORDER BY roleid DESC
		
		IF @@ROWCOUNT = 0
			BREAK;
		
		SELECT @StakeLevelList_1701_new = ''
			,@StakeLevelList_1702_new = ''
			,@StakeLevelList_1701 = ''
			,@StakeLevelList_1702 = ''
			
		IF @syncLiveCasino = 1
		BEGIN
			--get stakelevel from LiveCasino
			SELECT @StakeLevelList_1701 = StakeLevelList
			FROM LCS_CustGameType s with(Nolock) 
			WHERE custid = @custid
				AND GameTypeID = 108
				
			SELECT @StakeLevelList_1702 = StakeLevelList
			FROM LCS_CustGameType s with(Nolock) 
			WHERE custid = @custid
				AND GameTypeID = 109	
			
			SELECT @StakeLevelList_1701_new = @StakeLevelList_1701_new + CONVERT(VARCHAR(10),StakeLevelID) + ','
			FROM (
			SELECT MinStake, MaxStake
			FROM LCS_StakeLevel WITH(NOLOCK) 
			WHERE stakeLevelID IN (SELECT val FROM strSplit(@StakeLevelList_1701,','))
			)t 
			INNER JOIN bodb02.dbo.StakeLevel s WITH(NOLOCK) ON t.MinStake = s.MinStake AND t.MaxStake = s.MaxStake
			WHERE s.ExchangeID = @currency 
				AND GameTypeID = 1701
			ORDER BY s.MinStake, s.MaxStake
			
			IF @StakeLevelList_1701_new <> ''
				SELECT @StakeLevelList_1701_new = left(@StakeLevelList_1701_new,len(@StakeLevelList_1701_new) - 1)
			
			SELECT @StakeLevelList_1702_new = @StakeLevelList_1702_new + CONVERT(VARCHAR(10),StakeLevelID) + ','
			FROM (
			SELECT MinStake, MaxStake
			FROM LCS_StakeLevel WITH(NOLOCK) 
			WHERE stakeLevelID IN (SELECT val FROM strSplit(@StakeLevelList_1701,','))
			)t 
			INNER JOIN bodb02.dbo.StakeLevel s WITH(NOLOCK) ON t.MinStake = s.MinStake AND t.MaxStake = s.MaxStake
			WHERE s.ExchangeID = @currency 
				AND GameTypeID = 1702
			ORDER BY s.MinStake, s.MaxStake
			
			IF @StakeLevelList_1702_new <> ''
				SELECT @StakeLevelList_1702_new = left(@StakeLevelList_1702_new,len(@StakeLevelList_1702_new) - 1)
			
			INSERT INTO CustGameType(custid,GameTypeID,StakeLevelList)
			SELECT @custid, 1701,@StakeLevelList_1701_new
			UNION 
			SELECT @custid, 1702,@StakeLevelList_1702_new
		END
		ELSE
		BEGIN
			IF @roleid = 4
			BEGIN
				--get stake from Global settings
				SELECT @StakeLevelList_1701_new = @StakeLevelList_1701_new + CONVERT(VARCHAR(10),StakeLevelID) + ','
				FROM bodb02.dbo.StakeLevel s WITH(NOLOCK) 
				WHERE s.ExchangeID = @currency 
					AND GameTypeID = 1701
				ORDER BY s.MinStake, s.MaxStake
				
				SELECT @StakeLevelList_1702_new = @StakeLevelList_1702_new + CONVERT(VARCHAR(10),StakeLevelID) + ','
				FROM bodb02.dbo.StakeLevel s WITH(NOLOCK) 
				WHERE s.ExchangeID = @currency 
					AND GameTypeID = 1702
				ORDER BY s.MinStake, s.MaxStake
				
				IF @StakeLevelList_1701_new <> ''
					SELECT @StakeLevelList_1701_new = left(@StakeLevelList_1701_new,len(@StakeLevelList_1701_new) - 1)
			
				IF @StakeLevelList_1702_new <> ''
					SELECT @StakeLevelList_1702_new = left(@StakeLevelList_1702_new,len(@StakeLevelList_1702_new) - 1)
				
				INSERT INTO CustGameType(custid,GameTypeID,StakeLevelList)
				SELECT @custid, 1701,@StakeLevelList_1701_new
				UNION 
				SELECT @custid, 1702,@StakeLevelList_1702_new
			END
			ELSE IF @roleid IN (2,3)
			BEGIN
				INSERT INTO CustGameType(custid,GameTypeID,StakeLevelList)
				SELECT @custid, GameTypeID,	StakeLevelList
				FROM CustGameType WITH(NOLOCK)
				WHERE custID = @uplineID
					AND GameTypeID IN (1701,1702)
			END
			ELSE IF @roleid = 1
			BEGIN
				SELECT @StakeLevelList_1701 = StakeLevelList
				FROM CustGameType WITH(NOLOCK) 
				WHERE custid = @uplineID
					AND GameTypeID = 1701
				
				SELECT @StakeLevelList_1702 = StakeLevelList
				FROM CustGameType WITH(NOLOCK) 
				WHERE custid = @uplineID
					AND GameTypeID = 1702
				
				--get lowest stake level from upline to apply for member
				SELECT TOP (1) @StakeLevelList_1701_new = CONVERT(varchar(10),StakeLevelID)
				FROM bodb02.dbo.StakeLevel WITH(NOLOCK) 		
				WHERE StakeLevelID IN (SELECT val FROM strSplit(@StakeLevelList_1701,','))
				ORDER BY MinStake, MaxStake ASC
				
				SELECT TOP (1) @StakeLevelList_1702_new = CONVERT(varchar(10),StakeLevelID)
				FROM bodb02.dbo.StakeLevel WITH(NOLOCK) 		
				WHERE StakeLevelID IN (SELECT val FROM strSplit(@StakeLevelList_1702,','))
				ORDER BY MinStake, MaxStake ASC
				
				INSERT INTO CustGameType(custid,GameTypeID,StakeLevelList)
				SELECT @custid, 1701,@StakeLevelList_1701_new
				UNION 
				SELECT @custid, 1702,@StakeLevelList_1702_new
			END
		END
		
		DELETE #tmpCust WHERE custid = @custid
	END
	
	
	INSERT INTO [dbo].[CustSettingGame]
           ([CustID]
           ,[Bettype]
           ,[Sporttype]
           ,[apositiontaking]
           ,[mpositiontaking]
           ,[spositiontaking]
           ,[playerdiscount]
           ,[discount]
           ,[adiscount]
           ,[sdiscount]
           ,[autopositiontaking]
           ,[isautopositiontaking]
           ,[autompositiontaking]
           ,[isautompositiontaking])
	SELECT cs.[CustID]
           ,1701 as [Bettype]
           ,255 as [Sporttype]
           ,[apositiontaking]
           ,[mpositiontaking]
           ,[spositiontaking]
           ,[playerdiscount]
           ,[discount]
           ,[adiscount]
           ,[sdiscount]
           ,[autopositiontaking]
           ,[isautopositiontaking]
           ,[autompositiontaking]
           ,[isautompositiontaking]
	FROM  CustSettingGame cs WITH(NOLOCK) 
		INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid
	WHERE ci.srecommend = @srecommend
		AND ci.custid <= @maxcustid
		AND cs.sporttype = 162
		AND cs.bettype = 1101  
	       
	
	INSERT INTO [dbo].[CustOverrideGame]
           ([CustID]
           ,[Bettype]
           ,[Sporttype]
           ,[minpositiontaking])
	SELECT cs.[CustID]
           ,1701 as [Bettype]
           ,255 as [Sporttype]
           ,[minpositiontaking]           
    FROM  CustOverrideGame cs WITH(NOLOCK) 
		INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid
	WHERE ci.srecommend = @srecommend
		AND ci.custid <= @maxcustid
		AND cs.sporttype = 162
		AND cs.bettype = 1101  
	
	DECLARE @apos SMALLMONEY,
			@mpos SMALLMONEY
	
	UPDATE cs
	SET @apos = CASE WHEN apositiontaking > 0.93 THEN 0.93 ELSE apositiontaking END,
		apositiontaking = @apos,
		@mpos = CASE WHEN @apos + mpositiontaking > 0.93 THEN 0.93- @apos ELSE mpositiontaking END,
		mpositiontaking = @mpos,
		spositiontaking = CASE WHEN @apos + @mpos + spositiontaking > 0.93 THEN 0.93 - @mpos -@apos ELSE spositiontaking END
	FROM  CustSettingGame cs WITH(UPDLOCK,ROWLOCK) 
		INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid
	WHERE ci.srecommend = @srecommend
		AND ci.custid <= @maxcustid
		AND ci.roleid = 1
		AND cs.sporttype = 255
		AND cs.bettype = 1701 
		AND spositiontaking + mpositiontaking + apositiontaking > 0.93
		
	UPDATE cs
	SET @apos = CASE WHEN apositiontaking > 0.93 THEN 0.93 ELSE apositiontaking END,
		apositiontaking = @apos,
		mpositiontaking = CASE WHEN @apos + mpositiontaking > 0.93 THEN 0.93- @apos ELSE mpositiontaking END		
	FROM  CustSettingGame cs WITH(UPDLOCK,ROWLOCK) 
		INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid
	WHERE ci.srecommend = @srecommend
		AND ci.custid <= @maxcustid
		AND ci.roleid = 2
		AND cs.sporttype = 255
		AND cs.bettype = 1701 
		AND mpositiontaking + apositiontaking > 0.93	
	
	UPDATE cs
	SET @mpos = CASE WHEN mpositiontaking > 0.93 THEN 0.93 ELSE mpositiontaking END,
		mpositiontaking = @mpos,
		spositiontaking = CASE WHEN spositiontaking + @mpos > 0.93 THEN 0.93 - @mpos ELSE spositiontaking END 		
	FROM  CustSettingGame cs WITH(UPDLOCK,ROWLOCK) 
		INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid
	WHERE ci.srecommend = @srecommend
		AND ci.custid <= @maxcustid
		AND ci.roleid = 3
		AND cs.sporttype = 255
		AND cs.bettype = 1701 
		AND mpositiontaking + spositiontaking > 0.93	
		
	UPDATE cs
	SET spositiontaking = CASE WHEN spositiontaking > 0.93 THEN 0.93 ELSE spositiontaking END 		
	FROM  CustSettingGame cs WITH(UPDLOCK,ROWLOCK) 
		INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid
	WHERE ci.custid = @srecommend		
		AND cs.sporttype = 255
		AND cs.bettype = 1701 
		AND mpositiontaking + spositiontaking > 0.93		
			      	
	DROP TABLE #tmpCust	
END	
