
/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" viewers="vnteam" isFunction="0"></info>*/

--ALTER PROCEDURE [dbo].[Acc_CustVirtualMultiplier_Upd]
	--@CustID INT
	--, @SportType INT
	--, @VirtualMultiplier VARCHAR(MAX) = ''
	--, @UserID INT
	--, @IP VARCHAR(15) = ''
	--, @ErrCode TINYINT OUT
	--, @ErrMsg NVARCHAR(200) OUT
--AS
--/*    
--	Created: 20190626@Dominic    
--	Task :  Update VR setting of an account for a specific sport  [Redmind: #114830]
--	DB: DBCUST/CustDB    
--	Parameters:
--	Param's Explanation:  
--		• @VirtualMultiplier = '<Root>
--									<Row LevelID="1" ValueIDLive="1" ValueIDNonLive="2" />	
--								</Root>'		    
--	Revisions:    
--		- 20190626@Dominic : First commit
  
--*/ 
--BEGIN

DECLARE 	@CustID INT = 1176092
	, @SportType INT = 43
	, @VirtualMultiplier VARCHAR(MAX) = '<Root>
									<Row LevelID="1" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="2" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="3" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="4" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="5" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="6" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="7" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="8" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="9" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="10" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="11" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="12" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="13" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="14" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="15" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="16" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="17" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="18" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="19" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="20" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="21" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="22" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="23" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="24" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="25" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="26" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="27" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="28" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="29" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="30" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="31" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="32" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="33" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="34" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="35" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="36" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="37" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="38" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="39" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="40" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="41" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="42" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="43" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="44" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="45" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="46" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="47" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="48" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="49" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="50" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="51" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="52" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="53" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="54" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="55" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="56" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="57" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="58" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="59" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="60" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="61" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="62" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="63" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="64" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="65" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="66" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="67" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="68" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="69" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="70" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="71" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="72" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="73" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="74" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="75" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="76" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="77" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="78" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="79" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="80" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="81" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="82" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="83" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="84" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="85" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="86" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="87" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="88" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="89" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="90" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="91" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="92" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="93" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="94" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="95" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="96" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="97" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="98" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="99" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="100" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="101" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="102" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="103" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="104" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="105" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="106" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="107" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="108" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="109" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="110" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="111" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="112" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="113" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="114" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="115" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="116" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="117" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="118" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="119" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="120" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="121" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="122" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="123" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="124" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="125" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="126" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="127" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="128" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="129" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="130" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="131" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="132" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="133" ValueIDLive="16" ValueIDNonLive="2" />
<Row LevelID="134" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="135" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="136" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="137" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="138" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="139" ValueIDLive="15" ValueIDNonLive="2" />
<Row LevelID="140" ValueIDLive="10" ValueIDNonLive="2" />
<Row LevelID="141" ValueIDLive="10" ValueIDNonLive="2" />
								</Root>'
	, @UserID INT = 8
	, @IP VARCHAR(15) = ''
	, @ErrCode TINYINT 
	, @ErrMsg NVARCHAR(200) 

	SELECT @ErrCode = 0, @ErrMsg = ''
	DECLARE @StartRun DATETIME  
	DECLARE @EndRun DATETIME  
	DECLARE @Duration INT 
	DECLARE @ActionID INT = 1
	DECLARE @RoleID TINYINT
	DECLARE @TrackingValue1 varchar(MAX) = '', @TrackingValue2 varchar(MAX)= ''

	CREATE TABLE #New_VRCustSetting (CustID INT, LevelID INT, ValueIDLive TINYINT, ValueIDNonLive TINYINT)
	CREATE TABLE #Old_VRCustSetting (CustID INT, LevelID INT, ValueIDLive TINYINT, ValueIDNonLive TINYINT)
	CREATE TABLE #VRLineCustID (CustID INT, RoleID TINYINT)

	CREATE TABLE #Log (IsNew BIT, LevelID INT, ValueIDLive TINYINT, ValueIDNonLive TINYINT
						, FollowingCustID INT,FollowingValueIDLive TINYINT,FollowingValueIDNonLive TINYINT
					)
	
	SELECT @StartRun = GETUTCDATE()    

	DECLARE @DocHandler INT	

	IF @VirtualMultiplier <> ''
	BEGIN				
		EXEC sp_xml_preparedocument @DocHandler OUTPUT, @virtualmultiplier

		INSERT INTO #New_VRCustSetting(CustID, LevelID, ValueIDLive, ValueIDNonLive)
		SELECT @CustID,
			Data.LevelID,
			Data.ValueIDLive,
			Data.ValueIDNonLive
		FROM OPENXML (@DocHandler, '/Root/Row',1) 
		WITH (
			LevelID	INT,
			ValueIDLive TINYINT,
			ValueIDNonLive TINYINT	
		) AS Data

		EXEC sp_xml_removedocument @DocHandler
	END	

	CREATE UNIQUE CLUSTERED INDEX PK_LevelID ON #New_VRCustSetting(CustID, LevelID)
	CREATE UNIQUE CLUSTERED INDEX PK_LevelID ON #Old_VRCustSetting(CustID, LevelID)

	IF EXISTS (
					SELECT 1 
					FROM #New_VRCustSetting 
					WHERE ValueIDLive NOT IN (SELECT ValueID FROM VRValueMapping (NOLOCK))
				)  
		OR EXISTS (
					SELECT 1 
					FROM #New_VRCustSetting 
					WHERE ValueIDNonLive NOT IN (SELECT ValueID FROM VRValueMapping (NOLOCK))
				)
	BEGIN  
		SELECT @ErrMsg = N'Invalid virtual rate'
				, @ErrCode = 1  
		RETURN  
	END  

	--Get Upline's custid
	IF @CustID > 0
		INSERT INTO #VRLineCustID(CustID, RoleID)
		SELECT CustID,MAX(RoleID) RoleID
		FROM (
			SELECT upv.Val CustID, ROW_NUMBER() OVER (ORDER BY (SELECT 0)) RoleID
			FROM (
				SELECT custid,recommend,mrecommend,srecommend,0 [Global]
				FROM Customer (NOLOCK)
				WHERE CustID=@CustID
			) t
			UNPIVOT
			(
			  Val
			  FOR col IN (custid,recommend,mrecommend,srecommend,[Global])
			) upv
		) tmp
		GROUP BY CustID
	ELSE
		INSERT INTO #VRLineCustID(CustID, RoleID)
		SELECT 0, 5

	--Capture current VR setting
	INSERT INTO #Old_VRCustSetting(CustID, LevelID, ValueIDLive, ValueIDNonLive)
	SELECT vr.CustID, vr.LevelID, ValueIDLive, ValueIDNonLive
	FROM VRSetttingHierarchy h (NOLOCK)
	INNER JOIN VRCustSetting vr (NOLOCK)
		ON h.LevelID = vr.LevelID
	WHERE CustID IN (SELECT CustID FROM #VRLineCustID) 
		AND h.SportType = @SportType

	--Capture new VR setting
	INSERT INTO #New_VRCustSetting(CustID, LevelID, ValueIDLive, ValueIDNonLive)
	SELECT vr.CustID, vr.LevelID, ValueIDLive, ValueIDNonLive
	FROM #Old_VRCustSetting vr
	WHERE vr.CustID <> @CustID
	
	--Prepare data to write logs - Old data
	;WITH VR_Hierachy AS (
	   SELECT LevelID SrcLevelID, LevelID, ParentLevelID, 1 LayerNo
	   FROM VRSetttingHierarchy h
	   WHERE SportType = @SportType 
	   UNION ALL
	   SELECT p.SrcLevelID, c.LevelID, c.ParentLevelID, p.LayerNo + 1  LayerNo
	   FROM VRSetttingHierarchy c
		 INNER JOIN VR_Hierachy p on p.ParentLevelID = c.LevelID  -- this is the recursion
	)
	INSERT INTO #Log(IsNew, LevelID, ValueIDLive, ValueIDNonLive, FollowingCustID, FollowingValueIDLive, FollowingValueIDNonLive)
	SELECT 0 IsNew, LevelID,ValueIDLive,ValueIDNonLive,FollowingCustID,FollowingValueIDLive,FollowingValueIDNonLive
	FROM (
		SELECT h.SrcLevelID LevelID
			, ISNULL(vrc.ValueIDLive, 0) ValueIDLive, ISNULL(vrc.ValueIDNonLive,0) ValueIDNonLive
			, vr.CustID FollowingCustID
			, vr.ValueIDLive FollowingValueIDLive, vr.ValueIDNonLive FollowingValueIDNonLive
			, ROW_NUMBER() OVER(PARTITION BY h.SrcLevelID ORDER BY CASE WHEN ISNULL(vr.ValueIDLive, 0) = 0 THEN 2 ELSE 1 END, RoleID, LayerNo) RowNo_Live
			, ROW_NUMBER() OVER(PARTITION BY h.SrcLevelID ORDER BY CASE WHEN ISNULL(vr.ValueIDNonLive,0) = 0 THEN 2 ELSE 1 END, RoleID, LayerNo) RowNo_NonLive
		FROM VR_Hierachy h
		CROSS JOIN #VRLineCustID c
		LEFT JOIN #Old_VRCustSetting vrc (NOLOCK) 
			ON vrc.LevelID = h.LevelID
				AND vrc.CustID = @CustID
		LEFT JOIN #Old_VRCustSetting vr (NOLOCK) 
			ON vr.LevelID = h.LevelID
				AND vr.CustID = c.CustID
	) as tmp
	WHERE RowNo_Live=1 OR RowNo_NonLive=1

	--Prepare data to write logs - New data
	;WITH VR_Hierachy AS (
	   SELECT LevelID SrcLevelID, LevelID, ParentLevelID, 1 LayerNo
	   FROM VRSetttingHierarchy h
	   WHERE SportType = @SportType 
	   UNION ALL
	   SELECT p.SrcLevelID, c.LevelID, c.ParentLevelID, p.LayerNo + 1  LayerNo
	   FROM VRSetttingHierarchy c
		 INNER JOIN VR_Hierachy p on p.ParentLevelID = c.LevelID  -- this is the recursion
	)
	INSERT INTO #Log(IsNew, LevelID, ValueIDLive, ValueIDNonLive, FollowingCustID, FollowingValueIDLive, FollowingValueIDNonLive)
	SELECT 1 IsNew, LevelID,ValueIDLive,ValueIDNonLive,FollowingCustID,FollowingValueIDLive,FollowingValueIDNonLive
	FROM (
		SELECT h.SrcLevelID LevelID
			, ISNULL(vrc.ValueIDLive, 0) ValueIDLive, ISNULL(vrc.ValueIDNonLive,0) ValueIDNonLive
			, vr.CustID FollowingCustID
			, vr.ValueIDLive FollowingValueIDLive, vr.ValueIDNonLive FollowingValueIDNonLive
			, ROW_NUMBER() OVER(PARTITION BY h.SrcLevelID ORDER BY CASE WHEN ISNULL(vr.ValueIDLive, 0) = 0 THEN 2 ELSE 1 END, RoleID, LayerNo) RowNo_Live
			, ROW_NUMBER() OVER(PARTITION BY h.SrcLevelID ORDER BY CASE WHEN ISNULL(vr.ValueIDNonLive,0) = 0 THEN 2 ELSE 1 END, RoleID, LayerNo) RowNo_NonLive
		FROM VR_Hierachy h
		CROSS JOIN #VRLineCustID c
		LEFT JOIN #New_VRCustSetting vrc (NOLOCK) 
			ON vrc.LevelID = h.LevelID
				AND vrc.CustID = @CustID
		LEFT JOIN #New_VRCustSetting vr (NOLOCK) 
			ON vr.LevelID = h.LevelID
				AND vr.CustID = c.CustID
	) as tmp
	WHERE RowNo_Live=1 OR RowNo_NonLive=1


	SELECT @EndRun = GETUTCDATE()    
	SELECT @Duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

	SELECT @RoleID = roleid 
	FROM #VRLineCustID
	WHERE custid = @custid

	--EXECUTE	dbo.Acc_CustomerInfo_Execrep_04   
	--			@custid = @CustID
	--			, @roleid = @RoleID
	--			, @action = 'EsportVRUpd'
	--			, @virtualmultiplier = @virtualmultiplier

	SELECT @TrackingValue1 = (
		SELECT l.LevelID as l
			, CAST(CAST(ISNULL(vr1.Value,-1) AS FLOAT) AS VARCHAR(10)) a
			, CAST(CAST(ISNULL(vr2.Value,-1) AS FLOAT) AS VARCHAR(10)) b
			, l.FollowingCustID c
			, CAST(CAST(ISNULL(vr3.Value,-1) AS FLOAT) AS VARCHAR(10)) d
			, CAST(CAST(ISNULL(vr4.Value,-1) AS FLOAT) AS VARCHAR(10)) e
		FROM #Log  l
			INNER JOIN VRValueMapping  vr1 ON vr1.ValueID = l.ValueIDLive
			INNER JOIN VRValueMapping  vr2 ON vr2.ValueID = l.ValueIDNonLive
			INNER JOIN VRValueMapping  vr3 ON vr3.ValueID = l.FollowingValueIDLive
			INNER JOIN VRValueMapping  vr4 ON vr4.ValueID = l.FollowingValueIDNonLive
		WHERE l.IsNew = 0
		ORDER BY l.LevelID
		FOR XML  RAW('r')  
	)

	SELECT @TrackingValue1 = REPLACE(@TrackingValue1,'<r l="','<') 
	SELECT @TrackingValue1 = REPLACE(@TrackingValue1,'"/>','>')
	SELECT @TrackingValue1 = REPLACE(@TrackingValue1,'" a="','a')
	SELECT @TrackingValue1 = REPLACE(@TrackingValue1,'" b="','b')
	SELECT @TrackingValue1 = REPLACE(@TrackingValue1,'" c="','c')
	SELECT @TrackingValue1 = REPLACE(@TrackingValue1,'" d="','d')
	SELECT @TrackingValue1 = REPLACE(@TrackingValue1,'" e="','e')


	SELECT @TrackingValue2 = (
		SELECT l.LevelID as l
			, CAST(CAST(ISNULL(vr1.Value,-1) AS FLOAT) AS VARCHAR(10)) a
			, CAST(CAST(ISNULL(vr2.Value,-1) AS FLOAT) AS VARCHAR(10)) b
			, l.FollowingCustID c
			, CAST(CAST(ISNULL(vr3.Value,-1) AS FLOAT) AS VARCHAR(10)) d
			, CAST(CAST(ISNULL(vr4.Value,-1) AS FLOAT) AS VARCHAR(10)) e
		FROM #Log  l
			INNER JOIN VRValueMapping  vr1 ON vr1.ValueID = l.ValueIDLive
			INNER JOIN VRValueMapping  vr2 ON vr2.ValueID = l.ValueIDNonLive
			INNER JOIN VRValueMapping  vr3 ON vr3.ValueID = l.FollowingValueIDLive
			INNER JOIN VRValueMapping  vr4 ON vr4.ValueID = l.FollowingValueIDNonLive
		WHERE l.IsNew = 1
		ORDER BY l.LevelID
		FOR XML  RAW('r')  
	)

	SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'<r l="','<') 
	SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'"/>','>')
	SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'" a="','a')
	SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'" b="','b')
	SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'" c="','c')
	SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'" d="','d')
	SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'" e="','e')


	/*
		--Decompress
		SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'e','" e="')
		SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'d','" d="')
		SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'c','" c="')
		SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'b','" b="')
		SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'a','" a="')
		SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'>','"/>')
		SELECT @TrackingValue2 = REPLACE(@TrackingValue2,'<','<r l="') 

	*/



	SELECT ValueIDLive,ValueIDNonLive,FollowingCustID,FollowingValueIDLive,FollowingValueIDNonLive, LevelIDLst = 
    STUFF((SELECT ',' + CAST(LevelID AS VARCHAR(15))
           FROM #Log b 
           WHERE b.IsNew=1
				AND b.ValueIDLive = a.ValueIDLive 
				AND b.ValueIDNonLive = a.ValueIDNonLive 
				AND b.FollowingCustID = a.FollowingCustID 
				AND b.FollowingValueIDLive = a.FollowingValueIDLive 
				AND b.FollowingValueIDNonLive = a.FollowingValueIDNonLive 
          FOR XML PATH('')), 1, 1, '')
	FROM #Log a
	WHERE a.IsNew = 1
	GROUP BY ValueIDLive,ValueIDNonLive,FollowingCustID,FollowingValueIDLive,FollowingValueIDNonLive




	--EXEC DBLOG.bodb_CustomerLog.dbo.[Writelog_VirtualRate_UpdateSetting] @CustID=@CustID
	--				,@SportType=@SportType
	--				,@ActionID=@ActionID
	--				,@TrackingValue1=@TrackingValue1
	--				,@TrackingValue2=@TrackingValue2
	--				,@UserID=@UserID
	--				,@LogTime=@StartRun
	--				,@Duration=@Duration
	--				,@IP=@IP

	DROP TABLE #New_VRCustSetting
	DROP TABLE #Old_VRCustSetting
	DROP TABLE #VRLineCustID
	DROP TABLE #Log
--END