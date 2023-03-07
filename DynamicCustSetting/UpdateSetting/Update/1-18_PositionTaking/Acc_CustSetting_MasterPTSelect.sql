/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE Acc_CustSetting_MasterPTSelect
	@CustID			INT  
	, @ProductID	TINYINT
	, @SettingStatus TINYINT = 0  
AS  
/*  
	Created: 20200612@Elodie
	Task : Get Master'PT values of a product  
	DB:  DBCUST/CustDB  
	Original:  
 
	Revision:
		- 20200612@Elodie: Initial SP for setting type 18 [Redmine: #135363]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	
	Param's Explanation:  
		- @CustID: Master's ID  
		- @SettingStatus: 0: Pro, 1: UAT
   
 */  
BEGIN  
	DECLARE @SuperID INT  

	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT, IsLive BIT, SettingType SMALLINT)

	INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive, SettingType)
	SELECT SportType,Bettype,IsLive, SettingType 
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,18,@SettingStatus)

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[MaxPT]	[smallmoney],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,MaxPT)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,MaxPT 
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)
	
	SELECT @SuperID=ci.srecommend  
	FROM dbo.custInfo ci WITH(NOLOCK)  
	WHERE ci.custid=@CustID  
	
	SELECT pdt.SportType  
		, pdt.BetType  
		, pdt.IsLive  
		, pt.superPT  AS S3  
		, pt.masterPT  AS M3  
		, pt.IsAutoSuperPT AS IS3  
		, pt.AutoSuperPT AS US3  
		, pt.minPT   AS N3  
		, superpt.SuperPT AS S4  
		, superpt.MasterPT AS M4  
		, superpt.MinPT  AS N4  
	FROM #ProductSettingDetail pdt WITH (NOLOCK)  
	INNER JOIN #SportBettypeFilter ft 
			ON pdt.SportType = ft.sporttype
				AND pdt.BetType = ft.bettype
				AND pdt.IsLive = ft.islive
				AND pdt.SettingType = ft.SettingType
	INNER JOIN dbo.CustPTSetting3rd_Agent pt WITH (NOLOCK)  
		ON pdt.SportType = pt.sporttype  
		AND pdt.BetType = pt.bettype  
		AND pdt.IsLive = pt.islive  
		AND pt.custid = @CustID  
	INNER JOIN dbo.CustPTSetting3rd_Agent superpt WITH (NOLOCK)  
		ON pdt.SportType = superpt.sporttype  
		AND pdt.BetType = superpt.bettype  
		AND pdt.IsLive = superpt.islive  
		AND superpt.custid = @SuperID   
	ORDER BY pdt.SportType, pdt.BetType, pdt.IsLive  

	DROP TABLE #SportBettypeFilter
	DROP TABLE #ProductSettingDetail
END  

GO