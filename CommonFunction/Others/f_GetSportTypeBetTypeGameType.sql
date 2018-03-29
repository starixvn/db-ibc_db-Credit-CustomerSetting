/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="vnteam" isFunction="0"></info>*/
ALTER FUNCTION [dbo].[f_GetSportTypeBetTypeGameType] (
	  @Mode TINYINT)
RETURNS @retbl TABLE (ID INT, Name NVARCHAR(500),IsDisabled BIT,IBCBettypeID INT)
AS
/*
	Created: 20180326@Winnie
	Task: select Sporttype, bettype, gametype from another server
	DB: DBCUST/CUSTDB
	Original:
	Revisions:
		Param's Explanation:
			@Mode=1: Get Sporttype
			@Mode=2: Get Bettype
			@Mode=3: Get GameType
*/
BEGIN
		IF(@Mode=1)
		BEGIN	
			INSERT INTO @retbl(ID,Name)	
			SELECT SportType, SportName FROM DBAGE.bodb02.dbo.Sports WITH (NOLOCK)	
			IF @@ERROR<>0
			INSERT INTO @retbl(ID,Name)	
			SELECT SportType, SportName FROM DBTXN.bodb02.dbo.Sports WITH (NOLOCK)		
		END
		ELSE IF (@Mode=2)	
		BEGIN
			INSERT INTO @retbl(ID,Name)	
			SELECT TypeID, TypeNamee FROM DBAGE.bodb02.dbo.Bettype WITH (NOLOCK)
			IF @@ERROR<>0
			INSERT INTO @retbl(ID,Name)	
			SELECT TypeID, TypeNamee FROM DBTXN.bodb02.dbo.Bettype WITH (NOLOCK)
		END
		ELSE IF (@Mode=3)	
		BEGIN
			INSERT INTO @retbl(ID,Name,IsDisabled,IBCBettypeID)	
			SELECT GameTypeID, GameTypeName,IsDisabled,IBCBettypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK)
			IF @@ERROR<>0
			INSERT INTO @retbl(ID,Name,IsDisabled,IBCBettypeID)	
			SELECT GameTypeID, GameTypeName,IsDisabled,IBCBettypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK)
		END
	RETURN;
END