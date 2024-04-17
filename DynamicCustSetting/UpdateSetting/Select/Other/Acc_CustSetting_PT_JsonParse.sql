/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE Acc_CustSetting_PT_JsonParse(
	@PTSetting	VARCHAR(MAX) OUTPUT 
) 
AS
/*  
	Created: 20240109@Eden
	Task : Convert PT from Json format to XML format
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20240109@Eden: DCS Sportsbook Credit[redmine: #193083]
		
	Param's Explanation:
		@PTSetting = [
			{"SportType": "9914","BetType": "915","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "87"},
			{"SportType": "9914","BetType": "917","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
			{"SportType": "9913","BetType": "917","IsLive": "1","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
			{"SportType": "9915","BetType": "918","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
			{"SportType": "9913","BetType": "915","IsLive": "1","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
			{"SportType": "9913","BetType": "916","IsLive": "1","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
			{"SportType": "9914","BetType": "916","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"}
		]

	Example:
		DECLARE @PTSetting VARCHAR(MAX) = '[
			{"SportType": "9914","BetType": "915","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "87"},
			{"SportType": "9914","BetType": "917","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
			{"SportType": "9913","BetType": "917","IsLive": "1","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
			{"SportType": "9915","BetType": "918","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
			{"SportType": "9913","BetType": "915","IsLive": "1","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
			{"SportType": "9913","BetType": "916","IsLive": "1","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
			{"SportType": "9914","BetType": "916","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"}
		]'
		EXEC Acc_CustSetting_PT_JsonParse @PTSetting = @PTSetting OUTPUT
		SELECT CONVERT(XML,@PTSetting)
 */  
BEGIN 
	SET @PTSetting = LTRIM(RTRIM(@PTSetting))
	IF ISNULL(@PTSetting,'') = '' OR @PTSetting LIKE '<ROOT>%'
		RETURN


	SELECT @PTSetting = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,IsLive
						,SuperPT,MasterPT,AgentPT,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT,MinPT,MaxPT
						,IsAuto_New,IsAuto_Old,IsUpdAllMems,UpdAllMems_Value
					FROM OPENJSON(@PTSetting) WITH (
							 SportType		SMALLINT  '$.SportType'
							,BetType		SMALLINT  '$.BetType'
							,IsLive			BIT  '$.IsLive'
							--PT setting
							,SuperPT		SMALLMONEY '$.SuperPT'
							,MasterPT		SMALLMONEY '$.MasterPT'
							,AgentPT		SMALLMONEY '$.AgentPT'
							,IsAutoMasterPT	BIT		   '$.IsAutoMasterPT'
							,AutoMasterPT	SMALLMONEY '$.AutoMasterPT'
							,IsAutoSuperPT	BIT		   '$.IsAutoSuperPT'
							,AutoSuperPT	SMALLMONEY '$.AutoSuperPT'
							,MinPT			SMALLMONEY '$.MinPT'
							,MaxPT			SMALLMONEY '$.MaxPT'
							--Auto
							,IsAuto_New		BIT '$.IsAuto_New'
							,IsAuto_Old		BIT '$.IsAuto_Old'
							,IsUpdAllMems	BIT '$.IsUpdAllMems'
							,UpdAllMems_Value	SMALLMONEY '$.UpdAllMems_Value'
						)
					FOR XML RAW('PT'), ROOT ('ROOT'), TYPE
				)
			)
END