ALTER PROCEDURE [dbo].[Acc_CustomerUpdMember_CommissionHR]
	@custid INT,-- MemberId
	@v151discount_31 DECIMAL(9,8),--commission for Tote.
	@v151discount_41 DECIMAL(9,8),--commission for FO.	
	@v151discount_51 DECIMAL(9,8),
	@v152discount_41 DECIMAL(9,8),
	@v152discount_51 DECIMAL(9,8),
	@v153discount_51 DECIMAL(9,8),

	@UpdateMultiple BIT = 0,
	@Updatediscountv151_31 BIT = 1,
	@Updatediscountv151_41 BIT = 1,
	@Updatediscountv151_51 BIT = 1,
	@Updatediscountv152_41 BIT = 1,
	@Updatediscountv152_51 BIT = 1,	
	@Updatediscountv153_51 BIT = 1,
		
	@SubAccID INT = 0, --Sub-AccountID
	@UserID INT = 0,	
	@Language VARCHAR(2) = 'E',
	@IP VARCHAR(15)='',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
Created: 20081023@VinhTruong
Task : Update Master's commission for Horseracing
DB: DBTXN/bodb02

Revisions:
	- 20090515@Phuc: commission for tote and fixed odds.
					Write log subaccname instead of subaccid.
	- 20090917@Phuc: write log into DBLOG.
	- 20091201@Kiwi: Move custsetting to the separated table CustSetting3rd.
	- 20100112@Phuc: hardcode not to update commission for member under agent 8RM.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20101019@Henry: Record execution time
	- 20110111@Lukas: Add commission setting
						+ AU Horse racing
						+ UK, AU Greyhound racing
						+ AU Harness racing
	- 20110509@Lukas: Add message translation(Thai version)
	- 20110518@Johnson: write log for old setting
	- 20111104@TOM: Apply Multiple Edit Racing PT.
	- 20120412@Hurri: hardcode not to update commission for member under agent BARM.
	- 20120522@Sophia: Remove hardcode not to update commission for member under agent BARM.
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130227@Johnson: write log on DBTXN if DBLOG failure
	- 20131030@Kathy: Apply exec rep to update commission [Redmine:#3244]
Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()


--Check Param
if (@UpdateMultiple = 0 or @Updatediscountv151_31 = 1 or @Updatediscountv151_41 = 1 or @Updatediscountv151_51 = 1)
BEGIN --@Updatediscountv151
	IF	(@v151discount_31 < 0 OR @v151discount_31 > 0.01) and @Updatediscountv151_31 = 1
	BEGIN	
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate (SA Tote).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](2,@Language)
						END, @ErrCode = 101
		RETURN
	END
	IF	(@v151discount_41 < 0 OR @v151discount_41 > 0.01) and @Updatediscountv151_41 = 1
	BEGIN	
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate (UK/Irish Tote).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](3,@Language)
						END, @ErrCode = 102
		RETURN
	END
	IF	(@v151discount_51 < 0 OR @v151discount_51 > 0.01) and @Updatediscountv151_51 = 1
	BEGIN	
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate (Aust Tote).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](4,@Language)
						END, @ErrCode = 103
		RETURN
	END
END --@Updatediscountv151

if (@UpdateMultiple = 0 or @Updatediscountv152_41 = 1 or @Updatediscountv152_51 = 1)
BEGIN --@Updatediscountv152
	IF	(@v152discount_41 < 0 OR @v152discount_41 > 0.01) and @Updatediscountv152_41 = 1
	BEGIN	
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate (UK/Irish Greyhounds).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](5,@Language)
						END, @ErrCode = 104
		RETURN
	END
	IF	(@v152discount_51 < 0 OR @v152discount_51 > 0.01) and @Updatediscountv152_51 = 1
	BEGIN	
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate (Aust Greyhound).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](6,@Language)
						END, @ErrCode = 105
		RETURN
	END
END--@Updatediscountv152

if (@UpdateMultiple = 0 or @Updatediscountv153_51 = 1)
BEGIN --@Updatediscountv153
	IF	(@v153discount_51 < 0 OR @v153discount_51 > 0.01) and @Updatediscountv153_51 = 1
	BEGIN	
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate (Aust Harness).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](7,@Language)
						END, @ErrCode = 106
		RETURN
	END
END--@Updatediscountv153
---------------------------------------
DECLARE @username VARCHAR(40), @recommend INT,
		@Av151discount_31 DECIMAL(9,8), 
		@Av151discount_41 DECIMAL(9,8), 
		@Av151discount_51 DECIMAL(9,8),
		@Av152discount_41 DECIMAL(9,8),
		@Av152discount_51 DECIMAL(9,8),
		@Av153discount_51 DECIMAL(9,8),
		@db_v151discount_31 DECIMAL(9,8), 
		@db_v151discount_41 DECIMAL(9,8),
		@db_v151discount_51 DECIMAL(9,8),
		@db_v152discount_41 DECIMAL(9,8),
		@db_v152discount_51 DECIMAL(9,8),
		@db_v153discount_51 DECIMAL(9,8)
SELECT @UserName  = username,
		@recommend = recommend
FROM customer c WITH (NOLOCK) WHERE CustID = @CustID

SELECT 
	@db_v151discount_31 = ISNULL(playerdiscount , 0)
FROM CustSetting3rd WITH (NOLOCK) 
WHERE custid = @custid 
	AND bettype = 31 
	AND sporttype = 151
		
SELECT 
	@db_v151discount_41 = ISNULL(playerdiscount , 0) 
FROM CustSetting3rd WITH (NOLOCK) 
WHERE custid = @custid 
	AND bettype = 41 
	AND sporttype = 151

SELECT 
	@db_v151discount_51 = ISNULL(playerdiscount , 0) 
FROM CustSetting3rd WITH (NOLOCK) 
WHERE custid = @custid 
	AND bettype = 51 
	AND sporttype = 151

SELECT 
	@db_v152discount_41 = ISNULL(playerdiscount , 0) 
FROM CustSetting3rd WITH (NOLOCK) 
WHERE custid = @custid 
	AND bettype = 41 
	AND sporttype = 152

SELECT 
	@db_v152discount_51 = ISNULL(playerdiscount , 0) 
FROM CustSetting3rd WITH (NOLOCK) 
WHERE custid = @custid 
	AND bettype = 51 
	AND sporttype = 152

SELECT 
	@db_v153discount_51 = ISNULL(playerdiscount , 0) 
FROM CustSetting3rd WITH (NOLOCK) 
WHERE custid = @custid 
	AND bettype = 51 
	AND sporttype = 153


DECLARE @RoleId int
SELECT @RoleId = roleid
FROM custInfo with(NOLOCK)
WHERE custid = @custid 

if (@UpdateMultiple = 0 
	or @Updatediscountv151_31 = 1 
	or @Updatediscountv151_41 = 1 
	or @Updatediscountv151_51 = 1 

	or @Updatediscountv152_41 = 1
	or @Updatediscountv152_51 = 1

	or @Updatediscountv153_51 = 1
	)
BEGIN 
	--@Updatediscountv151
	if (@Updatediscountv151_31 = 1)
	BEGIN
		SELECT @Av151discount_31 = discount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @recommend AND bettype=31 AND sporttype = 151

		SELECT @v151discount_31 = CASE WHEN @v151discount_31 > @Av151discount_31 
											THEN @Av151discount_31 
									   ELSE @v151discount_31 
								  END
	END
	ELSE
		SELECT @v151discount_31 = @db_v151discount_31

	if (@Updatediscountv151_41 = 1)
	BEGIN
		SELECT @Av151discount_41 = discount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @recommend AND bettype=41 AND sporttype = 151 
		SELECT @v151discount_41 = CASE WHEN @v151discount_41 > @Av151discount_41 THEN @Av151discount_41 ELSE @v151discount_41 END
	END
	ELSE
		SELECT @db_v151discount_41 = @v151discount_41

	if (@Updatediscountv151_51 = 1)
	BEGIN
		SELECT @Av151discount_51 = discount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @recommend AND bettype=51 AND sporttype = 151
		SELECT @v151discount_51 = CASE WHEN @v151discount_51 > @Av151discount_51 THEN @Av151discount_51 ELSE @v151discount_51 END
	END
	ELSE
		SELECT @db_v151discount_51 = @v151discount_51
	--@Updatediscountv152
	if (@Updatediscountv152_41 = 1)
	BEGIN
		SELECT @Av152discount_41 = discount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @recommend AND bettype=41 AND sporttype = 152
		SELECT @v152discount_41 = CASE WHEN @v152discount_41 > @Av152discount_41 THEN @Av152discount_41 ELSE @v152discount_41 END
	END
	ELSE	
		SELECT @db_v152discount_41 = @v152discount_41
	if (@Updatediscountv152_51 = 1)
	BEGIN
		SELECT @Av152discount_51 = discount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @recommend AND bettype=51 AND sporttype = 152
		SELECT @v152discount_51 = CASE WHEN @v152discount_51 > @Av152discount_51 THEN @Av152discount_51 ELSE @v152discount_51 END
	END
	ELSE
		SELECT @db_v152discount_51 = @v152discount_51
	
	if (@Updatediscountv153_51 = 1)
	BEGIN
		SELECT @Av153discount_51 = discount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @recommend AND bettype=51 AND sporttype = 153
		SELECT @v153discount_51 = CASE WHEN @v153discount_51 > @Av153discount_51 THEN @Av153discount_51 ELSE @v153discount_51 END
	END
	ELSE
		SELECT @db_v153discount_51 = @v153discount_51


	-- Apply exec rep
	exec dbo.Acc_CustSetting3rd_06
			@CustId = @custid,
			@RoleId = @RoleId ,
			@v151discount_31 = @v151discount_31,
			@v151discount_41 = @v151discount_41, 
			@v151discount_51 = @v151discount_51,
			@v152discount_41 = @v152discount_41,
			@v152discount_51 = @v152discount_51,
			@v153discount_51 = @v153discount_51,
			@mode = 'HorseRacing'
END

	


Declare @LogSPData varchar(MAX),
		@TrackingValueDB varchar(4000)
		
Select @LogSPData = '<Acc_CustomerUpdMember_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
'v151discount_31="'+ coalesce(cast(@v151discount_31 as varchar(50)),space(1))+ '" ' +
'v151discount_41="'+ coalesce(cast(@v151discount_41 as varchar(50)),space(1))+ '" ' +
'v151discount_51="'+ coalesce(cast(@v151discount_51 as varchar(50)),space(1))+ '" ' +
'v152discount_41="'+ coalesce(cast(@v152discount_41 as varchar(50)),space(1))+ '" ' +
'v152discount_51="'+ coalesce(cast(@v152discount_51 as varchar(50)),space(1))+ '" ' +
'v153discount_51="'+ coalesce(cast(@v153discount_51 as varchar(50)),space(1))+ '" ' +
'UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_31="'+ coalesce(cast(@Updatediscountv151_31 as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_41="'+ coalesce(cast(@Updatediscountv151_41 as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_51="'+ coalesce(cast(@Updatediscountv151_51 as varchar(1)),space(1)) + '" ' +
'Updatediscountv152_41="'+ coalesce(cast(@Updatediscountv152_41 as varchar(1)),space(1)) + '" ' +
'Updatediscountv152_51="'+ coalesce(cast(@Updatediscountv152_51 as varchar(1)),space(1)) + '" ' +
'Updatediscountv153_51="'+ coalesce(cast(@Updatediscountv153_51 as varchar(1)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

Select @TrackingValueDB = '<Acc_CustomerUpdMember_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
'v151discount_31="'+ coalesce(cast(@db_v151discount_31 as varchar(50)),space(1))+ '" ' +
'v151discount_41="'+ coalesce(cast(@db_v151discount_41 as varchar(50)),space(1))+ '" ' +
'v151discount_51="'+ coalesce(cast(@db_v151discount_51 as varchar(50)),space(1))+ '" ' +
'v152discount_41="'+ coalesce(cast(@db_v152discount_41 as varchar(50)),space(1))+ '" ' +
'v152discount_51="'+ coalesce(cast(@db_v152discount_51 as varchar(50)),space(1))+ '" ' +
'v153discount_51="'+ coalesce(cast(@db_v153discount_51 as varchar(50)),space(1))+ '" ' +
'UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_31="'+ coalesce(cast(@Updatediscountv151_31 as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_41="'+ coalesce(cast(@Updatediscountv151_41 as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_51="'+ coalesce(cast(@Updatediscountv151_51 as varchar(1)),space(1)) + '" ' +
'Updatediscountv152_41="'+ coalesce(cast(@Updatediscountv152_41 as varchar(1)),space(1)) + '" ' +
'Updatediscountv152_51="'+ coalesce(cast(@Updatediscountv152_51 as varchar(1)),space(1)) + '" ' +
'Updatediscountv153_51="'+ coalesce(cast(@Updatediscountv153_51 as varchar(1)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

--Log customer info 
BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 212,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerUpdMember_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
	'v151discount_31="'+ coalesce(cast(@v151discount_31 as varchar(50)),space(1))+ '" ' +
	'v151discount_41="'+ coalesce(cast(@v151discount_41 as varchar(50)),space(1))+ '" ' +
	'v151discount_51="'+ coalesce(cast(@v151discount_51 as varchar(50)),space(1))+ '" ' +
	'v152discount_41="'+ coalesce(cast(@v152discount_41 as varchar(50)),space(1))+ '" ' +
	'v152discount_51="'+ coalesce(cast(@v152discount_51 as varchar(50)),space(1))+ '" ' +
	'v153discount_51="'+ coalesce(cast(@v153discount_51 as varchar(50)),space(1))+ '" ' +
	'UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
	'Updatediscountv151_31="'+ coalesce(cast(@Updatediscountv151_31 as varchar(1)),space(1)) + '" ' +
	'Updatediscountv151_41="'+ coalesce(cast(@Updatediscountv151_41 as varchar(1)),space(1)) + '" ' +
	'Updatediscountv151_51="'+ coalesce(cast(@Updatediscountv151_51 as varchar(1)),space(1)) + '" ' +
	'Updatediscountv152_41="'+ coalesce(cast(@Updatediscountv152_41 as varchar(1)),space(1)) + '" ' +
	'Updatediscountv152_51="'+ coalesce(cast(@Updatediscountv152_51 as varchar(1)),space(1)) + '" ' +
	'Updatediscountv153_51="'+ coalesce(cast(@Updatediscountv153_51 as varchar(1)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 212,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH	


	
	




GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_CommissionHR] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_CommissionHR] TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMember_CommissionHR] TO [vnteam] AS [dbo]