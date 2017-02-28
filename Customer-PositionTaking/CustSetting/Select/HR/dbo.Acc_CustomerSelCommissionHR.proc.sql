ALTER PROCEDURE [dbo].[Acc_CustomerSelCommissionHR]
	@CustID int
AS
--=====================================================
--Select commission for Horseracing
--Developer: Vinh Truong
--Modify from:
--Date: 2008-10-23
--=====================================================

Declare 
	@uplineID int,
	@roleid int,
	
	@UKComm money,
	@OtherComm money,

	@UKComm_Max money,
	@OtherComm_Max money,
	--phuong.nguyen, variables for up-lines	
	@UKComm_Master money,
	@OtherComm_Master money,
	@UKComm_Agent money,
	@OtherComm_Agent money
	
	--end
	
select @roleid = roleid
from customer with (nolock)
where custid = @custid
select @roleid = isnull(@roleid, 0)

	
select @uplineID = case @roleid when 1 then recommend when 2 then mrecommend when 3 then srecommend else 0 end
from customer with (nolock) where custid = @custid

if @roleid = 1
BEGIN	
	select 
		@UKComm = max(case when bettype = 31 then playerdiscount else 0 end),
		@OtherComm = max(case when bettype = 32 then playerdiscount else 0 end)
	from custsetting with (nolock)
	where sporttype = 151 and custid = @custid 	

	Select 
		@UKComm_Max = max(case when bettype = 31 then discount else 0 end),
		@OtherComm_Max = max(case when bettype = 32 then discount else 0 end)
	from 
		custsetting as cs WITH (NOLOCK)
	where cs.custid = @UplineID and cs.sporttype=151	
	
	--phuong.nguyen, Get uplines HR Comm
	--Agent comm
	select @UKComm_Agent = @UKComm_Max
	select @OtherComm_Agent = @OtherComm_Max
	
	--Master Comm 
	select @uplineID = mrecommend
	from customer with (nolock) where custid = @custid
	select 
		@UKComm_Master = max(case when bettype = 31 then adiscount else 0 end),
		@OtherComm_Master = max(case when bettype = 32 then adiscount else 0 end)
	from custsetting with (nolock)
	where sporttype = 151 and custid = @uplineID	
	--end
END
ELSE if @roleid = 2
BEGIN
	select 
		@UKComm = max(case when bettype = 31 then discount else 0 end),
		@OtherComm = max(case when bettype = 32 then discount else 0 end)
	from custsetting with (nolock)
	where sporttype = 151 and custid = @custid 	

	Select 
		@UKComm_Max = max(case when bettype = 31 then adiscount else 0 end),
		@OtherComm_Max = max(case when bettype = 32 then adiscount else 0 end)
	from 
		custsetting as cs WITH (NOLOCK)
	where cs.custid = @UplineID and cs.sporttype=151	
	
	--phuong.nguyen, Get uplines HR Comm
	--Master comm
	select @UKComm_Master = @UKComm_Max
	select @OtherComm_Master = @OtherComm_Max	
	--end
END
ELSE if @roleid = 3
BEGIN
	select 
		@UKComm = max(case when bettype = 31 then adiscount else 0 end),
		@OtherComm = max(case when bettype = 32 then adiscount else 0 end)
	from custsetting with (nolock)
	where sporttype = 151 and custid = @custid 	

	Select 
		@UKComm_Max = max(case when bettype = 31 then sdiscount else 0 end),
		@OtherComm_Max = max(case when bettype = 32 then sdiscount else 0 end)
	from 
		custsetting as cs WITH (NOLOCK)
	where cs.custid = @UplineID and cs.sporttype=151	
END
ELSE if @roleid = 4
BEGIN
	select 
		@UKComm = max(case when bettype = 31 then sdiscount else 0 end),
		@OtherComm = max(case when bettype = 32 then sdiscount else 0 end)
	from custsetting with (nolock)
	where sporttype = 151 and custid = @custid 	

	Select @UKComm_Max = 0.06, @OtherComm_Max = 0.09
END

select 
	@UKComm as UKComm,
	@OtherComm as OtherComm,
	@UKComm_Max as UKComm_Max,
	@OtherComm_Max as OtherComm_Max,
	--phuong.nguyen, get uplines HR comm
	@UKComm_Master as UKComm_Master,
	@OtherComm_Master as OtherComm_Master,
	@UKComm_Agent as UKComm_Agent,
	@OtherComm_Agent as OtherComm_Agent	



GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelCommissionHR] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelCommissionHR] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelCommissionHR] TO [bodbDownlineNetView]
GO