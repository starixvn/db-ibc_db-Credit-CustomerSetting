ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_02]
		@CustID		INT
	,	@RoleID		INT
	,	@StakeLevel	VARCHAR(MAX) = NULL
AS
/*
	Created: 20160121@Billy
	Task : Update Customer's Stake Level Settings - [Redmine: #51026]
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20161005@Elodie: Update LastUpdated field - [Redmine: #54994]
	Param's Explanation:
		@StakeLevel:
		<ROOT>
				<StakeLevel 
						CustID="12345"
						BetType="2401" 
						StakeLevelList="1,2,3,4,5"
				/>
		</ROOT>
*/
BEGIN
	SET NOCOUNT ON;

	IF dbo.f_CheckRepTable('CustStakeLevel_Agent') = 0
		RETURN;
	IF dbo.f_CheckRepTable('CustStakeLevel_Member') = 0
		RETURN;

	DECLARE	@iDoc			INT;

	CREATE TABLE #StakeLevel (
			CustID			INT
		,	BetType			INT
		,	StakeLevelList	VARCHAR(200)
		,	PRIMARY KEY CLUSTERED (CustID, BetType)
	);

	-- Read XML
	EXECUTE sys.sp_xml_preparedocument @iDoc OUTPUT, @StakeLevel;

	INSERT INTO	#StakeLevel
		(	CustID   , BetType   , StakeLevelList)
	SELECT	ox.CustID, ox.BetType, ox.StakeLevelList
	FROM	OPENXML(@iDoc, '/ROOT/StakeLevel', 1)
			WITH (
				CustID			INT
			,	BetType			INT
			,	StakeLevelList	VARCHAR(200)
			) AS ox;

	EXECUTE sys.sp_xml_removedocument @iDoc;

	UPDATE csla
	SET	csla.StakeLevelList = sl.StakeLevelList
	FROM		dbo.CustStakeLevel_Agent AS csla WITH(ROWLOCK,UPDLOCK)
	INNER JOIN	#StakeLevel AS sl
			ON	sl.CustID  = csla.CustID
			AND	sl.BetType = csla.BetType;

	UPDATE cslm
	SET	cslm.StakeLevelList = sl.StakeLevelList
		, cslm.LastUpdated = GETDATE()
	FROM		dbo.CustStakeLevel_Member AS cslm WITH(ROWLOCK,UPDLOCK)
	INNER JOIN	#StakeLevel AS sl
			ON	sl.CustID = cslm.CustID
			AND	sl.BetType = cslm.BetType;

	DROP TABLE #StakeLevel;
END;