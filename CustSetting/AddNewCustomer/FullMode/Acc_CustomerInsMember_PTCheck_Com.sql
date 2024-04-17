/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_PTCheck_Com]
	@siteid SMALLINT = 0,
	@currency SMALLINT = 0,
	@SettingType28 VARCHAR(MAX)= '' OUTPUT,
	@SettingStatus TINYINT = 0,
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT	
AS
/*
	Created: 20231010@Eden 
	Task : check PT for Super 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20231010@Eden: DCS Sportsbook Credit[redmine: #193083]

	Param's Explanation: 
		- @SettingType28 = '<Root>
						<R SportType="1" BetType="1" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						<R SportType="1" BetType="1" IsLive="1" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						....
						<R SportType="99" BetType="9" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
					</Root>'							
*/	
BEGIN
	SET NOCOUNT ON 
				
	DECLARE @tblPT TABLE (
				SettingType		SMALLINT,
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				SuperPT			SMALLMONEY,
				MasterPT		SMALLMONEY,		
				AgentPT			SMALLMONEY,	
				MinPT			SMALLMONEY,	
				Child_DisplayOrder	INT
				)
	CREATE TABLE #ProductSettingDetail_PTCheck(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		[MaxPT]	[smallmoney],
		Child_DisplayOrder	INT
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)
	
	DECLARE @xml XML,
			@ErrType XML
	
	IF ISNULL(@SettingType28,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML, @SettingType28)

		INSERT INTO @tblPT(SettingType,
			SportType, 
			BetType, 
			IsLive,
			SuperPT,
			MasterPT,
			AgentPT,
			MinPT
			)
		SELECT 28 as SettingType,
			T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
			T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
			T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT,
			T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS MinPT
		FROM  @xml.nodes('/Root/R') T(c)		
	END	
	
	INSERT INTO #ProductSettingDetail_PTCheck(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT,Child_DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,RealProductID,SettingLevel,MaxPT,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)
	WHERE SettingType IN (28)
	
	--check 0 <= AgentPT <= Master PT <= SuperPT <= MaxPT, MinPT <= SuperPT
	;WITH T AS (
		SELECT t.SportType, t.BetType, t.IsLive, ps.SettingLevel,ps.ProductID
		FROM @tblPT t
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		WHERE (t.SuperPT < 0 OR t.MasterPT < 0 OR t.AgentPT < 0 OR t.MinPT < 0
				OR t.SuperPT > ps.MaxPT OR t.MasterPT > t.SuperPT OR t.AgentPT > t.MasterPT
				OR t.MinPT > t.SuperPT
			)
	)
	SELECT @ErrType =
	(
		SELECT * 
		FROM T
		FOR XML RAW('Row'), TYPE
	)
	
	IF @ErrType IS NOT NULL
	BEGIN        
		 SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @MsgType = 61
					, @ErrCode = 601
		RETURN
	END	

	UPDATE t
	SET t.Child_DisplayOrder = d.Child_DisplayOrder
	FROM @tblPT t
		INNER JOIN #ProductSettingDetail_PTCheck d 
			ON t.SportType = d.SportType
			AND t.BetType = d.BetType
			AND t.IsLive = d.IsLive
		
	SELECT @SettingType28 = (
	SELECT SportType '@SportType', 
		BetType '@BetType', 
		IsLive '@IsLive',
		SuperPT '@SuperPT',
		MasterPT '@MasterPT',	
		AgentPT '@AgentPT',	
		MinPT '@MinPT'
	FROM @tblPT
	WHERE SettingType = 28
	ORDER BY Child_DisplayOrder,SportType,BetType
	FOR XML PATH ('R'), ROOT('Root')
	)	
	
	DROP TABLE #ProductSettingDetail_PTCheck
END		