/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE Acc_CustSetting_SuperMinPTCheck
	@custid		INT,
	@PT			VARCHAR(MAX),	
	@ErrCode	INT = 0 OUTPUT,
	@MsgType	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(4000)='' OUTPUT
AS
/*
	Created: Elodie
	Date: 2020-06-26
	Task: Check PT when update MinPT on super
	DB: DBCUST/CustDB
		
	Revisions:
        - 20200626@Elodie: Initial SP [Redmine:#135363]
		- 20200914@Eden: Minimize UM Time - Lock updating customer settings [#136464]
		- 20201022@Elodie: Change datatype of PT from tinyint to smallmoney  [Redmine: #143764]

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
				SuperMinPT	SMALLMONEY
				)
	DECLARE @tmpPTGroup TABLE(custid INT
							,sporttype INT
							,bettype INT
							,islive BIT
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
	
	--Exclude Update for Sport is having UM
	DELETE t
	FROM @tblPT t
		INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType IN(1,18)
		AND u.FunctionType = 1 --Edit Customer

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
				SELECT t.SportType, t.BetType, t.IsLive
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
				SELECT s.SportType, s.BetType, s.IsLive
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
END	 