/*<info serverAlias="DBCust-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="vnteam" isFunction="0"></info>*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_CustomerSelStatusByProductId]  
(
	 @custid  INT
	 ,@ProductID INT
)	
AS  
/*  Created: Winnie  
    Date: 20170310
    Task: Agent: Getting status by CustID & ProductID - (Redmine: #72336)
    DB: DBCUST / CUSTDB   
	Revisions:	
	Parameters Explanation
*/ 

BEGIN  
	SET NOCOUNT ON  

	DECLARE @UplineID INT,@RoleID INT, @IsDisabled BIT,@IsDisabledDownline BIT=0,@HasDownline BIT=0,@isHidden BIT=0,@IsHiddenUpline BIT=0,@IsSync BIT=1,@IsSyncedDownline BIT=1,
	@IsDisabledUpline BIT=0,@IsSyncedUpline BIT=1,@recommend INT,@mrecommend INT,@srecommend INT
	DECLARE @tmpProduct TABLE(ProductID INT)
	DECLARE @SportBettype TABLE(ProductID INT,Sporttype INT, Bettype INT,IsDisabled BIT NULL,IsDisabledDownline BIT ,GameTypeID INT NULL,HasDownline BIT,IsSync BIT,IsHidden BIT,IsDisabledUpline BIT,
	IsHiddenUpline BIT,IsSyncedUpline BIT,IsSyncedDownline BIT )		
	
	IF @ProductID=15 -- CB
	BEGIN
		SELECT @RoleID=RoleID,@IsDisabled=DisableColossusBet,@isHidden=HideColossusBet,@recommend=recommend,@mrecommend=mrecommend,@srecommend=srecommend FROM custInfo WITH(NOLOCK) WHERE custid=@custid
		IF @RoleID=2
		BEGIN
			SELECT @IsHiddenUpline=HideColossusBet,@IsDisabledUpline=DisableColossusBet FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@mrecommend
			IF EXISTS(SELECT 1  FROM dbo.CustInfo WITH (NOLOCK)  WHERE recommend = @CustID AND roleid=1)
				SELECT @HasDownline=1
			IF @HasDownline=1
				IF EXISTS(SELECT 1 FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND roleid=1 AND DisableColossusBet=1)
					SELECT @IsDisabledDownline=1
		END		
		ELSE IF @RoleID=3	
		BEGIN
			SELECT @IsHiddenUpline=HideColossusBet,@IsDisabledUpline=DisableColossusBet  FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@srecommend
			IF EXISTS(SELECT 1 FROM dbo.CustInfo WITH (NOLOCK)	WHERE mrecommend = @CustID AND roleid=2)
				SELECT @HasDownline=1
			IF @HasDownline=1
				IF EXISTS(SELECT 1 FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND roleid=2 AND DisableColossusBet=1)
					SELECT @IsDisabledDownline=1
		END		
		ELSE IF @RoleID=4	
		BEGIN
			IF EXISTS(SELECT 1 FROM dbo.CustInfo WITH (NOLOCK)  WHERE srecommend = @CustID AND roleid=3)
				SELECT @HasDownline=1
			IF @HasDownline=1
				IF EXISTS(SELECT 1 FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND roleid=3 AND DisableColossusBet=1)	
					SELECT @IsDisabledDownline=1
		END
		ELSE IF @RoleID=1
		BEGIN
			SELECT @IsHiddenUpline=HideColossusBet,@IsDisabledUpline=DisableColossusBet  FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@recommend
		END
		INSERT INTO @SportBettype(ProductID ,Sporttype , Bettype ,IsDisabled ,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline)
		VALUES(@ProductID,204,18000,@IsDisabled,@IsDisabledDownline,@HasDownline,@IsSync,@isHidden,@IsDisabledUpline,@IsHiddenUpline,@IsSyncedUpline,@IsSyncedDownline)		
	END 	
	
	ELSE IF @ProductID=5 -- VS
	BEGIN
		SELECT @RoleID=RoleID,@IsDisabled=DisableVirtualSports,@isHidden=HideVirtualSports,@recommend=recommend,@mrecommend=mrecommend,@srecommend=srecommend FROM custInfo WITH(NOLOCK) WHERE custid=@custid
		IF @RoleID=2
		BEGIN
			SELECT @IsHiddenUpline=HideVirtualSports,@IsDisabledUpline=DisableVirtualSports  FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@mrecommend
			IF EXISTS(SELECT 1 FROM dbo.CustInfo WITH (NOLOCK)	WHERE recommend = @CustID AND roleid=1)
				SELECT @HasDownline=1
			IF @HasDownline=1
				IF EXISTS(SELECT 1 FROM  custInfo WITH(NOLOCK) WHERE recommend=@custid AND roleid=1 AND DisableVirtualSports=1)
					SELECT @IsDisabledDownline=1
		END		
		ELSE IF @RoleID=3	
		BEGIN
			SELECT @IsHiddenUpline=HideVirtualSports,@IsDisabledUpline=DisableVirtualSports FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@srecommend
			IF EXISTS(SELECT 1	FROM dbo.CustInfo WITH (NOLOCK)  WHERE mrecommend = @CustID AND roleid=2)
				SELECT @HasDownline=1
			IF @HasDownline=1
				IF EXISTS(SELECT 1 FROM  custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND roleid=2 AND DisableVirtualSports=1)
					SELECT @IsDisabledDownline=1
		END
		ELSE IF @RoleID=4	
		BEGIN
			IF EXISTS(SELECT 1	FROM dbo.CustInfo WITH (NOLOCK)  WHERE srecommend = @CustID AND roleid=3)
				SELECT @HasDownline=1
			IF @HasDownline=1
				IF EXISTS(SELECT 1 FROM  custInfo WITH(NOLOCK) WHERE srecommend=@custid AND roleid=3 AND DisableVirtualSports=1)
						SELECT @IsDisabledDownline=1
		END	
		ELSE IF @RoleID=1
		BEGIN
			SELECT @IsHiddenUpline=HideVirtualSports,@IsDisabledUpline=DisableVirtualSports FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@recommend
		END
		INSERT INTO @SportBettype(ProductID ,Sporttype , Bettype ,IsDisabled ,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline)	
		VALUES(@ProductID,180,1201,@IsDisabled,@IsDisabledDownline,@HasDownline,@IsSync,@isHidden,@IsDisabledUpline,@IsHiddenUpline,@IsSyncedUpline,@IsSyncedDownline)				
	END 	
	ELSE IF @ProductID=6 -- Casino
	BEGIN
		SELECT @RoleID=RoleID,@IsDisabled=DisableCasino,@IsSync=ISNULL(SyncCasino,0),@recommend=recommend,@mrecommend=mrecommend,@srecommend=srecommend FROM custInfo WITH(NOLOCK) WHERE custid=@custid
		IF @RoleID=2
		BEGIN
			SELECT @IsSyncedUpline=ISNULL(SyncCasino,0),@IsDisabledUpline=DisableCasino FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@mrecommend
			IF EXISTS(SELECT 1	FROM dbo.CustInfo WITH (NOLOCK)	WHERE recommend = @CustID AND roleid=1)
					SELECT @HasDownline=1
			IF @HasDownline=1
			BEGIN
				IF EXISTS(SELECT 1 FROM  custInfo WITH(NOLOCK) WHERE recommend=@custid AND roleid=1 AND DisableCasino=1)
					SELECT @IsDisabledDownline=1
				IF EXISTS(SELECT 1 FROM  custInfo WITH(NOLOCK) WHERE recommend=@custid AND roleid=1 AND ISNULL(SyncCasino,0)=0)
					SELECT @IsSyncedDownline=0
			END
		END		
		ELSE IF @RoleID=3
		BEGIN	
			SELECT @IsSyncedUpline=ISNULL(SyncCasino,0),@IsDisabledUpline=DisableCasino FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@srecommend
			IF EXISTS(SELECT 1	FROM dbo.CustInfo WITH (NOLOCK)	WHERE mrecommend = @CustID AND roleid=2)
				SELECT @HasDownline=1
			IF @HasDownline=1
			BEGIN
				IF EXISTS(SELECT 1 FROM  custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND roleid=2 AND DisableCasino=1)
					SELECT @IsDisabledDownline=1
				IF EXISTS(SELECT 1 FROM  custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND roleid=2 AND ISNULL(SyncCasino,0)=0)
					SELECT @IsSyncedDownline=0
			END
		END
		ELSE IF @RoleID=4	
		BEGIN	
			
			IF EXISTS(SELECT 1	FROM dbo.CustInfo WITH (NOLOCK)	WHERE srecommend = @CustID AND roleid=3)
				SELECT @HasDownline=1
			IF @HasDownline=1
			BEGIN
				
				IF EXISTS(SELECT 1 FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND roleid=3 AND DisableCasino=1)
				BEGIN
				
					SELECT @IsDisabledDownline=1
						
				END
				IF EXISTS(SELECT 1 FROM  custInfo WITH(NOLOCK) WHERE srecommend=@custid AND roleid=3 AND ISNULL(SyncCasino,0)=0)
					SELECT @IsSyncedDownline=0
			END
		END
		ELSE IF @RoleID=1
		BEGIN	
			SELECT @IsSyncedUpline=ISNULL(SyncCasino,0),@IsDisabledUpline=DisableCasino FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@recommend
		END
		INSERT INTO @SportBettype(ProductID ,Sporttype , Bettype ,IsDisabled ,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline)
		VALUES(@ProductID,208,2101,@IsDisabled,@IsDisabledDownline,@HasDownline,@IsSync,@isHidden,@IsDisabledUpline,@IsHiddenUpline,@IsSyncedUpline,@IsSyncedDownline)			
	END 	
	ELSE IF @ProductID=8--Keno
	BEGIN	
		SELECT @Ishidden=HideKeno,@recommend=recommend,@mrecommend=mrecommend,@srecommend=srecommend,@RoleID=roleid FROM custInfo  WITH (NOLOCK)  WHERE custid=@custid
		INSERT INTO @SportBettype(ProductID ,Sporttype , Bettype ,IsDisabled ,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline)	
		SELECT 8,202,1501,NULL,0,0,1,0,0,0,1,1
		UNION
		SELECT 8,202,1503,NULL,0,0,1,0,0,0,1,1
		UNION
		SELECT 8,202,1504,NULL,0,0,1,0,0,0,1,1
		UNION
		SELECT 8,202,1505,NULL,0,0,1,0,0,0,1,1
		UNION
		SELECT 8,202,1508,NULL,0,0,1,0,0,0,1,1
		UNION
		SELECT 8,202,1511,NULL,0,0,1,0,0,0,1,1
		UNION
		SELECT 8,202,1513,NULL,0,0,1,0,0,0,1,1
		UNION
		SELECT 8,202,1514,NULL,0,0,1,0,0,0,1,1
		UNION
		SELECT 8,202,1515,NULL,0,0,1,0,0,0,1,1
		UNION
		SELECT 8,202,1516,NULL,0,0,1,0,0,0,1,1
		
		UPDATE s
		SET s.GameTypeID=g.GameTypeID
		FROM @SportBettype s		
		INNER JOIN DBACC.bodb02.dbo.Gametype g WITH(NOLOCK) ON s.Bettype=g.IBCBetTypeID
		WHERE g.IsDisabled = 0 
		
		UPDATE s
		SET s.IsDisabled=ct.IsDisabled
		FROM @SportBettype s 
		INNER JOIN 	CustGameType ct WITH(NOLOCK) ON ct.GameTypeID=s.GameTypeID
		WHERE ct.CustID=@custid
		
		IF @RoleID=4		
		BEGIN				 
			IF EXISTS(SELECT 1	FROM dbo.CustInfo WITH (NOLOCK) WHERE srecommend = @CustID AND roleid=3)
					SELECT @HasDownline=1
			IF @HasDownline=1
					UPDATE s
					SET s.IsDisabledDownline=(SELECT TOP 1 IsDisabled FROM CustGameType ct WITH(NOLOCK) 
									INNER JOIN  dbo.custInfo c WITH(NOLOCK) ON c.custid=ct.CustID 								
									WHERE  srecommend= @custid AND c.roleid=3 AND ct.IsDisabled = 1 AND s.GameTypeID=ct.GameTypeID)
					FROM @SportBettype s
		END
		IF @RoleID=3	
		BEGIN	
			UPDATE s
			SET s.IsDisabledUpline=ct.IsDisabled
			FROM @SportBettype s 
			INNER JOIN 	CustGameType ct WITH(NOLOCK) ON ct.GameTypeID=s.GameTypeID
			WHERE ct.CustID=@srecommend	
			SELECT @IsHiddenUpline=HideKeno FROM custInfo  WITH (NOLOCK)  WHERE custid=@srecommend
			IF EXISTS(SELECT 1 FROM dbo.CustInfo WITH (NOLOCK) 	WHERE mrecommend = @CustID AND roleid=2)
				SELECT @HasDownline=1
			IF @HasDownline=1
				UPDATE s
				SET s.IsDisabledDownline=(SELECT TOP 1 IsDisabled FROM CustGameType ct WITH(NOLOCK) 
										INNER JOIN  dbo.custInfo c WITH(NOLOCK) ON c.custid=ct.CustID 								
										WHERE  mrecommend= @custid AND ct.IsDisabled = 1 AND c.roleid=2 AND s.GameTypeID=ct.GameTypeID)
				FROM @SportBettype s 
		END
		IF @RoleID=2
		BEGIN
			UPDATE s
			SET s.IsDisabledUpline=ct.IsDisabled
			FROM @SportBettype s 
			INNER JOIN 	CustGameType ct WITH(NOLOCK) ON ct.GameTypeID=s.GameTypeID
			WHERE ct.CustID=@mrecommend	
			SELECT @IsHiddenUpline=HideKeno FROM custInfo  WITH (NOLOCK)  WHERE custid=@mrecommend
			IF EXISTS(SELECT 1 	FROM dbo.CustInfo WITH (NOLOCK) WHERE recommend = @CustID AND roleid=1)
				SELECT @HasDownline=1
			IF @HasDownline=1	
			UPDATE s
			SET s.IsDisabledDownline=(SELECT TOP 1 IsDisabled FROM CustGameType ct WITH(NOLOCK) 
									INNER JOIN  dbo.custInfo c WITH(NOLOCK) ON c.custid=ct.CustID 								
									WHERE  recommend= @custid AND ct.IsDisabled = 1 AND c.roleid=1 AND s.GameTypeID=ct.GameTypeID)
			FROM @SportBettype s 
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
		SET s.HasDownline=@HasDownline,s.IsHiddenUpline=@IsHiddenUpline
		FROM @SportBettype s	
			

	END 
	
	ELSE IF @ProductID=2--HR
	BEGIN
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
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND roleid=1 AND DisableHorseracing=1)
					SELECT @IsDisabledDownline151_31=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND roleid=1 AND DisableOpenTote=1)
					SELECT @IsDisabledDownline151_41=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND roleid=1 AND Disable151_AU=1)
					SELECT @IsDisabledDownline151_51=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND roleid=1 AND Disable152_UK=1)
					SELECT @IsDisabledDownline152_41=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND roleid=1 AND Disable152_AU=1)
					SELECT @IsDisabledDownline152_51=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND roleid=1 AND Disable153_AU=1)
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
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND roleid=2  AND DisableHorseracing=1)
					SELECT @IsDisabledDownline151_31=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND roleid=2  AND DisableOpenTote=1)
					SELECT @IsDisabledDownline151_41=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND roleid=2  AND Disable151_AU=1)
					SELECT @IsDisabledDownline151_51=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND roleid=2  AND Disable152_UK=1)
					SELECT @IsDisabledDownline152_41=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND roleid=2  AND Disable152_AU=1)
					SELECT @IsDisabledDownline152_51=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND roleid=2  AND Disable153_AU=1)
					SELECT @IsDisabledDownline153_51=1
				END
		END
		ELSE IF @RoleID=4	
		BEGIN
			IF EXISTS(SELECT 1 	FROM dbo.CustInfo WITH (NOLOCK)  WHERE srecommend = @CustID AND roleid=3)
					SELECT @HasDownline=1
			IF @HasDownline=1	
				BEGIN
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND roleid=3 AND DisableHorseracing=1)
					SELECT @IsDisabledDownline151_31=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND roleid=3 AND DisableOpenTote=1)
					SELECT @IsDisabledDownline151_41=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND roleid=3 AND Disable151_AU=1)
					SELECT @IsDisabledDownline151_51=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND roleid=3 AND Disable152_UK=1)
					SELECT @IsDisabledDownline152_41=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND roleid=3 AND Disable152_AU=1)
					SELECT @IsDisabledDownline152_51=1
				IF EXISTS(SELECT 1  FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND roleid=3 AND Disable153_AU=1)
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
		
		INSERT INTO @SportBettype(ProductID ,Sporttype , Bettype ,IsDisabled ,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline)
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
	END 

	SELECT ProductID,Sporttype, Bettype,IsDisabled,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline FROM @SportBettype
END
go
GRANT EXECUTE ON [dbo].[Acc_CustomerSelStatusByProductId] TO [bodbAdminNet] -- accouting
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelStatusByProductId]TO [bodbDownlineNet] -- alpha
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelStatusByProductId] TO [bodbExtAccNet] -- External
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelStatusByProductId] TO bodbDownlineNetView

GO 

