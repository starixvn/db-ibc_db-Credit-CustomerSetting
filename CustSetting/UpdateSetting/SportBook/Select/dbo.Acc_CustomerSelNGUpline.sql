ALTER PROCEDURE [dbo].[Acc_CustomerSelNGUpline]
	@username		VARCHAR(30),
	@userid			INT,							--Admin ID
	@minbet			MONEY			= 0 OUTPUT,
	@maxbet			MONEY			= 0 OUTPUT,
	@maxperball		MONEY			= 0 OUTPUT,
	@maxpermatch	MONEY			= 0 OUTPUT,
	@isEnable		BIT				= 1 OUTPUT,
	@ErrCode		INT				= 0 OUTPUT,
	@ErrMsg			VARCHAR(5000)	= '' OUTPUT
AS

/*
	Created: 20111117@Sophia
	Task: Check upline enable Number game, select upline Minbet, Maxbet, Maxperbll, Maxpermatch 
	DB: DBCUST.CustDB

	Revisions:
		- Dom.Cao@2012-07-20: Just allow Enable NG in credit site
		- 20130121@Dan: change linked server DB03 to DBPOLICY
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Param's Explanation:
		- @isEnable = 1 : unlock checkbox Enable
		- @isEnable = 0 : lock checkbox Enable
 
*/  

SET NOCOUNT ON

DECLARE @CustID int, @RoleID tinyint, @UplCustid int

SELECT @ErrCode = 0 , @ErrMsg = ''
SELECT	@CustID = 0, @RoleID = 0, @UplCustid= 0, @isEnable = 1, @minbet = 0, @maxbet = 0, @maxperball= 0, @maxpermatch = 0

--Check permission  
EXEC DBPOLICY.bodb02.dbo.Acc_Con_CheckPermission @custid=@UserID, @funcname='[EnableBetSettingNG]',@ErrCode=@ErrCode OUTPUT,@ErrMsg=@ErrMsg OUTPUT
IF @ErrCode <> 0
	RETURN
--end
 
SELECT	@CustID = CustID, @RoleID = RoleID, 
		@UplCustid = CASE WHEN RoleID = 1 THEN recommend 
							ELSE CASE WHEN RoleID = 2 THEN mrecommend 
								      ELSE CASE WHEN RoleID IN (3,4) THEN srecommend ELSE 0 END 
								END 
					  END 
FROM	custInfo WITH (NOLOCK)
WHERE	Username = @Username


---check valid username
IF ISNULL(@CustID,0) = 0 OR ISNULL(@UplCustid,0) = 0 OR @Roleid NOT IN (1,2,3,4)
BEGIN 
	SELECT @ErrCode = 100, @ErrMsg = 'Invalid Username.'
	RETURN
END

--check is deposite
IF(EXISTS (SELECT TOP 1 1 FROM customer c  WITH (NOLOCK)
			INNER JOIN [Site] s  WITH (NOLOCK) ON s.[site] = c.[site]
           WHERE c.custid = @UplCustid AND s.isLicensee=1))
BEGIN
	SELECT @ErrCode = 100, @ErrMsg = 'The settings of deposit customers is not enabled for editing from here!'
	RETURN
END


---check upline enabled number game 
IF EXISTS (	SELECT  TOP 1 1 
			FROM	custInfo WITH (NOLOCK)
			WHERE	CustID = @UplCustid AND @RoleID < 4 AND disablenumber = 1)	 
BEGIN 
	SELECT	@isEnable = 0 , 
			@ErrCode = 101, @ErrMsg = 'The upline is not enable number game.'
	RETURN
END


IF @roleid < 4
BEGIN 
--check upline condition

	SELECT		@MaxPerMatch = isnull(Min(case when cs.MaxPerMatch161 = 0 then NULL else cs.MaxPerMatch161 end),0),
				@Maxperball = isnull(Min(case when cs.MaxPerBall161 = 0 then NULL else cs.MaxPerBall161 end),0)
	FROM		custinfo cs WITH (NOLOCK) 
	INNER JOIN	custinfo as ci WITH (NOLOCK) 
			ON	(cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	WHERE		ci.custid = @custid


	SELECT 	@MinBet = ISNULL(Max(case when cs.MinBet = 0 then NULL else cs.MinBet end), 0), 
			@MaxBet = ISNULL(Min(case when cs.MaxBet = 0 then NULL else cs.MaxBet end),0)
	FROM 	custsetting3rd as cs WITH (NOLOCK)
	INNER JOIN	custinfo as ci WITH (NOLOCK) 
			ON (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
				and cs.sporttype=161
	WHERE		ci.custid = @CustID
END


	 
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelNGUpline] TO [bodbAdminNet]
GO 
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelNGUpline] TO [vnteam]
GO