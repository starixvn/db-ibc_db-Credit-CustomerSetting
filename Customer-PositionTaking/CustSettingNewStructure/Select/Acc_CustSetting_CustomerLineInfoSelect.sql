SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_CustomerLineInfoSelect] 
	  @UserName		NVARCHAR(50)
AS
/*
	Created: 20150622@Dominic
	Task : Get User infor
	DB: DBCUST/CustDB
	Original:

	Param's Explanation:
	
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
		, @currency TINYINT
		
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
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CustomerLineInfoSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CustomerLineInfoSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CustomerLineInfoSelect] TO [bodbExtAccNet]