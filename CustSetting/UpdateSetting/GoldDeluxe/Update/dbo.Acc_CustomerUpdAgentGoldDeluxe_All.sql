ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentGoldDeluxe_All]	
	@custid								INT,
	@mrecommend							INT,
	@v255mpositiontaking_1701			SMALLMONEY,
	@auto_v255mpositiontaking_1701		SMALLMONEY,
	@isauto_v255mpositiontaking_1701	BIT,

	@v255apositiontaking_1701			SMALLMONEY,
	@min_v255apositiontaking_1701		SMALLMONEY,
	@v255discount_1701					SMALLMONEY,	
	
	@v255UpdatePositiontaking_1701		BIT = 1,
	@v255UpdateAutoPositiontaking_1701  BIT = 1,
	@v255UpdateMinPositiontaking_1701	BIT = 1,
	@v255UpdateCommission_1701			BIT = 1,
	
	@updateallmembers					BIT = 0,
	@newmpositiontaking					SMALLMONEY = 0,--equals max(m+a) - chosen(a)

	@userid								INT,
	@SubAccID							INT = 0, --Sub-AccountID
	@Language							VARCHAR(2) = 'E',
	@IP									VARCHAR(19),	
	@ErrCode							VARCHAR(300) = '' OUTPUT,
	@ErrMsg								NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20150422@Elodie
	Task: master edit Gold Deluxe PT setting on agent
	DB: DBTXN/CustDB
	
	Revisions:
		- 20150610@Elodie: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable to DBCUST, Change Age_CustomerSelCheckBelonging to Age_CustomerSelCheckBelongingByCustID)
		- 20151008@Elodie: Hot fix n2 is updated although a2 is not updated [Redmine:#45208]
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]			            
	Parameters Explanation:
*/
BEGIN

	SET NOCOUNT ON 

	DECLARE @roleid			TINYINT, 
			@ErrCode_Cur	INT, 
			@ErrMsg_Cur		NVARCHAR(4000), 
			@ErrAcc			NVARCHAR(4000)
			
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	---------------------------
	-- ***Check Downline Belonging***
	EXEC Age_CustomerSelCheckBelonging 
		@SessionCustID = @mrecommend, 
		@Custid = @custid,
		@roleid = @roleid OUTPUT
		IF @roleid = 0 RETURN
	---------------------------

	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
	--Check disable user
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT	@ErrCode = @ErrCode + CONVERT(VARCHAR(300),@ErrCode_cur) + CHAR(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN
	END

	--update commission
	IF @v255UpdateCommission_1701 = 1
	BEGIN
								EXEC dbo.Acc_CustomerUpdAgentGoldDeluxe_Commission
					@custid				= @custid,
					@v255discount_1701	= @v255discount_1701,
					@UserID				= @UserID, 
					@SubAccID			= @SubAccID,
					@Language			= @Language, 
					@IP					= @IP,  
					@ErrCode			= @ErrCode_Cur OUTPUT, 
					@ErrMsg				= @ErrMsg_Cur OUTPUT

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT  @ErrCode = @ErrCode + CONVERT(VARCHAR(300),@ErrCode_cur) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			
			RETURN
		END
		ELSE
		BEGIN 
		 	SELECT	@ErrCode =  @ErrCode + '-101' + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

		END
	END						

	-- update positiontaking
	IF @v255UpdatePositiontaking_1701 = 1 OR @v255UpdateAutoPositiontaking_1701 = 1
	BEGIN
		SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''

								EXEC dbo.Acc_CustomerUpdAgentGoldDeluxe_PositionTaking 
					@custid								= @custid,					
					@v255mpositiontaking_1701			= @v255mpositiontaking_1701,
					@auto_v255mpositiontaking_1701		= @auto_v255mpositiontaking_1701,
					@isauto_v255mpositiontaking_1701	= @isauto_v255mpositiontaking_1701,
					@v255apositiontaking_1701			= @v255apositiontaking_1701,
					@min_v255apositiontaking_1701		= @min_v255apositiontaking_1701,					
					@updateallmembers					= @updateallmembers,
					@newmpositiontaking					= @newmpositiontaking,
					
					@v255UpdatePositiontaking_1701		= @v255UpdatePositiontaking_1701,
					@v255UpdateAutoPositiontaking_1701	= @v255UpdateAutoPositiontaking_1701,
					
					@SubAccID							= @SubAccID,
					@UserID								= @UserID,
					@Language							= @Language,
					@IP									= @IP,
					@ErrCode							= @ErrCode_Cur OUTPUT,
					@ErrMsg								= @ErrMsg_Cur OUTPUT			
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
		ELSE
		BEGIN
			SELECT @ErrCode = @ErrCode + '-103'+ CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
		END
	END

	IF @v255UpdateMinPositiontaking_1701 = 1 
	BEGIN
								EXEC Acc_CustOverrideUpdGoldDeluxe 
				@custid						= @custid, 
				@UplineID					= @mrecommend,
				@min_v255positiontaking_1701= @min_v255apositiontaking_1701, 
				@IP							= @IP, 
				@UserID						= @UserID, 
				@SubAccID					= @SubAccID,
				@Language					= @Language, 
				@ErrCode					= @ErrCode, 
				@ErrMsg						= @ErrMsg

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)						
		END
		ELSE
		BEGIN
			SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
		END
	END

END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentGoldDeluxe_All] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentGoldDeluxe_All] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentGoldDeluxe_All] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentGoldDeluxe_All] TO [vnteam] AS [dbo]