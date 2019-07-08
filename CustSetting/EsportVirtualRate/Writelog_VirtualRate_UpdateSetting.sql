/*<info serverAlias="DBLOG-bodb_CustomerLog" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE Writelog_VirtualRate_UpdateSetting 
	@CustID INT
	,@SportType INT
	,@ActionID INT
	,@TrackingValue1 VARCHAR(MAX)
	,@TrackingValue2 VARCHAR(MAX)
	,@UserID INT
	,@LogTime DATETIME
	,@Duration INT
	,@IP VARCHAR(15)
AS
/*
	Creator : Dominic
	Date : 2019-06-28
	Task :  Update VR setting of an account for a specific sport  [Redmind: #114830]
	DB: DBLOG/bodb_CustomerLog
	Revisions:
		- 20190628@Dominic: First commit
	Parameter:

	
*/
BEGIN

	INSERT INTO [dbo].[VRCustLog]
           ([SportType]
           ,[CustID]
           ,[ActionID]
           ,[TrackingValue1]
           ,[TrackingValue2]
           ,[UserID]
           ,[LogTime]
		   ,Duration
		   ,[IP])
     VALUES
           (@SportType
           ,@CustID
           ,@ActionID
           ,@TrackingValue1
           ,@TrackingValue2
           ,@UserID
           ,@LogTime
		   ,@Duration
		   ,@IP)

END
