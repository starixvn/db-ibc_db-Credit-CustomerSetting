/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_MasterMinPT_153_Check]
	@custid		INT,	
	@srecommend INT,
	@PT			VARCHAR(MAX),
	@ErrCode	INT = 0 OUTPUT,
	@MsgType	INT = 0 OUTPUT,
	@ErrMsg		VARCHAR(4000)='' OUTPUT, 
	@GroupID TINYINT = 1,
	@GroupType SMALLINT = 153,
	@SettingStatus TINYINT = 0
AS
/*
	Created: 20231101@Eden
	Task : check input parameters for updating Min pt on Master
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20231101@Eden: DCS Sportsbook Credit[redmine: #193083]

	Parameter's Explanations:
		@PT = <ROOT>
				<PT SportType="1" BetType="1" IsLive="0" MinPT="0"/>
				<PT SportType="1" BetType="1" IsLive="1" MinPT="0"/>
			</ROOT>
				
*/
BEGIN
	SET NOCOUNT ON
	SELECT @ErrCode = 0, @ErrMsg = '', @MsgType = 0
	DECLARE @SuperID INT, @MasterID INT
	CREATE TABLE #AgentTbl 	(CustID INT, UserName NVARCHAR(50))
	DECLARE @tmpPTGroup TABLE(sporttype INT
							,bettype INT
							,IsLive BIT
							,custid INT)

	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				MasterPT		SMALLMONEY,	
				MasterMinPT		SMALLMONEY,
				[ProductID] [tinyint],
				[SettingLevel] [tinyint]
				)
	
	SELECT @SuperID = @srecommend, @MasterID = @custid
	-- For read xml
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				MasterPT,
				MasterMinPT
			)
	SELECT
		b.SportType,
		b.BetType,
		b.IsLive,
		mcs.MasterPT,
		b.MinPT
	FROM dbo.f_DCS_PT_XMLParse(@PT) b	
		INNER JOIN CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) ON mcs.sporttype = b.sporttype AND mcs.bettype = b.bettype AND mcs.IsLive = b.IsLive					
	WHERE mcs.custid = @MasterID 	
	-- end read xml	

	DECLARE  @SiteID SMALLINT,
		@Currency SMALLINT	
	
	SELECT  @siteID = s.siteID,
			@Currency = c.currency
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid

	CREATE TABLE #ProductSettingDetail_MMinCheck(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		[MaxPT]	[smallmoney],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_MMinCheck(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @tblPT t
		INNER JOIN #ProductSettingDetail_MMinCheck ps
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
		INNER JOIN #ProductSettingDetail_MMinCheck ps 
			ON ps.BetType = t.BetType 
			AND ps.SportType = t.SportType
			AND ps.IsLive = t.IsLive
	
	INSERT INTO #AgentTbl(CustID, UserName)
	SELECT CustID, username FROM CustInfo WITH (NOLOCK) WHERE mrecommend = @MasterID AND roleid = 2 AND Enabled = 1

	--Check Param
    DECLARE @ErrType XML, @ErrCodeGroup INT
	
	--check master level
	SELECT @ErrCode = MAX (CASE	WHEN m.MasterMinPT < 0 THEN 200
								WHEN m.MasterPT < m.MasterMinPT OR s.MasterPT < m.MasterMinPT THEN 199 --check min(m3,m4)>=n3, n3<=m3<=l3
								ELSE 0 END)
	FROM dbo.CustPTSetting3rd_Agent s WITH (NOLOCK) 
		INNER JOIN @tblPT m ON s.sporttype = m.sporttype AND s.bettype = m.bettype AND s.IsLive = m.IsLive
		INNER JOIN #ProductSettingDetail_MMinCheck ps WITH(NOLOCK) ON m.SportType = ps.Sporttype AND m.BetType = ps.bettype AND m.IsLive = ps.IsLive
	WHERE s.custid = @SuperID
	
	SELECT @ErrCode = ISNULL(@ErrCode,0)
				
	IF 	@ErrCode = 200
	BEGIN
		SET @ErrType =
			(
				SELECT t.SportType, t.BetType, t.IsLive,t.ProductID,t.SettingLevel
				FROM @tblPT t
					INNER JOIN #ProductSettingDetail_MMinCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype AND t.BetType = ps.bettype AND t.IsLive = ps.IsLive
				WHERE t.MasterMinPT < 0										
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

    IF @ErrCode = 199
    BEGIN
        --check min(m3,m4)>=n3, n3<=m3<=l3
        SELECT @ErrType = ''
	     
	     SELECT @ErrType = (     			
				SELECT b.SportType, b.BetType, b.IsLive,b.ProductID,b.SettingLevel
				FROM 
					CustPTSetting3rd_Agent AS scs WITH (NOLOCK) 
					INNER JOIN @tblPT AS b ON scs.sporttype=b.sporttype 
												AND scs.bettype = b.bettype
												AND scs.IsLive = b.IsLive
				WHERE scs.custid = @SuperID 
					AND (b.MasterPT < b.MasterMinPT OR scs.MasterPT < b.MasterMinPT)			
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

	DROP TABLE #ProductSettingDetail_MMinCheck
END 