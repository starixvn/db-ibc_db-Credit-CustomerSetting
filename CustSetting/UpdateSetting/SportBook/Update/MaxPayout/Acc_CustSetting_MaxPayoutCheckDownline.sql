/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="vnteam" isFunction="0" isNested="1"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_MaxPayoutCheckDownline] 
	  @CustID		INT
	, @MaxPayoutLimit VARCHAR(MAX)
	, @Language VARCHAR(2)= 'E'
	, @ErrCode		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20210518@Winfred
	Task : Check Downline Customer's Parlay Max Payout
	DB: DBCUST/CustDB
	Original:

	Revision: 
		- 20210518@Winfred: Initial SP [RedmineID:#154104]	

	Param's Explanation:
		• @@MaxPayoutLimit:
		'<ROOT>				<MaxPayoutLimit 						SportType="1" 						BetType="1" 						SingleMatchParlay="3000" 						Combo2="40000" 						Combo35="6000000"						ComboOver6="1000000"				/>		</ROOT>'

	*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @AgentID		INT
		, @MasterID			INT
		, @SuperID			INT
		, @RoleID			INT

	DECLARE @xml		XML ,@Currency INT,@Bettype NVARCHAR(50),@Columns NVARCHAR(100), @isConfirm BIT = 0
	DECLARE @NewMaxPayoutTbl TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, SingleMatchParlay	MONEY
		, Combo2			MONEY
		, Combo35			MONEY
		, ComboOver6		MONEY
		)
	IF @MaxPayoutLimit IS NULL
		OR @MaxPayoutLimit = ''
		RETURN

	SELECT	@ErrCode	= 0 ,@ErrMsg		= ''

	--Parse XML data
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @MaxPayoutLimit

	INSERT @NewMaxPayoutTbl(SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
	SELECT SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6
	FROM OPENXML(@iDoc, '/ROOT/MaxPayoutLimit', 1) WITH (
				SportType		SMALLINT
				, BetType		SMALLINT
				, SingleMatchParlay	MONEY
				, Combo2			MONEY
				, Combo35			MONEY
				, ComboOver6		MONEY
			)

	EXEC sp_xml_removedocument @iDoc

	--Get currency of member
	SELECT @Currency = ci.currency
		, @AgentID = recommend
		, @MasterID = mrecommend
		, @SuperID	= srecommend
		, @RoleID = RoleID
	FROM dbo.custInfo ci WITH(NOLOCK)
	WHERE ci.custid=@CustID
	
	IF @RoleID = 2 AND EXISTS(SELECT TOP 1 1  
					FROM dbo.CustMaxPayoutSetting_Member cs WITH (NOLOCK)
					INNER JOIN @NewMaxPayoutTbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
					WHERE cs.custid IN (SELECT Custid from custInfo WITH(NOLOCK) WHERE recommend = @AgentID AND roleid  = 1 )
					AND  ((s.SingleMatchParlay < cs.SingleMatchParlay AND s.SingleMatchParlay > 0)
							OR (s.Combo2 < cs.Combo2 AND s.Combo2 > 0)
							OR (s.Combo35 < cs.Combo35 AND s.Combo35 > 0)
							OR (s.ComboOver6 < cs.ComboOver6 AND s.ComboOver6 > 0)))
	BEGIN
		SET @isConfirm = 1
	END	
	ELSE IF @RoleID = 3  AND EXISTS(SELECT TOP 1 1  
									FROM dbo.CustMaxPayoutSetting_Member cs WITH (NOLOCK)
									INNER JOIN @NewMaxPayoutTbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
									WHERE cs.custid IN (SELECT Custid from custInfo WITH(NOLOCK) WHERE mrecommend = @MasterID AND roleid  = 1 )
									AND  ((s.SingleMatchParlay < cs.SingleMatchParlay AND s.SingleMatchParlay > 0)
										OR (s.Combo2 < cs.Combo2 AND s.Combo2 > 0)
										OR (s.Combo35 < cs.Combo35 AND s.Combo35 > 0)
										OR (s.ComboOver6 < cs.ComboOver6 AND s.ComboOver6 > 0))
									UNION ALL
									SELECT TOP 1 1  
									FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
									INNER JOIN @NewMaxPayoutTbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
									WHERE cs.custid IN (SELECT Custid from custInfo WITH(NOLOCK) WHERE mrecommend = @MasterID AND roleid  = 2 )
									AND  ((s.SingleMatchParlay < cs.SingleMatchParlay AND s.SingleMatchParlay > 0)
										OR (s.Combo2 < cs.Combo2 AND s.Combo2 > 0)
										OR (s.Combo35 < cs.Combo35 AND s.Combo35 > 0)
										OR (s.ComboOver6 < cs.ComboOver6 AND s.ComboOver6 > 0)
										OR (cs.SingleMatchParlay = 0 AND S.SingleMatchParlay > 0) 
										OR (cs.Combo2 = 0 AND S.Combo2 > 0) 
										OR (cs.Combo35 = 0 AND S.Combo35 > 0) 
										OR (cs.ComboOver6 = 0 AND S.ComboOver6 > 0) )
					)
	BEGIN
		SET @isConfirm = 1
	END
	ELSE IF @RoleID = 4 AND EXISTS(SELECT TOP 1 1  
									FROM dbo.CustMaxPayoutSetting_Member cs WITH (NOLOCK)
									INNER JOIN @NewMaxPayoutTbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
									WHERE cs.custid IN (SELECT Custid from custInfo WITH(NOLOCK) WHERE srecommend = @SuperID AND roleid  = 1 )
									AND  ((s.SingleMatchParlay < cs.SingleMatchParlay AND s.SingleMatchParlay > 0)
										OR (s.Combo2 < cs.Combo2 AND s.Combo2 > 0)
										OR (s.Combo35 < cs.Combo35 AND s.Combo35 > 0)
										OR (s.ComboOver6 < cs.ComboOver6 AND s.ComboOver6 > 0))
									UNION 
									SELECT TOP 1 1  
									FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
									INNER JOIN @NewMaxPayoutTbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
									WHERE cs.custid IN (SELECT Custid from custInfo WITH(NOLOCK) WHERE srecommend = @SuperID AND roleid in(2 ,3) )
									AND  ((s.SingleMatchParlay < cs.SingleMatchParlay AND s.SingleMatchParlay > 0)
										OR (s.Combo2 < cs.Combo2 AND s.Combo2 > 0)
										OR (s.Combo35 < cs.Combo35 AND s.Combo35 > 0)
										OR (s.ComboOver6 < cs.ComboOver6 AND s.ComboOver6 > 0)
										OR (cs.SingleMatchParlay = 0 AND S.SingleMatchParlay > 0) 
										OR (cs.Combo2 = 0 AND S.Combo2 > 0) 
										OR (cs.Combo35 = 0 AND S.Combo35 > 0) 
										OR (cs.ComboOver6 = 0 AND S.ComboOver6 > 0) )
					)
	BEGIN
		SET @isConfirm = 1
	END

	IF @isConfirm = 1	
	BEGIN	
		SET	@ErrMsg = CASE @Language 
							WHEN 'E' THEN N'Submitting this setting will override some downlines'' setting which are currently higher than this new value. Do you want to proceed?'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10058,@Language)
						END
		SET @ErrCode = 10058	
		
		RETURN
	END	
	
END
GO
