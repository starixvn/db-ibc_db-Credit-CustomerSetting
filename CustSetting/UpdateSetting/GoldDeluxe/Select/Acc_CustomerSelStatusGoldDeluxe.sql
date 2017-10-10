/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelStatusGoldDeluxe]
	@CustId		INT,
	@ErrCode	INT				= 0		OUTPUT,
	@ErrMsg		VARCHAR(500)	= ''	OUTPUT
AS
/*
	Created: Winnie
	Date: 2017-06-28
	Task: Get status Gold Deluxe of customer
	DB: DBCUST.CustDB

	Revisions:
		- 20170628@Winnie : Create new SP RedmineID: #72957	
		- 20170918@Johnson: Fix the unsynchronized setting, remove IsSyncedDownline,
							and fix hasDownline status to show checkbox enable downline [Redmine: #72973]
							+hasDownline = 1: has at least one customer has sync status
										=0 : all downlines not sync			
							
	Parameter's Explanation:
 */
 BEGIN
       
SET NOCOUNT ON           
	DECLARE 
	   @srecommend  INT,          
	   @mrecommend  INT,          
	   @recommend  INT,               
	   @roleid   TINYINT,  
	   @IsDisabled			BIT, 
	   @IsSync				BIT,            
	   @HasDownline			BIT=0,
	   @IsDisabledUpline    BIT,
	   @IsSyncedUpline		BIT,
	   @IsDisabledDownline	BIT=0

			   
	SELECT @IsDisabled = ISNULL(DisableGoldDeluxe,1),  
			@IsSync=CASE WHEN HideGoldDeluxe=0 THEN 1 ELSE 0 END,   
			@roleid=roleid,
			@recommend = recommend,          
			@mrecommend = mrecommend,          
			@srecommend = srecommend          
	FROM dbo.custinfo WITH(NOLOCK)          
	WHERE custid = @custid    

	IF @roleid NOT IN (1,2,3,4)            
	BEGIN          
	  SELECT @ErrMsg = 'Invalid user.',          
		@ErrCode = 100          
	  RETURN          
	END                 
 
	IF @roleid = 4 
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE srecommend = @custid AND DisableGoldDeluxe = 1 AND HideGoldDeluxe = 0)
			SET @IsDisabledDownline = 1
		IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE srecommend = @custid AND HideGoldDeluxe = 0 AND custid <> @custid)
			SET @hasDownline = 1
		
		SELECT @IsDisabledUpline = 0,@IsSyncedUpline=1
	END
	ELSE IF @roleid = 3
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE mrecommend = @custid AND DisableGoldDeluxe = 1 AND HideGoldDeluxe = 0)
			SET @IsDisabledDownline = 1
		IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE mrecommend = @custid AND HideGoldDeluxe = 0 AND custid <> @custid)
			SET @hasDownline = 1
		
		SELECT @IsDisabledUpline = DisableGoldDeluxe,
			@IsSyncedUpline=CASE WHEN HideGoldDeluxe=0 THEN 1 ELSE 0 END 
		FROM dbo.custinfo WITH(NOLOCK) 
		WHERE custid = @srecommend    	
	END
	ELSE IF @roleid = 2
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE recommend = @custid AND DisableGoldDeluxe = 1 AND HideGoldDeluxe = 0)
			SET @IsDisabledDownline = 1
		IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE recommend = @custid AND HideGoldDeluxe = 0 AND custid <> @custid)
			SET @hasDownline = 1
		
		SELECT @IsDisabledUpline = DisableGoldDeluxe,
				@IsSyncedUpline=CASE WHEN HideGoldDeluxe=0 THEN 1 ELSE 0 END 
		FROM dbo.custinfo WITH(NOLOCK) 
		WHERE custid = @mrecommend          	
	END
	ELSE 
	BEGIN
		SET @IsDisabledDownline = 0
		SET @hasDownline = 0
		
		SELECT @IsDisabledUpline = DisableGoldDeluxe,
				@IsSyncedUpline=CASE WHEN HideGoldDeluxe=0 THEN 1 ELSE 0 END 
		FROM dbo.custinfo WITH(NOLOCK) 
		WHERE custid = @recommend          
	END
      
           
	IF ISNULL(@IsSyncedUpline,0) = 0          
	BEGIN          
	  SELECT @ErrMsg = 'The upline is not offered Gold Deluxe.',          
		@ErrCode = 101          
	  RETURN          
	END          
           
	SELECT 12				AS	ProductID,          
		255					AS	Sporttype,    
		1700				AS	Bettype,       
		@IsDisabled			AS  IsDisabled,
		@IsSync				AS	IsSync , 		
		@HasDownline		AS	HasDownline,
		@IsDisabledUpline   AS  IsDisabledUpline,
		@IsSyncedUpline		AS	IsSyncedUpline,
		@IsDisabledDownline	AS	IsDisabledDownline
END
GO
