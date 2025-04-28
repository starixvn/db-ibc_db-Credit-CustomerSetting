/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_Customer_Insert
(
	@TableName		VARCHAR(200)
	,@TransformJson VARBINARY(MAX)
	,@SiteDBGroupID SMALLINT
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20241226@Johnson
	 Task: Credit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20241226@Johnson: Initial [Redmine:#212684]
		- 20250428@Johnson:Upgrade ExchangeID data type for tables setting [redmine:#225013]
*/
BEGIN
	SET NOCOUNT ON;	
	
	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @MaxID BIGINT

			DECLARE @tmp_Customer TABLE 
			(	
				[rID] [bigint] NOT NULL,
				[UpdateTime] [datetime] NOT NULL,
				[custid] [int] NULL,
				[firstname] [nvarchar](50) NULL,
				[lastname] [nvarchar](50) NULL,
				[address] [nvarchar](80) NULL,
				[postal] [nvarchar](50) NULL,
				[city] [nvarchar](50) NULL,
				[state] [nvarchar](50) NULL,
				[country] [nvarchar](50) NULL,
				[phone] [nvarchar](50) NULL,
				[mobilephone] [nvarchar](50) NULL,
				[fax] [nvarchar](50) NULL,
				[email] [nvarchar](50) NULL,
				[birthday] [smalldatetime] NULL,
				[refcode1] [nvarchar](50) NULL,
				[refcode2] [nvarchar](50) NULL,
				[remark] [nvarchar](50) NULL,
				[creatdate] [smalldatetime] NULL,
				[creator] [int] NOT NULL,
				[username] [varchar](30) NOT NULL,
				[currency] [smallint] NULL,
				[userpwd] [varchar](40) NULL,
				[lastlogged] [smalldatetime] NULL,
				[pwdexpiry] [datetime] NULL,
				[roleid] [tinyint] NULL,
				[mrecommend] [int] NULL,
				[recommend] [int] NULL,
				[ugroup] [varchar](3) NULL,
				[logincount] [tinyint] NULL,
				[on_sessionid] [int] NULL,
				[site] [varchar](10) NULL,
				[iplogin] [nvarchar](20) NULL,
				[important] [bit] NULL,
				[srecommend] [int] NULL,
				[username2] [varchar](50) NULL
			)
		
			INSERT INTO @tmp_Customer ( [rID]
									  ,[UpdateTime]
									  ,[custid]
									  ,[firstname]
									  ,[lastname]
									  ,[address]
									  ,[postal]
									  ,[city]
									  ,[state]
									  ,[country]
									  ,[phone]
									  ,[mobilephone]
									  ,[fax]
									  ,[email]
									  ,[birthday]
									  ,[refcode1]
									  ,[refcode2]
									  ,[remark]
									  ,[creatdate]
									  ,[creator]
									  ,[username]
									  ,[currency]
									  ,[userpwd]
									  ,[lastlogged]
									  ,[pwdexpiry]
									  ,[roleid]
									  ,[mrecommend]
									  ,[recommend]
									  ,[ugroup]
									  ,[logincount]
									  ,[on_sessionid]
									  ,[site]
									  ,[iplogin]
									  ,[important]
									  ,[srecommend]
									  ,[username2]
									)
			SELECT [rID]
				  ,[UpdateTime]
				  ,[custid]
				  ,[firstname]
				  ,[lastname]
				  ,[address]
				  ,[postal]
				  ,[city]
				  ,[state]
				  ,[country]
				  ,[phone]
				  ,[mobilephone]
				  ,[fax]
				  ,[email]
				  ,[birthday]
				  ,[refcode1]
				  ,[refcode2]
				  ,[remark]
				  ,[creatdate]
				  ,[creator]
				  ,[username]
				  ,[currency]
				  ,[userpwd]
				  ,[lastlogged]
				  ,[pwdexpiry]
				  ,[roleid]
				  ,[mrecommend]
				  ,[recommend]
				  ,[ugroup]
				  ,[logincount]
				  ,[on_sessionid]
				  ,[site]
				  ,[iplogin]
				  ,[important]
				  ,[srecommend]
				  ,[username2]
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	[rID] [bigint],
				[updatetime] [datetime],
				[custid] [int],
				[firstname] [nvarchar](50),
				[lastname] [nvarchar](50),
				[address] [nvarchar](80),
				[postal] [nvarchar](50),
				[city] [nvarchar](50),
				[state] [nvarchar](50),
				[country] [nvarchar](50),
				[phone] [nvarchar](50),
				[mobilephone] [nvarchar](50),
				[fax] [nvarchar](50),
				[email] [nvarchar](50),
				[birthday] [smalldatetime],
				[refcode1] [nvarchar](50),
				[refcode2] [nvarchar](50),
				[remark] [nvarchar](50),
				[creatdate] [smalldatetime],
				[creator] [int],
				[username] [varchar](30),
				[currency] [int],
				[userpwd] [varchar](40),
				[lastlogged] [smalldatetime],
				[pwdexpiry] [datetime],
				[roleid] [tinyint],
				[mrecommend] [int],
				[recommend] [int],
				[ugroup] [varchar](3),
				[logincount] [tinyint],
				[on_sessionid] [int],
				[site] [varchar](10),
				[iplogin] [nvarchar](20),
				[important] [bit],
				[srecommend] [int],
				[username2] [varchar](50)
			)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_Customer

			INSERT INTO Customer_History ([rID]
									  ,[UpdateTime]
									  ,[custid]
									  ,[firstname]
									  ,[lastname]
									  ,[address]
									  ,[postal]
									  ,[city]
									  ,[state]
									  ,[country]
									  ,[phone]
									  ,[mobilephone]
									  ,[fax]
									  ,[email]
									  ,[birthday]
									  ,[refcode1]
									  ,[refcode2]
									  ,[remark]
									  ,[creatdate]
									  ,[creator]
									  ,[username]
									  ,[currency]
									  ,[userpwd]
									  ,[lastlogged]
									  ,[pwdexpiry]
									  ,[roleid]
									  ,[mrecommend]
									  ,[recommend]
									  ,[ugroup]
									  ,[logincount]
									  ,[on_sessionid]
									  ,[site]
									  ,[iplogin]
									  ,[important]
									  ,[srecommend]
									  ,[username2]
									  ,SiteDBGroupID)
			SELECT [rID]
				  ,[UpdateTime]
				  ,[custid]
				  ,[firstname]
				  ,[lastname]
				  ,[address]
				  ,[postal]
				  ,[city]
				  ,[state]
				  ,[country]
				  ,[phone]
				  ,[mobilephone]
				  ,[fax]
				  ,[email]
				  ,[birthday]
				  ,[refcode1]
				  ,[refcode2]
				  ,[remark]
				  ,[creatdate]
				  ,[creator]
				  ,[username]
				  ,[currency]
				  ,[userpwd]
				  ,[lastlogged]
				  ,[pwdexpiry]
				  ,[roleid]
				  ,[mrecommend]
				  ,[recommend]
				  ,[ugroup]
				  ,[logincount]
				  ,[on_sessionid]
				  ,[site]
				  ,[iplogin]
				  ,[important]
				  ,[srecommend]
				  ,[username2]
				  ,@SiteDBGroupID 			
			FROM @tmp_Customer

			UPDATE Dest_ServiceTransform
			SET rID = @MaxID,
				UpdateTime = GETDATE()
			WHERE TableName = @TableName
				AND SiteDBGroupID = @SiteDBGroupID
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH

		SET @ErrorCode = @@ERROR
		SET @ErrorMessage = ERROR_MESSAGE()

		ROLLBACK TRANSACTION
		RETURN
	END CATCH

END