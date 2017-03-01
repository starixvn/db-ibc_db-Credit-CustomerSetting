alter PROCEDURE [dbo].[Acc_CustomerUpdMaster_Commission]
    @custid INT,-- masterId
    
    @groupa DECIMAL(9,8),
    @groupb DECIMAL(9,8),
    @groupc DECIMAL(9,8),
    @groupd DECIMAL(9,8),
    @discountcs DECIMAL(9,8),
    @discount1x2 DECIMAL(9,8)=0,
    @discountHRFixedOdds DECIMAL(9,8)=0,
    @IsMyanmarOdds BIT = 0,
    @discountMyanmarOdds DECIMAL(9,8)=0,
    @discountMyanmarOdds_old DECIMAL(9,8)=0,
    
    --- number game commission
    @discountnumber decimal(9,8) = 0,

    @updatecomm_old BIT = 1,
    @SubAccID INT = 0, --Sub-AccountID
    
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
Task : Update Master's Commission
DB: DBTXN/bodb02
Original: [Acc_CustomerUpdMaster_Commission]

Revisions:
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090514@PhuongDao: Add 1x2 Commission
    - 20090723@Phuc: Write log subaccname instead of subaccid.
    - 20090917@Phuc: write log into DBLOG.
    - 20100112@Phuc: hardcode not to update commission for member under agent 8RM.
    - 20100112@Kiwi: amend to write log in xml format.
    - 20100903@Lukas: Add number game commission
    - 20101019@Henry: Record execution time
    - 20110606@Amy: Write log Old values
    - 20110729@Lukas: Add three new number game's bettypes
    - 20110930@Johnson: Add more group under Won currency
    - 20120412@Hurri: hardcode not to update commission for member under agent BARM.
    - 20120522@Sophia: Remove hardcode not to update commission for member under agent BARM.
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
    - 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
    - 20131029@Kathy: Apply exec rep to update commission [Redmine:#3244]
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB)
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	
Param's Explanation:
• @ErrCode:
    = 0: Update agent's commission successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()

	declare @Old_groupa DECIMAL(9,8),
		@Old_groupb DECIMAL(9,8),
		@Old_groupc DECIMAL(9,8),
		@Old_groupd DECIMAL(9,8),
		@Old_discountcs DECIMAL(9,8),
		@Old_discount1x2 DECIMAL(9,8),    
		@Old_discountHRFixedOdds DECIMAL(9,8),
		@Old_discountnumber decimal(9,8)
	    
	--Check Param
	IF 
		@discountcs<0 OR @discountcs>0.2
		OR @discount1x2<0 OR @discount1x2>0.2
		OR @discountHRFixedOdds<0 OR @discountHRFixedOdds>0.2
		OR @discountnumber < 0 OR @discountnumber > 0.2
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

	---------------------------------------
	DECLARE @srecommend INT, @username VARCHAR(40), @roleid INT

	SELECT    @username = username,
			@srecommend = srecommend,
			@roleid = roleid
	FROM customer WITH (NOLOCK)
	WHERE custid = @custid AND roleid = 3

	--Check Allowed downlines    
	EXEC Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
				@roleid=@roleid,
				@isExecRep=1,
				@isUpdatePT = 1,
				@Sporttype = 1,
				@Language='E',
				@ErrMsg=@ErrMsg output,
				@ErrCode=@ErrCode output
	IF    @ErrCode <> 0 
		RETURN 
	    
	--Check modify group(other) or financial
	IF @updatecomm_old = 1
	BEGIN

		SELECT         
			@Old_groupa = groupa, 
			@Old_groupb = groupb, 
			@Old_groupc = groupc, 
			@Old_groupd = groupd 
		FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=1
	    
		SELECT @Old_discountcs = adiscount FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 1 AND bettype = 4
		SELECT @Old_discount1x2 = adiscount    FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 1 AND bettype = 5
		SELECT @Old_discountHRFixedOdds = adiscount    FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 154 AND bettype = 20    
		SELECT @Old_discountnumber = adiscount FROM custsetting3rd AS cs3 WITH (NOLOCK) WHERE custid = @custid AND sporttype = 161 AND bettype = 81
	    
		--Get g3=g4 if g3>g4
		SELECT 
			@groupa = CASE WHEN @groupa>groupa THEN groupa ELSE @groupa END, 
			@groupb = CASE WHEN @groupb>groupb THEN groupb ELSE @groupb END, 
			@groupc = CASE WHEN @groupc>groupc THEN groupc ELSE @groupc END, 
			@groupd = CASE WHEN @groupd>groupd THEN groupd ELSE @groupd END
		FROM custsetting AS cs WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype=1 AND sporttype=1  

		--Get m3=s4 if m3>s4
		SELECT @discountcs = CASE WHEN @discountcs > sdiscount THEN sdiscount ELSE @discountcs END
		FROM custsetting AS cs WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype = 4 AND sporttype = 1
		---------------------------------------
		--Get m3=s4 if m3>s4 --1x2 
		SELECT @discount1x2 = CASE WHEN @discount1x2 > sdiscount THEN sdiscount ELSE @discount1x2 END
		FROM custsetting AS cs WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype = 5 AND sporttype = 1
	    
		---------------------------------------
		--Get m3=s4 if m3>s4 --HR Fixed Odds
		SELECT @discountHRFixedOdds = CASE WHEN @discountHRFixedOdds > sdiscount THEN sdiscount ELSE @discountHRFixedOdds END
		FROM custsetting AS cs WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype = 20 AND sporttype = 154
	    
		---------------------------------------
		--Get m3=s4 if m3>s4 --number game
		SELECT @discountnumber = case when @discountnumber > sdiscount then sdiscount else @discountnumber end
		FROM custsetting3rd as cs3 with(nolock)
		WHERE custid = @srecommend AND bettype = 81 AND sporttype = 161
	    
	    IF @IsMyanmarOdds = 1
	    BEGIN
			-- Reset discount value in case its value > upline
			SELECT @discountMyanmarOdds = CASE 
												WHEN @discountMyanmarOdds > commRate THEN commRate
												ELSE @discountMyanmarOdds   
											END
			FROM AgentCommRate WITH(NOLOCK)  
			WHERE custid = @srecommend   
				AND sporttype = 1   
				AND bettype = 301  
		END	
		-- Apply exec rep
			exec Acc_CustSetting_06
			@CustId = @custid,
			@RoleId = @RoleId,
			@groupa = @groupa,
			@groupb = @groupb,
			@groupc = @groupc,
			@groupd = @groupd,
			@discountcs = @discountcs,
			@discountHRFixedOdds = @discountHRFixedOdds,
			@discount1x2 = @discount1x2,
			@discountMyanmarOdds = @discountMyanmarOdds,
			@IsMyanmarOdds = @IsMyanmarOdds
	        

			 exec Acc_CustSetting3rd_06
			@CustId = @custid,
			@RoleId = @RoleId,
			@discountNumber = @discountnumber,
			@mode = 'NumberGame'
	END



	Declare @LogSPData varchar(8000)
	Declare @TrackingValue2 varchar(8000)

	Select @LogSPData = '<Acc_CustomerUpdMaster_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

	Select @TrackingValue2 = '<Acc_CustomerUpdMaster_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	BEGIN TRY
		--Log customer info 
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 205,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
	END TRY
	BEGIN CATCH
		Select @LogSPData = '<Acc_CustomerUpdMaster_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1))+ '" />'

		Select @TrackingValue2 = '<Acc_CustomerUpdMaster_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1))+ '" />'

		--Log customer info 
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 205,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration    
	END CATCH
END
GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_Commission] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_Commission] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_Commission] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_Commission] TO [bodbExtAccNet]
GO 
