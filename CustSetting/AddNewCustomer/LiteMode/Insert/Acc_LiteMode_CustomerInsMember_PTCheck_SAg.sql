/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_PTCheck_SAg]
	@srecommend INT,	
	
	@SettingType28 VARCHAR(MAX)= '' OUTPUT,-- SB
	@SettingType1 VARCHAR(MAX)= ''  OUTPUT,-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot), NG2
	@SettingType18 VARCHAR(MAX)= '' OUTPUT,-- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
	@CreationStatus TINYINT = 0,

	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT	
AS
/*
	Created: 20230523@Johnson  
	Task : check PT for master 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230523@Johnson: initial sp [redmine: #179159]

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
		
	DECLARE @tblPT28 TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				SuperPT			SMALLMONEY,
				IsAutoSuperPT	BIT,
				AutoSuperPT		SMALLMONEY,
				MasterPT		SMALLMONEY,				
				MasterMinPT		SMALLMONEY,
				MasterMaxPT		SMALLMONEY
				)		
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
				MasterMaxPT		SMALLMONEY
				)
	CREATE TABLE #ProductSettingDetail_PTCheck(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		[MaxPT]	[smallmoney],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)
	
	DECLARE @xml XML,
			@ErrType XML
	
	IF ISNULL(@SettingType28,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML, @SettingType28)
		
		INSERT INTO @tblPT28(SportType, 
			BetType, 
			IsLive,
			SuperPT,
			IsAutoSuperPT,
			AutoSuperPT,
			MasterPT,				
			MasterMinPT)
		SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney')/100 AS SuperPT,
			T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoSuperPT,
			T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney')/100 AS AutoSuperPT,
			T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney')/100 AS MasterPT,
			T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney')/100 AS MasterMinPT
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
	
	INSERT INTO #ProductSettingDetail_PTCheck(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT
	FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(NULL,@CreationStatus)
	
	--check pt > 0 
	;WITH T AS (
	SELECT t.SportType, t.BetType, t.IsLive
		FROM @tblPT28 t
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		WHERE ps.SettingType IN (28)--SB PT
			AND (t.SuperPT < 0 OR t.MasterPT < 0 
				OR t.SuperPT + t.MasterPT > ps.MaxPT/100
				OR t.AutoSuperPT < 0 
				OR t.AutoSuperPT > ps.MaxPT/100
				OR t.MasterMinPT < 0)
		UNION 
		SELECT t.SportType, t.BetType, t.IsLive
		FROM @tblPT18 t
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		WHERE ps.SettingType IN (1,18)--DCS PT
			AND (t.SuperPT < 0 OR t.MasterPT < 0 
				OR t.SuperPT + t.MasterPT > ps.MaxPT
				OR t.AutoSuperPT < 0 
				OR t.AutoSuperPT > ps.MaxPT
				OR t.MasterMinPT < 0
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
		SELECT b.SportType, b.BetType, b.IsLive, scs.minpositiontaking*100 as MinPT, scs.maxpositiontaking*100 as MaxPT      
		FROM custoverride as scs WITH (NOLOCK) 
			INNER JOIN @tblPT28 as b ON scs.sporttype = b.sporttype 
										AND scs.bettype = b.bettype
										AND b.isLive = 0				
		WHERE scs.custid = @srecommend 
			AND ((b.IsAutoSuperPT=0 
					AND (b.SuperPT + b.MasterPT > scs.maxpositiontaking 
						OR b.SuperPT + b.MasterPT < scs.minpositiontaking)
					) 
				OR (b.IsAutoSuperPT >0 
					AND (b.MasterPT>scs.maxpositiontaking 
						OR b.MasterPT + b.AutoSuperPT < scs.minpositiontaking)
					)
				)
		UNION 
		SELECT b.SportType, b.BetType, b.IsLive, scs.minlivepositiontaking*100 as MinPT, scs.maxlivepositiontaking*100 as MaxPT       
		FROM custoverride as scs WITH (NOLOCK) 
			INNER JOIN @tblPT28 as b ON scs.sporttype = b.sporttype 
										AND scs.bettype = b.bettype
										AND b.isLive = 1				
		WHERE scs.custid = @srecommend 
			AND ((b.IsAutoSuperPT=0 
					AND (b.SuperPT + b.MasterPT > scs.maxlivepositiontaking 
						OR b.SuperPT + b.MasterPT < scs.minlivepositiontaking)
					) 
				OR (b.IsAutoSuperPT >0 
					AND (b.MasterPT>scs.maxlivepositiontaking 
						OR b.MasterPT + b.AutoSuperPT < scs.minlivepositiontaking
						)
					)
				)
		UNION		
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
		SELECT * 
		FROM T
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
		SELECT b.SportType, b.BetType, b.IsLive, scs.mpositiontaking*100 as MaxPT				       
		FROM custsetting as scs WITH (NOLOCK)
			INNER JOIN @tblPT28 b ON scs.sporttype = b.SportType
									AND scs.bettype = b.BetType
									AND b.IsLive = 0					
		WHERE custid = @srecommend 
			AND scs.mpositiontaking < b.MasterPT
		UNION
		SELECT b.SportType, b.BetType, b.IsLive, scs.mlivepositiontaking*100 as MaxPT				       
		FROM custsetting as scs WITH (NOLOCK)
			INNER JOIN @tblPT28 b ON scs.sporttype = b.SportType
									AND scs.bettype = b.BetType
									AND b.IsLive = 1					
		WHERE custid = @srecommend 
			AND scs.mlivepositiontaking < b.MasterPT
		UNION			
		SELECT b.SportType, b.BetType, b.IsLive, scs.MasterPT as MaxPT				       
		FROM CustPTSetting3rd_Agent as scs WITH (NOLOCK)
			INNER JOIN @tblPT18 b ON scs.sporttype = b.SportType
									AND scs.bettype = b.BetType
									AND scs.isLive = b.IsLive					
		WHERE custid = @srecommend 
			AND scs.MasterPT < b.MasterPT
	)
	SELECT @ErrType = (    
		SELECT * FROM T
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
		SELECT b.SportType, b.BetType, b.IsLive, cs.spositiontaking as MaxPT
		FROM custsetting AS cs WITH (NOLOCK)
			INNER JOIN @tblPT28 b ON cs.sporttype = b.SportType 
								AND cs.bettype = b.BetType 
								AND b.IsLive = 0
		WHERE custid = @srecommend 
			AND (cs.spositiontaking < b.SuperPT OR b.SuperPT + b.MasterPT > cs.spositiontaking)
		UNION
		SELECT b.SportType, b.BetType, b.IsLive, cs.slivepositiontaking as MaxPT
		FROM custsetting AS cs WITH (NOLOCK)
			INNER JOIN @tblPT28 b ON cs.sporttype = b.SportType 
								AND cs.bettype = b.BetType 
								AND b.IsLive = 1
		WHERE custid = @srecommend 
			AND (cs.slivepositiontaking < b.SuperPT OR b.SuperPT + b.MasterPT > cs.slivepositiontaking)
		UNION	
		SELECT b.SportType, b.BetType, b.IsLive, cs.SuperPT as MaxPT
		FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK)
			INNER JOIN @tblPT18 b ON cs.sporttype = b.SportType AND cs.bettype = b.BetType AND cs.isLive = b.IsLive																									
		WHERE custid = @srecommend 
			AND (cs.SuperPT < b.SuperPT OR b.SuperPT + b.MasterPT > cs.SuperPT)
	)      
	SELECT @ErrType = (
		SELECT * FROM T
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
	FROM @tblPT28 t
	WHERE t.IsAutoSuperPT = 0 AND t.AutoSuperPT > 0
	
	UPDATE t
	SET t.AutoSuperPT = scs.spositiontaking
	FROM @tblPT28 t
		INNER JOIN custsetting as scs WITH (NOLOCK) ON scs.sporttype = t.SportType
												AND scs.bettype = t.BetType
												AND t.IsLive = 0					
	WHERE custid = @srecommend 
		AND t.AutoSuperPT > scs.spositiontaking
	
	UPDATE t
	SET t.AutoSuperPT = scs.slivepositiontaking
	FROM @tblPT28 t
		INNER JOIN custsetting as scs WITH (NOLOCK) ON scs.sporttype = t.SportType
												AND scs.bettype = t.BetType
												AND t.IsLive = 1					
	WHERE custid = @srecommend 
		AND t.AutoSuperPT > scs.slivepositiontaking
		
	UPDATE t
	SET t.IsAutoSuperPT = 1
	FROM @tblPT18 t
	WHERE t.IsAutoSuperPT = 0 AND t.AutoSuperPT > 0
	
	UPDATE t
	SET t.AutoSuperPT = scs.AutoSuperPT
	FROM @tblPT18 t
		INNER JOIN CustPTSetting3rd_Agent as scs WITH (NOLOCK) ON scs.sporttype = t.SportType
												AND scs.bettype = t.BetType
												AND scs.IsLive = t.IsLive					
	WHERE custid = @srecommend 
		AND t.AutoSuperPT > scs.AutoSuperPT
		
	SELECT @SettingType28 = (
	SELECT SportType '@SportType', 
		BetType '@BetType', 
		IsLive '@IsLive',
		SuperPT '@SuperPT',
		IsAutoSuperPT '@IsAuto',
		AutoSuperPT '@AutoPT',
		MasterPT '@MasterPT',				
		MasterMinPT '@MinPT'
	FROM @tblPT28
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
	FOR XML PATH ('R'), ROOT('Root')
	)		
	
	DROP TABLE #ProductSettingDetail_PTCheck
END		