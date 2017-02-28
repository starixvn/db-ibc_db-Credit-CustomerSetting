ALTER PROCEDURE [dbo].[WriteLog_UserLog_RunSP_MultiCust] 
      @UserID		INT
	, @CustIDList	VARCHAR(MAX)
	, @NewPT_XML	VARCHAR(MAX)
	, @OldPT_XML	VARCHAR(MAX)
	, @SubAccID		INT				= 0
	, @IP			VARCHAR(50)		= ''
	, @Language		VARCHAR(20)		= 'E'
	, @SPName		VARCHAR(50)		= NULL
	, @Doing		VARCHAR(4000)	= NULL
	, @ActionID		INT				= NULL
	, @Duration		INT				= NULL
	
	/* Created: 2014-12-09@Dominic 
    Task: Write log for SMA multiple upd grouped member's PT settings 
    DB: DBLOG/bodb_CustomerLog  
	*/
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @tblCust TABLE (CustID INT)

	--Parse affected Customer
	 DECLARE @XML XML  
	 SET @XML = N'<root><r>' + REPLACE(@CustIDList, ',', '</r><r>') + '</r></root>'  
	   
	 INSERT INTO @tblCust (CustID)   SELECT r.value('.','INT')  
	 FROM @xml.nodes('//root/r') AS RECORDS(r) 

	INSERT INTO dbo.UserLog_RunSP (
		UserID
		, CustID
		, SPName
		, Doing
		, ActionID
		, TrackingValue
		, TrackingValue2
		, Duration
		)
	SELECT @UserID
		, tmp.CustID
		, @SPName
		, @Doing
		, @ActionId
		, @NewPT_XML
		, @OldPT_XML
		, @Duration
	FROM @tblCust tmp
END

GO
GRANT EXECUTE ON [dbo].[WriteLog_UserLog_RunSP_MultiCust] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[WriteLog_UserLog_RunSP_MultiCust] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[WriteLog_UserLog_RunSP_MultiCust] TO [bodbExtAccNet]