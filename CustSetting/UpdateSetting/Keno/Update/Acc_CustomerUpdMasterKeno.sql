/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterKeno]
(
    @CustId INT --Master
    , @SportType INT = 202
    , @BetType INT
    
    , @s3 SMALLMONEY --s3
    , @us3 SMALLMONEY --us3
    , @is3 BIT = 0 --is3
    , @m3 SMALLMONEY --m3
    , @n3 SMALLMONEY --n3

    , @UpdateAllMembers    BIT = 0
    , @NewSPositionTaking SMALLMONEY = 0

    , @Discount DECIMAL(9,8) = 0
            
    , @UpdatePositiontaking    BIT = 0
    , @UpdateMinPositiontaking BIT = 0
    , @UpdateAutoPositionTaking    BIT = 0
    , @UpdateCommission BIT = 0
    
    , @SubAccID INT = 0 --Sub-AccountID
    , @UserID INT = 0
    , @Language varchar(2) = 'E'
    , @IP VARCHAR(15) = ''
    , @ErrCode VARCHAR(300)  = '' OUTPUT
    , @ErrMsg NVARCHAR(4000) = '' OUTPUT
)
AS
/*
    Created: 20140326@Patrick
    DB: DBCust/CustDB
    Task: Super edits Keno settings on master
        
    Revisions:
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
    Parameters Explanation:
        @ErrCode is:
            -101 update success commission
            -102 update success min PT
            -103 update success PT
*/
BEGIN
    SET NOCOUNT ON
    DECLARE @roleid TINYINT, @srecommend INT, @SyncLiveCasino BIT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000)
    SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

    --Check downline beloging
    EXEC dbo.Age_CustomerSelCheckBelonging @SessionCustID = @UserID
        , @Custid = @CustId
        , @roleid = @roleid OUTPUT

    IF (@roleid = 0) RETURN
    
    -- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103
		RETURN
	END
    --Check disable user
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode = @ErrCode_Cur OUTPUT, @ErrMsg = @ErrMsg_Cur OUTPUT
    IF @ErrCode_Cur > 0
    BEGIN
        SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
        RETURN
    END
    
    SELECT @srecommend = srecommend FROM CustInfo WITH (NOLOCK) WHERE custid = @Custid

    IF @UpdateCommission = 1
    BEGIN
                EXEC dbo.Acc_CustomerUpdMasterKeno_Commission @custid = @custid
            , @Discount    = @Discount
            , @BetType = @BetType
            , @SportType = @SportType
            , @IP = @IP
            , @SubAccID = @SubAccID
            , @UserID = @UserID
            , @Language    = @Language
            , @ErrCode = @ErrCode_Cur OUTPUT
            , @ErrMsg = @ErrMsg_Cur OUTPUT
    
        IF @ErrCode_Cur = 0
        BEGIN
            SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
        END
        ELSE
        BEGIN
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
            RETURN
        END
    END

    -- check n3<= m3
    IF @m3 < @n3
    BEGIN
        SELECT @ErrMsg_Cur = CASE @Language WHEN 'E' THEN 'Wrong position taking .<br>'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + '<br>' END
            , @ErrCode_Cur = 100
        SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
        RETURN    
    END

    IF @UpdateMinPositiontaking = 1
    BEGIN
                EXEC dbo.Acc_CustOverrideUpdKeno @custid = @custid
            , @sporttype = @sporttype
            , @bettype = @bettype
            , @Min_Positiontaking = @n3
            , @UplineID = @srecommend
            , @IP = @IP
            , @SubAccID = @SubAccID
            , @UserID = @userid
            , @Language = @Language
            , @ErrCode    = @ErrCode_Cur OUTPUT
            , @ErrMsg    = @ErrMsg_Cur OUTPUT
    
        IF @ErrCode_Cur <> 0
        BEGIN
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
            RETURN    
        END
        ELSE
            SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
    END

    IF(@UpdatePositiontaking = 1 OR @UpdateAutoPositionTaking = 1)
    BEGIN
                EXEC dbo.Acc_CustomerUpdMasterKeno_Positiontaking @custid = @custid
            , @sporttype = @sporttype
            , @bettype = @bettype
            , @s3 =  @s3--s3
            , @us3 = @us3 --us3
            , @is3 = @is3 --is3
            , @m3 = @m3 --m3
            , @n3 = @n3 --n3
    
            , @UpdateAllMembers    = @UpdateAllMembers
            , @NewSPositionTaking = @NewSPositionTaking
            , @UpdatePositiontaking = @UpdatePositiontaking
            , @UpdateMinPositiontaking = @UpdateMinPositiontaking
            , @UpdateAutoPositionTaking = @UpdateAutoPositionTaking

            , @IP = @IP
            , @SubAccID = @SubAccID
            , @UserID = @userid
            , @Language = @Language
            , @ErrCode = @ErrCode_Cur OUTPUT
            , @ErrMsg    = @ErrMsg_Cur OUTPUT
    
        IF @ErrCode_Cur = 0
        BEGIN
            SELECT @ErrCode = @ErrCode + '-103' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
        END
        ELSE
        BEGIN
            SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
            RETURN
        END
    END
END
GO
