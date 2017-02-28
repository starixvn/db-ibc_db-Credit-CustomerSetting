USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdUserInfo]    Script Date: 06/10/2015 16:25:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdUserInfo    Script Date: 6/2/2014 2:04:21 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdUserInfo    Script Date: 6/2/2014 12:38:18 PM ******/


ALTER PROCEDURE [dbo].[Acc_CustomerUpdUserInfo]
	@CustID         int,	
	@firstname      nvarchar(50) = NULL,
	@lastname       nvarchar(50) = NULL,
	@address        nvarchar(80) = NULL,
	@postal         nvarchar(50) = NULL,
	@city           nvarchar(50) = NULL,
	@state          nvarchar(50) = NULL,
	@country        nvarchar(50) = NULL,
	@phone          nvarchar(50) = NULL,
	@mobilephone    nvarchar(50) = NULL,
	@fax            nvarchar(50) = NULL,
	@email          nvarchar(50) = NULL,
	@birthday       smalldatetime = NULL,
	@refcode1       nvarchar(50) = NULL,
	@refcode2       nvarchar(50) = NULL,
	@remark         nvarchar(300) = NULL,
	@important      bit = NULL,
	@gender         bit = NULL,
	@disCasino      bit = 0,
	@SubAccID       int = 0, --Sub-AccountID
	@UserID         int,
	@Language       varchar(2) = 'E',
	@ErrCode        int = 0 OUTPUT,
	@ErrMsg         nvarchar(200) = '' OUTPUT,
	@IP             varchar(15)=''

AS
/*
Created: 20090122@Phuc
Task : Update customer's info
DB: DBTXN/bodb02
Original:
Revisions:
	- 20090723@Phuc: Write log subaccname instead of subaccid.
	- 20090801@Shifu: check disabled user	
	- 20090917@Phuc: write log into DBLOG.
	- 20091008@Kiwi: Remove WriteLog_UserLog
	- 20091125@Terry: Add one more para @disCasino to check disabled Casino
	- 20100107@Lewin: change sp format, call new writelog sp 
	- 20100414@Kiwi: Remove to do not update gender field.	
	- 20100917@Kiwi: Correct "convert wrong datatype when writing log"
	- 20101021@Henry: Record execution time
	- 20110603@Amy: Write Log Old values
	- 20110907@Lukas: Change linked-server from DB052 -> DB053
	- 20110909@Lukas: modify '@Old_import compare with NULL' code
	- 20120731@Lukas: Check old & new value in case of NULL
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Change linked server DB053 to DBAGE; Write more log on DBTXN server in case of DBLOG server failure
	- 20140519@Logan:   1.Updating remarks for SAg, MAg, Ag and members
	                    2.Code aligning
	- 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB) [Redmine:#36216]	                    
	- 20160128@Elodie: Don't update and write log with the fiels don't show on Alpha site
	- 20160903@Winnie: Fix bug #53634 [Log is still generated when Updating without any changed for a customer that does not have any log record for today]
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

DECLARE @old_firstname nvarchar(50),
        @old_lastname nvarchar(50),
        @old_address nvarchar(80),
        @old_postal nvarchar(50),
        @old_city nvarchar(50),
        @old_state nvarchar(50),
        @old_country nvarchar(50),
        @old_phone nvarchar(50),
        @old_mobilephone nvarchar(50),
        @old_fax nvarchar(50),
        @old_email nvarchar(50),
        @old_birthday smalldatetime,
        @old_refcode1 nvarchar(50),
        @old_refcode2 nvarchar(50),
        @old_remark nvarchar(300),
        @old_important bit,
        @old_gender bit

--Check disable user
EXEC dbo.Acc_CustomerSelCheckEnable
     @custid = @CustID,
     @ErrCode=@ErrCode output,
     @ErrMsg=@ErrMsg output
if @ErrCode <> 0 return
--end		

IF exists(select 1 
            from custinfo with(nolock)
           where synccasino = 1
             and custid = @CustID
         )
BEGIN
	IF @disCasino = 1
		BEGIN	
			Select @ErrMsg = case @Language 
								when 'E' then 'This USER INFO function is temporarily unavailable, please update later.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40005,@Language)
							end	,
				   @ErrCode = 100

			return
		END
END

declare @roleid int
 
SELECT @old_firstname = firstname ,
       @old_lastname = lastname,
       @old_address= address,
       @old_postal = postal ,
       @old_city = city ,
       @old_state = state,
       @old_country = country,
       @old_phone = phone,
       @old_mobilephone = mobilephone,
       @old_fax = fax,
       @old_email = email,
       @old_birthday = birthday,
       @old_refcode1 = refcode1,
       @old_refcode2 = refcode2,
       @old_remark = remark,
       @old_important = important,
       @roleid = roleid
  FROM customer with(nolock)
 where custid = @CustID
 
if @roleid = 2
    begin
        select @old_remark = creationRemark
          from CustAgent with(nolock)
         where custid = @CustID
    end

if @roleid = 3
    begin
        select @old_remark = creationRemark
          from CustMaster with(nolock)
         where custid = @CustID
    end
         
if @roleid = 4
    begin
        select @old_remark = creationRemark
          from CustSuper with(nolock)
         where custid = @CustID
    end         
         

IF ISNULL(@old_firstname,'') <> ISNULL(@firstname,'') OR
ISNULL(@old_lastname,'') <> ISNULL(@lastname,'') OR
ISNULL(@old_phone,'') <> ISNULL(@phone,'') OR
ISNULL(@old_mobilephone,'') <> ISNULL(@mobilephone,'') OR
ISNULL(@old_fax,'') <> ISNULL(@fax,'') OR
(@email IS NOT NULL AND ISNULL(@old_email,'') <> ISNULL(@email,'')) OR
(@address IS NOT NULL AND ISNULL(@old_address,'')<> ISNULL(@address,'')) OR
(@postal IS NOT NULL AND ISNULL(@old_postal,'') <> ISNULL(@postal,'')) OR
(@city IS NOT NULL AND ISNULL(@old_city,'') <> ISNULL(@city,'')) OR
(@state IS NOT NULL AND ISNULL(@old_state,'') <> ISNULL(@state,'')) OR
(@country IS NOT NULL AND ISNULL(@old_country,'') <> ISNULL(@country,'')) OR
(@birthday IS NOT NULL AND ISNULL(@old_birthday,'1900-01-01') <> ISNULL(@birthday,'1900-01-01')) OR
(@refcode1 IS NOT NULL AND ISNULL(@old_refcode1,'') <> ISNULL(@refcode1,'')) OR
(@refcode2 IS NOT NULL AND ISNULL(@old_refcode2,'') <> ISNULL(@refcode2,'')) OR
(@remark IS NOT NULL AND ISNULL(@old_remark,'') <> ISNULL(@remark,'')) OR
(@important IS NOT NULL AND ISNULL(@old_important,0) <> ISNULL(@important,0))

BEGIN

	Update customer with (ROWLOCK)
	   set firstname = case when @firstname is null then firstname else @firstname end,
		   lastname = case when @lastname is null then lastname else @lastname end,
		   address = case when @address is null then address else @address end,
		   postal = case when @postal is null then postal else @postal end,
		   city = case when @city is null then city else @city end,
		   state = case when @state is null then state else @state end,
		   country = case when @country is null then country else @country end,
		   phone = case when @phone is null then phone else @phone end,
		   mobilephone = case when @mobilephone is null then mobilephone else @mobilephone end,
		   fax = case when @fax is null then fax else @fax end,
		   email = case when @email is null then email else @email end,
		   birthday = case when @birthday is null then birthday else @birthday end,
		   refcode1 = case when @refcode1 is null then refcode1 else @refcode1 end,
		   refcode2 = case when @refcode2 is null then refcode2 else @refcode2 end,
		   --remark = case when @remark is null then remark else @remark end,
		   important = case when @important is null then important else @important end
	 where custID = @CustID
	 
    if @roleid = 1
    begin
        update customer with(rowlock, updlock)
           set remark = case when @remark is null then remark else SUBSTRING(@remark, 1, 50) end
         where custid = @CustID
    end

    if @roleid = 2
    begin
        update CustAgent with(rowlock, updlock)
           set creationRemark = case when @remark is null then creationRemark else @remark end
         where custid = @CustID
    end

    if @roleid = 3
    begin
        update CustMaster with(rowlock, updlock)
           set creationRemark = case when @remark is null then creationRemark else @remark end
         where custid = @CustID
    end
         
    if @roleid = 4
    begin
        update CustSuper with(rowlock, updlock)
           set creationRemark = case when @remark is null then creationRemark else @remark end
         where custid = @CustID
     end 

declare @LogSPData nvarchar(max)
declare @TrackingValue2 nvarchar(max)
IF @address IS NOT NULL AND
   @postal IS NOT NULL AND
   @city IS NOT NULL AND 
   @state IS NOT NULL AND
   @country IS NOT NULL AND  
   @birthday IS NOT NULL AND
   @refcode1 IS NOT NULL AND
   @refcode2 IS NOT NULL AND
   @remark IS NOT NULL AND
   @important IS NOT NULL
BEGIN
	Select @LogSPData = '<Acc_CustomerUpdUserInfo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1))+ '" ' + 
						'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as nvarchar(50)),space(1)))+ '" ' +
						'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as nvarchar(50)),space(1)))+ '" ' +
						'address="'+ dbo.f_EncodeXMLValue(coalesce(cast(@address as nvarchar(80)),space(1))) + '" ' +
						'postal="'+ dbo.f_EncodeXMLValue(coalesce(cast(@postal as nvarchar(50)),space(1)))+ '" ' +
						'city="'+ dbo.f_EncodeXMLValue(coalesce(cast(@city as nvarchar(50)),space(1)))+ '" ' +
						'state="'+ dbo.f_EncodeXMLValue(coalesce(cast(@state as nvarchar(50)),space(1)))+ '" ' +
						'country="'+ coalesce(cast(@country as nvarchar(50)),space(1))+ '" ' +
						'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as nvarchar(50)),space(1)))+ '" ' +
						'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as nvarchar(50)),space(1)))+ '" ' +
						'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as nvarchar(50)),space(1)))+ '" ' +
						'email="'+ dbo.f_EncodeXMLValue(coalesce(cast(@email as nvarchar(50)),space(1)))+ '" ' +
						'birthday="'+ coalesce(cast(@birthday as varchar(50)),space(1))+ '" ' +
						'refcode1="'+ dbo.f_EncodeXMLValue(coalesce(cast(@refcode1 as nvarchar(50)),space(1)))+ '" ' +
						'refcode2="'+ dbo.f_EncodeXMLValue(coalesce(cast(@refcode2 as nvarchar(50)),space(1)))+ '" ' +
						'remark="'+ dbo.f_EncodeXMLValue(coalesce(cast(@remark as nvarchar(50)),space(1)))+ '" ' +
						'important="'+ coalesce(cast(@important as varchar(50)),space(1))+ '" ' +
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1))+ '" ' +
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
					
	Select @TrackingValue2 = '<Acc_CustomerUpdUserInfo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1))+ '" ' + 
						'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_firstname as nvarchar(50)),space(1)))+ '" ' +
						'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_lastname as nvarchar(50)),space(1)))+ '" ' +
						'address="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_address as nvarchar(80)),space(1)))+ '" ' +
						'postal="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_postal as nvarchar(50)),space(1)))+ '" ' +
						'city="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_city as nvarchar(50)),space(1)))+ '" ' +
						'state="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_state as nvarchar(50)),space(1)))+ '" ' +
						'country="'+ coalesce(cast(@old_country as nvarchar(50)),space(1))+ '" ' +
						'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_phone as nvarchar(50)),space(1)))+ '" ' +
						'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_mobilephone as nvarchar(50)),space(1)))+ '" ' +
						'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_fax as nvarchar(50)),space(1)))+ '" ' +
						'email="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_email as nvarchar(50)),space(1)))+ '" ' +
						'birthday="'+ coalesce(cast(@old_birthday as varchar(50)),space(1))+ '" ' +
						'refcode1="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_refcode1 as nvarchar(50)),space(1)))+ '" ' +
						'refcode2="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_refcode2 as nvarchar(50)),space(1)))+ '" ' +
						'remark="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_remark as nvarchar(50)),space(1)))+ '" ' +
						'important="'+ coalesce(cast(@old_important as varchar(50)),space(1))+ '" ' +
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1))+ '" ' +
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
END
ELSE IF @email IS NOT NULL
BEGIN	
	Select @LogSPData = '<Acc_CustomerUpdUserInfo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1))+ '" ' + 
						'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as nvarchar(50)),space(1)))+ '" ' +
						'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as nvarchar(50)),space(1)))+ '" ' +
						'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as nvarchar(50)),space(1)))+ '" ' +
						'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as nvarchar(50)),space(1)))+ '" ' +
						'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as nvarchar(50)),space(1)))+ '" ' +
						'email="'+ dbo.f_EncodeXMLValue(coalesce(cast(@email as nvarchar(50)),space(1)))+ '" ' +
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1))+ '" ' +
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
					
	Select @TrackingValue2 = '<Acc_CustomerUpdUserInfo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1))+ '" ' + 
						'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_firstname as nvarchar(50)),space(1)))+ '" ' +
						'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_lastname as nvarchar(50)),space(1)))+ '" ' +
						'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_phone as nvarchar(50)),space(1)))+ '" ' +
						'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_mobilephone as nvarchar(50)),space(1)))+ '" ' +
						'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_fax as nvarchar(50)),space(1)))+ '" ' +
						'email="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_email as nvarchar(50)),space(1)))+ '" ' +
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1))+ '" ' +
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
END
ELSE 
BEGIN	
	Select @LogSPData = '<Acc_CustomerUpdUserInfo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1))+ '" ' + 
						'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as nvarchar(50)),space(1)))+ '" ' +
						'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as nvarchar(50)),space(1)))+ '" ' +
						'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as nvarchar(50)),space(1)))+ '" ' +
						'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as nvarchar(50)),space(1)))+ '" ' +
						'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as nvarchar(50)),space(1)))+ '" ' +						
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1))+ '" ' +
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
					
	Select @TrackingValue2 = '<Acc_CustomerUpdUserInfo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1))+ '" ' + 
						'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_firstname as nvarchar(50)),space(1)))+ '" ' +
						'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_lastname as nvarchar(50)),space(1)))+ '" ' +
						'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_phone as nvarchar(50)),space(1)))+ '" ' +
						'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_mobilephone as nvarchar(50)),space(1)))+ '" ' +
						'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_fax as nvarchar(50)),space(1)))+ '" ' +						
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1))+ '" ' +
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
END
set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
	/*604 Acc_CustomerUpdUserInfo_xtest Update customer info */
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 604,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END TRY
BEGIN CATCH			
	IF @address IS NOT NULL AND
	   @postal IS NOT NULL AND
	   @city IS NOT NULL AND 
	   @state IS NOT NULL AND
	   @country IS NOT NULL AND	 
	   @birthday IS NOT NULL AND
	   @refcode1 IS NOT NULL AND
	   @refcode2 IS NOT NULL AND
	   @remark IS NOT NULL AND
	   @important IS NOT NULL
	BEGIN
		Select @LogSPData = '<Acc_CustomerUpdUserInfo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1))+ '" ' + 
							'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as nvarchar(50)),space(1)))+ '" ' +
							'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as nvarchar(50)),space(1)))+ '" ' +
							'address="'+ dbo.f_EncodeXMLValue(coalesce(cast(@address as nvarchar(80)),space(1)))+ '" ' +
							'postal="'+ dbo.f_EncodeXMLValue(coalesce(cast(@postal as nvarchar(50)),space(1)))+ '" ' +
							'city="'+ dbo.f_EncodeXMLValue(coalesce(cast(@city as nvarchar(50)),space(1)))+ '" ' +
							'state="'+ dbo.f_EncodeXMLValue(coalesce(cast(@state as nvarchar(50)),space(1)))+ '" ' +
							'country="'+ coalesce(cast(@country as nvarchar(50)),space(1))+ '" ' +
							'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as nvarchar(50)),space(1)))+ '" ' +
							'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as nvarchar(50)),space(1)))+ '" ' +
							'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as nvarchar(50)),space(1)))+ '" ' +
							'email="'+ dbo.f_EncodeXMLValue(coalesce(cast(@email as nvarchar(50)),space(1)))+ '" ' +
							'birthday="'+ coalesce(cast(@birthday as varchar(50)),space(1))+ '" ' +
							'refcode1="'+ dbo.f_EncodeXMLValue(coalesce(cast(@refcode1 as nvarchar(50)),space(1)))+ '" ' +
							'refcode2="'+ dbo.f_EncodeXMLValue(coalesce(cast(@refcode2 as nvarchar(50)),space(1)))+ '" ' +
							'remark="'+ dbo.f_EncodeXMLValue(coalesce(cast(@remark as nvarchar(50)),space(1)))+ '" ' +
							'important="'+ coalesce(cast(@important as varchar(50)),space(1))+ '" ' +
							'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
							'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1))+ '" ' +
							'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+ '" ' +
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
						
		Select @TrackingValue2 = '<Acc_CustomerUpdUserInfo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1))+ '" ' + 
							'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_firstname as nvarchar(50)),space(1)))+ '" ' +
							'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_lastname as nvarchar(50)),space(1)))+ '" ' +
							'address="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_address as nvarchar(80)),space(1)))+ '" ' +
							'postal="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_postal as nvarchar(50)),space(1)))+ '" ' +
							'city="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_city as nvarchar(50)),space(1)))+ '" ' +
							'state="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_state as nvarchar(50)),space(1)))+ '" ' +
							'country="'+ coalesce(cast(@old_country as nvarchar(50)),space(1))+ '" ' +
							'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_phone as nvarchar(50)),space(1)))+ '" ' +
							'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_mobilephone as nvarchar(50)),space(1)))+ '" ' +
							'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_fax as nvarchar(50)),space(1)))+ '" ' +
							'email="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_email as nvarchar(50)),space(1)))+ '" ' +
							'birthday="'+ coalesce(cast(@old_birthday as varchar(50)),space(1))+ '" ' +
							'refcode1="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_refcode1 as nvarchar(50)),space(1)))+ '" ' +
							'refcode2="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_refcode2 as nvarchar(50)),space(1)))+ '" ' +
							'remark="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_remark as nvarchar(50)),space(1)))+ '" ' +
							'important="'+ coalesce(cast(@old_important as varchar(50)),space(1))+ '" ' +
							'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
							'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1))+ '" ' +
							'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+ '" ' +
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
	END
	ELSE IF @email IS NOT NULL
	BEGIN
		Select @LogSPData = '<Acc_CustomerUpdUserInfo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1))+ '" ' + 
							'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as nvarchar(50)),space(1)))+ '" ' +
							'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as nvarchar(50)),space(1)))+ '" ' +
							'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as nvarchar(50)),space(1)))+ '" ' +
							'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as nvarchar(50)),space(1)))+ '" ' +
							'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as nvarchar(50)),space(1)))+ '" ' +
							'email="'+ dbo.f_EncodeXMLValue(coalesce(cast(@email as nvarchar(50)),space(1)))+ '" ' +
							'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
							'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1))+ '" ' +
							'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+ '" ' +
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
						
		Select @TrackingValue2 = '<Acc_CustomerUpdUserInfo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1))+ '" ' + 
							'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_firstname as nvarchar(50)),space(1)))+ '" ' +
							'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_lastname as nvarchar(50)),space(1)))+ '" ' +
							'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_phone as nvarchar(50)),space(1)))+ '" ' +
							'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_mobilephone as nvarchar(50)),space(1)))+ '" ' +
							'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_fax as nvarchar(50)),space(1)))+ '" ' +
							'email="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_email as nvarchar(50)),space(1)))+ '" ' +
							'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
							'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1))+ '" ' +
							'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+ '" ' +
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
	END			
	ELSE 
	BEGIN
		Select @LogSPData = '<Acc_CustomerUpdUserInfo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1))+ '" ' + 
							'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as nvarchar(50)),space(1)))+ '" ' +
							'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as nvarchar(50)),space(1)))+ '" ' +
							'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as nvarchar(50)),space(1)))+ '" ' +
							'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as nvarchar(50)),space(1)))+ '" ' +
							'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as nvarchar(50)),space(1)))+ '" ' +							
							'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
							'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1))+ '" ' +
							'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+ '" ' +
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
						
		Select @TrackingValue2 = '<Acc_CustomerUpdUserInfo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1))+ '" ' + 
							'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_firstname as nvarchar(50)),space(1)))+ '" ' +
							'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_lastname as nvarchar(50)),space(1)))+ '" ' +
							'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_phone as nvarchar(50)),space(1)))+ '" ' +
							'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_mobilephone as nvarchar(50)),space(1)))+ '" ' +
							'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@old_fax as nvarchar(50)),space(1)))+ '" ' +							
							'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
							'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1))+ '" ' +
							'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+ '" ' +
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
	END			
	/*604 Acc_CustomerUpdUserInfo_xtest Update customer info */
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 604,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration	
END CATCH
END

ELSE RETURN
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdUserInfo] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdUserInfo] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdUserInfo] TO [bodbExtAccNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdUserInfo] TO [vnteam] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdUserInfo] TO [vnteam] AS [dbo]