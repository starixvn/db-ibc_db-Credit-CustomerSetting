USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdSuper_Commission]    Script Date: 06/10/2015 15:21:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuper_Commission    Script Date: 8/28/2014 2:05:02 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuper_Commission    Script Date: 8/21/2014 3:12:18 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuper_Commission    Script Date: 8/21/2014 2:58:05 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuper_Commission    Script Date: 12/5/2013 5:35:52 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuper_Commission]
    @custid INT,-- superid
    
    @groupa DECIMAL(9,8),
    @groupb DECIMAL(9,8),
    @groupc DECIMAL(9,8),
    @groupd DECIMAL(9,8),
    @discountcs DECIMAL(9,8),    
    @discount1x2 DECIMAL(9,8)=0,
    @discountHRFixedOdds DECIMAL(9,8)=0,
    @discountnumber DECIMAL(9,8)=0,
    @updatecomm_old BIT =1,
    @IsMyanmarOdds BIT = 0,
    @discountMyanmarOdds DECIMAL(9,8)=0,
    @discountMyanmarOdds_old DECIMAL(9,8)=0,
    @UserID INT = 0,    
    @Language VARCHAR(2) = 'E',
    @IP VARCHAR(15)='',
    @ErrCode INT = 0 OUTPUT,
    @ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
BEGIN
--@Source Control
/*
Created: 20080514@Thien
Task : Update Super's Commission
DB: DBTXN/bodb02
Original:[Acc_CustomerUpdSuper_Commission]

Revisions:
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090514@PhuongDao: Add 1x2 Commission
    - 20090917@Phuc: write log into DBLOG.
    - 20100112@Phuc: hardcode not to update commission for member under agent 8RM.
    - 20100112@Kiwi: amend to write log in xml format.
    - 20100901@Henry: Update commission for Number Game
    - 20101019@Henry: Record execution time
    - 20110606@Amy: Write log Old values
    - 20110930@Johnson: Add more group under Won currency
    - 20120412@Hurri: hardcode not to update commission for member under agent BARM.
    - 20120522@Sophia: Remove hardcode not to update commission for member under agent BARM.
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
    - 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
    - 20131029@Kathy: Apply exec rep to update commission [Redmine:#3244]
    - 20150609@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB) [Redmine:#36216]
    - 20150904@Helen: commission setting for MO [Redmine #41470]
     
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

	declare @err1 int, @err2 int
			,@RoleId int

		Select
			@RoleId = roleid
		from custInfo with(NOLOCK)
		where custid = @custid

	--Check Allowed downlines    
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
	        
	declare @Old_groupa DECIMAL(9,8),
		@Old_groupb DECIMAL(9,8),
		@Old_groupc DECIMAL(9,8),
		@Old_groupd DECIMAL(9,8),
		@Old_discountcs DECIMAL(9,8),    
		@Old_discount1x2 DECIMAL(9,8),
		@Old_discountHRFixedOdds DECIMAL(9,8),
		@Old_discountnumber DECIMAL(9,8),
		@Old_discountMyanmarOdds DECIMAL(9,8)

	IF 
		@discountcs<0 OR @discountcs>0.2
			OR @discount1x2<0 OR @discount1x2>0.2
			OR @discountHRFixedOdds<0 OR @discountHRFixedOdds>0.2
			OR @discountnumber<0 OR @discountnumber>0.2
			OR @groupa<0 OR @groupa>0.2
			OR @groupb<0 OR @groupb>0.2
			OR @groupc<0 OR @groupc>0.2
			OR @groupd<0 OR @groupd>0.2
			OR @discountMyanmarOdds < 0 OR @discountMyanmarOdds > 0.01
	BEGIN    
		SELECT @ErrMsg =     CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language)
					END, @ErrCode = 101
		RETURN
	END

	
	--Check modify group(other) or financial
	IF @updatecomm_old = 1
	BEGIN

		SELECT         
			@Old_groupa = groupa, 
			@Old_groupb = groupb, 
			@Old_groupc = groupc, 
			@Old_groupd = groupd 
		FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=1
	    
		SELECT @Old_discountcs = sdiscount FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 1 AND bettype = 4
		SELECT @Old_discount1x2 = sdiscount    FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 1 AND bettype = 5
		SELECT @Old_discountHRFixedOdds = sdiscount    FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 154 AND bettype = 20
		SELECT @Old_discountnumber = sdiscount FROM custsetting3rd AS cs3 WITH (NOLOCK) WHERE custid = @custid AND sporttype = 161 AND bettype = 81
	    
		-- Apply exec rep:
	        
		exec Acc_CustSetting_06
			@CustId = @custid,
			@RoleId = @RoleId,
			@groupa = @groupa,
			@groupb = @groupb,
			@groupc = @groupc,
			@groupd = @groupd,
			@discountcs = @discountcs,
			@discountHRFixedOdds = @discountHRFixedOdds,   
			@discountMyanmarOdds = @discountMyanmarOdds,   
			@IsMyanmarOdds = @IsMyanmarOdds,  
			@discount1x2 = @discount1x2
		
		exec Acc_CustSetting3rd_06
			@CustId = @custid,
			@RoleId = @RoleId,
			@discountNumber = @discountnumber,
			@mode = 'NumberGame'    
	END            
	    
	--204    Acc_CustomerUpdSuper_Commission    Update Sportsbook Commission for super
	Declare @LogSPData varchar(8000)
	Declare @TrackingValue2 varchar(8000)
	Select @LogSPData = '<Acc_CustomerUpdSuper_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'groupa="'+ coalesce(cast(@groupa as varchar(50)),space(1)) + '" ' 
	IF @IsMyanmarOdds = 0 
		SET @LogSPData = @LogSPData +
	'groupb="'+ coalesce(cast(@groupb as varchar(50)),space(1)) + '" ' +
	'groupc="'+ coalesce(cast(@groupc as varchar(50)),space(1)) + '" ' +
	'groupd="'+ coalesce(cast(@groupd as varchar(50)),space(1)) + '" ' 
	SET @LogSPData = @LogSPData +
	'discountcs="'+ coalesce(cast(@discountcs as varchar(50)),space(1)) + '" ' +
	'discount1x2="'+ coalesce(cast(@discount1x2 as varchar(50)),space(1)) + '" ' +
	'discountHRFixedOdds="'+ coalesce(cast(@discountHRFixedOdds as varchar(50)),space(1)) + '" ' +
	'discountnumber="'+ coalesce(cast(@discountnumber as varchar(50)),space(1)) + '" ' 
	
	IF @IsMyanmarOdds = 1
		SET @LogSPData = @LogSPData + 'discountMyanmarOdds="'+ coalesce(cast(@discountMyanmarOdds as varchar(50)),space(1)) + '" ' 
	
	SET @LogSPData = @LogSPData + 
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

	Select @TrackingValue2 = '<Acc_CustomerUpdSuper_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'groupa="'+ coalesce(cast(@Old_groupa as varchar(50)),space(1)) + '" ' 
	IF @IsMyanmarOdds = 0
		SET @TrackingValue2 = @TrackingValue2 +
	'groupb="'+ coalesce(cast(@Old_groupb as varchar(50)),space(1)) + '" ' +
	'groupc="'+ coalesce(cast(@Old_groupc as varchar(50)),space(1)) + '" ' +
	'groupd="'+ coalesce(cast(@Old_groupd as varchar(50)),space(1)) + '" ' 
	SET @TrackingValue2 = @TrackingValue2 +
	'discountcs="'+ coalesce(cast(@Old_discountcs as varchar(50)),space(1)) + '" ' +
	'discount1x2="'+ coalesce(cast(@Old_discount1x2 as varchar(50)),space(1)) + '" ' +
	'discountHRFixedOdds="'+ coalesce(cast(@Old_discountHRFixedOdds as varchar(50)),space(1)) + '" ' +
	'discountnumber="'+ coalesce(cast(@Old_discountnumber as varchar(50)),space(1)) + '" ' 
	
	IF @IsMyanmarOdds = 1
		SET @TrackingValue2 = @TrackingValue2 + 'discountMyanmarOdds="'+ coalesce(cast(@discountMyanmarOdds_old as varchar(50)),space(1)) + '" ' 

	SET @TrackingValue2 = @TrackingValue2 +		
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'


	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	BEGIN TRY
		--Log customer info 
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 204,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
	END TRY
	BEGIN CATCH
		Select @LogSPData = '<Acc_CustomerUpdSuper_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'groupa="'+ coalesce(cast(@groupa as varchar(50)),space(1)) + '" ' 
		IF @IsMyanmarOdds = 0
			SET @LogSPData = @LogSPData +
		'groupb="'+ coalesce(cast(@groupb as varchar(50)),space(1)) + '" ' +
		'groupc="'+ coalesce(cast(@groupc as varchar(50)),space(1)) + '" ' +
		'groupd="'+ coalesce(cast(@groupd as varchar(50)),space(1)) + '" ' 
		SET @LogSPData = @LogSPData +
		'discountcs="'+ coalesce(cast(@discountcs as varchar(50)),space(1)) + '" ' +
		'discount1x2="'+ coalesce(cast(@discount1x2 as varchar(50)),space(1)) + '" ' +
		'discountHRFixedOdds="'+ coalesce(cast(@discountHRFixedOdds as varchar(50)),space(1)) + '" ' +
		'discountnumber="'+ coalesce(cast(@discountnumber as varchar(50)),space(1)) + '" ' 
		
		IF @IsMyanmarOdds = 1
			SET @LogSPData = @LogSPData + 'discountMyanmarOdds="'+ coalesce(cast(@discountMyanmarOdds as varchar(50)),space(1)) + '" ' 
		
		SET @LogSPData = @LogSPData +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1))+ '" />'

		Select @TrackingValue2 = '<Acc_CustomerUpdSuper_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'groupa="'+ coalesce(cast(@Old_groupa as varchar(50)),space(1)) + '" ' 
		IF @IsMyanmarOdds = 0
			SET @TrackingValue2 = @TrackingValue2 +
		'groupb="'+ coalesce(cast(@Old_groupb as varchar(50)),space(1)) + '" ' +
		'groupc="'+ coalesce(cast(@Old_groupc as varchar(50)),space(1)) + '" ' +
		'groupd="'+ coalesce(cast(@Old_groupd as varchar(50)),space(1)) + '" ' 
		SET @TrackingValue2 = @TrackingValue2 +
		'discountcs="'+ coalesce(cast(@Old_discountcs as varchar(50)),space(1)) + '" ' +
		'discount1x2="'+ coalesce(cast(@Old_discount1x2 as varchar(50)),space(1)) + '" ' +
		'discountHRFixedOdds="'+ coalesce(cast(@Old_discountHRFixedOdds as varchar(50)),space(1)) + '" ' +
		'discountnumber="'+ coalesce(cast(@Old_discountnumber as varchar(50)),space(1)) + '" ' 
		
		IF @IsMyanmarOdds = 1 
			SET @TrackingValue2 = @TrackingValue2 +	'discountMyanmarOdds="'+ coalesce(cast(@discountMyanmarOdds_old as varchar(50)),space(1)) + '" ' 
		
		SET @TrackingValue2 = @TrackingValue2 +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1))+ '" />'

		--Log customer info 
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 204,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration    
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuper_Commission] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuper_Commission] TO [vnteam] AS [dbo]
