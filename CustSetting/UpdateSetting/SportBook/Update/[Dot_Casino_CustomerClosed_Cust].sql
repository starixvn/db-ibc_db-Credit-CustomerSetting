USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Dot_Casino_CustomerClosed_Cust]    Script Date: 5/31/2017 4:28:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Dot_Casino_CustomerClosed_Cust    Script Date: 12/18/2013 11:28:58 AM ******/

/****** Object:  Stored Procedure dbo.Dot_Casino_CustomerClosed_Cust    Script Date: 12/3/2013 1:03:50 PM ******/
ALTER PROCEDURE [dbo].[Dot_Casino_CustomerClosed_Cust]
	@CustID int,
	@Closed bit,
	@CSAdminID varchar(30),
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@IP varchar(15)=''
AS
/*
Creator : Phuong Doan
Date : 2009-02-25
Task : Update closed status
DB: DBTRANS.bodb02

History:
    - 20121026@Elodie: Modify to write log update into our Customer_Log DB instead of Userlog table.
	- 20170601@Winnie: Apply color for closed Account RedmineID: #74494
Param's Explanation:
	• @CustID: affected user 
	• @CSAdminID: ID of casino admin who does this action  
	• @ErrCode:
		= 0: Transaction recorded successfully.
		> 0: Specific Error.
	• @ErrMsg: Error description.
	• @IP: IP of reseter

*/
SET NOCOUNT ON
declare @startRun datetime, @endRun datetime, @duration int
set @startRun = getdate()
---------------------------

Declare @roleid tinyint ,@UplineClosed bit, @parentID int, @Old_Closed bit
select @roleid = roleid, @Old_Closed = isnull(closed,0),
@parentID = case RoleID when 1 then recommend when 2 then mrecommend when 3 then srecommend else 0 end
from Custinfo with (nolock)
where custid = @custid

Select @UplineClosed = isnull(closed,0) from Custinfo with (nolock) where custid = @parentID 

if @UplineClosed = 1 
BEGIN
	SELECT @ErrMsg = 'Parent account was closed. Cannot edit member.' , @ErrCode = 101
	return
END 
--Do not allow casino admin update status of users other than member, agent, master, super
if @RoleID not in (1,2,3,4)
begin
	SELECT @ErrMsg =  'Invalid account', @ErrCode = 102
	return
end


BEGIN TRANSACTION

update custinfo with (ROWLOCK, UPDLOCK) set Closed = @Closed
where custid = @custid
IF @Closed=1 
BEGIN
	IF(@roleid=1)
	BEGIN
		UPDATE CustLoginInfo_Member with (ROWLOCK, UPDLOCK) SET ClosedReason = 1
		WHERE custid = @custid
	END
	ELSE
	BEGIN
		UPDATE CustLoginInfo with (ROWLOCK, UPDLOCK) SET ClosedReason = 1
		WHERE custid = @custid
	END
END
ELSE
BEGIN
IF(@roleid=1)
	BEGIN
		UPDATE CustLoginInfo_Member with (ROWLOCK, UPDLOCK) SET ClosedReason = 0
		WHERE custid = @custid
	END
	ELSE
	BEGIN
		UPDATE CustLoginInfo with (ROWLOCK, UPDLOCK) SET ClosedReason = 0
		WHERE custid = @custid
	END
END
if (@@error <> 0)
begin
	ROLLBACK TRANSACTION
	Select @ErrMsg ='Update process is unsuccessful !', @ErrCode = 103
	return
end

if @closed = 1 and @roleid = 4
begin
	update custinfo with (ROWLOCK, UPDLOCK) set closed = @closed where srecommend = @custid	
	UPDATE cl SET ClosedReason = 1
	FROM CustLoginInfo cl with (ROWLOCK, UPDLOCK) 
	INNER JOIN custInfo c WITH(NOLOCK) ON c.custid=cl.CustID AND c.roleid IN(2,3)
	WHERE srecommend = @custid

	UPDATE cl SET ClosedReason = 1
	FROM CustLoginInfo_Member cl with (ROWLOCK, UPDLOCK) 
	INNER JOIN custInfo c WITH(NOLOCK) ON c.custid=cl.CustID AND c.roleid =1
	WHERE srecommend = @custid
	
	if (@@error <> 0)
	begin
		ROLLBACK TRANSACTION
		Select @ErrMsg = 'Update process is unsuccessful !', @ErrCode = 103
		return
	end
end

if @closed = 1 and @roleid = 3
begin
	update custinfo with (ROWLOCK, UPDLOCK) set closed = @closed where mrecommend = @custid
	UPDATE cl SET ClosedReason = 1
	FROM CustLoginInfo cl with (ROWLOCK, UPDLOCK) 
	INNER JOIN custInfo c WITH(NOLOCK) ON c.custid=cl.CustID  AND c.roleid =2
	WHERE mrecommend = @custid

	UPDATE cl SET ClosedReason = 1
	FROM CustLoginInfo_Member cl with (ROWLOCK, UPDLOCK) 
	INNER JOIN custInfo c WITH(NOLOCK) ON c.custid=cl.CustID AND c.roleid =1
	WHERE srecommend = @custid
	
	if (@@error <> 0)
	begin
		ROLLBACK TRANSACTION
		Select @ErrMsg = 'Update process is unsuccessful !', @ErrCode = 103
		return
	end
end

if @closed = 1 and @roleid = 2
begin
	update custinfo with (ROWLOCK, UPDLOCK) set closed = @closed where recommend = @custid

	UPDATE cl SET ClosedReason = 1
	FROM CustLoginInfo_Member cl with (ROWLOCK, UPDLOCK) 
	INNER JOIN custInfo c WITH(NOLOCK) ON c.custid=cl.CustID AND c.roleid =1
	WHERE srecommend = @custid

	if (@@error <> 0)
	begin
		ROLLBACK TRANSACTION
		Select @ErrMsg = 'Update process is unsuccessful !', @ErrCode = 103
	return
	end
end

COMMIT TRANSACTION

------------------write log------------------ 
DECLARE @LogData NVARCHAR(200)
DECLARE @TrackingValue2 NVARCHAR(200)
---------------------------
select @LogData ='<Dot_Casino_CustomerClosed custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'Closed="'+ coalesce(cast(@Closed as varchar(50)),space(1)) + '" ' +
'FromSite="Casino Admin" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(200)),space(1))+'" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

select @TrackingValue2 ='<Dot_Casino_CustomerClosed custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'Closed="'+ coalesce(cast(@Old_Closed as varchar(50)),space(1)) + '" ' +
'FromSite="Casino Admin" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(200)),space(1))+'" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @CsAdminID, 
	@CustID = @custid,
	@ActionID = 1142,
	@TrackingValue = @LogData,
	@TrackingValue2 = @TrackingValue2,
	@duration = @duration
