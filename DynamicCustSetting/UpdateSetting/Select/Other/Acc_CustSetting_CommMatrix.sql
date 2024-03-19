/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="vnteam" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[Acc_CustSetting_CommMatrix]   
   @ProductID TINYINT = NULL,
   @UserName VARCHAR(30) = '',
   @SettingStatus TINYINT = 0
AS  
/*  
	Created: 20150518@Dominic  
	Task : Get Comm Matrix
	DB:  DBCUST/CustDB   
	Original:  
  
	Revision:
		- 20160219@Dominic: Implement charge commission #49689
		- 20170426@Elodie: Implementing Ticket Commission Plugin - [Redmine: #75221]
		- 20200615@Elodie: Implement new setting type 19 [Redmine: #135363]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]

	Param's Explanation: 
		- @SettingStatus: 0: Pro, 1: UAT 		
   
 */  
BEGIN  
	CREATE TABLE #SportBettypeFilter (SportType SMALLINT, Bettype SMALLINT)

	INSERT INTO #SportBettypeFilter (SportType, Bettype)
	SELECT SportType, Bettype
	FROM (
			SELECT SportType, Bettype
			FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,3,@SettingStatus) -- comm
			UNION
			SELECT SportType, Bettype
			FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,5,@SettingStatus)  
			UNION
			SELECT SportType, Bettype
			FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,14,@SettingStatus) 
			UNION
			SELECT SportType, Bettype
			FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,19,@SettingStatus)
			) tmp
	
	SET NOCOUNT ON
	DECLARE @CustID INT
		, @RoleID INT
		, @SRecommend INT
		, @MRecommend INT
		, @Recommend INT

	SELECT @CustID = CustID
		, @RoleID = RoleID
		, @SRecommend = SRecommend
		, @MRecommend = MRecommend
		, @Recommend = Recommend
	FROM Custinfo WITH (NOLOCK)
	WHERE UserName = @UserName	
	
	
	DECLARE @CommMatrix TABLE (
		[RoleID] [TINYINT],
		[SportType] [smallint],
		[BetType] [smallint],
		[Discount] Decimal(9,8)
	)	
	
	
	INSERT @CommMatrix
	SELECT
		4
	  ,comm.[SportType]
	  ,comm.[BetType]
	  ,comm.Discount
	FROM [dbo].CustDiscount3rd_Agent comm WITH(NOLOCK)
	INNER JOIN #SportBettypeFilter pdt 
				ON pdt.SportType = comm.sporttype
					AND pdt.BetType = comm.bettype
	WHERE CustID = @SRecommend
	
	IF @RoleID IN (3, 2, 1)
	BEGIN
		INSERT @CommMatrix
		SELECT
			3
		  ,comm.[SportType]
		  ,comm.[BetType]
		  ,comm.Discount
		FROM [dbo].CustDiscount3rd_Agent comm WITH(NOLOCK)
		INNER JOIN #SportBettypeFilter pdt 
				ON pdt.SportType = comm.sporttype
					AND pdt.BetType = comm.bettype
		WHERE CustID = @MRecommend
		
		IF @RoleID IN (2, 1)
		BEGIN
			INSERT @CommMatrix
			SELECT
				2
			  ,comm.[SportType]
			  ,comm.[BetType]
			  ,comm.Discount
			FROM [dbo].CustDiscount3rd_Agent comm WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter pdt 
				ON pdt.SportType = comm.sporttype
					AND pdt.BetType = comm.bettype
			WHERE CustID = @Recommend
			
			IF @RoleID = 1
			BEGIN
				INSERT @CommMatrix
				SELECT
					1
				  ,comm.[SportType]
				  ,comm.[BetType]
				  ,comm.PlayerDiscount
				FROM [dbo].CustDiscount3rd_Member comm WITH(NOLOCK)
				INNER JOIN #SportBettypeFilter pdt 
					ON pdt.SportType = comm.sporttype
						AND pdt.BetType = comm.bettype
				WHERE CustID = @CustID
			END
		END
	END
	
	--Return Comm
	SELECT [RoleID]
		, [SportType]
		, [BetType]
		, Discount
	FROM @CommMatrix comm
	ORDER BY [SportType]
		, [BetType] , [RoleID] DESC

	DROP TABLE #SportBettypeFilter
END  
GO