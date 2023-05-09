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
		- 20200713@Eden: Integrate 3 new bet types for Keno [Redmine: #137475]
		- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
		- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
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

	SELECT ProductID,Sporttype, Bettype,IsDisabled,IsSync,IsHidden,IsDisabledUpline,IsHiddenUpline,IsSyncedUpline, 
		ISNULL(TotalDisabledMasters,0) TotalDisabledMasters, ISNULL(TotalEnabledMasters,0) TotalEnabledMasters, 
		ISNULL(TotalDisabledAgents,0) TotalDisabledAgents, ISNULL(TotalEnabledAgents,0) TotalEnabledAgents, 
		ISNULL(TotalDisabledMembers,0) TotalDisabledMembers, ISNULL(TotalEnabledMembers,0) TotalEnabledMembers
	FROM @SportBettype
END
GO