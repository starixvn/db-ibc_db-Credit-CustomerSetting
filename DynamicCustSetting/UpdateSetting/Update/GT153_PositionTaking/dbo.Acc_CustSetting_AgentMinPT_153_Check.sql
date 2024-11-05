/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE dbo.Acc_CustSetting_AgentMinPT_153_Check
	@custid			INT,
	@srecommend		INT,
	@mrecommend		INT,
	@PT				VARCHAR(MAX)='',
	@ErrCode		INT = 0 OUTPUT,
	@MsgType		INT = 0 OUTPUT,
	@ErrMsg			VARCHAR(4000)='' OUTPUT,
	@GroupID TINYINT = 1,
	@GroupType SMALLINT = 153,
	@SettingStatus TINYINT = 0
AS
/*
	Created: 20231101@Eden
	Task : check input parameters for updating min pt on Agent
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20231101@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20241030@Elodie: Check Agent Min PT > 0 [Redmine: #212710]
	Parameter's Explanations:
		
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @SuperID INT, @MasterID INT, @AgentID INT 
	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				AgentPT			SMALLMONEY,	
				AgentMinPT		SMALLMONEY,
				[ProductID] [tinyint],
				[SettingLevel] [tinyint]
				)	
	
	DECLARE @ErrType XML
	
	SELECT @SuperID = @srecommend, @MasterID = @mrecommend, @AgentID = @custid
						
	-- For read xml	
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,	
				AgentPT,							
				AgentMinPT
			)
	SELECT
		b.SportType,
		b.BetType,
		b.IsLive,
		acs.AgentPT, 
		b.MinPT
	FROM dbo.f_DCS_PT_XMLParse(@PT) b
		INNER JOIN CustPTSetting3rd_Agent AS acs WITH (NOLOCK) ON acs.sporttype = b.sporttype AND acs.bettype = b.bettype AND acs.IsLive = b.IsLive					
	WHERE acs.custid = @AgentID
	-- end read xml	

	DECLARE  @SiteID SMALLINT,
		@Currency SMALLINT	
	
	SELECT  @siteID = s.siteID,
			@Currency = c.currency
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid

	CREATE TABLE #ProductSettingDetail_MinACheck(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_MinACheck(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @tblPT t
		INNER JOIN #ProductSettingDetail_MinACheck ps
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
		INNER JOIN #ProductSettingDetail_MinACheck ps 
			ON ps.BetType = t.BetType 
			AND ps.SportType = t.SportType
			AND ps.IsLive = t.IsLive

	select @ErrType = '' 	
    
	SELECT @ErrCode = MAX (CASE	WHEN m.MaxPT < a.AgentMinPT THEN 199 --check l3 >= n2 
								WHEN a.AgentPT < a.AgentMinPT OR a.AgentMinPT < 0 THEN 198 --check a2 >= n2     
								ELSE 0 END)
	FROM dbo.CustPTSetting3rd_Agent m WITH(NOLOCK) 
		INNER JOIN @tblPT a ON m.sporttype = a.sporttype AND m.bettype = a.bettype AND m.IsLive = a.IsLive
	WHERE m.custid = @MasterID
	  
	SELECT @ErrCode = ISNULL(@ErrCode,0)
	  	    
  
	IF @ErrCode = 199
	BEGIN
		--check l3 >= n2    
		SELECT @ErrType = ''  	
				
		SELECT @ErrType = 
		(
			SELECT b.SportType, b.BetType,b.IsLive ,b.ProductID,b.SettingLevel
			FROM CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) 
				INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
										AND mcs.bettype = b.bettype        
										AND mcs.IsLive = b.IsLive			  
			WHERE mcs.custid = @MasterID
				AND mcs.MaxPT < b.AgentMinPT
			FOR XML RAW('Row'), TYPE
		)    		
		
		IF @ErrType IS NOT NULL
		BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20030" Msg="The Agent Min PT violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @MsgType = 5                                    
			RETURN
		END   
	END
	ELSE IF @ErrCode = 198
	BEGIN
		--check a2 >= n2       
		SELECT @ErrType = ''  	
				
		SELECT @ErrType = 
		(
			SELECT b.SportType, b.BetType,b.IsLive ,b.ProductID,b.SettingLevel
			FROM @tblPT b				
			WHERE b.AgentPT < b.AgentMinPT OR b.AgentMinPT < 0
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
	
	DROP TABLE #ProductSettingDetail_MinACheck
END