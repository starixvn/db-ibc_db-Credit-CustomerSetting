USE [bodb02]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelEditSuperGoldDeluxe]    Script Date: 05/12/2015 16:58:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE[dbo].[Acc_CustomerSelEditSuperGoldDeluxe]    
	@custid  INT    
AS    
 /*    
  Created: Kathy    
  Date: 20150424    
  Task: Company edits super's gold deluxe setting    
  DB: DBAGE.BODB02    
      
  Revisions:    
  
  Parameters Explanations:    
       
 */    
BEGIN
		
	SET NOCOUNT ON    
	    
	DECLARE @min_spositiontaking	SMALLMONEY    
			,@Downlines				BIT	= 1
			,@DisableDownlines		BIT = 0
			,@DisableGoldDeluxe		BIT 
		
	IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE srecommend = @CustID AND roleid = 3)
		SET @Downlines = 0	
	ELSE IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE srecommend = @custid AND roleid = 3 AND DisableGoldDeluxe = 1)
		SET @DisableDownlines = 1
		
	SELECT	@DisableGoldDeluxe = DisableGoldDeluxe
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @custid
	    
	SELECT	@min_spositiontaking = minpositiontaking    
	FROM	CustOverrideGame WITH(NOLOCK)    
	WHERE	custid = @custid 
			AND sporttype = 255 
			AND bettype = 1701  
	
	--Customer Info
	SELECT	username
			,username2 AS nickname
			,firstname
			,lastname
			,phone
			,mobilephone
			,fax
			,0								AS DisableUpline
			,ISNULL(@DisableGoldDeluxe,0)	AS DisableGoldDeluxe
			,@Downlines						AS Downlines
			,@DisableDownlines				AS DisableDownlines
	FROM	dbo.Customer WITH (NOLOCK)
	WHERE	custID = @CustID   	    
	     
	 --PT & commission
	 SELECT	ISNULL(@min_spositiontaking,0)	AS v255spositiontaking_1701_min,    
		    gs.MaxPositiontaking			AS v255spositiontaking_1701_max,    
		    cs.spositiontaking				AS v255spositiontaking_1701,    
		    cs.sdiscount					AS v255sdiscount_1701,    
		    gs.Maxsdiscount					AS v255sdicount_1701_max    
	 FROM	CustSettingGame cs WITH(NOLOCK)
	 INNER JOIN ProductGlobalSetting gs
		ON	gs.Sporttype =  cs.Sporttype 
			AND gs.IsDep = 0
	 WHERE custid = @custid 
			AND cs.sporttype = 255 
			AND cs.bettype = 1701    
			
	-- bet setting
	EXEC dbo.Acc_CustomerSelStakeLevelGoldDeluxe
		@custid		= @custid
		,@UplineId	= @custid
		
END






GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperGoldDeluxe] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperGoldDeluxe] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperGoldDeluxe] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperGoldDeluxe] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditSuperGoldDeluxe] TO [vnteam] AS [dbo]