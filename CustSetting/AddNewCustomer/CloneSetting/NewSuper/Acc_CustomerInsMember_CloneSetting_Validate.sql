/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CloneSetting_Validate]
(
	@UserName VARCHAR(30)
	,@Site NVARCHAR(50)
	,@Credit MONEY	
	,@ExistingCustid INT
	,@Creator INT	
	,@Language VARCHAR(2)= 'E'
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(4000) = '' OUTPUT
)
AS
/*  
 Created by: Helen  
 Date:20240704
 Original: 
 Task: Add new super from existing super [Redmine:#5456]
 DB: DBCUST/CustDB  
  
 Revisions:  
	- 20240704@Helen: Revise code for scaleout dbcust - [Redmine:#206823]
	- 20241216@Johnson: Change to use ProductSettingProfile [RedmineID: #212684]	
	- 20251103@Dave: Adjust Live Casino PT & Commission [Redmine: #242260]
 Explanation's Param:  
	- @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
	  
	- @ErrMsg: Error description.	
	- @SettingStatus: 0: Pro, 1: UAT
  
*/
BEGIN
	SET NOCOUNT ON
	DECLARE  @source_SiteLabel VARCHAR(50),@_Site VARCHAR(10)

	-- Check role of existing super and get source site
	DECLARE @existingUsername VARCHAR(30),@roleid tinyint, @Enabled BIT, @currency INT
		
	SELECT @existingUsername =  ISNULL(ci.username,''), @roleid = ISNULL(ci.roleid,0), @Enabled = ISNULL(ci.Enabled, 0)
		, @currency = ci.currency, @source_SiteLabel=s.SiteLabel, @_Site = c.site
	FROM dbo.CustInfo ci WITH(NOLOCK) 
		INNER JOIN Customer c WITH(NOLOCK) ON ci.custid=c.custid
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE ci.custid = @ExistingCustid
	
	-------------------BLOCK ADDING NEW USE UMCONFIG----------------------------
	DECLARE @SiteID int, @SiteLabel varchar(50) 

	SELECT @SiteID = siteid, @SiteLabel=SiteLabel
	FROM site WITH(NOLOCK) 
	WHERE site = @site

	DECLARE @FromTime VARCHAR(30), @ToTime VARCHAR(30)
	CREATE TABLE #UMConfig(SportType SMALLINT,SiteID INT, Currency INT ,BeginTime smalldatetime,EndTime smalldatetime)
		
	INSERT INTO #UMConfig(SportType,SiteID,Currency,BeginTime,EndTime)	
	SELECT t.SportType,t.SiteID,t.Currency,t.BeginTime,t.EndTime
	FROM UMConfig t WITH(NOLOCK)
	WHERE CONVERT(SMALLDATETIME,GETDATE()) BETWEEN t.BeginTime AND t.EndTime
		AND t.Currency IN (0,@currency)
		AND t.SiteID IN (0,@siteid)
		AND (t.FunctionType = 2 
			 OR (t.FunctionType = 1 AND t.LockAddingNew = 1)
			 )
		AND t.SuperID = 0
	
	--Delete Non-offered Products
	DELETE ft
	FROM #UMConfig ft
		INNER JOIN SportNonOfferedSiteCurrency nof WITH(NOLOCK)
			ON ft.SportType = nof.SportType
			AND nof.siteID IN (ft.SiteID, 0)
			AND nof.Currency IN (ft.Currency, 0)
	WHERE NOT EXISTS(	SELECT 1 
						FROM ProductSettingProfile p WITH(NOLOCK) 
						WHERE nof.SportType = p.SportType 
							AND nof.BetType <> p.BetType 
							AND p.SettingStatus = 0 
					)

	SELECT @FromTime = CONVERT(VARCHAR,MIN(dateadd(HH,12,t.BeginTime)),103) + ' ' + LTRIM(LEFT(CONVERT(VARCHAR, MIN(dateadd(HH,12,t.BeginTime)),8),5)),
		  @ToTime = CONVERT(VARCHAR,MAX(dateadd(HH,12,t.EndTime)),103) + ' ' + LTRIM(LEFT(CONVERT(VARCHAR, MAX(dateadd(HH,12,t.EndTime)),8),5))
	FROM #UMConfig t

	IF @FromTime IS NOT NULL AND @ToTime IS NOT NULL
	BEGIN
		SELECT @ErrCode = 90016
			 , @ErrMsg =   REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](90016,@Language),'<FromTime>',@FromTime),'<ToTime>',@ToTime)

		RETURN
	END
	------------------------------END----------------------------------------
	IF @credit <0
	BEGIN
		SELECT  @ErrCode = 2
		SELECT @ErrMsg = 	CASE @Language 
								WHEN 'E' THEN 'Credits must be positive.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](70025,@Language)
							END
		RETURN
	END

	--Check Inactive site:
	IF EXISTS (SELECT 1 FROM Site WITH (NOLOCK) WHERE site=@_Site AND isActive=0)
	BEGIN
		SELECT	@ErrMsg='Cannot copy Super because Source super''s site is inactive',
				@ErrCode=98
		RETURN

	END
	
	-- For Myanmar Odds
	DECLARE @IsMyanmarOdds_destination BIT = 0
	DECLARE @IsMyanmarOdds_source BIT = 0
	
	SET @IsMyanmarOdds_destination = dbo.fn_IsMyanmarOddsBySite(@Site)
	
	SET @IsMyanmarOdds_source = dbo.fn_IsMyanmarOdds (@ExistingCustid)
		
	IF @IsMyanmarOdds_destination <> @IsMyanmarOdds_source and @IsMyanmarOdds_source = 1
	BEGIN
		SELECT @ErrMsg = 'Cannot copy Super from Myanmar Odds site(s) to ' + @Site +'.',@ErrCode = 200								
		RETURN		
	END	

	IF @IsMyanmarOdds_destination <> @IsMyanmarOdds_source and @IsMyanmarOdds_destination = 1
	BEGIN
		SELECT @ErrMsg = 'Cannot copy Super from ' + @_Site +' to Myanmar Odds site(s).',@ErrCode = 201								
		RETURN		
	END

	--Check cross-site:
	IF ( @source_SiteLabel IN ('789y','MBC','IBC','777') OR @SiteLabel IN ('789y','MBC','IBC','777') )
		AND @SiteLabel<>@source_SiteLabel
	BEGIN
		SELECT	@ErrMsg='Cannot copy Super from ' + @_Site + ' (' + @source_SiteLabel + ') to ' + @Site + ' (' + @SiteLabel + ')',
				@ErrCode=99
		RETURN
	END	
	
	IF (@_Site = 'INDO' OR @Site = 'INDO') AND @_Site <> @Site
	BEGIN
		SELECT	@ErrMsg='Cannot copy Super from ' + @_Site + ' (' + @source_SiteLabel + ') to ' + @Site + ' (' + @SiteLabel + ')',
				@ErrCode=100
		RETURN
	END	

	IF @SiteLabel  = '789y'	
	BEGIN
		IF EXISTS(SELECT 1 FROM Acc_SuperPrefix WITH(NOLOCK)
			WHERE GroupName IN ('ACCUT','ACCYEN789','ACCYEN889','ACCTEST')
				AND Prefix = LEFT(@username,2)
				AND AllowNewSuper = 0
			)
		BEGIN
			SELECT @ErrMsg =  'The selected username prefix is not allowed for new supers anymore.',
				@ErrCode = 205
			RETURN		
		END	
	END
	
	--Not allow to create a IMBC customer from MBC customer and and vice versa
	IF (@_Site = 'IMBC' OR @Site = 'IMBC') AND @_Site <> @Site
	BEGIN
		SELECT @ErrMsg = 'Not allow to copy IMBC super setting to others and vice versa!',@ErrCode = 204								
		RETURN	
	END
	
	
	IF @roleid <> 4
	BEGIN		
		 SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Invalid user' + ' (' + @existingUsername + ')!'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language) + ' (' + @existingUsername + ')!'
								END, 
						@ErrCode = 202
		RETURN		
	END		 		
	
	IF @Enabled = 0
	BEGIN		
		 SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'This account was disabled!' + ' (' + @existingUsername + ')'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60020,@Language) + ' (' + @existingUsername + ')'
								END, 
						@ErrCode = 203
		RETURN		
	END		 
	
	DROP TABLE #UMConfig

END
GO


