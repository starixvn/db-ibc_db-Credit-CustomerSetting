/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].Acc_CustomerInsMember_PTCheck_DirectMember
	@srecommend INT,
	@mrecommend INT,
	@UplineRoleID TINYINT, 	
	@siteid SMALLINT =0,
	@currency SMALLINT =0,
	
	@GroupTypeT153 VARCHAR(MAX)= '',-- SB
	@SettingStatus TINYINT = 0,

	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20241107@Eden	
	Task: Validate when Super/Master create direct member
	DB: DBCUST.CustDB
	
	Revisions:
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 

	Param's Explanation: 
		- @GroupTypeT153 :
			[
				{"SportType": "9914","BetType": "915","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9914","BetType": "917","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9913","BetType": "917","IsLive": "1"	,"SuperPT": "38"},
				{"SportType": "9915","BetType": "918","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9913","BetType": "915","IsLive": "1"	,"SuperPT": "38"},
				{"SportType": "9913","BetType": "916","IsLive": "1"	,"SuperPT": "38"},
				{"SportType": "9914","BetType": "916","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9906","BetType": "4001","IsLive": "0","SuperPT": "38"},
				{"SportType": "9909","BetType": "3700","IsLive": "0","SuperPT": "38"},
				{"SportType": "9911","BetType": "2400","IsLive": "0","SuperPT": "38"},
				{"SportType": "9918","BetType": "4601","IsLive": "0","SuperPT": "38"}

			]
*/	
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				AgentPT			SMALLMONEY,
				SuperPT 		SMALLMONEY,
				MasterPT		SMALLMONEY,
				Child_DisplayOrder	INT
				)
	CREATE TABLE #ProductSettingDetail_PTCheck(
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],		
		[MaxPT]	[smallmoney],
		Child_DisplayOrder	INT
	)
	
	DECLARE @xml XML,
			@ErrType XML
	
	IF ISNULL(@GroupTypeT153,'') <> ''
	BEGIN
		INSERT INTO @tblPT(
			SportType,
			BetType, 
			IsLive,
			SuperPT,
			MasterPT
			)
		SELECT SportType,BetType,IsLive,SuperPT,MasterPT
		FROM OPENJSON(@GroupTypeT153) WITH (
				SportType SMALLINT  '$.SportType'
				,BetType SMALLINT  '$.BetType'
				,IsLive BIT  '$.IsLive'
				,SuperPT SMALLMONEY  '$.SuperPT'
				,MasterPT SMALLMONEY  '$.MasterPT'
			)		
	END	
	
	INSERT INTO #ProductSettingDetail_PTCheck(SportType,BetType,IsLive,ProductID,SettingLevel,MaxPT,Child_DisplayOrder)
	SELECT SportType,BetType,IsLive,RealProductID,SettingLevel,MaxPT,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)
	WHERE GroupType = 153
	
	BEGIN
		--check pt > 0 
		;WITH T AS (
			SELECT t.SportType, t.BetType, t.IsLive, SettingLevel,ps.ProductID
			FROM @tblPT t
				INNER JOIN #ProductSettingDetail_PTCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																	AND t.BetType = ps.bettype 
																	AND t.IsLive = ps.IsLive
			WHERE (t.SuperPT < 0 				
					OR t.SuperPT > ps.MaxPT
					OR t.MasterPT < 0 				
					OR t.MasterPT > ps.MaxPT
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
		
		IF @UplineRoleID = 4
		BEGIN
			--check n4<=s1<=s4<=l4
			;WITH T AS (
				SELECT b.SportType, b.BetType, b.IsLive,co.MinPT
					,CASE WHEN co.SuperPT > co.MaxPT  THEN co.MaxPT ELSE co.SuperPT END	AS MaxPT
				FROM @tblPT b
					INNER JOIN CustPTSetting3rd_Agent AS co WITH (NOLOCK) ON co.sporttype=b.sporttype 
																AND co.bettype = b.bettype 
																AND b.isLive = co.IsLive														
				WHERE co.custid = @srecommend 
					AND (b.SuperPT < co.MinPT OR b.SuperPT > co.MaxPT OR b.SuperPT > co.SuperPT)	
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
		END
		ELSE IF @UplineRoleID = 3
		BEGIN
			--check n3<=m1<=l3
			;WITH T AS (
				SELECT b.SportType, b.BetType, b.IsLive,co.MinPT,co.MaxPT	
				FROM @tblPT b
					INNER JOIN CustPTSetting3rd_Agent AS co WITH (NOLOCK) ON co.sporttype=b.sporttype 
																AND co.bettype = b.bettype 
																AND b.isLive = co.IsLive														
				WHERE co.custid = @mrecommend 
					AND (b.MasterPT < co.MinPT OR b.MasterPT > co.MaxPT)	
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
	
			--check m1<=min(m3,m4)
			SELECT @ErrType = ''

			;WITH T AS (
				SELECT b.SportType, b.BetType, b.IsLive, 
					CASE WHEN cs.MasterPT < scs.MasterPT THEN cs.MasterPT ELSE scs.MasterPT END MaxPT	
				FROM @tblPT b
					INNER JOIN CustPTSetting3rd_Agent AS cs WITH (NOLOCK) ON cs.custid = @mrecommend 
																AND cs.sporttype=b.sporttype 
																AND cs.bettype = b.bettype 
																AND cs.isLive = b.isLive
					INNER JOIN CustPTSetting3rd_Agent AS scs WITH (NOLOCK) ON scs.custid = @srecommend
																AND scs.sporttype=b.sporttype 
																AND scs.bettype = b.bettype 
																AND scs.isLive = b.isLive														
				WHERE b.MasterPT > CASE WHEN cs.MasterPT < scs.MasterPT THEN cs.MasterPT ELSE scs.MasterPT END		
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
				SELECT @ErrMsg = '<Root MsgID="20009" Msg="Wrong Master position taking.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 63
						, @ErrCode = 603	
				RETURN
			END  
		END
	END

	DROP TABLE #ProductSettingDetail_PTCheck
END
GO