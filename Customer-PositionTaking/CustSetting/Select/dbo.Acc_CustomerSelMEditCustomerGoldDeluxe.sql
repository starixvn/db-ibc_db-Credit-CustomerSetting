USE [bodb02]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelMEditCustomerGoldDeluxe]    Script Date: 05/12/2015 17:09:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_CustomerSelMEditCustomerGoldDeluxe]
	@custid		INT
AS
/*
	Created: 20150422@Elodie
	Task: Master select edits Gold Deluxe PT settings on member
	DB: DBAGE/BODB02
	
	Revisions:

	Parameters Explanation:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @AgentID							INT,
			@MasterID							INT,
			@SuperID							INT,
			@roleid								TINYINT,			
			@v255mpositiontaking_1701_max		SMALLMONEY,
			@v255mpositiontaking_1701_min		SMALLMONEY,
			@max_v255spositiontaking_1701		SMALLMONEY,
			@isauto_v255mpositiontaking_1701	BIT,
			@DisableAutoMPT						BIT	,
			@DisableGoldDeluxe					BIT,
			@DisableUpline						BIT

	SELECT	@AgentID = recommend,
			@MasterID = mrecommend,
			@SuperId = srecommend,
			@roleid	 = roleid,
			@DisableGoldDeluxe = DisableGoldDeluxe
	FROM	custinfo WITH(NOLOCK)
	WHERE	custid = @custid
	
	IF @roleid <> 1
		RETURN
		
	SELECT	@DisableUpline = DisableGoldDeluxe
	FROM	custinfo WITH(NOLOCK)
	WHERE	custid = @AgentID
	
	--get DisableAutoMPT
	SELECT	@DisableAutoMPT = DisableAutoMPT
	FROM	custmaster WITH(NOLOCK)
	WHERE	custid = @MasterID

	-- get is master auto on agent
	SELECT	@isauto_v255mpositiontaking_1701 = isautompositiontaking
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @AgentID 
			AND sporttype = 255 
			AND bettype = 1701 
	
	SELECT	@v255mpositiontaking_1701_max = mpositiontaking
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @MasterID 
			AND sporttype = 255 
			AND bettype = 1701

	SELECT	@max_v255spositiontaking_1701 = spositiontaking
	FROM	custsettingGame WITH(NOLOCK)
	WHERE	custid = @SuperID 
			AND sporttype = 255 
			AND bettype = 1701

	SELECT	@v255mpositiontaking_1701_min = minpositiontaking
	FROM	CustOverrideGame WITH(NOLOCK)
	WHERE	custid = @MasterID 
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
			,@DisableUpline		AS DisableUpline
			,ISNULL(@DisableGoldDeluxe,0) AS DisableGoldDeluxe
			,0 AS Downlines
			,0 AS DisableDownlines
	FROM	dbo.Customer WITH (NOLOCK)
	WHERE	custID = @CustID  
	
	--PT & commission
	SELECT 	
			ISNULL(@DisableAutoMPT,0) AS DisableAutoMPT,
			mpositiontaking AS v255mpositiontaking_1701,
			apositiontaking	AS V255apositiontaking_1701,
			autompositiontaking AS auto_v255mpositiontaking_1701_mem,
			isautompositiontaking AS isauto_v255mpositiontaking_1701_mem,

			@isauto_v255mpositiontaking_1701 AS isauto_v255mpositiontaking_1701,

			@v255mpositiontaking_1701_max AS auto_v255mpositiontaking_1701_max,
			
			--m1_max = m3 - a1
			@v255mpositiontaking_1701_max - apositiontaking AS v255mpositiontaking_1701_max,

			CASE WHEN @v255mpositiontaking_1701_min - apositiontaking < 0 THEN 0 ELSE @v255mpositiontaking_1701_min - apositiontaking END AS v255mpositiontaking_1701_min
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 255 
			AND bettype = 1701

	-- bet setting
	EXEC dbo.Acc_CustomerSelStakeLevelGoldDeluxe
		@custid		= @custid
		,@UplineId	= @AgentID
END







GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerGoldDeluxe] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerGoldDeluxe] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerGoldDeluxe] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelMEditCustomerGoldDeluxe] TO [vnteam] AS [dbo]