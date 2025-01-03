/*<info serverAlias="DBCBAK-CustDB_History" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_Custinfo_Select
(
	@TableName		VARCHAR(200)
	,@BatchSize		INT = 1000
	,@rID			INT
	,@TransformJson VARBINARY(MAX)  OUTPUT 
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20241224@Johnson
	 Task: Credit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBCUST/CustDB_History

	 Revision:
		- 20241224@Johnson: Initial [Redmine:#212684]
*/
BEGIN
	SET NOCOUNT ON;
	
	IF OBJECT_ID(@TableName) IS NULL OR @TableName <> 'Custinfo_History'
	BEGIN
		SELECT @ErrorCode = 100
			 ,@ErrorMessage = 'Objects is not exists!'
		RETURN;
	END

	DECLARE @MaxrID BIGINT
	SELECT @MaxrID = MAX(rID) FROM Custinfo_History WITH(NOLOCK)

	WAITFOR DELAY '00:00:00.005'
	
	SELECT @TransformJson = COMPRESS(( SELECT TOP(@BatchSize)
										rID				
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
										,updatetime			
								FROM Custinfo_History WITH(NOLOCK)
								WHERE rID > @rID 
									AND rID <= @MaxrID
								ORDER BY rID
								FOR JSON PATH
								,INCLUDE_NULL_VALUES
							))
END