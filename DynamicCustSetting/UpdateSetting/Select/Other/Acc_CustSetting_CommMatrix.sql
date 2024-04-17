/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="vnteam" isFunction="0" isNested="0"></info>*/

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
		- 20231019@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083] 

	Param's Explanation: 
		- @SettingStatus: 0: Pro, 1: UAT 		
   
 */  

BEGIN  
	CREATE TABLE #SportBettypeFilter (SportType SMALLINT, Bettype SMALLINT, Child_DisplayOrder INT)

	INSERT INTO #SportBettypeFilter (SportType, Bettype, Child_DisplayOrder)
	SELECT SportType, Bettype, Child_DisplayOrder
	FROM (
			SELECT SportType, Bettype, Child_DisplayOrder
			FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,3,@SettingStatus) -- comm
			UNION
			SELECT SportType, Bettype, Child_DisplayOrder
			FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,5,@SettingStatus)  
			UNION
			SELECT SportType, Bettype, Child_DisplayOrder
			FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,14,@SettingStatus) 
			UNION
			SELECT SportType, Bettype, Child_DisplayOrder
			FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,19,@SettingStatus)
			UNION
			SELECT SportType, Bettype, Child_DisplayOrder
			FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,25,@SettingStatus)
			) tmp
	
	SET NOCOUNT ON
	DECLARE @CustID INT
		, @RoleID INT
		, @SRecommend INT
		, @MRecommend INT
		, @Recommend INT
		, @ugroup VARCHAR(5)
		, @Site	VARCHAR(10)

	SELECT @CustID = CustID
		, @RoleID = RoleID
		, @SRecommend = SRecommend
		, @MRecommend = MRecommend
		, @Recommend = Recommend
		, @ugroup	= c.ugroup
		, @Site	= c.site	
	FROM Customer c WITH (NOLOCK)
	WHERE UserName = @UserName	
	
	
	DECLARE @CommMatrix TABLE (
		[RoleID] [TINYINT],
		[SportType] [smallint],
		[BetType] [smallint],
		[Discount] Decimal(9,8),
		Child_DisplayOrder INT
	)	
	
	
	INSERT @CommMatrix
	SELECT
		4
	  ,comm.[SportType]
	  ,comm.[BetType]
	  ,comm.Discount
	  , pdt.Child_DisplayOrder
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
		  , pdt.Child_DisplayOrder
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
			  , pdt.Child_DisplayOrder
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
				  , pdt.Child_DisplayOrder
				FROM [dbo].CustDiscount3rd_Member comm WITH(NOLOCK)
				INNER JOIN #SportBettypeFilter pdt 
					ON pdt.SportType = comm.sporttype
						AND pdt.BetType = comm.bettype
				WHERE CustID = @CustId

				UPDATE cm
				SET cm.BetType = CASE
								WHEN @uGroup IN ('a', 'hka', 'dea') THEN 1  
								WHEN @uGroup IN ('b', 'hkb', 'deb') THEN 3 
								WHEN @uGroup IN ('c', 'hkc', 'dec') THEN 7 
								WHEN @uGroup IN ('d', 'hkd', 'ded') THEN 8  
							END,
					cm.Child_DisplayOrder = CASE
										WHEN @uGroup IN ('a', 'hka', 'dea') THEN 1  
										WHEN @uGroup IN ('b', 'hkb', 'deb') THEN 2
										WHEN @uGroup IN ('c', 'hkc', 'dec') THEN 3 
										WHEN @uGroup IN ('d', 'hkd', 'ded') THEN 4  
									END
				FROM @CommMatrix cm
				WHERE RoleID = 1
				AND BetType = 1

				
			END
		END
	END


	IF @Site <> '76666B'
	BEGIN
		-- Fill Full Data to Show data Web
		IF EXISTS (SELECT 1 FROM @CommMatrix WHERE RoleID = 1 AND SportType = 1 AND BetType = 1)
		BEGIN
			INSERT INTO @CommMatrix 
				(
					RoleID
				    , SportType
				    , BetType
				    , Discount
				    , Child_DisplayOrder
				)
				SELECT 1 , 1, 3 , NULL , 2
			UNION SELECT 1 , 1, 7 , NULL , 3
			UNION SELECT 1 , 1, 8 , NULL , 4
		END
		ELSE IF EXISTS (SELECT 1 FROM @CommMatrix WHERE RoleID = 1 AND SportType = 1 AND BetType = 3)
		BEGIN
			INSERT INTO @CommMatrix 
				(
					RoleID
				    , SportType
				    , BetType
				    , Discount
				    , Child_DisplayOrder
				)
				SELECT 1 , 1, 1 , NULL , 1
			UNION SELECT 1 , 1, 7 , NULL , 3
			UNION SELECT 1 , 1, 8 , NULL , 4
		END
		ELSE IF EXISTS (SELECT 1 FROM @CommMatrix WHERE RoleID = 1 AND SportType = 1 AND BetType = 7)
		BEGIN
			INSERT INTO @CommMatrix 
				(
					RoleID
				    , SportType
				    , BetType
				    , Discount
				    , Child_DisplayOrder
				)
				SELECT 1 , 1, 1 , NULL , 1
			UNION SELECT 1 , 1, 3 , NULL , 2
			UNION SELECT 1 , 1, 8 , NULL , 4
		END
		ELSE IF EXISTS (SELECT 1 FROM @CommMatrix WHERE RoleID = 1 AND SportType = 1 AND BetType = 8)
		BEGIN
			INSERT INTO @CommMatrix 
				(
					RoleID
				    , SportType
				    , BetType
				    , Discount
				    , Child_DisplayOrder
				)
				SELECT 1 , 1, 1 , NULL , 1
			UNION SELECT 1 , 1, 3 , NULL , 2
			UNION SELECT 1 , 1, 7 , NULL , 3
		END
	END
	
	
	--Return Comm
	SELECT [RoleID]
		, [SportType]
		, [BetType]
		, Discount
		, comm.Child_DisplayOrder
	FROM @CommMatrix comm
	ORDER BY comm.Child_DisplayOrder , [SportType]
		, [BetType] , [RoleID] DESC

	DROP TABLE #SportBettypeFilter
END  
GO