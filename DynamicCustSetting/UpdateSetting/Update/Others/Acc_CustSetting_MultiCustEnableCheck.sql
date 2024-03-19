/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="vnteam" isFunction="0"></info>*/ 

ALTER PROCEDURE [dbo].[Acc_CustSetting_MultiCustEnableCheck] 
	  @CustIDList	VARCHAR(MAX)	= ''
	, @ErrCode		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(200)	= ''	OUTPUT
AS
/*
		Created: Dominic
		Date: 2014-12-08
		Task: Check enabled status for a list of costumers
		DB: DBCUST/CustDB
		Revisions:	
			- 20220613@Elodie: DBCUST - modify sp syntax to adapt with the SQL Server upgrade to 2019 [Redmine: #171831]  
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @UserNames NVARCHAR(4000) = ''
	DECLARE @tblCust TABLE (CustID INT)

	--Parse CustID
	INSERT INTO @tblCust (CustID)
	SELECT CONVERT(INT, value)
	FROM string_split(@CustIDList, ',')
	WHERE value <> ''

	SELECT TOP 100 @UserNames = @UserNames + ci.username + ','
	FROM custinfo ci WITH (NOLOCK)
	INNER JOIN @tblCust tmp
		ON tmp.CustID = ci.CustID
	WHERE ISNULL(ci.enabled, 0) = 0

	IF @@ROWCOUNT > 0
	BEGIN
		IF @UserNames <> ''
			SET @UserNames = LEFT(@UserNames, LEN(@UserNames) - 1)

		SELECT @ErrMsg = 'Some accounts were disabled!' + CASE 
				WHEN @UserNames IS NOT NULL
					AND @UserNames <> ''
					THEN '(' + @UserNames + ')'
				ELSE ''
				END
			, @ErrCode = 600

		RETURN
	END
END
GO