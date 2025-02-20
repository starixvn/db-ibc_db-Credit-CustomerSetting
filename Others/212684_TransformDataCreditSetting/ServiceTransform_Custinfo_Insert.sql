/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_Custinfo_Insert
(
	@TableName		VARCHAR(200)
	,@TransformJson VARBINARY(MAX)
	,@SiteDBGroupID SMALLINT
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20241224@Johnson
	 Task: Credit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20241224@Johnson: Initial [Redmine:#212684]
*/
BEGIN
	SET NOCOUNT ON;	
	
	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @MaxID BIGINT

			DECLARE @tmp_Custinfo TABLE 
			(	
				[rID] [bigint],
				[UpdateTime] [datetime] NOT NULL,
				[username] [nvarchar](50) NULL,
				[custid] [int] NOT NULL,
				[currency] [int] NULL,
				[roleid] [tinyint] NULL,
				[srecommend] [int] NULL,
				[mrecommend] [int] NULL,
				[recommend] [int] NULL,
				[dangercust] [bit] NULL,
				[autosuspend] [bit] NULL,
				[reject] [bit] NULL,
				[credit] [money] NULL,
				[closed] [bit] NULL,
				[MatchLimit] [smallmoney] NOT NULL,
				[VirtualMultiplier] [smallmoney] NOT NULL,
				[Enabled] [bit] NOT NULL,
				[danger] [tinyint] NOT NULL,
				[danger2] [tinyint] NOT NULL,
				[danger3] [tinyint] NOT NULL,
				[DisableOutright] [bit] NOT NULL,
				[Abnormal] [tinyint] NULL,
				[DoubleCommLosing] [bit] NULL,
				[autosuspend2] [money] NULL,
				[DisableEsports] [bit] NULL,
				[DisableSuperLive] [bit] NULL,
				[LockUpd] [bit] NULL,
				[BonusWalletFlag] [tinyint] NULL,
				[DangerLevel] [int] NULL,
				[CustomerClass] [smallint] NULL,
				[Danger4] [tinyint] NULL,
				[Danger5] [tinyint] NULL,
				[CCSoccer] [smallint] NULL,
				[CCBasketball] [smallint] NULL,
				[CCEsports] [smallint] NULL,
				[CCOtherSports] [smallint] NULL,
				[CCNonSports] [smallint] NULL,
				[autosuspend3] [bit] NULL
			)
		
			INSERT INTO @tmp_Custinfo ( rID
										,[UpdateTime]
									   ,[username]
									   ,[custid]
									   ,[currency]
									   ,[roleid]
									   ,[srecommend]
									   ,[mrecommend]
									   ,[recommend]
									   ,[dangercust]
									   ,[autosuspend]
									   ,[reject]
									   ,[credit]
									   ,[closed]
									   ,[MatchLimit]
									   ,[VirtualMultiplier]
									   ,[Enabled]
									   ,[danger]
									   ,[danger2]
									   ,[danger3]
									   ,[DisableOutright]
									   ,[Abnormal]
									   ,[DoubleCommLosing]
									   ,[autosuspend2]
									   ,[DisableEsports]
									   ,[DisableSuperLive]
									   ,[LockUpd]
									   ,[BonusWalletFlag]
									   ,[DangerLevel]
									   ,[CustomerClass]
									   ,[Danger4]
									   ,[Danger5]
									   ,[CCSoccer]
									   ,[CCBasketball]
									   ,[CCEsports]
									   ,[CCOtherSports]
									   ,[CCNonSports]
									   ,[autosuspend3]
									)
			SELECT rID
					,[UpdateTime]
				    ,username		
					,custid			
					,currency		
					,roleid			
					,srecommend		
					,mrecommend		
					,recommend		
					,dangercust			
					,autosuspend		
					,reject			
					,credit			
					,closed			
					,matchlimit			
					,virtualmultiplier	
					,[enabled]		
					,danger   			
					,danger2			
					,danger3			
					,disableoutright	           
					,abnormal			
					,doublecommLosing	      
					,autosuspend2		  
					,disableesports		
					,disablesuperLive	
					,lockupd			
					,bonuswalletflag	
					,dangerlevel		
					,customerclass		
					,danger4			
					,danger5			
					,ccsoccer			
					,ccbasketball		
					,ccesports			
					,ccothersports		
					,ccnonsports		
					,autosuspend3
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	[rID] [bigint],
					[updatetime] [datetime],
					[username] [nvarchar](50),
					[custid] [int],
					[currency] [int],
					[roleid] [tinyint],
					[srecommend] [int],
					[mrecommend] [int],
					[recommend] [int],
					[dangercust] [bit],
					[autosuspend] [bit],
					[reject] [bit],
					[credit] [money],
					[closed] [bit],
					[matchlimit] [smallmoney],
					[virtualmultiplier] [smallmoney],
					[enabled] [bit],
					[danger] [tinyint],
					[danger2] [tinyint],
					[danger3] [tinyint],
					[disableoutright] [bit],
					[abnormal] [tinyint],
					[doublecommlosing] [bit],
					[autosuspend2] [money],
					[disableesports] [bit],
					[disablesuperlive] [bit],
					[lockupd] [bit],
					[bonuswalletflag] [tinyint],
					[dangerlevel] [int],
					[customerclass] [smallint],
					[danger4] [tinyint],
					[danger5] [tinyint],
					[ccsoccer] [smallint],
					[ccbasketball] [smallint],
					[ccesports] [smallint],
					[ccothersports] [smallint],
					[ccnonsports] [smallint],
					[autosuspend3] [bit]
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_Custinfo

			INSERT INTO Custinfo_History (rID
									   ,[UpdateTime]
									   ,[username]
									   ,[custid]
									   ,[currency]
									   ,[roleid]
									   ,[srecommend]
									   ,[mrecommend]
									   ,[recommend]
									   ,[dangercust]
									   ,[autosuspend]
									   ,[reject]
									   ,[credit]
									   ,[closed]
									   ,[MatchLimit]
									   ,[VirtualMultiplier]
									   ,[Enabled]
									   ,[danger]
									   ,[danger2]
									   ,[danger3]
									   ,[DisableOutright]
									   ,[Abnormal]
									   ,[DoubleCommLosing]
									   ,[autosuspend2]
									   ,[DisableEsports]
									   ,[DisableSuperLive]
									   ,[LockUpd]
									   ,[BonusWalletFlag]
									   ,[DangerLevel]
									   ,[CustomerClass]
									   ,[Danger4]
									   ,[Danger5]
									   ,[CCSoccer]
									   ,[CCBasketball]
									   ,[CCEsports]
									   ,[CCOtherSports]
									   ,[CCNonSports]
									   ,[autosuspend3]
									   ,SiteDBGroupID)
			SELECT rID
			   ,[UpdateTime]
			   ,[username]
			   ,[custid]
			   ,[currency]
			   ,[roleid]
			   ,[srecommend]
			   ,[mrecommend]
			   ,[recommend]
			   ,[dangercust]
			   ,[autosuspend]
			   ,[reject]
			   ,[credit]
			   ,[closed]
			   ,[MatchLimit]
			   ,[VirtualMultiplier]
			   ,[Enabled]
			   ,[danger]
			   ,[danger2]
			   ,[danger3]
			   ,[DisableOutright]
			   ,[Abnormal]
			   ,[DoubleCommLosing]
			   ,[autosuspend2]
			   ,[DisableEsports]
			   ,[DisableSuperLive]
			   ,[LockUpd]
			   ,[BonusWalletFlag]
			   ,[DangerLevel]
			   ,[CustomerClass]
			   ,[Danger4]
			   ,[Danger5]
			   ,[CCSoccer]
			   ,[CCBasketball]
			   ,[CCEsports]
			   ,[CCOtherSports]
			   ,[CCNonSports]
			   ,[autosuspend3]
			   ,@SiteDBGroupID 			
			FROM @tmp_Custinfo

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