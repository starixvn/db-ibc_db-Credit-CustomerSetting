/*<info serverAlias="DBLOG-bodb_CustomerLog" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE Acc_CustVirtualMultiplier_ViewLog 
	@Username NVARCHAR(100)
	, @SportType INT
	, @IncludingUpline BIT = 0
	, @StartLogTime DATETIME
	, @EndLogTime DATETIME
	, @ErrCode TINYINT OUT
	, @ErrMsg NVARCHAR(200) OUT
AS
/*
	Creator : Dominic
	Date : 2019-07-25
	Task :  Log Function for New Virtual Rate Setting  [Redmind: #114830]
	DB: DBLOG/bodb_CustomerLog
	Revisions:
		- 20190725@Dominic: First commit
	Parameter:

	
*/
BEGIN
	DECLARE @CustID INT

	CREATE TABLE #VRLineCustID (CustID INT)
	CREATE TABLE #VRCustLog(LogID BIGINT, [CustID] INT, [TrackingValue2] [varchar](max))

	SELECT @CustID = CustID
	FROM bodb02.dbo.Customer c(NOLOCK)
	WHERE username = @Username
		AND roleid IN (1,2,3,4)

	IF @CustID IS NULL
	BEGIN
		SELECT @ErrCode = 1
		SELECT @ErrMsg = 'This username is not valid.'
		RETURN
	END

	IF @IncludingUpline = 1
	BEGIN
		INSERT INTO #VRLineCustID(CustID)
		SELECT CustID
		FROM (
			SELECT upv.Val CustID
			FROM (
				SELECT custid,recommend,mrecommend,srecommend,0 [Global]
				FROM bodb02.dbo.Customer (NOLOCK)
				WHERE CustID=@CustID
			) t
			UNPIVOT
			(
				Val
				FOR col IN (custid,recommend,mrecommend,srecommend,[Global])
			) upv
		) tmp
		GROUP BY CustID
	END
	ELSE
	BEGIN
		INSERT INTO #VRLineCustID(CustID)
		SELECT @CustID
	END

	INSERT INTO #VRCustLog(LogID, CustID, TrackingValue2)
	SELECT LogID, CustID, dbo.DecompressString(TrackingValue2)
	FROM VRCustLog (NOLOCK)
	WHERE CustID IN (SELECT CustID FROM #VRLineCustID) 
		AND LogTime BETWEEN @StartLogTime AND @EndLogTime
		AND SportType = 43

END
