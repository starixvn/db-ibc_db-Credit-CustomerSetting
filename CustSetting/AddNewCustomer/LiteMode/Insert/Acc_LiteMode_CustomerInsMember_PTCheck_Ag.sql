/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_PTCheck_Ag]
	@srecommend INT,
	@mrecommend INT,
	@recommend INT,		
	@siteid SMALLINT =0,
	@currency SMALLINT =0,
	
	@SettingType28 VARCHAR(MAX)= '' OUTPUT,-- SB
	@SettingType1 VARCHAR(MAX)= ''  OUTPUT,-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot)
	@SettingType18 VARCHAR(MAX)= '' OUTPUT,-- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
	@CreationStatus TINYINT = 0,

	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT	
AS
/*
	Created: 20230727@Johnson  
	Task : check PT for member 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230727@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
		- @SettingType28 = '<Root>
						<R SportType="1" BetType="1" IsLive="0" AgentPT="20" />
						<R SportType="1" BetType="1" IsLive="1" AgentPT="20" />
						....
						<R SportType="99" BetType="9" IsLive="0" AgentPT="20" />
					</Root>'			
		- @SettingType1 = '<Root>
						<R SportType="43" BetType="1" IsLive="0" AgentPT="20" />
						<R SportType="44" BetType="1" IsLive="0" AgentPT="20" />
						....
						<R SportType="9908" BetType="1201" IsLive="0" AgentPT="20" />
					</Root>'
		- @SettingType18 = '<Root>
						<R SportType="169" BetType="3611" IsLive="0" AgentPT="20" />
						<R SportType="220" BetType="1024" IsLive="0" AgentPT="20" />
						....
						<R SportType="245" BetType="4601" IsLive="0" AgentPT="20" />
					</Root>'									
*/	
BEGIN
	SET NOCOUNT ON 
		
	DECLARE @tblPT28 TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				AgentPT			SMALLMONEY,
				SuperPT 		SMALLMONEY,
				MasterPT		SMALLMONEY
				)		
	DECLARE @tblPT18 TABLE (
				SettingType		SMALLINT,
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				AgentPT			SMALLMONEY,
				SuperPT 		SMALLMONEY,
				MasterPT		SMALLMONEY
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
			AgentPT)
		SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney')/100 AS AgentPT
		FROM  @xml.nodes('/Root/R') T(c) 			
	END	

	IF ISNULL(@SettingType1,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML, @SettingType1)
		
		INSERT INTO @tblPT18(SettingType,
			SportType,
			BetType, 
			IsLive,
			AgentPT)
		SELECT 1 as SettingType,
			T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT
		FROM  @xml.nodes('/Root/R') T(c)
		 			
	END
	
	IF ISNULL(@SettingType18,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML, @SettingType18)
		
		INSERT INTO @tblPT18(SettingType,
			SportType,
			BetType, 
			IsLive,
			AgentPT)
		SELECT 18 as SettingType,
			T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT
		FROM  @xml.nodes('/Root/R') T(c)			
	END
	
	INSERT INTO #ProductSettingDetail_PTCheck(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT)
	SELECT SportType,BetType,SettingType,IsLive,RealProductID,SettingLevel,MaxPT
	FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(NULL,@CreationStatus,@siteid,@currency)
	WHERE SettingType IN (1,18,28)
	
	--check pt > 0 
	;WITH T AS (
	SELECT t.SportType, t.BetType, t.IsLive, SettingLevel,ps.ProductID
		FROM @tblPT28 t
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		WHERE ps.SettingType IN (28)--SB PT
			AND (t.AgentPT < 0 
				OR t.AgentPT > ps.MaxPT			
				)
		UNION 
		SELECT t.SportType, t.BetType, t.IsLive, SettingLevel,ps.ProductID
		FROM @tblPT18 t
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		WHERE ps.SettingType IN (1,18)--DCS PT
			AND (t.AgentPT < 0 				
				OR t.AgentPT > ps.MaxPT
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
	
	--check n2<=a1<=l2
	;WITH T AS (
		SELECT b.SportType, b.BetType, b.IsLive, 
			co.minpositiontaking*100 MinPT,
			co.maxpositiontaking*100 MaxPT	
		FROM @tblPT28 b
			INNER JOIN custoverride AS co WITH (NOLOCK) ON co.sporttype=b.sporttype 
														AND co.bettype = b.bettype 
														AND b.isLive = 0														
		WHERE co.custid = @recommend 
			AND (b.AgentPT < co.minpositiontaking OR b.AgentPT > co.maxpositiontaking)
		UNION ALL
		SELECT b.SportType, b.BetType, b.IsLive, 
			co.minlivepositiontaking*100 MinPT,
			co.maxlivepositiontaking*100 MaxPT	
		FROM @tblPT28 b
			INNER JOIN custoverride AS co WITH (NOLOCK) ON co.sporttype=b.sporttype 
														AND co.bettype = b.bettype 
														AND b.isLive = 1														
		WHERE co.custid = @recommend 
			AND (b.AgentPT < co.minlivepositiontaking OR b.AgentPT > co.maxlivepositiontaking)	
		UNION ALL
		SELECT b.SportType, b.BetType, b.IsLive,co.MinPT,co.MaxPT	
		FROM @tblPT18 b
			INNER JOIN CustPTSetting3rd_Agent AS co WITH (NOLOCK) ON co.sporttype=b.sporttype 
														AND co.bettype = b.bettype 
														AND b.isLive = 0														
		WHERE co.custid = @recommend 
			AND (b.AgentPT < co.MinPT OR b.AgentPT > co.MaxPT)	
	)	
	SELECT @ErrType =(
		SELECT t.* , ps.SettingLevel,ps.ProductID
		FROM T
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		FOR XML RAW('Row'), TYPE
	)	
	
	IF @ErrType IS NOT NULL
	BEGIN       
		SELECT @ErrMsg = '<Root MsgID="20002" Msg="Wrong position taking (min/max set by company).">'
						+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
				, @MsgType = 62
				, @ErrCode = 602	
		RETURN
	END  
	
	--check a1<=min(a2,a4) - Vinh
	SELECT @ErrType = ''
	;WITH T AS (
		SELECT b.SportType, b.BetType, b.IsLive, 
			(CASE WHEN cs.apositiontaking < scs.apositiontaking THEN cs.apositiontaking ELSE scs.apositiontaking END)*100 MaxPT	
		FROM @tblPT28 b
			INNER JOIN custsetting AS cs WITH (NOLOCK) ON cs.custid = @recommend 
														AND cs.sporttype=b.sporttype 
														AND cs.bettype = b.bettype 
														AND b.isLive = 0
			INNER JOIN custsetting AS scs WITH (NOLOCK) ON scs.custid = @srecommend
														AND scs.sporttype=b.sporttype 
														AND scs.bettype = b.bettype 																							
		WHERE b.AgentPT > CASE WHEN cs.apositiontaking < scs.apositiontaking THEN cs.apositiontaking ELSE scs.apositiontaking END
		UNION ALL
		SELECT b.SportType, b.BetType, b.IsLive, 
			(CASE WHEN cs.alivepositiontaking < scs.alivepositiontaking THEN cs.alivepositiontaking ELSE scs.alivepositiontaking END)*100 MaxPT	
		FROM @tblPT28 b
			INNER JOIN custsetting AS cs WITH (NOLOCK) ON cs.custid = @recommend 
														AND cs.sporttype=b.sporttype 
														AND cs.bettype = b.bettype 
														AND b.isLive = 1
			INNER JOIN custsetting AS scs WITH (NOLOCK) ON scs.custid = @srecommend
														AND scs.sporttype=b.sporttype 
														AND scs.bettype = b.bettype 																							
		WHERE b.AgentPT > CASE WHEN cs.alivepositiontaking < scs.alivepositiontaking THEN cs.alivepositiontaking ELSE scs.alivepositiontaking END
		UNION ALL
		SELECT b.SportType, b.BetType, b.IsLive, 
			CASE WHEN cs.AgentPT < scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END MaxPT	
		FROM @tblPT18 b
			INNER JOIN CustPTSetting3rd_Agent AS cs WITH (NOLOCK) ON cs.custid = @recommend 
														AND cs.sporttype=b.sporttype 
														AND cs.bettype = b.bettype 
														AND cs.isLive = b.isLive
			INNER JOIN CustPTSetting3rd_Agent AS scs WITH (NOLOCK) ON scs.custid = @srecommend
														AND scs.sporttype=b.sporttype 
														AND scs.bettype = b.bettype 
														AND scs.isLive = b.isLive														
		WHERE b.AgentPT > CASE WHEN cs.AgentPT < scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END		
	)
	SELECT @ErrType =(
		SELECT t.* , ps.SettingLevel,ps.ProductID
		FROM T
			INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																AND t.BetType = ps.bettype 
																AND t.IsLive = ps.IsLive
		FOR XML RAW('Row'), TYPE
	)	
	
	IF @ErrType IS NOT NULL
	BEGIN       
		SELECT @ErrMsg = '<Root MsgID="20008" Msg="Wrong agent position taking.">'
						+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
				, @MsgType = 63
				, @ErrCode = 603	
		RETURN
	END  
	
	--correct PT 
	--IF u2 = 0 THEN m1 = m2
    --else	IF u2 < m3 - a1 THEN m1 = u2
    --		else m1 = m3 - a1
	
	--@max_spt = @maxdownlinepos + spt 
    --IF @auto_spt = 0 THEN @spt = s3
    --else	IF @auto_spt < s4 - @mpt - @apt THEN @spt = @auto_spt
    --		else @spt = s4 - @mpt - @apt
	DECLARE @MasterPT SMALLMONEY
	
	UPDATE t
	SET @MasterPT = CASE WHEN cs.isautompositiontaking = 0 THEN cs.mpositiontaking 
						ELSE CASE WHEN cs.autompositiontaking < mcs.mpositiontaking - t.AgentPT THEN cs.autompositiontaking
								ELSE mcs.mpositiontaking - t.AgentPT END
						END,
		t.SuperPT = CASE WHEN mcs.isautopositiontaking = 0 THEN mcs.spositiontaking
						ELSE CASE WHEN mcs.autopositiontaking < scs.spositiontaking - @MasterPT - t.AgentPT
									THEN mcs.autopositiontaking
									ELSE scs.spositiontaking - @MasterPT - t.AgentPT
								END
						END,
		t.MasterPT = @MasterPT						
	FROM @tblPT28 t 
		INNER JOIN custsetting cs WITH(NOLOCK) ON cs.custid = @recommend
												AND cs.sporttype = t.sporttype
												AND cs.bettype = t.bettype
												AND t.IsLive = 0
		INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
												AND mcs.sporttype = t.sporttype
												AND mcs.bettype = t.bettype
		INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
												AND scs.sporttype = t.sporttype
												AND scs.bettype = t.bettype
	UPDATE t
	SET @MasterPT = CASE WHEN cs.isautolivempositiontaking = 0 THEN cs.mlivepositiontaking 
						ELSE CASE WHEN cs.autolivempositiontaking < mcs.mlivepositiontaking - t.AgentPT THEN cs.autolivempositiontaking
									ELSE mcs.mlivepositiontaking - t.AgentPT END
						END,
		t.SuperPT = CASE WHEN mcs.isautolivepositiontaking = 0 THEN mcs.slivepositiontaking
								ELSE CASE WHEN mcs.autolivepositiontaking < scs.slivepositiontaking - @MasterPT - t.AgentPT
											THEN mcs.autolivepositiontaking
											ELSE scs.slivepositiontaking - @MasterPT - t.AgentPT
										END
						END,
		t.MasterPT = @MasterPT							
	FROM @tblPT28 t 
		INNER JOIN custsetting cs WITH(NOLOCK) ON cs.custid = @recommend
												AND cs.sporttype = t.sporttype
												AND cs.bettype = t.bettype
												AND t.IsLive = 1
		INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
												AND mcs.sporttype = t.sporttype
												AND mcs.bettype = t.bettype
		INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
												AND scs.sporttype = t.sporttype
												AND scs.bettype = t.bettype										
	
	UPDATE t
	SET @MasterPT = CASE WHEN cs.IsAutoMasterPT = 0 THEN cs.MasterPT 
						ELSE CASE WHEN cs.AutoMasterPT < mcs.MasterPT - t.AgentPT THEN cs.AutoMasterPT
									ELSE mcs.MasterPT - t.AgentPT END
						END,
		t.SuperPT = CASE WHEN mcs.IsAutoSuperPT = 0 THEN mcs.SuperPT
								ELSE CASE WHEN mcs.AutoSuperPT < scs.SuperPT - @MasterPT - t.AgentPT
											THEN mcs.AutoSuperPT
											ELSE scs.SuperPT - @MasterPT - t.AgentPT
										END		
								END,
		t.MasterPT = @MasterPT				
	FROM @tblPT18 t 
		INNER JOIN CustPTSetting3rd_Agent cs WITH(NOLOCK) ON cs.custid = @recommend
												AND cs.sporttype = t.sporttype
												AND cs.bettype = t.bettype
												AND cs.IsLive = t.IsLive
		INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
												AND mcs.sporttype = t.sporttype
												AND mcs.bettype = t.bettype
												AND mcs.IsLive = t.IsLive
		INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @srecommend
												AND mcs.sporttype = t.sporttype
												AND mcs.bettype = t.bettype
												AND mcs.IsLive = t.IsLive
																						
	SELECT @SettingType28 = (
	SELECT SportType '@SportType', 
		BetType '@BetType', 
		IsLive '@IsLive',
		SuperPT '@SuperPT',
		MasterPT '@MasterPT',		
		AgentPT '@AgentPT'
	FROM @tblPT28
	FOR XML PATH ('R'), ROOT('Root')
	)	
	
	SELECT @SettingType1 = (
	SELECT SportType '@SportType', 
		BetType '@BetType', 
		IsLive '@IsLive',
		SuperPT '@SuperPT',
		MasterPT '@MasterPT',		
		AgentPT '@AgentPT'
	FROM @tblPT18
	WHERE SettingType = 1
	FOR XML PATH ('R'), ROOT('Root')
	)	
	
	SELECT @SettingType18 = (
	SELECT SportType '@SportType', 
		BetType '@BetType', 
		IsLive '@IsLive',
		SuperPT '@SuperPT',
		MasterPT '@MasterPT',		
		AgentPT '@AgentPT'
	FROM @tblPT18
	WHERE SettingType = 18
	FOR XML PATH ('R'), ROOT('Root')
	)	
	
	DROP TABLE #ProductSettingDetail_PTCheck
END		