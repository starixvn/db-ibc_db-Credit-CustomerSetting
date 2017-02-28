USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberLiveCS_SAg]    Script Date: 06/09/2015 16:34:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMemberLiveCS_SAg    Script Date: 5/20/2015 10:07:55 PM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMemberLiveCS_SAg    Script Date: 5/19/2015 4:20:55 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberLiveCS_SAg] 
	@custid		INT,	

	@v162spositiontaking_1101        SMALLMONEY,
	@isauto_v162spositiontaking_1101 BIT,
	@auto_v162spositiontaking_1101   SMALLMONEY,

	@v162UpdatePositiontaking_1101     BIT = 1,
	@v162UpdateAutoPositiontaking_1101 BIT = 1,

	@SubAccID	INT = 0,
	@IP			VARCHAR(50) = '',	
	@UserID		INT = 0,
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	VARCHAR(300) = '' OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 12Jan2012
		Task: Super edit PT on member
		DB: DBTXN/BODB02
		
		Revisions:
			- 20120928@Lukas: do not check max PT of super SLAM (8156203) - special requirement
			- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
			- 20130301@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
			- 20130516@Lukas: allow PT = 100%
			- 20131113@Johnson: Use execrept Acc_CustSetting3rd_00 to correct after update pt on member 
			- 20140317@Johnson: Check constraint min us1, s1 with max(n4-m1-a1,0) & merge code correct pt [redmine:#11562]
			- 20140811@Logan:   1. Add ErrCode when old & new values are the same (-107) [Redmine: #20319]
			                    2. Code aligning
			- 20150515@Johnson: fix bug s1_max = Max(n4-(m1+a1), s4 - m3) [Redmined: #35758]	
			- 20150606@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID) [Redmine:#36216]
		                  

		Parameters Explanation:
	*/
BEGIN
    SET NOCOUNT ON 


    DECLARE @startRun DATETIME
          , @endRun   DATETIME
          , @duration INT

    SET @startRun = GETDATE()

    DECLARE @roleid      TINYINT
          , @ErrCode_Cur INT
          , @ErrMsg_Cur  NVARCHAR(4000)
          , @ErrAcc      NVARCHAR(4000)
          , @srecommend  INT
          , @mrecommend  INT
          , @recommend   INT
          , @username    VARCHAR(50)
          , @ErrType     NVARCHAR(4000)
          , @db_v162spositiontaking_1101        SMALLMONEY
          , @db_isauto_v162spositiontaking_1101 BIT
          , @db_auto_v162spositiontaking_1101   SMALLMONEY
          , @UplineSyncLiveCS BIT

    DECLARE @mpos     SMALLMONEY
          , @apos     SMALLMONEY
          , @spos     SMALLMONEY
          , @mapos1   SMALLMONEY
          , @mapos2   SMALLMONEY
          , @mapos    SMALLMONEY
          , @maxspos  SMALLMONEY
          , @maxmapos SMALLMONEY

    DECLARE @tmp_cs TABLE
    (
        custid    INT
      , sporttype INT
      , bettype   INT
      , spositiontaking       SMALLMONEY
      , mpositiontaking       SMALLMONEY
      , apositiontaking       SMALLMONEY
      , isautopositiontaking  BIT
      , isautompositiontaking BIT
      , autopositiontaking    SMALLMONEY
      , autompositiontaking   SMALLMONEY
    )

    DECLARE @tmp_sag TABLE
    (
        custid            INT
      , sporttype         INT
      , bettype           INT
      , spositiontaking   SMALLMONEY
      , minpositiontaking SMALLMONEY
    )

    DECLARE @tmp_mag TABLE
    (
        custid               INT
      , sporttype            INT
      , bettype              INT
      , mpositiontaking      SMALLMONEY
      , isautopositiontaking BIT
      , autopositiontaking   SMALLMONEY
      , minpositiontaking    SMALLMONEY
    )

    DECLARE @tmp_ag TABLE
    (
        custid                INT
      , sporttype             INT
      , bettype               INT
      , isautompositiontaking BIT
      , autompositiontaking   SMALLMONEY
      , minpositiontaking     SMALLMONEY
    )

    SELECT @ErrCode_Cur = 0
         , @ErrMsg_Cur = ''
         , @ErrCode = ''
         , @ErrMsg = ''

    ---------------------------
    -- ***Check Downline Belonging***
    EXEC dbo.Age_CustomerSelCheckBelonging 
	    @SessionCustID = @Userid, 
	    @Custid = @custid,
	    @roleid = @roleid OUTPUT

    IF (@roleid = 0)
    BEGIN
        RETURN
    END
    ---------------------------

    --Check disable user
    EXEC dbo.Acc_CustomerSelCheckEnable
        @custid = @custid
      , @ErrCode = @ErrCode_Cur output
      , @ErrMsg = @ErrMsg_Cur output

    IF @ErrCode_Cur > 0
    BEGIN
	    SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
	         , @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
	    RETURN
    END
    --end

    SELECT @srecommend = srecommend
         , @mrecommend = mrecommend
         , @recommend = recommend
         , @username = username
      FROM customer WITH(NOLOCK)
     WHERE custid = @custid

    INSERT INTO @tmp_cs
    (
        custid
      , sporttype
      , bettype
      , spositiontaking
      , mpositiontaking
      , apositiontaking
      , isautopositiontaking
      , isautompositiontaking
      , autopositiontaking
      , autompositiontaking
    )
    SELECT custid
         , sporttype
         , bettype
         , spositiontaking
         , mpositiontaking
         , apositiontaking
         , isautopositiontaking
         , isautompositiontaking
         , autopositiontaking
         , autompositiontaking
      FROM CustSettingGame WITH(NOLOCK)
     WHERE custid = @custid
       AND sporttype = 162
       AND bettype = 1101

    SELECT @db_v162spositiontaking_1101 = spositiontaking
         , @db_isauto_v162spositiontaking_1101 = isautopositiontaking
         , @db_auto_v162spositiontaking_1101 = autopositiontaking
      FROM @tmp_cs
     WHERE sporttype = 162
       AND bettype = 1101

    --if not change any setting then not update
    IF @v162spositiontaking_1101 = @db_v162spositiontaking_1101
	    AND @isauto_v162spositiontaking_1101 = @db_isauto_v162spositiontaking_1101
	    AND @auto_v162spositiontaking_1101 = @db_auto_v162spositiontaking_1101
    BEGIN
        SELECT @ErrCode = @ErrCode + '-103' + CHAR(7)
             , @ErrMsg = @ErrMsg + CHAR(7)
	    RETURN
    END

    INSERT INTO @tmp_sag
    (
        custid
      , sporttype
      , bettype
      , spositiontaking
      , minpositiontaking
    )
    SELECT scs.custid
         , scs.sporttype
         , scs.bettype
         , scs.spositiontaking
         , sco.minpositiontaking
      FROM CustSettingGame scs WITH(NOLOCK)
INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON scs.custid = sco.custid
                                            AND scs.sporttype = sco.sporttype
                                            AND scs.bettype = sco.bettype
     WHERE scs.custid = @srecommend
       AND scs.sporttype = 162
       AND scs.bettype = 1101

    INSERT INTO @tmp_mag
    (
        custid
      , sporttype
      , bettype
      , mpositiontaking
      , isautopositiontaking
      , autopositiontaking
      , minpositiontaking
    )
    SELECT mcs.custid
         , mcs.sporttype
         , mcs.bettype
         , mpositiontaking
         , isautopositiontaking
         , autopositiontaking
         , minpositiontaking
      FROM CustSettingGame mcs WITH(NOLOCK)
INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mcs.custid = mco.custid
                                            AND mcs.sporttype = mco.sporttype
                                            AND mcs.bettype = mco.bettype
     WHERE mcs.custid = @mrecommend
       AND mcs.sporttype = 162
       AND mcs.bettype = 1101

    INSERT INTO @tmp_ag
    (
        custid
      , sporttype
      , bettype
      , isautompositiontaking
      , autompositiontaking
      , minpositiontaking
    )
    SELECT acs.custid
         , acs.sporttype
         , acs.bettype
         , isautompositiontaking
         , autompositiontaking
         , minpositiontaking
      FROM CustSettingGame acs WITH(NOLOCK)
INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON acs.custid = aco.custid
                                            AND acs.sporttype = aco.sporttype
                                            AND acs.bettype = aco.bettype
     WHERE acs.custid = @recommend
       AND acs.sporttype = 162
       AND acs.bettype = 1101

    SELECT @UplineSyncLiveCS = SyncLiveCasino
      FROM CustInfo WITH(NOLOCK)
     WHERE custid = @recommend 

    IF @v162UpdatePositiontaking_1101 = 1
    BEGIN
	    IF @v162spositiontaking_1101 < 0
	        OR (@v162spositiontaking_1101 > 1 AND @srecommend <> 8156203)
	    BEGIN
		    SELECT @ErrMsg_Cur = @UserName + ': '
		                       + CASE @Language
								   WHEN 'E' THEN 'Wrong position taking.'
								   ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language)
						         END
                 , @ErrCode_Cur = 100
    			
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
			     , @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

            RETURN
	    END	

	    --s1<=s4
	    SELECT @ErrType = ''	
	    SELECT @ErrType = @ErrType + 'Max: ' + CAST(spositiontaking AS VARCHAR(10)) 
	      FROM @tmp_sag
	     WHERE @v162spositiontaking_1101 > spositiontaking

	    IF @ErrType <> ''
	    BEGIN 
		    SELECT @ErrMsg_Cur =	@UserName + ': '+
							    case @Language 
								    when 'E' then 'Wrong  position taking.<br>'+@ErrType
								    ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
							    end, @ErrCode_Cur = 101
    		
		    SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
    					
		    RETURN	
	    END
    	
	    --s1 <= Max(n4-(m1+a1), s4 - m3)
	    select @ErrType = ''	
	    SELECT @ErrType = @ErrType + 'Max: ' + CAST((CASE WHEN scs.spositiontaking -  mcs.mpositiontaking > scs.minpositiontaking - (cs.apositiontaking+cs.mpositiontaking)
													THEN scs.spositiontaking -  mcs.mpositiontaking
													ELSE scs.minpositiontaking - (cs.apositiontaking+cs.mpositiontaking)
												END) AS VARCHAR(10)) 
	    FROM @tmp_sag scs
		    INNER JOIN @tmp_mag mcs ON scs.sporttype = mcs.sporttype and scs.bettype = mcs.bettype	
		    INNER JOIN CustSettingGame cs WITH(NOLOCK) ON cs.custid = @custid AND cs.sporttype = scs.sporttype and cs.bettype = scs.bettype	
	    WHERE @v162spositiontaking_1101 > CASE WHEN scs.spositiontaking -  mcs.mpositiontaking > scs.minpositiontaking - (cs.apositiontaking+cs.mpositiontaking)
												THEN scs.spositiontaking -  mcs.mpositiontaking
												ELSE scs.minpositiontaking - (cs.apositiontaking+cs.mpositiontaking)
											END
    		
	    IF @ErrType <> ''
	    BEGIN 
		    Select @ErrMsg_Cur =	@UserName + ': '+
							    case @Language 
								    when 'E' then 'Wrong  position taking.<br>'+@ErrType
								    ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
							    end, @ErrCode_Cur = 101
    		
		    SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
    					
		    RETURN	
	    END
    	
	    --s1 + m1 + a1 <=s4
	    select @ErrType = ''
	    SELECT @ErrType = @ErrType + 'Max: ' + CAST(scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking AS VARCHAR(10)) 
	    FROM @tmp_sag scs
		    INNER JOIN @tmp_cs cs ON scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype	
	    WHERE @v162spositiontaking_1101 + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
    	
	    IF @ErrType <> ''
	    BEGIN 
		    Select @ErrMsg_Cur =	@UserName + ': '+
							    case @Language 
								    when 'E' then 'Wrong  position taking.<br>'+@ErrType
								    ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
							    end, @ErrCode_Cur = 102
    		
		    SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
    					
		    RETURN	
	    END
    	
	    --s1>=s1_min
	    select @ErrType = ''
	    SELECT @ErrType = @ErrType + 'Min: ' + CAST(sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking AS VARCHAR(10)) 
	    FROM @tmp_sag sco
		    INNER JOIN @tmp_cs cs ON sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype
	    WHERE @v162spositiontaking_1101 + cs.mpositiontaking + cs.apositiontaking < sco.minpositiontaking
    	
	    IF @ErrType <> ''
	    BEGIN 
		    Select @ErrMsg_Cur =	@UserName + ': '+
							    case @Language 
								    when 'E' then 'Wrong  position taking.<br>'+@ErrType
								    ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
							    end, @ErrCode_Cur = 103
    		
		    SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
    					
		    RETURN	
	    END
	    --SELECT @v162spositiontaking_1101 = CASE WHEN @v162spositiontaking_1101 + @v162mpositiontaking_1101 + @v162apositiontaking_1101 > @v162spositiontaking_1101_max THEN @v162spositiontaking_1101_max - @v162mpositiontaking_1101 - @v162apositiontaking_1101 ELSE @v162spositiontaking_1101 END
    	
	    --SELECT @v162spositiontaking_1101 = CASE WHEN @v162spositiontaking_1101 < 0 THEN 0 ELSE @v162spositiontaking_1101 END
    END
     
    IF @v162UpdateAutoPositiontaking_1101 = 1
    BEGIN
	    --us1<=s4
	    SELECT @ErrType = ''	
	    SELECT @ErrType	= @ErrType + 'Max: ' + CAST(spositiontaking AS VARCHAR(10)) 
	    FROM @tmp_sag 		
	    WHERE @auto_v162spositiontaking_1101 > spositiontaking
    	
	    IF @ErrType <>''
	    BEGIN		
		    SELECT @ErrMsg_Cur = 	@UserName + ': '+
				    CASE @Language when 'E' then 'Wrong auto position taking.<br>'+@ErrType
								    ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
								    END, @ErrCode_Cur = 201		
    		
		    SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
    					
		    RETURN	
	    END
    	
	    --us1>= us1_min 
	    SELECT @ErrType = ''	
	    SELECT @ErrType	= @ErrType + 'Min: ' + CAST(sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking AS VARCHAR(10)) 
	    FROM @tmp_sag sco
		    INNER JOIN @tmp_cs cs ON sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype
	    WHERE @isauto_v162spositiontaking_1101 = 1 AND @auto_v162spositiontaking_1101 + cs.mpositiontaking + cs.apositiontaking < sco.minpositiontaking
    		
    	
	    IF @ErrType <>''
	    BEGIN		
		    SELECT @ErrMsg_Cur = 	@UserName + ': '+
				    CASE @Language when 'E' then 'Wrong auto position taking.<br>'+@ErrType
								    ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
								    END, @ErrCode_Cur = 202		
    		
		    SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
    					
		    RETURN	
	    END
    END


    IF @v162UpdatePositiontaking_1101 = 1
    BEGIN
    --don't update s1 for member under master was set i3=1(normal)
	    UPDATE cs
	    SET cs.spositiontaking = @v162spositiontaking_1101
	    FROM @tmp_cs cs
		    INNER JOIN @tmp_mag mcs ON cs.sporttype = mcs.sporttype AND cs.bettype = mcs.bettype
	    WHERE mcs.isautopositiontaking = 0 
    /*	UPDATE cs
	    SET cs.spositiontaking = @v162spositiontaking_1101
	    FROM CustSettingGame cs 
		    INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		    INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	    WHERE cs.custid = @custid AND cs.sporttype = 162 AND cs.bettype = 1101 AND mcs.isautopositiontaking = 0
    */
    END

    IF @v162UpdateAutoPositiontaking_1101 = 1
    BEGIN
    --Update auto PT
	    UPDATE cs
	    SET isautopositiontaking = @isauto_v162spositiontaking_1101, autopositiontaking = @auto_v162spositiontaking_1101
	    FROM @tmp_cs cs
	    WHERE sporttype = 162 and bettype = 1101
    /*
	    UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK)
	    SET isautopositiontaking = @isauto_v162spositiontaking_1101, autopositiontaking = @auto_v162spositiontaking_1101
	    WHERE custid = @custid AND sporttype = 162 AND bettype = 1101 
    	
	    if @@Error <> 0
	    BEGIN
		    SELECT @ErrMsg_Cur =  @UserName + ': '+
								    CASE @Language 
									    WHEN 'E' THEN 'Error updating auto position taking'
									    ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
								    END, @ErrCode_Cur = 202	
    		
		    SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					    @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
    					
		    RETURN	
	    END
    */
    END
    	
    --merge code correct pt
	    --check agent min/max
	    --update a1=n2 when a1<n2
	    UPDATE cs
	    SET cs.apositiontaking = aco.minpositiontaking,
		    cs.mpositiontaking = CASE WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking ELSE cs.mpositiontaking END
	    FROM @tmp_cs cs	
		    INNER JOIN @tmp_ag aco ON cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype
		    INNER JOIN @tmp_mag mcs ON mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	    WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype = 1101
		    AND cs.apositiontaking < aco.minpositiontaking
    	
	    --Recal AUTO MPT 
	    --Update m1=min(m3-a1,(im1?um1,um2))
	    UPDATE cs
	    SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END THEN
				    CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END ELSE mcs.mpositiontaking - cs.apositiontaking END
	    FROM @tmp_cs cs
		    INNER JOIN @tmp_ag acs ON acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
		    INNER JOIN @tmp_mag mcs ON mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	    WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype = 1101 
		    AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)
    		
	    --check master min/max
	    --update m1=n3-a1 if a1+m1<n3
	    UPDATE cs
	    SET cs.mpositiontaking = CASE WHEN cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking THEN mco.minpositiontaking - cs.apositiontaking ELSE cs.mpositiontaking END
	    FROM @tmp_cs cs
		    INNER JOIN @tmp_mag mco ON mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
	    WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype= 1101
    	
	    --update m1,a1 when a1+m1>m3
	    --update m1=if(m3-a1<0,0,m3-a1)
	    --update a1=if(a1+m1>m3,m3-m1,a1)
	    UPDATE cs
	    SET @mpos = CASE WHEN mcs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE mcs.mpositiontaking - cs.apositiontaking END,
		    cs.mpositiontaking = @mpos,
		    @apos = CASE WHEN @mpos + cs.apositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - @mpos ELSE cs.apositiontaking END,
		    cs.apositiontaking = CASE WHEN @apos > aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END	
	    FROM @tmp_cs cs
		    INNER JOIN @tmp_mag mcs ON mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		    INNER JOIN @tmp_ag aco ON aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
	    WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype = 1101
		    AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking 		
    			
	    --recal autopos
	    UPDATE cs
	    SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN
										    CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END 
								    ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
	    FROM @tmp_cs cs
		    INNER JOIN @tmp_mag mcs ON mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		    INNER JOIN @tmp_sag scs ON scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
	    WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype = 1101
		    AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)
    		
	    --check super min/max
	    --update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
	    UPDATE cs
	    SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
	    FROM @tmp_cs cs
		    INNER JOIN @tmp_sag sco ON sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype 
	    WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype = 1101 
		    AND cs.spositiontaking + cs.mpositiontaking  + cs.apositiontaking < sco.minpositiontaking
    	
	    --update s1,m1,a1 in case s1+m1+a1>s4
	    --s1=max(0,s4-m1-a1)
	    --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
	    --@maxmapos=min(m3,l3)
	    --@mapos2=min(@mapos1,@maxmapos)
	    --@mapos=max(@mapos2,n3)
	    --m1=max(0,@mapos-a1)
	    --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
    	
	    UPDATE cs
	    SET @spos = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END,
		    cs.spositiontaking = @spos,
		    @mapos1 = CASE WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos ELSE cs.mpositiontaking + cs.apositiontaking END,
		    @mapos2 = CASE WHEN @mapos1 > mcs.mpositiontaking THEN mcs.mpositiontaking ELSE @mapos1 END,
		    @mapos  = CASE WHEN @mapos > mcs.minpositiontaking THEN @mapos ELSE mcs.minpositiontaking END,		
		    @mpos = CASE WHEN @mapos - cs.apositiontaking > 0 THEN @mapos - cs.apositiontaking ELSE 0 END,
		    cs.mpositiontaking = @mpos,
		    @apos = CASE WHEN @mpos + cs.apositiontaking > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
		    cs.apositiontaking = CASE WHEN @apos > aco.minpositiontaking THEN @apos ELSE aco.minpositiontaking END
	    FROM @tmp_cs cs
		    INNER JOIN @tmp_sag scs ON scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
		    INNER JOIN @tmp_mag mcs ON mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 		
		    INNER JOIN @tmp_ag aco ON aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
	    WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype = 1101 
		    AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
    	
	    UPDATE cs
	    SET  cs.spositiontaking = t.spositiontaking
		    ,cs.mpositiontaking = t.mpositiontaking
		    ,cs.apositiontaking = t.apositiontaking
		    ,cs.isautopositiontaking = t.isautopositiontaking
		    ,cs.isautompositiontaking = t.isautompositiontaking 
		    ,cs.autopositiontaking = t.autopositiontaking
		    ,cs.autompositiontaking = t.autompositiontaking
	    FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
		    INNER JOIN @tmp_cs t ON cs.custid = t.custid AND cs.sporttype = t.sporttype AND cs.bettype = t.bettype
	    WHERE cs.spositiontaking <> t.spositiontaking
		    OR cs.mpositiontaking <> t.mpositiontaking
		    OR cs.apositiontaking <> t.apositiontaking
		    OR cs.isautopositiontaking <> t.isautopositiontaking
		    OR cs.isautompositiontaking <> t.isautompositiontaking 
		    OR cs.autopositiontaking <> t.autopositiontaking
		    OR cs.autompositiontaking <> t.autompositiontaking
    /*
    EXEC dbo.Acc_CustSetting3rd_00
		    @custid = @custid, 
		    @recommend = @recommend, 
		    @mrecommend = @mrecommend, 
		    @srecommend = @srecommend,
		    @mode = 'LiveCasino'	
    */
    ---EXEC dbo.Acc_CustomerUpdMemberLiveCS_MinPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend

    DECLARE @LogSPData VARCHAR(MAX),
		    @TrackingValueDB VARCHAR(5000)
    		
    SELECT @LogSPData = '<Acc_CustomerUpdMemberLiveCS_SAg Custid = "' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v162spositiontaking_1101 = "' + COALESCE(CAST(@v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'isauto_v162spositiontaking_1101 = "' + COALESCE(CAST(@isauto_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'auto_v162spositiontaking_1101 ="' + COALESCE(CAST(@auto_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v162UpdatePositiontaking_1101 ="' + COALESCE(CAST(@v162UpdatePositiontaking_1101 AS VARCHAR(10)), SPACE(1)) + '" ' +
	    'v162UpdateAutoPositiontaking_1101 ="' + COALESCE(CAST(@v162UpdateAutoPositiontaking_1101 AS VARCHAR(10)), SPACE(1)) + '" ' +
	    'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />' 

    SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberLiveCS_SAg Custid = "' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v162spositiontaking_1101 = "' + COALESCE(CAST(@db_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'isauto_v162spositiontaking_1101 = "' + COALESCE(CAST(@db_isauto_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'auto_v162spositiontaking_1101 ="' + COALESCE(CAST(@db_auto_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v162UpdatePositiontaking_1101 ="' + COALESCE(CAST(@v162UpdatePositiontaking_1101 AS VARCHAR(10)), SPACE(1)) + '" ' +
	    'v162UpdateAutoPositiontaking_1101 ="' + COALESCE(CAST(@v162UpdateAutoPositiontaking_1101 AS VARCHAR(10)), SPACE(1)) + '" ' +
	    'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />' 


    SET @endRun = GETDATE()
    SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @UserID,
		    @CustID = @CustID,
		    @ActionID = 428,
		    @TrackingValue = @LogSPData,
		    @TrackingValue2 = @TrackingValueDB,
		    @duration = @duration
    END TRY
    BEGIN CATCH
	    SELECT @LogSPData = '<Acc_CustomerUpdMemberLiveCS_SAg Custid = "' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v162spositiontaking_1101 = "' + COALESCE(CAST(@v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'isauto_v162spositiontaking_1101 = "' + COALESCE(CAST(@isauto_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'auto_v162spositiontaking_1101 ="' + COALESCE(CAST(@auto_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v162UpdatePositiontaking_1101 ="' + COALESCE(CAST(@v162UpdatePositiontaking_1101 AS VARCHAR(10)), SPACE(1)) + '" ' +
	    'v162UpdateAutoPositiontaking_1101 ="' + COALESCE(CAST(@v162UpdateAutoPositiontaking_1101 AS VARCHAR(10)), SPACE(1)) + '" ' +
	    'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	    'ErrMsg="'+ ERROR_MESSAGE() + '" />'
    	
	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @UserID,
		    @CustID = @CustID,
		    @ActionID = 428,
		    @TrackingValue = @LogSPData,
		    @TrackingValue2 = @TrackingValueDB,
		    @duration = @duration
    END CATCH	

    SELECT @ErrCode = '-103' + char(7)
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_SAg] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_SAg] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_SAg] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberLiveCS_SAg] TO [vnteam] AS [dbo]