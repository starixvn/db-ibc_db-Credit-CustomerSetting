ALTER PROCEDURE [dbo].[Acc_CustSetting_05]
    @srecommend INT = 0,
    @mrecommend INT =0,
    @recommend INT = 0,
    @roleid INT,
    --UPDATE auto pt ON master
    @isauto_spositiontaking_1 bit = 0, 
    @isauto_spositiontaking_2 bit = 0,
    @isauto_spositiontaking_3 bit = 0,
    @isauto_spositiontaking_4 bit = 0,
    @isauto_spositiontaking_5 bit = 0,
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
    
    @old_isauto_spositiontaking_1 bit = 0, 
    @old_isauto_spositiontaking_2 bit = 0, 
    @old_isauto_spositiontaking_3 bit = 0,
    @old_isauto_spositiontaking_4 bit = 0, 
    @old_isauto_spositiontaking_5 bit = 0, 
    @old_isauto_spositiontaking_6 bit = 0, 
    @old_isauto_spositiontaking_7 bit = 0, 
    @old_isauto_spositiontaking_8 bit = 0, 
    @old_isauto_spositiontaking_9 bit = 0,  
    @old_isauto_spositiontaking_10 bit = 0, 
    @old_isauto_spositiontaking_9999 bit = 0,  
    @old_isauto_slivepositiontaking_1 bit = 0, 
    @old_isauto_slivepositiontaking_3 bit = 0, 
    @old_isauto_slivepositiontaking_7 bit = 0, 
    @old_isauto_slivepositiontaking_8 bit = 0, 
    
    @old_isauto_v2spositiontaking_1 bit = 0,
    @old_isauto_v2spositiontaking_2 bit = 0,
    @old_isauto_v2spositiontaking_3 bit = 0,
    @old_isauto_v2spositiontaking_7 bit = 0,
    @old_isauto_v2spositiontaking_8 bit = 0,
    @old_isauto_v2spositiontaking_20 bit = 0,
    
    @old_isauto_v3spositiontaking_1 bit = 0,
    @old_isauto_v3spositiontaking_2 bit = 0,
    @old_isauto_v3spositiontaking_3 bit = 0,
    @old_isauto_v3spositiontaking_20 bit = 0,

    @old_isauto_v5spositiontaking_1 bit = 0,
    @old_isauto_v5spositiontaking_2 bit = 0,
    @old_isauto_v5spositiontaking_3 bit = 0,
    @old_isauto_v5spositiontaking_20 bit = 0,
    @old_isauto_v5spositiontaking_9999 bit = 0,

    @old_isauto_v8spositiontaking_1 bit = 0,
    @old_isauto_v8spositiontaking_3 bit = 0,
    @old_isauto_v8spositiontaking_20 bit = 0,

    @old_isauto_v10spositiontaking_1 bit = 0,
    @old_isauto_v10spositiontaking_2 bit = 0,
    @old_isauto_v10spositiontaking_3 bit = 0,
    @old_isauto_v10spositiontaking_20 bit = 0,

    @old_isauto_v11spositiontaking_1 bit = 0,
    @old_isauto_v11spositiontaking_20 bit = 0,

    @old_isauto_v99spositiontaking_1 bit = 0,
    @old_isauto_v99spositiontaking_2 bit = 0,
    @old_isauto_v99spositiontaking_3 bit = 0,
    @old_isauto_v99spositiontaking_20 bit = 0,

    -- mixed sports
    @old_isauto_v99spositiontaking_9 bit = 0,
    @old_isauto_v154spositiontaking_20 bit = 0,
    
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

    -- mixed sports
    @auto_v99spositiontaking_9 smallmoney = 0,
    @auto_v154spositiontaking_20 smallmoney = 0,

    @old_auto_spositiontaking_1 smallmoney = 0, 
    @old_auto_spositiontaking_2 smallmoney = 0,
    @old_auto_spositiontaking_3 smallmoney = 0,
    @old_auto_spositiontaking_4 smallmoney = 0,
    @old_auto_spositiontaking_5 smallmoney = 0,
    @old_auto_spositiontaking_6 smallmoney = 0,
    @old_auto_spositiontaking_7 smallmoney = 0,
    @old_auto_spositiontaking_8 smallmoney = 0,
    @old_auto_spositiontaking_9 smallmoney = 0,
    @old_auto_spositiontaking_10 smallmoney = 0,
    @old_auto_spositiontaking_9999 smallmoney = 0,
    @old_auto_slivepositiontaking_1 smallmoney = 0,
    @old_auto_slivepositiontaking_3 smallmoney = 0,
    @old_auto_slivepositiontaking_7 smallmoney = 0,
    @old_auto_slivepositiontaking_8 smallmoney = 0,
    
    @old_auto_v2spositiontaking_1 smallmoney = 0,
    @old_auto_v2spositiontaking_2 smallmoney = 0,
    @old_auto_v2spositiontaking_3 smallmoney = 0,
    @old_auto_v2spositiontaking_7 smallmoney = 0,
    @old_auto_v2spositiontaking_8 smallmoney = 0,
--    @old_auto_v2spositiontaking_9 smallmoney = 0,
    @old_auto_v2spositiontaking_20 smallmoney = 0,
    
    @old_auto_v3spositiontaking_1 smallmoney = 0,
    @old_auto_v3spositiontaking_2 smallmoney = 0,
    @old_auto_v3spositiontaking_3 smallmoney = 0,
    @old_auto_v3spositiontaking_20 smallmoney = 0,

    @old_auto_v5spositiontaking_1 smallmoney = 0,
    @old_auto_v5spositiontaking_2 smallmoney = 0,
    @old_auto_v5spositiontaking_3 smallmoney = 0,
    @old_auto_v5spositiontaking_20 smallmoney = 0,
    @old_auto_v5spositiontaking_9999 smallmoney = 0,

    @old_auto_v8spositiontaking_1 smallmoney = 0,
    @old_auto_v8spositiontaking_3 smallmoney = 0,
    @old_auto_v8spositiontaking_20 smallmoney = 0,

    @old_auto_v10spositiontaking_1 smallmoney = 0,
    @old_auto_v10spositiontaking_2 smallmoney = 0,
    @old_auto_v10spositiontaking_3 smallmoney = 0,
    @old_auto_v10spositiontaking_20 smallmoney = 0,

    @old_auto_v11spositiontaking_1 smallmoney = 0,
    @old_auto_v11spositiontaking_20 smallmoney = 0,

    @old_auto_v99spositiontaking_1 smallmoney = 0,
    @old_auto_v99spositiontaking_2 smallmoney = 0,
    @old_auto_v99spositiontaking_3 smallmoney = 0,
    @old_auto_v99spositiontaking_20 smallmoney = 0,

    -- mixed sports
    @old_auto_v99spositiontaking_9 smallmoney = 0,
    @old_auto_v154spositiontaking_20 smallmoney = 0,
    
    --UPDATE auto pt ON agent
    @isauto_mpositiontaking_1 bit = 0, 
    @isauto_mpositiontaking_2 bit = 0, 
    @isauto_mpositiontaking_3 bit = 0, 
    @isauto_mpositiontaking_4 bit = 0, 
    @isauto_mpositiontaking_5 bit = 0, 
    @isauto_mpositiontaking_6 bit = 0, 
    @isauto_mpositiontaking_7 bit = 0, 
    @isauto_mpositiontaking_8 bit = 0, 
    @isauto_mpositiontaking_9 bit = 0, 
    @isauto_mpositiontaking_10 bit = 0,
    @isauto_mpositiontaking_9999 bit = 0,  
    @isauto_mlivepositiontaking_1 bit = 0, 
    @isauto_mlivepositiontaking_3 bit = 0, 
    @isauto_mlivepositiontaking_7 bit = 0, 
    @isauto_mlivepositiontaking_8 bit = 0, 
    
    @isauto_v2mpositiontaking_1 bit = 0,
    @isauto_v2mpositiontaking_2 bit = 0,
    @isauto_v2mpositiontaking_3 bit = 0,
    @isauto_v2mpositiontaking_7 bit = 0,
    @isauto_v2mpositiontaking_8 bit = 0,
    @isauto_v2mpositiontaking_20 bit = 0,
    
    @isauto_v3mpositiontaking_1 bit = 0,
    @isauto_v3mpositiontaking_2 bit = 0,
    @isauto_v3mpositiontaking_3 bit = 0,
    @isauto_v3mpositiontaking_20 bit = 0,
    
    @isauto_v5mpositiontaking_1 bit = 0,
    @isauto_v5mpositiontaking_2 bit = 0,
    @isauto_v5mpositiontaking_3 bit = 0,
    @isauto_v5mpositiontaking_20 bit = 0,
    @isauto_v5mpositiontaking_9999 bit = 0,
    
    @isauto_v8mpositiontaking_1 bit = 0,
    @isauto_v8mpositiontaking_3 bit = 0,
    @isauto_v8mpositiontaking_20 bit = 0,

    @isauto_v10mpositiontaking_1 bit = 0,
    @isauto_v10mpositiontaking_2 bit = 0,
    @isauto_v10mpositiontaking_3 bit = 0,
    @isauto_v10mpositiontaking_20 bit = 0,

    @isauto_v11mpositiontaking_1 bit = 0,
    @isauto_v11mpositiontaking_20 bit = 0,

    @isauto_v99mpositiontaking_1 bit = 0,
    @isauto_v99mpositiontaking_2 bit = 0,
    @isauto_v99mpositiontaking_3 bit = 0,
    @isauto_v99mpositiontaking_20 bit = 0,

    -- mixed sports
    @isauto_v99mpositiontaking_9 bit = 0,
    @isauto_v154mpositiontaking_20 bit = 0,
    
    @old_isauto_mpositiontaking_1 bit = 0, 
    @old_isauto_mpositiontaking_2 bit = 0, 
    @old_isauto_mpositiontaking_3 bit = 0, 
    @old_isauto_mpositiontaking_4 bit = 0, 
    @old_isauto_mpositiontaking_5 bit = 0, 
    @old_isauto_mpositiontaking_6 bit = 0, 
    @old_isauto_mpositiontaking_7 bit = 0, 
    @old_isauto_mpositiontaking_8 bit = 0, 
    @old_isauto_mpositiontaking_9 bit = 0, 
    @old_isauto_mpositiontaking_10 bit = 0,
    @old_isauto_mpositiontaking_9999 bit = 0,  
    @old_isauto_mlivepositiontaking_1 bit = 0, 
    @old_isauto_mlivepositiontaking_3 bit = 0, 
    @old_isauto_mlivepositiontaking_7 bit = 0, 
    @old_isauto_mlivepositiontaking_8 bit = 0, 
    
    @old_isauto_v2mpositiontaking_1 bit = 0,
    @old_isauto_v2mpositiontaking_2 bit = 0,
    @old_isauto_v2mpositiontaking_3 bit = 0,
    @old_isauto_v2mpositiontaking_7 bit = 0,
    @old_isauto_v2mpositiontaking_8 bit = 0,
    @old_isauto_v2mpositiontaking_20 bit = 0,
    
    @old_isauto_v3mpositiontaking_1 bit = 0,
    @old_isauto_v3mpositiontaking_2 bit = 0,
    @old_isauto_v3mpositiontaking_3 bit = 0,
    @old_isauto_v3mpositiontaking_20 bit = 0,
    
    @old_isauto_v5mpositiontaking_1 bit = 0,
    @old_isauto_v5mpositiontaking_2 bit = 0,
    @old_isauto_v5mpositiontaking_3 bit = 0,
    @old_isauto_v5mpositiontaking_20 bit = 0,
    @old_isauto_v5mpositiontaking_9999 bit = 0,
    
    @old_isauto_v8mpositiontaking_1 bit = 0,
    @old_isauto_v8mpositiontaking_3 bit = 0,
    @old_isauto_v8mpositiontaking_20 bit = 0,

    @old_isauto_v10mpositiontaking_1 bit = 0,
    @old_isauto_v10mpositiontaking_2 bit = 0,
    @old_isauto_v10mpositiontaking_3 bit = 0,
    @old_isauto_v10mpositiontaking_20 bit = 0,

    @old_isauto_v11mpositiontaking_1 bit = 0,
    @old_isauto_v11mpositiontaking_20 bit = 0,

    @old_isauto_v99mpositiontaking_1 bit = 0,
    @old_isauto_v99mpositiontaking_2 bit = 0,
    @old_isauto_v99mpositiontaking_3 bit = 0,
    @old_isauto_v99mpositiontaking_20 bit = 0,

    -- mixed sports
    @old_isauto_v99mpositiontaking_9 bit = 0,
    @old_isauto_v154mpositiontaking_20 bit = 0,
    
    @auto_mpositiontaking_1 smallmoney = 0, 
    @auto_mpositiontaking_2 smallmoney = 0,
    @auto_mpositiontaking_3 smallmoney = 0,
    @auto_mpositiontaking_4 smallmoney = 0,
    @auto_mpositiontaking_5 smallmoney= 0,
    @auto_mpositiontaking_6 smallmoney = 0,
    @auto_mpositiontaking_7 smallmoney = 0,
    @auto_mpositiontaking_8 smallmoney = 0,
    @auto_mpositiontaking_9 smallmoney = 0,
    @auto_mpositiontaking_10 smallmoney = 0,
    @auto_mpositiontaking_9999 smallmoney = 0,
    @auto_mlivepositiontaking_1 smallmoney = 0,
    @auto_mlivepositiontaking_3 smallmoney = 0,
    @auto_mlivepositiontaking_7 smallmoney = 0,
    @auto_mlivepositiontaking_8 smallmoney = 0,
    
    @auto_v2mpositiontaking_1 smallmoney = 0,
    @auto_v2mpositiontaking_2 smallmoney = 0,
    @auto_v2mpositiontaking_3 smallmoney = 0,
    @auto_v2mpositiontaking_7 smallmoney = 0,
    @auto_v2mpositiontaking_8 smallmoney = 0,
--    @auto_v2mpositiontaking_9 smallmoney = 0,
    @auto_v2mpositiontaking_20 smallmoney = 0,
    
    @auto_v3mpositiontaking_1 smallmoney = 0,
    @auto_v3mpositiontaking_2 smallmoney = 0,
    @auto_v3mpositiontaking_3 smallmoney = 0,
    @auto_v3mpositiontaking_20 smallmoney = 0,

    @auto_v5mpositiontaking_1 smallmoney = 0,
    @auto_v5mpositiontaking_2 smallmoney = 0,
    @auto_v5mpositiontaking_3 smallmoney = 0,
    @auto_v5mpositiontaking_20 smallmoney = 0,
    @auto_v5mpositiontaking_9999 smallmoney = 0,

    @auto_v8mpositiontaking_1 smallmoney = 0,
    @auto_v8mpositiontaking_3 smallmoney = 0,
    @auto_v8mpositiontaking_20 smallmoney = 0,

    @auto_v10mpositiontaking_1 smallmoney = 0,
    @auto_v10mpositiontaking_2 smallmoney = 0,
    @auto_v10mpositiontaking_3 smallmoney = 0,
    @auto_v10mpositiontaking_20 smallmoney = 0,

    @auto_v11mpositiontaking_1 smallmoney = 0,
    @auto_v11mpositiontaking_20 smallmoney = 0,
    @auto_v99mpositiontaking_1 smallmoney = 0,
    @auto_v99mpositiontaking_2 smallmoney = 0,
    @auto_v99mpositiontaking_3 smallmoney = 0,
    @auto_v99mpositiontaking_20 smallmoney = 0,
    
    -- mixed sports
    @auto_v99mpositiontaking_9 smallmoney = 0,
    @auto_v154mpositiontaking_20 smallmoney = 0,
    
    @old_auto_mpositiontaking_1 smallmoney = 0, 
    @old_auto_mpositiontaking_2 smallmoney = 0,
    @old_auto_mpositiontaking_3 smallmoney = 0,
    @old_auto_mpositiontaking_4 smallmoney = 0,
    @old_auto_mpositiontaking_5 smallmoney= 0,
    @old_auto_mpositiontaking_6 smallmoney = 0,
    @old_auto_mpositiontaking_7 smallmoney = 0,
    @old_auto_mpositiontaking_8 smallmoney = 0,
    @old_auto_mpositiontaking_9 smallmoney = 0,
    @old_auto_mpositiontaking_10 smallmoney = 0,
    @old_auto_mpositiontaking_9999 smallmoney = 0,
    @old_auto_mlivepositiontaking_1 smallmoney = 0,
    @old_auto_mlivepositiontaking_3 smallmoney = 0,
    @old_auto_mlivepositiontaking_7 smallmoney = 0,
    @old_auto_mlivepositiontaking_8 smallmoney = 0,
    
    @old_auto_v2mpositiontaking_1 smallmoney = 0,
    @old_auto_v2mpositiontaking_2 smallmoney = 0,
    @old_auto_v2mpositiontaking_3 smallmoney = 0,
    @old_auto_v2mpositiontaking_7 smallmoney = 0,
    @old_auto_v2mpositiontaking_8 smallmoney = 0,
--    @old_auto_v2mpositiontaking_9 smallmoney = 0,
    @old_auto_v2mpositiontaking_20 smallmoney = 0,
    
    @old_auto_v3mpositiontaking_1 smallmoney = 0,
    @old_auto_v3mpositiontaking_2 smallmoney = 0,
    @old_auto_v3mpositiontaking_3 smallmoney = 0,
    @old_auto_v3mpositiontaking_20 smallmoney = 0,

    @old_auto_v5mpositiontaking_1 smallmoney = 0,
    @old_auto_v5mpositiontaking_2 smallmoney = 0,
    @old_auto_v5mpositiontaking_3 smallmoney = 0,
    @old_auto_v5mpositiontaking_20 smallmoney = 0,
    @old_auto_v5mpositiontaking_9999 smallmoney = 0,

    @old_auto_v8mpositiontaking_1 smallmoney = 0,
    @old_auto_v8mpositiontaking_3 smallmoney = 0,
    @old_auto_v8mpositiontaking_20 smallmoney = 0,

    @old_auto_v10mpositiontaking_1 smallmoney = 0,
    @old_auto_v10mpositiontaking_2 smallmoney = 0,
    @old_auto_v10mpositiontaking_3 smallmoney = 0,
    @old_auto_v10mpositiontaking_20 smallmoney = 0,

    @old_auto_v11mpositiontaking_1 smallmoney = 0,
    @old_auto_v11mpositiontaking_20 smallmoney = 0,
    @old_auto_v99mpositiontaking_1 smallmoney = 0,
    @old_auto_v99mpositiontaking_2 smallmoney = 0,
    @old_auto_v99mpositiontaking_3 smallmoney = 0,
    @old_auto_v99mpositiontaking_20 smallmoney = 0,
    
    -- mixed sports
    @old_auto_v99mpositiontaking_9 smallmoney = 0,
    @old_auto_v154mpositiontaking_20 smallmoney = 0,
    
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
    
    @updateallmembers bit = 0,
    @newspositiontaking smallmoney = 0,
    @newmpositiontaking smallmoney = 0,
    
    -- Outright PT for sports
    @isauto_v2spositiontaking_10 bit = 0,
    @isauto_v3spositiontaking_10 bit = 0,
    @isauto_v5spositiontaking_10 bit = 0,
    @isauto_v8spositiontaking_10 bit = 0,
    @isauto_v10spositiontaking_10 bit = 0,
    @isauto_v11spositiontaking_10 bit = 0,
    @isauto_v99spositiontaking_10 bit = 0,
    
	@old_isauto_v2spositiontaking_10 bit = 0,  
	@old_isauto_v3spositiontaking_10 bit = 0, 
	@old_isauto_v5spositiontaking_10 bit = 0, 
	@old_isauto_v8spositiontaking_10 bit = 0, 
	@old_isauto_v10spositiontaking_10 bit = 0, 
	@old_isauto_v11spositiontaking_10 bit = 0, 
	@old_isauto_v99spositiontaking_10 bit = 0, 
	
	@auto_v2spositiontaking_10 smallmoney = 0,
	@auto_v3spositiontaking_10 smallmoney = 0,
	@auto_v5spositiontaking_10 smallmoney = 0,
	@auto_v8spositiontaking_10 smallmoney = 0,
	@auto_v10spositiontaking_10 smallmoney = 0,
	@auto_v11spositiontaking_10 smallmoney = 0,
	@auto_v99spositiontaking_10 smallmoney = 0,
	
	@old_auto_v2spositiontaking_10 smallmoney = 0,
	@old_auto_v3spositiontaking_10 smallmoney = 0,
	@old_auto_v5spositiontaking_10 smallmoney = 0,
	@old_auto_v8spositiontaking_10 smallmoney = 0,
	@old_auto_v10spositiontaking_10 smallmoney = 0,
	@old_auto_v11spositiontaking_10 smallmoney = 0,
	@old_auto_v99spositiontaking_10 smallmoney = 0,
	
	@isauto_v2mpositiontaking_10 bit = 0,
	@isauto_v3mpositiontaking_10 bit = 0,
	@isauto_v5mpositiontaking_10 bit = 0,
	@isauto_v8mpositiontaking_10 bit = 0,
	@isauto_v10mpositiontaking_10 bit = 0,
	@isauto_v11mpositiontaking_10 bit = 0,
	@isauto_v99mpositiontaking_10 bit = 0,
	
	@auto_v2mpositiontaking_10 smallmoney = 0,
	@auto_v3mpositiontaking_10 smallmoney = 0,
	@auto_v5mpositiontaking_10 smallmoney = 0,
	@auto_v8mpositiontaking_10 smallmoney = 0,
	@auto_v10mpositiontaking_10 smallmoney = 0,
	@auto_v11mpositiontaking_10 smallmoney = 0,
	@auto_v99mpositiontaking_10 smallmoney = 0,
	
	@old_auto_v2mpositiontaking_10 smallmoney = 0,
	@old_auto_v3mpositiontaking_10 smallmoney = 0,
	@old_auto_v5mpositiontaking_10 smallmoney = 0,
	@old_auto_v8mpositiontaking_10 smallmoney = 0,
	@old_auto_v10mpositiontaking_10 smallmoney = 0,
	@old_auto_v11mpositiontaking_10 smallmoney = 0,
	@old_auto_v99mpositiontaking_10 smallmoney = 0,
	
	@old_isauto_v2mpositiontaking_10 bit = 0,
	@old_isauto_v3mpositiontaking_10 bit = 0,
	@old_isauto_v5mpositiontaking_10 bit = 0,
	@old_isauto_v8mpositiontaking_10 bit = 0,
	@old_isauto_v10mpositiontaking_10 bit = 0,
	@old_isauto_v11mpositiontaking_10 bit = 0,
	@old_isauto_v99mpositiontaking_10 bit = 0

	
    
 AS
    /*
        Created: Johnson
        Date: 2013-10-29
        Task: Apply execrep when UPDATE auto pt ON master , agent, member levels
        DB: DBCUST/custDB
        Original versions: Acc_CustomerUpdMaster_AutoPositiontaking_xtest
                    Acc_CustomerUpdAgent_AutoPositiontaking_xtest
        
        Revision:
            - 20131105@Elodie: Add HR Fixed Odds [Redmine:#6505]
            - 20140624@Johnson: Add bettype Others fOR soccer & tennis [Redmine #16903]
            - 20140818@Logan: Exclude disabled members while updating Master setting [Redmine: #19631]
		  - 20150610@Daniel: 
		   + Improve medthod check table existing in subscribers	
		   + Separate custDB to new server DBCUST   
		 - 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]       

        Parameter's Explanation:        
    */
BEGIN
    SET NOCOUNT ON

     if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustSetting') = 1 
	   AND dbo.f_CheckRepTable('CustOverride') = 1 
	   )
     RETURN
   
    
    Declare
            @bettype int,
            @autopositiontaking smallmoney,
            @autolivepositiontaking smallmoney,
            
            @autov2positiontaking smallmoney,
            @autov3positiontaking smallmoney,
            @autov5positiontaking smallmoney,
            @autov8positiontaking smallmoney,
            @autov10positiontaking smallmoney,
            @autov11positiontaking smallmoney,
            @autov99positiontaking smallmoney,
            -- mixed sports
            @autov99mppositiontaking smallmoney,
            @autov154positiontaking smallmoney,

            @old_autopositiontaking smallmoney,
            @old_autolivepositiontaking smallmoney,

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
            @old_isautov154positiontaking smallmoney
        
    --UPDATE min/max pt ON master
    IF @roleid = 3
    BEGIN
        DECLARE CUR CURSOR FOR
            SELECT 1 AS bettype
                 , @isauto_spositiontaking_1        AS isautopositiontaking
                 , @isauto_slivepositiontaking_1    AS isautolivepositiontaking
                 , @auto_spositiontaking_1          AS autopositiontaking
                 , @auto_slivepositiontaking_1      AS autolivepositiontaking
                 , @old_auto_spositiontaking_1      AS old_autopositiontaking
                 , @old_auto_slivepositiontaking_1  AS old_autolivepositiontaking
                 , @old_isauto_spositiontaking_1    AS old_isautopositiontaking
                 , @old_isauto_slivepositiontaking_1 AS old_isautolivepositiontaking
                 , @isauto_v2spositiontaking_1      AS isautov2positiontaking
                 , @auto_v2spositiontaking_1        AS autov2positiontaking
                 , @old_auto_v2spositiontaking_1    AS old_autov2positiontaking
                 , @old_isauto_v2spositiontaking_1  AS old_isautov2positiontaking
                 , @isauto_v3spositiontaking_1      AS isautov3positiontaking
                 , @auto_v3spositiontaking_1        AS autov3positiontaking
                 , @old_auto_v3spositiontaking_1    AS old_autov3positiontaking
                 , @old_isauto_v3spositiontaking_1  AS old_isautov3positiontaking
                 , @isauto_v5spositiontaking_1      AS isautov5positiontaking
                 , @auto_v5spositiontaking_1        AS autov5positiontaking
                 , @old_auto_v5spositiontaking_1    AS old_autov5positiontaking
                 , @old_isauto_v5spositiontaking_1  AS old_isautov5positiontaking
                 , @isauto_v8spositiontaking_1      AS isautov8positiontaking
                 , @auto_v8spositiontaking_1        AS autov8positiontaking
                 , @old_auto_v8spositiontaking_1    AS old_autov8positiontaking
                 , @old_isauto_v8spositiontaking_1  AS old_isautov8positiontaking
                 , @isauto_v10spositiontaking_1     AS isautov10positiontaking
                 , @auto_v10spositiontaking_1       AS autov10positiontaking
                 , @old_auto_v10spositiontaking_1   AS old_autov10positiontaking
                 , @old_isauto_v10spositiontaking_1 AS old_isautov10positiontaking
                 , @isauto_v11spositiontaking_1     AS isautov11positiontaking
                 , @auto_v11spositiontaking_1       AS autov11positiontaking
                 , @old_auto_v11spositiontaking_1   AS old_autov11positiontaking
                 , @old_isauto_v11spositiontaking_1 AS old_isautov11positiontaking
                 , @isauto_v99spositiontaking_1     AS isautov99positiontaking
                 , @auto_v99spositiontaking_1       AS autov99positiontaking
                 , @old_auto_v99spositiontaking_1   AS old_autov99positiontaking
                 , @old_isauto_v99spositiontaking_1 AS old_isautov99positiontaking
                 , 0 AS isautov99mppositiontaking
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
--2
  UNION ALL SELECT 2 AS bettype
                   , @isauto_spositiontaking_2        AS isautopositiontaking
                   , 0 AS isautolivepositiontaking
                   , @auto_spositiontaking_2          AS autopositiontaking
                   , 0 AS autolivepositiontaking
                   , @old_auto_spositiontaking_2      AS old_autopositiontaking
                   , 0 AS old_autolivepositiontaking
                   , @old_isauto_spositiontaking_2    AS old_isautopositiontaking
                   , 0 AS old_isautolivepositiontaking
                   , @isauto_v2spositiontaking_2      AS isautov2positiontaking
                   , @auto_v2spositiontaking_2        AS autov2positiontaking
                   , @old_auto_v2spositiontaking_2    AS old_autov2positiontaking
                   , @old_isauto_v2spositiontaking_2  AS old_isautov2positiontaking
                   , @isauto_v3spositiontaking_2      AS isautov3positiontaking
                   , @auto_v3spositiontaking_2        AS autov3positiontaking
                   , @old_auto_v3spositiontaking_2    AS old_autov3positiontaking
                   , @old_isauto_v3spositiontaking_2  AS old_isautov3positiontaking
                   , @isauto_v5spositiontaking_2      AS isautov5positiontaking
                   , @auto_v5spositiontaking_2        AS autov5positiontaking
                   , @old_auto_v5spositiontaking_2    AS old_autov5positiontaking
                   , @old_isauto_v5spositiontaking_2  AS old_isautov5positiontaking
                   , 0 AS isautov8positiontaking
                   , 0 AS autov8positiontaking
                   , 0 AS old_autov8positiontaking
                   , 0 AS old_isautov8positiontaking
                   , @isauto_v10spositiontaking_2     AS isautov10positiontaking
                   , @auto_v10spositiontaking_2       AS autov10positiontaking
                   , @old_auto_v10spositiontaking_2   AS old_autov10positiontaking
                   , @old_isauto_v10spositiontaking_2 AS old_isautov10positiontaking
                   , 0 AS isautov11positiontaking
                   , 0 AS autov11positiontaking
                   , 0 AS old_autov11positiontaking
                   , 0 AS old_isautov11positiontaking
                   , @isauto_v99spositiontaking_2     AS isautov99positiontaking
                   , @auto_v99spositiontaking_2       AS autov99positiontaking
                   , @old_auto_v99spositiontaking_2   AS old_autov99positiontaking
                   , @old_isauto_v99spositiontaking_2 AS old_isautov99positiontaking
                   , 0 AS isautov99mppositiontaking
                   , 0 AS autov99mppositiontaking
                   , 0 AS old_isautov99mppositiontaking
                   , 0 AS old_autov99mppositiontaking
                   , 0 AS isautov154positiontaking
                   , 0 AS autov154positiontaking
                   , 0 AS old_autov154positiontaking
                   , 0 AS old_isautov154positiontaking
--3
  UNION ALL SELECT 3 AS bettype
                 , @isauto_spositiontaking_3 AS isautopositiontaking
                 , @isauto_slivepositiontaking_3 AS isautolivepositiontaking
                 , @auto_spositiontaking_3 AS autopositiontaking
                 , @auto_slivepositiontaking_3 AS autolivepositiontaking
                 , @old_auto_spositiontaking_3 AS old_autopositiontaking
                 , @old_auto_slivepositiontaking_3 AS old_autolivepositiontaking
                 , @old_isauto_spositiontaking_3 AS old_isautopositiontaking
                 , @old_isauto_slivepositiontaking_3 AS old_isautolivepositiontaking
                 , @isauto_v2spositiontaking_3 AS isautov2positiontaking
                 , @auto_v2spositiontaking_3 AS autov2positiontaking
                 , @old_auto_v2spositiontaking_3 AS old_autov2positiontaking
                 , @old_isauto_v2spositiontaking_3 AS old_isautov2positiontaking
                 , @isauto_v3spositiontaking_3 AS isautov3positiontaking
                 , @auto_v3spositiontaking_3 AS autov3positiontaking
                 , @old_auto_v3spositiontaking_3 AS old_autov3positiontaking
                 , @old_isauto_v3spositiontaking_3 AS old_isautov3positiontaking
                 , @isauto_v5spositiontaking_3 AS isautov5positiontaking
                 , @auto_v5spositiontaking_3 AS autov5positiontaking
                 , @old_auto_v5spositiontaking_3 AS old_autov5positiontaking
                 , @old_isauto_v5spositiontaking_3 AS old_isautov5positiontaking
                 , @isauto_v8spositiontaking_3 AS isautov8positiontaking
                 , @auto_v8spositiontaking_3 AS autov8positiontaking
                 , @old_auto_v8spositiontaking_3 AS old_autov8positiontaking
                 , @old_isauto_v8spositiontaking_3 AS old_isautov8positiontaking
                 , @isauto_v10spositiontaking_3 AS isautov10positiontaking
                 , @auto_v10spositiontaking_3 AS autov10positiontaking
                 , @old_auto_v10spositiontaking_3 AS old_autov10positiontaking
                 , @old_isauto_v10spositiontaking_3 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 , 0 AS old_isautov11positiontaking
                 , @isauto_v99spositiontaking_3 AS isautov99positiontaking
                 , @auto_v99spositiontaking_3 AS autov99positiontaking
                 , @old_auto_v99spositiontaking_3 AS old_autov99positiontaking
                 , @old_isauto_v99spositiontaking_3 AS old_isautov99positiontaking
                 , 0 AS isautov99mppositiontaking
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
--4
  UNION ALL SELECT 4 AS bettype
                 , @isauto_spositiontaking_4 AS isautopositiontaking
                 , 0 AS isautolivepositiontaking
                 , @auto_spositiontaking_4 AS autopositiontaking
                 , 0 AS autolivepositiontaking
                 , @old_auto_spositiontaking_4 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , @old_isauto_spositiontaking_4 AS old_isautopositiontaking
                 , 0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking
                 , 0 AS old_autov2positiontaking
                 , 0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 , 0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking
                 , 0 AS autov5positiontaking
                 , 0 AS old_autov5positiontaking
                 , 0 AS old_isautov5positiontaking
                 , 0 AS isautov8positiontaking
                 , 0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking
                 , 0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 , 0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 , 0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking
                 , 0 AS autov99positiontaking
                 , 0 AS old_autov99positiontaking
                 , 0 AS old_isautov99positiontaking
                 , 0 AS isautov99mppositiontaking
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
--5
  UNION ALL SELECT 5 AS bettype
                 , @isauto_spositiontaking_5 AS isautopositiontaking
                 , 0 AS isautolivepositiontaking
                 , @auto_spositiontaking_5 AS autopositiontaking
                 , 0 AS autolivepositiontaking
                 , @old_auto_spositiontaking_5 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , @old_isauto_spositiontaking_5 AS old_isautopositiontaking
                 , 0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking
                 , 0 AS old_autov2positiontaking
                 , 0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 , 0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking
                 , 0 AS autov5positiontaking
                 , 0 AS old_autov5positiontaking
                 , 0 AS old_isautov5positiontaking
                 , 0 AS isautov8positiontaking
                 , 0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking
                 , 0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 , 0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 , 0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking
                 , 0 AS autov99positiontaking
                 , 0 AS old_autov99positiontaking
                 , 0 AS old_isautov99positiontaking
                 , 0 AS isautov99mppositiontaking
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
--6
  UNION ALL SELECT 6 AS bettype
                 , @isauto_spositiontaking_6 AS isautopositiontaking
                 , 0 AS isautolivepositiontaking
                 , @auto_spositiontaking_6 AS autopositiontaking
                 , 0 AS autolivepositiontaking
                 , @old_auto_spositiontaking_6 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , @old_isauto_spositiontaking_6 AS old_isautopositiontaking
                 , 0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking
                 , 0 AS old_autov2positiontaking
                 , 0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 , 0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking
                 , 0 AS autov5positiontaking
                 , 0 AS old_autov5positiontaking
                 , 0 AS old_isautov5positiontaking
                 , 0 AS isautov8positiontaking
                 , 0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking
                 , 0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 , 0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 , 0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking
                 , 0 AS autov99positiontaking
                 , 0 AS old_autov99positiontaking
                 , 0 AS old_isautov99positiontaking
                 , 0 AS isautov99mppositiontaking
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
--7
  UNION ALL SELECT 7 AS bettype
                 , @isauto_spositiontaking_7 AS isautopositiontaking
                 , @isauto_slivepositiontaking_7 AS isautolivepositiontaking
                 , @auto_spositiontaking_7 AS autopositiontaking
                 , @auto_slivepositiontaking_7 AS autolivepositiontaking
                 , @old_auto_spositiontaking_7 AS old_autopositiontaking
                 , @old_auto_slivepositiontaking_7 AS old_autolivepositiontaking
                 , @old_isauto_spositiontaking_7 AS old_isautopositiontaking
                 , @old_isauto_slivepositiontaking_7 AS old_isautolivepositiontaking
                 , @isauto_v2spositiontaking_7 AS isautov2positiontaking
                 , @auto_v2spositiontaking_7 AS autov2positiontaking
                 , @old_auto_v2spositiontaking_7 AS old_autov2positiontaking
                 , @old_isauto_v2spositiontaking_7 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 , 0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking
                 , 0 AS autov5positiontaking
                 , 0 AS old_autov5positiontaking
                 , 0 AS old_isautov5positiontaking
                 , 0 AS isautov8positiontaking
                 , 0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking
                 , 0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 , 0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 , 0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking
                 , 0 AS autov99positiontaking
                 , 0 AS old_autov99positiontaking
                 , 0 AS old_isautov99positiontaking
                 , 0 AS isautov99mppositiontaking
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
--8
  UNION ALL SELECT 8 AS bettype
                 , @isauto_spositiontaking_8 AS isautopositiontaking
                 , @isauto_slivepositiontaking_8 AS isautolivepositiontaking
                 , @auto_spositiontaking_8 AS autopositiontaking
                 , @auto_slivepositiontaking_8 AS autolivepositiontaking
                 , @old_auto_spositiontaking_8 AS old_autopositiontaking
                 , @old_auto_slivepositiontaking_8 AS old_autolivepositiontaking
                 , @old_isauto_spositiontaking_8 AS old_isautopositiontaking
                 , @old_isauto_slivepositiontaking_8 AS old_isautolivepositiontaking
                 , @isauto_v2spositiontaking_8 AS isautov2positiontaking
                 , @auto_v2spositiontaking_8 AS autov2positiontaking
                 , @old_auto_v2spositiontaking_8 AS old_autov2positiontaking
                 , @old_isauto_v2spositiontaking_8 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 , 0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking
                 , 0 AS autov5positiontaking
                 , 0 AS old_autov5positiontaking
                 , 0 AS old_isautov5positiontaking
                 , 0 AS isautov8positiontaking
                 , 0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking
                 , 0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 , 0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 , 0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking
                 , 0 AS autov99positiontaking
                 , 0 AS old_autov99positiontaking
                 , 0 AS old_isautov99positiontaking
                 , 0 AS isautov99mppositiontaking
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
--9
  UNION ALL SELECT 9 AS bettype
                 , @isauto_spositiontaking_9 AS isautopositiontaking
                 , 0 AS isautolivepositiontaking
                 , @auto_spositiontaking_9 AS autopositiontaking
                 , 0 AS autolivepositiontaking
                 , @old_auto_spositiontaking_9 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , @old_isauto_spositiontaking_9 AS old_isautopositiontaking
                 , 0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking
                 , 0 AS old_autov2positiontaking
                 , 0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 , 0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking
                 , 0 AS autov5positiontaking
                 , 0 AS old_autov5positiontaking
                 , 0 AS old_isautov5positiontaking
                 , 0 AS isautov8positiontaking
                 , 0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking
                 , 0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 , 0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 , 0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking
                 , 0 AS autov99positiontaking
                 , 0 AS old_autov99positiontaking
                 , 0 AS old_isautov99positiontaking
                 , @isauto_v99spositiontaking_9 AS isautov99mppositiontaking
                 , @auto_v99spositiontaking_9 AS autov99mppositiontaking
                 , @old_isauto_v99spositiontaking_9 AS old_isautov99mppositiontaking
                 , @old_auto_v99spositiontaking_9 AS old_autov99mppositiontaking
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
--10
  UNION ALL SELECT 10 AS bettype
                 , @isauto_spositiontaking_10 AS isautopositiontaking
                 , 0 AS isautolivepositiontaking
                 , @auto_spositiontaking_10 AS autopositiontaking
                 , 0 AS autolivepositiontaking
                 , @old_auto_spositiontaking_10 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , @old_isauto_spositiontaking_10 AS old_isautopositiontaking
                 , 0 AS old_isautolivepositiontaking
                 
                 , @isauto_v2spositiontaking_10 AS isautov2positiontaking
                 , @auto_v2spositiontaking_10 AS autov2positiontaking
                 , @old_auto_v2spositiontaking_10 AS old_autov2positiontaking
                 , @old_isauto_v2spositiontaking_10 AS old_isautov2positiontaking
                 
                 
                 , @isauto_v3spositiontaking_10 AS isautov3positiontaking
                 , @auto_v3spositiontaking_10 AS autov3positiontaking
                 , @old_auto_v3spositiontaking_10 AS old_autov3positiontaking
                 , @old_isauto_v3spositiontaking_10 AS old_isautov3positiontaking
                 
                 , @isauto_v5spositiontaking_10 AS isautov5positiontaking
                 , @auto_v5spositiontaking_10 AS autov5positiontaking
                 , @old_auto_v5spositiontaking_10 AS old_autov5positiontaking
                 , @old_isauto_v5spositiontaking_10 AS old_isautov5positiontaking
                 
                 , @isauto_v8spositiontaking_10 AS isautov8positiontaking
                 , @auto_v8spositiontaking_10 AS autov8positiontaking
                 , @old_auto_v8spositiontaking_10 AS old_autov8positiontaking
                 , @old_isauto_v8spositiontaking_10 AS old_isautov8positiontaking
                 
                 , @isauto_v10spositiontaking_10 AS isautov10positiontaking
                 , @auto_v10spositiontaking_10 AS autov10positiontaking
                 , @old_auto_v10spositiontaking_10 AS old_autov10positiontaking
                 , @old_isauto_v10spositiontaking_10 AS old_isautov10positiontaking
                 
                 , @isauto_v11spositiontaking_10 AS isautov11positiontaking
                 , @auto_v11spositiontaking_10 AS autov11positiontaking
                 , @old_auto_v11spositiontaking_10 AS old_autov11positiontaking
                 , @old_isauto_v11spositiontaking_10 AS old_isautov11positiontaking
                 
                 , @isauto_v99spositiontaking_10 AS isautov99positiontaking
                 , @auto_v99spositiontaking_10 AS autov99positiontaking
                 , @old_auto_v99spositiontaking_10 AS old_autov99positiontaking
                 , @old_isauto_v99spositiontaking_10 AS old_isautov99positiontaking
                 
                 , 0 AS isautov99mppositiontaking
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
--9999
  UNION ALL SELECT 9999 AS bettype
                 , @isauto_spositiontaking_9999 AS isautopositiontaking
                 , 0 AS isautolivepositiontaking
                 , @auto_spositiontaking_9999 AS autopositiontaking
                 , 0 AS autolivepositiontaking
                 , @old_auto_spositiontaking_9999 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , @old_isauto_spositiontaking_9999 AS old_isautopositiontaking
                 , 0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking
                 , 0 AS old_autov2positiontaking
                 , 0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 , 0 AS old_isautov3positiontaking
                 , @isauto_v5spositiontaking_9999 AS isautov5positiontaking
                 , @auto_v5spositiontaking_9999 AS autov5positiontaking
                 , @old_auto_v5spositiontaking_9999 AS old_autov5positiontaking
                 , @old_isauto_v5spositiontaking_9999 AS old_isautov5positiontaking
                 , 0 AS isautov8positiontaking
                 , 0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking
                 , 0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 , 0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 , 0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking
                 , 0 AS autov99positiontaking
                 , 0 AS old_autov99positiontaking
                 , 0 AS old_isautov99positiontaking
                 , 0 AS isautov99mppositiontaking
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
  UNION ALL SELECT 20 AS bettype
                 , 0 AS isautopositiontaking
                 , 0 AS isautolivepositiontaking
                 , 0 AS autopositiontaking
                 , 0 AS autolivepositiontaking
                 , 0 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , 0 AS old_isautopositiontaking
                 , 0 AS old_isautolivepositiontaking
                 , @isauto_v2spositiontaking_20 AS isautov2positiontaking
                 , @auto_v2spositiontaking_20 AS autov2positiontaking
                 , @old_auto_v2spositiontaking_20 AS old_autov2positiontaking
                 , @old_isauto_v2spositiontaking_20 AS old_isautov2positiontaking
                 , @isauto_v3spositiontaking_20 AS isautov3positiontaking
                 , @auto_v3spositiontaking_20 AS autov3positiontaking
                 , @old_auto_v3spositiontaking_20 AS old_autov3positiontaking
                 , @old_isauto_v3spositiontaking_20 AS old_isautov3positiontaking
                 , @isauto_v5spositiontaking_20 AS isautov5positiontaking
                 , @auto_v5spositiontaking_20 AS autov5positiontaking
                 , @old_auto_v5spositiontaking_20 AS old_autov5positiontaking
                 , @old_isauto_v5spositiontaking_20 AS old_isautov5positiontaking
                 , @isauto_v8spositiontaking_20 AS isautov8positiontaking
                 , @auto_v8spositiontaking_20 AS autov8positiontaking
                 , @old_auto_v8spositiontaking_20 AS old_autov8positiontaking
                 , @old_isauto_v8spositiontaking_20 AS old_isautov8positiontaking
                 , @isauto_v10spositiontaking_20 AS isautov10positiontaking
                 , @auto_v10spositiontaking_20 AS autov10positiontaking
                 , @old_auto_v10spositiontaking_20 AS old_autov10positiontaking
                 , @old_isauto_v10spositiontaking_20 AS old_isautov10positiontaking
                 , @isauto_v11spositiontaking_20 AS isautov11positiontaking
                 , @auto_v11spositiontaking_20 AS autov11positiontaking
                 , @old_auto_v11spositiontaking_20 AS old_autov11positiontaking
                 , @old_isauto_v11spositiontaking_20 AS old_isautov11positiontaking
                 , @isauto_v99spositiontaking_20 AS isautov99positiontaking
                 , @auto_v99spositiontaking_20 AS autov99positiontaking
                 , @old_auto_v99spositiontaking_20 AS old_autov99positiontaking
                 , @old_isauto_v99spositiontaking_20 AS old_isautov99positiontaking
                 , 0 AS isautov99mppositiontaking
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 , @isauto_v154spositiontaking_20 ASisautov154positiontaking
                 , @auto_v154spositiontaking_20 AS autov154positiontaking
                 , @old_auto_v154spositiontaking_20 AS old_autov154positiontaking
                 , @old_isauto_v154spositiontaking_20 AS old_isautov154positiontaking
  UNION ALL SELECT 21 AS bettype
                 , 0 AS isautopositiontaking
                 , 0 AS isautolivepositiontaking
                 , 0 AS autopositiontaking
                 , 0 AS autolivepositiontaking
                 , 0 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , 0 AS old_isautopositiontaking
                 , 0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking
                 , 0 AS old_autov2positiontaking
                 ,  0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 , 0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking
                 , 0 AS autov5positiontaking
                 , 0 AS old_autov5positiontaking
                 , 0 AS old_isautov5positiontaking
                 , 0 AS isautov8positiontaking
                 , 0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking
                 , 0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 , 0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 , 0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking
                 , 0 AS autov99positiontaking
                 , 0 AS old_autov99positiontaking
                 , 0 AS old_isautov99positiontaking
                 , 0 AS isautov99mppositiontaking
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
  UNION ALL SELECT 22 AS bettype
                 , 0 AS isautopositiontaking
                 , 0 AS isautolivepositiontaking
                 , 0 AS autopositiontaking
                 , 0 AS autolivepositiontaking
                 , 0 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , 0 AS old_isautopositiontaking
                 , 0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking
                 , 0 AS old_autov2positiontaking
                 , 0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 , 0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking
                 , 0 AS autov5positiontaking
                 , 0 AS old_autov5positiontaking
                 , 0 AS old_isautov5positiontaking
                 , 0 AS isautov8positiontaking
                 , 0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking
                 , 0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 , 0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 , 0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking
                 , 0 AS autov99positiontaking
                 , 0 AS old_autov99positiontaking
                 , 0 AS old_isautov99positiontaking
                 , 0 AS isautov99mppositiontaking
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
        
        OPEN CUR

        FETCH NEXT FROM CUR INTO
            @bettype
          , @isautopositiontaking, @isautolivepositiontaking
          , @autopositiontaking, @autolivepositiontaking
          , @old_autopositiontaking, @old_autolivepositiontaking
          , @old_isautopositiontaking, @old_isautolivepositiontaking
          --2
          , @isautov2positiontaking, @autov2positiontaking
          , @old_autov2positiontaking, @old_isautov2positiontaking
          --3
          ,    @isautov3positiontaking, @autov3positiontaking
          , @old_autov3positiontaking, @old_isautov3positiontaking
          --5
          ,    @isautov5positiontaking, @autov5positiontaking
          , @old_autov5positiontaking, @old_isautov5positiontaking
          --8
          ,    @isautov8positiontaking, @autov8positiontaking
          , @old_autov8positiontaking, @old_isautov8positiontaking
          --10
          ,    @isautov10positiontaking, @autov10positiontaking
          , @old_autov10positiontaking, @old_isautov10positiontaking
          --11
          , @isautov11positiontaking, @autov11positiontaking
          , @old_autov11positiontaking, @old_isautov11positiontaking
          --99
          , @isautov99positiontaking, @autov99positiontaking
          , @old_autov99positiontaking, @old_isautov99positiontaking
          , @isautov99mppositiontaking, @autov99mppositiontaking
          , @old_autov99mppositiontaking, @old_isautov99mppositiontaking
          --154
          , @isautov154positiontaking, @autov154positiontaking
          , @old_autov154positiontaking, @old_isautov154positiontaking

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (@autopositiontaking <> @old_autopositiontaking OR @isautopositiontaking <> @old_isautopositiontaking) AND (@updatepositiontaking = 1 OR @updatemultiple=0)
            BEGIN
                IF @isautopositiontaking >0 --auto PT is used
                BEGIN
                    --UPDATE use Auto_SPT at master fOR all members only when:
                    --(autoSPT at master changes AND isauto at master = 1
                    --OR isauto at master changes FROM 0 to 1)
                    --AND isauto at member = 0
                    SELECT @maxpos = spositiontaking
                      FROM custsetting cs WITH(NOLOCK)
                     WHERE custid = @srecommend
                       AND sporttype = 1
                       AND bettype = @bettype

                    UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET spositiontaking =
                             CASE
                               WHEN @maxpos - mpositiontaking - apositiontaking > @autopositiontaking THEN @autopositiontaking
                               ELSE @maxpos - mpositiontaking - apositiontaking
                             END
                      FROM custsetting cs
                INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                     WHERE c.mrecommend = @mrecommend
                       AND c.roleid = 1
                       AND c.Enabled = 1
                       AND cs.bettype = @bettype
                       AND cs.sporttype = 1
                       AND cs.isautopositiontaking = 0 -- only UPDATE members without AutoSPT at member

                END
                ELSE IF @isautopositiontaking <> @old_isautopositiontaking  --auto PT is NOT used
                BEGIN
                    IF @updateallmembers = 1 -- UPDATE All Member option is used
                    BEGIN
                        --UPDATE a specific SPT fOR all members only when:
                        --@updateallmembers = 1
                        --AND isauto at master = 0
                        --AND isauto at master change FROM 1 to 0
                        --AND isauto at member = 0
                            
                        UPDATE cs WITH(ROWLOCK, UPDLOCK)
                           SET spositiontaking =
                                 CASE
                                   WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking
                                   ELSE @newspositiontaking
                                 END
                          FROM custsetting cs
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                           AND cs.sporttype = mcs.sporttype
                                                           AND cs.bettype = mcs.bettype
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs.bettype = @bettype
                           AND cs.sporttype = 1
                           AND cs.isautopositiontaking = 0

                    END
                END
            END
            
            --UPDATE LIVE
            IF @bettype IN (1, 3, 7, 8,10)
               AND (@autolivepositiontaking <> @old_autolivepositiontaking
                    OR @isautolivepositiontaking <> @old_isautolivepositiontaking
                   )
               AND (@updatepositiontaking = 1
                    OR @updatemultiple = 0
                   )
            BEGIN
                IF @isautolivepositiontaking > 0
                BEGIN
                    SELECT @maxpos = slivepositiontaking
                      FROM custsetting cs WITH(NOLOCK)
                     WHERE custid = @srecommend
                       AND sporttype = 1
                       AND bettype = @bettype

                    UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET slivepositiontaking =
                             CASE
                               WHEN @maxpos - mlivepositiontaking - alivepositiontaking > @autolivepositiontaking THEN @autolivepositiontaking
                               ELSE @maxpos - mlivepositiontaking - alivepositiontaking
                             END
                      FROM custsetting cs
                INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                     WHERE c.mrecommend = @mrecommend
                       AND c.roleid = 1
                       AND c.Enabled = 1
                       AND cs.bettype = @bettype
                       AND cs.sporttype = 1
                       AND cs.isautolivepositiontaking = 0

                END
                ELSE IF @isautolivepositiontaking <> @old_isautolivepositiontaking
                BEGIN
                    IF @updateallmembers = 1
                    BEGIN
                        UPDATE cs WITH(ROWLOCK, UPDLOCK)
                           SET slivepositiontaking =
                                 CASE
                                   WHEN mcs.slivepositiontaking<@newspositiontaking THEN mcs.slivepositiontaking
                                   ELSE @newspositiontaking
                                 END
                          FROM custsetting cs
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                           AND cs.sporttype = mcs.sporttype
                                                           AND cs.bettype = mcs.bettype
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs.bettype = @bettype
                           AND cs.sporttype = 1
                           AND cs.isautolivepositiontaking = 0

                    END
                END
            END

            --UPDATE Basketball
            IF @bettype IN (1, 2, 3, 7, 8, 9, 20,10)
               AND (@autov2positiontaking <> @old_autov2positiontaking
                    OR @isautov2positiontaking <> @old_isautov2positiontaking
                   )
               AND (@updatepositiontakingv2 = 1
                    OR @updatemultiple = 0
                   )
            BEGIN
                IF @isautov2positiontaking > 0
                BEGIN
                    SELECT @maxpos = spositiontaking
                      FROM custsetting cs WITH(NOLOCK)
                     WHERE custid = @srecommend
                       AND sporttype = 2
                       AND bettype = @bettype

                    UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET spositiontaking =
                             CASE
                               WHEN @maxpos - mpositiontaking - apositiontaking > @autov2positiontaking THEN @autov2positiontaking
                               ELSE @maxpos - mpositiontaking - apositiontaking
                             END
                      FROM custsetting cs
                INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                     WHERE c.mrecommend = @mrecommend
                       AND c.roleid = 1
                       AND c.Enabled = 1
                       AND cs.bettype = @bettype
                       AND cs.sporttype = 2
                       AND cs.isautopositiontaking = 0

                END
                ELSE IF @isautov2positiontaking <> @old_isautov2positiontaking
                BEGIN
                    IF @updateallmembers = 1
                    BEGIN
                        UPDATE cs WITH(ROWLOCK, UPDLOCK)
                           SET spositiontaking =
                                 CASE
                                   WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking
                                   ELSE @newspositiontaking
                                 END
                          FROM custsetting cs
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                           AND cs.sporttype = mcs.sporttype
                                                           AND cs.bettype = mcs.bettype
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs.bettype = @bettype
                           AND cs.sporttype = 2
                           AND cs.isautopositiontaking = 0
                    END
                END
            END


            --UPDATE Football
            IF @bettype IN (1, 2, 3, 20,10)
               AND (@autov3positiontaking <> @old_autov3positiontaking
                    OR @isautov3positiontaking <> @old_isautov3positiontaking
                   )
               AND (@updatepositiontakingv3 = 1
                    OR @updatemultiple = 0
                   )
            BEGIN
                IF @isautov3positiontaking > 0
                BEGIN
                    SELECT @maxpos = spositiontaking
                      FROM custsetting cs WITH(NOLOCK)
                     WHERE custid = @srecommend
                       AND sporttype = 3
                       AND bettype = @bettype

                    UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET spositiontaking =
                             CASE
                               WHEN @maxpos - mpositiontaking - apositiontaking > @autov3positiontaking THEN @autov3positiontaking
                               ELSE @maxpos - mpositiontaking - apositiontaking
                             END
                      FROM custsetting cs
                INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                     WHERE c.mrecommend = @mrecommend
                       AND c.roleid = 1
                       AND c.Enabled = 1
                       AND cs.bettype = @bettype
                       AND cs.sporttype = 3
                       AND cs.isautopositiontaking = 0

                END
                ELSE IF @isautov3positiontaking <> @old_isautov3positiontaking
                BEGIN
                    IF @updateallmembers = 1
                    BEGIN
                        UPDATE cs WITH(ROWLOCK, UPDLOCK)
                           SET spositiontaking =
                                 CASE
                                   WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking
                                   ELSE @newspositiontaking END
                          FROM custsetting cs
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                           AND cs.sporttype = mcs.sporttype
                                                           AND cs.bettype = mcs.bettype
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs.bettype = @bettype
                           AND cs.sporttype = 3
                           AND cs.isautopositiontaking = 0
                            
                    END
                END
            END    


            --UPDATE Tennis
            IF @bettype IN (1, 2, 3, 20, 9999,10)
               AND (@autov5positiontaking <> @old_autov5positiontaking
                    OR @isautov5positiontaking <> @old_isautov5positiontaking
                   )
               AND (@updatepositiontakingv5 = 1
                    OR @updatemultiple = 0
                   )
            BEGIN
                IF @isautov5positiontaking >0
                BEGIN
                    SELECT @maxpos = spositiontaking
                      FROM custsetting cs WITH(NOLOCK)
                     WHERE custid = @srecommend
                       AND sporttype = 5
                       AND bettype = @bettype

                    UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET spositiontaking =
                             CASE
                               WHEN @maxpos - mpositiontaking - apositiontaking > @autov5positiontaking THEN @autov5positiontaking
                               ELSE @maxpos - mpositiontaking - apositiontaking
                             END
                      FROM custsetting cs
                INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                     WHERE c.mrecommend = @mrecommend
                       AND c.roleid = 1
                       AND c.Enabled = 1
                       AND cs.bettype = @bettype
                       AND cs.sporttype = 5
                       AND cs.isautopositiontaking = 0

                END
                ELSE IF @isautov5positiontaking <> @old_isautov5positiontaking
                BEGIN
                    IF @updateallmembers = 1
                    BEGIN
                        UPDATE cs WITH(ROWLOCK, UPDLOCK)
                           SET spositiontaking =
                                 CASE
                                   WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking
                                   ELSE @newspositiontaking
                                 END
                          FROM custsetting cs
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                           AND cs.sporttype = mcs.sporttype
                                                           AND cs.bettype = mcs.bettype
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs.bettype = @bettype
                           AND cs.sporttype = 5
                           AND cs.isautopositiontaking = 0

                    END
                END
            END    


            --UPDATE Baseball
            IF @bettype IN (1, 3, 20,10)
               AND (@autov8positiontaking <> @old_autov8positiontaking
                    OR @isautov8positiontaking <> @old_isautov8positiontaking
                   )
               AND (@updatepositiontakingv8 = 1
                    OR @updatemultiple = 0
                   )
            BEGIN
                IF @isautov8positiontaking > 0
                BEGIN
                    SELECT @maxpos = spositiontaking
                      FROM custsetting cs WITH(NOLOCK)
                     WHERE custid = @srecommend
                       AND sporttype = 8
                       AND bettype = @bettype
                        
                    UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET spositiontaking =
                             CASE
                               WHEN @maxpos - mpositiontaking - apositiontaking > @autov8positiontaking THEN @autov8positiontaking
                               ELSE @maxpos - mpositiontaking - apositiontaking
                             END
                      FROM custsetting cs
                INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                     WHERE c.mrecommend = @mrecommend
                       AND c.roleid = 1
                       AND c.Enabled = 1
                       AND cs.bettype = @bettype
                       AND cs.sporttype = 8
                       AND cs.isautopositiontaking = 0

                END
                ELSE IF @isautov8positiontaking <> @old_isautov8positiontaking
                BEGIN
                    IF @updateallmembers = 1
                    BEGIN
                        UPDATE cs WITH(ROWLOCK, UPDLOCK)
                           SET spositiontaking =
                                 CASE
                                   WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking
                                   ELSE @newspositiontaking
                                 END
                          FROM custsetting cs
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                           AND cs.sporttype = mcs.sporttype
                                                           AND cs.bettype = mcs.bettype
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs.bettype = @bettype
                           AND cs.sporttype = 8
                           AND cs.isautopositiontaking = 0

                    END
                END
            END    


            --UPDATE Golf
            IF @bettype IN (1, 2, 3, 20,10)
               AND (@autov10positiontaking <> @old_autov10positiontaking
                    OR @isautov10positiontaking <> @old_isautov10positiontaking
                   )
               AND (@updatepositiontakingv10 = 1
                    OR @updatemultiple = 0
                   )
            BEGIN
                IF @isautov10positiontaking > 0
                BEGIN
                    SELECT @maxpos = spositiontaking
                      FROM custsetting cs WITH(NOLOCK)
                     WHERE custid = @srecommend
                       AND sporttype = 10
                       AND bettype = @bettype

                    UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET spositiontaking =
                             CASE
                               WHEN @maxpos - mpositiontaking - apositiontaking > @autov10positiontaking THEN @autov10positiontaking
                               ELSE @maxpos - mpositiontaking - apositiontaking
                             END
                      FROM custsetting cs
                INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                     WHERE c.mrecommend = @mrecommend
                       AND c.roleid = 1
                       AND c.Enabled = 1
                       AND cs.bettype = @bettype
                       AND cs.sporttype = 10
                       AND cs.isautopositiontaking = 0

                END
                ELSE IF @isautov10positiontaking <> @old_isautov10positiontaking
                BEGIN
                    IF @updateallmembers = 1
                    BEGIN
                        UPDATE cs WITH(ROWLOCK, UPDLOCK)
                           SET spositiontaking =
                                 CASE
                                   WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking
                                   ELSE @newspositiontaking END
                          FROM custsetting cs
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                           AND cs.sporttype = mcs.sporttype
                                                           AND cs.bettype = mcs.bettype
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs.bettype = @bettype
                           AND cs.sporttype = 10
                           AND cs.isautopositiontaking = 0

                    END
                END
            END


            --UPDATE Motorsports
            IF @bettype IN (1, 20,10)
               AND (@autov11positiontaking <> @old_autov11positiontaking
                    OR @isautov11positiontaking <> @old_isautov11positiontaking
                   )
               AND (@updatepositiontakingv11 = 1
                    OR @updatemultiple = 0
                   )
            BEGIN
                IF @isautov11positiontaking > 0
                BEGIN
                    SELECT @maxpos = spositiontaking
                      FROM custsetting cs WITH(NOLOCK)
                     WHERE custid = @srecommend
                       AND sporttype = 11
                       AND bettype = @bettype

                    UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET spositiontaking =
                             CASE
                               WHEN @maxpos - mpositiontaking - apositiontaking > @autov11positiontaking THEN @autov11positiontaking
                               ELSE @maxpos - mpositiontaking - apositiontaking
                             END
                      FROM custsetting cs
                INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                     WHERE c.mrecommend = @mrecommend
                       AND c.roleid = 1
                       AND c.Enabled = 1
                       AND cs.bettype = @bettype
                       AND cs.sporttype = 11
                       AND cs.isautopositiontaking = 0

                END
                ELSE IF @isautov11positiontaking <> @old_isautov11positiontaking
                BEGIN
                    IF @updateallmembers = 1
                    BEGIN
                        UPDATE cs WITH(ROWLOCK, UPDLOCK)
                           SET spositiontaking =
                                 CASE
                                   WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking
                                   ELSE @newspositiontaking END
                          FROM custsetting cs
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                           AND cs.sporttype = mcs.sporttype
                                                           AND cs.bettype = mcs.bettype
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs.bettype = @bettype
                           AND cs.sporttype = 11
                           AND cs.isautopositiontaking = 0

                    END
                END
            END


            --UPDATE Other sports
            IF @bettype IN (1, 2, 3, 20,10)
               AND (@autov99positiontaking <> @old_autov99positiontaking
                    OR @isautov99positiontaking <> @old_isautov99positiontaking
                   )
               AND (@updatepositiontakingv99 = 1
                    OR @updatemultiple = 0
                   )
            BEGIN
                IF @isautov99positiontaking > 0
                BEGIN
                    SELECT @maxpos = spositiontaking
                      FROM custsetting cs WITH(NOLOCK)
                     WHERE custid = @srecommend
                       AND sporttype = 99
                       AND bettype = @bettype

                    UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET spositiontaking =
                             CASE
                               WHEN @maxpos - mpositiontaking - apositiontaking > @autov99positiontaking THEN @autov99positiontaking
                               ELSE @maxpos - mpositiontaking - apositiontaking
                             END
                      FROM custsetting cs
                INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                     WHERE c.mrecommend = @mrecommend
                       AND c.roleid = 1
                       AND c.Enabled = 1
                       AND cs.bettype = @bettype
                       AND cs.sporttype = 99
                       AND cs.isautopositiontaking = 0

                END
                ELSE IF @isautov99positiontaking <> @old_isautov99positiontaking
                BEGIN
                    IF @updateallmembers = 1
                    BEGIN
                        UPDATE cs WITH(ROWLOCK, UPDLOCK)
                           SET spositiontaking =
                                 CASE
                                   WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking
                                   ELSE @newspositiontaking END
                          FROM custsetting cs
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                           AND cs.sporttype = mcs.sporttype
                                                           AND cs.bettype = mcs.bettype
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs.bettype = @bettype
                           AND cs.sporttype = 99
                           AND cs.isautopositiontaking = 0

                    END
                END
            END            

    
            --UPDATE Mixed sports
            IF @bettype = 9
               AND (@autov99mppositiontaking <> @old_autov99mppositiontaking
                    OR @isautov99mppositiontaking <> @old_isautov99mppositiontaking
                   )
               AND (@updatepositiontakingv99mp = 1
                    OR @updatemultiple = 0)
            BEGIN
                IF @isautov99mppositiontaking > 0
                BEGIN
                    SELECT @maxpos = spositiontaking
                      FROM custsetting cs WITH(NOLOCK)
                     WHERE custid = @srecommend
                       AND sporttype = 99
                       AND bettype = @bettype

                    UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET spositiontaking =
                             CASE
                               WHEN @maxpos - mpositiontaking - apositiontaking > @autov99mppositiontaking THEN @autov99mppositiontaking
                               ELSE @maxpos - mpositiontaking - apositiontaking
                             END
                      FROM custsetting cs
                INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                     WHERE c.mrecommend = @mrecommend
                       AND c.roleid = 1
                       AND c.Enabled = 1
                       AND cs.bettype = @bettype
                       AND cs.sporttype = 99
                       AND cs.isautopositiontaking = 0

                END
                ELSE IF @isautov99mppositiontaking <> @old_isautov99mppositiontaking
                BEGIN
                    IF @updateallmembers = 1
                    BEGIN
                        UPDATE cs WITH(ROWLOCK, UPDLOCK)
                           SET spositiontaking =
                                 CASE
                                   WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking
                                   ELSE @newspositiontaking
                                 END
                          FROM custsetting cs
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                           AND cs.sporttype = mcs.sporttype
                                                           AND cs.bettype = mcs.bettype
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs.bettype = @bettype
                           AND cs.sporttype = 99
                           AND cs.isautopositiontaking = 0
                            
                    END
                END
            END-- END live


            --UPDATE HR Fixed Odds
            IF @bettype IN (20)
               AND (@autov154positiontaking <> @old_autov154positiontaking
                    OR @isautov154positiontaking <> @old_isautov154positiontaking
                   )
               AND (@updatepositiontakingv154 = 1
                    OR @updatemultiple = 0
                   )
            BEGIN
                IF @isautov154positiontaking >0
                BEGIN
                    SELECT @maxpos = spositiontaking
                      FROM custsetting cs WITH(NOLOCK)
                     WHERE custid = @srecommend
                       AND sporttype = 154
                       AND bettype = @bettype

                    UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET spositiontaking =
                             CASE
                               WHEN @maxpos - mpositiontaking - apositiontaking > @autov154positiontaking THEN @autov154positiontaking
                               ELSE @maxpos - mpositiontaking - apositiontaking
                             END
                      FROM custsetting cs
                INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                     WHERE c.mrecommend = @mrecommend
                       AND c.roleid = 1
                       AND c.Enabled = 1
                       AND cs.bettype = @bettype
                       AND cs.sporttype = 154
                       AND cs.isautopositiontaking = 0

                END
                else if @isautov154positiontaking <> @old_isautov154positiontaking
                BEGIN
                    if @updateallmembers = 1
                    BEGIN
                        UPDATE cs WITH(ROWLOCK, UPDLOCK)
                           SET spositiontaking =
                                 CASE
                                   WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking
                                   ELSE @newspositiontaking
                                 END
                          FROM custsetting cs
                    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
                    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                                           AND cs.sporttype = mcs.sporttype
                                                           AND cs.bettype = mcs.bettype
                         WHERE c.mrecommend = @mrecommend
                           AND c.roleid = 1
                           AND c.Enabled = 1
                           AND cs.bettype = @bettype
                           AND cs.sporttype = 154
                           AND cs.isautopositiontaking = 0

                    END
                END
            END
            
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
                    @isautov154positiontaking, @autov154positiontaking, @old_autov154positiontaking, @old_isautov154positiontaking
        END

        CLOSE CUR
        DEALLOCATE CUR
    END
    ELSE IF @roleid = 2
    BEGIN
                    Declare CUR CURSOR FOR 
                        SELECT 1 AS bettype
                 , @isauto_mpositiontaking_1  AS isautopositiontaking
                 , @isauto_mlivepositiontaking_1 AS isautolivepositiontaking
                 , @auto_mpositiontaking_1 AS autopositiontaking
                 , @auto_mlivepositiontaking_1 AS autolivepositiontaking    ,        @old_auto_mpositiontaking_1  AS old_autopositiontaking
                 , @old_auto_mlivepositiontaking_1 AS old_autolivepositiontaking
                 , @old_isauto_mpositiontaking_1  AS old_isautopositiontaking     ,       @old_isauto_mlivepositiontaking_1 AS old_isautolivepositiontaking
                 ,  @isauto_v2mpositiontaking_1 AS isautov2positiontaking
                 , @auto_v2mpositiontaking_1 AS autov2positiontaking
                 , @old_auto_v2mpositiontaking_1 AS old_autov2positiontaking
                 , @old_isauto_v2mpositiontaking_1 AS old_isautov2positiontaking
                 , @isauto_v3mpositiontaking_1 AS isautov3positiontaking
                 , @auto_v3mpositiontaking_1 AS autov3positiontaking
                 , @old_auto_v3mpositiontaking_1 AS old_autov3positiontaking
                 , @old_isauto_v3mpositiontaking_1 AS old_isautov3positiontaking
                 , @isauto_v5mpositiontaking_1 AS isautov5positiontaking
                 , @auto_v5mpositiontaking_1 AS autov5positiontaking
                 , @old_auto_v5mpositiontaking_1 AS old_autov5positiontaking
                 , @old_isauto_v5mpositiontaking_1 AS old_isautov5positiontaking
                 , @isauto_v8mpositiontaking_1 AS isautov8positiontaking
                 , @auto_v8mpositiontaking_1 AS autov8positiontaking
                 , @old_auto_v8mpositiontaking_1 AS old_autov8positiontaking
                 , @old_isauto_v8mpositiontaking_1 AS old_isautov8positiontaking
                 , @isauto_v10mpositiontaking_1 AS isautov10positiontaking    ,       @auto_v10mpositiontaking_1 AS autov10positiontaking    ,       @old_auto_v10mpositiontaking_1 AS old_autov10positiontaking
                 , @old_isauto_v10mpositiontaking_1 AS old_isautov10positiontaking
                 , @isauto_v11mpositiontaking_1 AS isautov11positiontaking
                 , @auto_v11mpositiontaking_1 AS autov11positiontaking
                 , @old_auto_v11mpositiontaking_1 AS old_autov11positiontaking
                 , @old_isauto_v11mpositiontaking_1 AS old_isautov11positiontaking
                 , @isauto_v99mpositiontaking_1 AS isautov99positiontaking    ,       @auto_v99mpositiontaking_1 AS autov99positiontaking    ,       @old_auto_v99mpositiontaking_1 AS old_autov99positiontaking
                 , @old_isauto_v99mpositiontaking_1 AS old_isautov99positiontaking    ,                                0 AS isautov99mppositiontaking    ,                                0 AS autov99mppositiontaking    ,                                    0 AS old_autov99mppositiontaking
                 ,                                         0 AS old_isautov99mppositiontaking    ,0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
      UNION ALL SELECT 2 AS bettype
                 , @isauto_mpositiontaking_2  AS isautopositiontaking
                 ,   0 AS isautolivepositiontaking
                 , @auto_mpositiontaking_2 AS autopositiontaking    ,                                 0 AS autolivepositiontaking
                 , @old_auto_mpositiontaking_2  AS old_autopositiontaking
                 ,                                  0 AS old_autolivepositiontaking
                 , @old_isauto_mpositiontaking_2  AS old_isautopositiontaking     ,                                       0 AS old_isautolivepositiontaking
                 ,  @isauto_v2mpositiontaking_2 AS isautov2positiontaking
                 , @auto_v2mpositiontaking_2 AS autov2positiontaking
                 , @old_auto_v2mpositiontaking_2 AS old_autov2positiontaking
                 , @old_isauto_v2mpositiontaking_2 AS old_isautov2positiontaking
                 , @isauto_v3mpositiontaking_2 AS isautov3positiontaking
                 , @auto_v3mpositiontaking_2 AS autov3positiontaking
                 , @old_auto_v3mpositiontaking_2 AS old_autov3positiontaking
                 , @old_isauto_v3mpositiontaking_2 AS old_isautov3positiontaking
                 , @isauto_v5mpositiontaking_2 AS isautov5positiontaking
                 , @auto_v5mpositiontaking_2 AS autov5positiontaking
                 , @old_auto_v5mpositiontaking_2 AS old_autov5positiontaking
                 , @old_isauto_v5mpositiontaking_2 AS old_isautov5positiontaking
                 ,                             0 AS isautov8positiontaking    ,                                0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking        ,    @isauto_v10mpositiontaking_2 AS isautov10positiontaking    ,       @auto_v10mpositiontaking_2 AS autov10positiontaking    ,       @old_auto_v10mpositiontaking_2 AS old_autov10positiontaking
                 , @old_isauto_v10mpositiontaking_2 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 ,   0 AS old_isautov11positiontaking
                 , @isauto_v99mpositiontaking_2 AS isautov99positiontaking    ,       @auto_v99mpositiontaking_2 AS autov99positiontaking    ,       @old_auto_v99mpositiontaking_2 AS old_autov99positiontaking
                 , @old_isauto_v99mpositiontaking_2 AS old_isautov99positiontaking    ,                                0 AS isautov99mppositiontaking    ,                                0 AS autov99mppositiontaking    ,                                    0 AS old_autov99mppositiontaking
                 ,                                         0 AS old_isautov99mppositiontaking    ,0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
      UNION ALL SELECT 3 AS bettype
                 , @isauto_mpositiontaking_3  AS isautopositiontaking
                 , @isauto_mlivepositiontaking_3 AS isautolivepositiontaking
                 , @auto_mpositiontaking_3 AS autopositiontaking
                 , @auto_mlivepositiontaking_3 AS autolivepositiontaking
                 , @old_auto_mpositiontaking_3  AS old_autopositiontaking
                 , @old_auto_mlivepositiontaking_3 AS old_autolivepositiontaking
                 , @old_isauto_mpositiontaking_3  AS old_isautopositiontaking     ,       @old_isauto_mlivepositiontaking_3 AS old_isautolivepositiontaking
                 ,  @isauto_v2mpositiontaking_3 AS isautov2positiontaking
                 , @auto_v2mpositiontaking_3 AS autov2positiontaking
                 , @old_auto_v2mpositiontaking_3 AS old_autov2positiontaking
                 , @old_isauto_v2mpositiontaking_3 AS old_isautov2positiontaking
                 , @isauto_v3mpositiontaking_3 AS isautov3positiontaking
                 , @auto_v3mpositiontaking_3 AS autov3positiontaking
                 , @old_auto_v3mpositiontaking_3 AS old_autov3positiontaking
                 , @old_isauto_v3mpositiontaking_3 AS old_isautov3positiontaking
                 , @isauto_v5mpositiontaking_3 AS isautov5positiontaking
                 , @auto_v5mpositiontaking_3 AS autov5positiontaking
                 , @old_auto_v5mpositiontaking_3 AS old_autov5positiontaking
                 , @old_isauto_v5mpositiontaking_3 AS old_isautov5positiontaking
                 , @isauto_v8mpositiontaking_3 AS isautov8positiontaking
                 , @auto_v8mpositiontaking_3 AS autov8positiontaking
                 , @old_auto_v8mpositiontaking_3 AS old_autov8positiontaking
                 , @old_isauto_v8mpositiontaking_3 AS old_isautov8positiontaking
                 , @isauto_v10mpositiontaking_3 AS isautov10positiontaking    ,       @auto_v10mpositiontaking_3 AS autov10positiontaking    ,       @old_auto_v10mpositiontaking_3 AS old_autov10positiontaking
                 , @old_isauto_v10mpositiontaking_3 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 ,   0 AS old_isautov11positiontaking
                 , @isauto_v99mpositiontaking_3 AS isautov99positiontaking    ,       @auto_v99mpositiontaking_3 AS autov99positiontaking    ,       @old_auto_v99mpositiontaking_3 AS old_autov99positiontaking
                 , @old_isauto_v99mpositiontaking_3 AS old_isautov99positiontaking    ,                                0 AS isautov99mppositiontaking    ,                                0 AS autov99mppositiontaking    ,                                    0 AS old_autov99mppositiontaking
                 ,                                         0 AS old_isautov99mppositiontaking    ,0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
      UNION ALL SELECT 4 AS bettype
                 , @isauto_mpositiontaking_4  AS isautopositiontaking
                 ,   0 AS isautolivepositiontaking
                 , @auto_mpositiontaking_4 AS autopositiontaking    ,                                 0 AS autolivepositiontaking
                 , @old_auto_mpositiontaking_4  AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , @old_isauto_mpositiontaking_4  AS old_isautopositiontaking     ,                                       0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking    ,                                    0 AS old_autov2positiontaking
                 ,    0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 ,     0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking                                ,       0 AS autov5positiontaking                            ,                                    0 AS old_autov5positiontaking    ,                                     0 AS old_isautov5positiontaking
                 ,                             0 AS isautov8positiontaking    ,                                0 AS autov8positiontaking
                 ,   0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking        ,                               0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 ,   0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 ,   0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking                            ,       0 AS autov99positiontaking
                 ,                         0 AS old_autov99positiontaking
                 ,     0 AS old_isautov99positiontaking                                ,                                0 AS isautov99mppositiontaking    ,                                0 AS autov99mppositiontaking    ,                                    0 AS old_autov99mppositiontaking
                 ,                                         0 AS old_isautov99mppositiontaking    ,0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
      UNION ALL SELECT 5 AS bettype
                 , @isauto_mpositiontaking_5  AS isautopositiontaking
                 ,   0 AS isautolivepositiontaking
                 , @auto_mpositiontaking_5 AS autopositiontaking    ,                                 0 AS autolivepositiontaking
                 , @old_auto_mpositiontaking_5  AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , @old_isauto_mpositiontaking_5  AS old_isautopositiontaking     ,                                        0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking
                 , 0 AS old_autov2positiontaking
                 ,     0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 ,     0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking                                ,       0 AS autov5positiontaking                            ,                                    0 AS old_autov5positiontaking    ,                                     0 AS old_isautov5positiontaking
                 ,                             0 AS isautov8positiontaking    ,                                0 AS autov8positiontaking
                 ,  0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking        ,                               0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 ,   0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 ,   0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking                            ,       0 AS autov99positiontaking
                 ,                         0 AS old_autov99positiontaking
                 ,     0 AS old_isautov99positiontaking                                ,                                0 AS isautov99mppositiontaking    ,                                0 AS autov99mppositiontaking    ,                                    0 AS old_autov99mppositiontaking
                 ,                                         0 AS old_isautov99mppositiontaking    ,0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
      UNION ALL SELECT 6 AS bettype
                 , @isauto_mpositiontaking_6  AS isautopositiontaking
                 ,   0 AS isautolivepositiontaking
                 , @auto_mpositiontaking_6 AS autopositiontaking    ,                                 0 AS autolivepositiontaking
                 , @old_auto_mpositiontaking_6  AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , @old_isauto_mpositiontaking_6  AS old_isautopositiontaking     ,                                        0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking
                 , 0 AS old_autov2positiontaking
                 ,     0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 ,     0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking                                ,       0 AS autov5positiontaking                            ,                                    0 AS old_autov5positiontaking    ,                                     0 AS old_isautov5positiontaking
                 ,                             0 AS isautov8positiontaking    ,                                0 AS autov8positiontaking
                 ,  0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking        ,                               0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 ,   0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 ,   0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking                            ,       0 AS autov99positiontaking
                 ,                         0 AS old_autov99positiontaking
                 ,     0 AS old_isautov99positiontaking                                ,                                0 AS isautov99mppositiontaking    ,                                0 AS autov99mppositiontaking    ,                                    0 AS old_autov99mppositiontaking
                 ,                                         0 AS old_isautov99mppositiontaking    ,0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
      UNION ALL SELECT 7 AS bettype
                 , @isauto_mpositiontaking_7  AS isautopositiontaking
                 , @isauto_mlivepositiontaking_7 AS isautolivepositiontaking
                 , @auto_mpositiontaking_7 AS autopositiontaking
                 , @auto_mlivepositiontaking_7 AS autolivepositiontaking
                 , @old_auto_mpositiontaking_7  AS old_autopositiontaking
                 , @old_auto_mlivepositiontaking_7 AS old_autolivepositiontaking
                 , @old_isauto_mpositiontaking_7  AS old_isautopositiontaking     ,        @old_isauto_mlivepositiontaking_7 AS old_isautolivepositiontaking
                 ,  @isauto_v2mpositiontaking_7 AS isautov2positiontaking
                 , @auto_v2mpositiontaking_7 AS autov2positiontaking
                 , @old_auto_v2mpositiontaking_7 AS old_autov2positiontaking
                 , @old_isauto_v2mpositiontaking_7 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 ,     0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking                                ,       0 AS autov5positiontaking                            ,                                    0 AS old_autov5positiontaking    ,                                     0 AS old_isautov5positiontaking
                 ,                             0 AS isautov8positiontaking
                 , 0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking        ,                               0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 ,   0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 ,   0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking                            ,       0 AS autov99positiontaking
                 ,                         0 AS old_autov99positiontaking
                 ,     0 AS old_isautov99positiontaking                                ,                                0 AS isautov99mppositiontaking    ,                                0 AS autov99mppositiontaking    ,                                    0 AS old_autov99mppositiontaking
                 ,                                         0 AS old_isautov99mppositiontaking    ,0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
      UNION ALL SELECT 8 AS bettype
                 , @isauto_mpositiontaking_8  AS isautopositiontaking
                 , @isauto_mlivepositiontaking_8 AS isautolivepositiontaking
                 , @auto_mpositiontaking_8 AS autopositiontaking
                 , @auto_mlivepositiontaking_8 AS autolivepositiontaking
                 , @old_auto_mpositiontaking_8  AS old_autopositiontaking
                 , @old_auto_mlivepositiontaking_8 AS old_autolivepositiontaking
                 , @old_isauto_mpositiontaking_8  AS old_isautopositiontaking     ,       @old_isauto_mlivepositiontaking_8 AS old_isautolivepositiontaking
                 ,  @isauto_v2mpositiontaking_8 AS isautov2positiontaking
                 , @auto_v2mpositiontaking_8 AS autov2positiontaking
                 , @old_auto_v2mpositiontaking_8 AS old_autov2positiontaking
                 , @old_isauto_v2mpositiontaking_8 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 ,     0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking                                ,       0 AS autov5positiontaking                            ,                                    0 AS old_autov5positiontaking    ,                                     0 AS old_isautov5positiontaking
                 ,                             0 AS isautov8positiontaking
                 , 0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking        ,                               0 AS isautov10positiontaking    ,                                0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 ,   0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 ,   0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking                            ,       0 AS autov99positiontaking
                 ,                         0 AS old_autov99positiontaking
                 ,     0 AS old_isautov99positiontaking                                ,                                0 AS isautov99mppositiontaking    ,                                0 AS autov99mppositiontaking    ,                                    0 AS old_autov99mppositiontaking
                 ,                                         0 AS old_isautov99mppositiontaking    ,0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
      UNION ALL SELECT 9 AS bettype
                 , @isauto_mpositiontaking_9  AS isautopositiontaking
                 ,   0 AS isautolivepositiontaking
                 , @auto_mpositiontaking_9 AS autopositiontaking    ,                                 0 AS autolivepositiontaking
                 , @old_auto_mpositiontaking_9  AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , @old_isauto_mpositiontaking_9  AS old_isautopositiontaking     ,                                        0 AS old_isautolivepositiontaking    ,  /*@isauto_v2mpositiontaking_9*/0 AS isautov2positiontaking    ,  /*@auto_v2mpositiontaking_9*/0 AS autov2positiontaking    ,   /*@old_auto_v2mpositiontaking_9*/0 AS old_autov2positiontaking    ,     /*@old_isauto_v2mpositiontaking_9*/0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 ,     0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking                                ,       0 AS autov5positiontaking                            ,                                    0 AS old_autov5positiontaking    ,                                     0 AS old_isautov5positiontaking
                 ,                             0 AS isautov8positiontaking    ,                                0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking        ,                               0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 ,   0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 ,   0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking                            ,       0 AS autov99positiontaking
                 ,                         0 AS old_autov99positiontaking
                 ,     0 AS old_isautov99positiontaking                                ,    @isauto_v99mpositiontaking_9  AS isautov99mppositiontaking    ,        @auto_v99mpositiontaking_9 AS autov99mppositiontaking    ,       @old_auto_v99mpositiontaking_9 AS old_autov99mppositiontaking
                 ,          @old_isauto_v99mpositiontaking_9 AS old_isautov99mppositiontaking    ,0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
      
      UNION ALL SELECT 10 AS bettype
                 , @isauto_mpositiontaking_10 AS isautopositiontaking
                 ,   0 AS isautolivepositiontaking
                 , @auto_mpositiontaking_10 AS autopositiontaking
                 , 0 AS autolivepositiontaking
                 , @old_auto_mpositiontaking_10 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking
                 , @old_isauto_mpositiontaking_10 AS old_isautopositiontaking
                 , 0 AS old_isautolivepositiontaking
                 
                 , @isauto_v2mpositiontaking_10 AS isautov2positiontaking
                 , @auto_v2mpositiontaking_10 AS autov2positiontaking
                 , @old_auto_v2mpositiontaking_10 AS old_autov2positiontaking
                 , @old_isauto_v2mpositiontaking_10 AS old_isautov2positiontaking
                 
                 , @isauto_v3mpositiontaking_10 AS isautov3positiontaking
                 , @auto_v3mpositiontaking_10 AS autov3positiontaking
                 , @old_auto_v3mpositiontaking_10 AS old_autov3positiontaking
                 , @old_isauto_v3mpositiontaking_10 AS old_isautov3positiontaking
                 
                 , @isauto_v5mpositiontaking_10 AS isautov5positiontaking
                 , @auto_v5mpositiontaking_10 AS autov5positiontaking 
                 , @old_auto_v5mpositiontaking_10 AS old_autov5positiontaking
                 , @old_isauto_v5mpositiontaking_10 AS old_isautov5positiontaking
                 
                 , @isauto_v8mpositiontaking_10 AS isautov8positiontaking
                 , @auto_v8mpositiontaking_10 AS autov8positiontaking
                 , @old_auto_v8mpositiontaking_10 AS old_autov8positiontaking
                 , @old_isauto_v8mpositiontaking_10 AS old_isautov8positiontaking
                 
                 , @isauto_v10mpositiontaking_10 AS isautov10positiontaking
                 , @auto_v10mpositiontaking_10 AS autov10positiontaking
                 , @old_auto_v10mpositiontaking_10 AS old_autov10positiontaking
                 , @old_isauto_v10mpositiontaking_10 AS old_isautov10positiontaking
                 
                 , @isauto_v11mpositiontaking_10 AS isautov11positiontaking
                 , @auto_v11mpositiontaking_10 AS autov11positiontaking
                 , @old_auto_v11mpositiontaking_10 AS old_autov11positiontaking
                 , @old_isauto_v11mpositiontaking_10 AS old_isautov11positiontaking
                 
                 , @isauto_v99mpositiontaking_10 AS isautov99positiontaking
                 , @auto_v99mpositiontaking_10 AS autov99positiontaking
                 , @old_auto_v99mpositiontaking_10 AS old_autov99positiontaking
                 , @old_isauto_v99mpositiontaking_10 AS old_isautov99positiontaking
                 
                 , 0 AS isautov99mppositiontaking 
                 , 0 AS autov99mppositiontaking
                 , 0 AS old_autov99mppositiontaking
                 , 0 AS old_isautov99mppositiontaking
                 , 0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
      UNION ALL SELECT 9999 AS bettype
                 , @isauto_mpositiontaking_9999  AS isautopositiontaking    ,                          0 AS isautolivepositiontaking
                 , @auto_mpositiontaking_9999 AS autopositiontaking    ,                             0 AS autolivepositiontaking
                 , @old_auto_mpositiontaking_9999  AS old_autopositiontaking
                 ,      0 AS old_autolivepositiontaking
                 , @old_isauto_mpositiontaking_9999  AS old_isautopositiontaking  ,                                        0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking
                 , 0 AS old_autov2positiontaking
                 ,     0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 ,     0 AS old_isautov3positiontaking
                 , @isauto_v5mpositiontaking_9999 AS isautov5positiontaking,       @auto_v5mpositiontaking_9999 AS autov5positiontaking
                 , @old_auto_v5mpositiontaking_9999 AS old_autov5positiontaking    ,      @old_isauto_v5mpositiontaking_9999 AS old_isautov5positiontaking
                 ,                             0 AS isautov8positiontaking    ,                                0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking        ,                               0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 ,   0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 ,   0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking                            ,       0 AS autov99positiontaking
                 ,                         0 AS old_autov99positiontaking
                 ,     0 AS old_isautov99positiontaking                                ,                                0  AS isautov99mppositiontaking    ,                                0 AS autov99mppositiontaking    ,                                    0 AS old_autov99mppositiontaking
                 ,                                         0 AS old_isautov99mppositiontaking    ,0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
      UNION ALL SELECT 20 AS bettype
                 , 0 AS isautopositiontaking
                 ,   0 AS isautolivepositiontaking
                 , 0 AS autopositiontaking    ,                                 0 AS autolivepositiontaking
                 ,                            0 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking    ,                                   0 AS old_isautopositiontaking     ,                                        0 AS old_isautolivepositiontaking
                 ,  @isauto_v2mpositiontaking_20 AS isautov2positiontaking
                 , @auto_v2mpositiontaking_20 AS autov2positiontaking
                 , @old_auto_v2mpositiontaking_20 AS old_autov2positiontaking
                 , @old_isauto_v2mpositiontaking_20 AS old_isautov2positiontaking
                 , @isauto_v3mpositiontaking_20 AS isautov3positiontaking
                 , @auto_v3mpositiontaking_20 AS autov3positiontaking
                 , @old_auto_v3mpositiontaking_20 AS old_autov3positiontaking
                 , @old_isauto_v3mpositiontaking_20 AS old_isautov3positiontaking
                 , @isauto_v5mpositiontaking_20 AS isautov5positiontaking
                 , @auto_v5mpositiontaking_20 AS autov5positiontaking
                 , @old_auto_v5mpositiontaking_20 AS old_autov5positiontaking    ,      @old_isauto_v5mpositiontaking_20 AS old_isautov5positiontaking    ,    @isauto_v8mpositiontaking_20 AS isautov8positiontaking    ,        @auto_v8mpositiontaking_20 AS autov8positiontaking    ,        @old_auto_v8mpositiontaking_20 AS old_autov8positiontaking
                 , @old_isauto_v8mpositiontaking_20 AS old_isautov8positiontaking
                 , @isauto_v10mpositiontaking_20 AS isautov10positiontaking
                 , @auto_v10mpositiontaking_20 AS autov10positiontaking    ,       @old_auto_v10mpositiontaking_20 AS old_autov10positiontaking
                 , @old_isauto_v10mpositiontaking_20 AS old_isautov10positiontaking
                 , @isauto_v11mpositiontaking_20 AS isautov11positiontaking
                 , @auto_v11mpositiontaking_20 AS autov11positiontaking
                 , @old_auto_v11mpositiontaking_20 AS old_autov11positiontaking
                 , @old_isauto_v11mpositiontaking_20 AS old_isautov11positiontaking
                 , @isauto_v99mpositiontaking_20 AS isautov99positiontaking
                 , @auto_v99mpositiontaking_20 AS autov99positiontaking    ,       @old_auto_v99mpositiontaking_20 AS old_autov99positiontaking
                 , @old_isauto_v99mpositiontaking_20 AS old_isautov99positiontaking    ,                                0 AS isautov99mppositiontaking    ,                                0 AS autov99mppositiontaking    ,                                    0 AS old_autov99mppositiontaking
                 ,                                         0 AS old_isautov99mppositiontaking    ,@isauto_v154mpositiontaking_20 ASisautov154positiontaking
                 , @auto_v154mpositiontaking_20 AS autov154positiontaking
                 , @old_auto_v154mpositiontaking_20 AS old_autov154positiontaking
                 , @old_isauto_v154mpositiontaking_20 AS old_isautov154positiontaking
      UNION ALL SELECT 21 AS bettype
                 , 0 AS isautopositiontaking
                 ,   0 AS isautolivepositiontaking
                 , 0 AS autopositiontaking    ,                                 0 AS autolivepositiontaking
                 ,                            0 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking    ,                                   0 AS old_isautopositiontaking     ,                                        0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking
                 , 0 AS old_autov2positiontaking
                 ,     0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 ,     0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking                                ,       0 AS autov5positiontaking                            ,                                     0 AS old_autov5positiontaking    ,                                     0 AS old_isautov5positiontaking
                 ,                             0 AS isautov8positiontaking    ,                                0 AS autov8positiontaking
                 , 0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking        ,                               0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 ,   0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 ,   0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking                            ,       0 AS autov99positiontaking
                 ,                         0 AS old_autov99positiontaking
                 ,     0 AS old_isautov99positiontaking                                ,                                0 AS isautov99mppositiontaking    ,                                0 AS autov99mppositiontaking    ,                                    0 AS old_autov99mppositiontaking
                 ,                                         0 AS old_isautov99mppositiontaking    ,0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
      UNION ALL SELECT 22 AS bettype
                 , 0 AS isautopositiontaking
                 ,   0 AS isautolivepositiontaking
                 , 0 AS autopositiontaking    ,                                 0 AS autolivepositiontaking
                 ,                            0 AS old_autopositiontaking
                 , 0 AS old_autolivepositiontaking    ,                                   0 AS old_isautopositiontaking     ,                                        0 AS old_isautolivepositiontaking
                 , 0 AS isautov2positiontaking
                 , 0 AS autov2positiontaking
                 , 0 AS old_autov2positiontaking
                 ,     0 AS old_isautov2positiontaking
                 , 0 AS isautov3positiontaking
                 , 0 AS autov3positiontaking
                 , 0 AS old_autov3positiontaking
                 ,     0 AS old_isautov3positiontaking
                 , 0 AS isautov5positiontaking                                ,       0 AS autov5positiontaking                            ,                                    0 AS old_autov5positiontaking    ,                                     0 AS old_isautov5positiontaking
                 ,                             0 AS isautov8positiontaking    ,                                0 AS autov8positiontaking
                 ,  0 AS old_autov8positiontaking
                 , 0 AS old_isautov8positiontaking        ,                               0 AS isautov10positiontaking
                 , 0 AS autov10positiontaking
                 , 0 AS old_autov10positiontaking
                 ,    0 AS old_isautov10positiontaking
                 , 0 AS isautov11positiontaking
                 , 0 AS autov11positiontaking
                 , 0 AS old_autov11positiontaking
                 ,   0 AS old_isautov11positiontaking
                 , 0 AS isautov99positiontaking                            ,       0 AS autov99positiontaking
                 ,                         0 AS old_autov99positiontaking
                 ,     0 AS old_isautov99positiontaking                                ,                                0 AS isautov99mppositiontaking    ,                                0 AS autov99mppositiontaking    ,                                    0 AS old_autov99mppositiontaking
                 ,                                         0 AS old_isautov99mppositiontaking    ,0 AS isautov154positiontaking
                 , 0 AS autov154positiontaking
                 , 0 AS old_autov154positiontaking
                 , 0 AS old_isautov154positiontaking
            
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
                    @isautov154positiontaking, @autov154positiontaking, @old_autov154positiontaking, @old_isautov154positiontaking

                --UPDATE use Auto_MPT at agent fOR all members only when:
                --(autoMPT at agent changes AND isauto at agent = 1
                --OR isauto at agent changes FROM 0 to 1)
                -- m1=min(m3-a1,u2)
                
                --UPDATE a specific MPT fOR all members only when:
                --@updateallmembers = 1
                --AND isauto at agent = 0
                --AND isauto at agent change FROM 1 to 0
                --m1=min(m2,@newmpositiontaking)
                
                WHILE @@FETCH_STATUS = 0
                BEGIN
                    if (@autopositiontaking <> @old_autopositiontaking OR @isautopositiontaking <> @old_isautopositiontaking) AND (@updatepositiontaking = 1 OR @updatemultiple=0)
                    BEGIN
                        if @isautopositiontaking >0 --auto PT is used
                        BEGIN                
                            -- m1=min(m3-a1,u2)                
                            SELECT @maxpos = mpositiontaking FROM custsetting cs WITH(NOLOCK) WHERE custid = @mrecommend
                           AND sporttype=1 AND bettype = @bettype
                            UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN @maxpos - apositiontaking > @autopositiontaking THEN @autopositiontaking
                               ELSE @maxpos - apositiontaking END
                          FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                         WHERE 
                                c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=1
                            
                        END
                        else if @isautopositiontaking <> @old_isautopositiontaking  --auto PT is NOT used
                        BEGIN
                            if @updateallmembers = 1 -- UPDATE All Member option is used
                            BEGIN
                                --m1=min(m2,@newmpositiontaking)
                                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN acs.mpositiontaking<@newmpositiontaking THEN acs.mpositiontaking
                               ELSE @newmpositiontaking END
                              FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                                INNER JOIN  custsetting AS acs WITH(NOLOCK) ON acs.custid = @recommend
                                                          AND cs.sporttype=acs.sporttype
                                                          AND cs.bettype=acs.bettype
                             WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=1                 
                                
                            END
                        END
                    END
                    --UPDATE LIVE
                    if @bettype IN (1, 3, 7, 8) AND (@autolivepositiontaking <> @old_autolivepositiontaking OR @isautolivepositiontaking <> @old_isautolivepositiontaking ) AND (@updatepositiontaking = 1 OR @updatemultiple=0)
                    BEGIN
                        if @isautolivepositiontaking >0 --Use AUTO_MPT
                        BEGIN
                            --m1=min(m3-a1,u2)
                            SELECT @maxpos = mlivepositiontaking FROM custsetting cs WITH(NOLOCK) WHERE custid = @mrecommend
                           AND sporttype=1 AND bettype = @bettype
                            UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mlivepositiontaking =
                             CASE
                               WHEN @maxpos - alivepositiontaking>@autolivepositiontaking THEN @autolivepositiontaking
                               ELSE @maxpos - alivepositiontaking END
                          FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                         WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=1 
                            
                        END
                        else if @isautolivepositiontaking <> @old_isautolivepositiontaking --Not use AUTO_PT
                        BEGIN
                            if @updateallmembers = 1--UPDATE all member
                            BEGIN
                                --m1=min(m2,@newmpositiontaking)
                                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mlivepositiontaking =
                             CASE
                               WHEN acs.mlivepositiontaking<@newmpositiontaking THEN acs.mlivepositiontaking
                               ELSE @newmpositiontaking END
                              FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                                INNER JOIN  custsetting AS acs WITH(NOLOCK) ON acs.custid = @recommend
                                                          AND cs.sporttype=acs.sporttype
                                                          AND cs.bettype=acs.bettype
                             WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=1             
                                
                            END
                        END
                    END
                    --UPDATE Basketball
                    if @bettype IN (1, 2, 3, 7, 8, 9,10, 20) AND (@autov2positiontaking <> @old_autov2positiontaking OR @isautov2positiontaking <> @old_isautov2positiontaking ) AND (@updatepositiontakingv2 = 1 OR @updatemultiple=0)
                    BEGIN
                        if @isautov2positiontaking >0
                        BEGIN
                            --UPDATE m1=min(m3-a1,u2)
                            SELECT @maxpos = mpositiontaking FROM custsetting cs WITH(NOLOCK) WHERE custid = @mrecommend
                           AND sporttype=2 AND bettype = @bettype
                            UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN @maxpos - apositiontaking>@autov2positiontaking THEN @autov2positiontaking
                               ELSE @maxpos - apositiontaking END
                          FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                         WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=2
                            
                        END
                        else if @isautov2positiontaking <> @old_isautov2positiontaking -- Not use AUTO_PT
                        BEGIN
                            if @updateallmembers = 1 --UPDATE all member
                            BEGIN
                                --m1=min(m2,@newmpositiontaking)
                                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN acs.mpositiontaking<@newmpositiontaking THEN acs.mpositiontaking
                               ELSE @newmpositiontaking END
                              FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                                INNER JOIN  custsetting AS acs WITH(NOLOCK) ON acs.custid = @recommend
                                                          AND cs.sporttype=acs.sporttype
                                                          AND cs.bettype=acs.bettype
                             WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=2 
                                
                            END
                        END
                    END    
                    
                    --UPDATE Football
                    if @bettype IN (1, 2, 3, 10,20) AND (@autov3positiontaking <> @old_autov3positiontaking OR @isautov3positiontaking <> @old_isautov3positiontaking ) AND (@updatepositiontakingv3 = 1 OR @updatemultiple=0)
                    BEGIN
                        if @isautov3positiontaking >0 --Use AUTO_MPT
                        BEGIN
                            --m1=min(m3-a1,u2)
                            SELECT @maxpos = mpositiontaking FROM custsetting cs WITH(NOLOCK) WHERE custid = @mrecommend
                           AND sporttype=3 AND bettype = @bettype
                            UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN @maxpos - apositiontaking>@autov3positiontaking THEN @autov3positiontaking
                               ELSE @maxpos - apositiontaking END
                          FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                         WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=3 
                            
                        END
                        else if @isautov3positiontaking <> @old_isautov3positiontaking --Not use AUTO_MPT
                        BEGIN
                            if @updateallmembers = 1 --UPDATE all member
                            BEGIN
                                --m1=min(m2,@newmpositiontaking)
                                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN acs.mpositiontaking<@newmpositiontaking THEN acs.mpositiontaking
                               ELSE @newmpositiontaking END
                              FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                                INNER JOIN  custsetting AS acs WITH(NOLOCK) ON acs.custid = @recommend
                                                          AND cs.sporttype=acs.sporttype
                                                          AND cs.bettype=acs.bettype
                             WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=3 
                                
                            END
                        END
                    END    

                    --UPDATE Tennis
                    if @bettype IN (1, 2, 3, 10,20,9999) AND (@autov5positiontaking <> @old_autov5positiontaking OR @isautov5positiontaking <> @old_isautov5positiontaking ) AND (@updatepositiontakingv5 = 1 OR @updatemultiple=0)
                    BEGIN
                        if @isautov5positiontaking >0
                        BEGIN
                            -- m1=min(m3-a1,u2)
                            SELECT @maxpos = mpositiontaking FROM custsetting cs WITH(NOLOCK) WHERE custid = @mrecommend
                           AND sporttype=5 AND bettype = @bettype
                            UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN @maxpos - apositiontaking>@autov5positiontaking THEN @autov5positiontaking
                               ELSE @maxpos - apositiontaking END
                          FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                         WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=5 
                            
                        END
                        else if @isautov5positiontaking <> @old_isautov5positiontaking
                        BEGIN
                            if @updateallmembers = 1--UPDATE all member
                            BEGIN
                                --m1=min(m2,@newmpositiontaking)
                                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN acs.mpositiontaking<@newmpositiontaking THEN acs.mpositiontaking
                               ELSE @newmpositiontaking END
                              FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                                INNER JOIN  custsetting AS acs WITH(NOLOCK) ON acs.custid = @recommend
                                                          AND cs.sporttype=acs.sporttype
                                                          AND cs.bettype=acs.bettype
                             WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=5
                                
                            END
                        END
                    END    

                    --UPDATE Baseball
                    if @bettype IN (1, 3,10, 20) AND (@autov8positiontaking <> @old_autov8positiontaking OR @isautov8positiontaking <> @old_isautov8positiontaking ) AND (@updatepositiontakingv8 = 1 OR @updatemultiple=0)
                    BEGIN
                        if @isautov8positiontaking >0--Use AUTO MPT
                        BEGIN
                            --m1=min(m3-a1,u2)
                            SELECT @maxpos = mpositiontaking FROM custsetting cs WITH(NOLOCK) WHERE custid = @mrecommend
                           AND sporttype=8 AND bettype = @bettype
                            UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN @maxpos - apositiontaking>@autov8positiontaking THEN @autov8positiontaking
                               ELSE @maxpos - apositiontaking END
                          FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                         WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=8 
                            
                        END
                        else if @isautov8positiontaking <> @old_isautov8positiontaking -- Not use AUTO MPT
                        BEGIN
                            if @updateallmembers = 1--All member
                            BEGIN
                                --m1=min(m2,@newmpositiontaking)
                                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN acs.mpositiontaking<@newmpositiontaking THEN acs.mpositiontaking
                               ELSE @newmpositiontaking END
                              FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                                INNER JOIN  custsetting AS acs WITH(NOLOCK) ON acs.custid = @recommend
                                                          AND cs.sporttype=acs.sporttype
                                                          AND cs.bettype=acs.bettype
                             WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=8 AND cs.isautopositiontaking=0
                                
                            END
                        END
                    END    

                    --UPDATE Golf
                    if @bettype IN (1, 2, 3,10, 20) AND (@autov10positiontaking <> @old_autov10positiontaking OR @isautov10positiontaking <> @old_isautov10positiontaking ) AND (@updatepositiontakingv10 = 1 OR @updatemultiple=0)
                    BEGIN
                        if @isautov10positiontaking >0 --Use AUTO MPT
                        BEGIN
                            --m1=min(m3-a1,u2)
                            SELECT @maxpos = mpositiontaking FROM custsetting cs WITH(NOLOCK) WHERE custid = @mrecommend
                           AND sporttype=10 AND bettype = @bettype
                            UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN @maxpos - apositiontaking>@autov10positiontaking THEN @autov10positiontaking
                               ELSE @maxpos - apositiontaking END
                          FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                         WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=10 
                            
                        END
                        else if @isautov10positiontaking <> @old_isautov10positiontaking --Not use AUTO MPT
                        BEGIN
                            if @updateallmembers = 1 -- all member
                            BEGIN
                                --m1=min(m2,@newmpositiontaking)
                                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN acs.mpositiontaking<@newmpositiontaking THEN acs.mpositiontaking
                               ELSE @newmpositiontaking END
                              FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                                INNER JOIN  custsetting AS acs WITH(NOLOCK) ON acs.custid = @recommend
                                                          AND cs.sporttype=acs.sporttype
                                                          AND cs.bettype=acs.bettype
                             WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=10 
                                
                            END
                        END
                    END    

                    --UPDATE Motorsports
                    if @bettype IN (1,10,20) AND (@autov11positiontaking <> @old_autov11positiontaking OR @isautov11positiontaking <> @old_isautov11positiontaking ) AND (@updatepositiontakingv11 = 1 OR @updatemultiple=0)
                    BEGIN
                        if @isautov11positiontaking >0 --Use AUTO MPT
                        BEGIN
                            --m1=min(m3-a1,u2)
                            SELECT @maxpos = mpositiontaking FROM custsetting cs WITH(NOLOCK) WHERE custid = @mrecommend
                           AND sporttype=11 AND bettype = @bettype
                            UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN @maxpos - apositiontaking>@autov11positiontaking THEN @autov11positiontaking
                               ELSE @maxpos - apositiontaking END
                          FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                         WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=11 
                            
                        END
                        else if @isautov11positiontaking <> @old_isautov11positiontaking -- Not use AUTO MPT
                        BEGIN
                            if @updateallmembers = 1 -- all member
                            BEGIN
                                --m1=min(m2,@newmpositiontaking)
                                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN acs.mpositiontaking<@newmpositiontaking THEN acs.mpositiontaking
                               ELSE @newmpositiontaking END
                              FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                                INNER JOIN  custsetting AS acs WITH(NOLOCK) ON acs.custid = @recommend
                                                          AND cs.sporttype=acs.sporttype
                                                          AND cs.bettype=acs.bettype
                             WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=11 
                                
                            END
                        END
                    END    
                    --UPDATE Other sports
                    if @bettype IN (1, 2, 3,10, 20) AND (@autov99positiontaking <> @old_autov99positiontaking OR @isautov99positiontaking <> @old_isautov99positiontaking ) AND (@updatepositiontakingv99 = 1 OR @updatemultiple=0)
                    BEGIN
                        if @isautov99positiontaking >0 --Use AUTO MPT
                        BEGIN 
                            --m1=min(m3-a1,u2)
                            SELECT @maxpos = mpositiontaking FROM custsetting cs WITH(NOLOCK) WHERE custid = @mrecommend
                           AND sporttype=99 AND bettype = @bettype
                            UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN @maxpos - apositiontaking>@autov99positiontaking THEN @autov99positiontaking
                               ELSE @maxpos - apositiontaking END
                          FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                         WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=99 
                            
                        END
                        else if @isautov99positiontaking <> @old_isautov99positiontaking --Not use AUTO MPT
                        BEGIN
                            if @updateallmembers = 1 --All member
                            BEGIN
                                --m1=min(m2,@newmpositiontaking)
                                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN acs.mpositiontaking<@newmpositiontaking THEN acs.mpositiontaking
                               ELSE @newmpositiontaking END
                              FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                                INNER JOIN  custsetting AS acs WITH(NOLOCK) ON acs.custid = @recommend
                                                          AND cs.sporttype=acs.sporttype
                                                          AND cs.bettype=acs.bettype
                             WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=99
                                
                            END
                        END
                    END            
                    
                    --UPDATE Mixed sports        
                    if @bettype =9 AND (@autov99mppositiontaking <> @old_autov99mppositiontaking OR @isautov99mppositiontaking <> @old_isautov99mppositiontaking ) AND (@updatepositiontakingv99mp = 1 OR @updatemultiple=0)
                    BEGIN
                        if @isautov99mppositiontaking >0 --Use AUTO MPT
                        BEGIN 
                            --m1=min(m3-a1,u2)
                            SELECT @maxpos = mpositiontaking FROM custsetting cs WITH(NOLOCK) WHERE custid = @mrecommend
                           AND sporttype=99 AND bettype = @bettype
                            UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN @maxpos - apositiontaking>@autov99mppositiontaking THEN @autov99mppositiontaking
                               ELSE @maxpos - apositiontaking END
                          FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                         WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=99 
                            
                        END
                        else if @isautov99mppositiontaking <> @old_isautov99mppositiontaking --Not use AUTO MPT
                        BEGIN
                            if @updateallmembers = 1 --All member
                            BEGIN
                                --m1=min(m2,@newmpositiontaking)
                                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN acs.mpositiontaking<@newmpositiontaking THEN acs.mpositiontaking
                               ELSE @newmpositiontaking END
                              FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                                INNER JOIN  custsetting AS acs WITH(NOLOCK) ON acs.custid = @recommend
                                                          AND cs.sporttype=acs.sporttype
                                                          AND cs.bettype=acs.bettype
                             WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=99
                                
                            END
                        END
                    END                
                    --UPDATE HR Fixed Odds
                    if @bettype IN (20) AND (@autov154positiontaking <> @old_autov154positiontaking OR @isautov154positiontaking <> @old_isautov154positiontaking ) AND (@updatepositiontakingv154 = 1 OR @updatemultiple=0)
                    BEGIN
                        if @isautov154positiontaking >0 --Use AUTO MPT
                        BEGIN
                            --m1=min(m3-a1,u2)
                            SELECT @maxpos = mpositiontaking FROM custsetting cs WITH(NOLOCK) WHERE custid = @mrecommend
                           AND sporttype=154 AND bettype = @bettype
                            UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN @maxpos - apositiontaking>@autov154positiontaking THEN @autov154positiontaking
                               ELSE @maxpos - apositiontaking END
                          FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                         WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=154                            
                        END
                        else if @isautov154positiontaking <> @old_isautov154positiontaking -- Not use AUTO MPT
                        BEGIN
                            if @updateallmembers = 1 -- all member
                            BEGIN
                                --m1=min(m2,@newmpositiontaking)
                                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                       SET mpositiontaking =
                             CASE
                               WHEN acs.mpositiontaking<@newmpositiontaking THEN acs.mpositiontaking
                               ELSE @newmpositiontaking END
                              FROM custsetting cs
                INNER JOIN  custinfo AS c WITH(NOLOCK) ON cs.custid = c.custid
                                INNER JOIN  custsetting AS acs WITH(NOLOCK) ON acs.custid = @recommend
                                                          AND cs.sporttype=acs.sporttype
                                                          AND cs.bettype=acs.bettype
                             WHERE  c.recommend = @recommend
                           AND c.roleid = 1 AND cs.bettype = @bettype
                                                          AND cs.sporttype=154                                
                            END
                        END
                    END                
                                    
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
                        @isautov154positiontaking, @autov154positiontaking, @old_autov154positiontaking, @old_isautov154positiontaking
            END
        CLOSE CUR
        DEALLOCATE CUR
    END
END