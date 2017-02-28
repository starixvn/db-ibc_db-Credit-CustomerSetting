ALTER PROCEDURE [dbo].[Acc_CustomerUpdP2PAgent_GameSetting]
	@custid INT,
	@StakeLevel1 BIT, 
	@StakeLevel2 BIT, 
	@StakeLevel3 BIT, 
	@StakeLevel4 BIT, 
	@StakeLevel5 BIT, 
	@BetType int,
	@SubAccID INT = 0, --Sub-AccountID
	@UserID INT = 0, 
	@Language VARCHAR(2) = 'E',
	@IP VARCHAR(40)='',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
Created: 20110421@Amy
Task : Update Agent's P2P GameSetting
DB: DBTXN/bodb02
Original:

Revisions: 
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130318@Elodie: Write more log on DBTXN server in case of DBLOG server failure
	
Param's Explanation:
@ErrCode:
	= 0: Update commission successfully.
	> 0: Specific Error.
	range: 201
@ErrMsg: Error description.
*/

SET NOCOUNT ON

DECLARE @startRun DATETIME, @duration INT
SET @startRun = getdate()

DECLARE @UplineID INT;
DECLARE @Upline_SL1 BIT, @Upline_SL2 BIT, @Upline_SL3 BIT, @Upline_SL4 BIT, @Upline_SL5 BIT,		
		@Old_StakeLevel1 BIT, @Old_StakeLevel2 BIT, @Old_StakeLevel3 BIT, @Old_StakeLevel4 BIT, @Old_StakeLevel5 BIT

SELECT @Old_StakeLevel1 = stakelevel1, 
		@Old_StakeLevel2 = stakelevel2, 
		@Old_StakeLevel3 = stakelevel3, 
		@Old_StakeLevel4 = stakelevel4, 
		@Old_StakeLevel5 = stakelevel5
FROM P2PGameSetting p WITH(nolock) WHERE custid=@custid AND bettype=@BetType

IF	@Old_StakeLevel1 = @StakeLevel1 AND
	@Old_StakeLevel2 = @StakeLevel2 AND
	@Old_StakeLevel3 = @StakeLevel3 AND
	@Old_StakeLevel4 = @StakeLevel4 AND 
	@Old_StakeLevel5 = @StakeLevel5
RETURN

SELECT @UplineID=c.mrecommend FROM CustInfo c WITH (NOLOCK) WHERE c.custid=@custid ;

SELECT @Upline_SL1=stakelevel1, @Upline_SL2=stakelevel2, @Upline_SL3=stakelevel3, @Upline_SL4=stakelevel4, @Upline_SL5=stakelevel5
FROM dbo.P2PGameSetting p WITH(nolock) WHERE custid=@UplineID AND bettype=@BetType

IF (@Upline_SL1=0 AND @StakeLevel1 =1) OR (@Upline_SL2=0 AND @StakeLevel2 = 1) OR (@Upline_SL3=0 AND @StakeLevel3 =1) OR (@Upline_SL4=0 AND @StakeLevel4 =1) OR (@Upline_SL5=0 AND @StakeLevel5 =1)
BEGIN
	SELECT @ErrMsg = CASE @Language 
				WHEN 'E' THEN 'You do not have permission to update Game setting (' + dbo.F_Get_BetNameByTypeID(@BetType,'E') + ')'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10023,@Language) + ' (' + dbo.F_Get_BetNameByTypeID(@BetType,@Language) + ')'
				END, @ErrCode = 201
	RETURN 
END

--Accounting Site : Update full stake level
IF exists(select 1 from DBO.CUSTINFO (nolock)
		Where CUSTID = @UserID AND ROLEID > 4 )
	Begin
			-- Update Agent
			UPDATE dbo.P2PGameSetting WITH (ROWLOCK, UPDLOCK)
			SET stakelevel1=@stakelevel1, 
			 stakelevel2=@stakelevel2, 
			 stakelevel3=@stakelevel3, 
			 stakelevel4=@stakelevel4,
			 stakelevel5=@stakelevel5
			WHERE custid=@custid AND bettype=@BetType

			-- Update Member  
			UPDATE dbo.P2PGameSetting WITH (ROWLOCK, UPDLOCK)  
			SET stakelevel1 = CASE WHEN p.stakelevel1=1 AND @stakelevel1=0 THEN @stakelevel1 ELSE p.stakelevel1 END,
			 stakelevel2 = CASE WHEN p.stakelevel2=1 AND @stakelevel2=0 THEN @stakelevel2 ELSE p.stakelevel2 END,
			 stakelevel3 = CASE WHEN p.stakelevel3=1 AND @stakelevel3=0 THEN @stakelevel3 ELSE p.stakelevel3 END,
			 stakelevel4 = CASE WHEN p.stakelevel4=1 AND @stakelevel4=0 THEN @stakelevel4 ELSE p.stakelevel4 END,
			 stakelevel5 = CASE WHEN p.stakelevel5=1 AND @stakelevel5=0 THEN @stakelevel5 ELSE p.stakelevel5 END
			FROM dbo.P2PGameSetting p   
			 INNER JOIN dbo.Custinfo cf WITH (nolock) on p.custid=cf.custid  
			WHERE cf.recommend=@custid AND cf.roleid=1 AND p.bettype=@BetType
	End
--Agent Site : Do not update stake level 1 (play for fun)
Else
	Begin
			-- Update Agent
			UPDATE dbo.P2PGameSetting WITH (ROWLOCK, UPDLOCK)
			SET stakelevel2=@stakelevel2, 
			 stakelevel3=@stakelevel3, 
			 stakelevel4=@stakelevel4,
			 stakelevel5=@stakelevel5
			WHERE custid=@custid AND bettype=@BetType

			-- Update Member  
			UPDATE dbo.P2PGameSetting WITH (ROWLOCK, UPDLOCK)  
			SET stakelevel2 = CASE WHEN p.stakelevel2=1 AND @stakelevel2=0 THEN @stakelevel2 ELSE p.stakelevel2 END,
			 stakelevel3 = CASE WHEN p.stakelevel3=1 AND @stakelevel3=0 THEN @stakelevel3 ELSE p.stakelevel3 END,
			 stakelevel4 = CASE WHEN p.stakelevel4=1 AND @stakelevel4=0 THEN @stakelevel4 ELSE p.stakelevel4 END,
			 stakelevel5 = CASE WHEN p.stakelevel5=1 AND @stakelevel5=0 THEN @stakelevel5 ELSE p.stakelevel5 END
			FROM dbo.P2PGameSetting p   
			 INNER JOIN dbo.Custinfo cf WITH (nolock) on p.custid=cf.custid  
			WHERE cf.recommend=@custid AND cf.roleid=1 AND p.bettype=@BetType	
	End
DECLARE @LogSPData VARCHAR(5000)
DECLARE @TrackingValue2 VARCHAR(5000)

SELECT @LogSPData = '<Acc_CustomerUpdP2PAgent_GameSetting custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'stakelevel1="'+ coalesce(cast(@stakelevel1 as varchar(50)),space(1)) + '" ' +
'stakelevel2="'+ coalesce(cast(@stakelevel2 as varchar(50)),space(1)) + '" ' +
'stakelevel3="'+ coalesce(cast(@stakelevel3 as varchar(50)),space(1)) + '" ' +
'stakelevel4="'+ coalesce(cast(@stakelevel4 as varchar(50)),space(1)) + '" ' +
'stakelevel5="'+ coalesce(cast(@stakelevel5 as varchar(50)),space(1)) + '" ' +
'BetType="'+ coalesce(cast(@BetType as varchar(10)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(40)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

SELECT @TrackingValue2 = '<Acc_CustomerUpdP2PAgent_GameSetting custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'stakelevel1="'+ coalesce(cast(@Old_stakelevel1 as varchar(50)),space(1)) + '" ' +
'stakelevel2="'+ coalesce(cast(@Old_stakelevel2 as varchar(50)),space(1)) + '" ' +
'stakelevel3="'+ coalesce(cast(@Old_stakelevel3 as varchar(50)),space(1)) + '" ' +
'stakelevel4="'+ coalesce(cast(@Old_stakelevel4 as varchar(50)),space(1)) + '" ' +
'stakelevel5="'+ coalesce(cast(@Old_stakelevel5 as varchar(50)),space(1)) + '" ' +
'BetType="'+ coalesce(cast(@BetType as varchar(10)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(40)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

SET @duration  = datedIFf (millisecond,@startRun,getdate())

BEGIN TRY
	--Log customer info 
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 353,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END TRY
BEGIN CATCH
	SELECT @LogSPData = '<Acc_CustomerUpdP2PAgent_GameSetting custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'stakelevel1="'+ coalesce(cast(@stakelevel1 as varchar(50)),space(1)) + '" ' +
	'stakelevel2="'+ coalesce(cast(@stakelevel2 as varchar(50)),space(1)) + '" ' +
	'stakelevel3="'+ coalesce(cast(@stakelevel3 as varchar(50)),space(1)) + '" ' +
	'stakelevel4="'+ coalesce(cast(@stakelevel4 as varchar(50)),space(1)) + '" ' +
	'stakelevel5="'+ coalesce(cast(@stakelevel5 as varchar(50)),space(1)) + '" ' +
	'BetType="'+ coalesce(cast(@BetType as varchar(10)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(40)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ error_message() + '" />'

	SELECT @TrackingValue2 = '<Acc_CustomerUpdP2PAgent_GameSetting custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'stakelevel1="'+ coalesce(cast(@Old_stakelevel1 as varchar(50)),space(1)) + '" ' +
	'stakelevel2="'+ coalesce(cast(@Old_stakelevel2 as varchar(50)),space(1)) + '" ' +
	'stakelevel3="'+ coalesce(cast(@Old_stakelevel3 as varchar(50)),space(1)) + '" ' +
	'stakelevel4="'+ coalesce(cast(@Old_stakelevel4 as varchar(50)),space(1)) + '" ' +
	'stakelevel5="'+ coalesce(cast(@Old_stakelevel5 as varchar(50)),space(1)) + '" ' +
	'BetType="'+ coalesce(cast(@BetType as varchar(10)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(40)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ error_message() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 353,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END CATCH	

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdP2PAgent_GameSetting] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdP2PAgent_GameSetting] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdP2PAgent_GameSetting] TO vnteam


