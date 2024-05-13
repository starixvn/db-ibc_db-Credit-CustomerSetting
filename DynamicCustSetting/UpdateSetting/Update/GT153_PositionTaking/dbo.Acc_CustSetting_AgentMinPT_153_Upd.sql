 /*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentMinPT_153_Upd]
	@custid				INT,
	@PT					VARCHAR(MAX),
	@SubAccID			INT = 0,
	@UserID				INT = 0,       
    @IP					VARCHAR(15)='',     
    @IsCountPT			BIT = 1,
    @ErrCode			INT = 0 OUTPUT,
    @MsgType			INT = 0 OUTPUT,
    @ErrMsg				NVARCHAR(MAX) = '' OUTPUT, 
	@SettingStatus		TINYINT = 0,
	@GroupType			SMALLINT = 153,
	@GroupID			TINYINT = 1 -- default SB
 AS
/*
	Created: 20231101@Eden
	Task : Update Min pt on Agent
	DB: DBCUST/CustDB
	Original:

	Revision:
	- 20231101@Eden: DCS Sportsbook Credit[redmine: #193083]
	- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960] 
		
	Parameter's Explanation:
		@PT = <ROOT>
				<PT SportType="9913" BetType="916" IsLive="1" MinPT="8"/>
				<PT SportType="9914" BetType="915" IsLive="0" MinPT="8"/>
			</ROOT>
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @roleid			TINYINT			
			,@startRun		DATETIME
			,@endRun		DATETIME
			,@duration		INT			
			,@logSPData		VARCHAR(5000)
			,@logSPData_Old	VARCHAR(5000)
			,@xml			XML
    
	 SET @startRun = GETDATE()
			
	---------------------------
	-- ***Check Downline Belonging***
	EXEC dbo.Age_CustomerSelCheckBelongingByCustID 
		@SessionCustID	= @Userid 
		,@Custid		= @custid		
		,@roleid		= @roleid OUTPUT
	IF (@roleid = 0) RETURN
	
	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
		@custid		= @custid
		,@ErrCode	= @ErrCode OUTPUT
		,@ErrMsg	= @ErrMsg OUTPUT
		
	IF @ErrCode > 0	
	BEGIN
		SELECT @MsgType = 101
		RETURN
	END
	--end
	
	---- Checking total downlines before UPDATEs 
    EXEC dbo.Acc_CustomerSelCheckAllowedDownlines    
		@custid			= @custid
        ,@roleid		= 2
        ,@isExecRep		= 1
        ,@isUpdatePT	= 1
        ,@Sporttype		= 1
        ,@Language		= 'E'
        ,@ErrMsg		= @ErrMsg OUTPUT
        ,@ErrCode		= @ErrCode OUTPUT
        
    IF @ErrCode > 0	
	BEGIN
		SELECT @MsgType = 101
		RETURN
	END 
    ----------		
    
    IF @PT = '' RETURN 
    
    DECLARE @username VARCHAR(40), @srecommend INT, @mrecommend INT
    
    SELECT @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend         
	FROM custinfo with (NOLOCK)         
	WHERE CustID = @CustID 
	
	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,							
				AgentMinPT		SMALLMONEY,
				SettingLevel TINYINT,
				ProductID TINYINT,
				Child_DisplayOrder TINYINT
				)	
				
	-- For read xml
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				AgentMinPT
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

	CREATE TABLE #ProductSettingDetail_AMinUpd(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		Child_DisplayOrder TINYINT,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_AMinUpd(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,Child_DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @tblPT t
		INNER JOIN #ProductSettingDetail_AMinUpd ps 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer
	
	IF NOT EXISTS( SELECT 1 FROM @tblPT)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

		RETURN
	END

	UPDATE tmp
	SET tmp.SettingLevel = psd.SettingLevel,
		tmp.ProductID = psd.ProductID,
		tmp.Child_DisplayOrder = psd.Child_DisplayOrder
	FROM @tblPT tmp
		INNER JOIN #ProductSettingDetail_AMinUpd psd
			ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType
					AND psd.IsLive = tmp.IsLive


	-- check Limit Daily PT Update
	DECLARE  @isLimit BIT = 0 ,@isCancel BIT = 0, @LastUpdated DATE
	IF @IsCountPT = 1
	BEGIN
		EXEC dbo.Age_LimitPTDailyCheck    
			 @custid		= @custid
			,@Actorid		= @UserID
			,@UpdatePT		= @PT
			,@LastUpdated	= @LastUpdated OUTPUT
			,@isLimit		= @isLimit OUTPUT
			,@isCancel		= @isCancel OUTPUT
			,@SettingStatus = @SettingStatus
		IF @isCancel > 0	
		BEGIN
			
			SELECT @ErrMsg = '<Root MsgID="10078" Msg="'+ CAST (@LastUpdated AS VARCHAR(10)) +'"> </Root>'
                    , @ErrCode = 10078
                    , @MsgType = 6   
				RETURN
		END
	END 

    -- Log old data
	SET @xml = (
		SELECT  @custid                         AS '@CustID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
                @IP                             AS '@IP',
                (
					SELECT  @GroupID									AS '@GroupID',
							t.ProductID									AS '@ProductID',
							cs.sporttype									AS '@SportType',
                            cs.bettype										AS '@BetType',
                            cs.isLive										AS '@IsLive',
						    dbo.f_FomatNumericToChar(cs.MinPT			/100.0)	AS '@AgentMinPT',
							t.SettingLevel									AS '@SettingLevel'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					ORDER BY t.Child_DisplayOrder
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('ROOT'), 
        TYPE
	)
	
    SET @logSPData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	
	IF NOT EXISTS (SELECT 1 FROM @tblPT WHERE SportType IN (211,9906)) 
		AND NOT EXISTS (SELECT TOP 1 1
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
					WHERE custid = @custid
						AND cs.MinPT <> t.AgentMinPT			
					)
	BEGIN
		RETURN
	END
	
	EXEC Acc_CustSetting_AgentMinPT_153_Check
		@custid		= @custid,
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,
		@PT			= @PT,
		@ErrCode	= @ErrCode OUTPUT,
		@MsgType	= @MsgType OUTPUT,
		@ErrMsg		= @ErrMsg OUTPUT,
		@GroupID = @GroupID,
		@GroupType = @GroupType,
		@SettingStatus = @SettingStatus
	
	IF @ErrCode > 0
		RETURN
	
	 --update data change into db
	 UPDATE cs
	SET cs.MinPT = b.AgentMinPT		
	FROM CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN @tblPT b ON cs.Sporttype = b.SportType
								AND cs.bettype = b.BetType
								AND cs.isLive = b.IsLive								
	WHERE cs.custid = @custid
		AND cs.MinPT <> b.AgentMinPT					
	
	EXEC dbo.Acc_DynamicCustSetting3rd_04 
		@AgentID = @custid
		,@MasterID = @mrecommend
		,@SuperID = @srecommend
		,@RoleID = 2
		,@SportBettypeXML = @PT

	-- The minimum position taking value of agent was modified by agent's upline
	EXEC dbo.Age_MessageNoticeUpd_Wrapper @custID = @custid, @userID = @UserID 

    -- Log new updated data
	SET @xml = (
		SELECT  @custid                         AS '@CustID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
                @IP                             AS '@IP',
                (
					SELECT  @GroupID									AS '@GroupID',
							t.ProductID									AS '@ProductID',
							cs.sporttype									AS '@SportType',
                            cs.bettype										AS '@BetType',
                            cs.isLive										AS '@IsLive',
						    dbo.f_FomatNumericToChar(cs.MinPT			/100.0)	AS '@AgentMinPT',
							t.SettingLevel									AS '@SettingLevel'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					ORDER BY t.Child_DisplayOrder
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('ROOT'), 
        TYPE
	)
	
	SET @logSPData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @logSpData_Old = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData_Old)
	SELECT @logSpData = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData)
	
	-- end write log
	SET @endRun		= GETDATE()  
	SET @duration	= DATEDIFF(MILLISECOND, @startRun, @endRun) 

	DECLARE @ActionID INT

	SELECT @ActionID = CASE 
					WHEN @GroupID = 1 THEN 522 -- SB
								ELSE 534 -- 3rdProducts
							END
						
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = @ActionID,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @logSPData_Old,
		@duration = @duration

	DROP TABLE #ProductSettingDetail_AMinUpd

	-- Update Limitation PT
	IF @isLimit > 0
	BEGIN
		EXEC dbo.Age_LimitPTDailyUpd    
			 @custid		= @custid
			,@Actorid		= @UserID
			,@UpdatePT		= @PT
			,@ErrCode		= @ErrCode OUTPUT
			,@ErrMsg		= @ErrMsg OUTPUT
		IF @ErrCode > 0
		RETURN
	END 
END
GO
