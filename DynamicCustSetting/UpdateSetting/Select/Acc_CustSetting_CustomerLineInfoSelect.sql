/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_CustomerLineInfoSelect] 
	  @UserName		NVARCHAR(50)
AS
/*
	Created: 20150622@Dominic
	Task : Get User infor
	DB: DBCUST/CustDB
	Original:

	Param's Explanation:
	
	Revisions:
		- 20250325@Johnson: change datatype for ExchangeID[redmine: #221098]
	*/
BEGIN
	DECLARE @CustID INT
		, @RoleID TINYINT
		, @SAg VARCHAR(20)
		, @MAg VARCHAR(20)
		, @Ag VARCHAR(20)
		, @SRecommend INT
		, @MRecommend INT
		, @Recommend INT
		, @currency INT
		
	SELECT @CustID = CustID
		, @currency = currency
	FROM Custinfo WITH (NOLOCK)
	WHERE UserName = @UserName

	SELECT @UserName = UserName
		, @RoleID = RoleID
		, @SRecommend = SRecommend
		, @MRecommend = MRecommend
		, @Recommend = Recommend
	FROM Custinfo WITH (NOLOCK)
	WHERE CustID = @CustID

	SELECT @SAg = UserName
	FROM Custinfo WITH (NOLOCK)
	WHERE CustID = @SRecommend

	SELECT @MAg = UserName
	FROM Custinfo WITH (NOLOCK)
	WHERE CustID = @MRecommend

	SELECT @Ag = UserName
	FROM Custinfo WITH (NOLOCK)
	WHERE CustID = @Recommend
	
	--Return Customer Infor
	SELECT @CustID CustID
		, @UserName UserName
		, @RoleID RoleID
		, @currency Currency
		, @SRecommend SuperID
		, @MRecommend MasterID
		, @Recommend AgentID
		, @SAg SuperName
		, @MAg MasterName
		, @Ag AgentName
END

GO