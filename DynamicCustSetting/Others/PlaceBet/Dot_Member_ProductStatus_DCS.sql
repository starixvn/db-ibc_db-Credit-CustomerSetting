/*<info serverAlias="DBCUST-CUSTDB" executers="Dot_Casino,Dot_intg,Dot_Member" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Dot_Member_ProductStatus_DCS]
	@custid int,
	@sporttype smallint,
	@bettype smallint= 0,
	@liveindicator bit =0,
	@isLicensee bit = 0
AS
BEGIN
/*
    DB: DBCust/CustDB
    Original: 
    
Revisions:
    --20160401@CharlieMa: add Deposit feature
    --20160530@Vivi: licensee only sporttype=212 get data from Dep_CustProductStatus setting table
    --20160817@BrianYang: Support search by bettype and use min bitmapOrder to be result to return, due to Sport Type have 2 bettypes setting
    --20160830@Vivi: remove hardcode sporttype=212
    --20170706@Joychen: becsuse VNDBA setting credit   :all VS for 180 as representavtive
                                              Licensee :180~186 for 180 as representavtive,190~191 for 190 as representavtive
    --20180213@TWJoe (DBCust):Betradar VS credit   :193 VS for 180 as representavtive
                                        Licensee :193 for 190 as representavtive
    --20180305@TWJoe (DBCust):Betradar VS credit   :192 VS for 180 as representavtive
                                        Licensee :192 for 190 as representavtive
    --20181128@TWJoe (DBCust):Betradar VS credit   :194 VS for 180 as representavtive
                                        Licensee :194 for 190 as representavtive
    --20200320@TWAdam(DBCust): Support sporttype 195,196 for Betradar VS
    --20200408@TWAdam(DBCust): Support sporttype 197 for Betradar VS
    - 20201127@Winfred: 231 for 180 as representavtive [redmine:#131370]    
    --20220727@TWAndy(DBCust): Support NumberGame(161) and Happy5(164) for Licensee
	- 20221121@Eden: Unify VS and RNG Lottery Customer Settings [RedmineID: #180640]
	- 20221121@TWAndy(DBCust): Support NumberGame(161) and Happy5(164) for Credit
	- 20240221@Tacy: Virtual Sports - Merge VS1, VS2, VS3 into Virtual Sports [RedmineID: #198008]
Explanation :   

*/
    SET nocount ON;
    DECLARE @IsHidden BIT,
            @IsDisabled BIT  
    DECLARE @BitMapOrder TINYINT

    IF @isLicensee = 0
    BEGIN           
        SELECT @sporttype = case when @sporttype between 180 and 186 then 9908
							     when @sporttype between 190 and 197 then 9908 
							     when @sporttype = 231 then 9908
								 when @sporttype in (161,164) then 161
							     else @sporttype end

		SELECT @bettype = case when @bettype = 1021 then 1024
							    when @sporttype = 9908 then 1201
							    else @bettype end

        --Get Bitmaporder
        SELECT @BitMapOrder = min(bitmapOrder)
        FROM dbo.ProductStatusProfile psp WITH (NOLOCK) 
        WHERE Sporttype = @sporttype
        and Bettype = (case when @bettype <> 0 then @bettype else Bettype end) 

        --Get Product Status
        SELECT @IsDisabled = ISNULL(dbo.f_GetProductStatus(bitmapIsDisabled,@BitMapOrder),1)
            ,@IsHidden = ISNULL(dbo.f_GetProductStatus(bitmapIsHidden,@BitMapOrder),1)
        FROM dbo.CustProductStatus stt WITH (NOLOCK)
        WHERE CustID = @custid
        
    END
    ELSE
    BEGIN
        SELECT @sporttype = case when @sporttype between 180 and 186 then 9908
                                 when @sporttype between 190 and 197 then 9908
                                 when @sporttype in (161,164) then 161
                                 else @sporttype end

		SELECT @bettype = case when @sporttype = 9908 then 1201
							    else @bettype end

        --Get Bitmaporder
        SELECT @BitMapOrder = min(bitmapOrder)
        FROM dbo.Dep_ProductStatusProfile psp WITH (NOLOCK) 
        WHERE Sporttype = @sporttype
            and Bettype = (case when @bettype <> 0 then @bettype else Bettype end) 
            
        IF @BitMapOrder IS NOT NULL
        BEGIN
            --Get Product Status
            SELECT @IsDisabled = ISNULL(dbo.f_GetProductStatus(bitmapIsDisabled,@BitMapOrder),1)
                ,@IsHidden = ISNULL(dbo.f_GetProductStatus(bitmapIsHidden,@BitMapOrder),1)
            FROM dbo.Dep_CustProductStatus stt WITH (NOLOCK)
            WHERE CustID = @custid
        END
        ELSE
        BEGIN
            --License users are allowed to play Muay Thai (@sporttype=44)
            SELECT @IsHidden = 0, @IsDisabled = 0
        END
    END

    SELECT @IsHidden IsHidden, @IsDisabled IsDisabled
END
GO