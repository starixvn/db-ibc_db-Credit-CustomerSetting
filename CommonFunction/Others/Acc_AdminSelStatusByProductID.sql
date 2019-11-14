/*<info serverAlias="DBCust-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[Acc_AdminSelStatusByProductID]  
(
	 @custid  INT
	 ,@ProductID INT
)	
AS  
/*  Created: Johnson  
    Date: 20180228
    Task: Admin: Getting status by CustID & ProductID for credit customer
    DB: DBCUST/CUSTDB   
	Original: Acc_CustomerSelStatusByProductID
	
	Revisions:	
		- 20180228@Johnson: new direction for status[RedmineID: #87328]
		- 20190828@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
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
		SELECT @RoleID=RoleID,@IsDisabled=ISNULL(DisableColossusBet,1),@isHidden=ISNULL(HideColossusBet,1),@recommend=recommend,@mrecommend=mrecommend,@srecommend=srecommend 
		FROM custInfo WITH(NOLOCK) 
		WHERE custid=@custid
		
		IF @RoleID=2
		BEGIN
			SELECT @IsHiddenUpline=ISNULL(HideColossusBet,1),@IsDisabledUpline=ISNULL(DisableColossusBet,1) 
			FROM dbo.CustInfo WITH (NOLOCK)  
			WHERE custid=@mrecommend
			
			SELECT @TotalDisabledMembers = SUM(CASE WHEN ISNULL(DisableColossusBet,1) =1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN ISNULL(DisableColossusBet,1) = 0 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE recommend = @custid
				AND roleid = 1
		END		
		ELSE IF @RoleID=3	
		BEGIN
			SELECT @IsHiddenUpline=ISNULL(HideColossusBet,1),@IsDisabledUpline=ISNULL(DisableColossusBet,1)  
			FROM dbo.CustInfo WITH (NOLOCK)  
			WHERE custid=@srecommend
			
			SELECT @TotalDisabledAgents = SUM(CASE WHEN ISNULL(DisableColossusBet,1) =1 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalEnabledAgents = SUM(CASE WHEN ISNULL(DisableColossusBet,1) = 0 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalDisabledMembers = SUM(CASE WHEN ISNULL(DisableColossusBet,1) =1 AND roleid = 1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN ISNULL(DisableColossusBet,1) = 0 AND roleid = 1 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE mrecommend = @custid						
		END		
		ELSE IF @RoleID=4	
		BEGIN
			SELECT @TotalDisabledMasters = SUM(CASE WHEN ISNULL(DisableColossusBet,1) =1 AND roleid = 3 THEN 1 ELSE 0 END),
				@TotalEnabledMasters = SUM(CASE WHEN ISNULL(DisableColossusBet,1) = 0 AND roleid = 3 THEN 1 ELSE 0 END),
				@TotalDisabledAgents = SUM(CASE WHEN ISNULL(DisableColossusBet,1) =1 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalEnabledAgents = SUM(CASE WHEN ISNULL(DisableColossusBet,1) = 0 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalDisabledMembers = SUM(CASE WHEN ISNULL(DisableColossusBet,1) =1 AND roleid = 1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN ISNULL(DisableColossusBet,1) = 0 AND roleid = 1 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE srecommend = @custid
		END
		ELSE IF @RoleID=1
		BEGIN
			SELECT @IsHiddenUpline=ISNULL(HideColossusBet,1),@IsDisabledUpline=ISNULL(DisableColossusBet,1)  
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
			
			SELECT @TotalDisabledAgents = SUM(CASE WHEN DisableCasino = 1 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalEnabledAgents = SUM(CASE WHEN DisableCasino = 0 AND roleid = 2 THEN 1 ELSE 0 END),
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
		
		INSERT INTO @SportBettype(ProductID ,Sporttype , Bettype ,IsDisabled,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,GameTypeID,
								TotalEnabledMasters,TotalDisabledMasters,TotalEnabledAgents,TotalDisabledAgents,TotalEnabledMembers,TotalDisabledMembers)
		SELECT 8,202,IBCBetTypeID,NULL,0,0,0,0,1,GameTypeID,0,0,0,0,0,0
		FROM DBACC.bodb02.dbo.Gametype WHERE  IBCBetTypeID BETWEEN 1501 AND 1599 AND IBCBetTypeID NOT IN(1502,1507,1509) AND IsDisabled = 0 
		
		UPDATE s
		SET s.IsDisabled=ct.IsDisabled
		FROM @SportBettype s 
		INNER JOIN 	CustGameType ct WITH(NOLOCK) ON ct.GameTypeID=s.GameTypeID
		WHERE ct.CustID=@custid 
		
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
			WHERE ci.recommend = @custid
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
			
	END 
	IF @ProductID=12 -- GD
	BEGIN
		SELECT @RoleID=RoleID,@IsDisabled=DisableGoldDeluxe,@isHidden=HideGoldDeluxe,@recommend=recommend,@mrecommend=mrecommend,@srecommend=srecommend,
			@IsSync = CASE WHEN HideGoldDeluxe = 1 THEN 0 ELSE 1 END 
		FROM custInfo WITH(NOLOCK) 
		WHERE custid=@custid
		
		IF @RoleID=2
		BEGIN
			SELECT @IsHiddenUpline=HideGoldDeluxe,@IsDisabledUpline=DisableGoldDeluxe,
				@IsSyncedUpline = CASE WHEN HideGoldDeluxe = 1 THEN 0 ELSE 1 END
			FROM dbo.CustInfo WITH (NOLOCK)  
			WHERE custid=@mrecommend
			
			SELECT @TotalDisabledMembers = SUM(CASE WHEN DisableGoldDeluxe =1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN DisableGoldDeluxe = 0 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE recommend = @custid
				AND roleid = 1
		END		
		ELSE IF @RoleID=3	
		BEGIN
			SELECT @IsHiddenUpline=HideGoldDeluxe,@IsDisabledUpline=DisableGoldDeluxe,
				@IsSyncedUpline = CASE WHEN HideGoldDeluxe = 1 THEN 0 ELSE 1 END  
			FROM dbo.CustInfo WITH (NOLOCK)  
			WHERE custid=@srecommend
			
			SELECT @TotalDisabledAgents = SUM(CASE WHEN DisableGoldDeluxe =1 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalEnabledAgents = SUM(CASE WHEN DisableGoldDeluxe = 0 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalDisabledMembers = SUM(CASE WHEN DisableGoldDeluxe =1 AND roleid = 1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN DisableGoldDeluxe = 0 AND roleid = 1 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE mrecommend = @custid						
		END		
		ELSE IF @RoleID=4	
		BEGIN
			SELECT @TotalDisabledMasters = SUM(CASE WHEN DisableGoldDeluxe =1 AND roleid = 3 THEN 1 ELSE 0 END),
				@TotalEnabledMasters = SUM(CASE WHEN DisableGoldDeluxe = 0 AND roleid = 3 THEN 1 ELSE 0 END),
				@TotalDisabledAgents = SUM(CASE WHEN DisableGoldDeluxe =1 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalEnabledAgents = SUM(CASE WHEN DisableGoldDeluxe = 0 AND roleid = 2 THEN 1 ELSE 0 END),
				@TotalDisabledMembers = SUM(CASE WHEN DisableGoldDeluxe =1 AND roleid = 1 THEN 1 ELSE 0 END),
				@TotalEnabledMembers = SUM(CASE WHEN DisableGoldDeluxe = 0 AND roleid = 1 THEN 1 ELSE 0 END)
			FROM dbo.CustInfo WITH(NOLOCK)
			WHERE srecommend = @custid
			
			SELECT @IsSyncedUpline = 1
		END
		ELSE IF @RoleID=1
		BEGIN
			SELECT @IsHiddenUpline=HideGoldDeluxe,@IsDisabledUpline=DisableGoldDeluxe,
				@IsSyncedUpline = CASE WHEN HideGoldDeluxe = 1 THEN 0 ELSE 1 END  
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
		VALUES(@ProductID,255,1701,@IsDisabled,@IsSync,@isHidden,@IsDisabledUpline,@IsHiddenUpline,@IsSyncedUpline,
			@TotalDisabledMasters,@TotalEnabledMasters,@TotalDisabledAgents,@TotalEnabledAgents,@TotalDisabledMembers,@TotalEnabledMembers)
	END 	

	SELECT ProductID,Sporttype, Bettype,IsDisabled,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline, 
		ISNULL(TotalDisabledMasters,0) TotalDisabledMasters, ISNULL(TotalEnabledMasters,0) TotalEnabledMasters, 
		ISNULL(TotalDisabledAgents,0) TotalDisabledAgents, ISNULL(TotalEnabledAgents,0) TotalEnabledAgents, 
		ISNULL(TotalDisabledMembers,0) TotalDisabledMembers, ISNULL(TotalEnabledMembers,0) TotalEnabledMembers
	FROM @SportBettype
END
GO