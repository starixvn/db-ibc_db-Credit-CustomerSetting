/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE Acc_CustSetting_SuperMinPT_153_Check
	@custid		INT,
	@PT			VARCHAR(MAX),	
	@ErrCode	INT = 0 OUTPUT,
	@MsgType	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(4000)='' OUTPUT,
	@GroupID TINYINT = 1,
	@GroupType SMALLINT = 153,
	@SettingStatus TINYINT = 0
AS
/*
	Created: 20231101@Eden
	Task : Check PT when update MinPT on super
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20231101@Eden: DCS Sportsbook Credit[redmine: #193083]

	Parameter's Explanation:
		@PT = <ROOT>
					<PT SportType="1" BetType="1" IsLive="0" MinPT="0"/>
					<PT SportType="1" BetType="1" IsLive="1" MinPT="0"/>
				</ROOT>
				
*/
BEGIN
	SET NOCOUNT ON
	
	 --Check Param
    DECLARE @ErrType XML, @ErrCodeGroup INT
	CREATE TABLE #MasterTbl (CustID INT, UserName NVARCHAR(50))
	CREATE TABLE #AgentTbl 	(CustID INT, UserName NVARCHAR(50))
	DECLARE @SuperID INT
						
	DECLARE @tblPT TABLE (
				SportType	SMALLINT,
				BetType		SMALLINT,
				IsLive		BIT,			
				SuperMinPT	SMALLMONEY,
				[ProductID] [tinyint],
				[SettingLevel] [tinyint]
				)
	DECLARE @tmpPTGroup TABLE(custid INT
							,sporttype INT
							,bettype INT
							,IsLive BIT
							)
				
	-- For read xml
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,				
				SuperMinPT
			)
	SELECT
		SportType,
		BetType,
		IsLive,		
		MinPT
	FROM dbo.f_DCS_PT_XMLParse(@PT)	
	-- end read xml		
	
	DECLARE  @SiteID SMALLINT,
		@Currency SMALLINT	
	
	SELECT  @siteID = s.siteID,
			@Currency = c.currency
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid
	
	CREATE TABLE #ProductSettingDetail_MinsCheck(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_MinsCheck(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @tblPT t
		INNER JOIN #ProductSettingDetail_MinsCheck ps
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer
	
	UPDATE t
	SET t.SettingLevel = ps.SettingLevel,
		t.ProductID = ps.ProductID
	FROM @tblPT t
		INNER JOIN #ProductSettingDetail_MinsCheck ps 
			ON ps.BetType = t.BetType 
			AND ps.SportType = t.SportType
			AND ps.IsLive = t.IsLive

	SELECT @SuperID = @custid

	INSERT INTO #MasterTbl(CustID, UserName)
	SELECT CustID, username FROM CustInfo WITH (NOLOCK) WHERE srecommend = @SuperID AND roleid = 3	

	INSERT INTO #AgentTbl(CustID, UserName)
	SELECT CustID, username FROM CustInfo WITH (NOLOCK) WHERE srecommend = @SuperID AND roleid = 2 AND Enabled = 1

	SELECT @ErrCode = MAX (CASE	WHEN s.SuperMinPT < 0 THEN 200 
								WHEN cs.SuperPT < s.SuperMinPT THEN 199 --check n4<=s4								
								ELSE 0 END)
	FROM @tblPT s
		INNER JOIN CustPTSetting3rd_Agent cs WITH (NOLOCK) ON cs.SportType = s.Sporttype AND cs.BetType = s.bettype AND cs.IsLive = s.IsLive
	WHERE cs.custid = @SuperID

	SELECT @ErrCode = ISNULL(@ErrCode,0)

	IF @ErrCode = 200
	BEGIN
		SET @ErrType =
			(
				SELECT t.SportType, t.BetType, t.IsLive,t.ProductID,t.SettingLevel
					FROM @tblPT t
				WHERE t.SuperMinPT < 0
				FOR XML RAW('Row'), TYPE
			)
	
		IF @ErrType IS NOT NULL
		BEGIN        
			SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 5
			RETURN
		END		
	END

	-- check super level		
	IF @ErrCode = 199
	BEGIN
		--check n4<=s4
			SELECT @ErrType = ''
	     
			SELECT @ErrType = 
			(
				SELECT s.SportType, s.BetType, s.IsLive,s.ProductID,s.SettingLevel
				FROM @tblPT s
					INNER JOIN CustPTSetting3rd_Agent cs WITH (NOLOCK) ON cs.SportType = s.Sporttype AND cs.BetType = s.bettype AND cs.IsLive = s.IsLive	
				WHERE cs.custid = @SuperID
				ORDER BY s.SportType, s.BetType, s.IsLive
				FOR XML RAW('Row'), TYPE
			)	
		
		IF @ErrType IS NOT NULL
		BEGIN
			SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">' 
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 5
			RETURN
		END
	END

	SELECT @ErrCode = 0

	DROP TABLE #ProductSettingDetail_MinsCheck
	DROP TABLE #AgentTbl
	DROP TABLE #MasterTbl
END	 