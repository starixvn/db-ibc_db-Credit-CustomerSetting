/*<info serverAlias="DBCUST-CustDB" executers="Dot_Member" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Dot_Member_CustomerGetVirtualRateBySportBettype]
                    @CustID     INT,
                    @SportType  SMALLINT,
                    @BetType    SMALLINT,
                    @isLive     BIT,
                    @virtualMultiplier Smallmoney out
                    
AS
    /*
        Created: 20151019@joy
        DB: DBCUST.CustDB
        Task: Select Virtual Rate from new table structure

        Revisions:

        Parameter's Explanation:
    */
BEGIN
    SET NOCOUNT ON

    SELECT      @virtualMultiplier=dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID)
    FROM        CustVirtualSetting    	AS cvs WITH(NOLOCK)
    INNER JOIN  ProfileVirtualSetting   AS pvs WITH(NOLOCK)
            ON  cvs.seqNo = pvs.seqNo
    WHERE       cvs.custid = @CustID
            AND pvs.sporttype = @SportType
            AND pvs.bettype = @BetType
            AND pvs.islive = @isLive   
			AND pvs.isActive=1  
END