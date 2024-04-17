/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="vnteam" isFunction="1"></info>*/
ALTER FUNCTION [dbo].[f_GetSportTypeBetTypeGameType] (
	  @Mode TINYINT,@Server VARCHAR(50))
RETURNS @retbl TABLE (ID INT PRIMARY KEY, Name NVARCHAR(500),IsDisabled BIT,IBCBettypeID INT)
AS

/*
	Created: 20180326@Winnie
	Task: select Sporttype, bettype, gametype from another server
	DB: DBCUST/CUSTDB
	Original:
	Revisions:
		-- 20190329@Winnie: Create function [RedmineID:#91216]
		Param's Explanation:
			@Mode=1: Get Sporttype
			@Mode=2: Get Bettype
			@Mode=3: Get GameType
*/
BEGIN
	IF(@Server='DBAGE')
	BEGIN
			IF(@Mode=1)
			BEGIN
				INSERT INTO @retbl(ID,Name)	
				SELECT SportType, SportName FROM DBAGE.bodb02.dbo.Sports WITH (NOLOCK)	
			END			
			ELSE IF (@Mode=2)	
			BEGIN
				INSERT INTO @retbl(ID,Name)	
				SELECT TypeID, TypeNamee FROM DBAGE.bodb02.dbo.Bettype WITH (NOLOCK)				
			END
			ELSE IF (@Mode=3)	
			BEGIN
				INSERT INTO @retbl(ID,Name,IsDisabled,IBCBettypeID)	
				SELECT GameTypeID, GameTypeName,IsDisabled,IBCBettypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK)				
			END	
	END
	ELSE IF(@Server='DBTXN')
	BEGIN
		IF(@Mode=1)
		BEGIN
			INSERT INTO @retbl(ID,Name)	
			SELECT SportType, SportName FROM DBTXN.bodb02.dbo.Sports WITH (NOLOCK)	
		END	
		ELSE IF (@Mode=2)	
		BEGIN
			INSERT INTO @retbl(ID,Name)	
			SELECT TypeID, TypeNamee FROM DBTXN.bodb02.dbo.Bettype WITH (NOLOCK)				
		END
		ELSE IF (@Mode=3)	
		BEGIN
			INSERT INTO @retbl(ID,Name,IsDisabled,IBCBettypeID)	
			SELECT GameTypeID, GameTypeName,IsDisabled,IBCBettypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK)				
		END
	END
	RETURN;
END


GO