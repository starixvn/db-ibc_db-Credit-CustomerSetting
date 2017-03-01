ALTER FUNCTION [dbo].[IsAllowChangePositiontaking] (@mrecommend int, @currentdate datetime)  
RETURNS bit 
AS  
BEGIN 
	declare @Allow bit
	declare @positiontakingallowday tinyint, @positiontakingallowtime1 smalldatetime, @positiontakingallowtime2 smalldatetime
	declare @currenttime datetime

	select
		@positiontakingallowday = positiontakingallowday,
		@positiontakingallowtime1 = positiontakingallowtime1,
		@positiontakingallowtime2 = positiontakingallowtime2 
	from DB05.bodb02.dbo.Customer with (NOLOCK) 
	where custid = @mrecommend
	
	select @positiontakingallowtime1 = convert(datetime, convert(varchar(10),@positiontakingallowtime1,114))
	select @positiontakingallowtime2 = convert(datetime, convert(varchar(10),@positiontakingallowtime2,114))
	select @currenttime = convert(datetime, convert(varchar(10),@currentdate,114))
	select @allow = case when isnull(@positiontakingallowday, 0) = 0 or (datepart(weekday, dateadd(hh,12,@currentdate)) = @positiontakingallowday and dateadd(hh,12,@currenttime) >= @positiontakingallowtime1 and dateadd(hh,12,@currenttime)<= @positiontakingallowtime2) then 1 else 0 end
	return @allow
END


