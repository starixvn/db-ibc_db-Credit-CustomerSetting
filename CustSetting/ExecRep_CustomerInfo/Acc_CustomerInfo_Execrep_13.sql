/*<info serverAlias="DBCUST-CustDB" executers="bodbadminNet" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_13]
		@custid int = 0,
		@recommend int = 0,
		@mrecommend int = 0,
		@srecommend int = 0,
		@sporttype		INT = 0, 
		@bettype		INT = 0,
		@updautomaster bit = 1,
		@updautosuper bit = 1,
		@mode varchar(20) ='Keno'
AS
/*
	Created: 20220808@Tacy
	Task : update PT on member when using Search&Copy New member function
	DB: DBCust/CustDB
	Original:

	Revisions:
		- 20220808@Tacy: Initial SP [RedmineID: #176225]

	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON;
	
	IF NOT(dbo.f_CheckRepTable('custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustSettingGame') = 1 
	   AND dbo.f_CheckRepTable('CustOverrideGame') = 1 
	   AND dbo.f_CheckRepTable('CustSetting3rd') = 1 
	   AND dbo.f_CheckRepTable('CustOverride3rd') = 1 
	   )
	 RETURN

	DECLARE @mpos SMALLMONEY, @apos SMALLMONEY, @spos SMALLMONEY, @mapos1 SMALLMONEY, @mapos2 SMALLMONEY, @mapos SMALLMONEY, @maxspos SMALLMONEY, @maxmapos SMALLMONEY

	IF @mode = 'Keno'
	BEGIN		
		--check agent min/max
		--update a1=n2 when a1<n2
		UPDATE cs
		SET cs.apositiontaking = aco.minpositiontaking,
			cs.mpositiontaking = CASE WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking ELSE cs.mpositiontaking END
		FROM CustSettingGame cs	with (ROWLOCK, UPDLOCK)
			INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend AND cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype
			INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype
			AND cs.apositiontaking < aco.minpositiontaking
	
		--Recal AUTO MPT 
		--Update m1=min(m3-a1,(im1?um1,um2))
		UPDATE cs
		SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END THEN
					CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END ELSE mcs.mpositiontaking - cs.apositiontaking END
		FROM CustSettingGame cs with (ROWLOCK, UPDLOCK)
			INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = @recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
			INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
			AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)
		
		--check master min/max
		--update m1=n3-a1 if a1+m1<n3
		UPDATE cs
		SET cs.mpositiontaking = CASE WHEN cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking THEN mco.minpositiontaking - cs.apositiontaking ELSE cs.mpositiontaking END
		FROM CustSettingGame cs with (ROWLOCK, UPDLOCK)
			INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend AND mco.sporttype = @sporttype AND mco.bettype = @bettype
		WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype= @bettype
	
		--update m1,a1 when a1+m1>m3
		--update m1=if(m3-a1<0,0,m3-a1)
		--update a1=if(a1+m1>m3,m3-m1,a1)
		UPDATE cs
		SET @mpos = CASE WHEN mcs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE mcs.mpositiontaking - cs.apositiontaking END,
			cs.mpositiontaking = @mpos,
			@apos = CASE WHEN @mpos + cs.apositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - @mpos ELSE cs.apositiontaking END,
			cs.apositiontaking = CASE WHEN @apos > aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END	
		FROM CustSettingGame cs with (ROWLOCK, UPDLOCK)
			INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
			INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
		WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype
			AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking 		
		
		--recal autopos
		UPDATE cs
		SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN
											CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END 
									ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
		FROM CustSettingGame cs with (ROWLOCK, UPDLOCK)
			INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
			INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
		WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype
			AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)
		
		--check super min/max
		--update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
		UPDATE cs
		SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
		FROM CustSettingGame cs with (ROWLOCK, UPDLOCK)
			INNER JOIN CustOverrideGame sco WITH (NOLOCK) ON sco.custid = @srecommend AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype 
		WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
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
			@mapos  = CASE WHEN @mapos > mco.minpositiontaking THEN @mapos ELSE mco.minpositiontaking END,		
			@mpos = CASE WHEN @mapos - cs.apositiontaking > 0 THEN @mapos - cs.apositiontaking ELSE 0 END,
			cs.mpositiontaking = @mpos,
			@apos = CASE WHEN @mpos + cs.apositiontaking > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
			cs.apositiontaking = CASE WHEN @apos > aco.minpositiontaking THEN @apos ELSE aco.minpositiontaking END
		FROM CustSettingGame cs with (ROWLOCK, UPDLOCK)
			INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
			INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
			INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
			INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
		WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype =  @bettype
			AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
	
		RETURN	
	END
END
GO