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
		- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
		- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]

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
	
	SELECT ProductID,Sporttype, Bettype,IsDisabled,IsDisabledDownline,HasDownline,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline,IsSyncedDownline FROM @SportBettype
END

GO
