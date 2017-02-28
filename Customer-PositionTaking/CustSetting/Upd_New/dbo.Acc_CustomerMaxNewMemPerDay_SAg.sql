USE [CustDB]
GO

/****** Object:  StoredProcedure [dbo].[Acc_CustomerMaxNewMemPerDay_SAg]    Script Date: 05/14/2014 10:26:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[Acc_CustomerMaxNewMemPerDay_SAg]
	@username	varchar(30),
	@mode		varchar(1),
	@creator	int,
	@Language	varchar(2) = 'E',
	@IP			varchar(20) = '',
	@Limit		smallint			OUTPUT,
	@ErrCode	int = 0				OUTPUT,
	@ErrMsg		nvarchar(4000) = '' OUTPUT
	
AS
--@Source Control
/*
Created:	20140507@Logan
Task :		15818 
			AccountingSite\Retrieve, update limit of newly created member of Super Agent
		
DB:			DBTXN/CustDB
Revisions:

			- 20140507@Logan: Initial version

Param's Explanation:	
• @ErrCode:
    = 0: Successfully
	> 0: Specific Error
  
• @ErrMsg: Error description.
*/
begin

	SET NOCOUNT ON;

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	declare @tmpLimit int = -2
	set @startRun = getdate()
	
	if @mode not in ('U', 'Q')
	begin
		select @ErrMsg = 'Incorrect mode. Please check again with admin.',
			   @ErrCode = 1
		return
	end
    
    if @mode = 'Q'
    begin
		select @tmpLimit = a.maxNewMemPerDay
		  from CustSuper a with(nolock) inner join Customer b with(nolock)
			on a.custid = b.custid
		 where 1=1   
		   and b.username = @username
		   and b.roleid = 4
		   and a.IsInternal = 0			--is not Internal Super account
		   and a.custid > 100			--is not System Dummy Super Agent
		   and not exists (select 1		--is not Dummy Super Agent of Deposit
							 from Dep_CustSuper c with(nolock)
							where c.custid = a.custid
						  )
						  
		if @tmpLimit = -2
		begin
			select @ErrMsg = case @Language 
								when 'E' then 'Invalid user'
								else [dbo].[f_Get_MsgNamebyMsgID](40002, @Language)
							 end,
				   @ErrCode = 1
			return
		end
		
		select @Limit = @tmpLimit
    end
    
    if @mode = 'U'
    begin
		if @Limit <= -2
		begin
			select @ErrMsg = 'Incorrect limit value. Please insert a valid number.',
				   @ErrCode = 1
			return
		end
		
		declare @custid int
		declare @oldLimit smallint
		
		select @custid = custid
		  from Customer with(nolock)
		 where username = @username
		
		select @oldLimit = maxNewMemPerDay
		  from CustSuper with(nolock)
		 where custid = @custid
		
		update CustSuper with(rowlock, updlock)
		   set maxNewMemPerDay = @Limit
		 where custid = @custid
		
		if @@ERROR <> 0
		begin
			select @ErrMsg = 'Cannot update!! Please try again.',
				   @ErrCode = 1
			return		   
		end
		 
		select @ErrMsg = 'Successfully updated.'
		
		set @endRun = getdate()
		set @duration  = datediff (millisecond, @startRun, @endRun)

		--Log Update Action		
		declare @LogSPData varchar(8000)
		
		select @LogSPData = '<Acc_CustomerMaxNewMemPerDay_SAg custid="' + coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
							'NewValue="' + coalesce(cast(@Limit as varchar(50)),space(1)) + '" ' +
							'OldValue="' + coalesce(cast(@oldLimit as varchar(50)),space(1)) + '" ' +
							'UserID="' + coalesce(cast(@creator as varchar(50)),space(1)) + '" ' +
							'IP="' + coalesce(cast(@IP as varchar(50)),space(1)) + '" />'
		begin try
			exec DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
					@UserID = @creator,
					@CustID = @custid,
					@ActionID = 647,
					@TrackingValue = @LogSPData,
					@duration = @duration
		end try
		
		begin catch
			select @LogSPData = '<Acc_CustomerMaxNewMemPerDay_SAg custid="' + coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
							    'NewValue="' + coalesce(cast(@Limit as varchar(50)),space(1)) + '" ' +
							    'OldValue="' + coalesce(cast(@oldLimit as varchar(50)),space(1)) + '" ' +
							    'UserID="' + coalesce(cast(@creator as varchar(50)),space(1)) + '" ' +
							    'IP="' + coalesce(cast(@IP as varchar(50)),space(1)) + '" ' +
								'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
								'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" />'
			
			exec DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
					@UserID = @creator,
					@CustID = @custid,
					@ActionID = 647,
					@TrackingValue = @LogSPData,
					@duration = @duration		
		end catch		
    end
end


GO
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerMaxNewMemPerDay_SAg] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerMaxNewMemPerDay_SAg] TO [bodbAdminNet]
GO 
