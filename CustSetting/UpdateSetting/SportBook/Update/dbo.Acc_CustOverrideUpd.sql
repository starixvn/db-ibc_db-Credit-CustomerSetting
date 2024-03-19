/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustOverrideUpd]
    @custid int,
    @minpositiontaking_1 smallmoney,
    @minpositiontaking_2 smallmoney,
    @minpositiontaking_3 smallmoney,
    @minpositiontaking_4 smallmoney,
    @minpositiontaking_5 smallmoney,
    @minpositiontaking_6 smallmoney,
    @minpositiontaking_7 smallmoney,
    @minpositiontaking_8 smallmoney,
    @minpositiontaking_9 smallmoney,
    @minpositiontaking_10 smallmoney,
    @minpositiontaking_9999 smallmoney = 0,
    @minlivepositiontaking_1 smallmoney,
    @minlivepositiontaking_3 smallmoney,
    @minlivepositiontaking_7 smallmoney,
    @minlivepositiontaking_8 smallmoney,
    
    @minv2positiontaking_1 smallmoney,
    @minv2positiontaking_2 smallmoney,
    @minv2positiontaking_3 smallmoney,
    @minv2positiontaking_7 smallmoney,
    @minv2positiontaking_8 smallmoney,
    --@minv2positiontaking_9 smallmoney,
    @minv2positiontaking_20 smallmoney,
    @minv2positiontaking_9999 smallmoney,

    @minv3positiontaking_1 smallmoney,
    @minv3positiontaking_2 smallmoney,
    @minv3positiontaking_3 smallmoney,
    @minv3positiontaking_20 smallmoney,

    @minv5positiontaking_1 smallmoney,
    @minv5positiontaking_2 smallmoney,
    @minv5positiontaking_3 smallmoney,
    @minv5positiontaking_20 smallmoney,
    @minv5positiontaking_9999 smallmoney = 0,

    @minv8positiontaking_1 smallmoney,
    @minv8positiontaking_3 smallmoney,
    @minv8positiontaking_20 smallmoney,

    @minv10positiontaking_1 smallmoney,
    @minv10positiontaking_2 smallmoney,
    @minv10positiontaking_3 smallmoney,
    @minv10positiontaking_20 smallmoney,

    @minv11positiontaking_1 smallmoney,
    @minv11positiontaking_20 smallmoney,

    @minv99positiontaking_1 smallmoney,
    @minv99positiontaking_2 smallmoney,
    @minv99positiontaking_3 smallmoney,
    @minv99positiontaking_9 smallmoney,
    @minv99positiontaking_20 smallmoney,
	@minv99positiontaking_9999 smallmoney,      
    
    @maxpositiontaking_1 smallmoney,
    @maxpositiontaking_2 smallmoney,
    @maxpositiontaking_3 smallmoney,
    @maxpositiontaking_4 smallmoney,
    @maxpositiontaking_5 smallmoney,
    @maxpositiontaking_6 smallmoney,
    @maxpositiontaking_7 smallmoney,
    @maxpositiontaking_8 smallmoney,
    @maxpositiontaking_9 smallmoney,
    @maxpositiontaking_10 smallmoney,
    @maxpositiontaking_9999 smallmoney = 0,
    
    @maxlivepositiontaking_1 smallmoney,
    @maxlivepositiontaking_3 smallmoney,
    @maxlivepositiontaking_7 smallmoney,
    @maxlivepositiontaking_8 smallmoney,
    
    @maxv2positiontaking_1 smallmoney,
    @maxv2positiontaking_2 smallmoney,
    @maxv2positiontaking_3 smallmoney,
    @maxv2positiontaking_7 smallmoney,
    @maxv2positiontaking_8 smallmoney,
    --@maxv2positiontaking_9 smallmoney,
    @maxv2positiontaking_20 smallmoney,
    @maxv2positiontaking_9999 smallmoney,

    @maxv3positiontaking_1 smallmoney,
    @maxv3positiontaking_2 smallmoney,
    @maxv3positiontaking_3 smallmoney,
    @maxv3positiontaking_20 smallmoney,

    @maxv5positiontaking_1 smallmoney,
    @maxv5positiontaking_2 smallmoney,
    @maxv5positiontaking_3 smallmoney,
    @maxv5positiontaking_20 smallmoney,
    @maxv5positiontaking_9999 smallmoney = 0,

    @maxv8positiontaking_1 smallmoney,
    @maxv8positiontaking_3 smallmoney,
    @maxv8positiontaking_20 smallmoney,

    @maxv10positiontaking_1 smallmoney,
    @maxv10positiontaking_2 smallmoney,
    @maxv10positiontaking_3 smallmoney,
    @maxv10positiontaking_20 smallmoney,

    @maxv11positiontaking_1 smallmoney,
    @maxv11positiontaking_20 smallmoney,

    @maxv99positiontaking_1 smallmoney,
    @maxv99positiontaking_2 smallmoney,
    @maxv99positiontaking_3 smallmoney,
    @maxv99positiontaking_9 smallmoney,
    @maxv99positiontaking_20 smallmoney,
	@maxv99positiontaking_9999 smallmoney,     
    
    -- Outright PT for sports
    @minv2positiontaking_10 smallmoney = 0,
    @minv3positiontaking_10 smallmoney = 0,
    @minv5positiontaking_10 smallmoney = 0,
    @minv8positiontaking_10 smallmoney = 0,
    @minv10positiontaking_10 smallmoney = 0,
    @minv11positiontaking_10 smallmoney = 0,
    @minv99positiontaking_10 smallmoney = 0,
    
	@maxv2positiontaking_10 smallmoney = 0,
	@maxv3positiontaking_10 smallmoney = 0,
	@maxv5positiontaking_10 smallmoney = 0,
	@maxv8positiontaking_10 smallmoney = 0,
	@maxv10positiontaking_10 smallmoney = 0,
	@maxv11positiontaking_10 smallmoney = 0,
	@maxv99positiontaking_10 smallmoney = 0,
    
    @CheckPermission bit = 1,
    @UpdateMinPos bit = 1,
    @UpdateMaxPos bit = 1,
    @language varchar(2) = 'E',
    @UserID int = 0,
    @SubAccID int = 0, --Sub-AccountID
    @WriteLog bit = 1,
    @IP varchar(15)='',
    @ErrCode int = 0 OUTPUT,
    @ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20080514@Thien
Task : Update CustOverride
DB: DBTXN/bodb02
Original: 

Revisions:
    - 20090424@Phuc: Separate finance sporttype(201).
    - 20090701@Phuc: remove dbo.IsAllowChangePositiontaking.
                    Write log subaccname instead of subaccid.
    - 20090801@Shifu: check disabled user    
    - 20090917@Phuc: write log into DBLOG.
    - 20100112@Kiwi: amend to write log in xml format.
    - 20100422@Jamie: Check the total downlines before updating Min PT at super level 
    - 20100728@Kiwi: grant execute permission to [bodbExtAccNet,wsv_xnap]
    - 20100901@Henry: Add Number Game + Mix Parlay Mixed Sports
    - 20101019@Henry: Record execution time
    - 20110603@Amy: Write log Old values
    - 20110624@Johnson: check if not update Min/Max PT then write log new Min/Max PT values are the old Min/Max PT values.
    - 20110728@Johnson: - remove bettype dead ball over/under of number game
                        - add more bettype for nubmer game Warrior,  Next combo and Number Group
    - 20110831@Lukas: Hardcode to fix bug ( set 0 for Number Group PT values)
    - 20110709@Johnson: Change to use new server DB053 instead DB052
    - 20111028@Thien: change to call ExecRep SP: Acc_CustSetting3rd_00 & Acc_CustSetting3rd_01
    - 20120311@Thien: include master level into weekend checking
    - 20120704@Johnson: Remove setting hard code of number group
    - 20130527@Elodie:  Change linked server DB053 to DBAGE, DB03 to DBONUSER
                        Write more log on DBTXN server in case of DBLOG server failure
    - 20130809@Jamie: Checking total downlines before UPDATEs
    - 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
    - 20131029@Johnson: Apply execrep when update min/max pt on master or agent
    - 20131112@Johnson: use execrep Acc_CustSetting_04/Acc_CustSetting3rd_04 instead of Acc_CustSetting_00/Acc_CustSetting3rd_00 for updating min pt on super
    - 20140618@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
    - 20140729@Logan:   1.Exclude disabled agents while updating SM's setting [Redmine: #19631]
                        2.Code aligning on modified parts
	- 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable, Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB) [Redmine:#36216]                        
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]	 
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]	
	- 20200724@Eden: Minimize UM Time - Lock updating customer settings [#136464]
	- 20201028@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20210510@Eden: Enhancement for not relying on DB On_User [redmine: #154507]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

--> Check UM config
EXEC [Acc_CheckUM] @CustID = @CustID, @ProductID = 1
	, @Language = @Language, @FunctionType = 1
	, @ErrCode = @ErrCode OUTPUT, @ErrMsg = @ErrMsg OUTPUT 
	, @ReturnUMData = 0
		
IF @ErrCode <>0 
	RETURN

--Check disable user
EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return
--end

Declare @roleid int, @srecommend int, @mrecommend int, @recommend int
select @roleid = roleid, @srecommend=srecommend, @mrecommend=mrecommend, @recommend=recommend from customer with (NOLOCK) where custid = @custid
----------------------------------------------------------------------------------------------------
declare @IsValid bit, @totalDownlines int 

-- --Disable on Weekend's peak hour, from 7PM - 2AM (GMT+8)
--if @roleid in (3, 4) and datename(weekday, getdate()) in ('Saturday','Sunday') and datepart(hour, getdate()) between 7 and  14
--BEGIN
--    SELECT @totalDownlines = count(custid) FROM Custinfo WITH (NOLOCK) WHERE case @roleid when 4 then srecommend else mrecommend end = @custID 
--    IF @totalDownlines >  500
--    BEGIN         
--        Select @ErrCode = 100, @ErrMsg = 'This function is not available during peak hour at weekend since it might affect the performance of the whole system. Please contact IT for further assistance.'
--        RETURN
--    END 
--END

---- Checking total downlines before UPDATEs 


--Check Allowed downlines during peak hour at weekend    
EXEC dbo.Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
                                    @roleid=@roleid,
                                    @isExecRep=1,
                                    @isUpdatePT = 1,
                                    @Sporttype = 1,
                                    @Language='E',
                                    @ErrMsg=@ErrMsg output,
                                    @ErrCode=@ErrCode output
IF    @ErrCode <> 0 
    RETURN 
/*
if not exists (select 1 from custinfo with (nolock) where custid = @custid and srecommend in (181940,197461))
BEGIN
--    declare @ErrMsg varchar(200)
    Select @ErrMsg = 'Sorry, please try again later.'
    RaisError (@ErrMsg, 16, 1)
    return
END
*/

--Check Old_minmax <> New_minmax
Declare     @old_minpositiontaking_1 smallmoney,
    @old_minpositiontaking_2 smallmoney,
    @old_minpositiontaking_3 smallmoney,
    @old_minpositiontaking_4 smallmoney,
    @old_minpositiontaking_5 smallmoney,
    @old_minpositiontaking_6 smallmoney,
    @old_minpositiontaking_7 smallmoney,
    @old_minpositiontaking_8 smallmoney,
    @old_minpositiontaking_9 smallmoney,
    @old_minpositiontaking_10 smallmoney,
    @old_minpositiontaking_9999 smallmoney,
    @old_minlivepositiontaking_1 smallmoney,
    @old_minlivepositiontaking_3 smallmoney,
    @old_minlivepositiontaking_7 smallmoney,
    @old_minlivepositiontaking_8 smallmoney,
    
    @old_minv2positiontaking_1 smallmoney,
    @old_minv2positiontaking_2 smallmoney,
    @old_minv2positiontaking_3 smallmoney,
    @old_minv2positiontaking_7 smallmoney,
    @old_minv2positiontaking_8 smallmoney,
    --@old_minv2positiontaking_9 smallmoney,
    @old_minv2positiontaking_20 smallmoney,
    @old_minv2positiontaking_9999 smallmoney,

    @old_minv3positiontaking_1 smallmoney,
    @old_minv3positiontaking_2 smallmoney,
    @old_minv3positiontaking_3 smallmoney,
    @old_minv3positiontaking_20 smallmoney,

    @old_minv5positiontaking_1 smallmoney,
    @old_minv5positiontaking_2 smallmoney,
    @old_minv5positiontaking_3 smallmoney,
    @old_minv5positiontaking_20 smallmoney,
    @old_minv5positiontaking_9999 smallmoney,

    @old_minv8positiontaking_1 smallmoney,
    @old_minv8positiontaking_3 smallmoney,
    @old_minv8positiontaking_20 smallmoney,

    @old_minv10positiontaking_1 smallmoney,
    @old_minv10positiontaking_2 smallmoney,
    @old_minv10positiontaking_3 smallmoney,
    @old_minv10positiontaking_20 smallmoney,

    @old_minv11positiontaking_1 smallmoney,
    @old_minv11positiontaking_20 smallmoney,

    @old_minv99positiontaking_1 smallmoney,
    @old_minv99positiontaking_2 smallmoney,
    @old_minv99positiontaking_3 smallmoney,
    @old_minv99positiontaking_9 smallmoney,
    @old_minv99positiontaking_20 smallmoney,
	@old_minv99positiontaking_9999 smallmoney,   
    
    @old_maxpositiontaking_1 smallmoney,
    @old_maxpositiontaking_2 smallmoney,
    @old_maxpositiontaking_3 smallmoney,
    @old_maxpositiontaking_4 smallmoney,
    @old_maxpositiontaking_5 smallmoney,
    @old_maxpositiontaking_6 smallmoney,
    @old_maxpositiontaking_7 smallmoney,
    @old_maxpositiontaking_8 smallmoney,
    @old_maxpositiontaking_9 smallmoney,
    @old_maxpositiontaking_10 smallmoney,
    @old_maxpositiontaking_9999 smallmoney,
    
    @old_maxlivepositiontaking_1 smallmoney,
    @old_maxlivepositiontaking_3 smallmoney,
    @old_maxlivepositiontaking_7 smallmoney,
    @old_maxlivepositiontaking_8 smallmoney,
    
    @old_maxv2positiontaking_1 smallmoney,
    @old_maxv2positiontaking_2 smallmoney,
    @old_maxv2positiontaking_3 smallmoney,
    @old_maxv2positiontaking_7 smallmoney,
    @old_maxv2positiontaking_8 smallmoney,
    --@old_maxv2positiontaking_9 smallmoney,
    @old_maxv2positiontaking_20 smallmoney,
    @old_maxv2positiontaking_9999 smallmoney,

    @old_maxv3positiontaking_1 smallmoney,
    @old_maxv3positiontaking_2 smallmoney,
    @old_maxv3positiontaking_3 smallmoney,
    @old_maxv3positiontaking_20 smallmoney,

    @old_maxv5positiontaking_1 smallmoney,
    @old_maxv5positiontaking_2 smallmoney,
    @old_maxv5positiontaking_3 smallmoney,
    @old_maxv5positiontaking_20 smallmoney,
    @old_maxv5positiontaking_9999 smallmoney,

    @old_maxv8positiontaking_1 smallmoney,
    @old_maxv8positiontaking_3 smallmoney,
    @old_maxv8positiontaking_20 smallmoney,

    @old_maxv10positiontaking_1 smallmoney,
    @old_maxv10positiontaking_2 smallmoney,
    @old_maxv10positiontaking_3 smallmoney,
    @old_maxv10positiontaking_20 smallmoney,

    @old_maxv11positiontaking_1 smallmoney,
    @old_maxv11positiontaking_20 smallmoney,

    @old_maxv99positiontaking_1 smallmoney,
    @old_maxv99positiontaking_2 smallmoney,
    @old_maxv99positiontaking_3 smallmoney,
    @old_maxv99positiontaking_9 smallmoney,
    @old_maxv99positiontaking_20 smallmoney,
	@old_maxv99positiontaking_9999 smallmoney,
   
    @old_minv2positiontaking_10 smallmoney,
    @old_minv3positiontaking_10 smallmoney,
    @old_minv5positiontaking_10 smallmoney,
    @old_minv8positiontaking_10 smallmoney,
    @old_minv10positiontaking_10 smallmoney,
    @old_minv11positiontaking_10 smallmoney,
    @old_minv99positiontaking_10 smallmoney,
    
	@old_maxv2positiontaking_10 smallmoney,
	@old_maxv3positiontaking_10 smallmoney,
	@old_maxv5positiontaking_10 smallmoney,
	@old_maxv8positiontaking_10 smallmoney,
	@old_maxv10positiontaking_10 smallmoney,
	@old_maxv11positiontaking_10 smallmoney,
	@old_maxv99positiontaking_10 smallmoney
	
	

    
--Get Old data
    select @old_minpositiontaking_1 = minpositiontaking, @old_maxpositiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 1
    select @old_minpositiontaking_2 = minpositiontaking, @old_maxpositiontaking_2 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 2
    select @old_minpositiontaking_3 = minpositiontaking, @old_maxpositiontaking_3 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 3
    select @old_minpositiontaking_4 = minpositiontaking, @old_maxpositiontaking_4 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 4
    select @old_minpositiontaking_5 = minpositiontaking, @old_maxpositiontaking_5 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 5
    select @old_minpositiontaking_6 = minpositiontaking, @old_maxpositiontaking_6 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 6
    select @old_minpositiontaking_7 = minpositiontaking, @old_maxpositiontaking_7 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 7
    select @old_minpositiontaking_8 = minpositiontaking, @old_maxpositiontaking_8 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 8
    select @old_minpositiontaking_9 = minpositiontaking, @old_maxpositiontaking_9 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 9
    select @old_minpositiontaking_10 = minpositiontaking, @old_maxpositiontaking_10 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 10
    
    -- Outright PT for sports
    select @old_minv2positiontaking_10 = minpositiontaking, @old_maxv2positiontaking_10 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 10
    select @old_minv3positiontaking_10 = minpositiontaking, @old_maxv3positiontaking_10 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 3 and bettype = 10
    select @old_minv5positiontaking_10 = minpositiontaking, @old_maxv5positiontaking_10 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 5 and bettype = 10
    select @old_minv8positiontaking_10 = minpositiontaking, @old_maxv8positiontaking_10 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 8 and bettype = 10
    select @old_minv10positiontaking_10 = minpositiontaking, @old_maxv10positiontaking_10 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 10 and bettype = 10
    select @old_minv11positiontaking_10 = minpositiontaking, @old_maxv11positiontaking_10 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 11 and bettype = 10
    select @old_minv99positiontaking_10 = minpositiontaking, @old_maxv99positiontaking_10 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 99 and bettype = 10
    
    
    select @old_minpositiontaking_9999 = minpositiontaking, @old_maxpositiontaking_9999 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 9999
    
    select @old_minlivepositiontaking_1 = minlivepositiontaking, @old_maxlivepositiontaking_1 = maxlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 1
    select @old_minlivepositiontaking_3 = minlivepositiontaking, @old_maxlivepositiontaking_3 = maxlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 3
    select @old_minlivepositiontaking_7 = minlivepositiontaking, @old_maxlivepositiontaking_7 = maxlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 7
    select @old_minlivepositiontaking_8 = minlivepositiontaking, @old_maxlivepositiontaking_8 = maxlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 8
    
    select @old_minv2positiontaking_1 = minpositiontaking, @old_maxv2positiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 1
    select @old_minv2positiontaking_2 = minpositiontaking, @old_maxv2positiontaking_2 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 2
    select @old_minv2positiontaking_3 = minpositiontaking, @old_maxv2positiontaking_3 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 3
    select @old_minv2positiontaking_7 = minpositiontaking, @old_maxv2positiontaking_7 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 7
    select @old_minv2positiontaking_8 = minpositiontaking, @old_maxv2positiontaking_8 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 8
    --select @old_minv2positiontaking_9 = minpositiontaking, @old_maxv2positiontaking_9 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 9
    select @old_minv2positiontaking_20 = minpositiontaking, @old_maxv2positiontaking_20 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 20
    select @old_minv2positiontaking_9999 = minpositiontaking, @old_maxv2positiontaking_9999 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 9999

    select @old_minv3positiontaking_1 = minpositiontaking, @old_maxv3positiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=3 and bettype = 1
    select @old_minv3positiontaking_2 = minpositiontaking, @old_maxv3positiontaking_2 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=3 and bettype = 2
    select @old_minv3positiontaking_3 = minpositiontaking, @old_maxv3positiontaking_3 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=3 and bettype = 3
    select @old_minv3positiontaking_20 = minpositiontaking, @old_maxv3positiontaking_20 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=3 and bettype = 20

    select @old_minv5positiontaking_1 = minpositiontaking, @old_maxv5positiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=5 and bettype = 1
    select @old_minv5positiontaking_2 = minpositiontaking, @old_maxv5positiontaking_2 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=5 and bettype = 2
    select @old_minv5positiontaking_3 = minpositiontaking, @old_maxv5positiontaking_3 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=5 and bettype = 3
    select @old_minv5positiontaking_20 = minpositiontaking, @old_maxv5positiontaking_20 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=5 and bettype = 20
    select @old_minv5positiontaking_9999 = minpositiontaking, @old_maxv5positiontaking_9999 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=5 and bettype = 9999

    select @old_minv8positiontaking_1 = minpositiontaking, @old_maxv8positiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=8 and bettype = 1
    select @old_minv8positiontaking_3 = minpositiontaking, @old_maxv8positiontaking_3 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=8 and bettype = 3
    select @old_minv8positiontaking_20 = minpositiontaking, @old_maxv8positiontaking_20 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=8 and bettype = 20

    select @old_minv10positiontaking_1 = minpositiontaking, @old_maxv10positiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=10 and bettype = 1
    select @old_minv10positiontaking_2 = minpositiontaking, @old_maxv10positiontaking_2 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=10 and bettype = 2
    select @old_minv10positiontaking_3 = minpositiontaking, @old_maxv10positiontaking_3 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=10 and bettype = 3
    select @old_minv10positiontaking_20 = minpositiontaking, @old_maxv10positiontaking_20 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=10 and bettype = 20

    select @old_minv11positiontaking_1 = minpositiontaking, @old_maxv11positiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=11 and bettype = 1
    select @old_minv11positiontaking_20 = minpositiontaking, @old_maxv11positiontaking_20 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=11 and bettype = 20

    select @old_minv99positiontaking_1 = minpositiontaking, @old_maxv99positiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=99 and bettype = 1
    select @old_minv99positiontaking_2 = minpositiontaking, @old_maxv99positiontaking_2 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=99 and bettype = 2
    select @old_minv99positiontaking_3 = minpositiontaking, @old_maxv99positiontaking_3 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=99 and bettype = 3
    select @old_minv99positiontaking_9 = minpositiontaking, @old_maxv99positiontaking_9 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=99 and bettype = 9
    select @old_minv99positiontaking_20 = minpositiontaking, @old_maxv99positiontaking_20 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=99 and bettype = 20
    select @old_minv99positiontaking_9999 = minpositiontaking, @old_maxv99positiontaking_9999 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=99 and bettype = 9999      

--Check Old_minmax = New_minmax
IF (@UpdateMinPos = 0 or 
        (
            @minpositiontaking_1 = @old_minpositiontaking_1 and
            @minpositiontaking_2 = @old_minpositiontaking_2 and
            @minpositiontaking_3 = @old_minpositiontaking_3 and
            @minpositiontaking_4 = @old_minpositiontaking_4 and
            @minpositiontaking_5 = @old_minpositiontaking_5 and
            @minpositiontaking_6 = @old_minpositiontaking_6 and
            @minpositiontaking_7 = @old_minpositiontaking_7 and
            @minpositiontaking_8 = @old_minpositiontaking_8 and
            @minpositiontaking_9 = @old_minpositiontaking_9 and
            @minpositiontaking_10 = @old_minpositiontaking_10 and
            
            -- outright PT for sports
            @minv2positiontaking_10 = @old_minv2positiontaking_10 and
            @minv3positiontaking_10 = @old_minv3positiontaking_10 and
            @minv5positiontaking_10 = @old_minv5positiontaking_10 and
            @minv8positiontaking_10 = @old_minv8positiontaking_10 and
            @minv10positiontaking_10 = @old_minv10positiontaking_10 and
            @minv11positiontaking_10 = @old_minv11positiontaking_10 and
            @minv99positiontaking_10 = @old_minv99positiontaking_10 and
            
            @minpositiontaking_9999 = @old_minpositiontaking_9999 and
            @minlivepositiontaking_1 = @old_minlivepositiontaking_1 and
            @minlivepositiontaking_3 = @old_minlivepositiontaking_3 and
            @minlivepositiontaking_7 = @old_minlivepositiontaking_7 and
            @minlivepositiontaking_8 = @old_minlivepositiontaking_8 and

            @minv2positiontaking_1 = @old_minv2positiontaking_1 and
            @minv2positiontaking_2 = @old_minv2positiontaking_2 and
            @minv2positiontaking_3 = @old_minv2positiontaking_3 and
            @minv2positiontaking_7 = @old_minv2positiontaking_7 and
            @minv2positiontaking_8 = @old_minv2positiontaking_8 and
            --@minv2positiontaking_9 = @old_minv2positiontaking_9 and
            @minv2positiontaking_20 = @old_minv2positiontaking_20 and
            @minv2positiontaking_9999 = @old_minv2positiontaking_9999 and

            @minv3positiontaking_1 = @old_minv3positiontaking_1 and
            @minv3positiontaking_2 = @old_minv3positiontaking_2 and
            @minv3positiontaking_3 = @old_minv3positiontaking_3 and
            @minv3positiontaking_20 = @old_minv3positiontaking_20 and

            @minv5positiontaking_1 = @old_minv5positiontaking_1 and
            @minv5positiontaking_2 = @old_minv5positiontaking_2 and
            @minv5positiontaking_3 = @old_minv5positiontaking_3 and
            @minv5positiontaking_20 = @old_minv5positiontaking_20 and
            @minv5positiontaking_9999 = @old_minv5positiontaking_9999 and

            @minv8positiontaking_1 = @old_minv8positiontaking_1 and
            @minv8positiontaking_3 = @old_minv8positiontaking_3 and
            @minv8positiontaking_20 = @old_minv8positiontaking_20 and

            @minv10positiontaking_1 = @old_minv10positiontaking_1 and
            @minv10positiontaking_2 = @old_minv10positiontaking_2 and
            @minv10positiontaking_3 = @old_minv10positiontaking_3 and
            @minv10positiontaking_20 = @old_minv10positiontaking_20 and

            @minv11positiontaking_1 = @old_minv11positiontaking_1 and
            @minv11positiontaking_20 = @old_minv11positiontaking_20 and

            @minv99positiontaking_1 = @old_minv99positiontaking_1 and
            @minv99positiontaking_2 = @old_minv99positiontaking_2 and
            @minv99positiontaking_3 = @old_minv99positiontaking_3 and
            @minv99positiontaking_9 = @old_minv99positiontaking_9 and
            @minv99positiontaking_20 = @old_minv99positiontaking_20 and
            @minv99positiontaking_9999 = @old_minv99positiontaking_9999 
        )
    )
    and 
    ( @UpdateMaxPos = 0 or
        (
            @maxpositiontaking_1 = @old_maxpositiontaking_1 and
            @maxpositiontaking_2 = @old_maxpositiontaking_2 and
            @maxpositiontaking_3 = @old_maxpositiontaking_3 and
            @maxpositiontaking_4 = @old_maxpositiontaking_4 and
            @maxpositiontaking_5 = @old_maxpositiontaking_5 and
            @maxpositiontaking_6 = @old_maxpositiontaking_6 and
            @maxpositiontaking_7 = @old_maxpositiontaking_7 and
            @maxpositiontaking_8 = @old_maxpositiontaking_8 and
            @maxpositiontaking_9 = @old_maxpositiontaking_9 and
            @maxpositiontaking_10 = @old_maxpositiontaking_10 and
            
            -- outright PT for sports
            @maxv2positiontaking_10 = @old_maxv2positiontaking_10 and
            @maxv3positiontaking_10 = @old_maxv3positiontaking_10 and
            @maxv5positiontaking_10 = @old_maxv5positiontaking_10 and
            @maxv8positiontaking_10 = @old_maxv8positiontaking_10 and
            @maxv10positiontaking_10 = @old_maxv10positiontaking_10 and
            @maxv11positiontaking_10 = @old_maxv11positiontaking_10 and
            @maxv99positiontaking_10 = @old_maxv99positiontaking_10 and
            
            
            @maxpositiontaking_9999 = @old_maxpositiontaking_9999 and
            @maxlivepositiontaking_1 = @old_maxlivepositiontaking_1 and
            @maxlivepositiontaking_3 = @old_maxlivepositiontaking_3 and
            @maxlivepositiontaking_7 = @old_maxlivepositiontaking_7 and
            @maxlivepositiontaking_8 = @old_maxlivepositiontaking_8 and

            @maxv2positiontaking_1 = @old_maxv2positiontaking_1 and
            @maxv2positiontaking_2 = @old_maxv2positiontaking_2 and
            @maxv2positiontaking_3 = @old_maxv2positiontaking_3 and
            @maxv2positiontaking_7 = @old_maxv2positiontaking_7 and
            @maxv2positiontaking_8 = @old_maxv2positiontaking_8 and
            --@maxv2positiontaking_9 = @old_maxv2positiontaking_9 and
            @maxv2positiontaking_20 = @old_maxv2positiontaking_20 and
            @maxv2positiontaking_9999 = @old_maxv2positiontaking_9999 and

            @maxv3positiontaking_1 = @old_maxv3positiontaking_1 and
            @maxv3positiontaking_2 = @old_maxv3positiontaking_2 and
            @maxv3positiontaking_3 = @old_maxv3positiontaking_3 and
            @maxv3positiontaking_20 = @old_maxv3positiontaking_20 and

            @maxv5positiontaking_1 = @old_maxv5positiontaking_1 and
            @maxv5positiontaking_2 = @old_maxv5positiontaking_2 and
            @maxv5positiontaking_3 = @old_maxv5positiontaking_3 and
            @maxv5positiontaking_20 = @old_maxv5positiontaking_20 and
            @maxv5positiontaking_9999 = @old_maxv5positiontaking_9999 and

            @maxv8positiontaking_1 = @old_maxv8positiontaking_1 and
            @maxv8positiontaking_3 = @old_maxv8positiontaking_3 and
            @maxv8positiontaking_20 = @old_maxv8positiontaking_20 and

            @maxv10positiontaking_1 = @old_maxv10positiontaking_1 and
            @maxv10positiontaking_2 = @old_maxv10positiontaking_2 and
            @maxv10positiontaking_3 = @old_maxv10positiontaking_3 and
            @maxv10positiontaking_20 = @old_maxv10positiontaking_20 and

            @maxv11positiontaking_1 = @old_maxv11positiontaking_1 and
            @maxv11positiontaking_20 = @old_maxv11positiontaking_20 and

            @maxv99positiontaking_1 = @old_maxv99positiontaking_1 and
            @maxv99positiontaking_2 = @old_maxv99positiontaking_2 and
            @maxv99positiontaking_3 = @old_maxv99positiontaking_3 and
            @maxv99positiontaking_9 = @old_maxv99positiontaking_9 and
            @maxv99positiontaking_20 = @old_maxv99positiontaking_20 and
			@maxv99positiontaking_9999 = @old_maxv99positiontaking_9999                         
        )
    )
BEGIN
    return
END

--check and set new values
IF(@UpdateMinPos = 0)    
BEGIN
    SELECT @minpositiontaking_1 = @old_minpositiontaking_1,
            @minpositiontaking_2 = @old_minpositiontaking_2,
            @minpositiontaking_3 = @old_minpositiontaking_3,
            @minpositiontaking_4 = @old_minpositiontaking_4,
            @minpositiontaking_5 = @old_minpositiontaking_5,
            @minpositiontaking_6 = @old_minpositiontaking_6,
            @minpositiontaking_7 = @old_minpositiontaking_7,
            @minpositiontaking_8 = @old_minpositiontaking_8,
            @minpositiontaking_9 = @old_minpositiontaking_9,
            @minpositiontaking_10 = @old_minpositiontaking_10,
            -- Outright PT for sports
            @minv2positiontaking_10 = @old_minv2positiontaking_10,
            @minv3positiontaking_10 = @old_minv3positiontaking_10,
            @minv5positiontaking_10 = @old_minv5positiontaking_10,
            @minv8positiontaking_10 = @old_minv8positiontaking_10,
            @minv10positiontaking_10 = @old_minv10positiontaking_10,
            @minv11positiontaking_10 = @old_minv11positiontaking_10,
            @minv99positiontaking_10 = @old_minv99positiontaking_10,
            
            @minpositiontaking_9999 = @old_minpositiontaking_9999,
            @minlivepositiontaking_1 = @old_minlivepositiontaking_1,
            @minlivepositiontaking_3 = @old_minlivepositiontaking_3,
            @minlivepositiontaking_7 = @old_minlivepositiontaking_7,
            @minlivepositiontaking_8 = @old_minlivepositiontaking_8,

            @minv2positiontaking_1 = @old_minv2positiontaking_1,
            @minv2positiontaking_2 = @old_minv2positiontaking_2,
            @minv2positiontaking_3 = @old_minv2positiontaking_3,
            @minv2positiontaking_7 = @old_minv2positiontaking_7,
            @minv2positiontaking_8 = @old_minv2positiontaking_8,
            --@minv2positiontaking_9 = @old_minv2positiontaking_9,
            @minv2positiontaking_20 = @old_minv2positiontaking_20,
            @minv2positiontaking_9999 = @old_minv2positiontaking_9999,

            @minv3positiontaking_1 = @old_minv3positiontaking_1,
            @minv3positiontaking_2 = @old_minv3positiontaking_2,
            @minv3positiontaking_3 = @old_minv3positiontaking_3,
            @minv3positiontaking_20 = @old_minv3positiontaking_20,

            @minv5positiontaking_1 = @old_minv5positiontaking_1,
            @minv5positiontaking_2 = @old_minv5positiontaking_2,
            @minv5positiontaking_3 = @old_minv5positiontaking_3,
            @minv5positiontaking_20 = @old_minv5positiontaking_20,
            @minv5positiontaking_9999 = @old_minv5positiontaking_9999,

            @minv8positiontaking_1 = @old_minv8positiontaking_1,
            @minv8positiontaking_3 = @old_minv8positiontaking_3,
            @minv8positiontaking_20 = @old_minv8positiontaking_20,

            @minv10positiontaking_1 = @old_minv10positiontaking_1,
            @minv10positiontaking_2 = @old_minv10positiontaking_2,
            @minv10positiontaking_3 = @old_minv10positiontaking_3,
            @minv10positiontaking_20 = @old_minv10positiontaking_20,

            @minv11positiontaking_1 = @old_minv11positiontaking_1,
            @minv11positiontaking_20 = @old_minv11positiontaking_20,

            @minv99positiontaking_1 = @old_minv99positiontaking_1,
            @minv99positiontaking_2 = @old_minv99positiontaking_2,
            @minv99positiontaking_3 = @old_minv99positiontaking_3,
            @minv99positiontaking_9 = @old_minv99positiontaking_9,
            @minv99positiontaking_20 = @old_minv99positiontaking_20,
            @minv99positiontaking_9999 = @old_minv99positiontaking_9999
END

IF @UpdateMaxPos = 0 
    BEGIN
        SELECT @maxpositiontaking_1 = @old_maxpositiontaking_1,
            @maxpositiontaking_2 = @old_maxpositiontaking_2,
            @maxpositiontaking_3 = @old_maxpositiontaking_3,
            @maxpositiontaking_4 = @old_maxpositiontaking_4,
            @maxpositiontaking_5 = @old_maxpositiontaking_5,
            @maxpositiontaking_6 = @old_maxpositiontaking_6,
            @maxpositiontaking_7 = @old_maxpositiontaking_7,
            @maxpositiontaking_8 = @old_maxpositiontaking_8,
            @maxpositiontaking_9 = @old_maxpositiontaking_9,
            @maxpositiontaking_10 = @old_maxpositiontaking_10,
            -- Outright PT for sports
            @maxv2positiontaking_10 = @old_maxv2positiontaking_10,
            @maxv3positiontaking_10 = @old_maxv3positiontaking_10,
            @maxv5positiontaking_10 = @old_maxv5positiontaking_10,
            @maxv8positiontaking_10 = @old_maxv8positiontaking_10,
            @maxv10positiontaking_10 = @old_maxv10positiontaking_10,
            @maxv11positiontaking_10 = @old_maxv11positiontaking_10,
            @maxv99positiontaking_10 = @old_maxv99positiontaking_10,
            
            @maxpositiontaking_9999 = @old_maxpositiontaking_9999,
            @maxlivepositiontaking_1 = @old_maxlivepositiontaking_1,
            @maxlivepositiontaking_3 = @old_maxlivepositiontaking_3,
            @maxlivepositiontaking_7 = @old_maxlivepositiontaking_7,
            @maxlivepositiontaking_8 = @old_maxlivepositiontaking_8,

            @maxv2positiontaking_1 = @old_maxv2positiontaking_1,
            @maxv2positiontaking_2 = @old_maxv2positiontaking_2,
            @maxv2positiontaking_3 = @old_maxv2positiontaking_3,
            @maxv2positiontaking_7 = @old_maxv2positiontaking_7,
            @maxv2positiontaking_8 = @old_maxv2positiontaking_8,
            --@maxv2positiontaking_9 = @old_maxv2positiontaking_9,
            @maxv2positiontaking_20 = @old_maxv2positiontaking_20,
            @maxv2positiontaking_9999 = @old_maxv2positiontaking_9999,

            @maxv3positiontaking_1 = @old_maxv3positiontaking_1,
            @maxv3positiontaking_2 = @old_maxv3positiontaking_2,
            @maxv3positiontaking_3 = @old_maxv3positiontaking_3,
            @maxv3positiontaking_20 = @old_maxv3positiontaking_20,

            @maxv5positiontaking_1 = @old_maxv5positiontaking_1,
            @maxv5positiontaking_2 = @old_maxv5positiontaking_2,
            @maxv5positiontaking_3 = @old_maxv5positiontaking_3,
            @maxv5positiontaking_20 = @old_maxv5positiontaking_20,
            @maxv5positiontaking_9999 = @old_maxv5positiontaking_9999,

            @maxv8positiontaking_1 = @old_maxv8positiontaking_1,
            @maxv8positiontaking_3 = @old_maxv8positiontaking_3,
            @maxv8positiontaking_20 = @old_maxv8positiontaking_20,

            @maxv10positiontaking_1 = @old_maxv10positiontaking_1,
            @maxv10positiontaking_2 = @old_maxv10positiontaking_2,
            @maxv10positiontaking_3 = @old_maxv10positiontaking_3,
            @maxv10positiontaking_20 = @old_maxv10positiontaking_20,

            @maxv11positiontaking_1 = @old_maxv11positiontaking_1,
            @maxv11positiontaking_20 = @old_maxv11positiontaking_20,

            @maxv99positiontaking_1 = @old_maxv99positiontaking_1,
            @maxv99positiontaking_2 = @old_maxv99positiontaking_2,
            @maxv99positiontaking_3 = @old_maxv99positiontaking_3,
            @maxv99positiontaking_9 = @old_maxv99positiontaking_9,
            @maxv99positiontaking_20 = @old_maxv99positiontaking_20,
            @maxv99positiontaking_9999 = @old_maxv99positiontaking_9999 
    END    

EXEC dbo.Acc_CustOverrideUpd_CheckParam
            @custid = @custid,
            @minpositiontaking_1 = @minpositiontaking_1,
            @minpositiontaking_2 = @minpositiontaking_2,
            @minpositiontaking_3 = @minpositiontaking_3,
            @minpositiontaking_4 = @minpositiontaking_4,
            @minpositiontaking_5 = @minpositiontaking_5,
            @minpositiontaking_6 = @minpositiontaking_6,
            @minpositiontaking_7 = @minpositiontaking_7,
            @minpositiontaking_8 = @minpositiontaking_8,
            @minpositiontaking_9 = @minpositiontaking_9,
            @minpositiontaking_10 = @minpositiontaking_10,
            
            -- outright PT for sports
            @minv2positiontaking_10 = @minv2positiontaking_10,
            @minv3positiontaking_10 = @minv3positiontaking_10,
            @minv5positiontaking_10 = @minv5positiontaking_10,
            @minv8positiontaking_10 = @minv8positiontaking_10,
            @minv10positiontaking_10 = @minv10positiontaking_10,
            @minv11positiontaking_10 = @minv11positiontaking_10,
            @minv99positiontaking_10 = @minv99positiontaking_10,
            
            
            @minpositiontaking_9999 = @minpositiontaking_9999,
            @minlivepositiontaking_1 = @minlivepositiontaking_1,
            @minlivepositiontaking_3 = @minlivepositiontaking_3,
            @minlivepositiontaking_7 = @minlivepositiontaking_7,
            @minlivepositiontaking_8 = @minlivepositiontaking_8,
            @minv2positiontaking_1 = @minv2positiontaking_1,
            @minv2positiontaking_2 = @minv2positiontaking_2,
            @minv2positiontaking_3 = @minv2positiontaking_3,
            @minv2positiontaking_7 = @minv2positiontaking_7,
            @minv2positiontaking_8 = @minv2positiontaking_8,
            --@minv2positiontaking_9 = @minv2positiontaking_9,
            @minv2positiontaking_20 = @minv2positiontaking_20,
            @minv2positiontaking_9999 = @minv2positiontaking_9999,

            @minv3positiontaking_1 = @minv3positiontaking_1,
            @minv3positiontaking_2 = @minv3positiontaking_2,
            @minv3positiontaking_3 = @minv3positiontaking_3,
            @minv3positiontaking_20 = @minv3positiontaking_20,
            @minv5positiontaking_1 = @minv5positiontaking_1,
            @minv5positiontaking_2 = @minv5positiontaking_2,
            @minv5positiontaking_3 = @minv5positiontaking_3,
            @minv5positiontaking_20 = @minv5positiontaking_20,
            @minv5positiontaking_9999 = @minv5positiontaking_9999,
            @minv8positiontaking_1 = @minv8positiontaking_1,
            @minv8positiontaking_3 = @minv8positiontaking_3,
            @minv8positiontaking_20 = @minv8positiontaking_20,
            @minv10positiontaking_1 = @minv10positiontaking_1,
            @minv10positiontaking_2 = @minv10positiontaking_2,
            @minv10positiontaking_3 = @minv10positiontaking_3,
            @minv10positiontaking_20 = @minv10positiontaking_20,
            @minv11positiontaking_1 = @minv11positiontaking_1,
            @minv11positiontaking_20 = @minv11positiontaking_20,

            @minv99positiontaking_1 = @minv99positiontaking_1,
            @minv99positiontaking_2 = @minv99positiontaking_2,
            @minv99positiontaking_3 = @minv99positiontaking_3,
            @minv99positiontaking_9 = @minv99positiontaking_9,
            @minv99positiontaking_20 = @minv99positiontaking_20,
            @minv99positiontaking_9999 = @minv99positiontaking_9999,
                      
            @maxpositiontaking_1 = @maxpositiontaking_1,
            @maxpositiontaking_2 = @maxpositiontaking_2,
            @maxpositiontaking_3 = @maxpositiontaking_3,
            @maxpositiontaking_4 = @maxpositiontaking_4,
            @maxpositiontaking_5 = @maxpositiontaking_5,
            @maxpositiontaking_6 = @maxpositiontaking_6,
            @maxpositiontaking_7 = @maxpositiontaking_7,
            @maxpositiontaking_8 = @maxpositiontaking_8,
            @maxpositiontaking_9 = @maxpositiontaking_9,
            @maxpositiontaking_10 = @maxpositiontaking_10,
            -- Outright PT for sports
            @maxv2positiontaking_10 = @maxv2positiontaking_10,
            @maxv3positiontaking_10 = @maxv3positiontaking_10,
            @maxv5positiontaking_10 = @maxv5positiontaking_10,
            @maxv8positiontaking_10 = @maxv8positiontaking_10,
            @maxv10positiontaking_10 = @maxv10positiontaking_10,
            @maxv11positiontaking_10 = @maxv11positiontaking_10,
            @maxv99positiontaking_10 = @maxv99positiontaking_10,
                        
            @maxpositiontaking_9999 = @maxpositiontaking_9999,
            @maxlivepositiontaking_1 = @maxlivepositiontaking_1,
            @maxlivepositiontaking_3 = @maxlivepositiontaking_3,
            @maxlivepositiontaking_7 = @maxlivepositiontaking_7,
            @maxlivepositiontaking_8 = @maxlivepositiontaking_8,
            @maxv2positiontaking_1 = @maxv2positiontaking_1,
            @maxv2positiontaking_2 = @maxv2positiontaking_2,
            @maxv2positiontaking_3 = @maxv2positiontaking_3,
            @maxv2positiontaking_7 = @maxv2positiontaking_7,
            @maxv2positiontaking_8 = @maxv2positiontaking_8,
            --@maxv2positiontaking_9 = @maxv2positiontaking_9,
            @maxv2positiontaking_20 = @maxv2positiontaking_20,
            @maxv2positiontaking_9999 = @maxv2positiontaking_9999,

            @maxv3positiontaking_1 = @maxv3positiontaking_1,
            @maxv3positiontaking_2 = @maxv3positiontaking_2,
            @maxv3positiontaking_3 = @maxv3positiontaking_3,
            @maxv3positiontaking_20 = @maxv3positiontaking_20,
            @maxv5positiontaking_1 = @maxv5positiontaking_1,
            @maxv5positiontaking_2 = @maxv5positiontaking_2,
            @maxv5positiontaking_3 = @maxv5positiontaking_3,
            @maxv5positiontaking_20 = @maxv5positiontaking_20,
            @maxv5positiontaking_9999 = @maxv5positiontaking_9999,
            @maxv8positiontaking_1 = @maxv8positiontaking_1,
            @maxv8positiontaking_3 = @maxv8positiontaking_3,
            @maxv8positiontaking_20 = @maxv8positiontaking_20,
            @maxv10positiontaking_1 = @maxv10positiontaking_1,
            @maxv10positiontaking_2 = @maxv10positiontaking_2,
            @maxv10positiontaking_3 = @maxv10positiontaking_3,
            @maxv10positiontaking_20 = @maxv10positiontaking_20,
            @maxv11positiontaking_1 = @maxv11positiontaking_1,
            @maxv11positiontaking_20 = @maxv11positiontaking_20,

            @maxv99positiontaking_1 = @maxv99positiontaking_1,
            @maxv99positiontaking_2 = @maxv99positiontaking_2,
            @maxv99positiontaking_3 = @maxv99positiontaking_3,
            @maxv99positiontaking_9 = @maxv99positiontaking_9,
            @maxv99positiontaking_20 = @maxv99positiontaking_20,
            @maxv99positiontaking_9999 = @maxv99positiontaking_9999,            
            
            @UpdateMinPos = @UpdateMinPos,
            @UpdateMaxPos = @UpdateMaxPos,
            @roleid = @roleid,
            @srecommend = @srecommend,
            @mrecommend = @mrecommend,
            @recommend = @recommend,
            @isvalid = @isvalid OUTPUT,
            @errmsg = @errmsg OUTPUT,
            @errcode = @errcode OUTPUT,
            @language = @language

if @ErrCode <> 0
BEGIN
    return
END

----------------------------------------------------------------------------------------------------
declare @logdata nvarchar(300)

if @UpdateMinPos = 1
BEGIN
    
    Update custoverride with (ROWLOCK, UPDLOCK) set minpositiontaking = b.minpositiontaking, minlivepositiontaking = b.minlivepositiontaking
    from custoverride inner join     
            (
                select         @custid as custid,  1 as sporttype, 1 as bettype, @minpositiontaking_1 as minpositiontaking,  @minlivepositiontaking_1 as minlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 2 as bettype, @minpositiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 3 as bettype, @minpositiontaking_3 as minpositiontaking,  @minlivepositiontaking_3 as minlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 4 as bettype, @minpositiontaking_4 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 5 as bettype, @minpositiontaking_5 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 6 as bettype, @minpositiontaking_6 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 7 as bettype, @minpositiontaking_7 as minpositiontaking,  @minlivepositiontaking_7 as minlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 8 as bettype, @minpositiontaking_8 as minpositiontaking,  @minlivepositiontaking_8 as minlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 9 as bettype, @minpositiontaking_9 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 10 as bettype, @minpositiontaking_10 as minpositiontaking,  0 as minlivepositiontaking
                
                -- Outright PT for sports 
                union all select     @custid as custid,  2 as sporttype, 10 as bettype, @minv2positiontaking_10 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  3 as sporttype, 10 as bettype, @minv3positiontaking_10 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  5 as sporttype, 10 as bettype, @minv5positiontaking_10 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  8 as sporttype, 10 as bettype, @minv8positiontaking_10 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  10 as sporttype, 10 as bettype, @minv10positiontaking_10 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  11 as sporttype, 10 as bettype, @minv11positiontaking_10 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  99 as sporttype, 10 as bettype, @minv99positiontaking_10 as minpositiontaking,  0 as minlivepositiontaking
                
                union all select     @custid as custid,  1 as sporttype, 9999 as bettype, @minpositiontaking_9999 as minpositiontaking,  0 as minlivepositiontaking
                
                union all select     @custid as custid,  2 as sporttype, 1 as bettype, @minv2positiontaking_1 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  2 as sporttype, 2 as bettype, @minv2positiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  2 as sporttype, 3 as bettype, @minv2positiontaking_3 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  2 as sporttype, 7 as bettype, @minv2positiontaking_7 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  2 as sporttype, 8 as bettype, @minv2positiontaking_8 as minpositiontaking,  0 as minlivepositiontaking
                --union all select     @custid as custid,  2 as sporttype, 9 as bettype, @minv2positiontaking_9 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  2 as sporttype, 20 as bettype, @minv2positiontaking_20 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  2 as sporttype, 9999 as bettype, @minv2positiontaking_9999 as minpositiontaking,  0 as minlivepositiontaking

                union all select     @custid as custid,  3 as sporttype, 1 as bettype, @minv3positiontaking_1 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  3 as sporttype, 2 as bettype, @minv3positiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  3 as sporttype, 3 as bettype, @minv3positiontaking_3 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  3 as sporttype, 20 as bettype, @minv3positiontaking_20 as minpositiontaking,  0 as minlivepositiontaking

                union all select     @custid as custid,  5 as sporttype, 1 as bettype, @minv5positiontaking_1 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  5 as sporttype, 2 as bettype, @minv5positiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  5 as sporttype, 3 as bettype, @minv5positiontaking_3 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  5 as sporttype, 20 as bettype, @minv5positiontaking_20 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  5 as sporttype, 9999 as bettype, @minv5positiontaking_9999 as minpositiontaking,  0 as minlivepositiontaking

                union all select     @custid as custid,  8 as sporttype, 1 as bettype, @minv8positiontaking_1 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  8 as sporttype, 3 as bettype, @minv8positiontaking_3 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  8 as sporttype, 20 as bettype, @minv8positiontaking_20 as minpositiontaking,  0 as minlivepositiontaking

                union all select     @custid as custid,  10 as sporttype, 1 as bettype, @minv10positiontaking_1 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  10 as sporttype, 2 as bettype, @minv10positiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  10 as sporttype, 3 as bettype, @minv10positiontaking_3 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  10 as sporttype, 20 as bettype, @minv10positiontaking_20 as minpositiontaking,  0 as minlivepositiontaking

                union all select     @custid as custid,  11 as sporttype, 1 as bettype, @minv11positiontaking_1 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  11 as sporttype, 20 as bettype, @minv11positiontaking_20 as minpositiontaking,  0 as minlivepositiontaking

                union all select     @custid as custid,  99 as sporttype, 1 as bettype, @minv99positiontaking_1 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  99 as sporttype, 2 as bettype, @minv99positiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  99 as sporttype, 3 as bettype, @minv99positiontaking_3 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  99 as sporttype, 9 as bettype, @minv99positiontaking_9 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  99 as sporttype, 20 as bettype, @minv99positiontaking_20 as minpositiontaking,  0 as minlivepositiontaking
                union all select     @custid as custid,  99 as sporttype, 9999 as bettype, @minv99positiontaking_9999 as minpositiontaking,  0 as minlivepositiontaking
           
                
            ) as b on custoverride.custid = b.custid and custoverride.sporttype=b.sporttype and custoverride.bettype = b.bettype
    where custoverride.custid = @custid        
    
END

if @UpdateMaxPos = 1
BEGIN

    Update custoverride with (ROWLOCK, UPDLOCK) set maxpositiontaking = b.maxpositiontaking, maxlivepositiontaking = b.maxlivepositiontaking
    from custoverride inner join     
            (
                select         @custid as custid,  1 as sporttype, 1 as bettype, @maxpositiontaking_1 as maxpositiontaking,  @maxlivepositiontaking_1 as maxlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 2 as bettype, @maxpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 3 as bettype, @maxpositiontaking_3 as maxpositiontaking,  @maxlivepositiontaking_3 as maxlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 4 as bettype, @maxpositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 5 as bettype, @maxpositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 6 as bettype, @maxpositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 7 as bettype, @maxpositiontaking_7 as maxpositiontaking,  @maxlivepositiontaking_7 as maxlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 8 as bettype, @maxpositiontaking_8 as maxpositiontaking,  @maxlivepositiontaking_8 as maxlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 9 as bettype, @maxpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  1 as sporttype, 10 as bettype, @maxpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                -- Outright PT for sport
                union all select     @custid as custid,  2 as sporttype, 10 as bettype, @maxv2positiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  3 as sporttype, 10 as bettype, @maxv3positiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  5 as sporttype, 10 as bettype, @maxv5positiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  8 as sporttype, 10 as bettype, @maxv8positiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  10 as sporttype, 10 as bettype, @maxv10positiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  11 as sporttype, 10 as bettype, @maxv11positiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  99 as sporttype, 10 as bettype, @maxv99positiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                
                union all select     @custid as custid,  1 as sporttype, 9999 as bettype, @maxpositiontaking_9999 as maxpositiontaking,  0 as maxlivepositiontaking
                
                union all select     @custid as custid,  2 as sporttype, 1 as bettype, @maxv2positiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  2 as sporttype, 2 as bettype, @maxv2positiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  2 as sporttype, 3 as bettype, @maxv2positiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  2 as sporttype, 7 as bettype, @maxv2positiontaking_7 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  2 as sporttype, 8 as bettype, @maxv2positiontaking_8 as maxpositiontaking,  0 as maxlivepositiontaking
                --union all select     @custid as custid,  2 as sporttype, 9 as bettype, @maxv2positiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  2 as sporttype, 20 as bettype, @maxv2positiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  2 as sporttype, 9999 as bettype, @maxv2positiontaking_9999 as maxpositiontaking,  0 as maxlivepositiontaking
                
                union all select     @custid as custid,  3 as sporttype, 1 as bettype, @maxv3positiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  3 as sporttype, 2 as bettype, @maxv3positiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  3 as sporttype, 3 as bettype, @maxv3positiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  3 as sporttype, 20 as bettype, @maxv3positiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     @custid as custid,  5 as sporttype, 1 as bettype, @maxv5positiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  5 as sporttype, 2 as bettype, @maxv5positiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  5 as sporttype, 3 as bettype, @maxv5positiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  5 as sporttype, 20 as bettype, @maxv5positiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  5 as sporttype, 9999 as bettype, @maxv5positiontaking_9999 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     @custid as custid,  8 as sporttype, 1 as bettype, @maxv8positiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  8 as sporttype, 3 as bettype, @maxv8positiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  8 as sporttype, 20 as bettype, @maxv8positiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     @custid as custid,  10 as sporttype, 1 as bettype, @maxv10positiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  10 as sporttype, 2 as bettype, @maxv10positiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  10 as sporttype, 3 as bettype, @maxv10positiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  10 as sporttype, 20 as bettype, @maxv10positiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     @custid as custid,  11 as sporttype, 1 as bettype, @maxv11positiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  11 as sporttype, 20 as bettype, @maxv11positiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     @custid as custid,  99 as sporttype, 1 as bettype, @maxv99positiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  99 as sporttype, 2 as bettype, @maxv99positiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  99 as sporttype, 3 as bettype, @maxv99positiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     @custid as custid,  99 as sporttype, 9 as bettype, @maxv99positiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking            
                union all select     @custid as custid,  99 as sporttype, 20 as bettype, @maxv99positiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking            
                union all select     @custid as custid,  99 as sporttype, 9999 as bettype, @maxv99positiontaking_9999 as maxpositiontaking,  0 as maxlivepositiontaking
                        
            ) as b on custoverride.custid = b.custid and custoverride.sporttype=b.sporttype and custoverride.bettype = b.bettype
    where custoverride.custid = @custid   
END

if @roleid = 2
BEGIN
                EXEC dbo.Acc_CustSetting_04 @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend, @roleid = 2
    -- The minimum position taking value of agent was modified by agent's upline
    EXEC dbo.Age_MessageNoticeUpd_Wrapper @custID = @custid, @userID = @UserID
END
else if @roleid = 3
BEGIN
                EXEC dbo.Acc_CustSetting_04 @mrecommend = @mrecommend, @srecommend = @srecommend, @roleid = 3
END
else if @roleid= 4 and @WriteLog = 1 and @UpdateMinPos = 1
BEGIN
                EXEC dbo.Acc_CustSetting_04 @srecommend = @srecommend, @roleid = 4
END
else if @roleid= 4 and @WriteLog = 1 and @UpdateMaxPos = 1
BEGIN
    EXEC dbo.Acc_CustSetting_01 @srecommend = @srecommend
END


if @WriteLog = 1
BEGIN
    Declare @LogSPData varchar(5000)
    Declare @TrackingValue2 varchar(5000)
    
    Select @LogSPData = '<Acc_CustOverrideUpd><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'CheckPermission="'+ coalesce(cast(@CheckPermission as varchar(50)),space(1)) + '" ' +
    'UpdMinPos="'+ coalesce(cast(@UpdateMinPos as varchar(50)),space(1)) + '" ' +
    'UpdMaxPos="'+ coalesce(cast(@UpdateMaxPos as varchar(50)),space(1)) + '" ' +
    'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
    'WriteLog="'+ coalesce(cast(@WriteLog as varchar(50)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +
    
    '<MinMaxPT minpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@minpositiontaking_1),space(1)) + '" ' +
    'minpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@minpositiontaking_2),space(1)) + '" ' +
    'minpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@minpositiontaking_3),space(1)) + '" ' +
    'minpt_4="'+ coalesce(dbo.f_FomatNumericToChar(@minpositiontaking_4),space(1)) + '" ' +
    'minpt_5="'+ coalesce(dbo.f_FomatNumericToChar(@minpositiontaking_5),space(1)) + '" ' +
    'minpt_6="'+ coalesce(dbo.f_FomatNumericToChar(@minpositiontaking_6),space(1)) + '" ' +
    'minpt_7="'+ coalesce(dbo.f_FomatNumericToChar(@minpositiontaking_7),space(1)) + '" ' +
    'minpt_8="'+ coalesce(dbo.f_FomatNumericToChar(@minpositiontaking_8),space(1)) + '" ' +
    'minpt_9="'+ coalesce(dbo.f_FomatNumericToChar(@minpositiontaking_9),space(1)) + '" ' +
    'minpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@minpositiontaking_10),space(1)) + '" ' +
    --outright PT for sports
    'minv2pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@minv2positiontaking_10),space(1)) + '" ' +
    'minv3pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@minv3positiontaking_10),space(1)) + '" ' +
    'minv5pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@minv5positiontaking_10),space(1)) + '" ' +
    'minv8pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@minv8positiontaking_10),space(1)) + '" ' +
    'minv10pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@minv10positiontaking_10),space(1)) + '" ' +
    'minv11pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@minv11positiontaking_10),space(1)) + '" ' +
    'minv99pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@minv99positiontaking_10),space(1)) + '" ' +
    
    'minpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@minpositiontaking_9999),space(1)) + '" ' +
    'minlivept_1="'+ coalesce(dbo.f_FomatNumericToChar(@minlivepositiontaking_1),space(1)) + '" ' +
    'minlivept_3="'+ coalesce(dbo.f_FomatNumericToChar(@minlivepositiontaking_3),space(1)) + '" ' +
    'minlivept_7="'+ coalesce(dbo.f_FomatNumericToChar(@minlivepositiontaking_7),space(1)) + '" ' +
    'minlivept_8="'+ coalesce(dbo.f_FomatNumericToChar(@minlivepositiontaking_8),space(1)) + '" ' +
    'maxpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@maxpositiontaking_1),space(1)) + '" ' +
    'maxpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@maxpositiontaking_2),space(1)) + '" ' +
    'maxpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@maxpositiontaking_3),space(1)) + '" ' +
    'maxpt_4="'+ coalesce(dbo.f_FomatNumericToChar(@maxpositiontaking_4),space(1)) + '" ' +
    'maxpt_5="'+ coalesce(dbo.f_FomatNumericToChar(@maxpositiontaking_5),space(1)) + '" ' +
    'maxpt_6="'+ coalesce(dbo.f_FomatNumericToChar(@maxpositiontaking_6),space(1)) + '" ' +
    'maxpt_7="'+ coalesce(dbo.f_FomatNumericToChar(@maxpositiontaking_7),space(1)) + '" ' +
    'maxpt_8="'+ coalesce(dbo.f_FomatNumericToChar(@maxpositiontaking_8),space(1)) + '" ' +
    'maxpt_9="'+ coalesce(dbo.f_FomatNumericToChar(@maxpositiontaking_9),space(1)) + '" ' +
    'maxpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@maxpositiontaking_10),space(1)) + '" ' +
    
    -- Outright PT for sports
    'maxv2pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@maxv2positiontaking_10),space(1)) + '" ' +
    'maxv3pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@maxv3positiontaking_10),space(1)) + '" ' +
    'maxv5pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@maxv5positiontaking_10),space(1)) + '" ' +
    'maxv8pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@maxv8positiontaking_10),space(1)) + '" ' +
    'maxv10pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@maxv10positiontaking_10),space(1)) + '" ' +
    'maxv11pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@maxv11positiontaking_10),space(1)) + '" ' +
    'maxv99pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@maxv99positiontaking_10),space(1)) + '" ' +
    
    'maxpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@maxpositiontaking_9999),space(1)) + '" ' +
    'maxlivept_1="'+ coalesce(dbo.f_FomatNumericToChar(@maxlivepositiontaking_1),space(1)) + '" ' +
    'maxlivept_3="'+ coalesce(dbo.f_FomatNumericToChar(@maxlivepositiontaking_3),space(1)) + '" ' +
    'maxlivept_7="'+ coalesce(dbo.f_FomatNumericToChar(@maxlivepositiontaking_7),space(1)) + '" ' +
    'maxlivept_8="'+ coalesce(dbo.f_FomatNumericToChar(@maxlivepositiontaking_8),space(1)) + '" ' +
    
    'minv2pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@minv2positiontaking_1),space(1)) + '" ' +
    'minv2pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@minv2positiontaking_2),space(1)) + '" ' +
    'minv2pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@minv2positiontaking_3),space(1)) + '" ' +
    'minv2pt_7="'+ coalesce(dbo.f_FomatNumericToChar(@minv2positiontaking_7),space(1)) + '" ' +
    'minv2pt_8="'+ coalesce(dbo.f_FomatNumericToChar(@minv2positiontaking_8),space(1)) + '" ' +
    --'minv2pt_9="'+ coalesce(dbo.f_FomatNumericToChar(@minv2positiontaking_9),space(1)) + '" ' +
    'minv2pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@minv2positiontaking_20),space(1)) + '" ' +
    'minv2pt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@minv2positiontaking_9999),space(1)) + '" ' +
    
    'maxv2pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@maxv2positiontaking_1),space(1)) + '" ' +
    'maxv2pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@maxv2positiontaking_2),space(1)) + '" ' +
    'maxv2pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@maxv2positiontaking_3),space(1)) + '" ' +
    'maxv2pt_7="'+ coalesce(dbo.f_FomatNumericToChar(@maxv2positiontaking_7),space(1)) + '" ' +
    'maxv2pt_8="'+ coalesce(dbo.f_FomatNumericToChar(@maxv2positiontaking_8),space(1)) + '" ' +
    --'maxv2pt_9="'+ coalesce(dbo.f_FomatNumericToChar(@maxv2positiontaking_9),space(1)) + '" ' +
    'maxv2pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@maxv2positiontaking_20),space(1)) + '" ' +
    'maxv2pt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@maxv2positiontaking_9999),space(1)) + '" ' +
    
    'minv3pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@minv3positiontaking_1),space(1)) + '" ' +
    'minv3pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@minv3positiontaking_2),space(1)) + '" ' +
    'minv3pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@minv3positiontaking_3),space(1)) + '" ' +
    'minv3pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@minv3positiontaking_20),space(1)) + '" ' +    
    'maxv3pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@maxv3positiontaking_1),space(1)) + '" ' +
    'maxv3pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@maxv3positiontaking_2),space(1)) + '" ' +
    'maxv3pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@maxv3positiontaking_3),space(1)) + '" ' +
    'maxv3pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@maxv3positiontaking_20),space(1)) + '" ' +

    'minv5pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@minv5positiontaking_1),space(1)) + '" ' +
    'minv5pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@minv5positiontaking_2),space(1)) + '" ' +
    'minv5pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@minv5positiontaking_3),space(1)) + '" ' +
    'minv5pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@minv5positiontaking_20),space(1)) + '" ' +
    'minv5pt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@minv5positiontaking_9999),space(1)) + '" ' +
    'maxv5pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@maxv5positiontaking_1),space(1)) + '" ' +
    'maxv5pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@maxv5positiontaking_2),space(1)) + '" ' +
    'maxv5pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@maxv5positiontaking_3),space(1)) + '" ' +
    'maxv5pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@maxv5positiontaking_20),space(1)) + '" ' +
    'maxv5pt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@maxv5positiontaking_9999),space(1)) + '" ' +

    'minv8pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@minv8positiontaking_1),space(1)) + '" ' +
    'minv8pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@minv8positiontaking_3),space(1)) + '" ' +
    'minv8pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@minv8positiontaking_20),space(1)) + '" ' +
    'maxv8pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@maxv8positiontaking_1),space(1)) + '" ' +
    'maxv8pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@maxv8positiontaking_3),space(1)) + '" ' +
    'maxv8pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@maxv8positiontaking_20),space(1)) + '" ' +

    'minv10pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@minv10positiontaking_1),space(1)) + '" ' +
    'minv10pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@minv10positiontaking_2),space(1)) + '" ' +
    'minv10pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@minv10positiontaking_3),space(1)) + '" ' +
    'minv10pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@minv10positiontaking_20),space(1)) + '" ' +
    'maxv10pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@maxv10positiontaking_1),space(1)) + '" ' +
    'maxv10pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@maxv10positiontaking_2),space(1)) + '" ' +
    'maxv10pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@maxv10positiontaking_3),space(1)) + '" ' +
    'maxv10pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@maxv10positiontaking_20),space(1)) + '" ' +

    'minv11pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@minv11positiontaking_1),space(1)) + '" ' +
    'minv11pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@minv11positiontaking_20),space(1)) + '" ' +
    'maxv11pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@maxv11positiontaking_1),space(1)) + '" ' +
    'maxv11pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@maxv11positiontaking_20),space(1)) + '" ' +
    
    'minv99pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@minv99positiontaking_1),space(1)) + '" ' +
    'minv99pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@minv99positiontaking_2),space(1)) + '" ' +
    'minv99pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@minv99positiontaking_3),space(1)) + '" ' +
    'minv99pt_9="'+ coalesce(dbo.f_FomatNumericToChar(@minv99positiontaking_9),space(1)) + '" ' +
    'minv99pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@minv99positiontaking_20),space(1)) + '" ' +
	'minv99pt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@minv99positiontaking_9999),space(1)) + '" ' +
    'maxv99pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@maxv99positiontaking_1),space(1)) + '" ' +
    'maxv99pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@maxv99positiontaking_2),space(1)) + '" ' +
    'maxv99pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@maxv99positiontaking_3),space(1)) + '" ' +
    'maxv99pt_9="'+ coalesce(dbo.f_FomatNumericToChar(@maxv99positiontaking_9),space(1)) + '" ' +
    'maxv99pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@maxv99positiontaking_20),space(1)) + '" ' +
    'maxv99pt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@maxv99positiontaking_9999),space(1)) + '" /></Acc_CustOverrideUpd>'
    
    SELECT @TrackingValue2 = '<Acc_CustOverrideUpd><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'CheckPermission="'+ coalesce(cast(@CheckPermission as varchar(50)),space(1)) + '" ' +
    'UpdMinPos="'+ coalesce(cast(@UpdateMinPos as varchar(50)),space(1)) + '" ' +
    'UpdMaxPos="'+ coalesce(cast(@UpdateMaxPos as varchar(50)),space(1)) + '" ' +
    'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
    'WriteLog="'+ coalesce(cast(@WriteLog as varchar(50)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +
    
    '<MinMaxPT minpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_minpositiontaking_1),space(1)) + '" ' +
    'minpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@old_minpositiontaking_2),space(1)) + '" ' +
    'minpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_minpositiontaking_3),space(1)) + '" ' +
    'minpt_4="'+ coalesce(dbo.f_FomatNumericToChar(@old_minpositiontaking_4),space(1)) + '" ' +
    'minpt_5="'+ coalesce(dbo.f_FomatNumericToChar(@old_minpositiontaking_5),space(1)) + '" ' +
    'minpt_6="'+ coalesce(dbo.f_FomatNumericToChar(@old_minpositiontaking_6),space(1)) + '" ' +
    'minpt_7="'+ coalesce(dbo.f_FomatNumericToChar(@old_minpositiontaking_7),space(1)) + '" ' +
    'minpt_8="'+ coalesce(dbo.f_FomatNumericToChar(@old_minpositiontaking_8),space(1)) + '" ' +
    'minpt_9="'+ coalesce(dbo.f_FomatNumericToChar(@old_minpositiontaking_9),space(1)) + '" ' +
    'minpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_minpositiontaking_10),space(1)) + '" ' +
    
    -- Outrgiht PT
    'minv2pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv2positiontaking_10),space(1)) + '" ' +
    'minv3pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv3positiontaking_10),space(1)) + '" ' +
    'minv5pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv5positiontaking_10),space(1)) + '" ' +
    'minv8pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv8positiontaking_10),space(1)) + '" ' +
    'minv10pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv10positiontaking_10),space(1)) + '" ' +
    'minv11pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv11positiontaking_10),space(1)) + '" ' +
    'minv99pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv99positiontaking_10),space(1)) + '" ' +
    
    
    'minpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@old_minpositiontaking_9999),space(1)) + '" ' +
    'minlivept_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_minlivepositiontaking_1),space(1)) + '" ' +
    'minlivept_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_minlivepositiontaking_3),space(1)) + '" ' +
    'minlivept_7="'+ coalesce(dbo.f_FomatNumericToChar(@old_minlivepositiontaking_7),space(1)) + '" ' +
    'minlivept_8="'+ coalesce(dbo.f_FomatNumericToChar(@old_minlivepositiontaking_8),space(1)) + '" ' +
    'maxpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxpositiontaking_1),space(1)) + '" ' +
    'maxpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxpositiontaking_2),space(1)) + '" ' +
    'maxpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxpositiontaking_3),space(1)) + '" ' +
    'maxpt_4="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxpositiontaking_4),space(1)) + '" ' +
    'maxpt_5="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxpositiontaking_5),space(1)) + '" ' +
    'maxpt_6="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxpositiontaking_6),space(1)) + '" ' +
    'maxpt_7="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxpositiontaking_7),space(1)) + '" ' +
    'maxpt_8="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxpositiontaking_8),space(1)) + '" ' +
    'maxpt_9="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxpositiontaking_9),space(1)) + '" ' +
    'maxpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxpositiontaking_10),space(1)) + '" ' +
    
    -- Outright PT for sports
    'maxv2pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv2positiontaking_10),space(1)) + '" ' +
    'maxv3pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv3positiontaking_10),space(1)) + '" ' +
    'maxv5pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv5positiontaking_10),space(1)) + '" ' +
    'maxv8pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv8positiontaking_10),space(1)) + '" ' +
    'maxv10pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv10positiontaking_10),space(1)) + '" ' +
    'maxv11pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv11positiontaking_10),space(1)) + '" ' +
    'maxv99pt_10="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv99positiontaking_10),space(1)) + '" ' +
    
    'maxpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxpositiontaking_9999),space(1)) + '" ' +
    'maxlivept_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxlivepositiontaking_1),space(1)) + '" ' +
    'maxlivept_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxlivepositiontaking_3),space(1)) + '" ' +
    'maxlivept_7="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxlivepositiontaking_7),space(1)) + '" ' +
    'maxlivept_8="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxlivepositiontaking_8),space(1)) + '" ' +
    
    'minv2pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv2positiontaking_1),space(1)) + '" ' +
    'minv2pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv2positiontaking_2),space(1)) + '" ' +
    'minv2pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv2positiontaking_3),space(1)) + '" ' +
    'minv2pt_7="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv2positiontaking_7),space(1)) + '" ' +
    'minv2pt_8="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv2positiontaking_8),space(1)) + '" ' +    
    'minv2pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv2positiontaking_20),space(1)) + '" ' +
    'minv2pt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv2positiontaking_9999),space(1)) + '" ' +
    
    'maxv2pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv2positiontaking_1),space(1)) + '" ' +
    'maxv2pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv2positiontaking_2),space(1)) + '" ' +
    'maxv2pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv2positiontaking_3),space(1)) + '" ' +
    'maxv2pt_7="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv2positiontaking_7),space(1)) + '" ' +
    'maxv2pt_8="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv2positiontaking_8),space(1)) + '" ' +    
    'maxv2pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv2positiontaking_20),space(1)) + '" ' +
    'maxv2pt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv2positiontaking_9999),space(1)) + '" ' +
    
    'minv3pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv3positiontaking_1),space(1)) + '" ' +
    'minv3pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv3positiontaking_2),space(1)) + '" ' +
    'minv3pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv3positiontaking_3),space(1)) + '" ' +
    'minv3pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv3positiontaking_20),space(1)) + '" ' +    
    'maxv3pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv3positiontaking_1),space(1)) + '" ' +
    'maxv3pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv3positiontaking_2),space(1)) + '" ' +
    'maxv3pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv3positiontaking_3),space(1)) + '" ' +
    'maxv3pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv3positiontaking_20),space(1)) + '" ' +

    'minv5pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv5positiontaking_1),space(1)) + '" ' +
    'minv5pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv5positiontaking_2),space(1)) + '" ' +
    'minv5pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv5positiontaking_3),space(1)) + '" ' +
    'minv5pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv5positiontaking_20),space(1)) + '" ' +
    'minv5pt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv5positiontaking_9999),space(1)) + '" ' +
    'maxv5pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv5positiontaking_1),space(1)) + '" ' +
    'maxv5pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv5positiontaking_2),space(1)) + '" ' +
    'maxv5pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv5positiontaking_3),space(1)) + '" ' +
    'maxv5pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv5positiontaking_20),space(1)) + '" ' +
    'maxv5pt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv5positiontaking_9999),space(1)) + '" ' +

    'minv8pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv8positiontaking_1),space(1)) + '" ' +
    'minv8pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv8positiontaking_3),space(1)) + '" ' +
    'minv8pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv8positiontaking_20),space(1)) + '" ' +
    'maxv8pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv8positiontaking_1),space(1)) + '" ' +
    'maxv8pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv8positiontaking_3),space(1)) + '" ' +
    'maxv8pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv8positiontaking_20),space(1)) + '" ' +

    'minv10pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv10positiontaking_1),space(1)) + '" ' +
    'minv10pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv10positiontaking_2),space(1)) + '" ' +
    'minv10pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv10positiontaking_3),space(1)) + '" ' +
    'minv10pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv10positiontaking_20),space(1)) + '" ' +
    'maxv10pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv10positiontaking_1),space(1)) + '" ' +
    'maxv10pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv10positiontaking_2),space(1)) + '" ' +
    'maxv10pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv10positiontaking_3),space(1)) + '" ' +
    'maxv10pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv10positiontaking_20),space(1)) + '" ' +

    'minv11pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv11positiontaking_1),space(1)) + '" ' +
    'minv11pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv11positiontaking_20),space(1)) + '" ' +
    'maxv11pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv11positiontaking_1),space(1)) + '" ' +
    'maxv11pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv11positiontaking_20),space(1)) + '" ' +
    
    'minv99pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv99positiontaking_1),space(1)) + '" ' +
    'minv99pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv99positiontaking_2),space(1)) + '" ' +
    'minv99pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv99positiontaking_3),space(1)) + '" ' +
    'minv99pt_9="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv99positiontaking_9),space(1)) + '" ' +
    'minv99pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv99positiontaking_20),space(1)) + '" ' +
	'minv99pt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@old_minv99positiontaking_9999),space(1)) + '" ' +
    'maxv99pt_1="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv99positiontaking_1),space(1)) + '" ' +
    'maxv99pt_2="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv99positiontaking_2),space(1)) + '" ' +
    'maxv99pt_3="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv99positiontaking_3),space(1)) + '" ' +
    'maxv99pt_9="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv99positiontaking_9),space(1)) + '" ' +
    'maxv99pt_20="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv99positiontaking_20),space(1)) + '" ' +
	'maxv99pt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@old_maxv99positiontaking_9999),space(1)) + '" /></Acc_CustOverrideUpd>'
        
    set @endRun = getdate()
    set @duration  = datediff (millisecond,@startRun,@endRun)
        
	 EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 500,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValue2,
        @duration = @duration    
END

GO

