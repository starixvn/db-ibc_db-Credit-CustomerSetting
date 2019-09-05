/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_06]
    @CustId int,
    @RoleId int,
    @mode varchar(30),
    @Sporttype INT = 202, 
    @Bettype INT = 1501, 
    @Discount DECIMAL(9,8) = 0
AS
/*
	Created: Kathy
    Date: 20131029
    Task : Update commission [Redmine:#3244]
    DB: DBCUST/CustDB
    Original: 
    Revisions:
        - 20131029@Kathy: Update NumberGame's commission for all level. Refer to:
            + Acc_CustomerUpdSuper_Commission
            + Acc_CustomerUpdMaster_Commission
            + Acc_CustomerUpdAgent_Commission
            + Acc_CustomerUpdMember_Commission
        - 20131030@Kathy: Apply exec rep for all level Horse Racing. Refer to:
            + Acc_CustomerUpdSuper_CommissionHR
            + Acc_CustomerUpdMaster_CommissionHR
            + Acc_CustomerUpdAgent_CommissionHR
            + Acc_CustomerUpdMember_CommissionHR
        - 20131031@Kathy: Apply exec rep for super, master, agent level Live Casino. Refer to:
            + Acc_CustomerUpdSuperLiveCS_Commission
            + Acc_CustomerUpdMasterLiveCS_Commission
            + Acc_CustomerUpdAgentLiveCS_Commission
        - 20131118@Kathy: Update live casino commission for super and all downlines. Refer to:
            + Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels                        
        - 20131122@Francis: Add checking for super Deposit Type
            + If super is Deposit, do not update commission on its downline members for LiveCasino
        - 20140227@Elodie: Add Keno sport [Redmine:#11658]
        - 20140729@Logan:   1.Exclude disabled agents while updating SM's setting [Redmine: #19631]
                            2.Code aligning on modified parts
		- 20141113@Johnson: Hardcode agent list not give commission for downlines 
						and add Keno, LiveCasino sport for member level [Redmine #25787]                                              
		- 20150422@Elodie: Add Gold Deluxe product [Redmine:#34486]
		- 20150610@Daniel: 
			+ Improve medthod check table existing in subscribers	
			+ Separate custDB to new server DBCUST  
		- 20150616@Johnson: Add more hard customers not give commission [Redmine: #34798]	
		- 20150825@Helen: Colossus Bet - [Redmine: #41264]
		- 20151111@Helen: Add more hard customers not give commission [Redmine: #47068]
		- 20151222@Johnson: Add more customers not give commission [Redmine: #49494]
		- 20160125@Helen: Add more customers not give commission [Redmine: #51057]		
		- 20160608@Elodie: Add more customers not give commission [Redmine: #58999]	\
		- 20160909@Winnie: Not apply CustNoComm for 3rd product [Redmine: #63736]	
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20190829@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
    Param's Explanation: 
        @mode: 
                - 'Numbergame': Number game
                - 'HorseRacing': Horse Racing
                - 'LiveCasino': Live Casino
                - 'Keno': Keno
                - 'LiveCasinoUpdAll': Update LC commision for super and downlines
				- 'GoldDeluxe': Gold Deluxe
            
    */
BEGIN
    SET NOCOUNT ON;
    
	if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	     AND dbo.f_CheckRepTable('custsetting3rd') = 1 
	     AND dbo.f_CheckRepTable('CustSettingGame') = 1 
	     AND dbo.f_CheckRepTable('customer') = 1 
	     AND dbo.f_CheckRepTable('Dep_CustSuper') = 1 
     ) 
	   	RETURN    

	IF @mode = 'Keno' or @mode = 'GoldDeluxe' 
    BEGIN
        IF @RoleId = 4
        BEGIN
            UPDATE dbo.CustSettingGame WITH(UPDLOCK, ROWLOCK)
               SET sdiscount = @Discount
             WHERE custid = @CustId AND bettype = @Bettype
                AND sporttype = @Sporttype AND sdiscount <> @Discount

            --Update g3=g4 if g3>g4
            UPDATE cs
               SET cs.adiscount = @Discount
              FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
                INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.srecommend = @custid AND ci.roleid = 3
                 AND bettype = @Bettype AND cs.sporttype = @Sporttype
                 AND cs.adiscount > @Discount

            --Update g2=g4 if g2>g4
            UPDATE cs
               SET cs.discount = @Discount
              FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
				INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.srecommend = @custid
               AND ci.roleid     = 2
               AND ci.Enabled    = 1
               AND bettype       = @Bettype
               AND cs.sporttype  = @Sporttype
               AND cs.discount   > @Discount

            --Update g4 at Member level
            UPDATE cs
               SET sdiscount = @Discount
              FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
             WHERE ci.srecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.Bettype = @Bettype
               AND cs.Sporttype = @Sporttype
               AND cs.sdiscount <> @Discount

			
            --At member level, update adiscount = sdiscount if adiscount > sdiscount
                
			UPDATE cs
			   SET cs.adiscount = cs.sdiscount
			  FROM dbo.CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
				INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
			 WHERE ci.srecommend = @custid
			   AND ci.roleid = 1
			   AND ci.Enabled = 1
			   AND cs.Bettype = @Bettype
			   AND cs.Sporttype = @Sporttype
			   AND cs.adiscount > cs.sdiscount


			--At member level, update discount = adiscount if discount > adiscount
			UPDATE cs
			   SET cs.discount = cs.adiscount
			  FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
				INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
			 WHERE ci.srecommend = @custid
			   AND ci.roleid = 1
			   AND ci.Enabled = 1
			   AND cs.Bettype = @Bettype
			   AND cs.Sporttype = @Sporttype 
			   AND cs.discount > cs.adiscount


			--At member level, update playerdiscount = discount  if playerdiscount > discount
			UPDATE cs
			   SET cs.playerdiscount = cs.discount 
			  FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
				INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
			 WHERE ci.srecommend = @custid
			   AND ci.roleid = 1
			   AND ci.Enabled = 1
			   AND cs.Bettype = @Bettype
			   AND cs.Sporttype = @Sporttype
			   AND cs.playerdiscount > cs.discount
			END	   
        
        
        IF @RoleId = 3
        BEGIN
            --Update @Master: g3, m3
            UPDATE dbo.CustSettingGame WITH (UPDLOCK, ROWLOCK)
               SET adiscount = @Discount
             WHERE custid = @custid AND bettype = @Bettype AND sporttype = @Sporttype AND adiscount <> @Discount

            --Update g2 = g3 if g2>g3 at agent
            UPDATE cs
               SET cs.discount = @Discount
              FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
				INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
             WHERE ci.mrecommend = @custid
               AND ci.roleid     = 2
               AND ci.Enabled    = 1
               AND cs.sporttype  = @Sporttype
               AND cs.bettype    = @Bettype
               AND cs.discount   > @Discount

            --Update g3 @ member level
            UPDATE cs
               SET cs.adiscount = @Discount
              FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
				INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @Sporttype
               AND cs.bettype = @Bettype 
                 
               AND cs.adiscount <> @Discount

			    
			--At member level, update discount = adiscount  if discount > adiscount
			UPDATE cs
			   SET cs.discount = cs.adiscount
			  FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
				INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
			 WHERE ci.mrecommend = @custid
			   AND ci.roleid = 1
			   AND ci.Enabled = 1
			   AND cs.bettype = @Bettype
			   AND cs.sporttype = @Sporttype 
			   AND cs.discount > cs.adiscount

			--At member level, update playerdiscount = discount  if playerdiscount > discount
			UPDATE cs
			   SET cs.playerdiscount = cs.discount
			  FROM dbo.CustSettingGame cs WITH (UPDLOCK, ROWLOCK)
				INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
			 WHERE ci.mrecommend = @custid
			   AND ci.roleid = 1
			   AND ci.Enabled = 1
			   AND cs.bettype = @Bettype
			   AND cs.sporttype = @Sporttype 
			   AND cs.playerdiscount > cs.discount
			
        END
        
        IF @RoleId = 2
        BEGIN
            --Update @Agent: g2, a2
            UPDATE dbo.CustSettingGame WITH (ROWLOCK, UPDLOCK)
            SET    discount = @Discount
             WHERE custid = @custid AND bettype = @Bettype AND sporttype = @Sporttype AND discount <> @Discount
				
            --Update g2, a2 at Member level
            UPDATE cs
                   SET cs.discount = @Discount
              FROM dbo.CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN dbo.custinfo c WITH(NOLOCK) ON cs.custid = c.custid
             WHERE c.recommend = @custid 
				
                AND c.roleid = 1 AND bettype = @Bettype
                AND sporttype = @Sporttype AND cs.discount <> @Discount

           
			--At member level, update playerdiscount = discount  if playerdiscount > discount
			UPDATE cs 
			   SET cs.playerdiscount = cs.discount
			  FROM dbo.CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
				INNER JOIN dbo.custinfo c WITH(NOLOCK) ON cs.custid = c.custid
			 WHERE c.recommend = @custid AND c.roleid = 1
				AND sporttype = @Sporttype AND bettype = @Bettype AND cs.playerdiscount > cs.discount 
			
        END
        
        IF @RoleId = 1 
        BEGIN            
            UPDATE CustSettingGame WITH(ROWLOCK, UPDLOCK)
            SET    playerdiscount = @Discount
             WHERE custid=@custid AND sporttype = @Sporttype AND bettype = @Bettype
				     
			
		END 
    END    
 
END
GO