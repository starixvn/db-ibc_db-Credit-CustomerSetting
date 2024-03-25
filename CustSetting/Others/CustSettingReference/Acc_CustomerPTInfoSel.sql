/*<info serverAlias="DBAGE-bodb02" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustomerPTInfoSel]     
	@CustID			INT	= NULL
,	@Site			VARCHAR(10) = NULL
,	@IsTest			TINYINT	= 0
AS

/*
	Created: 
	Task : Get PT Infor of a SportsBook
	DB: DBAGE/bodb02
	Original: DBTXN - Acc_CustomerSelRefSport_Bettype

	Revisions:
		--20231114@Johnson: Hide bettype SABA for site 777777 [redmine: #194591]
		- 20231019@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083] 

	Param's Explanation:
		@CustID (Login account): =NULL: Admin ; =NOT NULL: SMA 
		@isShowAll: 0: Show Active Bettype, 1: Show ALL 
		@IsTest: 0 is get PRO | 3 is get UAT

	Sportbettypematrix.IsTest = 0 : PRO  || = 1 : Test UAT
	Sportbettypematrix.Enabled = 0 : Non-Used(don't Active)  || 1 : Used (active)

	Sample: EXEC [Acc_CustomerPTInfoSel_UAT2] @CustID = 19096909 , @IsTest = 0
*/

BEGIN

	SET NOCOUNT ON 

	DECLARE 
		@SpecialPlatform	TINYINT = 0
	,	@srecommend		INT

	--20231114@Johnson: Hide bettype SABA for site 777777 [redmine: #194591]
	IF ISNULL(@CustID,0) <> 0
	BEGIN
		SELECT @Site = Site, @srecommend = srecommend
		FROM Customer WITH (NOLOCK)
		WHERE custid = @CustID
	END

	SELECT @SpecialPlatform = SpecialPlatfrom
	FROM Site WITH (NOLOCK)
	WHERE Site = @Site
	--End #194591
	     
	SELECT DISTINCT  b.typedesc , b1.typeid
	FROM bettype b WITH (NOLOCk)
	INNER JOIN SportBettypeMatrix sbm WITH (NOLOCK) ON b.typeid = sbm.BetType
	INNER JOIN bettype b1 WITH (NOLOCK) ON b.DisplayedTypeID = b1.typeid
	WHERE 
	sbm.ProductID = 1
	AND b.typedesc IN ('915','916','917','918')
	AND sbm.Enabled = 1
	AND 1 = CASE WHEN @SpecialPlatform = 4 AND b1.typeid IN (228,229) THEN 0 ELSE 1 END --Hide bettype SABA xxx for 777777
	AND sbm.IsTest = CASE WHEN @IsTest = 0 THEN 0 ELSE sbm.IsTest END
	ORDER BY b.typedesc
        	 
END



