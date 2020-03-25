/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="0"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_CommMatrix]   
   @ProductID TINYINT = NULL,
   @UserName VARCHAR(30) = ''
AS  
/*  
	Created: 20150518@Dominic  
	Task : Get Comm Matrix
	DB:  DBCUST/CustDB   
	Original:  

  	Revisions: 
		- 20160219@Dominic: Implement charge commission #49689
		- 20170426@Elodie: Implementing Ticket Commission Plugin - [Redmine: #75221]
		- 20200325@Tiara: Handle dummy Product [Redmine: #130678]

	Param's Explanation: 

   
 */  
BEGIN  
	SET NOCOUNT ON
	--Handle dummy product
	CREATE TABLE #SportBettypeFilter 
	(ProductID TINYINT, 
	SportType SMALLINT, 
	Bettype SMALLINT, 
	IsLive BIT, 
	SettingType SMALLINT)

	INSERT INTO #SportBettypeFilter (ProductID, SportType, Bettype, IsLive, SettingType)
	SELECT 21, 211, 2401, 0, 3
	WHERE @ProductID = 21
	UNION
	SELECT 39, 244, 3001, 0, 3
	WHERE @ProductID = 39
	UNION 
	SELECT 45, 243, 3101, 0, 3
	WHERE @ProductID = 45

	INSERT INTO #SportBettypeFilter (ProductID, SportType, Bettype, IsLive, SettingType)
	SELECT * 
	FROM (
	SELECT *
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,3) -- comm
	UNION
	SELECT *
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,5)  
	UNION
	SELECT *
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,14) ) tmp
	
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