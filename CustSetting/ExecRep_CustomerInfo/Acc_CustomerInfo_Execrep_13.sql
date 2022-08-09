/*<info serverAlias="DBCUST-CustDB" executers="bodbadminNet" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_13]
		@CustID			INT,
		@SettingList	VARCHAR(MAX) = NULL,
		@Mode			VARCHAR(50) = '',
		@UserID			INT	= 0
AS
/*
	Created: 20220808@Tacy
	Task : Update Member's DCS setting by Search&Copy New member function
	DB: DBCust/CustDB
	Original:

	Revisions:
		- 20220808@Tacy: Initial SP [RedmineID: #176225]

	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON;
	

END
GO