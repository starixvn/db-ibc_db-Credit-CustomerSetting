/*<info serverAlias="DBMSG-bodb_Message" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [DBA_Archive_PrivateMessageForSuperMaster]
(
	@SMList			VARCHAR(MAX) = NULL,	
	@Stage				TINYINT = 1
)
AS
/*
	Created: 20200505@Max
	Task: Archiving credit accounts process for Master & Agent levels [Redmine: #130032]
	DB: DBMSG.bodb_message

	Revisions:
		- 20200505@Max: Archiving credit accounts process for Master & Agent levels [Redmine: #130032]
	Param's Explanation:
		@SMList: list Super, Master ID
		@Stage: kind of message when sending
			= 1: stage 1
			= 2: stage 2
			= 3: satge 3
	EXEC DBA_Archive_PrivateMessageForSuperMaster @SMList = N'<ROOT><SM CustId="791088" UserName="AA" GroupLevelName="S1"/><SM CustId="860379" UserName="BB" GroupLevelName="M2"/></ROOT>', @Stage = 2
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @MessageID INT

	--SELECT @MessageID = CASE WHEN @Stage = 1 THEN 1074255111 ELSE 1074255112 END -- hard code

	DECLARE @Creator INT, @CreatorName NVARCHAR(50), @CustID INT, @UserName VARCHAR(30), @i INT, @Max INT, @GroupLevelName VARCHAR(10)
	DECLARE @Content_en NVARCHAR(4000)
			, @Content_vn NVARCHAR(4000)
			, @Content_ch NVARCHAR(4000) -- Traditional
			, @Content_cs NVARCHAR(4000) -- Simplified
			, @Content_th NVARCHAR(4000) -- Thai


	DECLARE @PostTime DATETIME
	SELECT @PostTime = GETDATE()

	SELECT @Creator = 10278938, @CreatorName = 'starixIT'	
		
	-- Handle Master information
	DECLARE @TempMember AS TABLE (ID INT IDENTITY(1,1), Custid int, Username varchar(30), GroupLevelName VARCHAR(10))
	DECLARE @DocHandler	INT

	BEGIN TRY
		EXEC sp_xml_preparedocument @DocHandler OUTPUT, @SMList

		INSERT INTO @TempMember ( Custid, Username, GroupLevelName)
		SELECT CustId, UserName, GroupLevelName
		FROM OPENXML(@DocHandler, '/ROOT/SM', 1) WITH (CustId INT, UserName VARCHAR(30), GroupLevelName VARCHAR(10)) AS Data

		EXEC sp_xml_removedocument @DocHandler
	END TRY

	BEGIN CATCH
		SELECT ErrCode = 100
			,ErrMsg = N'Paramter invalid.'

		RETURN
	END CATCH;	
	
	-- Insert Message Target	
	SET @i = 1
	SELECT @Max = Max(ID) FROM @TempMember

	WHILE @i <= @Max
	BEGIN
		SELECT @CustID = custid, @UserName = username, @GroupLevelName = GroupLevelName FROM @TempMember WHERE ID = @i

		SELECT @Content_en = cm.Content_en,
			@Content_ch = cm.Content_ch,
			@Content_cs = cm.Content_cs,
			@Content_vn = cm.Content_vn,
			@Content_th = cm.Content_th
		FROM dbo.CustArchiveMessage cm WITH (NOLOCK)
		WHERE cm.StageID = @Stage
			AND cm.GroupLevelName = @GroupLevelName
		
		-- Insert message
		EXEC dbo.Dot_Msg_SetMessage2 
			@MessageId	= @MessageId OUTPUT,
			@Content_en = @Content_en,
			@Content_ch = @Content_ch,
			@Content_cs = @Content_cs,
			@Content_th = @Content_th,
			@Content_vn = @Content_vn,
			@MsgType	= 1,			 -- message to customer (personal)
			@IsSticky	= 0,			 -- Is special Message or not 
			@Creator	= @Creator,
			@CreatorName = @CreatorName,
			@IsTest		= 0,			 -- Is test or not 
			@IsBatch	= 0			 -- normal message (no need to replace the symbol @@ by transid when display)

		EXEC dbo.Dot_Msg_SetUsrMessage
		@MessageId	= @MessageId,
		@TargetId	= @CustID,
		@TargetName = @UserName,
		@PostTime	= @PostTime,
		@isRead		= 0		
		
		SELECT @i = @i + 1
	END
	
END