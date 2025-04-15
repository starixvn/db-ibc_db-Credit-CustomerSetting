/*<info serverAlias="DBGLOB-GlobCustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_CustomerSelSuggestUsername_DirectMember] 
	@UplineUsername	VARCHAR(30),
	@seqname	VARCHAR(10) = '' OUTPUT,
	@ErrCode 	INT = 0	 OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20241107@Eden		
	Task: Suggest available suffix for new super/master direct member
	DB:  DBCUST/CUSTDB
		
	Revisions:
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 

	Parameter's Explanation:			
	
	Examples:
	DECLARE @seqname VARCHAR(10) = ''
			,@ErrCode INT = 0 
			,@ErrMsg NVARCHAR(4000) = '' 
			,@UplineUsername VARCHAR(30) = 'EdentestS1'
	EXEC GlobCustDB..[Age_CustomerSelSuggestUsername_DirectMember] 
		@UplineUsername = @UplineUsername,
		@seqname = @seqname OUT,
		@ErrMsg = @ErrMsg OUT
	SELECT   @seqname as seqname
			,@ErrMsg AS ErrMsg
	*/ 
BEGIN	
	SET NOCOUNT ON

	DECLARE @RoleID TINYINT, @ExistedSeqname VARCHAR(10) = '', @CustID INT

	SELECT @RoleID = roleid, @CustID = custid FROM CustInfoMini (NOLOCK) WHERE username = @UplineUsername AND roleid IN(3,4)

	IF ISNULL(@UplineUsername,'') = ''
	BEGIN
		SELECT @ErrMsg = 'Invalid super/master'
	     , @ErrCode = 10001
	END

	CREATE TABLE #custSeq_Agent (SeqName VARCHAR(3) PRIMARY KEY)
	CREATE TABLE #custSeq_Member (SeqName VARCHAR(3) PRIMARY KEY)

	INSERT INTO #custSeq_Agent(SeqName)
	SELECT SeqName FROM age_custSeq WITH(NOLOCK) WHERE type = 2

	INSERT INTO #custSeq_Member(SeqName)
	SELECT SeqName FROM age_custSeq WITH(NOLOCK) WHERE type = 1

	IF @RoleID = 4 -- Get latest Super direct member with suitable username pattern, and increase its sequence name
	BEGIN
		SELECT TOP (1) @ExistedSeqname = RIGHT(username,7)
		FROM dbo.CustInfoMini WITH(NOLOCK,INDEX(IX_CustInfoMini_Srecommend))			
		WHERE username LIKE @UplineUsername + '[0-9a-z]' + '[0-9a-z]' + '[0-9a-z]' + '[0-9a-z]' + '[0-9a-z]' + '[0-9a-z]' + '[0-9a-z]'
			AND recommend = -4
			AND srecommend = @CustID
		ORDER BY CustID DESC

		SELECT TOP 1 @seqname = m.SeqName + a.SeqName + p.SeqName
		FROM #custSeq_Agent m
			CROSS JOIN #custSeq_Agent a
			CROSS JOIN #custSeq_Member p
		WHERE NOT EXISTS (
			SELECT TOP 1 1
			FROM dbo.CustInfoMini WITH(NOLOCK)			
			WHERE username LIKE @UplineUsername + m.SeqName + a.SeqName + p.SeqName
				OR username2 LIKE @UplineUsername + m.SeqName + a.SeqName + p.SeqName
			)
			AND NOT EXISTS (
			SELECT TOP 1 1
			FROM dbo.CustSubMini WITH(NOLOCK)			
			WHERE username LIKE @UplineUsername + m.SeqName + a.SeqName + p.SeqName
				OR username2 LIKE @UplineUsername + m.SeqName + a.SeqName + p.SeqName
			)
			AND  m.SeqName + a.SeqName + p.SeqName > @ExistedSeqname
			AND  (	m.SeqName > LEFT( @ExistedSeqname,2)
					OR (m.SeqName = LEFT( @ExistedSeqname,2) AND a.SeqName >= SUBSTRING(@ExistedSeqname,2,2))
				 )
		ORDER BY m.SeqName ASC,a.SeqName ASC ,p.SeqName ASC

		IF ISNULL(@seqname,'') = ''
		BEGIN
			SELECT TOP 1 @seqname = m.SeqName + a.SeqName + p.SeqName
			FROM #custSeq_Agent m
				CROSS JOIN #custSeq_Agent a
				CROSS JOIN #custSeq_Member p
			WHERE NOT EXISTS (
				SELECT TOP 1 1
				FROM dbo.CustInfoMini WITH(NOLOCK)			
				WHERE username LIKE @UplineUsername + m.SeqName + a.SeqName + p.SeqName
					OR username2 LIKE @UplineUsername + m.SeqName + a.SeqName + p.SeqName
				)
				AND NOT EXISTS (
				SELECT TOP 1 1
				FROM dbo.CustSubMini WITH(NOLOCK)			
				WHERE username LIKE @UplineUsername + m.SeqName + a.SeqName + p.SeqName
					OR username2 LIKE @UplineUsername + m.SeqName + a.SeqName + p.SeqName
				)
				AND  m.SeqName + a.SeqName + p.SeqName < @ExistedSeqname
			ORDER BY m.SeqName ASC,a.SeqName ASC ,p.SeqName ASC
		END
	END
	ELSE
	IF @RoleID = 3 -- Get latest Master direct member with suitable username pattern, and increase its sequence name
	BEGIN
		SELECT TOP (1) @ExistedSeqname = RIGHT(username,5)
		FROM dbo.CustInfoMini WITH(NOLOCK,INDEX(IX_CustInfoMini_mrecommend))			
		WHERE username LIKE @UplineUsername + '[0-9a-z]' + '[0-9a-z]' + '[0-9a-z]' + '[0-9a-z]' + '[0-9a-z]'
			AND recommend = -3
			AND mrecommend = @CustID
		ORDER BY CustID DESC

		SELECT TOP 1 @seqname = a.SeqName + p.SeqName
		FROM #custSeq_Agent a
			CROSS JOIN #custSeq_Member p
		WHERE NOT EXISTS (
			SELECT TOP 1 1
			FROM dbo.CustInfoMini WITH(NOLOCK)			
			WHERE username LIKE @UplineUsername + a.SeqName + p.SeqName
				OR username2 LIKE @UplineUsername + a.SeqName + p.SeqName
			)
			AND NOT EXISTS (
			SELECT TOP 1 1
			FROM dbo.CustSubMini WITH(NOLOCK)			
			WHERE username LIKE @UplineUsername + a.SeqName + p.SeqName
				OR username2 LIKE @UplineUsername + a.SeqName + p.SeqName
			)
			AND  a.SeqName + p.SeqName > @ExistedSeqname
			AND  a.SeqName >= LEFT(@ExistedSeqname,2)
		ORDER BY a.SeqName ASC ,p.SeqName ASC

		IF ISNULL(@seqname,'') = ''
			BEGIN
				SELECT TOP 1 @seqname = a.SeqName + p.SeqName
			FROM #custSeq_Agent a
				CROSS JOIN #custSeq_Member p
			WHERE NOT EXISTS (
				SELECT TOP 1 1
				FROM dbo.CustInfoMini WITH(NOLOCK)			
				WHERE username LIKE @UplineUsername + a.SeqName + p.SeqName
					OR username2 LIKE @UplineUsername + a.SeqName + p.SeqName
				)
				AND NOT EXISTS (
				SELECT TOP 1 1
				FROM dbo.CustSubMini WITH(NOLOCK)			
				WHERE username LIKE @UplineUsername + a.SeqName + p.SeqName
					OR username2 LIKE @UplineUsername + a.SeqName + p.SeqName
				)
				AND  a.SeqName + p.SeqName < @ExistedSeqname
			ORDER BY a.SeqName ASC ,p.SeqName ASC
		END
	END
	
	IF ISNULL (@seqname , '') = '' 	
	BEGIN
		SELECT @ErrMsg = 'Sorry, you cannot create more accounts because the total downlines have reached the limit. Please contact your upline for further assistance.'
	     , @ErrCode = 40002
	END
		
	DROP TABLE #custSeq_Member
	DROP TABLE #custSeq_Agent
END
