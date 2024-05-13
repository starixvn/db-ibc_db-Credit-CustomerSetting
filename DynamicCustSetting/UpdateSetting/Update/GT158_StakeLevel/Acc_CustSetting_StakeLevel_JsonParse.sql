/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE Acc_CustSetting_StakeLevel_JsonParse(
	@StakeLevel	VARCHAR(MAX) OUTPUT 
) 
AS
/*  
	Created: 20240215@Eden
	Task : Convert StakeLevel from Json format to XML format
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20240215@Eden: Unify Live Casino & RNG slot/RNG Casino [Redmine: #198960]
		
	Param's Explanation:
		@StakeLevel = [
			{"SportType": "159","BetType": "3151","StakeLevelList": "3151"},
			{"SportType": "211","BetType": "2401","StakeLevelList": "3151"}
		]

	Example:
		DECLARE @StakeLevel VARCHAR(MAX) = '[
			{"SportType": "159","BetType": "3151","StakeLevelList": "3151"},
			{"SportType": "211","BetType": "2401","StakeLevelList": "3151"}
		]'
		EXEC Acc_CustSetting_StakeLevel_JsonParse @StakeLevel = @StakeLevel OUTPUT
		SELECT CONVERT(XML,@StakeLevel)
 */  
BEGIN 
	SET @StakeLevel = LTRIM(RTRIM(@StakeLevel))
	IF ISNULL(@StakeLevel,'') = '' OR @StakeLevel LIKE '<ROOT>%'
		RETURN


	SELECT @StakeLevel = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,StakeLevelList
					FROM OPENJSON(@StakeLevel) WITH (
							 SportType		SMALLINT  '$.SportType'
							,BetType		SMALLINT  '$.BetType'
							,StakeLevelList	VARCHAR(200)  '$.StakeLevelList'
						)
					FOR XML RAW('StakeLevel'), ROOT ('ROOT'), TYPE
				)
			)
END
GO