 ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentLiveCS_CheckParam]
	@custid								INT,
	
	@v162mpositiontaking_1101			SMALLMONEY,
	@auto_v162mpositiontaking_1101		SMALLMONEY,
	@isauto_v162mpositiontaking_1101	BIT = 0,
	@v162apositiontaking_1101			SMALLMONEY,
	@min_v162apositiontaking_1101		SMALLMONEY,
	
	@Language							VARCHAR(2) = 'E',
	@ErrCode							INT = 0 OUTPUT,
	@ErrMsg								NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-07-25
		Task: Check paramter before update pt live casino
		DB: DBTXN/CustDB
		
		Revisions:
			- 20140925@Johnson: Remove bettype name from error message
		Parameter's explanation:
	*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @UserName			NVARCHAR(50), 
			@mrecommend			INT, 
			@srecommend			INT, 
			@SyncLiveCasino		BIT,
			@max_v162mapositiontaking_1101 SMALLMONEY,
			@ErrAcc				VARCHAR(4000), 
			@ErrType			VARCHAR(4000)
	
	SELECT @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend, @SyncLiveCasino = SyncLiveCasino 
	FROM custinfo WITH(NOLOCK) 
	WHERE CustID = @CustID
	
	IF	@v162apositiontaking_1101 < 0	
		OR @v162mpositiontaking_1101 < 0
		OR @v162apositiontaking_1101 + @v162mpositiontaking_1101 > 1
	BEGIN
		SELECT @ErrCode = 100
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
					END
		RETURN
	END
	
	--check n3<=m2+a2  if im2 = 0, 
	--a2<=l3 and um2+a2>=n3 if im2 = 1
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + 'Min: '+ CAST((co.minpositiontaking) AS VARCHAR(10))+ '<br>'
	FROM custoverrideGame co WITH(NOLOCK)
		INNER JOIN 
			(
				SELECT 1101 AS bettype, 162 AS sporttype, @v162apositiontaking_1101 AS apositiontaking, @v162mpositiontaking_1101 AS mpositiontaking, @isauto_v162mpositiontaking_1101 AS isauto_mpositiontaking, @auto_v162mpositiontaking_1101 AS auto_mpositiontaking
			) b ON co.sporttype = b.sporttype AND co.bettype = b.bettype				
	WHERE co.custid = @mrecommend AND (	
						((b.isauto_mpositiontaking = 0) AND (b.mpositiontaking + b.apositiontaking < co.minpositiontaking)) or 
						(b.isauto_mpositiontaking > 0 AND (b.apositiontaking + b.auto_mpositiontaking < co.minpositiontaking))
					)
	IF @ErrType <>''
	BEGIN
		SELECT @ErrCode = 101
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					END
		RETURN
	END
	
	--n2<=a2
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + 'Min: '+ CAST((co.minpositiontaking) AS VARCHAR(10)) + '<br>'
	FROM 
		( 
			SELECT 1101 AS bettype, 162 AS sporttype, @min_v162apositiontaking_1101 AS minpositiontaking
		) AS co
		INNER JOIN 
		(
			select 1101 AS bettype, 162 AS sporttype, @v162apositiontaking_1101 AS apositiontaking
		) AS b ON co.sporttype = b.sporttype AND co.bettype = b.bettype				
	WHERE b.apositiontaking < co.minpositiontaking

	IF @ErrType <>''
	BEGIN
		SELECT @ErrCode = 102
		SELECT @ErrMsg = case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		RETURN
	END
	
	SELECT @max_v162mapositiontaking_1101 = mpositiontaking 
	FROM CustSettingGame WITH(NOLOCK) 
	WHERE custid = @mrecommend AND bettype = 1101 AND sporttype = 162
	
	
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType +  'Max: '+ cast((b.max_mapositiontaking) as varchar(10)) + '<br>'
	FROM
		(				
			select 1101 as bettype, 162 as sporttype, @v162apositiontaking_1101 AS apositiontaking, @v162mpositiontaking_1101 AS mpositiontaking, @max_v162mapositiontaking_1101 AS max_mapositiontaking
		) b				
	WHERE (b.apositiontaking + b.mpositiontaking > b.max_mapositiontaking) 

	IF @ErrType <>''
	BEGIN
		select @ErrCode = 103
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking.<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
					end		
		return
	END
	
	--check um2<=min(m3,l3) - Phuc@20081209
	select @ErrType = ''
	select @ErrType = @ErrType + 'Max: '+ cast(max_mapositiontaking as varchar(10)) + '<br>'
	from 
	(
		select 1101 AS bettype, 162 as sporttype, @auto_v162mpositiontaking_1101 as autopositiontaking, @isauto_v162mpositiontaking_1101 as isautopositiontaking, @max_v162mapositiontaking_1101 as max_mapositiontaking		
	) as b 				
	where b.isautopositiontaking = 1 
		AND b.autopositiontaking > max_mapositiontaking
		

	if @ErrType <>''
	BEGIN
		select @ErrCode = 104
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking.<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
					end		
		return
	END
	
END
