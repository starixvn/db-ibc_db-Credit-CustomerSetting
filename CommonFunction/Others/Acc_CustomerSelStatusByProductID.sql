/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" isFunction="0"></info>*/
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
		- 20190820@Eden: Hide setting of inactive products - Colossus Bet [RedmineID: #117439]
		- 20190903@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
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
		SELECT @RoleID=RoleID,@IsDisabled=ISNULL(DisableColossusBet,1),@isHidden=ISNULL(HideColossusBet,1),@recommend=recommend,@mrecommend=mrecommend,@srecommend=srecommend FROM custInfo WITH(NOLOCK) WHERE custid=@custid
		IF @RoleID=2
		BEGIN
			SELECT @IsHiddenUpline=ISNULL(HideColossusBet,1),@IsDisabledUpline=ISNULL(DisableColossusBet,1) FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@mrecommend
			IF EXISTS(SELECT 1  FROM dbo.CustInfo WITH (NOLOCK)  WHERE recommend = @CustID AND roleid=1)
				SELECT @HasDownline=1
			IF @HasDownline=1
				IF EXISTS(SELECT 1 FROM custInfo WITH(NOLOCK) WHERE recommend=@custid AND ISNULL(DisableColossusBet,1)=1)
					SELECT @IsDisabledDownline=1
		END		
		ELSE IF @RoleID=3	
		BEGIN
			SELECT @IsHiddenUpline=ISNULL(HideColossusBet,1),@IsDisabledUpline=ISNULL(DisableColossusBet,1)  FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@srecommend
			IF EXISTS(SELECT 1 FROM dbo.CustInfo WITH (NOLOCK)	WHERE mrecommend = @CustID AND roleid=2)
				SELECT @HasDownline=1
			IF @HasDownline=1
				IF EXISTS(SELECT 1 FROM custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND ISNULL(DisableColossusBet,1)=1)
					SELECT @IsDisabledDownline=1
		END		
		ELSE IF @RoleID=4	
		BEGIN
			IF EXISTS(SELECT 1 FROM dbo.CustInfo WITH (NOLOCK)  WHERE srecommend = @CustID AND roleid=3)
				SELECT @HasDownline=1
			IF @HasDownline=1
				IF EXISTS(SELECT 1 FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND ISNULL(DisableColossusBet,1)=1)	
					SELECT @IsDisabledDownline=1
		END
		ELSE IF @RoleID=1
		BEGIN
			SELECT @IsHiddenUpline=ISNULL(HideColossusBet,1),@IsDisabledUpline=ISNULL(DisableColossusBet,1)  FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@recommend
		END
		INSERT INTO @SportBettype(ProductID ,Sporttype , Bettype ,IsDisabled ,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline)
		VALUES(@ProductID,204,18000,@IsDisabled,@IsDisabledDownline,@HasDownline,@IsSync,@isHidden,@IsDisabledUpline,@IsHiddenUpline,@IsSyncedUpline,@IsSyncedDownline)		
	END 	
	
	
	ELSE IF @ProductID=6 -- Casino
	BEGIN
		SELECT @RoleID=RoleID,@IsDisabled=DisableCasino,@IsSync=ISNULL(SyncCasino,0),@recommend=recommend,@mrecommend=mrecommend,@srecommend=srecommend FROM custInfo WITH(NOLOCK) WHERE custid=@custid
		IF @RoleID=2
		BEGIN
			SELECT @IsSyncedUpline=ISNULL(SyncCasino,0),@IsDisabledUpline=DisableCasino FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@mrecommend
			IF EXISTS(SELECT 1	FROM dbo.CustInfo WITH (NOLOCK)	WHERE recommend = @CustID AND roleid=1 AND SyncCasino=1)
					SELECT @HasDownline=1
			IF @HasDownline=1
			BEGIN
				IF EXISTS(SELECT 1 FROM  custInfo WITH(NOLOCK) WHERE recommend=@custid AND DisableCasino=1 AND SyncCasino=1)
					SELECT @IsDisabledDownline=1
				IF EXISTS(SELECT 1 FROM  custInfo WITH(NOLOCK) WHERE recommend=@custid AND roleid=1 AND ISNULL(SyncCasino,0)=0)
					SELECT @IsSyncedDownline=0
			END
		END		
		ELSE IF @RoleID=3
		BEGIN	
			SELECT @IsSyncedUpline=ISNULL(SyncCasino,0),@IsDisabledUpline=DisableCasino FROM dbo.CustInfo WITH (NOLOCK)  WHERE custid=@srecommend
			IF EXISTS(SELECT 1	FROM dbo.CustInfo WITH (NOLOCK)	WHERE mrecommend = @CustID AND roleid=2 AND SyncCasino=1)
				SELECT @HasDownline=1
			IF @HasDownline=1
			BEGIN
				IF EXISTS(SELECT 1 FROM  custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND DisableCasino=1 AND SyncCasino=1)
					SELECT @IsDisabledDownline=1
				IF EXISTS(SELECT 1 FROM  custInfo WITH(NOLOCK) WHERE mrecommend=@custid AND roleid=2 AND ISNULL(SyncCasino,0)=0)
					SELECT @IsSyncedDownline=0
			END
		END
		ELSE IF @RoleID=4	
		BEGIN	
			
			IF EXISTS(SELECT 1	FROM dbo.CustInfo WITH (NOLOCK)	WHERE srecommend = @CustID AND roleid=3 AND SyncCasino=1)
				SELECT @HasDownline=1
			IF @HasDownline=1
			BEGIN
				
				IF EXISTS(SELECT 1 FROM custInfo WITH(NOLOCK) WHERE srecommend=@custid AND DisableCasino=1  AND SyncCasino=1)
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

		INSERT INTO @SportBettype(ProductID ,Sporttype , Bettype ,IsDisabled ,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline,GameTypeID)	
		SELECT 8,202,IBCBetTypeID,NULL,NULL,0,1,0,0,0,1,1,GameTypeID		
		FROM DBACC.bodb02.dbo.Gametype WHERE  IBCBetTypeID BETWEEN 1501 AND 1599 AND IBCBetTypeID NOT IN(1502,1507,1509) AND IsDisabled = 0 

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
									WHERE  srecommend= @custid AND ct.IsDisabled = 1 AND s.GameTypeID=ct.GameTypeID)
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
										WHERE  mrecommend= @custid AND ct.IsDisabled = 1 AND s.GameTypeID=ct.GameTypeID)
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
									WHERE  recommend= @custid AND ct.IsDisabled = 1 AND s.GameTypeID=ct.GameTypeID)
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
		
		DELETE FROM @SportBettype WHERE IsDisabled IS NULL	

	END 
	
	SELECT ProductID,Sporttype, Bettype,IsDisabled,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline FROM @SportBettype
END

GO
