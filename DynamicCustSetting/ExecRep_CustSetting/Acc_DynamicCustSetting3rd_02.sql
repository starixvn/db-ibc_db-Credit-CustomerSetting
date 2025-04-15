/*<info serverAlias="DBCust-CustDB" executers="wsv_nap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_02]
	@CustID		INT,
	@RoleID		INT,
	@StakeLevel	VARCHAR(MAX) = NULL,
	@BetLimit	VARCHAR(MAX) = NULL,
	@Mode		VARCHAR(20) = 'StakeLevel'
AS
/*
	Created: 20160121@Billy
	Task : Update Customer's Stake Level Settings - [Redmine: #51026]
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20161005@Elodie: Update LastUpdated field - [Redmine: #54994]
		- 20210727@Elodie: Adjust downline's betsetting [Redmine: #158073]
		- 20220511@Tacy: Insert history of member bet setting [RedmineID: #170739]
		- 20241203@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 

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
	SET NOCOUNT ON
	DECLARE @CustList VARCHAR(MAX), @ErrMsg VARCHAR(MAX)
	DECLARE	@iDoc INT, @BatchNo INT, @SportbettypeCount INT
	CREATE TABLE #Agent(custid INT, RoleID INT)
	CREATE TABLE #Member(custid INT)
	CREATE TABLE #AgentTmpBatch(custid INT)
	CREATE TABLE #MemberTmpBatch(custid INT)

	DECLARE @HistoryTbl TABLE (
			CustID				INT
			, SportType			SMALLINT
			, BetType			SMALLINT
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			, StakeLevelList	VARCHAR(200)
			, UpdateTime		DATETIME
		)

	IF @Mode = 'StakeLevel'
	BEGIN
		IF NOT (dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
			AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT	
		)
		RETURN;

		CREATE TABLE #StakeLevel (
				CustID			INT
			,	BetType			INT
			,	StakeLevelList	VARCHAR(200)
			,	PRIMARY KEY CLUSTERED (CustID, BetType)
		)

		-- Read XML
		EXECUTE sys.sp_xml_preparedocument @iDoc OUTPUT, @StakeLevel

		INSERT INTO	#StakeLevel
			(	CustID   , BetType   , StakeLevelList)
		SELECT	ox.CustID, ox.BetType, ox.StakeLevelList
		FROM	OPENXML(@iDoc, '/ROOT/StakeLevel', 1)
				WITH (
					CustID			INT
				,	BetType			INT
				,	StakeLevelList	VARCHAR(200)
				) AS ox

		EXECUTE sys.sp_xml_removedocument @iDoc

		UPDATE csla
		SET	csla.StakeLevelList = sl.StakeLevelList,
			RepUpdateTime = dbo.f_GetDateTime2()
		FROM		dbo.CustStakeLevel_Agent AS csla WITH(ROWLOCK,UPDLOCK)
		INNER JOIN	#StakeLevel AS sl
				ON	sl.CustID  = csla.CustID
				AND	sl.BetType = csla.BetType

		UPDATE cslm
		SET	cslm.StakeLevelList = sl.StakeLevelList
			, cslm.LastUpdated = GETDATE()
			, RepUpdateTime = dbo.f_GetDateTime2()
		OUTPUT deleted.CustID, deleted.SportType, deleted.BetType, deleted.StakeLevelList, inserted.LastUpdated
			INTO @HistoryTbl(CustID, SportType, BetType, StakeLevelList, UpdateTime)
		FROM		dbo.CustStakeLevel_Member AS cslm WITH(ROWLOCK,UPDLOCK)
		INNER JOIN	#StakeLevel AS sl
				ON	sl.CustID = cslm.CustID
				AND	sl.BetType = cslm.BetType

		--insert Bet Setting history
		SET @CustList = (SELECT	CustID			AS '@CustID',
								SportType		AS '@SportType',
								BetType			AS '@BetType',
								'NULL'			AS '@MaxBet',
								'NULL'			AS '@MaxPerMatch',
								StakeLevelList	AS '@StakeLevelList',
								UpdateTime		AS '@UpdateTime'
					FROM @HistoryTbl
					FOR XML PATH('r'), ROOT ('root')
					)
		
		EXECUTE Acc_DynamicCustSetting3rd_08 @CustList=@CustList, @ErrMsg = @ErrMsg OUTPUT;

		IF @ErrMsg <> ''
			RETURN

		DROP TABLE #StakeLevel
	END
END
GO