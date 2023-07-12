/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_PTCheck_MAg]
	@mrecommend INT,	
	@srecommend INT,
	
	@SettingType28 VARCHAR(MAX)= '' OUTPUT,-- SB
	@SettingType1 VARCHAR(MAX)= ''  OUTPUT,-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot)
	@SettingType18 VARCHAR(MAX)= '' OUTPUT,-- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
	@CreationStatus TINYINT = 0,

	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT	
AS
/*
	Created: 20230629@Johnson  
	Task : check PT for agent 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230629@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
		- @SettingType28 = '<Root>
						<R SportType="1" BetType="1" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
						<R SportType="1" BetType="1" IsLive="1" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
						....
						<R SportType="99" BetType="9" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
					</Root>'			
		- @SettingType1 = '<Root>
						<R SportType="43" BetType="1" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
						<R SportType="44" BetType="1" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
						....
						<R SportType="9908" BetType="1201" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
					</Root>'
		- @SettingType18 = '<Root>
						<R SportType="169" BetType="3611" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
						<R SportType="220" BetType="1024" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
						....
						<R SportType="245" BetType="4601" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
					</Root>'						
*/	
BEGIN
	SET NOCOUNT ON 
		
	DECLARE @tblPT28 TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				MasterPT		SMALLMONEY,
				IsAutoMasterPT	BIT,
				AutoMasterPT	SMALLMONEY,
				AgentPT			SMALLMONEY,				
				AgentMinPT		SMALLMONEY
				)		
	DECLARE @tblPT18 TABLE (
				SettingType		SMALLINT,
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				MasterPT		SMALLMONEY,
				IsAutoMasterPT	BIT,
				AutoMasterPT	SMALLMONEY,
				AgentPT			SMALLMONEY,				
				AgentMinPT		SMALLMONEY
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
			MasterPT,
			IsAutoMasterPT,
			AutoMasterPT,
			AgentPT,				
			AgentMinPT)
		SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney')/100 AS MasterPT,
			T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoMasterPT,
			T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney')/100 AS AutoMasterPT,
			T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney')/100 AS AgentPT,
			T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney')/100 AS AgentMinPT
		FROM  @xml.nodes('/Root/R') T(c) 			
	END	

	IF ISNULL(@SettingType1,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML, @SettingType1)
		
		INSERT INTO @tblPT18(SettingType,
			SportType,
			BetType, 
			IsLive,
			MasterPT,
			IsAutoMasterPT,
			AutoMasterPT,
			AgentPT,				
			AgentMinPT)
		SELECT 1 as SettingType,
			T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
			T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoMasterPT,
			T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoMasterPT,
			T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT,
			T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS AgentMinPT
		FROM  @xml.nodes('/Root/R') T(c)
		 			
	END
	
	IF ISNULL(@SettingType18,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML, @SettingType18)
		
		INSERT INTO @tblPT18(SettingType,
			SportType,
			BetType, 
			IsLive,
			MasterPT,
			IsAutoMasterPT,
			AutoMasterPT,
			AgentPT,				
			AgentMinPT)
		SELECT 18 as SettingType,
			T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
			T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoMasterPT,
			T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoMasterPT,
			T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT,
			T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS AgentMinPT
		FROM  @xml.nodes('/Root/R') T(c)			
	END
	
	INSERT INTO #ProductSettingDetail_PTCheck(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,
		CASE WHEN SettingLevel = 4 THEN SettingLevel --SporttypeBettype
			ELSE 2 END as SettingLevel,--Sporttype
		MaxPT
	FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(NULL,@CreationStatus)
	WHERE SettingType IN (1,18,28)
	
	--check pt > 0 
	;WITH T AS (
	SELECT t.SportType, t.BetType, t.IsLive, SettingLevel
		FROM @tblPT28 t
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		WHERE ps.SettingType IN (28)--SB PT
			AND (t.AgentPT < 0 OR t.MasterPT < 0 
					OR t.AgentPT + t.MasterPT > ps.MaxPT
					OR t.MasterPT > ps.MaxPT			
					OR t.AutoMasterPT < 0 
					OR t.AutoMasterPT > ps.MaxPT)
		UNION 
		SELECT t.SportType, t.BetType, t.IsLive, SettingLevel
		FROM @tblPT18 t
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		WHERE ps.SettingType IN (1,18)--DCS PT
			AND (t.AgentPT < 0 OR t.MasterPT < 0 
				OR t.AgentPT + t.MasterPT > ps.MaxPT
				OR t.MasterPT > ps.MaxPT			
				OR t.AutoMasterPT < 0 
				OR t.AutoMasterPT > ps.MaxPT
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
	
	IF EXISTS(	
			SELECT 1
			FROM @tblPT28 t
			WHERE IsAutoMasterPT = 1 
			UNION 			
			SELECT 1
			FROM @tblPT18 t
			WHERE IsAutoMasterPT = 1 	
			)
			AND EXISTS (SELECT 1 FROM CustMaster WITH(NOLOCK) 
						WHERE custid = @mrecommend	
							AND DisableAutoMPT = 1)
	BEGIN
		SELECT @ErrCode = 602,
			   @ErrMsg = '<Root MsgID="20044" Msg="You are not allowed to have Auto PT, please contact your upline." />',
			   @MsgType = 0
		RETURN					
	END	
	
	--Check if(!i2)n3<=m2+a2<=min(m3,l3)
	--			else a2<=l3 and u2+a2>=n3
	;WITH T AS (
		SELECT b.SportType, b.BetType, b.IsLive, mco.minpositiontaking*100 as MinPT
				, (CASE WHEN mcs.mpositiontaking	> mco.maxpositiontaking THEN mcs.mpositiontaking ELSE  mco.maxpositiontaking END)*100 MaxPT			
		FROM 
			custsetting mcs WITH(NOLOCK)			  
			INNER JOIN @tblPT28 b ON mcs.sporttype=b.sporttype 
								AND mcs.bettype = b.bettype        
								AND b.isLive = 0
			INNER JOIN custoverride AS mco WITH (NOLOCK) ON mcs.custid = mco.custid
														AND mcs.sporttype=b.sporttype 
														AND mcs.bettype = b.bettype 						
		WHERE mcs.custid = @mrecommend 
			AND (         
					(b.IsAutoMasterPT=0
					AND (b.MasterPT + b.AgentPT > CASE WHEN mcs.mpositiontaking	> mco.maxpositiontaking THEN mcs.mpositiontaking ELSE  mco.maxpositiontaking END OR b.MasterPT + b.AgentPT  < mco.minpositiontaking)
					)
					OR         
					(b.IsAutoMasterPT>0 
					AND (b.AgentPT > CASE WHEN mcs.mpositiontaking	> mco.maxpositiontaking THEN mcs.mpositiontaking ELSE  mco.maxpositiontaking END OR b.AgentPT + b.AutoMasterPT < mco.minpositiontaking)
					)        
				)	
		UNION ALL
		SELECT b.SportType, b.BetType, b.IsLive, mco.minpositiontaking*100 as MinPT
				, (CASE WHEN mcs.mpositiontaking	> mco.maxpositiontaking THEN mcs.mpositiontaking ELSE  mco.maxpositiontaking END)*100 MaxPT			
		FROM 
			custsetting mcs WITH(NOLOCK)			  
			INNER JOIN @tblPT28 b ON mcs.sporttype=b.sporttype 
								AND mcs.bettype = b.bettype        
								AND b.isLive = 1
			INNER JOIN custoverride AS mco WITH (NOLOCK) ON mcs.custid = mco.custid
														AND mcs.sporttype=b.sporttype 
														AND mcs.bettype = b.bettype 						
		WHERE mcs.custid = @mrecommend 
			AND (         
					(b.IsAutoMasterPT=0
					AND (b.MasterPT + b.AgentPT > CASE WHEN mcs.mlivepositiontaking	> mco.maxlivepositiontaking THEN mcs.mlivepositiontaking ELSE  mco.maxlivepositiontaking END OR b.MasterPT + b.AgentPT  < mco.minlivepositiontaking)
					)
					OR         
					(b.IsAutoMasterPT>0 
					AND (b.AgentPT > CASE WHEN mcs.mlivepositiontaking	> mco.maxlivepositiontaking THEN mcs.mlivepositiontaking ELSE  mco.maxlivepositiontaking END OR b.AgentPT + b.AutoMasterPT < mco.minlivepositiontaking)
					)        
				)
		UNION ALL	
		SELECT b.SportType, b.BetType, b.IsLive, mcs.MinPT
				, CASE WHEN mcs.MaxPT	> mcs.MasterPT THEN mcs.MasterPT ELSE  mcs.MaxPT END MaxPT			
		FROM 
			CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) 
			INNER JOIN @tblPT18 b ON mcs.sporttype=b.sporttype 
									AND mcs.bettype = b.bettype        
									AND mcs.isLive = b.isLive       			
		WHERE mcs.custid = @mrecommend 
			AND (         
					(b.IsAutoMasterPT=0
					AND (b.MasterPT + b.AgentPT > CASE WHEN mcs.MaxPT	> mcs.MasterPT THEN mcs.MasterPT ELSE  mcs.MaxPT END OR b.MasterPT + b.AgentPT  < mcs.MinPT)
					)
					OR         
					(b.IsAutoMasterPT>0 
					AND (b.AgentPT > CASE WHEN mcs.MaxPT	> mcs.MasterPT THEN mcs.MasterPT ELSE  mcs.MaxPT END OR b.AgentPT + b.AutoMasterPT < mcs.MinPT)
					)        
				)				
	)
	SELECT @ErrType =(
		SELECT t.* , ps.SettingLevel
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
				, @ErrCode = 603	
		RETURN
	END  
	
	--check a2<=a4
	SELECT @ErrType = ''
	;WITH T AS (
		SELECT b.SportType, b.BetType, b.IsLive, scs.apositiontaking*100 as MaxPT				
		FROM 
			custsetting scs WITH(NOLOCK)			  
			INNER JOIN @tblPT28 b ON scs.sporttype=b.sporttype 
								AND scs.bettype = b.bettype        
								AND b.isLive = 0						
		WHERE scs.custid = @srecommend 
			AND b.AgentPT > scs.apositiontaking	
		UNION ALL
		SELECT b.SportType, b.BetType, b.IsLive, scs.alivepositiontaking*100 as MaxPT				
		FROM 
			custsetting scs WITH(NOLOCK)			  
			INNER JOIN @tblPT28 b ON scs.sporttype=b.sporttype 
								AND scs.bettype = b.bettype        
								AND b.isLive = 1						
		WHERE scs.custid = @srecommend 
			AND b.AgentPT > scs.alivepositiontaking
		UNION ALL
		SELECT b.SportType, b.BetType, b.IsLive, scs.AgentPT as MaxPT				
		FROM 
			CustPTSetting3rd_Agent scs WITH(NOLOCK)			  
			INNER JOIN @tblPT28 b ON scs.sporttype=b.sporttype 
								AND scs.bettype = b.bettype        
								AND b.isLive = 0						
		WHERE scs.custid = @srecommend 
			AND b.AgentPT > scs.AgentPT		
	)
	SELECT @ErrType =(
		SELECT t.*,ps.SettingLevel 
		FrOM T
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		FOR XML RAW('Row'), TYPE
	)	
	
	IF @ErrType IS NOT NULL
	BEGIN       
		SELECT @ErrMsg = '<Root MsgID="20005" Msg="Wrong position taking (max set by company).">'
						+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
				, @MsgType = 63
				, @ErrCode = 604	
		RETURN
	END  
		
	--correct im2,um2
	UPDATE t
	SET t.IsAutoMasterPT = 1
	FROM @tblPT28 t
	WHERE t.IsAutoMasterPT = 0 AND t.AutoMasterPT > 0
	
	UPDATE t
	SET t.AutoMasterPT = mcs.mpositiontaking
	FROM @tblPT28 t
		INNER JOIN custsetting as mcs WITH (NOLOCK) ON mcs.sporttype = t.SportType
												AND mcs.bettype = t.BetType
												AND t.IsLive = 0					
	WHERE custid = @mrecommend 
		AND t.AutoMasterPT > mcs.mpositiontaking
	
	UPDATE t
	SET t.AutoMasterPT = mcs.mpositiontaking
	FROM @tblPT28 t
		INNER JOIN custsetting as mcs WITH (NOLOCK) ON mcs.sporttype = t.SportType
												AND mcs.bettype = t.BetType
												AND t.IsLive = 1					
	WHERE custid = @mrecommend 
		AND t.AutoMasterPT > mcs.mlivepositiontaking

	UPDATE t
	SET t.IsAutoMasterPT = 1
	FROM @tblPT18 t
	WHERE t.IsAutoMasterPT = 0 AND t.AutoMasterPT > 0
	
	UPDATE t
	SET t.AutoMasterPT = mcs.MasterPT
	FROM @tblPT18 t
		INNER JOIN CustPTSetting3rd_Agent as mcs WITH (NOLOCK) ON mcs.sporttype = t.SportType
																AND mcs.bettype = t.BetType
																AND t.IsLive = 0					
	WHERE custid = @mrecommend 
		AND t.AutoMasterPT > mcs.MasterPT
	
	SELECT @SettingType28 = (
	SELECT SportType '@SportType', 
		BetType '@BetType', 
		IsLive '@IsLive',
		MasterPT '@MasterPT',
		IsAutoMasterPT '@IsAuto',
		AutoMasterPT '@AutoPT',
		AgentPT '@AgentPT',				
		AgentMinPT '@MinPT'
	FROM @tblPT28
	FOR XML PATH ('R'), ROOT('Root')
	)	
	
	SELECT @SettingType1 = (
	SELECT SportType '@SportType', 
		BetType '@BetType', 
		IsLive '@IsLive',
		MasterPT '@MasterPT',
		IsAutoMasterPT '@IsAuto',
		AutoMasterPT '@AutoPT',
		AgentPT '@AgentPT',				
		AgentMinPT '@MinPT'
	FROM @tblPT18
	WHERE SettingType = 1
	FOR XML PATH ('R'), ROOT('Root')
	)	
	
	SELECT @SettingType18 = (
	SELECT SportType '@SportType', 
		BetType '@BetType', 
		IsLive '@IsLive',
		MasterPT '@MasterPT',
		IsAutoMasterPT '@IsAuto',
		AutoMasterPT '@AutoPT',
		AgentPT '@AgentPT',				
		AgentMinPT '@MinPT'
	FROM @tblPT18
	WHERE SettingType = 18
	FOR XML PATH ('R'), ROOT('Root')
	)		
	
	DROP TABLE #ProductSettingDetail_PTCheck
END		