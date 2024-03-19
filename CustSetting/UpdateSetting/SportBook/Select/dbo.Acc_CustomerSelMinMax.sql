/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelMinMax]
	@custid					INT, 
	@minbet                 MONEY = 0 OUTPUT, 
	@maxbet                 MONEY = 0 OUTPUT, 
	@maxpermatch            MONEY = 0 OUTPUT, 
	@minbetv2               MONEY = 0 OUTPUT, 
	@maxbetv2               MONEY = 0 OUTPUT, 
	@maxpermatchv2          MONEY = 0 OUTPUT, 
	@minbetv3               MONEY = 0 OUTPUT, 
	@maxbetv3               MONEY = 0 OUTPUT, 
	@maxpermatchv3          MONEY = 0 OUTPUT, 
	@minbetv5               MONEY = 0 OUTPUT, 
	@maxbetv5               MONEY = 0 OUTPUT, 
	@maxpermatchv5          MONEY = 0 OUTPUT, 
	@minbetv8               MONEY = 0 OUTPUT, 
	@maxbetv8               MONEY = 0 OUTPUT, 
	@maxpermatchv8          MONEY = 0 OUTPUT, 
	@minbetv10              MONEY = 0 OUTPUT, 
	@maxbetv10              MONEY = 0 OUTPUT, 
	@maxpermatchv10         MONEY = 0 OUTPUT, 
	@minbetv11              MONEY = 0 OUTPUT, 
	@maxbetv11              MONEY = 0 OUTPUT, 
	@maxpermatchv11         MONEY = 0 OUTPUT, 
	@minbetv99              MONEY = 0 OUTPUT, 
	@maxbetv99              MONEY = 0 OUTPUT, 
	@maxpermatchv99         MONEY = 0 OUTPUT, 
	@minbetv99mp            MONEY = 0 OUTPUT, 
	@maxbetv99mp            MONEY = 0 OUTPUT, 
	@maxpermatchv99mp       MONEY = 0 OUTPUT, 
	@minbetv1mp             MONEY = 0 OUTPUT, 
	@maxbetv1mp             MONEY = 0 OUTPUT, 
	@maxpermatchv1mp        MONEY = 0 OUTPUT, 	
	@MaxPayoutPerMatch      MONEY = 0 OUTPUT, 
	@MaxPayoutPerMatchv2    MONEY = 0 OUTPUT, 
	@MaxPayoutPerMatchv3    MONEY = 0 OUTPUT, 
	@MaxPayoutPerMatchv5    MONEY = 0 OUTPUT, 
	@MaxPayoutPerMatchv8    MONEY = 0 OUTPUT, 
	@MaxPayoutPerMatchv10   MONEY = 0 OUTPUT, 
	@MaxPayoutPerMatchv11   MONEY = 0 OUTPUT, 
	@MaxPayoutPerMatchv99   MONEY = 0 OUTPUT, 
	@MaxPayoutPerMatchv99mp MONEY = 0 OUTPUT, 
	@MaxPayoutPerMatchv1mp  MONEY = 0 OUTPUT,
	--Saba
	--- Saba soccer
	@minbetv1saba				MONEY = 0 OUTPUT, 
	@maxbetv1saba				MONEY = 0 OUTPUT, 
	@maxpermatchv1saba			MONEY = 0 OUTPUT, 
	@maxPayoutpermatchv1saba    MONEY = 0 OUTPUT,
	--- Saba basketball
	@minbetv2saba				MONEY = 0 OUTPUT, 
	@maxbetv2saba				MONEY = 0 OUTPUT, 
	@maxpermatchv2saba			MONEY = 0 OUTPUT, 
	@maxPayoutpermatchv2saba	MONEY = 0 OUTPUT
AS
/*
Created: 20110427@Simon
Task : Select customer minbet, maxbet, maxpermatch. 
DB: DBCUST/CUSTDB
Original:

Revisions:
    - 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
    - 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
    - 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
Param's Explanation:
• @custid: custid that need to be viewed.   
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @RoleID INT 
	SELECT @RoleID = RoleID FROM custInfo WITH(NOLOCK) WHERE custid = @custid
	
	--> Get BetSetting
	IF @RoleID = 1
	BEGIN
		SELECT 
			 @minbet				= max(case when cbs.bettype = 1 and cbs.sporttype=1 then cbs.minbet else 0 end)				
			,@maxbet  				= max(case when cbs.bettype = 1 and cbs.sporttype=1 then cbs.maxbet else 0 end)					
			,@MaxPerMatch  			= max(case when cbs.bettype = 1 and cbs.sporttype=1 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatch  	= max(case when cbs.bettype = 1 and cbs.sporttype=1 then cbs.MaxPayoutPerMatch else 0 end)
							 
			,@MinBetv2  			= max(case when cbs.bettype = 1 and cbs.sporttype=2 then cbs.minbet else 0 end)					
			,@MaxBetv2  			= max(case when cbs.bettype = 1 and cbs.sporttype=2 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv2  		= max(case when cbs.bettype = 1 and cbs.sporttype=2 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv2  	= max(case when cbs.bettype = 1 and cbs.sporttype=2 then cbs.MaxPayoutPerMatch else 0 end)
							 
			,@MinBetv3  			= max(case when cbs.bettype = 1 and cbs.sporttype=3 then cbs.minbet else 0 end)					
			,@MaxBetv3  			= max(case when cbs.bettype = 1 and cbs.sporttype=3 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv3  		= max(case when cbs.bettype = 1 and cbs.sporttype=3 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv3  	= max(case when cbs.bettype = 1 and cbs.sporttype=3 then cbs.MaxPayoutPerMatch else 0 end)	
							 
			,@MinBetv5  			= max(case when cbs.bettype = 1 and cbs.sporttype=5 then cbs.minbet else 0 end)					
			,@MaxBetv5  			= max(case when cbs.bettype = 1 and cbs.sporttype=5 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv5  		= max(case when cbs.bettype = 1 and cbs.sporttype=5 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv5  	= max(case when cbs.bettype = 1 and cbs.sporttype=5 then cbs.MaxPayoutPerMatch else 0 end)	
							 
			,@MinBetv8  			= max(case when cbs.bettype = 1 and cbs.sporttype=8 then cbs.minbet else 0 end)					
			,@MaxBetv8  			= max(case when cbs.bettype = 1 and cbs.sporttype=8 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv8  		= max(case when cbs.bettype = 1 and cbs.sporttype=8 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv8  	= max(case when cbs.bettype = 1 and cbs.sporttype=8 then cbs.MaxPayoutPerMatch else 0 end)	
							 
			,@MinBetv10  			= max(case when cbs.bettype = 1 and cbs.sporttype=10 then cbs.minbet else 0 end)					
			,@MaxBetv10  			= max(case when cbs.bettype = 1 and cbs.sporttype=10 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv10  		= max(case when cbs.bettype = 1 and cbs.sporttype=10 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv10  = max(case when cbs.bettype = 1 and cbs.sporttype=10 then cbs.MaxPayoutPerMatch else 0 end)
						 
			,@MinBetv11  			= max(case when cbs.bettype = 1 and cbs.sporttype=11 then cbs.minbet else 0 end)					
			,@MaxBetv11  			= max(case when cbs.bettype = 1 and cbs.sporttype=11 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv11  		= max(case when cbs.bettype = 1 and cbs.sporttype=11 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv11  = max(case when cbs.bettype = 1 and cbs.sporttype=11 then cbs.MaxPayoutPerMatch else 0 end)	
							 
			,@MinBetv99  			= max(case when cbs.bettype = 1 and cbs.sporttype=99 then cbs.minbet else 0 end)					
			,@MaxBetv99  			= max(case when cbs.bettype = 1 and cbs.sporttype=99 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv99  		= max(case when cbs.bettype = 1 and cbs.sporttype=99 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv99  = max(case when cbs.bettype = 1 and cbs.sporttype=99 then cbs.MaxPayoutPerMatch else 0 end)
								 
			,@MinBetv99MP  			= max(case when cbs.bettype = 9 and cbs.sporttype=99 then cbs.minbet else 0 end)					
			,@MaxBetv99MP  			= max(case when cbs.bettype = 9 and cbs.sporttype=99 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv99MP  	= max(case when cbs.bettype = 9 and cbs.sporttype=99 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv99MP = max(case when cbs.bettype = 9 and cbs.sporttype=99 then cbs.MaxPayoutPerMatch else 0 end)
			 
			,@MinBetv1MP  			= max(case when cbs.bettype = 9 and cbs.sporttype=1 then cbs.minbet else 0 end)					
			,@MaxBetv1MP  			= max(case when cbs.bettype = 9 and cbs.sporttype=1 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv1MP  		= max(case when cbs.bettype = 9 and cbs.sporttype=1 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv1MP = max(case when cbs.bettype = 9 and cbs.sporttype=1 then cbs.MaxPayoutPerMatch else 0 end)			 
			
			,@minbetv1saba  			= max(case when cbs.bettype = 1 and cbs.sporttype=9901 then cbs.minbet else 0 end)					
			,@maxbetv1saba  			= max(case when cbs.bettype = 1 and cbs.sporttype=9901 then cbs.maxbet else 0 end)					
			,@maxpermatchv1saba  		= max(case when cbs.bettype = 1 and cbs.sporttype=9901 then cbs.MaxPerMatch else 0 end)				
			,@maxPayoutpermatchv1saba  	= max(case when cbs.bettype = 1 and cbs.sporttype=9901 then cbs.MaxPayoutPerMatch else 0 end)

			,@minbetv2saba  			= max(case when cbs.bettype = 1 and cbs.sporttype=9902 then cbs.minbet else 0 end)					
			,@maxbetv2saba  			= max(case when cbs.bettype = 1 and cbs.sporttype=9902 then cbs.maxbet else 0 end)					
			,@maxpermatchv2saba  		= max(case when cbs.bettype = 1 and cbs.sporttype=9902 then cbs.MaxPerMatch else 0 end)				
			,@maxPayoutpermatchv2saba  	= max(case when cbs.bettype = 1 and cbs.sporttype=9902 then cbs.MaxPayoutPerMatch else 0 end)
		FROM CustBetSetting_Member cbs WITH(NOLOCK) 
		WHERE CustID = @CustId
	END
	ELSE IF @RoleID IN(2,3,4)
	BEGIN
		SELECT 
			 @minbet				= max(case when cbs.bettype = 1 and cbs.sporttype=1 then cbs.minbet else 0 end)				
			,@maxbet  				= max(case when cbs.bettype = 1 and cbs.sporttype=1 then cbs.maxbet else 0 end)					
			,@MaxPerMatch  			= max(case when cbs.bettype = 1 and cbs.sporttype=1 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatch  	= max(case when cbs.bettype = 1 and cbs.sporttype=1 then cbs.MaxPayoutPerMatch else 0 end)
							 
			,@MinBetv2  			= max(case when cbs.bettype = 1 and cbs.sporttype=2 then cbs.minbet else 0 end)					
			,@MaxBetv2  			= max(case when cbs.bettype = 1 and cbs.sporttype=2 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv2  		= max(case when cbs.bettype = 1 and cbs.sporttype=2 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv2  	= max(case when cbs.bettype = 1 and cbs.sporttype=2 then cbs.MaxPayoutPerMatch else 0 end)
							 
			,@MinBetv3  			= max(case when cbs.bettype = 1 and cbs.sporttype=3 then cbs.minbet else 0 end)					
			,@MaxBetv3  			= max(case when cbs.bettype = 1 and cbs.sporttype=3 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv3  		= max(case when cbs.bettype = 1 and cbs.sporttype=3 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv3  	= max(case when cbs.bettype = 1 and cbs.sporttype=3 then cbs.MaxPayoutPerMatch else 0 end)	
							 
			,@MinBetv5  			= max(case when cbs.bettype = 1 and cbs.sporttype=5 then cbs.minbet else 0 end)					
			,@MaxBetv5  			= max(case when cbs.bettype = 1 and cbs.sporttype=5 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv5  		= max(case when cbs.bettype = 1 and cbs.sporttype=5 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv5  	= max(case when cbs.bettype = 1 and cbs.sporttype=5 then cbs.MaxPayoutPerMatch else 0 end)	
							 
			,@MinBetv8  			= max(case when cbs.bettype = 1 and cbs.sporttype=8 then cbs.minbet else 0 end)					
			,@MaxBetv8  			= max(case when cbs.bettype = 1 and cbs.sporttype=8 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv8  		= max(case when cbs.bettype = 1 and cbs.sporttype=8 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv8  	= max(case when cbs.bettype = 1 and cbs.sporttype=8 then cbs.MaxPayoutPerMatch else 0 end)	
							 
			,@MinBetv10  			= max(case when cbs.bettype = 1 and cbs.sporttype=10 then cbs.minbet else 0 end)					
			,@MaxBetv10  			= max(case when cbs.bettype = 1 and cbs.sporttype=10 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv10  		= max(case when cbs.bettype = 1 and cbs.sporttype=10 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv10  = max(case when cbs.bettype = 1 and cbs.sporttype=10 then cbs.MaxPayoutPerMatch else 0 end)
						 
			,@MinBetv11  			= max(case when cbs.bettype = 1 and cbs.sporttype=11 then cbs.minbet else 0 end)					
			,@MaxBetv11  			= max(case when cbs.bettype = 1 and cbs.sporttype=11 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv11  		= max(case when cbs.bettype = 1 and cbs.sporttype=11 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv11  = max(case when cbs.bettype = 1 and cbs.sporttype=11 then cbs.MaxPayoutPerMatch else 0 end)	
							 
			,@MinBetv99  			= max(case when cbs.bettype = 1 and cbs.sporttype=99 then cbs.minbet else 0 end)					
			,@MaxBetv99  			= max(case when cbs.bettype = 1 and cbs.sporttype=99 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv99  		= max(case when cbs.bettype = 1 and cbs.sporttype=99 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv99  = max(case when cbs.bettype = 1 and cbs.sporttype=99 then cbs.MaxPayoutPerMatch else 0 end)
								 
			,@MinBetv99MP  			= max(case when cbs.bettype = 9 and cbs.sporttype=99 then cbs.minbet else 0 end)					
			,@MaxBetv99MP  			= max(case when cbs.bettype = 9 and cbs.sporttype=99 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv99MP  	= max(case when cbs.bettype = 9 and cbs.sporttype=99 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv99MP = max(case when cbs.bettype = 9 and cbs.sporttype=99 then cbs.MaxPayoutPerMatch else 0 end)
			 
			,@MinBetv1MP  			= max(case when cbs.bettype = 9 and cbs.sporttype=1 then cbs.minbet else 0 end)					
			,@MaxBetv1MP  			= max(case when cbs.bettype = 9 and cbs.sporttype=1 then cbs.maxbet else 0 end)					
			,@MaxPerMatchv1MP  		= max(case when cbs.bettype = 9 and cbs.sporttype=1 then cbs.MaxPerMatch else 0 end)				
			,@MaxPayoutPerMatchv1MP = max(case when cbs.bettype = 9 and cbs.sporttype=1 then cbs.MaxPayoutPerMatch else 0 end)	
		 			
			,@minbetv1saba  			= max(case when cbs.bettype = 1 and cbs.sporttype=9901 then cbs.minbet else 0 end)					
			,@maxbetv1saba  			= max(case when cbs.bettype = 1 and cbs.sporttype=9901 then cbs.maxbet else 0 end)					
			,@maxpermatchv1saba  		= max(case when cbs.bettype = 1 and cbs.sporttype=9901 then cbs.MaxPerMatch else 0 end)				
			,@maxPayoutpermatchv1saba  	= max(case when cbs.bettype = 1 and cbs.sporttype=9901 then cbs.MaxPayoutPerMatch else 0 end)

			,@minbetv2saba  			= max(case when cbs.bettype = 1 and cbs.sporttype=9902 then cbs.minbet else 0 end)					
			,@maxbetv2saba  			= max(case when cbs.bettype = 1 and cbs.sporttype=9902 then cbs.maxbet else 0 end)					
			,@maxpermatchv2saba  		= max(case when cbs.bettype = 1 and cbs.sporttype=9902 then cbs.MaxPerMatch else 0 end)				
			,@maxPayoutpermatchv2saba  	= max(case when cbs.bettype = 1 and cbs.sporttype=9902 then cbs.MaxPayoutPerMatch else 0 end)			
		FROM CustBetSetting_Agent cbs WITH(NOLOCK) 
		WHERE CustID = @CustId
	END
END
GO
