
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMaster_AutoPositiontaking    Script Date: 8/21/2014 3:12:20 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMaster_AutoPositiontaking    Script Date: 8/21/2014 2:58:11 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaster_AutoPositiontaking]
    @mrecommend int,
    @srecommend int,
    @auto_spositiontaking_1 smallmoney = 0, 
    @auto_spositiontaking_2 smallmoney = 0,
    @auto_spositiontaking_3 smallmoney = 0,
    @auto_spositiontaking_4 smallmoney = 0,
    @auto_spositiontaking_5 smallmoney = 0,
    @auto_spositiontaking_6 smallmoney = 0,
    @auto_spositiontaking_7 smallmoney = 0,
    @auto_spositiontaking_8 smallmoney = 0,
    @auto_spositiontaking_9 smallmoney = 0,
    @auto_spositiontaking_10 smallmoney = 0,
    @auto_spositiontaking_9999 smallmoney = 0,
    @auto_slivepositiontaking_1 smallmoney = 0,
    @auto_slivepositiontaking_3 smallmoney = 0,
    @auto_slivepositiontaking_7 smallmoney = 0,
    @auto_slivepositiontaking_8 smallmoney = 0,
    
    @auto_v2spositiontaking_1 smallmoney = 0,
    @auto_v2spositiontaking_2 smallmoney = 0,
    @auto_v2spositiontaking_3 smallmoney = 0,
    @auto_v2spositiontaking_7 smallmoney = 0,
    @auto_v2spositiontaking_8 smallmoney = 0,
--    @auto_v2spositiontaking_9 smallmoney = 0,
    @auto_v2spositiontaking_20 smallmoney = 0,
    
    @auto_v3spositiontaking_1 smallmoney = 0,
    @auto_v3spositiontaking_2 smallmoney = 0,
    @auto_v3spositiontaking_3 smallmoney = 0,
    @auto_v3spositiontaking_20 smallmoney = 0,

    @auto_v5spositiontaking_1 smallmoney = 0,
    @auto_v5spositiontaking_2 smallmoney = 0,
    @auto_v5spositiontaking_3 smallmoney = 0,
    @auto_v5spositiontaking_20 smallmoney = 0,
    @auto_v5spositiontaking_9999 smallmoney = 0,

    @auto_v8spositiontaking_1 smallmoney = 0,
    @auto_v8spositiontaking_3 smallmoney = 0,
    @auto_v8spositiontaking_20 smallmoney = 0,

    @auto_v10spositiontaking_1 smallmoney = 0,
    @auto_v10spositiontaking_2 smallmoney = 0,
    @auto_v10spositiontaking_3 smallmoney = 0,
    @auto_v10spositiontaking_20 smallmoney = 0,

    @auto_v11spositiontaking_1 smallmoney = 0,
    @auto_v11spositiontaking_20 smallmoney = 0,

    @auto_v99spositiontaking_1 smallmoney = 0,
    @auto_v99spositiontaking_2 smallmoney = 0,
    @auto_v99spositiontaking_3 smallmoney = 0,
    @auto_v99spositiontaking_20 smallmoney = 0,

    --- mixed sports
    @auto_v99spositiontaking_9 smallmoney = 0,

    @auto_v154spositiontaking_20 smallmoney = 0,

    -- number game
    @auto_v161spositiontaking_81 smallmoney = 0,
    @auto_v161spositiontaking_83 smallmoney = 0,    
    @auto_v161spositiontaking_86 smallmoney = 0,
    @auto_v161spositiontaking_88 smallmoney = 0,
    
    @auto_v161slivepositiontaking_85 smallmoney = 0,
    @auto_v161slivepositiontaking_86 smallmoney = 0,
    @auto_v161slivepositiontaking_87 smallmoney = 0,
    @auto_v161slivepositiontaking_89 smallmoney = 0,
    @auto_v161slivepositiontaking_90 smallmoney = 0,
    
    @updatemultiple bit = 0,
    @updatepositiontaking bit = 1,
    
    @updatepositiontakingv2 bit = 1,
    @updatepositiontakingv3 bit = 1,
    @updatepositiontakingv5 bit = 1,
    @updatepositiontakingv8 bit = 1,
    @updatepositiontakingv10 bit = 1,
    @updatepositiontakingv11 bit = 1,
    @updatepositiontakingv99 bit = 1,

    -- mixed sports
    @updatepositiontakingv99mp bit = 1,
    @updatepositiontakingv154 bit = 1,
    -- number game
    @updatepositiontakingv161 bit = 1,
    

    @language varchar(2),
    @updateallmembers bit = 0,
    @newspositiontaking smallmoney,
    @userid int,
    
    @isauto_spositiontaking_1 bit = 0,
    @isauto_spositiontaking_2 bit = 0,
    @isauto_spositiontaking_3 bit = 0,
    @isauto_spositiontaking_4 bit = 0,
    @isauto_spositiontaking_5 bit= 0,
    @isauto_spositiontaking_6 bit = 0,
    @isauto_spositiontaking_7 bit = 0,
    @isauto_spositiontaking_8 bit = 0,
    @isauto_spositiontaking_9 bit = 0,
    @isauto_spositiontaking_10 bit = 0,
    @isauto_spositiontaking_9999 bit = 0,
    
    @isauto_slivepositiontaking_1 bit = 0,
    @isauto_slivepositiontaking_3 bit = 0,
    @isauto_slivepositiontaking_7 bit = 0,
    @isauto_slivepositiontaking_8 bit = 0,
    
    @isauto_v2spositiontaking_1 bit = 0,
    @isauto_v2spositiontaking_2 bit = 0,
    @isauto_v2spositiontaking_3 bit = 0,
    @isauto_v2spositiontaking_7 bit = 0,
    @isauto_v2spositiontaking_8 bit = 0,
--    @isauto_v2spositiontaking_9 bit = 0,
    @isauto_v2spositiontaking_20 bit = 0,
    
    @isauto_v3spositiontaking_1 bit = 0,
    @isauto_v3spositiontaking_2 bit = 0,
    @isauto_v3spositiontaking_3 bit = 0,
    @isauto_v3spositiontaking_20 bit = 0,

    @isauto_v5spositiontaking_1 bit = 0,
    @isauto_v5spositiontaking_2 bit = 0,
    @isauto_v5spositiontaking_3 bit = 0,
    @isauto_v5spositiontaking_20 bit = 0,
    @isauto_v5spositiontaking_9999 bit = 0,

    @isauto_v8spositiontaking_1 bit = 0,
    @isauto_v8spositiontaking_3 bit = 0,
    @isauto_v8spositiontaking_20 bit = 0,

    @isauto_v10spositiontaking_1 bit = 0,
    @isauto_v10spositiontaking_2 bit = 0,
    @isauto_v10spositiontaking_3 bit = 0,
    @isauto_v10spositiontaking_20 bit = 0,

    @isauto_v11spositiontaking_1 bit = 0,
    @isauto_v11spositiontaking_20 bit = 0,

    @isauto_v99spositiontaking_1 bit = 0,
    @isauto_v99spositiontaking_2 bit = 0,
    @isauto_v99spositiontaking_3 bit = 0,
    @isauto_v99spositiontaking_20 bit = 0,

    -- mixed sports
    @isauto_v99spositiontaking_9 bit = 0,
    
    @isauto_v154spositiontaking_20 bit = 0,
    
    -- number game    
    @isauto_v161spositiontaking_81 bit = 0,
    @isauto_v161spositiontaking_83 bit = 0,    
    @isauto_v161spositiontaking_86 bit = 0,
    @isauto_v161spositiontaking_88 bit = 0,
    @isauto_v161slivepositiontaking_85 bit = 0,
    @isauto_v161slivepositiontaking_86 bit = 0,
    @isauto_v161slivepositiontaking_87 bit = 0,
    @isauto_v161slivepositiontaking_89 bit = 0,
    @isauto_v161slivepositiontaking_90 bit = 0,
    
    -- Outright PT for sports
    
	@auto_v2spositiontaking_10 smallmoney = 0,
	@auto_v3spositiontaking_10 smallmoney = 0,
	@auto_v5spositiontaking_10 smallmoney = 0,
	@auto_v8spositiontaking_10 smallmoney = 0,
	@auto_v10spositiontaking_10 smallmoney = 0,
	@auto_v11spositiontaking_10 smallmoney = 0,
	@auto_v99spositiontaking_10 smallmoney = 0,
	
	@isauto_v2spositiontaking_10 bit = 0,
	@isauto_v3spositiontaking_10 bit = 0,
	@isauto_v5spositiontaking_10 bit = 0,
	@isauto_v8spositiontaking_10 bit = 0,
	@isauto_v10spositiontaking_10 bit = 0,
	@isauto_v11spositiontaking_10 bit = 0,
	@isauto_v99spositiontaking_10 bit = 0,
	
    @ErrCode int = 0 OUTPUT,
    @ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20080514@Thien
Task : update auto super PT at master level
DB: DBTXN/bodb02
Original: Acc_CustomerUpdAutoPositiontaking_Master

Revisions:
    - 20081023@Phuc: Add new sporttype 201, bettype 3.
    - 20090122@PhuongBich: add new sporttype 201, bettype 2.
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20100904@Lukas:    - Add number game setting
                        - Add mixed sports setting
                        - Remove mix parlay of basketball
    - 20110729@Lukas: (Number Game)
                - Add three new bettypes: Warrior, Next Combo, Number Group
                - Remove Dead ball Over/Under
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
    - 20131029@Johnson: Apply execrep when update downlines
    - 20140624@Johnson: Add bettype Others for soccer & tennis [Redmine #16903]
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/


SET NOCOUNT ON
if @updatepositiontaking = 0 and @updatepositiontakingv2 = 0 and @updatepositiontakingv3 = 0 and @updatepositiontakingv5 = 0 and @updatepositiontakingv8 = 0 and @updatepositiontakingv10 = 0 and @updatepositiontakingv11 = 0  and @updatepositiontakingv99 = 0 and @updatepositiontakingv99mp = 0 and @updatepositiontakingv154 = 0 and @updatepositiontakingv161 = 0 and @updatemultiple=1
BEGIN
    return
END

Declare
    @bettype int,
    @autopositiontaking smallmoney,
    @autolivepositiontaking smallmoney,
    @old_autopositiontaking smallmoney,
    @old_autolivepositiontaking smallmoney,

    @autov2positiontaking smallmoney,
    @autov3positiontaking smallmoney,
    @autov5positiontaking smallmoney,
    @autov8positiontaking smallmoney,
    @autov10positiontaking smallmoney,
    @autov11positiontaking smallmoney,
    @autov99positiontaking smallmoney,
        
    @autov99mppositiontaking smallmoney,
    @autov154positiontaking smallmoney,
    @autov161positiontaking smallmoney,
    @autov161livepositiontaking smallmoney,
    
    @old_autov2positiontaking smallmoney,
    @old_autov3positiontaking smallmoney,
    @old_autov5positiontaking smallmoney,
    @old_autov8positiontaking smallmoney,
    @old_autov10positiontaking smallmoney,
    @old_autov11positiontaking smallmoney,
    @old_autov99positiontaking smallmoney,

    -- mixed sports
    @old_autov99mppositiontaking smallmoney,
    @old_autov154positiontaking smallmoney,
    -- number game
    @old_autov161positiontaking smallmoney,
    @old_autov161livepositiontaking smallmoney,
    
    @maxpos smallmoney,
    @isautopositiontaking bit, 
    @isautolivepositiontaking bit, 
    
    @isautov2positiontaking bit,
    @isautov3positiontaking bit,
    @isautov5positiontaking bit,
    @isautov8positiontaking bit,
    @isautov10positiontaking bit,
    @isautov11positiontaking bit,
    @isautov99positiontaking bit,

    -- mixed sports
    @isautov99mppositiontaking bit,
    @isautov154positiontaking bit,

    -- number game
    @isautov161positiontaking bit,
    @isautov161livepositiontaking bit,
    
    @old_isautopositiontaking smallmoney, 
    @old_isautolivepositiontaking smallmoney, 
    
    @old_isautov2positiontaking smallmoney,
    @old_isautov3positiontaking smallmoney,
    @old_isautov5positiontaking smallmoney,
    @old_isautov8positiontaking smallmoney,
    @old_isautov10positiontaking smallmoney,
    @old_isautov11positiontaking smallmoney,
    @old_isautov99positiontaking smallmoney,
    
    -- mixed sports
    @old_isautov99mppositiontaking smallmoney,
    @old_isautov154positiontaking smallmoney,
    
    -- number game
    @old_isautov161positiontaking smallmoney,
    @old_isautov161livepositiontaking smallmoney
Declare 
    @old_auto_spositiontaking_1 smallmoney,
    @old_auto_spositiontaking_2 smallmoney,
    @old_auto_spositiontaking_3 smallmoney,
    @old_auto_spositiontaking_4 smallmoney,
    @old_auto_spositiontaking_5 smallmoney,
    @old_auto_spositiontaking_6 smallmoney,
    @old_auto_spositiontaking_7 smallmoney,
    @old_auto_spositiontaking_8 smallmoney,
    @old_auto_spositiontaking_9 smallmoney,
    @old_auto_spositiontaking_10 smallmoney,
    @old_auto_spositiontaking_9999 smallmoney,
    @old_auto_slivepositiontaking_1 smallmoney,
    @old_auto_slivepositiontaking_3 smallmoney,
    @old_auto_slivepositiontaking_7 smallmoney,
    @old_auto_slivepositiontaking_8 smallmoney,
    
    @old_auto_v2spositiontaking_1 smallmoney,
    @old_auto_v2spositiontaking_2 smallmoney,
    @old_auto_v2spositiontaking_3 smallmoney,
    @old_auto_v2spositiontaking_7 smallmoney,
    @old_auto_v2spositiontaking_8 smallmoney,
--    @old_auto_v2spositiontaking_9 smallmoney,
    @old_auto_v2spositiontaking_20 smallmoney,
    
    @old_auto_v3spositiontaking_1 smallmoney,
    @old_auto_v3spositiontaking_2 smallmoney,
    @old_auto_v3spositiontaking_3 smallmoney,
    @old_auto_v3spositiontaking_20 smallmoney,

    @old_auto_v5spositiontaking_1 smallmoney,
    @old_auto_v5spositiontaking_2 smallmoney,
    @old_auto_v5spositiontaking_3 smallmoney,
    @old_auto_v5spositiontaking_20 smallmoney,
    @old_auto_v5spositiontaking_9999 smallmoney,

    @old_auto_v8spositiontaking_1 smallmoney,
    @old_auto_v8spositiontaking_3 smallmoney,
    @old_auto_v8spositiontaking_20 smallmoney,

    @old_auto_v10spositiontaking_1 smallmoney,
    @old_auto_v10spositiontaking_2 smallmoney,
    @old_auto_v10spositiontaking_3 smallmoney,
    @old_auto_v10spositiontaking_20 smallmoney,

    @old_auto_v11spositiontaking_1 smallmoney,
    @old_auto_v11spositiontaking_20 smallmoney,

    @old_auto_v99spositiontaking_1 smallmoney,
    @old_auto_v99spositiontaking_2 smallmoney,
    @old_auto_v99spositiontaking_3 smallmoney,
    @old_auto_v99spositiontaking_20 smallmoney,
        
    -- mixed sports
    @old_auto_v99spositiontaking_9 smallmoney,
    @old_auto_v154spositiontaking_20 smallmoney,

    -- number game
    @old_auto_v161spositiontaking_81 smallmoney,
    @old_auto_v161spositiontaking_83 smallmoney,    
    @old_auto_v161spositiontaking_86 smallmoney,
    @old_auto_v161spositiontaking_88 smallmoney,
    @old_auto_v161slivepositiontaking_85 smallmoney,
    @old_auto_v161slivepositiontaking_86 smallmoney,
    @old_auto_v161slivepositiontaking_87 smallmoney,
    @old_auto_v161slivepositiontaking_89 smallmoney,
    @old_auto_v161slivepositiontaking_90 smallmoney,

    @old_isauto_spositiontaking_1 bit,
    @old_isauto_spositiontaking_2 bit,
    @old_isauto_spositiontaking_3 bit,
    @old_isauto_spositiontaking_4 bit,
    @old_isauto_spositiontaking_5 bit,
    @old_isauto_spositiontaking_6 bit,
    @old_isauto_spositiontaking_7 bit,
    @old_isauto_spositiontaking_8 bit,
    @old_isauto_spositiontaking_9 bit,
    @old_isauto_spositiontaking_10 bit,
    @old_isauto_spositiontaking_9999 bit,
    
    @old_isauto_slivepositiontaking_1 bit,
    @old_isauto_slivepositiontaking_3 bit,
    @old_isauto_slivepositiontaking_7 bit,
    @old_isauto_slivepositiontaking_8 bit,
    
    @old_isauto_v2spositiontaking_1 bit,
    @old_isauto_v2spositiontaking_2 bit,
    @old_isauto_v2spositiontaking_3 bit,
    @old_isauto_v2spositiontaking_7 bit,
    @old_isauto_v2spositiontaking_8 bit,
--    @old_isauto_v2spositiontaking_9 bit,
    @old_isauto_v2spositiontaking_20 bit,
    
    @old_isauto_v3spositiontaking_1 bit,
    @old_isauto_v3spositiontaking_2 bit,
    @old_isauto_v3spositiontaking_3 bit,
    @old_isauto_v3spositiontaking_20 bit,

    @old_isauto_v5spositiontaking_1 bit,
    @old_isauto_v5spositiontaking_2 bit,
    @old_isauto_v5spositiontaking_3 bit,
    @old_isauto_v5spositiontaking_20 bit,
    @old_isauto_v5spositiontaking_9999 bit,

    @old_isauto_v8spositiontaking_1 bit,
    @old_isauto_v8spositiontaking_3 bit,
    @old_isauto_v8spositiontaking_20 bit,

    @old_isauto_v10spositiontaking_1 bit,
    @old_isauto_v10spositiontaking_2 bit,
    @old_isauto_v10spositiontaking_3 bit,
    @old_isauto_v10spositiontaking_20 bit,

    @old_isauto_v11spositiontaking_1 bit,
    @old_isauto_v11spositiontaking_20 bit,

    @old_isauto_v99spositiontaking_1 bit,
    @old_isauto_v99spositiontaking_2 bit,
    @old_isauto_v99spositiontaking_3 bit,
    @old_isauto_v99spositiontaking_20 bit,

    -- mixed sports
    @old_isauto_v99spositiontaking_9 bit,
    @old_isauto_v154spositiontaking_20 bit,
    
    -- number game
    @old_isauto_v161spositiontaking_81 bit,
    @old_isauto_v161spositiontaking_83 bit,    
    @old_isauto_v161spositiontaking_86 bit,
    @old_isauto_v161spositiontaking_88 bit,
    @old_isauto_v161slivepositiontaking_85 bit,
    @old_isauto_v161slivepositiontaking_86 bit,
    @old_isauto_v161slivepositiontaking_87 bit,
    @old_isauto_v161slivepositiontaking_89 bit,
    @old_isauto_v161slivepositiontaking_90 bit,
    
    @old_auto_v2spositiontaking_10 smallmoney,
    @old_auto_v3spositiontaking_10 smallmoney,
    @old_auto_v5spositiontaking_10 smallmoney,
    @old_auto_v8spositiontaking_10 smallmoney,
    @old_auto_v10spositiontaking_10 smallmoney,
    @old_auto_v11spositiontaking_10 smallmoney,
    @old_auto_v99spositiontaking_10 smallmoney,
    
	@old_isauto_v2spositiontaking_10 bit,
	@old_isauto_v3spositiontaking_10 bit,
	@old_isauto_v5spositiontaking_10 bit,
	@old_isauto_v8spositiontaking_10 bit,
	@old_isauto_v10spositiontaking_10 bit,
	@old_isauto_v11spositiontaking_10 bit,
	@old_isauto_v99spositiontaking_10 bit

    
--------------------------------------------------------
--Get old Auto PT from Master
select     @old_auto_spositiontaking_1    =    autopositiontaking        ,    @old_isauto_spositiontaking_1    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    1
select     @old_auto_spositiontaking_2    =    autopositiontaking        ,    @old_isauto_spositiontaking_2    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    2
select     @old_auto_spositiontaking_3    =    autopositiontaking        ,    @old_isauto_spositiontaking_3    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    3
select     @old_auto_spositiontaking_4    =    autopositiontaking        ,    @old_isauto_spositiontaking_4    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    4
select     @old_auto_spositiontaking_5    =    autopositiontaking        ,    @old_isauto_spositiontaking_5    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    5
select     @old_auto_spositiontaking_6    =    autopositiontaking        ,    @old_isauto_spositiontaking_6    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    6
select     @old_auto_spositiontaking_7    =    autopositiontaking        ,    @old_isauto_spositiontaking_7    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    7
select     @old_auto_spositiontaking_8    =    autopositiontaking        ,    @old_isauto_spositiontaking_8    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    8
select     @old_auto_spositiontaking_9    =    autopositiontaking        ,    @old_isauto_spositiontaking_9    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    9
select     @old_auto_spositiontaking_10    =    autopositiontaking        ,    @old_isauto_spositiontaking_10    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    10

-- Outright PT for sports
select     @old_auto_v2spositiontaking_10    =    autopositiontaking        ,    @old_isauto_v2spositiontaking_10    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    2    and bettype=    10
select     @old_auto_v3spositiontaking_10    =    autopositiontaking        ,    @old_isauto_v3spositiontaking_10    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    3    and bettype=    10
select     @old_auto_v5spositiontaking_10    =    autopositiontaking        ,    @old_isauto_v5spositiontaking_10    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    5    and bettype=    10
select     @old_auto_v8spositiontaking_10    =    autopositiontaking        ,    @old_isauto_v8spositiontaking_10    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    8    and bettype=    10
select     @old_auto_v10spositiontaking_10    =    autopositiontaking        ,    @old_isauto_v10spositiontaking_10    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =  10    and bettype=    10
select     @old_auto_v11spositiontaking_10    =    autopositiontaking        ,    @old_isauto_v11spositiontaking_10    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =  11    and bettype=    10
select     @old_auto_v99spositiontaking_10    =    autopositiontaking        ,    @old_isauto_v99spositiontaking_10    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =  99    and bettype=    10


select     @old_auto_spositiontaking_9999    =    autopositiontaking        ,    @old_isauto_spositiontaking_9999    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    9999
select     @old_auto_slivepositiontaking_1    =    autolivepositiontaking        ,    @old_isauto_slivepositiontaking_1    =    isautolivepositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    1
select     @old_auto_slivepositiontaking_3    =    autolivepositiontaking        ,    @old_isauto_slivepositiontaking_3    =    isautolivepositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    3
select     @old_auto_slivepositiontaking_7    =    autolivepositiontaking        ,    @old_isauto_slivepositiontaking_7    =    isautolivepositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    7
select     @old_auto_slivepositiontaking_8    =    autolivepositiontaking        ,    @old_isauto_slivepositiontaking_8    =    isautolivepositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype =    1    and bettype=    8

select     @old_auto_v2spositiontaking_1    =    autopositiontaking        ,    @old_isauto_v2spositiontaking_1    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=2    and bettype=    1
select     @old_auto_v2spositiontaking_2    =    autopositiontaking        ,    @old_isauto_v2spositiontaking_2    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=2    and bettype=    2
select     @old_auto_v2spositiontaking_3    =    autopositiontaking        ,    @old_isauto_v2spositiontaking_3    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=2    and bettype=    3
select     @old_auto_v2spositiontaking_7    =    autopositiontaking        ,    @old_isauto_v2spositiontaking_7    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=2    and bettype=    7
select     @old_auto_v2spositiontaking_8    =    autopositiontaking        ,    @old_isauto_v2spositiontaking_8    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=2    and bettype=    8
--select     @old_auto_v2spositiontaking_9    =    autopositiontaking        ,    @old_isauto_v2spositiontaking_9    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=2    and bettype=    9
select     @old_auto_v2spositiontaking_20    =    autopositiontaking        ,    @old_isauto_v2spositiontaking_20    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=2    and bettype=    20

select     @old_auto_v3spositiontaking_1    =    autopositiontaking        ,    @old_isauto_v3spositiontaking_1    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=3    and bettype=    1
select     @old_auto_v3spositiontaking_2    =    autopositiontaking        ,    @old_isauto_v3spositiontaking_2    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=3    and bettype=    2
select     @old_auto_v3spositiontaking_3    =    autopositiontaking        ,    @old_isauto_v3spositiontaking_3    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=3    and bettype=    3
select     @old_auto_v3spositiontaking_20    =    autopositiontaking        ,    @old_isauto_v3spositiontaking_20    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=3    and bettype=    20

select     @old_auto_v5spositiontaking_1    =    autopositiontaking        ,    @old_isauto_v5spositiontaking_1    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=5    and bettype=    1
select     @old_auto_v5spositiontaking_2    =    autopositiontaking        ,    @old_isauto_v5spositiontaking_2    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=5    and bettype=    2
select     @old_auto_v5spositiontaking_3    =    autopositiontaking        ,    @old_isauto_v5spositiontaking_3    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=5    and bettype=    3
select     @old_auto_v5spositiontaking_20    =    autopositiontaking        ,    @old_isauto_v5spositiontaking_20    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=5    and bettype=    20
select     @old_auto_v5spositiontaking_9999    =    autopositiontaking        ,    @old_isauto_v5spositiontaking_9999    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=5    and bettype=    9999

select     @old_auto_v8spositiontaking_1    =    autopositiontaking        ,    @old_isauto_v8spositiontaking_1    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=8    and bettype=    1
select     @old_auto_v8spositiontaking_3    =    autopositiontaking        ,    @old_isauto_v8spositiontaking_3    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=8    and bettype=    3
select     @old_auto_v8spositiontaking_20    =    autopositiontaking        ,    @old_isauto_v8spositiontaking_20    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=8    and bettype=    20

select     @old_auto_v10spositiontaking_1    =    autopositiontaking        ,    @old_isauto_v10spositiontaking_1    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=10    and bettype=    1
select     @old_auto_v10spositiontaking_2    =    autopositiontaking        ,    @old_isauto_v10spositiontaking_2    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=10    and bettype=    2
select     @old_auto_v10spositiontaking_3    =    autopositiontaking        ,    @old_isauto_v10spositiontaking_3    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=10    and bettype=    3
select     @old_auto_v10spositiontaking_20    =    autopositiontaking        ,    @old_isauto_v10spositiontaking_20    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=10    and bettype=    20

select     @old_auto_v11spositiontaking_1    =    autopositiontaking        ,    @old_isauto_v11spositiontaking_1    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=11    and bettype=    1
select     @old_auto_v11spositiontaking_20    =    autopositiontaking        ,    @old_isauto_v11spositiontaking_20    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=11    and bettype=    20

select     @old_auto_v99spositiontaking_1    =    autopositiontaking        ,    @old_isauto_v99spositiontaking_1    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=99    and bettype=    1
select     @old_auto_v99spositiontaking_2    =    autopositiontaking        ,    @old_isauto_v99spositiontaking_2    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=99    and bettype=    2
select     @old_auto_v99spositiontaking_3    =    autopositiontaking        ,    @old_isauto_v99spositiontaking_3    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=99    and bettype=    3
select     @old_auto_v99spositiontaking_20    =    autopositiontaking        ,    @old_isauto_v99spositiontaking_20    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=99    and bettype=    20
--mixed sports
select     @old_auto_v99spositiontaking_9    =    autopositiontaking        ,    @old_isauto_v99spositiontaking_9    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=99    and bettype=    9

select     @old_auto_v154spositiontaking_20    =    autopositiontaking        ,    @old_isauto_v154spositiontaking_20    =    isautopositiontaking        from custsetting with (nolock) where custid = @mrecommend and sporttype=154    and bettype=    20

-- number game
select     @old_auto_v161spositiontaking_81    =    autopositiontaking        ,    @old_isauto_v161spositiontaking_81    =    isautopositiontaking        from custsetting3rd with (nolock) where custid = @mrecommend and sporttype=161    and bettype=    81
select     @old_auto_v161spositiontaking_83    =    autopositiontaking        ,    @old_isauto_v161spositiontaking_83    =    isautopositiontaking        from custsetting3rd with (nolock) where custid = @mrecommend and sporttype=161    and bettype=    83
select     @old_auto_v161spositiontaking_86    =    autopositiontaking        ,    @old_isauto_v161spositiontaking_86    =    isautopositiontaking        from custsetting3rd with (nolock) where custid = @mrecommend and sporttype=161    and bettype=    86
select     @old_auto_v161spositiontaking_88    =    autopositiontaking        ,    @old_isauto_v161spositiontaking_88    =    isautopositiontaking        from custsetting3rd with (nolock) where custid = @mrecommend and sporttype=161    and bettype=    88
select     @old_auto_v161slivepositiontaking_85    =    autolivepositiontaking        ,    @old_isauto_v161slivepositiontaking_85    =    isautolivepositiontaking        from custsetting3rd with (nolock) where custid = @mrecommend and sporttype =    161    and bettype=    85
select     @old_auto_v161slivepositiontaking_86    =    autolivepositiontaking        ,    @old_isauto_v161slivepositiontaking_86    =    isautolivepositiontaking        from custsetting3rd with (nolock) where custid = @mrecommend and sporttype =    161    and bettype=    86
select     @old_auto_v161slivepositiontaking_87    =    autolivepositiontaking        ,    @old_isauto_v161slivepositiontaking_87    =    isautolivepositiontaking        from custsetting3rd with (nolock) where custid = @mrecommend and sporttype =    161    and bettype=    87
select     @old_auto_v161slivepositiontaking_89    =    autolivepositiontaking        ,    @old_isauto_v161slivepositiontaking_89    =    isautolivepositiontaking        from custsetting3rd with (nolock) where custid = @mrecommend and sporttype =    161    and bettype=    89
select     @old_auto_v161slivepositiontaking_90    =    autolivepositiontaking        ,    @old_isauto_v161slivepositiontaking_90    =    isautolivepositiontaking        from custsetting3rd with (nolock) where custid = @mrecommend and sporttype =    161    and bettype=    90



if @updatepositiontaking = 1 or @updatemultiple=0
BEGIN
    --Update Master Agent account (autopositiontaking field)
    --For Football
    update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
    from custsetting inner join 
            (
                        select 1 as bettype, @auto_spositiontaking_1 as autopositiontaking, @auto_slivepositiontaking_1    as autolivepositiontaking, @isauto_spositiontaking_1 as isautopositiontaking, @isauto_slivepositiontaking_1    as isautolivepositiontaking
                union all     select 2 as bettype, @auto_spositiontaking_2 as autopositiontaking, 0                as autolivepositiontaking, @isauto_spositiontaking_2 as isautopositiontaking, 0                as isautolivepositiontaking
                union all     select 3 as bettype, @auto_spositiontaking_3 as autopositiontaking, @auto_slivepositiontaking_3     as autolivepositiontaking, @isauto_spositiontaking_3 as isautopositiontaking, @isauto_slivepositiontaking_3    as isautolivepositiontaking
                union all     select 4 as bettype, @auto_spositiontaking_4 as autopositiontaking, 0                as autolivepositiontaking, @isauto_spositiontaking_4 as isautopositiontaking, 0                as isautolivepositiontaking
                union all     select 5 as bettype, @auto_spositiontaking_5 as autopositiontaking, 0                as autolivepositiontaking, @isauto_spositiontaking_5 as isautopositiontaking, 0                as isautolivepositiontaking
                union all     select 6 as bettype, @auto_spositiontaking_6 as autopositiontaking, 0                as autolivepositiontaking, @isauto_spositiontaking_6 as isautopositiontaking, 0                as isautolivepositiontaking
                union all     select 7 as bettype, @auto_spositiontaking_7 as autopositiontaking, @auto_slivepositiontaking_7     as autolivepositiontaking, @isauto_spositiontaking_7 as isautopositiontaking, @isauto_slivepositiontaking_7    as isautolivepositiontaking
                union all     select 8 as bettype, @auto_spositiontaking_8 as autopositiontaking, @auto_slivepositiontaking_8     as autolivepositiontaking, @isauto_spositiontaking_8 as isautopositiontaking, @isauto_slivepositiontaking_8    as isautolivepositiontaking            
                union all     select 9 as bettype, @auto_spositiontaking_9 as autopositiontaking, 0                as autolivepositiontaking, @isauto_spositiontaking_9 as isautopositiontaking, 0                as isautolivepositiontaking
                union all     select 10 as bettype, @auto_spositiontaking_10 as autopositiontaking, 0                as autolivepositiontaking, @isauto_spositiontaking_10 as isautopositiontaking, 0                as isautolivepositiontaking
                union all     select 9999 as bettype, @auto_spositiontaking_9999 as autopositiontaking, 0                as autolivepositiontaking, @isauto_spositiontaking_9999 as isautopositiontaking, 0                as isautolivepositiontaking
            ) as b on b.bettype = custsetting.bettype
    where custsetting.custid = @mrecommend and custsetting.sporttype=1
    if @@Error <> 0
    BEGIN
        
        SELECT @ErrMsg =  
            case @Language 
                when 'E' then 'Error updating auto position taking (for Soccer)'
                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
            end    
            ,  @ErrCode=201
        return
    END
END
if (@updatepositiontakingv2 = 1 or @updatemultiple=0)
BEGIN
    --Update Master Agent account
    --For Basketball
    update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
    from custsetting inner join 
            (
                        select 1 as bettype, @auto_v2spositiontaking_1 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v2spositiontaking_1 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 2 as bettype, @auto_v2spositiontaking_2 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v2spositiontaking_2 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 3 as bettype, @auto_v2spositiontaking_3 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v2spositiontaking_3 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 7 as bettype, @auto_v2spositiontaking_7 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v2spositiontaking_7 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 8 as bettype, @auto_v2spositiontaking_8 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v2spositiontaking_8 as isautopositiontaking, 0    as isautolivepositiontaking
--                union all     select 9 as bettype, @auto_v2spositiontaking_9 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v2spositiontaking_9 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 20 as bettype, @auto_v2spositiontaking_20 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v2spositiontaking_20 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 10 as bettype, @auto_v2spositiontaking_10 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v2spositiontaking_10 as isautopositiontaking, 0    as isautolivepositiontaking
            
            ) as b on b.bettype = custsetting.bettype
    where custsetting.custid = @mrecommend and custsetting.sporttype=2
    if @@Error <> 0
    BEGIN
        
        SELECT @ErrMsg =  
            case @Language 
                when 'E' then 'Error updating auto position taking (for Basketball)'
                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
            end    
            ,  @ErrCode=202
        return
    END
END

if (@updatepositiontakingv3 = 1 or @updatemultiple=0)
BEGIN
    --Update Master Agent account
    --For Football
    update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
    from custsetting inner join 
            (
                        select 1 as bettype, @auto_v3spositiontaking_1 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v3spositiontaking_1 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 2 as bettype, @auto_v3spositiontaking_2 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v3spositiontaking_2 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 3 as bettype, @auto_v3spositiontaking_3 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v3spositiontaking_3 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 20 as bettype, @auto_v3spositiontaking_20 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v3spositiontaking_20 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 10 as bettype, @auto_v3spositiontaking_10 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v3spositiontaking_10 as isautopositiontaking, 0    as isautolivepositiontaking
                
            ) as b on b.bettype = custsetting.bettype
    where custsetting.custid = @mrecommend and custsetting.sporttype=3
    if @@Error <> 0
    BEGIN
        
        SELECT @ErrMsg =  
            case @Language 
                when 'E' then 'Error updating auto position taking (for Football)'
                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
            end    
            ,  @ErrCode=203
        return
    END
END

if (@updatepositiontakingv5 = 1 or @updatemultiple=0)
BEGIN
    --Update Master Agent account
    --For Tennis
    update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
    from custsetting inner join 
            (
                        select 1 as bettype, @auto_v5spositiontaking_1 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v5spositiontaking_1 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 2 as bettype, @auto_v5spositiontaking_2 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v5spositiontaking_2 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 3 as bettype, @auto_v5spositiontaking_3 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v5spositiontaking_3 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 20 as bettype, @auto_v5spositiontaking_20 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v5spositiontaking_20 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 9999 as bettype, @auto_v5spositiontaking_9999 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v5spositiontaking_9999 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 10 as bettype, @auto_v5spositiontaking_10 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v5spositiontaking_10 as isautopositiontaking, 0    as isautolivepositiontaking
                
            ) as b on b.bettype = custsetting.bettype
    where custsetting.custid = @mrecommend and custsetting.sporttype=5
    if @@Error <> 0
    BEGIN
        
        SELECT @ErrMsg =  
            case @Language 
                when 'E' then 'Error updating auto position taking (for Tennis)'
                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
            end    
            ,  @ErrCode=204
        return
    END
END

if (@updatepositiontakingv8 = 1 or @updatemultiple=0)
BEGIN
    --Update Master Agent account
    --For Baseball
    update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
    from custsetting inner join 
            (
                        select 1 as bettype, @auto_v8spositiontaking_1 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v8spositiontaking_1 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 3 as bettype, @auto_v8spositiontaking_3 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v8spositiontaking_3 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 20 as bettype, @auto_v8spositiontaking_20 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v8spositiontaking_20 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 10 as bettype, @auto_v8spositiontaking_10 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v8spositiontaking_10 as isautopositiontaking, 0    as isautolivepositiontaking
            ) as b on b.bettype = custsetting.bettype
    where custsetting.custid = @mrecommend and custsetting.sporttype=8
    if @@Error <> 0
    BEGIN
        
        SELECT @ErrMsg =  
            case @Language 
                when 'E' then 'Error updating auto position taking (for Baseball)'
                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
            end    
            ,  @ErrCode=205
        return
    END
END

if (@updatepositiontakingv10 = 1 or @updatemultiple=0)
BEGIN
    --Update Master Agent account
    --For Golf
    update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
    from custsetting inner join 
            (
                        select 1 as bettype, @auto_v10spositiontaking_1 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v10spositiontaking_1 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 2 as bettype, @auto_v10spositiontaking_2 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v10spositiontaking_2 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 3 as bettype, @auto_v10spositiontaking_3 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v10spositiontaking_3 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 20 as bettype, @auto_v10spositiontaking_20 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v10spositiontaking_20 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 10 as bettype, @auto_v10spositiontaking_10 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v10spositiontaking_10 as isautopositiontaking, 0    as isautolivepositiontaking
            ) as b on b.bettype = custsetting.bettype
    where custsetting.custid = @mrecommend and custsetting.sporttype=10
    if @@Error <> 0
    BEGIN
        
        SELECT @ErrMsg =  
            case @Language 
                when 'E' then 'Error updating auto position taking (for Golf)'
                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
            end    
            ,  @ErrCode=206
        return
    END
END

if (@updatepositiontakingv11 = 1 or @updatemultiple=0)
BEGIN
    --Update Master Agent account
    --For Motorsports
    update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
    from custsetting inner join 
            (
                        select 1 as bettype, @auto_v11spositiontaking_1 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v11spositiontaking_1 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 20 as bettype, @auto_v11spositiontaking_20 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v11spositiontaking_20 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 10 as bettype, @auto_v11spositiontaking_10 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v11spositiontaking_10 as isautopositiontaking, 0    as isautolivepositiontaking
            ) as b on b.bettype = custsetting.bettype
    where custsetting.custid = @mrecommend and custsetting.sporttype=11
    if @@Error <> 0
    BEGIN
        
        SELECT @ErrMsg =  
            case @Language 
                when 'E' then 'Error updating auto position taking (for Motorsports)'
                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
            end    
            ,  @ErrCode=207
        return
    END
END

if (@updatepositiontakingv99 = 1 or @updatemultiple=0)
BEGIN
    --Update Master Agent account
    --For Other sports
    update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
    from custsetting inner join 
            (
                        select 1 as bettype, @auto_v99spositiontaking_1 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v99spositiontaking_1 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 2 as bettype, @auto_v99spositiontaking_2 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v99spositiontaking_2 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 3 as bettype, @auto_v99spositiontaking_3 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v99spositiontaking_3 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 20 as bettype, @auto_v99spositiontaking_20 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v99spositiontaking_20 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 10 as bettype, @auto_v99spositiontaking_10 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v99spositiontaking_10 as isautopositiontaking, 0    as isautolivepositiontaking
            ) as b on b.bettype = custsetting.bettype
    where custsetting.custid = @mrecommend and custsetting.sporttype=99
    if @@Error <> 0
    BEGIN
        
        SELECT @ErrMsg =  
            case @Language 
                when 'E' then 'Error updating auto position taking (for Other sports)'
                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
            end    
            ,  @ErrCode=208
        return
    END
END

-- mixed sports
if (@updatepositiontakingv99mp = 1 or @updatemultiple=0)
BEGIN
    --Update Master Agent account
    --For Mixed Sports
    update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
    from custsetting inner join 
            (
                select 9 as bettype, @auto_v99spositiontaking_9 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v99spositiontaking_9 as isautopositiontaking, 0    as isautolivepositiontaking                
            ) as b on b.bettype = custsetting.bettype
    where custsetting.custid = @mrecommend and custsetting.sporttype=99
    if @@Error <> 0
    BEGIN
        
        SELECT @ErrMsg =  
            case @Language 
                when 'E' then 'Error updating auto position taking (for Mix Sports Parlay)'
                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + case @Language 
                                                                                when 'CS' then N'(供混合体育过关)'
                                                                                when 'CT' then N'(供混合體育過關)'
                                                                                when 'TH' then N'(สำหรับกีฬาบอลชุด)'
                                                                                when 'J' then N'(Mix Sports Parlay)'
                                                                                when 'KO' then N'(Mix Sports Parlay)'
                                                                                when 'VI' then N'(Mix Sports Parlay)'
                                                                                else N'(Mix Sports Parlay)' END
            end    
            ,  @ErrCode=301
        return
    END
END

if (@updatepositiontakingv154 = 1 or @updatemultiple=0)
BEGIN
    --Update Master Agent account
    --For Motorsports
    update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
    from custsetting inner join 
            (
                        select 20 as bettype, @auto_v154spositiontaking_20 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v154spositiontaking_20 as isautopositiontaking, 0    as isautolivepositiontaking
            ) as b on b.bettype = custsetting.bettype
    where custsetting.custid = @mrecommend and custsetting.sporttype=154
    if @@Error <> 0
    BEGIN
        
        SELECT @ErrMsg =  
            case @Language 
                when 'E' then 'Error updating auto position taking (for HR Fixed Odds)'
                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
            end    
            ,  @ErrCode=207
        return
    END
END

-- number game
if (@updatepositiontakingv161 = 1 or @updatemultiple=0)
BEGIN
    --Update Master Agent account
    --For Number game
    update cs with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
    from custsetting3rd cs inner join 
            (
                            select 81 as bettype, @auto_v161spositiontaking_81 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v161spositiontaking_81 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 83 as bettype, @auto_v161spositiontaking_83 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v161spositiontaking_83 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 88 as bettype, @auto_v161spositiontaking_88 as autopositiontaking, 0    as autolivepositiontaking, @isauto_v161spositiontaking_88 as isautopositiontaking, 0    as isautolivepositiontaking
                union all     select 85 as bettype, 0 as autopositiontaking, @auto_v161slivepositiontaking_85     as autolivepositiontaking, 0 as isautopositiontaking, @isauto_v161slivepositiontaking_85    as isautolivepositiontaking
                union all     select 86 as bettype, @auto_v161spositiontaking_86 as autopositiontaking, @auto_v161slivepositiontaking_86     as autolivepositiontaking, @isauto_v161spositiontaking_86 as isautopositiontaking, @isauto_v161slivepositiontaking_86    as isautolivepositiontaking
                union all     select 87 as bettype, 0 as autopositiontaking, @auto_v161slivepositiontaking_87     as autolivepositiontaking, 0 as isautopositiontaking, @isauto_v161slivepositiontaking_87    as isautolivepositiontaking
                union all     select 89 as bettype, 0 as autopositiontaking, @auto_v161slivepositiontaking_89     as autolivepositiontaking, 0 as isautopositiontaking, @isauto_v161slivepositiontaking_89    as isautolivepositiontaking
                union all     select 90 as bettype, 0 as autopositiontaking, @auto_v161slivepositiontaking_90     as autolivepositiontaking, 0 as isautopositiontaking, @isauto_v161slivepositiontaking_90    as isautolivepositiontaking

            ) as b on b.bettype = cs.bettype
    where cs.custid = @mrecommend and cs.sporttype=161
    if @@Error <> 0
    BEGIN
        
        SELECT @ErrMsg =  
            case @Language 
                when 'E' then 'Error updating auto position taking (For Number game)'
                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
            end    
            ,  @ErrCode=302
        return
    END
END

EXEC Acc_CustSetting_05
    @srecommend = @srecommend,
    @mrecommend = @mrecommend,    
    @roleid = 3,
    @isauto_spositiontaking_1 = @isauto_spositiontaking_1, 
    @isauto_spositiontaking_2 = @isauto_spositiontaking_2,
    @isauto_spositiontaking_3 = @isauto_spositiontaking_3,
    @isauto_spositiontaking_4 = @isauto_spositiontaking_4,
    @isauto_spositiontaking_5 = @isauto_spositiontaking_5,
    @isauto_spositiontaking_6 = @isauto_spositiontaking_6, 
    @isauto_spositiontaking_7 = @isauto_spositiontaking_7, 
    @isauto_spositiontaking_8 = @isauto_spositiontaking_8, 
    @isauto_spositiontaking_9 = @isauto_spositiontaking_9,  
    @isauto_spositiontaking_10 = @isauto_spositiontaking_10,
    @isauto_spositiontaking_9999 = @isauto_spositiontaking_9999,   
    @isauto_slivepositiontaking_1 = @isauto_slivepositiontaking_1, 
    @isauto_slivepositiontaking_3 = @isauto_slivepositiontaking_3, 
    @isauto_slivepositiontaking_7 = @isauto_slivepositiontaking_7, 
    @isauto_slivepositiontaking_8 = @isauto_slivepositiontaking_8, 
    
    @isauto_v2spositiontaking_1 = @isauto_v2spositiontaking_1,
    @isauto_v2spositiontaking_2 = @isauto_v2spositiontaking_2,
    @isauto_v2spositiontaking_3 = @isauto_v2spositiontaking_3,
    @isauto_v2spositiontaking_7 = @isauto_v2spositiontaking_7,
    @isauto_v2spositiontaking_8 = @isauto_v2spositiontaking_8,
    @isauto_v2spositiontaking_20 = @isauto_v2spositiontaking_20,
    
    @isauto_v3spositiontaking_1 = @isauto_v3spositiontaking_1,
    @isauto_v3spositiontaking_2 = @isauto_v3spositiontaking_2,
    @isauto_v3spositiontaking_3 = @isauto_v3spositiontaking_3,
    @isauto_v3spositiontaking_20 = @isauto_v3spositiontaking_20,

    @isauto_v5spositiontaking_1 = @isauto_v5spositiontaking_1,
    @isauto_v5spositiontaking_2 = @isauto_v5spositiontaking_2,
    @isauto_v5spositiontaking_3 = @isauto_v5spositiontaking_3,
    @isauto_v5spositiontaking_20 = @isauto_v5spositiontaking_20,
    @isauto_v5spositiontaking_9999 = @isauto_v5spositiontaking_9999,

    @isauto_v8spositiontaking_1 = @isauto_v8spositiontaking_1,
    @isauto_v8spositiontaking_3 = @isauto_v8spositiontaking_3,
    @isauto_v8spositiontaking_20 = @isauto_v8spositiontaking_20,

    @isauto_v10spositiontaking_1 = @isauto_v10spositiontaking_1,
    @isauto_v10spositiontaking_2 = @isauto_v10spositiontaking_2,
    @isauto_v10spositiontaking_3 = @isauto_v10spositiontaking_3,
    @isauto_v10spositiontaking_20 = @isauto_v10spositiontaking_20,

    @isauto_v11spositiontaking_1 = @isauto_v11spositiontaking_1,
    @isauto_v11spositiontaking_20 = @isauto_v11spositiontaking_20,

    @isauto_v99spositiontaking_1 = @isauto_v99spositiontaking_1,
    @isauto_v99spositiontaking_2 = @isauto_v99spositiontaking_2,
    @isauto_v99spositiontaking_3 = @isauto_v99spositiontaking_3,
    @isauto_v99spositiontaking_20 = @isauto_v99spositiontaking_20,

    -- mixed sports
    @isauto_v99spositiontaking_9 = @isauto_v99spositiontaking_9,
    @isauto_v154spositiontaking_20 = @isauto_v154spositiontaking_20,
    
    @old_isauto_spositiontaking_1 = @old_isauto_spositiontaking_1, 
    @old_isauto_spositiontaking_2 = @old_isauto_spositiontaking_2, 
    @old_isauto_spositiontaking_3 = @old_isauto_spositiontaking_3,
    @old_isauto_spositiontaking_4 = @old_isauto_spositiontaking_4, 
    @old_isauto_spositiontaking_5 = @old_isauto_spositiontaking_5, 
    @old_isauto_spositiontaking_6 = @old_isauto_spositiontaking_6, 
    @old_isauto_spositiontaking_7 = @old_isauto_spositiontaking_7, 
    @old_isauto_spositiontaking_8 = @old_isauto_spositiontaking_8, 
    @old_isauto_spositiontaking_9 = @old_isauto_spositiontaking_9,  
    @old_isauto_spositiontaking_10 = @old_isauto_spositiontaking_10, 
    @old_isauto_spositiontaking_9999 = @old_isauto_spositiontaking_9999,
    @old_isauto_slivepositiontaking_1 = @old_isauto_slivepositiontaking_1, 
    @old_isauto_slivepositiontaking_3 = @old_isauto_slivepositiontaking_3, 
    @old_isauto_slivepositiontaking_7 = @old_isauto_slivepositiontaking_7, 
    @old_isauto_slivepositiontaking_8 = @old_isauto_slivepositiontaking_8, 
    
    @old_isauto_v2spositiontaking_1 = @old_isauto_v2spositiontaking_1,
    @old_isauto_v2spositiontaking_2 = @old_isauto_v2spositiontaking_2,
    @old_isauto_v2spositiontaking_3 = @old_isauto_v2spositiontaking_3,
    @old_isauto_v2spositiontaking_7 = @old_isauto_v2spositiontaking_7,
    @old_isauto_v2spositiontaking_8 = @old_isauto_v2spositiontaking_8,
    @old_isauto_v2spositiontaking_20 = @old_isauto_v2spositiontaking_20,
    
    @old_isauto_v3spositiontaking_1 = @old_isauto_v3spositiontaking_1,
    @old_isauto_v3spositiontaking_2 = @old_isauto_v3spositiontaking_2,
    @old_isauto_v3spositiontaking_3 = @old_isauto_v3spositiontaking_3,
    @old_isauto_v3spositiontaking_20 = @old_isauto_v3spositiontaking_20,

    @old_isauto_v5spositiontaking_1 = @old_isauto_v5spositiontaking_1,
    @old_isauto_v5spositiontaking_2 = @old_isauto_v5spositiontaking_2,
    @old_isauto_v5spositiontaking_3 = @old_isauto_v5spositiontaking_3,
    @old_isauto_v5spositiontaking_20 = @old_isauto_v5spositiontaking_20,
    @old_isauto_v5spositiontaking_9999 = @old_isauto_v5spositiontaking_9999,

    @old_isauto_v8spositiontaking_1 = @old_isauto_v8spositiontaking_1,
    @old_isauto_v8spositiontaking_3 = @old_isauto_v8spositiontaking_3,
    @old_isauto_v8spositiontaking_20 = @old_isauto_v8spositiontaking_20,

    @old_isauto_v10spositiontaking_1 = @old_isauto_v10spositiontaking_1,
    @old_isauto_v10spositiontaking_2 = @old_isauto_v10spositiontaking_2,
    @old_isauto_v10spositiontaking_3 = @old_isauto_v10spositiontaking_3,
    @old_isauto_v10spositiontaking_20 = @old_isauto_v10spositiontaking_20,

    @old_isauto_v11spositiontaking_1 = @old_isauto_v11spositiontaking_1,
    @old_isauto_v11spositiontaking_20 = @old_isauto_v11spositiontaking_20,

    @old_isauto_v99spositiontaking_1 = @old_isauto_v99spositiontaking_1,
    @old_isauto_v99spositiontaking_2 = @old_isauto_v99spositiontaking_2,
    @old_isauto_v99spositiontaking_3 = @old_isauto_v99spositiontaking_3,
    @old_isauto_v99spositiontaking_20 = @old_isauto_v99spositiontaking_20,

    -- mixed sports
    @old_isauto_v99spositiontaking_9 = @old_isauto_v99spositiontaking_9,
    @old_isauto_v154spositiontaking_20 = @old_isauto_v154spositiontaking_20,
    
    @auto_spositiontaking_1 = @auto_spositiontaking_1, 
    @auto_spositiontaking_2 = @auto_spositiontaking_2,
    @auto_spositiontaking_3 = @auto_spositiontaking_3,
    @auto_spositiontaking_4 = @auto_spositiontaking_4,
    @auto_spositiontaking_5 = @auto_spositiontaking_5,
    @auto_spositiontaking_6 = @auto_spositiontaking_6,
    @auto_spositiontaking_7 = @auto_spositiontaking_7,
    @auto_spositiontaking_8 = @auto_spositiontaking_8,
    @auto_spositiontaking_9 = @auto_spositiontaking_9,
    @auto_spositiontaking_10 = @auto_spositiontaking_10,
    @auto_spositiontaking_9999 = @auto_spositiontaking_9999,
    @auto_slivepositiontaking_1 = @auto_slivepositiontaking_1,
    @auto_slivepositiontaking_3 = @auto_slivepositiontaking_3,
    @auto_slivepositiontaking_7 = @auto_slivepositiontaking_7,
    @auto_slivepositiontaking_8 = @auto_slivepositiontaking_8,
    
    @auto_v2spositiontaking_1 = @auto_v2spositiontaking_1,
    @auto_v2spositiontaking_2 = @auto_v2spositiontaking_2,
    @auto_v2spositiontaking_3 = @auto_v2spositiontaking_3,
    @auto_v2spositiontaking_7 = @auto_v2spositiontaking_7,
    @auto_v2spositiontaking_8 = @auto_v2spositiontaking_8,
--    @auto_v2spositiontaking_9 = @auto_v2spositiontaking_9,
    @auto_v2spositiontaking_20 = @auto_v2spositiontaking_20,
    
    @auto_v3spositiontaking_1 = @auto_v3spositiontaking_1,
    @auto_v3spositiontaking_2 = @auto_v3spositiontaking_2,
    @auto_v3spositiontaking_3 = @auto_v3spositiontaking_3,
    @auto_v3spositiontaking_20 = @auto_v3spositiontaking_20,

    @auto_v5spositiontaking_1 = @auto_v5spositiontaking_1,
    @auto_v5spositiontaking_2 = @auto_v5spositiontaking_2,
    @auto_v5spositiontaking_3 = @auto_v5spositiontaking_3,
    @auto_v5spositiontaking_20 = @auto_v5spositiontaking_20,
    @auto_v5spositiontaking_9999 = @auto_v5spositiontaking_9999,

    @auto_v8spositiontaking_1 = @auto_v8spositiontaking_1,
    @auto_v8spositiontaking_3 = @auto_v8spositiontaking_3,
    @auto_v8spositiontaking_20 = @auto_v8spositiontaking_20,

    @auto_v10spositiontaking_1 = @auto_v10spositiontaking_1,
    @auto_v10spositiontaking_2 = @auto_v10spositiontaking_2,
    @auto_v10spositiontaking_3 = @auto_v10spositiontaking_3,
    @auto_v10spositiontaking_20 = @auto_v10spositiontaking_20,

    @auto_v11spositiontaking_1 = @auto_v11spositiontaking_1,
    @auto_v11spositiontaking_20 = @auto_v11spositiontaking_20,

    @auto_v99spositiontaking_1 = @auto_v99spositiontaking_1,
    @auto_v99spositiontaking_2 = @auto_v99spositiontaking_2,
    @auto_v99spositiontaking_3 = @auto_v99spositiontaking_3,
    @auto_v99spositiontaking_20 = @auto_v99spositiontaking_20,

    --- mixed sports
    @auto_v99spositiontaking_9 = @auto_v99spositiontaking_9,
    @auto_v154spositiontaking_20 = @auto_v154spositiontaking_20,

    @old_auto_spositiontaking_1 = @old_auto_spositiontaking_1, 
    @old_auto_spositiontaking_2 = @old_auto_spositiontaking_2,
    @old_auto_spositiontaking_3 = @old_auto_spositiontaking_3,
    @old_auto_spositiontaking_4 = @old_auto_spositiontaking_4,
    @old_auto_spositiontaking_5 = @old_auto_spositiontaking_5,
    @old_auto_spositiontaking_6 = @old_auto_spositiontaking_6,
    @old_auto_spositiontaking_7 = @old_auto_spositiontaking_7,
    @old_auto_spositiontaking_8 = @old_auto_spositiontaking_8,
    @old_auto_spositiontaking_9 = @old_auto_spositiontaking_9,
    @old_auto_spositiontaking_10 = @old_auto_spositiontaking_10,
    @old_auto_spositiontaking_9999 = @old_auto_spositiontaking_9999,
    @old_auto_slivepositiontaking_1 = @old_auto_slivepositiontaking_1,
    @old_auto_slivepositiontaking_3 = @old_auto_slivepositiontaking_3,
    @old_auto_slivepositiontaking_7 = @old_auto_slivepositiontaking_7,
    @old_auto_slivepositiontaking_8 = @old_auto_slivepositiontaking_8,
    
    @old_auto_v2spositiontaking_1 = @old_auto_v2spositiontaking_1,
    @old_auto_v2spositiontaking_2 = @old_auto_v2spositiontaking_2,
    @old_auto_v2spositiontaking_3 = @old_auto_v2spositiontaking_3,
    @old_auto_v2spositiontaking_7 = @old_auto_v2spositiontaking_7,
    @old_auto_v2spositiontaking_8 = @old_auto_v2spositiontaking_8,
--    @old_auto_v2spositiontaking_9 = @old_auto_v2spositiontaking_9,
    @old_auto_v2spositiontaking_20 = @old_auto_v2spositiontaking_20,
    
    @old_auto_v3spositiontaking_1 = @old_auto_v3spositiontaking_1,
    @old_auto_v3spositiontaking_2 = @old_auto_v3spositiontaking_2,
    @old_auto_v3spositiontaking_3 = @old_auto_v3spositiontaking_3,
    @old_auto_v3spositiontaking_20 = @old_auto_v3spositiontaking_20,

    @old_auto_v5spositiontaking_1 = @old_auto_v5spositiontaking_1,
    @old_auto_v5spositiontaking_2 = @old_auto_v5spositiontaking_2,
    @old_auto_v5spositiontaking_3 = @old_auto_v5spositiontaking_3,
    @old_auto_v5spositiontaking_20 = @old_auto_v5spositiontaking_20,
    @old_auto_v5spositiontaking_9999 = @old_auto_v5spositiontaking_9999,

    @old_auto_v8spositiontaking_1 = @old_auto_v8spositiontaking_1,
    @old_auto_v8spositiontaking_3 = @old_auto_v8spositiontaking_3,
    @old_auto_v8spositiontaking_20 = @old_auto_v8spositiontaking_20,

    @old_auto_v10spositiontaking_1 = @old_auto_v10spositiontaking_1,
    @old_auto_v10spositiontaking_2 = @old_auto_v10spositiontaking_2,
    @old_auto_v10spositiontaking_3 = @old_auto_v10spositiontaking_3,
    @old_auto_v10spositiontaking_20 = @old_auto_v10spositiontaking_20,

    @old_auto_v11spositiontaking_1 = @old_auto_v11spositiontaking_1,
    @old_auto_v11spositiontaking_20 = @old_auto_v11spositiontaking_20,

    @old_auto_v99spositiontaking_1 = @old_auto_v99spositiontaking_1,
    @old_auto_v99spositiontaking_2 = @old_auto_v99spositiontaking_2,
    @old_auto_v99spositiontaking_3 = @old_auto_v99spositiontaking_3,
    @old_auto_v99spositiontaking_20 = @old_auto_v99spositiontaking_20,

    --- mixed sports
    @old_auto_v99spositiontaking_9 = @old_auto_v99spositiontaking_9,
    @old_auto_v154spositiontaking_20 = @old_auto_v154spositiontaking_20,

    --update auto pt on agent 
    
    @updatemultiple = @updatemultiple,
    @updatepositiontaking = @updatepositiontaking,
    
    @updatepositiontakingv2 = @updatepositiontakingv2,
    @updatepositiontakingv3 = @updatepositiontakingv3,
    @updatepositiontakingv5 = @updatepositiontakingv5,
    @updatepositiontakingv8 = @updatepositiontakingv8,
    @updatepositiontakingv10 = @updatepositiontakingv10,
    @updatepositiontakingv11 = @updatepositiontakingv11,
    @updatepositiontakingv99 = @updatepositiontakingv99,

    -- mixed sports
    @updatepositiontakingv99mp = @updatepositiontakingv99mp,
    @updatepositiontakingv154 = @updatepositiontakingv154,
    
    @updateallmembers = @updateallmembers,
    @newspositiontaking = @newspositiontaking,
    -- Outright PT for sports
    @isauto_v2spositiontaking_10 = @isauto_v2spositiontaking_10,
    @isauto_v3spositiontaking_10 = @isauto_v3spositiontaking_10,
    @isauto_v5spositiontaking_10 = @isauto_v5spositiontaking_10,
    @isauto_v8spositiontaking_10 = @isauto_v8spositiontaking_10,
    @isauto_v10spositiontaking_10 = @isauto_v10spositiontaking_10,
    @isauto_v11spositiontaking_10 = @isauto_v11spositiontaking_10,
    @isauto_v99spositiontaking_10 = @isauto_v99spositiontaking_10,
    
	@old_isauto_v2spositiontaking_10 = @old_isauto_v2spositiontaking_10, 
	@old_isauto_v3spositiontaking_10 = @old_isauto_v3spositiontaking_10, 
	@old_isauto_v5spositiontaking_10 = @old_isauto_v5spositiontaking_10, 
	@old_isauto_v8spositiontaking_10 = @old_isauto_v8spositiontaking_10, 
	@old_isauto_v10spositiontaking_10 = @old_isauto_v10spositiontaking_10, 
	@old_isauto_v11spositiontaking_10 = @old_isauto_v11spositiontaking_10, 
	@old_isauto_v99spositiontaking_10 = @old_isauto_v99spositiontaking_10, 
	
	@auto_v2spositiontaking_10 = @auto_v2spositiontaking_10,
	@auto_v3spositiontaking_10 = @auto_v3spositiontaking_10,
	@auto_v5spositiontaking_10 = @auto_v5spositiontaking_10,
	@auto_v8spositiontaking_10 = @auto_v8spositiontaking_10,
	@auto_v10spositiontaking_10 = @auto_v10spositiontaking_10,
	@auto_v11spositiontaking_10 = @auto_v11spositiontaking_10,
	@auto_v99spositiontaking_10 = @auto_v99spositiontaking_10,
	
	@old_auto_v2spositiontaking_10 = @old_auto_v2spositiontaking_10,
	@old_auto_v3spositiontaking_10 = @old_auto_v3spositiontaking_10,
	@old_auto_v5spositiontaking_10 = @old_auto_v5spositiontaking_10,
	@old_auto_v8spositiontaking_10 = @old_auto_v8spositiontaking_10,
	@old_auto_v10spositiontaking_10 = @old_auto_v10spositiontaking_10,
	@old_auto_v11spositiontaking_10 = @old_auto_v11spositiontaking_10,
	@old_auto_v99spositiontaking_10 = @old_auto_v99spositiontaking_10



EXEC dbo.Acc_CustSetting3rd_05
    @srecommend = @srecommend,
    @mrecommend = @mrecommend,    
    @roleid = 3,
    @mode = 'number',
    
    @isauto_v161spositiontaking_81 = @isauto_v161spositiontaking_81,
    @isauto_v161spositiontaking_83 = @isauto_v161spositiontaking_83,    
    @isauto_v161spositiontaking_86 = @isauto_v161spositiontaking_86,
    @isauto_v161spositiontaking_88 = @isauto_v161spositiontaking_88,
    
    @isauto_v161slivepositiontaking_85 = @isauto_v161slivepositiontaking_85,
    @isauto_v161slivepositiontaking_86 = @isauto_v161slivepositiontaking_86,
    @isauto_v161slivepositiontaking_87 = @isauto_v161slivepositiontaking_87,
    @isauto_v161slivepositiontaking_89 = @isauto_v161slivepositiontaking_89,
    @isauto_v161slivepositiontaking_90 = @isauto_v161slivepositiontaking_90,
    
    @old_isauto_v161spositiontaking_81 = @old_isauto_v161spositiontaking_81,
    @old_isauto_v161spositiontaking_83 = @old_isauto_v161spositiontaking_83,    
    @old_isauto_v161spositiontaking_86 = @old_isauto_v161spositiontaking_86,
    @old_isauto_v161spositiontaking_88 = @old_isauto_v161spositiontaking_88,
    
    @old_isauto_v161slivepositiontaking_85 = @old_isauto_v161slivepositiontaking_85,
    @old_isauto_v161slivepositiontaking_86 = @old_isauto_v161slivepositiontaking_86,
    @old_isauto_v161slivepositiontaking_87 = @old_isauto_v161slivepositiontaking_87,
    @old_isauto_v161slivepositiontaking_89 = @old_isauto_v161slivepositiontaking_89,
    @old_isauto_v161slivepositiontaking_90 = @old_isauto_v161slivepositiontaking_90,
    
    @auto_v161spositiontaking_81 = @auto_v161spositiontaking_81,
    @auto_v161spositiontaking_83 = @auto_v161spositiontaking_83,    
    @auto_v161spositiontaking_86 = @auto_v161spositiontaking_86,
    @auto_v161spositiontaking_88 = @auto_v161spositiontaking_88,
    
    @auto_v161slivepositiontaking_85 = @auto_v161slivepositiontaking_85,
    @auto_v161slivepositiontaking_86 = @auto_v161slivepositiontaking_86,
    @auto_v161slivepositiontaking_87 = @auto_v161slivepositiontaking_87,
    @auto_v161slivepositiontaking_89 = @auto_v161slivepositiontaking_89,
    @auto_v161slivepositiontaking_90 = @auto_v161slivepositiontaking_90,
    
    @old_auto_v161spositiontaking_81 = @old_auto_v161spositiontaking_81,
    @old_auto_v161spositiontaking_83 = @old_auto_v161spositiontaking_83,    
    @old_auto_v161spositiontaking_86 = @old_auto_v161spositiontaking_86,
    @old_auto_v161spositiontaking_88 = @old_auto_v161spositiontaking_88,
    
    @old_auto_v161slivepositiontaking_85 = @old_auto_v161slivepositiontaking_85,
    @old_auto_v161slivepositiontaking_86 = @old_auto_v161slivepositiontaking_86,
    @old_auto_v161slivepositiontaking_87 = @old_auto_v161slivepositiontaking_87,
    @old_auto_v161slivepositiontaking_89 = @old_auto_v161slivepositiontaking_89,
    @old_auto_v161slivepositiontaking_90 = @old_auto_v161slivepositiontaking_90,
    
    @updatepositiontakingv161 = @updatepositiontakingv161,
    @updateallmembers = @updateallmembers,
    @updatemultiple = @updatemultiple,
    @newspositiontaking = @newspositiontaking
    
/*
                                                                                                                                                                                                                                                                                                                                                                                                
        select 1 as bettype    ,       @isauto_spositiontaking_1 as isautopositiontaking    ,      @isauto_slivepositiontaking_1 as isautolivepositiontaking            ,      @auto_spositiontaking_1 as autopositiontaking    ,       @auto_slivepositiontaking_1 as autolivepositiontaking            ,      @old_auto_spositiontaking_1 as old_autopositiontaking    ,       @old_auto_slivepositiontaking_1 as old_autolivepositiontaking            ,      @old_isauto_spositiontaking_1 as old_isautopositiontaking    ,       @old_isauto_slivepositiontaking_1 as old_isautolivepositiontaking    ,       @isauto_v2spositiontaking_1 as isautov2positiontaking    ,       @auto_v2spositiontaking_1 as autov2positiontaking    ,       @old_auto_v2spositiontaking_1 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_1 as old_isautov2positiontaking    ,    @isauto_v2spositiontaking_1 as isautov2positiontaking    ,       @auto_v2spositiontaking_1 as autov2positiontaking    ,       @old_auto_v2spositiontaking_1 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_1 as old_isautov2positiontaking    ,    @isauto_v3spositiontaking_1 as isautov3positiontaking    ,       @auto_v3spositiontaking_1 as autov3positiontaking    ,       @old_auto_v3spositiontaking_1 as old_autov3positiontaking    ,       @old_isauto_v3spositiontaking_1 as old_isautov3positiontaking    ,    @isauto_v5spositiontaking_1 as isautov5positiontaking    ,       @auto_v5spositiontaking_1 as autov5positiontaking    ,       @old_auto_v5spositiontaking_1 as old_autov5positiontaking    ,       @old_isauto_v5spositiontaking_1 as old_isautov5positiontaking    ,    @isauto_v8spositiontaking_1 as isautov8positiontaking    ,       @auto_v8spositiontaking_1 as autov8positiontaking    ,       @old_auto_v8spositiontaking_1 as old_autov8positiontaking    ,       @old_isauto_v8spositiontaking_1 as old_isautov8positiontaking    ,    @isauto_v10spositiontaking_1 as isautov10positiontaking    ,       @auto_v10spositiontaking_1 as autov10positiontaking    ,       @old_auto_v10spositiontaking_1 as old_autov10positiontaking    ,       @old_isauto_v10spositiontaking_1 as old_isautov10positiontaking    ,    @isauto_v11spositiontaking_1 as isautov11positiontaking    ,       @auto_v11spositiontaking_1 as autov11positiontaking    ,       @old_auto_v11spositiontaking_1 as old_autov11positiontaking    ,       @old_isauto_v11spositiontaking_1 as old_isautov11positiontaking    ,    @isauto_v12spositiontaking_1 as isautov12positiontaking    ,       @auto_v12spositiontaking_1 as autov12positiontaking    ,       0 as old_autov12positiontaking    ,       @old_isauto_v12spositiontaking_1 as old_isautov12positiontaking    ,    @isauto_v99spositiontaking_1 as isautov99positiontaking    ,       @auto_v99spositiontaking_1 as autov99positiontaking    ,       @old_auto_v99spositiontaking_1 as old_autov99positiontaking    ,       @old_isauto_v99spositiontaking_1 as old_isautov99positiontaking    
    union all      select 2 as bettype    ,       @isauto_spositiontaking_2 as isautopositiontaking    ,      0 as isautolivepositiontaking            ,      @auto_spositiontaking_2 as autopositiontaking    ,      0 as autolivepositiontaking            ,      @old_auto_spositiontaking_2 as old_autopositiontaking    ,      0 as old_autolivepositiontaking            ,      @old_isauto_spositiontaking_2 as old_isautopositiontaking    ,      0 as old_isautolivepositiontaking    ,       @isauto_v2spositiontaking_2 as isautov2positiontaking    ,       @auto_v2spositiontaking_2 as autov2positiontaking    ,           @old_auto_v2spositiontaking_2 as old_autov2positiontaking    ,           @old_isauto_v2spositiontaking_2 as old_isautov2positiontaking    ,    @isauto_v2spositiontaking_2 as isautov2positiontaking    ,       @auto_v2spositiontaking_2 as autov2positiontaking    ,           @old_auto_v2spositiontaking_2 as old_autov2positiontaking    ,           @old_isauto_v2spositiontaking_2 as old_isautov2positiontaking    ,    @isauto_v3spositiontaking_2 as isautov3positiontaking    ,       @auto_v3spositiontaking_2 as autov3positiontaking    ,           @old_auto_v3spositiontaking_2 as old_autov3positiontaking    ,           @old_isauto_v3spositiontaking_2 as old_isautov3positiontaking    ,    @isauto_v5spositiontaking_2 as isautov5positiontaking    ,       @auto_v5spositiontaking_2 as autov5positiontaking    ,           @old_auto_v5spositiontaking_2 as old_autov5positiontaking    ,           @old_isauto_v5spositiontaking_2 as old_isautov5positiontaking    ,    0 as isautov8positiontaking    ,       0 as autov8positiontaking    ,           0 as old_autov8positiontaking    ,           0 as old_isautov8positiontaking    ,    @isauto_v10spositiontaking_2 as isautov10positiontaking    ,       @auto_v10spositiontaking_2 as autov10positiontaking    ,           @old_auto_v10spositiontaking_2 as old_autov10positiontaking    ,           @old_isauto_v10spositiontaking_2 as old_isautov10positiontaking    ,    0 as isautov11positiontaking    ,       0 as autov11positiontaking    ,           0 as old_autov11positiontaking    ,           0 as old_isautov11positiontaking    ,    @isauto_v12spositiontaking_2 as isautov12positiontaking    ,       @auto_v12spositiontaking_2 as autov12positiontaking    ,           @old_auto_v12spositiontaking_2 as old_autov12positiontaking    ,           @old_isauto_v12spositiontaking_2 as old_isautov12positiontaking    ,    @isauto_v99spositiontaking_2 as isautov99positiontaking    ,       @auto_v99spositiontaking_2 as autov99positiontaking    ,           @old_auto_v99spositiontaking_2 as old_autov99positiontaking    ,           @old_isauto_v99spositiontaking_2 as old_isautov99positiontaking    
    union all     select 3 as bettype    ,       @isauto_spositiontaking_3 as isautopositiontaking    ,      @isauto_slivepositiontaking_3 as isautolivepositiontaking            ,      @auto_spositiontaking_3 as autopositiontaking    ,       @auto_slivepositiontaking_3 as autolivepositiontaking            ,      @old_auto_spositiontaking_3 as old_autopositiontaking    ,       @old_auto_slivepositiontaking_3 as old_autolivepositiontaking            ,      @old_isauto_spositiontaking_3 as old_isautopositiontaking    ,       @old_isauto_slivepositiontaking_3 as old_isautolivepositiontaking    ,       @isauto_v2spositiontaking_3 as isautov2positiontaking    ,       @auto_v2spositiontaking_3 as autov2positiontaking    ,       @old_auto_v2spositiontaking_3 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_3 as old_isautov2positiontaking    ,    @isauto_v2spositiontaking_3 as isautov2positiontaking    ,       @auto_v2spositiontaking_3 as autov2positiontaking    ,       @old_auto_v2spositiontaking_3 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_3 as old_isautov2positiontaking    ,    @isauto_v3spositiontaking_3 as isautov3positiontaking    ,       @auto_v3spositiontaking_3 as autov3positiontaking    ,       @old_auto_v3spositiontaking_3 as old_autov3positiontaking    ,       @old_isauto_v3spositiontaking_3 as old_isautov3positiontaking    ,    @isauto_v5spositiontaking_3 as isautov5positiontaking    ,       @auto_v5spositiontaking_3 as autov5positiontaking    ,       @old_auto_v5spositiontaking_3 as old_autov5positiontaking    ,       @old_isauto_v5spositiontaking_3 as old_isautov5positiontaking    ,    @isauto_v8spositiontaking_3 as isautov8positiontaking    ,       @auto_v8spositiontaking_3 as autov8positiontaking    ,       @old_auto_v8spositiontaking_3 as old_autov8positiontaking    ,       @old_isauto_v8spositiontaking_3 as old_isautov8positiontaking    ,    @isauto_v10spositiontaking_3 as isautov10positiontaking    ,       @auto_v10spositiontaking_3 as autov10positiontaking    ,       @old_auto_v10spositiontaking_3 as old_autov10positiontaking    ,       @old_isauto_v10spositiontaking_3 as old_isautov10positiontaking    ,    0 as isautov11positiontaking    ,       0 as autov11positiontaking    ,       0 as old_autov11positiontaking    ,       0 as old_isautov11positiontaking    ,    0 as isautov12positiontaking    ,       0 as autov12positiontaking    ,       0 as old_autov12positiontaking    ,       0 as old_isautov12positiontaking    ,    @isauto_v99spositiontaking_3 as isautov99positiontaking    ,       @auto_v99spositiontaking_3 as autov99positiontaking    ,       @old_auto_v99spositiontaking_3 as old_autov99positiontaking    ,       @old_isauto_v99spositiontaking_3 as old_isautov99positiontaking    
    union all      select 4 as bettype    ,       @isauto_spositiontaking_4 as isautopositiontaking    ,      0 as isautolivepositiontaking            ,       @auto_spositiontaking_4 as autopositiontaking    ,      0 as autolivepositiontaking            ,       @old_auto_spositiontaking_4 as old_autopositiontaking    ,      0 as old_autolivepositiontaking            ,       @old_isauto_spositiontaking_4 as old_isautopositiontaking    ,      0 as old_isautolivepositiontaking    ,       0 as isautov2positiontaking    ,       0 as autov2positiontaking    ,           0 as old_autov2positiontaking    ,           0 as old_isautov2positiontaking    ,    0 as isautov2positiontaking    ,       0 as autov2positiontaking    ,           0 as old_autov2positiontaking    ,           0 as old_isautov2positiontaking    ,    0 as isautov3positiontaking    ,       0 as autov3positiontaking    ,           0 as old_autov3positiontaking    ,           0 as old_isautov3positiontaking    ,    0 as isautov5positiontaking    ,       0 as autov5positiontaking    ,           0 as old_autov5positiontaking    ,           0 as old_isautov5positiontaking    ,    0 as isautov8positiontaking    ,       0 as autov8positiontaking    ,           0 as old_autov8positiontaking    ,           0 as old_isautov8positiontaking    ,    0 as isautov10positiontaking    ,       0 as autov10positiontaking    ,           0 as old_autov10positiontaking    ,           0 as old_isautov10positiontaking    ,    0 as isautov11positiontaking    ,       0 as autov11positiontaking    ,           0 as old_autov11positiontaking    ,           0 as old_isautov11positiontaking    ,    0 as isautov12positiontaking    ,       0 as autov12positiontaking    ,           0 as old_autov12positiontaking    ,           0 as old_isautov12positiontaking    ,    0 as isautov99positiontaking    ,       0 as autov99positiontaking    ,           0 as old_autov99positiontaking    ,           0 as old_isautov99positiontaking      
    union all     select 5 as bettype    ,       @isauto_spositiontaking_5 as isautopositiontaking    ,      0 as isautolivepositiontaking            ,       @auto_spositiontaking_5 as autopositiontaking    ,      0 as autolivepositiontaking            ,       @old_auto_spositiontaking_5 as old_autopositiontaking    ,      0 as old_autolivepositiontaking            ,       @old_isauto_spositiontaking_5 as old_isautopositiontaking    ,      0 as old_isautolivepositiontaking    ,       0 as isautov2positiontaking    ,       0 as autov2positiontaking    ,           0 as old_autov2positiontaking    ,           0 as old_isautov2positiontaking    ,    0 as isautov2positiontaking    ,       0 as autov2positiontaking    ,           0 as old_autov2positiontaking    ,           0 as old_isautov2positiontaking    ,    0 as isautov3positiontaking    ,       0 as autov3positiontaking    ,           0 as old_autov3positiontaking    ,           0 as old_isautov3positiontaking    ,    0 as isautov5positiontaking    ,       0 as autov5positiontaking    ,           0 as old_autov5positiontaking    ,           0 as old_isautov5positiontaking    ,    0 as isautov8positiontaking    ,       0 as autov8positiontaking    ,           0 as old_autov8positiontaking    ,           0 as old_isautov8positiontaking    ,    0 as isautov10positiontaking    ,       0 as autov10positiontaking    ,           0 as old_autov10positiontaking    ,           0 as old_isautov10positiontaking    ,    0 as isautov11positiontaking    ,       0 as autov11positiontaking    ,           0 as old_autov11positiontaking    ,           0 as old_isautov11positiontaking    ,    0 as isautov12positiontaking    ,       0 as autov12positiontaking    ,           0 as old_autov12positiontaking    ,           0 as old_isautov12positiontaking    ,    0 as isautov99positiontaking    ,       0 as autov99positiontaking    ,           0 as old_autov99positiontaking    ,           0 as old_isautov99positiontaking    
    union all      select 6 as bettype    ,       @isauto_spositiontaking_6 as isautopositiontaking    ,      0 as isautolivepositiontaking            ,       @auto_spositiontaking_6 as autopositiontaking    ,      0 as autolivepositiontaking            ,       @old_auto_spositiontaking_6 as old_autopositiontaking    ,      0 as old_autolivepositiontaking            ,       @old_isauto_spositiontaking_6 as old_isautopositiontaking    ,      0 as old_isautolivepositiontaking    ,       0 as isautov2positiontaking    ,       0 as autov2positiontaking    ,           0 as old_autov2positiontaking    ,           0 as old_isautov2positiontaking    ,    0 as isautov2positiontaking    ,       0 as autov2positiontaking    ,           0 as old_autov2positiontaking    ,           0 as old_isautov2positiontaking                                                                                                                                                                                                                                    
    union all      select 7 as bettype    ,       @isauto_spositiontaking_7 as isautopositiontaking    ,      @isauto_slivepositiontaking_7 as isautolivepositiontaking            ,      @auto_spositiontaking_7 as autopositiontaking    ,       @auto_slivepositiontaking_7 as autolivepositiontaking            ,      @old_auto_spositiontaking_7 as old_autopositiontaking    ,       @old_auto_slivepositiontaking_7 as old_autolivepositiontaking            ,      @old_isauto_spositiontaking_7 as old_isautopositiontaking    ,       @old_isauto_slivepositiontaking_7 as old_isautolivepositiontaking    ,       @isauto_v2spositiontaking_7 as isautov2positiontaking    ,       @auto_v2spositiontaking_7 as autov2positiontaking    ,       @old_auto_v2spositiontaking_7 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_7 as old_isautov2positiontaking    ,    @isauto_v2spositiontaking_7 as isautov2positiontaking    ,       @auto_v2spositiontaking_7 as autov2positiontaking    ,       @old_auto_v2spositiontaking_7 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_7 as old_isautov2positiontaking    ,    0 as isautov3positiontaking    ,       0 as autov3positiontaking    ,           0 as old_autov3positiontaking    ,           0 as old_isautov3positiontaking    ,    0 as isautov5positiontaking    ,       0 as autov5positiontaking    ,           0 as old_autov5positiontaking    ,           0 as old_isautov5positiontaking    ,    0 as isautov8positiontaking    ,       0 as autov8positiontaking    ,           0 as old_autov8positiontaking    ,           0 as old_isautov8positiontaking    ,    0 as isautov10positiontaking    ,       0 as autov10positiontaking    ,           0 as old_autov10positiontaking    ,           0 as old_isautov10positiontaking    ,    0 as isautov11positiontaking    ,       0 as autov11positiontaking    ,           0 as old_autov11positiontaking    ,           0 as old_isautov11positiontaking    ,    0 as isautov12positiontaking    ,       0 as autov12positiontaking    ,           0 as old_autov12positiontaking    ,           0 as old_isautov12positiontaking    ,    0 as isautov99positiontaking    ,       0 as autov99positiontaking    ,           0 as old_autov99positiontaking    ,           0 as old_isautov99positiontaking    
    union all      select 8 as bettype    ,       @isauto_spositiontaking_8 as isautopositiontaking    ,      @isauto_slivepositiontaking_8 as isautolivepositiontaking            ,      @auto_spositiontaking_8 as autopositiontaking    ,       @auto_slivepositiontaking_8 as autolivepositiontaking            ,      @old_auto_spositiontaking_8 as old_autopositiontaking    ,       @old_auto_slivepositiontaking_8 as old_autolivepositiontaking            ,      @old_isauto_spositiontaking_8 as old_isautopositiontaking    ,       @old_isauto_slivepositiontaking_8 as old_isautolivepositiontaking    ,       @isauto_v2spositiontaking_8 as isautov2positiontaking    ,       @auto_v2spositiontaking_8 as autov2positiontaking    ,       @old_auto_v2spositiontaking_8 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_8 as old_isautov2positiontaking    ,    @isauto_v2spositiontaking_8 as isautov2positiontaking    ,       @auto_v2spositiontaking_8 as autov2positiontaking    ,       @old_auto_v2spositiontaking_8 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_8 as old_isautov2positiontaking    ,    0 as isautov3positiontaking    ,       0 as autov3positiontaking    ,           0 as old_autov3positiontaking    ,           0 as old_isautov3positiontaking    ,    0 as isautov5positiontaking    ,       0 as autov5positiontaking    ,           0 as old_autov5positiontaking    ,           0 as old_isautov5positiontaking    ,    0 as isautov8positiontaking    ,       0 as autov8positiontaking    ,           0 as old_autov8positiontaking    ,           0 as old_isautov8positiontaking    ,    0 as isautov10positiontaking    ,       0 as autov10positiontaking    ,           0 as old_autov10positiontaking    ,           0 as old_isautov10positiontaking    ,    0 as isautov11positiontaking    ,       0 as autov11positiontaking    ,           0 as old_autov11positiontaking    ,           0 as old_isautov11positiontaking    ,    0 as isautov12positiontaking    ,       0 as autov12positiontaking    ,           0 as old_autov12positiontaking    ,           0 as old_isautov12positiontaking    ,    0 as isautov99positiontaking    ,       0 as autov99positiontaking    ,           0 as old_autov99positiontaking    ,           0 as old_isautov99positiontaking    
    union all      select 9 as bettype    ,       @isauto_spositiontaking_9 as isautopositiontaking    ,      0 as isautolivepositiontaking            ,       @auto_spositiontaking_9 as autopositiontaking    ,      0 as autolivepositiontaking            ,       @old_auto_spositiontaking_9 as old_autopositiontaking    ,      0 as old_autolivepositiontaking            ,       @old_isauto_spositiontaking_9 as old_isautopositiontaking    ,      0 as old_isautolivepositiontaking    ,       0 as isautov2positiontaking    ,       0 as autov2positiontaking    ,           0 as old_autov2positiontaking    ,           0 as old_isautov2positiontaking    ,    0 as isautov2positiontaking    ,       0 as autov2positiontaking    ,           0 as old_autov2positiontaking    ,           0 as old_isautov2positiontaking    ,    0 as isautov3positiontaking    ,       0 as autov3positiontaking    ,           0 as old_autov3positiontaking    ,           0 as old_isautov3positiontaking    ,    0 as isautov5positiontaking    ,       0 as autov5positiontaking    ,           0 as old_autov5positiontaking    ,           0 as old_isautov5positiontaking    ,    0 as isautov8positiontaking    ,       0 as autov8positiontaking    ,           0 as old_autov8positiontaking    ,           0 as old_isautov8positiontaking    ,    0 as isautov10positiontaking    ,       0 as autov10positiontaking    ,           0 as old_autov10positiontaking    ,           0 as old_isautov10positiontaking    ,    0 as isautov11positiontaking    ,       0 as autov11positiontaking    ,           0 as old_autov11positiontaking    ,           0 as old_isautov11positiontaking    ,    0 as isautov12positiontaking    ,       0 as autov12positiontaking    ,           0 as old_autov12positiontaking    ,           0 as old_isautov12positiontaking    ,    0 as isautov99positiontaking    ,       0 as autov99positiontaking    ,           0 as old_autov99positiontaking    ,           0 as old_isautov99positiontaking      
    union all      select 10 as bettype    ,       @isauto_spositiontaking_10 as isautopositiontaking    ,      0 as isautolivepositiontaking            ,       @auto_spositiontaking_10 as autopositiontaking    ,      0 as autolivepositiontaking            ,       @old_auto_spositiontaking_10 as old_autopositiontaking    ,      0 as old_autolivepositiontaking            ,       @old_isauto_spositiontaking_10 as old_isautopositiontaking    ,      0 as old_isautolivepositiontaking    ,       0 as isautov2positiontaking    ,       0 as autov2positiontaking    ,           0 as old_autov2positiontaking    ,           0 as old_isautov2positiontaking    ,    0 as isautov2positiontaking    ,       0 as autov2positiontaking    ,           0 as old_autov2positiontaking    ,           0 as old_isautov2positiontaking    ,    0 as isautov3positiontaking    ,       0 as autov3positiontaking    ,           0 as old_autov3positiontaking    ,           0 as old_isautov3positiontaking    ,    0 as isautov5positiontaking    ,       0 as autov5positiontaking    ,           0 as old_autov5positiontaking    ,           0 as old_isautov5positiontaking    ,    0 as isautov8positiontaking    ,       0 as autov8positiontaking    ,           0 as old_autov8positiontaking    ,           0 as old_isautov8positiontaking    ,    0 as isautov10positiontaking    ,       0 as autov10positiontaking    ,           0 as old_autov10positiontaking    ,           0 as old_isautov10positiontaking    ,    0 as isautov11positiontaking    ,       0 as autov11positiontaking    ,           0 as old_autov11positiontaking    ,           0 as old_isautov11positiontaking    ,    0 as isautov12positiontaking    ,       0 as autov12positiontaking    ,           0 as old_autov12positiontaking    ,           0 as old_isautov12positiontaking    ,    0 as isautov99positiontaking    ,       0 as autov99positiontaking    ,           0 as old_autov99positiontaking    ,           0 as old_isautov99positiontaking    
    union all     select 20 as bettype    ,       0 as isautopositiontaking    ,      0 as isautolivepositiontaking            ,      0 as autopositiontaking    ,       0 as autolivepositiontaking            ,      0 as old_autopositiontaking    ,       0 as old_autolivepositiontaking            ,      0 as old_isautopositiontaking    ,       0 as old_isautolivepositiontaking    ,       @isauto_v2spositiontaking_20 as isautov2positiontaking    ,       @auto_v2spositiontaking_20 as autov2positiontaking    ,       @old_auto_v2spositiontaking_20 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_20 as old_isautov2positiontaking    ,    @isauto_v2spositiontaking_20 as isautov2positiontaking    ,       @auto_v2spositiontaking_20 as autov2positiontaking    ,       @old_auto_v2spositiontaking_20 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_20 as old_isautov2positiontaking    ,    @isauto_v3spositiontaking_20 as isautov3positiontaking    ,       @auto_v3spositiontaking_20 as autov3positiontaking    ,       @old_auto_v3spositiontaking_20 as old_autov3positiontaking    ,       @old_isauto_v3spositiontaking_20 as old_isautov3positiontaking    ,    @isauto_v5spositiontaking_20 as isautov5positiontaking    ,       @auto_v5spositiontaking_20 as autov5positiontaking    ,       @old_auto_v5spositiontaking_20 as old_autov5positiontaking    ,       @old_isauto_v5spositiontaking_20 as old_isautov5positiontaking    ,    @isauto_v8spositiontaking_20 as isautov8positiontaking    ,       @auto_v8spositiontaking_20 as autov8positiontaking    ,       @old_auto_v8spositiontaking_20 as old_autov8positiontaking    ,       @old_isauto_v8spositiontaking_20 as old_isautov8positiontaking    ,    @isauto_v10spositiontaking_20 as isautov10positiontaking    ,       @auto_v10spositiontaking_20 as autov10positiontaking    ,       @old_auto_v10spositiontaking_20 as old_autov10positiontaking    ,       @old_isauto_v10spositiontaking_20 as old_isautov10positiontaking    ,    @isauto_v11spositiontaking_20 as isautov11positiontaking    ,       @auto_v11spositiontaking_20 as autov11positiontaking    ,       @old_auto_v11spositiontaking_20 as old_autov11positiontaking    ,       @old_isauto_v11spositiontaking_20 as old_isautov11positiontaking    ,    0 as isautov12positiontaking    ,       0 as autov12positiontaking    ,       0 as old_autov12positiontaking    ,       0 as old_isautov12positiontaking    ,    @isauto_v99spositiontaking_20 as isautov99positiontaking    ,       @auto_v99spositiontaking_20 as autov99positiontaking    ,       @old_auto_v99spositiontaking_20 as old_autov99positiontaking    ,       @old_isauto_v99spositiontaking_20 as old_isautov99positiontaking    
    union all      select 21 as bettype    ,       0 as isautopositiontaking    ,      0 as isautolivepositiontaking            ,      0 as autopositiontaking    ,       0 as autolivepositiontaking            ,      0 as old_autopositiontaking    ,       0 as old_autolivepositiontaking            ,      0 as old_isautopositiontaking    ,       0 as old_isautolivepositiontaking    ,       0 as isautov2positiontaking    ,       0 as autov2positiontaking    ,       0 as old_autov2positiontaking    ,       0 as old_isautov2positiontaking    ,    @isauto_v2spositiontaking_7 as isautov2positiontaking    ,       @auto_v2spositiontaking_7 as autov2positiontaking    ,       @old_auto_v2spositiontaking_7 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_7 as old_isautov2positiontaking    ,    0 as isautov3positiontaking    ,       0 as autov3positiontaking    ,           0 as old_autov3positiontaking    ,           0 as old_isautov3positiontaking    ,    0 as isautov5positiontaking    ,       0 as autov5positiontaking    ,           0 as old_autov5positiontaking    ,           0 as old_isautov5positiontaking    ,    0 as isautov8positiontaking    ,       0 as autov8positiontaking    ,           0 as old_autov8positiontaking    ,           0 as old_isautov8positiontaking    ,    0 as isautov10positiontaking    ,       0 as autov10positiontaking    ,           0 as old_autov10positiontaking    ,           0 as old_isautov10positiontaking    ,    0 as isautov11positiontaking    ,       0 as autov11positiontaking    ,           0 as old_autov11positiontaking    ,           0 as old_isautov11positiontaking    ,    @isauto_v2spositiontaking_21 as isautov12positiontaking    ,       @auto_v2spositiontaking_21 as autov12positiontaking    ,           @old_auto_v2spositiontaking_21 as old_autov12positiontaking    ,           @old_isauto_v2spositiontaking_21 as old_isautov12positiontaking    ,    0 as isautov99positiontaking    ,       0 as autov99positiontaking    ,           0 as old_autov99positiontaking    ,           0 as old_isautov99positiontaking    
    union all      select 22 as bettype    ,       0 as isautopositiontaking    ,      0 as isautolivepositiontaking            ,      0 as autopositiontaking    ,       0 as autolivepositiontaking            ,      0 as old_autopositiontaking    ,       0 as old_autolivepositiontaking            ,      0 as old_isautopositiontaking    ,       0 as old_isautolivepositiontaking    ,       0 as isautov2positiontaking    ,       0 as autov2positiontaking    ,       0 as old_autov2positiontaking    ,       0 as old_isautov2positiontaking    ,    @isauto_v2spositiontaking_8 as isautov2positiontaking    ,       @auto_v2spositiontaking_8 as autov2positiontaking    ,       @old_auto_v2spositiontaking_8 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_8 as old_isautov2positiontaking    ,    0 as isautov3positiontaking    ,       0 as autov3positiontaking    ,           0 as old_autov3positiontaking    ,           0 as old_isautov3positiontaking    ,    0 as isautov5positiontaking    ,       0 as autov5positiontaking    ,           0 as old_autov5positiontaking    ,           0 as old_isautov5positiontaking    ,    0 as isautov8positiontaking    ,       0 as autov8positiontaking    ,           0 as old_autov8positiontaking    ,           0 as old_isautov8positiontaking    ,    0 as isautov10positiontaking    ,       0 as autov10positiontaking    ,           0 as old_autov10positiontaking    ,           0 as old_isautov10positiontaking    ,    0 as isautov11positiontaking    ,       0 as autov11positiontaking    ,           0 as old_autov11positiontaking    ,           0 as old_isautov11positiontaking    ,    @isauto_v2spositiontaking_22 as isautov12positiontaking    ,       @auto_v2spositiontaking_22 as autov12positiontaking    ,           @old_auto_v2spositiontaking_22 as old_autov12positiontaking    ,           @old_isauto_v2spositiontaking_22 as old_isautov12positiontaking    ,    0 as isautov99positiontaking    ,       0 as autov99positiontaking    ,           0 as old_autov99positiontaking    ,           0 as old_isautov99positiontaking

*/

    --Update member accounts
    --Using CURSOR to update spositiontaking field



/*--old code
                        select 1 as bettype    ,       @isauto_spositiontaking_1 as isautopositiontaking    ,      @isauto_slivepositiontaking_1 as isautolivepositiontaking    ,       @isauto_v2spositiontaking_1 as isautobpositiontaking    ,      @auto_spositiontaking_1 as autopositiontaking    ,       @auto_slivepositiontaking_1 as autolivepositiontaking    ,       @auto_v2spositiontaking_1 as autobpositiontaking    ,      @old_auto_spositiontaking_1 as old_autopositiontaking    ,       @old_auto_slivepositiontaking_1 as old_autolivepositiontaking    ,       @old_auto_v2spositiontaking_1 as old_autobpositiontaking    ,      @old_isauto_spositiontaking_1 as old_isautopositiontaking    ,       @old_isauto_slivepositiontaking_1 as old_isautolivepositiontaking    ,       @old_isauto_v2spositiontaking_1 as old_isautobpositiontaking
                union all      select 2 as bettype    ,       @isauto_spositiontaking_2 as isautopositiontaking    ,      0 as isautolivepositiontaking    ,       @isauto_v2spositiontaking_2 as isautobpositiontaking    ,      @auto_spositiontaking_2 as autopositiontaking    ,      0 as autolivepositiontaking    ,       @auto_v2spositiontaking_2 as autobpositiontaking    ,      @old_auto_spositiontaking_2 as old_autopositiontaking    ,      0 as old_autolivepositiontaking    ,           @old_auto_v2spositiontaking_2 as old_autobpositiontaking    ,      @old_isauto_spositiontaking_2 as old_isautopositiontaking    ,      0 as old_isautolivepositiontaking    ,           @old_isauto_v2spositiontaking_2 as old_isautobpositiontaking
                union all     select 3 as bettype    ,       @isauto_spositiontaking_3 as isautopositiontaking    ,      @isauto_slivepositiontaking_3 as isautolivepositiontaking    ,       @isauto_v2spositiontaking_3 as isautobpositiontaking    ,      @auto_spositiontaking_3 as autopositiontaking    ,       @auto_slivepositiontaking_3 as autolivepositiontaking    ,       @auto_v2spositiontaking_3 as autobpositiontaking    ,      @old_auto_spositiontaking_3 as old_autopositiontaking    ,       @old_auto_slivepositiontaking_3 as old_autolivepositiontaking    ,       @old_auto_v2spositiontaking_3 as old_autobpositiontaking    ,      @old_isauto_spositiontaking_3 as old_isautopositiontaking    ,       @old_isauto_slivepositiontaking_3 as old_isautolivepositiontaking    ,       @old_isauto_v2spositiontaking_3 as old_isautobpositiontaking
                union all      select 4 as bettype    ,       @isauto_spositiontaking_4 as isautopositiontaking    ,      0 as isautolivepositiontaking    ,       0 as isautobpositiontaking    ,       @auto_spositiontaking_4 as autopositiontaking    ,      0 as autolivepositiontaking    ,       0 as autobpositiontaking    ,       @old_auto_spositiontaking_4 as old_autopositiontaking    ,      0 as old_autolivepositiontaking    ,           0 as old_autobpositiontaking    ,       @old_isauto_spositiontaking_4 as old_isautopositiontaking    ,      0 as old_isautolivepositiontaking    ,           0 as old_isautobpositiontaking
                union all     select 5 as bettype    ,       @isauto_spositiontaking_5 as isautopositiontaking    ,      0 as isautolivepositiontaking    ,       0 as isautobpositiontaking    ,       @auto_spositiontaking_5 as autopositiontaking    ,      0 as autolivepositiontaking    ,       0 as autobpositiontaking    ,       @old_auto_spositiontaking_5 as old_autopositiontaking    ,      0 as old_autolivepositiontaking    ,           0 as old_autobpositiontaking    ,       @old_isauto_spositiontaking_5 as old_isautopositiontaking    ,      0 as old_isautolivepositiontaking    ,           0 as old_isautobpositiontaking
                union all      select 6 as bettype    ,       @isauto_spositiontaking_6 as isautopositiontaking    ,      0 as isautolivepositiontaking    ,       0 as isautobpositiontaking    ,       @auto_spositiontaking_6 as autopositiontaking    ,      0 as autolivepositiontaking    ,       0 as autobpositiontaking    ,       @old_auto_spositiontaking_6 as old_autopositiontaking    ,      0 as old_autolivepositiontaking    ,           0 as old_autobpositiontaking    ,       @old_isauto_spositiontaking_6 as old_isautopositiontaking    ,      0 as old_isautolivepositiontaking    ,           0 as old_isautobpositiontaking
                union all      select 7 as bettype    ,       @isauto_spositiontaking_7 as isautopositiontaking    ,      @isauto_slivepositiontaking_7 as isautolivepositiontaking    ,       @isauto_v2spositiontaking_7 as isautobpositiontaking    ,      @auto_spositiontaking_7 as autopositiontaking    ,       @auto_slivepositiontaking_7 as autolivepositiontaking    ,       @auto_v2spositiontaking_7 as autobpositiontaking    ,      @old_auto_spositiontaking_7 as old_autopositiontaking    ,       @old_auto_slivepositiontaking_7 as old_autolivepositiontaking    ,       @old_auto_v2spositiontaking_7 as old_autobpositiontaking    ,      @old_isauto_spositiontaking_7 as old_isautopositiontaking    ,       @old_isauto_slivepositiontaking_7 as old_isautolivepositiontaking    ,       @old_isauto_v2spositiontaking_7 as old_isautobpositiontaking
                union all      select 8 as bettype    ,       @isauto_spositiontaking_8 as isautopositiontaking    ,      @isauto_slivepositiontaking_8 as isautolivepositiontaking    ,       @isauto_v2spositiontaking_8 as isautobpositiontaking    ,      @auto_spositiontaking_8 as autopositiontaking    ,       @auto_slivepositiontaking_8 as autolivepositiontaking    ,       @auto_v2spositiontaking_8 as autobpositiontaking    ,      @old_auto_spositiontaking_8 as old_autopositiontaking    ,       @old_auto_slivepositiontaking_8 as old_autolivepositiontaking    ,       @old_auto_v2spositiontaking_8 as old_autobpositiontaking    ,      @old_isauto_spositiontaking_8 as old_isautopositiontaking    ,       @old_isauto_slivepositiontaking_8 as old_isautolivepositiontaking    ,       @old_isauto_v2spositiontaking_8 as old_isautobpositiontaking
                union all      select 9 as bettype    ,       @isauto_spositiontaking_9 as isautopositiontaking    ,      0 as isautolivepositiontaking    ,       0 as isautobpositiontaking    ,       @auto_spositiontaking_9 as autopositiontaking    ,      0 as autolivepositiontaking    ,       0 as autobpositiontaking    ,       @old_auto_spositiontaking_9 as old_autopositiontaking    ,      0 as old_autolivepositiontaking    ,           0 as old_autobpositiontaking    ,       @old_isauto_spositiontaking_9 as old_isautopositiontaking    ,      0 as old_isautolivepositiontaking    ,           0 as old_isautobpositiontaking
                union all      select 10 as bettype    ,       @isauto_spositiontaking_10 as isautopositiontaking    ,      0 as isautolivepositiontaking    ,       0 as isautobpositiontaking    ,       @auto_spositiontaking_10 as autopositiontaking    ,      0 as autolivepositiontaking    ,       0 as autobpositiontaking    ,       @old_auto_spositiontaking_10 as old_autopositiontaking    ,      0 as old_autolivepositiontaking    ,           0 as old_autobpositiontaking    ,       @old_isauto_spositiontaking_10 as old_isautopositiontaking    ,      0 as old_isautolivepositiontaking    ,           0 as old_isautobpositiontaking
*/--end old code

/*
    Declare CUR CURSOR FOR 
            select 1 as bettype    ,       @isauto_spositiontaking_1 as isautopositiontaking    ,      @isauto_slivepositiontaking_1 as isautolivepositiontaking    ,      @auto_spositiontaking_1 as autopositiontaking    ,       @auto_slivepositiontaking_1 as autolivepositiontaking    ,      @old_auto_spositiontaking_1 as old_autopositiontaking        ,       @old_auto_slivepositiontaking_1 as old_autolivepositiontaking    ,      @old_isauto_spositiontaking_1 as old_isautopositiontaking        ,       @old_isauto_slivepositiontaking_1 as old_isautolivepositiontaking    ,       @isauto_v2spositiontaking_1 as isautov2positiontaking    ,       @auto_v2spositiontaking_1 as autov2positiontaking    ,       @old_auto_v2spositiontaking_1 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_1 as old_isautov2positiontaking    ,    @isauto_v3spositiontaking_1 as isautov3positiontaking    ,       @auto_v3spositiontaking_1 as autov3positiontaking    ,       @old_auto_v3spositiontaking_1 as old_autov3positiontaking    ,       @old_isauto_v3spositiontaking_1 as old_isautov3positiontaking    ,    @isauto_v5spositiontaking_1 as isautov5positiontaking    ,       @auto_v5spositiontaking_1 as autov5positiontaking    ,       @old_auto_v5spositiontaking_1 as old_autov5positiontaking    ,       @old_isauto_v5spositiontaking_1 as old_isautov5positiontaking    ,    @isauto_v8spositiontaking_1 as isautov8positiontaking    ,       @auto_v8spositiontaking_1 as autov8positiontaking    ,       @old_auto_v8spositiontaking_1 as old_autov8positiontaking    ,       @old_isauto_v8spositiontaking_1 as old_isautov8positiontaking    ,    @isauto_v10spositiontaking_1 as isautov10positiontaking    ,       @auto_v10spositiontaking_1 as autov10positiontaking    ,       @old_auto_v10spositiontaking_1 as old_autov10positiontaking    ,       @old_isauto_v10spositiontaking_1 as old_isautov10positiontaking    ,    @isauto_v11spositiontaking_1 as isautov11positiontaking    ,       @auto_v11spositiontaking_1 as autov11positiontaking    ,       @old_auto_v11spositiontaking_1 as old_autov11positiontaking    ,       @old_isauto_v11spositiontaking_1 as old_isautov11positiontaking    ,    @isauto_v99spositiontaking_1 as isautov99positiontaking    ,        @auto_v99spositiontaking_1 as autov99positiontaking    ,       @old_auto_v99spositiontaking_1 as old_autov99positiontaking    ,       @old_isauto_v99spositiontaking_1 as old_isautov99positiontaking    , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking                                                        ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 2 as bettype    ,       @isauto_spositiontaking_2 as isautopositiontaking    ,                                0 as isautolivepositiontaking    ,      @auto_spositiontaking_2 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,        @old_auto_spositiontaking_2 as old_autopositiontaking    ,                                        0 as old_autolivepositiontaking    ,      @old_isauto_spositiontaking_2 as old_isautopositiontaking        ,                                        0 as old_isautolivepositiontaking    ,       @isauto_v2spositiontaking_2 as isautov2positiontaking    ,       @auto_v2spositiontaking_2 as autov2positiontaking    ,         @old_auto_v2spositiontaking_2 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_2 as old_isautov2positiontaking    ,    @isauto_v3spositiontaking_2 as isautov3positiontaking    ,       @auto_v3spositiontaking_2 as autov3positiontaking    ,       @old_auto_v3spositiontaking_2 as old_autov3positiontaking    ,       @old_isauto_v3spositiontaking_2 as old_isautov3positiontaking    ,    @isauto_v5spositiontaking_2 as isautov5positiontaking    ,       @auto_v5spositiontaking_2 as autov5positiontaking    ,       @old_auto_v5spositiontaking_2 as old_autov5positiontaking    ,       @old_isauto_v5spositiontaking_2 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                   0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,    @isauto_v10spositiontaking_2 as isautov10positiontaking    ,       @auto_v10spositiontaking_2 as autov10positiontaking    ,       @old_auto_v10spositiontaking_2 as old_autov10positiontaking    ,       @old_isauto_v10spositiontaking_2 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,    @isauto_v99spositiontaking_2 as isautov99positiontaking    ,        @auto_v99spositiontaking_2 as autov99positiontaking    ,       @old_auto_v99spositiontaking_2 as old_autov99positiontaking    ,       @old_isauto_v99spositiontaking_2 as old_isautov99positiontaking    , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking                                                        ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all     select 3 as bettype    ,       @isauto_spositiontaking_3 as isautopositiontaking    ,      @isauto_slivepositiontaking_3 as isautolivepositiontaking    ,      @auto_spositiontaking_3 as autopositiontaking    ,       @auto_slivepositiontaking_3 as autolivepositiontaking    ,        @old_auto_spositiontaking_3 as old_autopositiontaking    ,       @old_auto_slivepositiontaking_3 as old_autolivepositiontaking    ,      @old_isauto_spositiontaking_3 as old_isautopositiontaking        ,        @old_isauto_slivepositiontaking_3 as old_isautolivepositiontaking    ,       @isauto_v2spositiontaking_3 as isautov2positiontaking    ,       @auto_v2spositiontaking_3 as autov2positiontaking    ,       @old_auto_v2spositiontaking_3 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_3 as old_isautov2positiontaking    ,    @isauto_v3spositiontaking_3 as isautov3positiontaking    ,       @auto_v3spositiontaking_3 as autov3positiontaking    ,       @old_auto_v3spositiontaking_3 as old_autov3positiontaking    ,       @old_isauto_v3spositiontaking_3 as old_isautov3positiontaking    ,    @isauto_v5spositiontaking_3 as isautov5positiontaking    ,       @auto_v5spositiontaking_3 as autov5positiontaking    ,       @old_auto_v5spositiontaking_3 as old_autov5positiontaking    ,       @old_isauto_v5spositiontaking_3 as old_isautov5positiontaking    ,    @isauto_v8spositiontaking_3 as isautov8positiontaking    ,       @auto_v8spositiontaking_3 as autov8positiontaking    ,       @old_auto_v8spositiontaking_3 as old_autov8positiontaking    ,       @old_isauto_v8spositiontaking_3 as old_isautov8positiontaking    ,    @isauto_v10spositiontaking_3 as isautov10positiontaking    ,       @auto_v10spositiontaking_3 as autov10positiontaking    ,       @old_auto_v10spositiontaking_3 as old_autov10positiontaking    ,       @old_isauto_v10spositiontaking_3 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,    @isauto_v99spositiontaking_3 as isautov99positiontaking    ,        @auto_v99spositiontaking_3 as autov99positiontaking    ,       @old_auto_v99spositiontaking_3 as old_autov99positiontaking    ,       @old_isauto_v99spositiontaking_3 as old_isautov99positiontaking    , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking                                                        ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 4 as bettype    ,       @isauto_spositiontaking_4 as isautopositiontaking    ,                                0 as isautolivepositiontaking    ,      @auto_spositiontaking_4 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,        @old_auto_spositiontaking_4 as old_autopositiontaking    ,                                     0 as old_autolivepositiontaking    ,       @old_isauto_spositiontaking_4 as old_isautopositiontaking    ,                                         0 as old_isautolivepositiontaking    ,                                    0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                        0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                   0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,    0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking                                                        ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all     select 5 as bettype    ,       @isauto_spositiontaking_5 as isautopositiontaking    ,                                0 as isautolivepositiontaking    ,      @auto_spositiontaking_5 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,        @old_auto_spositiontaking_5 as old_autopositiontaking    ,                                      0 as old_autolivepositiontaking    ,       @old_isauto_spositiontaking_5 as old_isautopositiontaking    ,                                        0 as old_isautolivepositiontaking    ,                                    0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                      0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                   0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,    0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking                                                        ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 6 as bettype    ,       @isauto_spositiontaking_6 as isautopositiontaking    ,                                0 as isautolivepositiontaking    ,      @auto_spositiontaking_6 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,        @old_auto_spositiontaking_6 as old_autopositiontaking    ,                                     0 as old_autolivepositiontaking    ,       @old_isauto_spositiontaking_6 as old_isautopositiontaking    ,                                        0 as old_isautolivepositiontaking    ,                                 0 as isautov2positiontaking    ,                                 0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                     0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                   0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,   0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking                                                        ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 7 as bettype    ,       @isauto_spositiontaking_7 as isautopositiontaking    ,      @isauto_slivepositiontaking_7 as isautolivepositiontaking    ,      @auto_spositiontaking_7 as autopositiontaking    ,       @auto_slivepositiontaking_7 as autolivepositiontaking    ,        @old_auto_spositiontaking_7 as old_autopositiontaking    ,       @old_auto_slivepositiontaking_7 as old_autolivepositiontaking    ,      @old_isauto_spositiontaking_7 as old_isautopositiontaking        ,         @old_isauto_slivepositiontaking_7 as old_isautolivepositiontaking    ,        @isauto_v2spositiontaking_7 as isautov2positiontaking    ,       @auto_v2spositiontaking_7 as autov2positiontaking    ,       @old_auto_v2spositiontaking_7 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_7 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                   0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,    0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking                                                        ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 8 as bettype    ,       @isauto_spositiontaking_8 as isautopositiontaking    ,      @isauto_slivepositiontaking_8 as isautolivepositiontaking    ,      @auto_spositiontaking_8 as autopositiontaking    ,       @auto_slivepositiontaking_8 as autolivepositiontaking    ,        @old_auto_spositiontaking_8 as old_autopositiontaking    ,       @old_auto_slivepositiontaking_8 as old_autolivepositiontaking    ,      @old_isauto_spositiontaking_8 as old_isautopositiontaking        ,       @old_isauto_slivepositiontaking_8 as old_isautolivepositiontaking    ,       @isauto_v2spositiontaking_8 as isautov2positiontaking    ,       @auto_v2spositiontaking_8 as autov2positiontaking    ,       @old_auto_v2spositiontaking_8 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_8 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                   0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,    0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking                                                        ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 9 as bettype    ,       @isauto_spositiontaking_9 as isautopositiontaking    ,                                0 as isautolivepositiontaking    ,      @auto_spositiontaking_9 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,        @old_auto_spositiontaking_9 as old_autopositiontaking    ,                                        0 as old_autolivepositiontaking    ,       @old_isauto_spositiontaking_9 as old_isautopositiontaking    ,                                        0 as old_isautolivepositiontaking    ,     0 as isautov2positiontaking    ,     0 as autov2positiontaking    ,     0 as old_autov2positiontaking    ,     0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                   0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,     0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , @isauto_v99spositiontaking_9 as isautov99mppositiontaking    , @auto_v99spositiontaking_9 as autov99mppositiontaking    , @old_isauto_v99spositiontaking_9 as old_isautov99mppositiontaking    , @old_auto_v99spositiontaking_9 as old_autov99mppositiontaking    , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking
union all      select 10 as bettype,       @isauto_spositiontaking_10 as isautopositiontaking    ,                                0 as isautolivepositiontaking    ,      @auto_spositiontaking_10 as autopositiontaking,                                    0 as autolivepositiontaking    ,        @old_auto_spositiontaking_10 as old_autopositiontaking    ,                                      0 as old_autolivepositiontaking    ,       @old_isauto_spositiontaking_10 as old_isautopositiontaking    ,                                        0 as old_isautolivepositiontaking    ,                                 0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                      0 as old_autov2positiontaking    ,                                     0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                   0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,    0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking                                                        ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all     select 20 as bettype,       0 as isautopositiontaking                            ,                                0 as isautolivepositiontaking    ,                            0 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,                                    0 as old_autopositiontaking    ,                                      0 as old_autolivepositiontaking    ,                                     0 as old_isautopositiontaking    ,                                      0 as old_isautolivepositiontaking      ,        @isauto_v2spositiontaking_20 as isautov2positiontaking    ,       @auto_v2spositiontaking_20 as autov2positiontaking    ,       @old_auto_v2spositiontaking_20 as old_autov2positiontaking    ,       @old_isauto_v2spositiontaking_20 as old_isautov2positiontaking    ,    @isauto_v3spositiontaking_20 as isautov3positiontaking    ,       @auto_v3spositiontaking_20 as autov3positiontaking    ,       @old_auto_v3spositiontaking_20 as old_autov3positiontaking    ,       @old_isauto_v3spositiontaking_20 as old_isautov3positiontaking    ,    @isauto_v5spositiontaking_20 as isautov5positiontaking    ,       @auto_v5spositiontaking_20 as autov5positiontaking    ,       @old_auto_v5spositiontaking_20 as old_autov5positiontaking    ,       @old_isauto_v5spositiontaking_20 as old_isautov5positiontaking    ,    @isauto_v8spositiontaking_20 as isautov8positiontaking    ,       @auto_v8spositiontaking_20 as autov8positiontaking    ,       @old_auto_v8spositiontaking_20 as old_autov8positiontaking    ,       @old_isauto_v8spositiontaking_20 as old_isautov8positiontaking    ,    @isauto_v10spositiontaking_20 as isautov10positiontaking,        @auto_v10spositiontaking_20 as autov10positiontaking,       @old_auto_v10spositiontaking_20 as old_autov10positiontaking    ,       @old_isauto_v10spositiontaking_20 as old_isautov10positiontaking    ,    @isauto_v11spositiontaking_20 as isautov11positiontaking,       @auto_v11spositiontaking_20 as autov11positiontaking    ,       @old_auto_v11spositiontaking_20 as old_autov11positiontaking    ,       @old_isauto_v11spositiontaking_20 as old_isautov11positiontaking    ,    @isauto_v99spositiontaking_20 as isautov99positiontaking,        @auto_v99spositiontaking_20 as autov99positiontaking,       @old_auto_v99spositiontaking_20 as old_autov99positiontaking    ,       @old_isauto_v99spositiontaking_20 as old_isautov99positiontaking    , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking                                                        ,@isauto_v154spositiontaking_20 as isautov154positiontaking    ,@auto_v154spositiontaking_20 as autov154positiontaking    ,@old_auto_v154spositiontaking_20 as old_autov154positiontaking    ,@old_isauto_v154spositiontaking_20 as old_isautov154positiontaking
union all      select 21 as bettype,       0 as isautopositiontaking                            ,                                0 as isautolivepositiontaking    ,                            0 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,                                    0 as old_autopositiontaking    ,                                        0 as old_autolivepositiontaking    ,                                    0 as old_isautopositiontaking    ,                                      0 as old_isautolivepositiontaking        ,                                 0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                      0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                    0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,    0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking                                                        ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 22 as bettype,       0 as isautopositiontaking                            ,                                0 as isautolivepositiontaking    ,                            0 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,                                    0 as old_autopositiontaking    ,                                        0 as old_autolivepositiontaking    ,                                     0 as old_isautopositiontaking    ,                                      0 as old_isautolivepositiontaking        ,                                 0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                     0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                    0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,   0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , 0 as isautov161livepositiontaking                                    , 0 as autov161positiontaking                            , 0 as autov161livepositiontaking                                , 0 as old_autov161positiontaking                                , 0 as old_autov161livepositiontaking                                    , 0 as old_isautov161positiontaking                                    , 0 as old_isautov161livepositiontaking                                                        ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
--- number game
union all      select 81 as bettype,       0 as isautopositiontaking                            ,                                0 as isautolivepositiontaking    ,                            0 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,                                    0 as old_autopositiontaking    ,                                        0 as old_autolivepositiontaking    ,                                     0 as old_isautopositiontaking    ,                                      0 as old_isautolivepositiontaking        ,                                 0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                     0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                    0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,   0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , @isauto_v161spositiontaking_81 as isautov161positiontaking    , 0 as isautov161livepositiontaking                                    , @auto_v161spositiontaking_81 as autov161positiontaking, 0 as autov161livepositiontaking                                , @old_auto_v161spositiontaking_81 as old_autov161positiontaking    , 0 as old_autov161livepositiontaking                                , @old_isauto_v161spositiontaking_81 as old_isautov161positiontaking    , 0 as old_isauto_v161livepositiontaking                                                ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 83 as bettype,       0 as isautopositiontaking                            ,                                0 as isautolivepositiontaking    ,                            0 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,                                    0 as old_autopositiontaking    ,                                        0 as old_autolivepositiontaking    ,                                     0 as old_isautopositiontaking    ,                                      0 as old_isautolivepositiontaking        ,                                 0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                     0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                    0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,   0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , @isauto_v161spositiontaking_83 as isautov161positiontaking    , 0 as isautov161livepositiontaking                                    , @auto_v161spositiontaking_83 as autov161positiontaking, 0 as autov161livepositiontaking                                , @old_auto_v161spositiontaking_83 as old_autov161positiontaking    , 0 as old_autov161livepositiontaking                                , @old_isauto_v161spositiontaking_83 as old_isautov161positiontaking    , 0 as old_isauto_v161livepositiontaking                                                ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 88 as bettype,       0 as isautopositiontaking                            ,                                0 as isautolivepositiontaking    ,                            0 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,                                    0 as old_autopositiontaking    ,                                        0 as old_autolivepositiontaking    ,                                     0 as old_isautopositiontaking    ,                                      0 as old_isautolivepositiontaking        ,                                 0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                     0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                    0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,   0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , @isauto_v161spositiontaking_88 as isautov161positiontaking    , 0 as isautov161livepositiontaking                                    , @auto_v161spositiontaking_88 as autov161positiontaking, 0 as autov161livepositiontaking                                , @old_auto_v161spositiontaking_88 as old_autov161positiontaking    , 0 as old_autov161livepositiontaking                                , @old_isauto_v161spositiontaking_88 as old_isautov161positiontaking    , 0 as old_isauto_v161livepositiontaking                                                ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 85 as bettype,       0 as isautopositiontaking                            ,                                0 as isautolivepositiontaking    ,                            0 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,                                    0 as old_autopositiontaking    ,                                        0 as old_autolivepositiontaking    ,                                     0 as old_isautopositiontaking    ,                                      0 as old_isautolivepositiontaking        ,                                 0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                     0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                    0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,   0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , @isauto_v161slivepositiontaking_85 as isautov161livepositiontaking, 0 as autov161positiontaking                            , @auto_v161slivepositiontaking_85 as autov161livepositiontaking, 0 as old_autov161positiontaking                                    , @old_auto_v161slivepositiontaking_85 as old_autov161livepositiontaking    , 0 as old_isautov161positiontaking                                        , @old_isauto_v161slivepositiontaking_85 as old_isautov161livepositiontaking    ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 86 as bettype,       0 as isautopositiontaking                            ,                                0 as isautolivepositiontaking    ,                            0 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,                                    0 as old_autopositiontaking    ,                                        0 as old_autolivepositiontaking    ,                                     0 as old_isautopositiontaking    ,                                      0 as old_isautolivepositiontaking        ,                                 0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                     0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                    0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,   0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , @isauto_v161spositiontaking_86 as isautov161positiontaking    , @isauto_v161slivepositiontaking_86 as isautov161livepositiontaking, @auto_v161spositiontaking_86 as autov161positiontaking, @auto_v161slivepositiontaking_86 as autov161livepositiontaking, @old_auto_v161spositiontaking_86 as old_autov161positiontaking    , @old_auto_v161slivepositiontaking_86 as old_autov161livepositiontaking    , @old_isauto_v161spositiontaking_86 as old_isautov161positiontaking    , @old_isauto_v161slivepositiontaking_86 as old_isautov161livepositiontaking    ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 87 as bettype,       0 as isautopositiontaking                            ,                                0 as isautolivepositiontaking    ,                            0 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,                                    0 as old_autopositiontaking    ,                                        0 as old_autolivepositiontaking    ,                                     0 as old_isautopositiontaking    ,                                      0 as old_isautolivepositiontaking        ,                                 0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                     0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                    0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,   0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , @isauto_v161slivepositiontaking_87 as isautov161livepositiontaking, 0 as autov161positiontaking                            , @auto_v161slivepositiontaking_87 as autov161livepositiontaking, 0 as old_autov161positiontaking                                    , @old_auto_v161slivepositiontaking_87 as old_autov161livepositiontaking    , 0 as old_isautov161positiontaking                                        , @old_isauto_v161slivepositiontaking_87 as old_isautov161livepositiontaking    ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 89 as bettype,       0 as isautopositiontaking                            ,                                0 as isautolivepositiontaking    ,                            0 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,                                    0 as old_autopositiontaking    ,                                        0 as old_autolivepositiontaking    ,                                     0 as old_isautopositiontaking    ,                                      0 as old_isautolivepositiontaking        ,                                 0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                     0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                    0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,   0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , @isauto_v161slivepositiontaking_89 as isautov161livepositiontaking, 0 as autov161positiontaking                            , @auto_v161slivepositiontaking_89 as autov161livepositiontaking, 0 as old_autov161positiontaking                                    , @old_auto_v161slivepositiontaking_89 as old_autov161livepositiontaking    , 0 as old_isautov161positiontaking                                        , @old_isauto_v161slivepositiontaking_89 as old_isautov161livepositiontaking    ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking
union all      select 90 as bettype,       0 as isautopositiontaking                            ,                                0 as isautolivepositiontaking    ,                            0 as autopositiontaking    ,                                    0 as autolivepositiontaking    ,                                    0 as old_autopositiontaking    ,                                        0 as old_autolivepositiontaking    ,                                     0 as old_isautopositiontaking    ,                                      0 as old_isautolivepositiontaking        ,                                 0 as isautov2positiontaking    ,                                0 as autov2positiontaking    ,                                     0 as old_autov2positiontaking    ,                                     0 as old_isautov2positiontaking    ,                                0 as isautov3positiontaking    ,                                0 as autov3positiontaking    ,                                    0 as old_autov3positiontaking    ,                                      0 as old_isautov3positiontaking    ,                             0 as isautov5positiontaking    ,                                 0 as autov5positiontaking    ,                                   0 as old_autov5positiontaking    ,                                      0 as old_isautov5positiontaking    ,                              0 as isautov8positiontaking    ,                                 0 as autov8positiontaking    ,                                    0 as old_autov8positiontaking    ,                                     0 as old_isautov8positiontaking    ,                            0 as isautov10positiontaking    ,                                0 as autov10positiontaking    ,                                    0 as old_autov10positiontaking    ,                                    0 as old_isautov10positiontaking    ,                            0 as isautov11positiontaking    ,                                0 as autov11positiontaking    ,                                    0 as old_autov11positiontaking    ,                                    0 as old_isautov11positiontaking    ,   0 as isautov99positiontaking                            ,        0 as autov99positiontaking                            ,            0 as old_autov99positiontaking                            ,           0 as old_isautov99positiontaking                                , 0 as isautov99mppositiontaking                            , 0 as autov99mppositiontaking                            , 0 as old_isautov99mppositiontaking                                , 0 as old_autov99mppositiontaking                                , 0 as isautov161positiontaking                                    , @isauto_v161slivepositiontaking_90 as isautov161livepositiontaking, 0 as autov161positiontaking                            , @auto_v161slivepositiontaking_90 as autov161livepositiontaking, 0 as old_autov161positiontaking                                    , @old_auto_v161slivepositiontaking_90 as old_autov161livepositiontaking    , 0 as old_isautov161positiontaking                                        , @old_isauto_v161slivepositiontaking_90 as old_isautov161livepositiontaking    ,0 as isautov154positiontaking                                ,0 as autov154positiontaking                            ,0 as old_autov154positiontaking                                ,0 as old_isautov154positiontaking


    OPEN CUR

    FETCH NEXT FROM CUR INTO
        @bettype, @isautopositiontaking, @isautolivepositiontaking, @autopositiontaking, @autolivepositiontaking, @old_autopositiontaking, @old_autolivepositiontaking, @old_isautopositiontaking, @old_isautolivepositiontaking,
        @isautov2positiontaking, @autov2positiontaking, @old_autov2positiontaking, @old_isautov2positiontaking,    
        @isautov3positiontaking, @autov3positiontaking, @old_autov3positiontaking, @old_isautov3positiontaking,    
        @isautov5positiontaking, @autov5positiontaking, @old_autov5positiontaking, @old_isautov5positiontaking,    
        @isautov8positiontaking, @autov8positiontaking, @old_autov8positiontaking, @old_isautov8positiontaking,    
        @isautov10positiontaking, @autov10positiontaking, @old_autov10positiontaking, @old_isautov10positiontaking,
        @isautov11positiontaking, @autov11positiontaking, @old_autov11positiontaking, @old_isautov11positiontaking,
        @isautov99positiontaking, @autov99positiontaking, @old_autov99positiontaking, @old_isautov99positiontaking,
        @isautov99mppositiontaking, @autov99mppositiontaking, @old_autov99mppositiontaking, @old_isautov99mppositiontaking,
        @isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking,
        @isautov154positiontaking, @autov154positiontaking, @old_autov154positiontaking, @old_isautov154positiontaking

    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        if (@autopositiontaking <> @old_autopositiontaking or @isautopositiontaking <> @old_isautopositiontaking) and (@updatepositiontaking = 1 or @updatemultiple=0)
        BEGIN
            if @isautopositiontaking >0 --auto PT is used
            BEGIN
                --Update use Auto_SPT at master for all members only when:
                    --(autoSPT at master changes AND isauto at master = 1
                    --OR isauto at master changes from 0 to 1)
                    --AND isauto at member = 0
                select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=1 and bettype = @bettype
                update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking> @autopositiontaking then @autopositiontaking else @maxpos - mpositiontaking-apositiontaking end
                from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                where
                    c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1
                    and custsetting.isautopositiontaking=0 -- only update members without AutoSPT at member
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                        case @Language 
                            when 'E' then 'Error updating auto position taking (for Soccer)'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
                        end    
                        ,  @ErrCode=209
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautopositiontaking <> @old_isautopositiontaking  --auto PT is NOT used
            BEGIN
                if @updateallmembers = 1 -- Update All Member option is used
                BEGIN
                    --Update a specific SPT for all members only when:
                        --@updateallmembers = 1
                        --AND isauto at master = 0
                        --AND isauto at master change from 1 to 0
                        --AND isauto at member = 0
                    
                    update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                    from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                    inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1 and custsetting.isautopositiontaking=0                
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Soccer)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
                            end    
                        ,  @ErrCode=210
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END
        END
        ---------------------------------
        --Update LIVE
        if @bettype in (1,3,7,8) and (@autolivepositiontaking <> @old_autolivepositiontaking or @isautolivepositiontaking <> @old_isautolivepositiontaking ) and (@updatepositiontaking = 1 or @updatemultiple=0)
        BEGIN
            if @isautolivepositiontaking >0
            BEGIN
                select @maxpos = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=1 and bettype = @bettype
                update custsetting with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autolivepositiontaking then @autolivepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
                from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1 and custsetting.isautolivepositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                        case @Language 
                            when 'E' then 'Error updating auto position taking (for Soccer - LIVE)'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + case @Language 
                                                                                            when 'CS' then N'(于足球-现场)'
                                                                                            when 'CT' then N'(於足球-現場)'
                                                                                            when 'TH' then N'(สำหรับการเล่นสดขณะแข่งขัน ของฟุตบอล)'
                                                                                            when 'J' then N'(for Soccer - LIVE)'
                                                                                            when 'KO' then N'(축구- 생중계)'
                                                                                            when 'VI' then N'(Bóng đá - Trực tuyến)'
                                                                                            else N'(for Soccer - LIVE)' END
                        end    
                        ,  @ErrCode=211
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautolivepositiontaking <> @old_isautolivepositiontaking
            BEGIN
                if @updateallmembers = 1
                BEGIN
                    update custsetting with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when mcs.slivepositiontaking<@newspositiontaking then mcs.slivepositiontaking else @newspositiontaking end
                    from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                    inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1 and custsetting.isautolivepositiontaking=0                
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                        case @Language 
                            when 'E' then 'Error updating auto position taking (for Soccer - LIVE)'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + case @Language 
                                                                                            when 'CS' then N'(于足球-现场)'
                                                                                            when 'CT' then N'(於足球-現場)'
                                                                                            when 'TH' then N'(สำหรับการเล่นสดขณะแข่งขัน ของฟุตบอล)'
                                                                                            when 'J' then N'(for Soccer - LIVE)'
                                                                                            when 'KO' then N'(축구- 생중계)'
                                                                                            when 'VI' then N'(Bóng đá - Trực tuyến)'
                                                                                            else N'(for Soccer - LIVE)' END
                        end    
                        ,  @ErrCode=212
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END
        END
        ---------------------------------
        --Update Basketball
        if @bettype in (1,2,3,7,8,9,20) and (@autov2positiontaking <> @old_autov2positiontaking or @isautov2positiontaking <> @old_isautov2positiontaking ) and (@updatepositiontakingv2 = 1 or @updatemultiple=0)
        BEGIN
            if @isautov2positiontaking >0
            BEGIN
                select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=2 and bettype = @bettype
                update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov2positiontaking then @autov2positiontaking else @maxpos - mpositiontaking-apositiontaking end
                from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=2 and custsetting.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Basketball)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
                            end
                        ,  @ErrCode=213
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautov2positiontaking <> @old_isautov2positiontaking
            BEGIN
                if @updateallmembers = 1
                BEGIN
                    update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                    from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                    inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=2 and custsetting.isautopositiontaking=0
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Basketball)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
                            end    
                            ,  @ErrCode=214
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END
        END    
        
                ---------------------------------
        --Update Football
        if @bettype in (1,2,3,20) and (@autov3positiontaking <> @old_autov3positiontaking or @isautov3positiontaking <> @old_isautov3positiontaking ) and (@updatepositiontakingv3 = 1 or @updatemultiple=0)
        BEGIN
            if @isautov3positiontaking >0
            BEGIN
                select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=3 and bettype = @bettype
                update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov3positiontaking then @autov3positiontaking else @maxpos - mpositiontaking-apositiontaking end
                from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=3 and custsetting.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Football)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
                            end    
                            ,  @ErrCode=215
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautov3positiontaking <> @old_isautov3positiontaking
            BEGIN
                if @updateallmembers = 1
                BEGIN
                    update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                    from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                    inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=3 and custsetting.isautopositiontaking=0
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Football)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
                            end    
                            ,  @ErrCode=216
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END
        END    

        ---------------------------------
        --Update Tennis
        if @bettype in (1,2,3,20) and (@autov5positiontaking <> @old_autov5positiontaking or @isautov5positiontaking <> @old_isautov5positiontaking ) and (@updatepositiontakingv5 = 1 or @updatemultiple=0)
        BEGIN
            if @isautov5positiontaking >0
            BEGIN
                select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=5 and bettype = @bettype
                update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov5positiontaking then @autov5positiontaking else @maxpos - mpositiontaking-apositiontaking end
                from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=5 and custsetting.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Tennis)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
                            end
                            ,  @ErrCode=217
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautov5positiontaking <> @old_isautov5positiontaking
            BEGIN
                if @updateallmembers = 1
                BEGIN
                    update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                    from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                    inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=5 and custsetting.isautopositiontaking=0
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Tennis)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
                            end    
                            ,  @ErrCode=218
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END
        END    

        ---------------------------------
        --Update Baseball
        if @bettype in (1,3,20) and (@autov8positiontaking <> @old_autov8positiontaking or @isautov8positiontaking <> @old_isautov8positiontaking ) and (@updatepositiontakingv8 = 1 or @updatemultiple=0)
        BEGIN
            if @isautov8positiontaking >0
            BEGIN
                select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=8 and bettype = @bettype
                update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov8positiontaking then @autov8positiontaking else @maxpos - mpositiontaking-apositiontaking end
                from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=8 and custsetting.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Baseball)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
                            end    
                            ,  @ErrCode=219
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautov8positiontaking <> @old_isautov8positiontaking
            BEGIN
                if @updateallmembers = 1
                BEGIN
                    update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                    from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                    inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=8 and custsetting.isautopositiontaking=0
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Baseball)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
                            end    
                            ,  @ErrCode=220
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END
        END    

        ---------------------------------
        --Update Golf
        if @bettype in (1,2,3,20) and (@autov10positiontaking <> @old_autov10positiontaking or @isautov10positiontaking <> @old_isautov10positiontaking ) and (@updatepositiontakingv10 = 1 or @updatemultiple=0)
        BEGIN
            if @isautov10positiontaking >0
            BEGIN
                select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=10 and bettype = @bettype
                update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov10positiontaking then @autov10positiontaking else @maxpos - mpositiontaking-apositiontaking end
                from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=10 and custsetting.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Golf)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
                            end    
                            ,  @ErrCode=221
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautov10positiontaking <> @old_isautov10positiontaking
            BEGIN
                if @updateallmembers = 1
                BEGIN
                    update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                    from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                    inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=10 and custsetting.isautopositiontaking=0
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Golf)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
                            end    
                            ,  @ErrCode=222
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END
        END    

        ---------------------------------
        --Update Motorsports
        if @bettype in (1,20) and (@autov11positiontaking <> @old_autov11positiontaking or @isautov11positiontaking <> @old_isautov11positiontaking ) and (@updatepositiontakingv11 = 1 or @updatemultiple=0)
        BEGIN
            if @isautov11positiontaking >0
            BEGIN
                select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=11 and bettype = @bettype
                update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov11positiontaking then @autov11positiontaking else @maxpos - mpositiontaking-apositiontaking end
                from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=11 and custsetting.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Motorsports)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
                            end    
                            ,  @ErrCode=223
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautov11positiontaking <> @old_isautov11positiontaking
            BEGIN
                if @updateallmembers = 1
                BEGIN
                    update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                    from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                    inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=11 and custsetting.isautopositiontaking=0
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Motorsports)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
                            end    
                            ,  @ErrCode=224
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END
        END    
        ---------------------------------
        --Update Other sports
        if @bettype in (1,2,3,20) and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking ) and (@updatepositiontakingv99 = 1 or @updatemultiple=0)
        BEGIN
            if @isautov99positiontaking >0
            BEGIN
                select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=99 and bettype = @bettype
                update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov99positiontaking then @autov99positiontaking else @maxpos - mpositiontaking-apositiontaking end
                from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 and custsetting.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Other sports)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
                            end    
                            ,  @ErrCode=225
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautov99positiontaking <> @old_isautov99positiontaking
            BEGIN
                if @updateallmembers = 1
                BEGIN
                    update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                    from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                    inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 and custsetting.isautopositiontaking=0
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Other sports)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
                            end    
                            ,  @ErrCode=226
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END
        END            
        
        ---------------------------------
        --Update Mixed sports
        if @bettype =9 and (@autov99mppositiontaking <> @old_autov99mppositiontaking or @isautov99mppositiontaking <> @old_isautov99mppositiontaking ) and (@updatepositiontakingv99mp = 1 or @updatemultiple=0)
        BEGIN
            if @isautov99mppositiontaking >0
            BEGIN
                select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=99 and bettype = @bettype
                update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking > @autov99mppositiontaking then @autov99mppositiontaking else @maxpos - mpositiontaking-apositiontaking end
                from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 and custsetting.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Mix Sports Parlay)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + case @Language 
                                                                                            when 'CS' then N'(供混合体育过关)'
                                                                                            when 'CT' then N'(供混合體育過關)'
                                                                                            when 'TH' then N'(สำหรับกีฬาบอลชุด)'
                                                                                            when 'J' then N'(Mix Sports Parlay)'
                                                                                            when 'KO' then N'(Mix Sports Parlay)'
                                                                                            when 'VI' then N'(Mix Sports Parlay)'
                                                                                            else N'(Mix Sports Parlay)' END
                            end    
                            ,  @ErrCode=303
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautov99mppositiontaking <> @old_isautov99mppositiontaking
            BEGIN
                if @updateallmembers = 1
                BEGIN
                    update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                    from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                    inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 and custsetting.isautopositiontaking=0
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Mix Sports Parlay)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + case @Language 
                                                                                            when 'CS' then N'(供混合体育过关)'
                                                                                            when 'CT' then N'(供混合體育過關)'
                                                                                            when 'TH' then N'(สำหรับกีฬาบอลชุด)'
                                                                                            when 'J' then N'(Mix Sports Parlay)'
                                                                                            when 'KO' then N'(Mix Sports Parlay)'
                                                                                            when 'VI' then N'(Mix Sports Parlay)'
                                                                                            else N'(Mix Sports Parlay)' END
                            end    
                            ,  @ErrCode=304
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END
        END

        ---------------------------------
        --Update HR Fixed Odds
        if @bettype in (20) and (@autov154positiontaking <> @old_autov154positiontaking or @isautov154positiontaking <> @old_isautov154positiontaking ) and (@updatepositiontakingv154 = 1 or @updatemultiple=0)
        BEGIN
            if @isautov154positiontaking >0
            BEGIN
                select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=154 and bettype = @bettype
                update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov154positiontaking then @autov154positiontaking else @maxpos - mpositiontaking-apositiontaking end
                from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=154 and custsetting.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for HR Fixed Odds)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
                            end    
                            ,  @ErrCode=223
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautov154positiontaking <> @old_isautov154positiontaking
            BEGIN
                if @updateallmembers = 1
                BEGIN
                    update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                    from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
                    inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=154 and custsetting.isautopositiontaking=0
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for HR Fixed Odds)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
                            end    
                            ,  @ErrCode=224
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END
        END    
        
        ---------------------------------
        --Update Number game
        if @bettype in (81,83,86,88) and (@autov161positiontaking <> @old_autov161positiontaking or @isautov161positiontaking <> @old_isautov161positiontaking ) and (@updatepositiontakingv161 = 1 or @updatemultiple=0)
        BEGIN
            if @isautov161positiontaking > 0
            BEGIN
                select @maxpos = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
                update cs3 with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking > @autov161positiontaking then @autov161positiontaking else @maxpos - mpositiontaking-apositiontaking end
                from custsetting3rd cs3 inner join customer as c with (NOLOCK) on cs3.custid = c.custid
                where c.mrecommend = @mrecommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161 and cs3.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Number game)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
                            end    
                            ,  @ErrCode=305
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautov161positiontaking <> @old_isautov161positiontaking
            BEGIN
                if @updateallmembers = 1
                BEGIN
                    update cs3 with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs3.spositiontaking<@newspositiontaking then mcs3.spositiontaking else @newspositiontaking end
                    from custsetting3rd cs3 inner join customer as c with (NOLOCK) on cs3.custid = c.custid
                    inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = @mrecommend and cs3.sporttype=mcs3.sporttype and cs3.bettype=mcs3.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161 and cs3.isautopositiontaking=0
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                            case @Language 
                                when 'E' then 'Error updating auto position taking (for Number game)'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
                            end    
                            ,  @ErrCode=306
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END                    
        END
        --- number game live        
        if @bettype in (85,86,87,89,90) and (@autov161livepositiontaking <> @old_autov161livepositiontaking or @isautov161livepositiontaking <> @old_isautov161livepositiontaking ) and (@updatepositiontakingv161 = 1 or @updatemultiple=0)
        BEGIN
            if @isautov161livepositiontaking > 0
            BEGIN
                select @maxpos = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
                update custsetting3rd with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
                from custsetting3rd inner join customer as c with (NOLOCK) on custsetting3rd.custid = c.custid
                where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting3rd.bettype = @bettype and custsetting3rd.sporttype=161 and custsetting3rd.isautolivepositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg =  
                        case @Language 
                            when 'E' then 'Error updating auto position taking (for Number Game - LIVE)'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + case @Language 
                                                                                            when 'CS' then N'(供数字游戏-现场)'
                                                                                            when 'CT' then N'(供數字游戲-現場)'
                                                                                            when 'TH' then N'(สำหรับเกมหมายเลข -สด)'
                                                                                            when 'J' then N'(for Number Game - LIVE)'
                                                                                            when 'KO' then N'(for Number Game - LIVE)'
                                                                                            when 'VI' then N'(for Number Game - Trực tuyến)'
                                                                                            else N'(for Number Game - LIVE)' END
                        end    
                        ,  @ErrCode=307
                    DEALLOCATE CUR
                    CLOSE CUR
                    return
                END
            END
            else if @isautov161livepositiontaking <> @old_isautov161livepositiontaking
            BEGIN
                if @updateallmembers = 1
                BEGIN
                    update custsetting3rd with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when mcs.slivepositiontaking<@newspositiontaking then mcs.slivepositiontaking else @newspositiontaking end
                    from custsetting3rd inner join customer as c with (NOLOCK) on custsetting3rd.custid = c.custid
                    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting3rd.sporttype=mcs.sporttype and custsetting3rd.bettype=mcs.bettype
                    where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting3rd.bettype = @bettype and custsetting3rd.sporttype=161 and custsetting3rd.isautolivepositiontaking=0                
                    if @@Error <> 0
                    BEGIN
                        
                        SELECT @ErrMsg =  
                        case @Language 
                            when 'E' then 'Error updating auto position taking (for Number Game - LIVE)'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + case @Language 
                                                                                            when 'CS' then N'(供数字游戏-现场)'
                                                                                            when 'CT' then N'(供數字游戲-現場)'
                                                                                            when 'TH' then N'(สำหรับเกมหมายเลข -สด)'
                                                                                            when 'J' then N'(for Number Game - LIVE)'
                                                                                            when 'KO' then N'(for Number Game - LIVE)'
                                                                                            when 'VI' then N'(for Number Game - Trực tuyến)'
                                                                                            else N'(for Number Game - LIVE)' END
                        end    
                        ,  @ErrCode=308
                        DEALLOCATE CUR
                        CLOSE CUR
                        return
                    END
                END
            END 
        END        ---- end live

        FETCH NEXT FROM CUR INTO
            @bettype, @isautopositiontaking, @isautolivepositiontaking, @autopositiontaking, @autolivepositiontaking, @old_autopositiontaking, @old_autolivepositiontaking, @old_isautopositiontaking, @old_isautolivepositiontaking,
            @isautov2positiontaking, @autov2positiontaking, @old_autov2positiontaking, @old_isautov2positiontaking,    
            @isautov3positiontaking, @autov3positiontaking, @old_autov3positiontaking, @old_isautov3positiontaking,    
            @isautov5positiontaking, @autov5positiontaking, @old_autov5positiontaking, @old_isautov5positiontaking,    
            @isautov8positiontaking, @autov8positiontaking, @old_autov8positiontaking, @old_isautov8positiontaking,    
            @isautov10positiontaking, @autov10positiontaking, @old_autov10positiontaking, @old_isautov10positiontaking,
            @isautov11positiontaking, @autov11positiontaking, @old_autov11positiontaking, @old_isautov11positiontaking,
            @isautov99positiontaking, @autov99positiontaking, @old_autov99positiontaking, @old_isautov99positiontaking,
            @isautov99mppositiontaking, @autov99mppositiontaking, @old_autov99mppositiontaking, @old_isautov99mppositiontaking,
            @isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking,
            @isautov154positiontaking, @autov154positiontaking, @old_autov154positiontaking, @old_isautov154positiontaking
            
    END

    CLOSE CUR
    DEALLOCATE CUR
--END*/






GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_AutoPositiontaking] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_AutoPositiontaking] TO [bodbDownlineNetView]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_AutoPositiontaking] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_AutoPositiontaking] TO [bodbDownlineNet]
GO 
