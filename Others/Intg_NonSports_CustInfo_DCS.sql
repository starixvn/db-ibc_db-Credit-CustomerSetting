/*<info serverAlias="DBCUST-CustDB" executers="Dot_Member,Dot_Intg" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Intg_NonSports_CustInfo_DCS] 
    @custid int,
    @sporttype int = 0,
    @WinMaxBetType smallint = 0,
    @isLicensee bit = 0
AS
/*
	Created:	20160223@Brian
	Task:		Get cust info base on DCS structure
	DB:			DBCUST/CustDB
	Original:	
 
	Revisions: 
     -- 20160223@BrianYang(CUSTDB): Copy from Intg_NonSports_CustInfo_test use for get custinfo include product status 
     -- 2016/04/01@CharlieMa(CUSTDB): add Deposit feature
     -- 2016/04/27@BrianYang(CUSTDB): change @MaxLoseVendorGame data type from smallmoney to money 
     -- 2019/04/16@FannyChen(CUSTDB): add select column DisableCasino
     -- 2019/05/10@YolandaWu(CUSTDB): add usertype (CN88)
     -- 2019/05/30@Vivi(CUSTDB): add UM control
     -- 2019/06/13 @Sobi(CUSTDB): CN88 User Check reject,closed setting from CS_CustomerStatus
     -- 2021/07/05 @EricFU(CUSTDB) : add Reject/Close Account for credit user, remove CB88 logic
     -- 2021/07/13 @EricFU(CUSTDB) : modify @CloseInfo,@Locked,@SuspendInfo > 0

	--------------------------------------------------------------------------------
    -- !!!!!!!!!!!!!!! include UM function !!!!!!!!!!!!!!!!!!!!!!!!
    -- durning UM time alert function [f_CheckUMStatus]
    --------------------------------------------------------------------------------    
*/
BEGIN
    SET NOCOUNT ON;

    -- 1 Declare variable
   declare @MaxWinVendorGame smallmoney=0, @MaxLoseVendorGame money=0, @DisBetSetting bit
   declare @UMRejectFlag bit = 0
    -- 2 Cust wim losee limit 
    /*
        Initial : Previous version is query from CustWinLimit, VN Team(Johnson) remide change to used CustWinLossLimit_Member
    */
    if @WinMaxBetType<>0
    begin
        select @MaxWinVendorGame=ISNULL(MaxWinLimit,0), @MaxLoseVendorGame=ISNULL(MaxLossLimit,0)
        from CustWinLossLimit_Member with (nolock) 
        where sporttype=@sporttype 
          and bettype=@WinMaxBetType 
          and CustID=@custid
    end
    
    -- 4 Check Product status  
    /* 
        Initial : Core Team Joe provide sample code to get production status 
    
    */
    -- 20181219@Vivi: add get UM flag
    SELECT @UMRejectFlag = dbo.f_CheckUMStatus(@custid, @isLicensee)

    IF @isLicensee = 0 
    BEGIN
        DECLARE @IsDisabled BIT  
        DECLARE @BitMapOrder TINYINT, @SuspendInfo TINYINT, @CloseInfo TINYINT, @Locked TINYINT 
        --Get Bitmaporder
        SELECT @BitMapOrder = min(bitmapOrder)
        FROM dbo.ProductStatusProfile psp WITH (NOLOCK) 
        WHERE Sporttype = @sporttype        
                
        --Get Product Status
        SELECT @IsDisabled = ISNULL(dbo.f_GetProductStatus(bitmapIsDisabled,@BitMapOrder),1),
            @SuspendInfo = SuspendInfo, @CloseInfo = CloseInfo, @Locked = Locked
        FROM dbo.CustProductStatus WITH (NOLOCK)
        WHERE CustID = @custid

        SELECT  c.currency as currency,
                e.currency as currencyname,
                e.MultipliedBy as currencymultiplier,
                c.username as username,
                c.srecommend as srecommend,
                c.mrecommend as mrecommend,
                c.recommend as recommend,
                e.actualrate as actualrate,
                e.actualrate as virtualrate,
                c.credit as credit,         
                (case                   
                    when (isnull(@CloseInfo,0) > 0 ) or (isnull(@Locked,0) > 0 ) then 1
                    else 0 end) as closed,
                (case
                    when (isnull(@SuspendInfo,0) > 0) then 1
                    when (@UMRejectFlag = 0) then 0
                    when (@UMRejectFlag = 1) and (c.srecommend = 72 or c.currency = 20) then 0
                    when (@UMRejectFlag = 1) then 1
                    else 0 end) as reject,
                @MaxWinVendorGame as MaxWinVendorGame,
                @MaxLoseVendorGame as MaxLoseVendorGame,
                @IsDisabled as DisableProdcut,
                c.DisableCasino as DisableCasino
        from CustInfo c with (nolock)   
        inner join exchange e with (nolock) on c.currency = e.exchangeid
        where c.custid = @custid
    END
    ELSE
    BEGIN
        set @DisBetSetting=0
        CREATE TABLE #tmp (IsHidden bit, IsDisabled bit)
    
        INSERT INTO  #tmp (IsHidden, IsDisabled)
        exec Dot_Member_ProductStatus_DCS
                    @custid=@custid,
                    @sporttype=@sporttype,
                    @isLicensee = @isLicensee               
        select @DisBetSetting=IsDisabled from #tmp  
    
        SELECT  c.currency as currency,
                e.currency as currencyname,
                e.MultipliedBy as currencymultiplier,
                c.username as username,
                c.srecommend as srecommend,
                c.mrecommend as mrecommend,
                c.recommend as recommend,
                e.actualrate as actualrate,
                e.actualrate as virtualrate,
                c.credit as credit,         
                isnull(c.closed,0) as closed,
                (case                   
                    when (@UMRejectFlag = 0) then 0
                    when (@UMRejectFlag = 1) and (c.srecommend = 72 or c.currency = 20) then 0
                    when (@UMRejectFlag = 1) then 1
                    else isnull(c.reject,0) end) as reject,
                @MaxWinVendorGame as MaxWinVendorGame,
                @MaxLoseVendorGame as MaxLoseVendorGame,
                @DisBetSetting as DisableProdcut,
                c.DisableCasino as DisableCasino
        from CustInfo c with (nolock)   
        inner join exchange e with (nolock) on c.currency = e.exchangeid
        where c.custid = @custid
    END
        
END
GO