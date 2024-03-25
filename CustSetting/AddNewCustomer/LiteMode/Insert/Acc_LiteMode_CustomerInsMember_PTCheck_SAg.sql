/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_PTCheck_SAg]
	@srecommend INT,	
	@siteid SMALLINT = 0,
	@currency SMALLINT = 0,
	
	@SettingType28 VARCHAR(MAX)= '' OUTPUT,-- SB
	@SettingType1 VARCHAR(MAX)= ''  OUTPUT,-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot)
	@SettingType18 VARCHAR(MAX)= '' OUTPUT,-- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
	@SettingStatus TINYINT = 0,

	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT	
AS
/*
	Created: 20230523@Johnson  
	Task : check PT for master 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230523@Johnson: initial sp [redmine: #179159]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]

	Param's Explanation: 
		- @SettingType28 = '<Root>
						<R SportType="1" BetType="1" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						<R SportType="1" BetType="1" IsLive="1" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						....
						<R SportType="99" BetType="9" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
					</Root>'			
		- @SettingType1 = '<Root>
						<R SportType="43" BetType="1" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						<R SportType="44" BetType="1" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						....
						<R SportType="9908" BetType="1201" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
					</Root>'
		- @SettingType18 = '<Root>
						<R SportType="169" BetType="3611" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						<R SportType="220" BetType="1024" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						....
						<R SportType="245" BetType="4601" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
					</Root>'					
*/	
BEGIN
	SET NOCOUNT ON 
				
	DECLARE @tblPT18 TABLE (
				SettingType		SMALLINT,
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				SuperPT			SMALLMONEY,
				IsAutoSuperPT	BIT,
				AutoSuperPT		SMALLMONEY,
				MasterPT		SMALLMONEY,				
				MasterMinPT		SMALLMONEY,
				MasterMaxPT		SMALLMONEY,
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

		INSERT INTO @tblPT18(SettingType,
			SportType, 
			BetType, 
			IsLive,
			SuperPT,
			IsAutoSuperPT,
			AutoSuperPT,
			MasterPT,				
			MasterMinPT)
		SELECT 28 as SettingType,
			T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
			T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoSuperPT,
			T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoSuperPT,
			T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
			T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS MasterMinPT
		FROM  @xml.nodes('/Root/R') T(c)		
	END	

	IF ISNULL(@SettingType1,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML, @SettingType1)
		
		INSERT INTO @tblPT18(SettingType,
			SportType, 
			BetType, 
			IsLive,
			SuperPT,
			IsAutoSuperPT,
			AutoSuperPT,
			MasterPT,				
			MasterMinPT)
		SELECT 1 as SettingType,
			T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
			T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoSuperPT,
			T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoSuperPT,
			T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
			T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS MasterMinPT
		FROM  @xml.nodes('/Root/R') T(c)
		 			
	END
	
	IF ISNULL(@SettingType18,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML, @SettingType18)
		
		INSERT INTO @tblPT18(SettingType,
			SportType, 
			BetType, 
			IsLive,
			SuperPT,
			IsAutoSuperPT,
			AutoSuperPT,
			MasterPT,				
			MasterMinPT)
		SELECT 18 as SettingType,
			T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
			T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoSuperPT,
			T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoSuperPT,
			T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
			T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS MasterMinPT
		FROM  @xml.nodes('/Root/R') T(c)			
	END
	
	INSERT INTO #ProductSettingDetail_PTCheck(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT,Child_DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,RealProductID,SettingLevel,MaxPT,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)
	WHERE SettingType IN (1,18,28)
	
	--check pt > 0 
	;WITH T AS (
		SELECT t.SportType, t.BetType, t.IsLive, ps.SettingLevel,ps.ProductID
		FROM @tblPT18 t
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		WHERE (t.SuperPT < 0 OR t.MasterPT < 0 
				OR t.SuperPT + t.MasterPT > ps.MaxPT
				OR t.AutoSuperPT < 0 
				OR t.AutoSuperPT > ps.MaxPT
				OR t.MasterMinPT < 0
				OR t.MasterMinPT > t.MasterPT
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
	
	--check n4<=s3+m3<=l4 if i3 = 0, 
	--m3<=l4 and u3+m3>=n4 if i3 = 1
	SELECT @ErrType = ''
    
	;WITH T AS (	
		SELECT b.SportType, b.BetType, b.IsLive, scs.MinPT, scs.MaxPT       
		FROM CustPTSetting3rd_Agent as scs WITH (NOLOCK) 
			INNER JOIN @tblPT18 as b ON scs.sporttype = b.sporttype 
										AND scs.bettype = b.bettype
										AND scs.isLive = b.isLive					
		WHERE scs.custid = @srecommend 
			AND ((b.IsAutoSuperPT=0 
					AND (b.SuperPT + b.MasterPT > scs.MaxPT 
						OR b.SuperPT + b.MasterPT < scs.MinPT)
					) 
				OR (b.IsAutoSuperPT >0 
					AND (b.MasterPT>scs.MaxPT 
						OR b.MasterPT + b.AutoSuperPT < scs.MinPT)
					)
				)
	)    
	SELECT @ErrType = (  
		SELECT t.*, ps.SettingLevel,ps.ProductID 
		FROM T
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		FOR XML RAW('Row'), TYPE
		)	 
  
	IF @ErrType IS NOT NULL
	BEGIN
		SELECT @ErrMsg = '<Root MsgID="20025" Msg="The position taking violates Upline Min/Max PT.">'
						+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
				, @MsgType = 62 
				, @ErrCode = 602
		RETURN            
	END
	
	--check m3<=m4
	SELECT @ErrType = ''        
	;WITH T AS (
		SELECT b.SportType, b.BetType, b.IsLive, scs.MasterPT as MaxPT				       
		FROM CustPTSetting3rd_Agent as scs WITH (NOLOCK)
			INNER JOIN @tblPT18 b ON scs.sporttype = b.SportType
									AND scs.bettype = b.BetType
									AND scs.isLive = b.IsLive					
		WHERE custid = @srecommend 
			AND scs.MasterPT < b.MasterPT
	)
	SELECT @ErrType = (    
		SELECT t.*, ps.SettingLevel,ps.ProductID 
		FROM T
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		FOR XML RAW('Row'), TYPE
	)

	IF @ErrType IS NOT NULL
	BEGIN           
		SELECT @ErrMsg = '<Root MsgID="20027" Msg="The position taking violates Master Max PT set by company">'
						+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
				, @MsgType = 63
				, @ErrCode = 603	
		RETURN  
	END
	
	--s3<=s4,s3+m3<=s4
	SELECT @ErrType = ''  
	;WITH T AS (
		SELECT b.SportType, b.BetType, b.IsLive, cs.SuperPT as MaxPT
		FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK)
			INNER JOIN @tblPT18 b ON cs.sporttype = b.SportType AND cs.bettype = b.BetType AND cs.isLive = b.IsLive																									
		WHERE custid = @srecommend 
			AND (cs.SuperPT < b.SuperPT OR b.SuperPT + b.MasterPT > cs.SuperPT)
	)      
	SELECT @ErrType = (
		SELECT t.*, ps.SettingLevel,ps.ProductID 
		FROM T
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		FOR XML RAW('Row'), TYPE
	)

	IF @ErrType IS NOT NULL
	BEGIN
		SELECT @ErrMsg = '<Root MsgID="20028" Msg="The position taking violates Super Max PT.">'
						+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
				, @MsgType = 63 
				, @ErrCode = 604
		RETURN
	END
	
	--correct i3,u3
	UPDATE t
	SET t.IsAutoSuperPT = 1
	FROM @tblPT18 t
	WHERE t.IsAutoSuperPT = 0 AND t.AutoSuperPT > 0
	
	UPDATE t
	SET t.AutoSuperPT = scs.SuperPT
	FROM @tblPT18 t
		INNER JOIN CustPTSetting3rd_Agent as scs WITH (NOLOCK) ON scs.sporttype = t.SportType
												AND scs.bettype = t.BetType
												AND scs.IsLive = t.IsLive					
	WHERE custid = @srecommend 
		AND t.AutoSuperPT > scs.SuperPT

	UPDATE t
	SET t.Child_DisplayOrder = d.Child_DisplayOrder
	FROM @tblPT18 t
		INNER JOIN #ProductSettingDetail_PTCheck d 
			ON t.SportType = d.SportType
			AND t.BetType = d.BetType
			AND t.IsLive = d.IsLive
		
	SELECT @SettingType28 = (
	SELECT SportType '@SportType', 
		BetType '@BetType', 
		IsLive '@IsLive',
		SuperPT '@SuperPT',
		IsAutoSuperPT '@IsAuto',
		AutoSuperPT '@AutoPT',
		MasterPT '@MasterPT',				
		MasterMinPT '@MinPT'
	FROM @tblPT18
	WHERE SettingType = 28
	ORDER BY Child_DisplayOrder,SportType,BetType
	FOR XML PATH ('R'), ROOT('Root')
	)	
	
	SELECT @SettingType1 = (
	SELECT SportType '@SportType', 
		BetType '@BetType', 
		IsLive '@IsLive',
		SuperPT '@SuperPT',
		IsAutoSuperPT '@IsAuto',
		AutoSuperPT '@AutoPT',
		MasterPT '@MasterPT',				
		MasterMinPT '@MinPT'
	FROM @tblPT18
	WHERE SettingType = 1
	ORDER BY Child_DisplayOrder,SportType,BetType
	FOR XML PATH ('R'), ROOT('Root')
	)	
	
	SELECT @SettingType18 = (
	SELECT SportType '@SportType', 
		BetType '@BetType', 
		IsLive '@IsLive',
		SuperPT '@SuperPT',
		IsAutoSuperPT '@IsAuto',
		AutoSuperPT '@AutoPT',
		MasterPT '@MasterPT',				
		MasterMinPT '@MinPT'
	FROM @tblPT18
	WHERE SettingType = 18
	ORDER BY Child_DisplayOrder,SportType,BetType
	FOR XML PATH ('R'), ROOT('Root')
	)		
	
	DROP TABLE #ProductSettingDetail_PTCheck
END		