 ALTER PROCEDURE [dbo].[Acc_CustomerSettingsCloneFromRealAccount]
	@fromUsername	VARCHAR(50),
	@toUsername		VARCHAR(50),
	@userID			INT,
	@IP				VARCHAR(30)= '',
	@ErrCode		INT = 0 OUTPUT,
	@ErrMsg			VARCHAR(500) = '' OUTPUT
 AS	
	/*
		Created: Johnson
		Date: 2015-01-27
		Task: clone settings(PT,comm,bet settings) from real account to test account for checking issue
		DB: DBTXN/CustDB
		
		Revisions:
		
		Parameter's Explantion:
	*/
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @fromCustID INT,
			@fromCurrency INT,
			@fromRoleid	INT,
			@fromSuperID INT,
			@fromMasterID INT,
			@fromAgentID INT,
			
			@toCustID	INT,			
			@toCurrency INT,
			@toRoleid	INT,
			@toSuperID INT,
			@toMasterID INT,
			@toAgentID INT
	
	DECLARE @tmpUser TABLE (fromCustID INT, toCustID INT, roleid INT)		
	
	SELECT @fromCustID = CustID
		,@fromCurrency = Currency
		,@fromRoleid = roleid
		,@fromSuperID = srecommend
		,@fromMasterID = mrecommend
		,@fromAgentID = recommend 
	FROM customer (NOLOCK) 
	WHERE username = @fromUsername
	
	SELECT @toCustID = CustID
		,@toCurrency = Currency
		,@toRoleid = roleid
		,@toSuperID = srecommend
		,@toMasterID = mrecommend
		,@toAgentID = recommend
	FROM customer (NOLOCK) 
	WHERE username = @toUsername
	
	
	IF @toCurrency <> 20 OR ISNULL(@toCustID,0) = 0 
		OR @fromRoleid <> @toRoleid
		OR EXISTS(SELECT 1 FROM Dep_custSuper WITH(NOLOCK) WHERE custid = @toSuperID)	
	BEGIN
		SELECT @ErrCode = 100,
				@ErrMsg = 'Invalid test account'
		RETURN
	END
	
	IF ISNULL(@fromCustID,0) = 0 OR @fromRoleid NOT IN (1,2,3,4)
		OR EXISTS(SELECT 1 FROM Dep_custSuper WITH(NOLOCK) WHERE custid = @fromSuperID)	
	BEGIN
		SELECT @ErrCode = 101,
				@ErrMsg = 'Invalid real account'
		RETURN
	END
		
	IF @fromRoleid = 4
	BEGIN
		INSERT INTO @tmpUser (fromCustID, toCustID, roleid)
		SELECT @fromCustID, @toCustID, 4
	END
	ELSE IF @fromRoleid = 3
	BEGIN
		INSERT INTO @tmpUser (fromCustID, toCustID, roleid)
		SELECT @fromCustID, @toCustID, 3
		UNION 
		SELECT @fromSuperID, @toSuperID, 4
	END
	ELSE IF @fromRoleid = 2
	BEGIN
		INSERT INTO @tmpUser (fromCustID, toCustID, roleid)
		SELECT @fromCustID, @toCustID, 2
		UNION 
		SELECT @fromSuperID, @toSuperID, 4
		UNION 
		SELECT @fromMasterID, @toMasterID, 3
	END
	ELSE IF @fromRoleid = 1
	BEGIN
		INSERT INTO @tmpUser (fromCustID, toCustID, roleid)
		SELECT @fromCustID, @toCustID, 1
		UNION 
		SELECT @fromSuperID, @toSuperID, 4
		UNION 
		SELECT @fromMasterID, @toMasterID, 3
		UNION 
		SELECT @fromAgentID, @toAgentID, 2		
	END
	
	
	UPDATE cs
	SET  cs.[apositiontaking] = cs2.[apositiontaking]
	  ,cs.[mpositiontaking] = cs2.[mpositiontaking]
	  ,cs.[spositiontaking] = cs2.[spositiontaking]
	  ,cs.[alivepositiontaking] = cs2.[alivepositiontaking]
	  ,cs.[mlivepositiontaking] = cs2.[mlivepositiontaking]
	  ,cs.[slivepositiontaking] = cs2.[slivepositiontaking]
	  ,cs.[playerdiscount] = cs2.[playerdiscount]
	  ,cs.[discount] = cs2.[discount]
	  ,cs.[adiscount] = cs2.[adiscount]
	  ,cs.[sdiscount] = cs2.[sdiscount]
	  ,cs.[groupa] = cs2.[groupa]
	  ,cs.[groupb] = cs2.[groupb]
	  ,cs.[groupc] = cs2.[groupc]
	  ,cs.[groupd] = cs2.[groupd]
	  ,cs.[groupe] = cs2.[groupe]
	  ,cs.[groupf] = cs2.[groupf]
	  ,cs.[minbet] = cs2.[minbet]
	  ,cs.[maxbet] = cs2.[maxbet]
	  ,cs.[autopositiontaking]	= cs2.[autopositiontaking]
	  ,cs.[autolivepositiontaking] = cs2.[autolivepositiontaking]
	  ,cs.[isautopositiontaking] = cs2.[isautopositiontaking]
	  ,cs.[isautolivepositiontaking] = cs2.[isautolivepositiontaking]
	  ,cs.[autompositiontaking]	= cs2.[autompositiontaking]
	  ,cs.[autolivempositiontaking] = cs2.[autolivempositiontaking]
	  ,cs.[isautompositiontaking] = cs2.[isautompositiontaking]
	  ,cs.[isautolivempositiontaking] = cs2.[isautolivempositiontaking]
	FROM custSetting cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN custSetting cs2 WITH(NOLOCK) ON cs.sporttype = cs2.sporttype
													AND cs.bettype = cs2.bettype
		INNER JOIN @tmpUser t ON cs.custid = t.toCustID AND cs2.custid = t.fromCustID													
	
	IF @@Error <> 0
	BEGIN
		SELECT @ErrCode = 103,
				@ErrMsg = 'Clone settings fails. Please try again'
		RETURN
	END		
	
	UPDATE cs
	SET cs.[minpositiontaking]		= cs2.[minpositiontaking]
	  ,cs.[maxpositiontaking]		= cs2.[maxpositiontaking]
	  ,cs.[minlivepositiontaking]	= cs2.[minlivepositiontaking]
	  ,cs.[maxlivepositiontaking]	= cs2.[maxlivepositiontaking]
	FROM custoverride cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN custoverride cs2 WITH(NOLOCK) ON cs.sporttype = cs2.sporttype
													AND cs.bettype = cs2.bettype
		INNER JOIN @tmpUser t ON cs.custid = t.toCustID AND cs2.custid = t.fromCustID	
	WHERE t.roleid <> 1
	
	IF @@Error <> 0
	BEGIN
		SELECT @ErrCode = 104,
				@ErrMsg = 'Clone settings fails. Please try again'
		RETURN
	END		
	
	UPDATE cs
	SET  cs.[apositiontaking]		=   cs2.[apositiontaking]			
	  ,cs.[mpositiontaking]			=	cs2.[mpositiontaking]
	  ,cs.[spositiontaking]			=	cs2.[spositiontaking]
	  ,cs.[playerdiscount]			=	cs2.[playerdiscount]
	  ,cs.[discount]				=	cs2.[discount]
	  ,cs.[adiscount]				=	cs2.[adiscount]
	  ,cs.[sdiscount]				=	cs2.[sdiscount]
	  ,cs.[minbet]					=	cs2.[minbet]
	  ,cs.[maxbet]					=	cs2.[maxbet]
	  ,cs.[autopositiontaking]		=	cs2.[autopositiontaking]
	  ,cs.[isautopositiontaking]	=	cs2.[isautopositiontaking]
	  ,cs.[autompositiontaking]		=	cs2.[autompositiontaking]
	  ,cs.[isautompositiontaking]	=	cs2.[isautompositiontaking]
	  ,cs.[alivepositiontaking]		=	cs2.[alivepositiontaking]
	  ,cs.[mlivepositiontaking]		=	cs2.[mlivepositiontaking]
	  ,cs.[slivepositiontaking]		=	cs2.[slivepositiontaking]
	  ,cs.[autolivepositiontaking]	=	cs2.[autolivepositiontaking]
	  ,cs.[isautolivepositiontaking] =	cs2.[isautolivepositiontaking]
	  ,cs.[autolivempositiontaking]	 =	cs2.[autolivempositiontaking]
	  ,cs.[isautolivempositiontaking] =	cs2.[isautolivempositiontaking]
	FROM CustSetting3rd cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN CustSetting3rd cs2 WITH(NOLOCK) ON cs.sporttype = cs2.sporttype
													AND cs.bettype = cs2.bettype
		INNER JOIN @tmpUser t ON cs.custid = t.toCustID AND cs2.custid = t.fromCustID		
	
	IF @@Error <> 0
	BEGIN
		SELECT @ErrCode = 105,
				@ErrMsg = 'Clone settings fails. Please try again'
		RETURN
	END		
	
	UPDATE cs
	SET cs.[minpositiontaking]		= cs2.[minpositiontaking]
	  ,cs.[maxpositiontaking]		= cs2.[maxpositiontaking]
	  ,cs.[minlivepositiontaking]	= cs2.[minlivepositiontaking]
	  ,cs.[maxlivepositiontaking]	= cs2.[maxlivepositiontaking]
	FROM custOverride3rd cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN custOverride3rd cs2 WITH(NOLOCK) ON cs.sporttype = cs2.sporttype
													AND cs.bettype = cs2.bettype
		INNER JOIN @tmpUser t ON cs.custid = t.toCustID AND cs2.custid = t.fromCustID		
	WHERE t.roleid <> 1
	
	IF @@Error <> 0
	BEGIN
		SELECT @ErrCode = 106,
				@ErrMsg = 'Clone settings fails. Please try again'
		RETURN
	END	
	
	UPDATE cs
	SET cs.[apositiontaking]		= cs2.[apositiontaking]
	  ,cs.[mpositiontaking]			= cs2.[mpositiontaking]
	  ,cs.[spositiontaking]			= cs2.[spositiontaking]
	  ,cs.[playerdiscount]			= cs2.[playerdiscount]
	  ,cs.[discount]				= cs2.[discount]
	  ,cs.[adiscount]				= cs2.[adiscount]
	  ,cs.[sdiscount]				= cs2.[sdiscount]
	  ,cs.[autopositiontaking]		= cs2.[autopositiontaking]
	  ,cs.[isautopositiontaking]	= cs2.[isautopositiontaking]
	  ,cs.[autompositiontaking]		= cs2.[autompositiontaking]
	  ,cs.[isautompositiontaking]	= cs2.[isautompositiontaking]
	FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN CustSettingGame cs2 WITH(NOLOCK) ON cs.sporttype = cs2.sporttype
													AND cs.bettype = cs2.bettype
		INNER JOIN @tmpUser t ON cs.custid = t.toCustID AND cs2.custid = t.fromCustID	
	
	IF @@Error <> 0
	BEGIN
		SELECT @ErrCode = 107,
				@ErrMsg = 'Clone settings fails. Please try again'
		RETURN
	END		
	
	UPDATE cs
	SET cs.[minpositiontaking] = cs2.[minpositiontaking]
	FROM CustOverrideGame cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN CustOverrideGame cs2 WITH(NOLOCK) ON cs.sporttype = cs2.sporttype
													AND cs.bettype = cs2.bettype
		INNER JOIN @tmpUser t ON cs.custid = t.toCustID AND cs2.custid = t.fromCustID	
	WHERE t.roleid <> 1									
		
	IF @@Error <> 0
	BEGIN
		SELECT @ErrCode = 108,
				@ErrMsg = 'Clone settings fails. Please try again'
		RETURN
	END				
	
	UPDATE cg
	SET cg.minbet = cg2.minbet,
		cg.maxbet = cg2.maxbet,
		cg.MaxPerGameType = cg2.MaxPerGameType
	FROM CustGameType cg WITH(UPDLOCK,ROWLOCK)
		INNER JOIN CustGameType cg2 WITH(NOLOCK) ON cg.GameTypeID = cg2.GameTypeID													
		INNER JOIN @tmpUser t ON cg.custid = t.toCustID AND cg2.custid = t.fromCustID	
		
	IF @@Error <> 0
	BEGIN
		SELECT @ErrCode = 109,
				@ErrMsg = 'Clone settings fails. Please try again'
		RETURN
	END	
	
	UPDATE c
	SET c.maxpermatch = c2.maxpermatch,
		c.maxpermatch2 = c2.maxpermatch2,
		c.maxpermatch3 = c2.maxpermatch3,
		c.maxpermatch5 = c2.maxpermatch5,
		c.maxpermatch8 = c2.maxpermatch8,
		c.maxpermatch10 = c2.maxpermatch10,
		c.maxpermatch11 = c2.maxpermatch11,
		
		c.maxpermatch99 = c2.maxpermatch99,
		c.MaxPerMatch99MP = c2.MaxPerMatch99MP,	
		c.maxpermatch151 = c2.maxpermatch151,
		c.maxpermatch151_OT = c2.maxpermatch151_OT,		
		c.MaxPerMatch151_AU = c2.MaxPerMatch151_AU,
		c.MaxPerMatch152_UK = c2.MaxPerMatch152_UK,
		c.MaxPerMatch152_AU = c2.MaxPerMatch152_AU,
		c.MaxPerMatch153_AU = c2.MaxPerMatch153_AU,
		c.maxpermatch154 = c2.maxpermatch154,
		c.maxpermatch161 = c2.maxpermatch161,
		c.MaxPerBall161 = c2.MaxPerBall161,
		
		c.maxpermatch180 = c2.maxpermatch180,
		c.maxpermatch181 = c2.maxpermatch181,
		c.maxpermatch182 = c2.maxpermatch182,
		c.maxpermatch183 = c2.maxpermatch183,
		c.maxpermatch184 = c2.maxpermatch184,
		c.maxpermatch185 = c2.maxpermatch185,
		c.maxpermatch186 = c2.maxpermatch186,
		
		c.MaxPerMatch201 = c2.MaxPerMatch201
	FROM @tmpUser t 
		INNER JOIN CustInfo c WITH(UPDLOCK,ROWLOCK) ON c.custid = t.toCustID
		INNER JOIN CustInfo c2 WITH(NOLOCK) ON c2.custid = t.fromCustID	
		
	IF @@Error <> 0
	BEGIN
		SELECT @ErrCode = 109,
				@ErrMsg = 'Clone settings fails. Please try again'
		RETURN
	END	
	
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSettingsCloneFromRealAccount] TO [bodbAdminNet]