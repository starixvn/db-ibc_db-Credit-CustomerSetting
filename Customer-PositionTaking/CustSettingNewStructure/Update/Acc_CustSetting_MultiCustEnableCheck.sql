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
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @UserNames NVARCHAR(4000) = ''
	DECLARE @tblCust TABLE (CustID INT)

	--Parse CustID
	INSERT INTO @tblCust (CustID)
	SELECT CONVERT(INT, val)
	FROM dbo.strSplit(@CustIDList, ',')

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
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MultiCustEnableCheck] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MultiCustEnableCheck] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MultiCustEnableCheck] TO [bodbExtAccNet]