/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelStatusByProductID]  
(
	 @custid  INT
	 ,@ProductID INT
)	
AS  
/*  Created: Winnie  
    Date: 20170310
    Task: Agent: Getting status by CustID & ProductID - (Redmine: #72336)
    DB: DBCUST/CUSTDB   
	Revisions:	
		- 20170601@Elodie: Migrate Inspired VS to DCS structure [Redmine: #77274]
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20170504@Winnie: [Keno] - New 6 mini games - Customer Setting Development [RedmineID: #93796]
		- 20180115@Johnson: new direction for status[RedmineID: #87328]
	Parameters Explanation
*/ 

BEGIN  
	SET NOCOUNT ON  

	DECLARE @UplineID INT,@RoleID INT, @IsDisabled BIT,@IsDisabledDownline BIT=0,@HasDownline BIT=0,@isHidden BIT=0,@IsHiddenUpline BIT=0,@IsSync BIT=1,@IsSyncedDownline BIT=1,
			@IsDisabledUpline BIT=0,@IsSyncedUpline BIT=1,@recommend INT,@mrecommend INT,@srecommend INT,
			@TotalEnabledMasters INT = 0, @TotalDisabledMasters INT = 0, @TotalEnabledAgents INT = 0, @TotalDisabledAgents INT = 0, @TotalEnabledMembers INT = 0, @TotalDisabledMembers INT = 0
	
	DECLARE @tmpProduct TABLE(ProductID INT)
	
	DECLARE @SportBettype TABLE(ProductID INT,
								Sporttype INT, 
								Bettype INT,
								IsDisabled BIT NULL,								
								GameTypeID INT NULL,								
								IsSync BIT,
								IsHidden BIT,
								IsDisabledUpline BIT,
								IsHiddenUpline BIT,
								IsSyncedUpline BIT,								 
								TotalEnabledMasters INT DEFAULT 0, 
								TotalDisabledMasters INT DEFAULT 0, 
								TotalEnabledAgents INT DEFAULT 0, 
								TotalDisabledAgents INT DEFAULT 0, 
								TotalEnabledMembers INT DEFAULT 0,
								TotalDisabledMembers INT DEFAULT 0
								)		
	
	IF @ProductID=15 -- CB
	BEGIN
		SELECT @RoleID=RoleID,@IsDisabled=DisableColossusBet,@isHidden=HideColossusBet,@recommend=recommend,@mrecommend=mrecommend,@srecommend=srecommend 
		FROM custInfo WITH(NOLOCK) 
		WHERE custid=@custid
		
		IF @RoleID=2
		BEGIN
			SELECT @IsHiddenUpline=HideColossusBet,@IsDisabledUpline=DisableColossusBet 
			FROM dbo.CustInfo WITH (NOLOCK)  
			WHERE custid=@mrecommend
			
			SELECT @TotalDisabledMembers = SUM(CASE WHEN DisableColossusBet =1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN DisableColossusBet = 0 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE recommend = @custid
				AND roleid = 1
		END		
		ELSE IF @RoleID=3	
		BEGIN
			SELECT @IsHiddenUpline=HideColossusBet,@IsDisabledUpline=DisableColossusBet  
			FROM dbo.CustInfo WITH (NOLOCK)  
			WHERE custid=@srecommend
			
			SELECT @TotalDisabledAgents = SUM(CASE WHEN DisableColossusBet =1 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalEnabledAgents = SUM(CASE WHEN DisableColossusBet = 0 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalDisabledMembers = SUM(CASE WHEN DisableColossusBet =1 AND roleid = 1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN DisableColossusBet = 0 AND roleid = 1 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE mrecommend = @custid						
		END		
		ELSE IF @RoleID=4	
		BEGIN
			SELECT @TotalDisabledMasters = SUM(CASE WHEN DisableColossusBet =1 AND roleid = 3 THEN 1 ELSE 0 END),
				@TotalEnabledMasters = SUM(CASE WHEN DisableColossusBet = 0 AND roleid = 3 THEN 1 ELSE 0 END),
				@TotalDisabledAgents = SUM(CASE WHEN DisableColossusBet =1 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalEnabledAgents = SUM(CASE WHEN DisableColossusBet = 0 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalDisabledMembers = SUM(CASE WHEN DisableColossusBet =1 AND roleid = 1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN DisableColossusBet = 0 AND roleid = 1 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE srecommend = @custid
		END
		ELSE IF @RoleID=1
		BEGIN
			SELECT @IsHiddenUpline=HideColossusBet,@IsDisabledUpline=DisableColossusBet  
			FROM dbo.CustInfo WITH (NOLOCK)  
			WHERE custid=@recommend
		END
		INSERT INTO @SportBettype(ProductID,
								Sporttype, 
								Bettype ,
								IsDisabled ,
								IsSync,
								IsHidden,
								IsDisabledUpline,
								IsHiddenUpline,
								IsSyncedUpline,
								TotalDisabledMasters,
								TotalEnabledMasters,
								TotalDisabledAgents,
								TotalEnabledAgents,
								TotalDisabledMembers,
								TotalEnabledMembers)
		VALUES(@ProductID,204,18000,@IsDisabled,@IsSync,@isHidden,@IsDisabledUpline,@IsHiddenUpline,@IsSyncedUpline,
			@TotalDisabledMasters,@TotalEnabledMasters,@TotalDisabledAgents,@TotalEnabledAgents,@TotalDisabledMembers,@TotalEnabledMembers)
	END 	
	ELSE IF @ProductID = 3 --Number Game
	BEGIN
		SELECT @RoleID=RoleID,@IsDisabled=DisableNumber,@recommend=recommend,@mrecommend=mrecommend,@srecommend=srecommend 
		FROM dbo.custInfo WITH(NOLOCK) 
		WHERE custid=@custid
		
		IF @RoleID=2
		BEGIN
			SELECT @IsDisabledUpline=DisableNumber
			FROM dbo.CustInfo WITH (NOLOCK)  
			WHERE custid=@mrecommend
			
			SELECT @TotalDisabledMembers = SUM(CASE WHEN DisableNumber =1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN DisableNumber = 0 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE recommend = @custid
				AND roleid = 1
		END		
		ELSE IF @RoleID=3	
		BEGIN
			SELECT @IsDisabledUpline=DisableNumber
			FROM dbo.CustInfo WITH (NOLOCK)  
			WHERE custid=@srecommend
			
			SELECT @TotalDisabledAgents = SUM(CASE WHEN DisableNumber =1 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalEnabledAgents = SUM(CASE WHEN DisableNumber = 0 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalDisabledMembers = SUM(CASE WHEN DisableNumber =1 AND roleid = 1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN DisableNumber = 0 AND roleid = 1 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE mrecommend = @custid						
		END		
		ELSE IF @RoleID=4	
		BEGIN
			SELECT @TotalDisabledMasters = SUM(CASE WHEN DisableNumber =1 AND roleid = 3 THEN 1 ELSE 0 END),
				@TotalEnabledMasters = SUM(CASE WHEN DisableNumber = 0 AND roleid = 3 THEN 1 ELSE 0 END),
				@TotalDisabledAgents = SUM(CASE WHEN DisableNumber =1 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalEnabledAgents = SUM(CASE WHEN DisableNumber = 0 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalDisabledMembers = SUM(CASE WHEN DisableNumber =1 AND roleid = 1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN DisableNumber = 0 AND roleid = 1 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE srecommend = @custid
		END
		ELSE IF @RoleID=1
		BEGIN
			SELECT @IsDisabledUpline=DisableNumber  
			FROM dbo.CustInfo WITH (NOLOCK)  
			WHERE custid=@recommend
		END
		INSERT INTO @SportBettype(ProductID,
								Sporttype, 
								Bettype ,
								IsDisabled ,
								IsSync,
								IsHidden,
								IsDisabledUpline,
								IsHiddenUpline,
								IsSyncedUpline,
								TotalDisabledMasters,
								TotalEnabledMasters,
								TotalDisabledAgents,
								TotalEnabledAgents,
								TotalDisabledMembers,
								TotalEnabledMembers)
		VALUES(@ProductID,161,81,@IsDisabled,@IsSync,@isHidden,@IsDisabledUpline,@IsHiddenUpline,@IsSyncedUpline,
			@TotalDisabledMasters,@TotalEnabledMasters,@TotalDisabledAgents,@TotalEnabledAgents,@TotalDisabledMembers,@TotalEnabledMembers)
	END
	ELSE IF @ProductID=6 -- Casino
	BEGIN
		SELECT @RoleID=RoleID,
			@IsDisabled=DisableCasino,
			@IsSync=ISNULL(SyncCasino,0),
			@recommend=recommend,
			@mrecommend=mrecommend,
			@srecommend=srecommend 
		FROM custInfo WITH(NOLOCK) 
		WHERE custid=@custid
		
		IF @RoleID=2
		BEGIN
			SELECT @IsSyncedUpline=ISNULL(SyncCasino,0),@IsDisabledUpline=DisableCasino 
			FROM dbo.CustInfo WITH (NOLOCK)  
			WHERE custid=@mrecommend
			
			SELECT @TotalDisabledMembers = SUM(CASE WHEN DisableCasino = 1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN DisableCasino = 0 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE recommend=@custid
				AND roleid = 1
				AND SyncCasino=1			
		END		
		ELSE IF @RoleID=3
		BEGIN	
			SELECT @IsSyncedUpline=ISNULL(SyncCasino,0),@IsDisabledUpline=DisableCasino 
			FROM dbo.CustInfo WITH (NOLOCK)  
			WHERE custid=@srecommend
			
			SELECT @TotalDisabledAgents = SUM(CASE WHEN DisableCasino = 1 AND roleid = 2 THEN 2 ELSE 0 END),
				@TotalEnabledAgents = SUM(CASE WHEN DisableCasino = 0 AND roleid = 2 THEN 2 ELSE 0 END),
				@TotalDisabledMembers = SUM(CASE WHEN DisableCasino = 1 AND roleid = 1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN DisableCasino = 0 AND roleid = 1 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE mrecommend=@custid				
				AND SyncCasino=1
		END
		ELSE IF @RoleID=4	
		BEGIN	
			SELECT @TotalDisabledMasters = SUM(CASE WHEN DisableCasino = 1 AND roleid = 3 THEN 1 ELSE 0 END),
				@TotalEnabledMasters = SUM(CASE WHEN DisableCasino = 0 AND roleid = 3 THEN 1 ELSE 0 END),
				@TotalDisabledAgents = SUM(CASE WHEN DisableCasino = 1 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalEnabledAgents = SUM(CASE WHEN DisableCasino = 0 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalDisabledMembers = SUM(CASE WHEN DisableCasino = 1 AND roleid = 1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN DisableCasino = 0 AND roleid = 1 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE srecommend=@custid				
				AND SyncCasino=1			
		END
		ELSE IF @RoleID=1
		BEGIN	
			SELECT @IsSyncedUpline=ISNULL(SyncCasino,0),@IsDisabledUpline=DisableCasino FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@recommend
		END
		INSERT INTO @SportBettype(ProductID,
								Sporttype, 
								Bettype ,
								IsDisabled ,
								IsSync,
								IsHidden,
								IsDisabledUpline,
								IsHiddenUpline,
								IsSyncedUpline,
								TotalDisabledMasters,
								TotalEnabledMasters,
								TotalDisabledAgents,
								TotalEnabledAgents,
								TotalDisabledMembers,
								TotalEnabledMembers)
		VALUES(@ProductID,208,2101,@IsDisabled,@IsSync,@isHidden,@IsDisabledUpline,@IsHiddenUpline,@IsSyncedUpline,
				@TotalDisabledMasters,@TotalEnabledMasters,@TotalDisabledAgents,@TotalEnabledAgents,@TotalDisabledMembers,@TotalEnabledMembers)			
	END 	
	ELSE IF @ProductID=8--Keno
	BEGIN	
		SELECT @Ishidden=HideKeno,@recommend=recommend,@mrecommend=mrecommend,@srecommend=srecommend,@RoleID=roleid 
		FROM custInfo  WITH (NOLOCK)  
		WHERE custid=@custid
		
	

		INSERT INTO @SportBettype(ProductID ,Sporttype , Bettype ,IsDisabled ,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline,GameTypeID)	
		SELECT 8,202,IBCBetTypeID,NULL,NULL,0,1,0,0,0,1,1,GameTypeID		
		FROM DBACC.bodb02.dbo.Gametype WHERE  IBCBetTypeID BETWEEN 1501 AND 1599 AND IBCBetTypeID NOT IN(1502,1507,1509) AND IsDisabled = 0 

		UPDATE s
		SET s.IsDisabled=ct.IsDisabled
		FROM @SportBettype s 
		INNER JOIN 	CustGameType ct WITH(NOLOCK) ON ct.GameTypeID=s.GameTypeID
		WHERE ct.CustID=@custid
		
		IF @Roleid = 4
		BEGIN
			;WITH t as 
			(SELECT	ct.GameTypeID,
				TotalDisabledMasters = SUM(CASE WHEN roleid = 3 AND ct.IsDisabled = 1 THEN 1 ELSE 0 END),
				TotalEnabledMasters = SUM(CASE WHEN roleid = 3 AND ct.IsDisabled = 0 THEN 1 ELSE 0 END),
				TotalDisabledAgents = SUM(CASE WHEN roleid = 2 AND ct.IsDisabled = 1 THEN 1 ELSE 0 END),
				TotalEnabledAgents = SUM(CASE WHEN roleid = 2 AND ct.IsDisabled = 0 THEN 1 ELSE 0 END),
				TotalDisabledMembers = SUM(CASE WHEN roleid = 1 AND ct.IsDisabled = 1 THEN 1 ELSE 0 END),
				TotalEnabledMembers = SUM(CASE WHEN roleid = 1 AND ct.IsDisabled = 0 THEN 1 ELSE 0 END)
			FROM @SportBettype s 
				INNER JOIN dbo.CustGameType ct WITH(NOLOCK) ON ct.GameTypeID=s.GameTypeID
				INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.custid = ct.custid
			WHERE ci.srecommend = @custid
			GROUP BY ct.GameTypeID
			)
			UPDATE s
			SET TotalDisabledMasters = t.TotalDisabledMasters,
				TotalEnabledMasters =   t.TotalEnabledMasters,
				TotalDisabledAgents =   t.TotalDisabledAgents,
				TotalEnabledAgents =   t.TotalEnabledAgents,
				TotalDisabledMembers =   t.TotalDisabledMembers,
				TotalEnabledMembers =   t.TotalEnabledMembers 
			FROM @SportBettype s	
				INNER JOIN t ON s.gametypeid = t.gametypeid
				
		END
		IF @RoleID=3	
		BEGIN	
			UPDATE s
			SET s.IsDisabledUpline=ct.IsDisabled
			FROM @SportBettype s 
			INNER JOIN 	CustGameType ct WITH(NOLOCK) ON ct.GameTypeID=s.GameTypeID
			WHERE ct.CustID=@srecommend	
			SELECT @IsHiddenUpline=HideKeno FROM custInfo  WITH (NOLOCK)  WHERE custid=@srecommend
			
			;WITH t as 
			(SELECT	ct.GameTypeID,
				TotalDisabledAgents = SUM(CASE WHEN roleid = 2 AND ct.IsDisabled = 1 THEN 1 ELSE 0 END),
				TotalEnabledAgents = SUM(CASE WHEN roleid = 2 AND ct.IsDisabled = 0 THEN 1 ELSE 0 END),
				TotalDisabledMembers = SUM(CASE WHEN roleid = 1 AND ct.IsDisabled = 1 THEN 1 ELSE 0 END),
				TotalEnabledMembers = SUM(CASE WHEN roleid = 1 AND ct.IsDisabled = 0 THEN 1 ELSE 0 END)
			FROM @SportBettype s 
				INNER JOIN dbo.CustGameType ct WITH(NOLOCK) ON ct.GameTypeID=s.GameTypeID
				INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.custid = ct.custid
			WHERE ci.mrecommend = @custid
			GROUP BY ct.GameTypeID
			)
			UPDATE s
			SET TotalDisabledAgents =   t.TotalDisabledAgents,
				TotalEnabledAgents =   t.TotalEnabledAgents,
				TotalDisabledMembers =   t.TotalDisabledMembers,
				TotalEnabledMembers =   t.TotalEnabledMembers 
			FROM @SportBettype s	
				INNER JOIN t ON s.gametypeid = t.gametypeid
		END
		IF @RoleID=2
		BEGIN
			UPDATE s
			SET s.IsDisabledUpline=ct.IsDisabled
			FROM @SportBettype s 
			INNER JOIN 	CustGameType ct WITH(NOLOCK) ON ct.GameTypeID=s.GameTypeID
			WHERE ct.CustID=@mrecommend	
			SELECT @IsHiddenUpline=HideKeno FROM custInfo  WITH (NOLOCK)  WHERE custid=@mrecommend
			
			;WITH t as 
			(SELECT	ct.GameTypeID,
				TotalDisabledMembers = SUM(CASE WHEN roleid = 1 AND ct.IsDisabled = 1 THEN 1 ELSE 0 END),
				TotalEnabledMembers = SUM(CASE WHEN roleid = 1 AND ct.IsDisabled = 0 THEN 1 ELSE 0 END)
			FROM @SportBettype s 
				INNER JOIN dbo.CustGameType ct WITH(NOLOCK) ON ct.GameTypeID=s.GameTypeID
				INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.custid = ct.custid
			WHERE ci.mrecommend = @custid
			GROUP BY ct.GameTypeID
			)
			UPDATE s
			SET TotalDisabledMembers =   t.TotalDisabledMembers,
				TotalEnabledMembers =   t.TotalEnabledMembers 
			FROM @SportBettype s	
				INNER JOIN t ON s.gametypeid = t.gametypeid
		END	
		IF @RoleID=1
		BEGIN
			UPDATE s
			SET s.IsDisabledUpline=ct.IsDisabled
			FROM @SportBettype s 
			INNER JOIN 	CustGameType ct WITH(NOLOCK) ON ct.GameTypeID=s.GameTypeID
			WHERE ct.CustID=@recommend	
			SELECT @IsHiddenUpline=HideKeno FROM custInfo  WITH (NOLOCK)  WHERE custid=@recommend
		END		
		UPDATE s
		SET s.IsHiddenUpline=@IsHiddenUpline
		FROM @SportBettype s	
		
		DELETE FROM @SportBettype WHERE IsDisabled IS NULL	

	END 
	
	ELSE IF @ProductID=2--HR
	BEGIN
		DECLARE @SportBettype2 TABLE(ProductID INT,
								Sporttype INT, 
								Bettype INT,
								IsDisabled BIT NULL,
								IsDisabledDownline BIT,
								GameTypeID INT NULL,
								HasDownline BIT,
								IsSync BIT,
								IsHidden BIT,
								IsDisabledUpline BIT,
								IsHiddenUpline BIT,
								IsSyncedUpline BIT,
								IsSyncedDownline BIT)
								
		DECLARE @IsDisabled151_31 BIT,@IsDisabled151_41	BIT,@IsDisabled151_51 BIT,@IsDisabled152_41 BIT, @IsDisabled152_51 BIT,@IsDisabled153_51 BIT,
		@IsDisabledDownline151_31 BIT=0,@IsDisabledDownline151_41 BIT=0,@IsDisabledDownline151_51 BIT=0,@IsDisabledDownline152_41 BIT=0, @IsDisabledDownline152_51 BIT=0,@IsDisabledDownline153_51 BIT=0,
		@IsDisabledUpline151_31 BIT=0,@IsDisabledUpline151_41 BIT=0,@IsDisabledUpline151_51 BIT=0,@IsDisabledUpline152_41 BIT=0, @IsDisabledUpline152_51 BIT=0,@IsDisabledUpline153_51 BIT=0
		
		SELECT @RoleID=RoleID,@IsDisabled151_31=DisableHorseracing,@IsDisabled151_41=DisableOpenTote,@IsDisabled151_51=Disable151_AU,@IsDisabled152_41=Disable152_UK,
		@IsDisabled152_51=Disable152_AU,@IsDisabled153_51=Disable153_AU,@recommend=recommend,@mrecommend=mrecommend,@srecommend=srecommend
		FROM custInfo WITH(NOLOCK) WHERE custid=@custid
		
		IF @RoleID=2
		BEGIN
			SELECT @IsDisabledUpline151_31=DisableHorseracing FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@mrecommend
			SELECT @IsDisabledUpline151_41=DisableOpenTote FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@mrecommend
			SELECT @IsDisabledUpline151_51=Disable151_AU FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@mrecommend
			SELECT @IsDisabledUpline152_41=Disable152_UK FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@mrecommend
			SELECT @IsDisabledUpline152_51=Disable152_AU FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@mrecommend
			SELECT @IsDisabledUpline153_51=Disable153_AU FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@mrecommend
			IF EXISTS(SELECT 1 	FROM dbo.CustInfo WITH (NOLOCK)	WHERE recommend = @CustID AND roleid=1)
					SELECT @HasDownline=1
			IF @HasDownline=1
				BEGIN	
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND DisableHorseracing=1)
					SELECT @IsDisabledDownline151_31=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND DisableOpenTote=1)
					SELECT @IsDisabledDownline151_41=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND Disable151_AU=1)
					SELECT @IsDisabledDownline151_51=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND Disable152_UK=1)
					SELECT @IsDisabledDownline152_41=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND Disable152_AU=1)
					SELECT @IsDisabledDownline152_51=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND Disable153_AU=1)
					SELECT @IsDisabledDownline153_51=1
				END
		END
		ELSE IF @RoleID=3	
		BEGIN
			SELECT @IsDisabledUpline151_31=DisableHorseracing FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@srecommend
			SELECT @IsDisabledUpline151_41=DisableOpenTote FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@srecommend
			SELECT @IsDisabledUpline151_51=Disable151_AU FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@srecommend
			SELECT @IsDisabledUpline152_41=Disable152_UK FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@srecommend
			SELECT @IsDisabledUpline152_51=Disable152_AU FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@srecommend
			SELECT @IsDisabledUpline153_51=Disable153_AU FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@srecommend
			
			IF EXISTS(SELECT 1 	FROM dbo.CustInfo WITH (NOLOCK)	WHERE mrecommend = @CustID AND roleid=2)
				SELECT @HasDownline=1
			IF @HasDownline=1	
				BEGIN
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND DisableHorseracing=1)
					SELECT @IsDisabledDownline151_31=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND DisableOpenTote=1)
					SELECT @IsDisabledDownline151_41=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND Disable151_AU=1)
					SELECT @IsDisabledDownline151_51=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND Disable152_UK=1)
					SELECT @IsDisabledDownline152_41=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND Disable152_AU=1)
					SELECT @IsDisabledDownline152_51=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND Disable153_AU=1)
					SELECT @IsDisabledDownline153_51=1
				END
		END
		ELSE IF @RoleID=4	
		BEGIN
			IF EXISTS(SELECT 1 	FROM dbo.CustInfo WITH (NOLOCK)  WHERE srecommend = @CustID AND roleid=3)
					SELECT @HasDownline=1
			IF @HasDownline=1	
				BEGIN
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND DisableHorseracing=1)
					SELECT @IsDisabledDownline151_31=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND DisableOpenTote=1)
					SELECT @IsDisabledDownline151_41=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND Disable151_AU=1)
					SELECT @IsDisabledDownline151_51=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND Disable152_UK=1)
					SELECT @IsDisabledDownline152_41=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND Disable152_AU=1)
					SELECT @IsDisabledDownline152_51=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND Disable153_AU=1)
					SELECT @IsDisabledDownline153_51=1
				END 
		END
		ELSE IF @RoleID=1
		BEGIN
			SELECT @IsDisabledUpline151_31=DisableHorseracing FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@recommend
			SELECT @IsDisabledUpline151_41=DisableOpenTote FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@recommend
			SELECT @IsDisabledUpline151_51=Disable151_AU FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@recommend
			SELECT @IsDisabledUpline152_41=Disable152_UK FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@recommend
			SELECT @IsDisabledUpline152_51=Disable152_AU FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@recommend
			SELECT @IsDisabledUpline153_51=Disable153_AU FROM dbo.CustInfo WITH (NOLOCK)	WHERE custid=@recommend		
		END
		
		INSERT INTO @SportBettype2(ProductID ,Sporttype , Bettype ,IsDisabled ,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline)
		SELECT 2,151,31,@IsDisabled151_31,@IsDisabledDownline151_31,@HasDownline,@IsSync,@isHidden,@IsDisabledUpline151_31,@IsHiddenUpline,@IsSyncedUpline,@IsSyncedDownline
		UNION
		SELECT 2,151,41,@IsDisabled151_41,@IsDisabledDownline151_41,@HasDownline,@IsSync,@isHidden,@IsDisabledUpline151_41,@IsHiddenUpline,@IsSyncedUpline,@IsSyncedDownline	
		UNION
		SELECT 2,151,51,@IsDisabled151_51,@IsDisabledDownline151_51,@HasDownline,@IsSync,@isHidden,@IsDisabledUpline151_51,@IsHiddenUpline,@IsSyncedUpline,@IsSyncedDownline	
		UNION
		SELECT 2,152,41,@IsDisabled152_41,@IsDisabledDownline152_41,@HasDownline,@IsSync,@isHidden,@IsDisabledUpline152_41,@IsHiddenUpline,@IsSyncedUpline,@IsSyncedDownline	
		UNION
		SELECT 2,152,51,@IsDisabled152_51,@IsDisabledDownline152_51,@HasDownline,@IsSync,@isHidden,@IsDisabledUpline152_51,@IsHiddenUpline,@IsSyncedUpline,@IsSyncedDownline	
		UNION
		SELECT 2,153,51,@IsDisabled153_51,@IsDisabledDownline153_51,@HasDownline,@IsSync,@isHidden,@IsDisabledUpline153_51,@IsHiddenUpline,@IsSyncedUpline,@IsSyncedDownline	
		
		SELECT ProductID,Sporttype, Bettype,IsDisabled,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline FROM @SportBettype2
		
		RETURN
	END 

	SELECT ProductID,Sporttype, Bettype,IsDisabled,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline, 
		TotalDisabledMasters, TotalEnabledMasters, TotalDisabledAgents, TotalEnabledAgents, TotalDisabledMembers, TotalEnabledMembers
	FROM @SportBettype
END

GO