/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].Acc_CustSetting_MasterPT_153_Check
	@custid		INT,	
	@srecommend INT,
	
	@PT			VARCHAR(MAX),
	@UpdateMinPT BIT = 1, 
	@UpdatePresetPT BIT = 1,
	
	@ErrCode	INT = 0 OUTPUT,
	@MsgType	INT = 0 OUTPUT,
	@ErrMsg		VARCHAR(4000)='' OUTPUT,
	@GroupID TINYINT = 1,
	@GroupType SMALLINT = 153,
	@SettingStatus TINYINT = 0
AS
/*
	Created: 20231101@Eden
	Task : check input parameters for updating pt on Master
	DB: DBCUST/CustDB
	Original:

	Revision:
	- 20231101@Eden: DCS Sportsbook Credit[redmine: #193083]

	Parameter's Explanations:
		@PT = <ROOT>
				<PT SportType="1" BetType="1" IsLive="0" SuperPT="30" IsAutoSuperPT = "0" AutoSuperPT = "0" MasterPT ="60" MinPT="0" IsUpdAllMems="1" UpdAllMems_Value="20"/>
				<PT SportType="1" BetType="1" IsLive="1" SuperPT="30" IsAutoSuperPT = "0" AutoSuperPT = "0" MasterPT ="60" MinPT="0" IsUpdAllMems="0" UpdAllMems_Value="0"/>
			</ROOT>
				
*/
BEGIN
	SET NOCOUNT ON
	SELECT @ErrCode = 0, @ErrMsg = '', @MsgType = 0
	DECLARE @SuperID INT, @MasterID INT
	CREATE TABLE #AgentTbl 	(CustID INT, UserName NVARCHAR(50))
	DECLARE @tmpPTGroup TABLE(sporttype INT
							,bettype INT
							,IsLive BIT
							,custid INT
							)

	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				SuperPT			SMALLMONEY,
				IsAutoSuperPT	BIT,
				AutoSuperPT		SMALLMONEY,
				MasterPT		SMALLMONEY,				
				MasterMinPT		SMALLMONEY,
				MasterMaxPT		SMALLMONEY,
				[ProductID] [tinyint],
				[SettingLevel] [tinyint]
				)

	DECLARE  @SiteID SMALLINT,
		@Currency SMALLINT	
	
	SELECT  @siteID = s.siteID,
			@Currency = c.currency
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid
	
	CREATE TABLE #ProductSettingDetail_MCheck(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		[MaxPT]	[smallmoney],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_MCheck(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)
	
	SELECT @SuperID = @srecommend, @MasterID = @custid
	-- For read xml
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				SuperPT,
				IsAutoSuperPT,
				AutoSuperPT,
				MasterPT,				
				MasterMinPT,
				MasterMaxPT
			)
	SELECT
		b.SportType,
		b.BetType,
		b.IsLive,
		b.SuperPT,
		b.IsAutoSuperPT,
		b.AutoSuperPT,
		b.MasterPT,		
		b.MinPT,
		mcs.MaxPT
	FROM dbo.f_DCS_PT_XMLParse(@PT) b
		INNER JOIN CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) ON mcs.sporttype = b.sporttype AND mcs.bettype = b.bettype AND mcs.IsLive = b.IsLive					
	WHERE mcs.custid = @MasterID 
	-- end read xml	

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @tblPT t
		INNER JOIN #ProductSettingDetail_MCheck ps
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer
	
	UPDATE t
	SET t.SettingLevel = ps.SettingLevel,
		t.ProductID = ps.ProductID
	FROM @tblPT t
		INNER JOIN #ProductSettingDetail_MCheck ps 
			ON ps.BetType = t.BetType 
			AND ps.SportType = t.SportType 
			AND ps.IsLive = t.IsLive

	INSERT INTO #AgentTbl(CustID, UserName)
	SELECT CustID, username FROM CustInfo WITH (NOLOCK) WHERE mrecommend = @MasterID AND roleid = 2 AND Enabled = 1

	--Check Param
    DECLARE @ErrType XML, @ErrCodeGroup INT
	
	--check master level
	SELECT @ErrCode = MAX (CASE	WHEN m.SuperPT < 0 OR m.MasterPT < 0 OR m.SuperPT + m.MasterPT > ps.MaxPT OR m.AutoSuperPT < 0 OR m.AutoSuperPT > ps.MaxPT OR m.MasterMinPT < 0 THEN 200
								WHEN m.MasterPT < m.MasterMinPT OR s.MasterPT < m.MasterMinPT THEN 199 --check min(m3,m4)>=n3
								WHEN (m.IsAutoSuperPT=0 AND (m.SuperPT + m.MasterPT > s.MaxPT OR m.SuperPT + m.MasterPT < s.MinPT))							
										OR (m.IsAutoSuperPT = 1 AND (m.MasterPT>s.MaxPT OR m.MasterPT + m.AutoSuperPT < s.MinPT)) THEN 198 --check n4<=s3+m3<=l4 if i3 = 0, m3<=l4 and u3+m3>=n4 if i3 = 1
								WHEN m.MasterPT > m.MasterMaxPT OR m.MasterPT < m.MasterMinPT  THEN 197 --check n3<=m3<=l3
								WHEN s.MasterPT < m.MasterPT THEN 196 --check m3<=m4
								WHEN s.SuperPT < m.AutoSuperPT THEN 195 --Check u3<=s4
								WHEN m.IsAutoSuperPT = 1 AND m.AutoSuperPT < (CASE WHEN s.MinPT > s.MasterPT THEN s.MinPT - s.MasterPT ELSE 0 END) THEN 194 --Check u3>=Max(0, N4-M4)        
								WHEN s.SuperPT < m.SuperPT OR m.SuperPT + m.MasterPT > s.SuperPT THEN 193 --Check s3<=s4, s3+m3<=s4
								WHEN m.IsAutoSuperPT = 0 AND m.SuperPT < CASE WHEN s.MinPT > s.MasterPT THEN s.MinPT - s.MasterPT ELSE 0 END THEN 192 --Check s3>=Max(0, N4-M4)  
								ELSE 0 END)
	FROM dbo.CustPTSetting3rd_Agent s WITH (NOLOCK) 
		INNER JOIN @tblPT m ON s.sporttype = m.sporttype AND s.bettype = m.bettype AND s.IsLive = m.IsLive
		INNER JOIN #ProductSettingDetail_MCheck ps WITH(NOLOCK) ON m.SportType = ps.Sporttype AND m.BetType = ps.bettype AND m.IsLive = ps.IsLive
	WHERE s.custid = @SuperID
	
	SELECT @ErrCode = ISNULL(@ErrCode,0)
				
	IF 	@ErrCode = 200
	BEGIN
		SET @ErrType =
			(
				SELECT t.SportType, t.BetType, t.IsLive,t.ProductID,t.SettingLevel
				FROM @tblPT t
					INNER JOIN #ProductSettingDetail_MCheck ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																		AND t.BetType = ps.bettype 
																		AND t.IsLive = ps.IsLive
				WHERE (t.SuperPT < 0 OR t.MasterPT < 0 
						OR t.SuperPT + t.MasterPT > ps.MaxPT
						OR t.AutoSuperPT < 0 
						OR t.AutoSuperPT > ps.MaxPT
						OR t.MasterMinPT < 0					
					)
				FOR XML RAW('Row'), TYPE
			)
	
		IF @ErrType IS NOT NULL
		 BEGIN        
			 SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 5
			RETURN
		END			
    END	

    IF @UpdateMinPT = 1 AND @ErrCode = 199
    BEGIN
        --check min(m3,m4)>=n3
        SELECT @ErrType = ''
	     
	     SELECT @ErrType = (     			
				SELECT b.SportType, b.BetType, b.IsLive,b.ProductID,b.SettingLevel
				FROM 
					CustPTSetting3rd_Agent AS scs WITH (NOLOCK) 
					INNER JOIN @tblPT AS b ON scs.sporttype=b.sporttype 
												AND scs.bettype = b.bettype
												AND scs.IsLive = b.IsLive
				WHERE scs.custid = @SuperID 
					AND (b.MasterPT < b.MasterMinPT OR scs.MasterPT < b.MasterMinPT)			
				FOR XML RAW('Row'), TYPE
		)
        
        IF @ErrType IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @MsgType = 5                                    
            RETURN
        END
    END	
    
    IF @UpdatePresetPT = 1
    BEGIN
		IF @ErrCode = 198
		BEGIN 
			--check n4<=s3+m3<=l4 if i3 = 0, 
			--m3<=l4 and u3+m3>=n4 if i3 = 1
			SELECT @ErrType = ''
        
			 SELECT @ErrType = (     			
					SELECT b.SportType, b.BetType, b.IsLive, scs.MinPT, scs.MaxPT ,b.ProductID,b.SettingLevel      
					FROM CustPTSetting3rd_Agent as scs WITH (NOLOCK) 
						INNER JOIN @tblPT as b ON scs.sporttype = b.sporttype 
													AND scs.bettype = b.bettype
													AND scs.IsLive = b.IsLive					
					WHERE scs.custid = @SuperID 
						AND (    
								(
									b.IsAutoSuperPT=0 
									AND (
										b.SuperPT + b.MasterPT > scs.MaxPT 
										OR b.SuperPT + b.MasterPT < scs.MinPT
										)
								) 
								OR 
								(
									b.IsAutoSuperPT >0 
									AND (
										b.MasterPT>scs.MaxPT 
										OR b.MasterPT + b.AutoSuperPT < scs.MinPT
										)
								)
						  )
					FOR XML RAW('Row'), TYPE
					)	 
              
			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20025" Msg="The position taking violates Upline Min/Max PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 4                                   
				RETURN            
			END
        END
		ELSE IF @ErrCode = 197
		BEGIN
			--n3<=m3<=l3
			SELECT @ErrType = ''        
			SELECT @ErrType = (     			
					SELECT b.SportType, b.BetType, b.IsLive, b.MasterMinPT as MinPT, mcs.MaxPT ,b.ProductID,b.SettingLevel     				
					FROM CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) 
						INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
													AND mcs.bettype = b.bettype
													AND mcs.IsLive = b.IsLive					
					WHERE mcs.custid = @MasterID 
						AND (
								b.MasterPT > mcs.MaxPT 
							OR b.MasterPT < b.MasterMinPT
							)        
					FOR XML RAW('Row'), TYPE
					)
                        
			IF @ErrType IS NOT NULL
			BEGIN            
				SELECT @ErrMsg = '<Root MsgID="20025" Msg="The position taking violates Upline Min/Max PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 4                                   
				RETURN                
                       
			END
        END				
		ELSE IF @ErrCode = 196
		BEGIN
			--check m3<=m4
			SELECT @ErrType = ''        
			SELECT @ErrType = (     			
					SELECT b.SportType, b.BetType, b.IsLive, scs.MasterPT as MaxPT,b.ProductID,b.SettingLevel				       
					FROM CustPTSetting3rd_Agent as scs WITH (NOLOCK)
						INNER JOIN @tblPT b ON scs.sporttype = b.SportType
												AND scs.bettype = b.BetType
												AND scs.IsLive = b.IsLive					
					WHERE custid = @SuperID 
						AND scs.MasterPT < b.MasterPT
					FOR XML RAW('Row'), TYPE
			)
        
			IF @ErrType IS NOT NULL
			BEGIN           
				SELECT @ErrMsg = '<Root MsgID="20027" Msg="The position taking violates Master Max PT set by company">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 3                                 
				RETURN  
			END
        END		
		ELSE IF @ErrCode = 195
		BEGIN
			--u3<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = (
				SELECT b.SportType, b.BetType, b.IsLive, cs.SuperPT as MaxPT,b.ProductID,b.SettingLevel 					
				FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK)
					INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
											AND cs.bettype = b.bettype
											AND cs.IsLive = b.IsLive														
				WHERE cs.custid = @SuperID 
					AND cs.SuperPT < b.AutoSuperPT
				FOR XML RAW('Row'), TYPE
			)
            
			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20028" Msg="The position taking violates Super Max PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 3                                 
				RETURN
			END
        END
		ELSE IF @ErrCode = 194
		BEGIN
			--u3>=Max(0, N4-M4)        
			SELECT @ErrType = ''
			SELECT @ErrType = (
						SELECT b.SportType, b.BetType, b.IsLive, (CASE WHEN scs.MinPT - scs.MasterPT > 0 THEN scs.MinPT - scs.MasterPT ELSE 0 END) as MinPT 
							,b.ProductID,b.SettingLevel
						FROM CustPTSetting3rd_Agent AS scs WITH (NOLOCK)
							INNER JOIN @tblPT b ON scs.sporttype = b.sporttype AND scs.bettype = b.bettype AND scs.IsLive = b.IsLive						
					   WHERE scs.custid = @SuperID 
							AND (b.IsAutoSuperPT >0 
								AND b.AutoSuperPT < (CASE WHEN scs.MinPT > scs.MasterPT
															THEN scs.MinPT - scs.MasterPT ELSE 0 END)
								)
						FOR XML RAW('Row'), TYPE
					)
        
			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20029" Msg=" The position taking violates Super Min PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 2                                
				RETURN            
			END 
        END
		ELSE IF @ErrCode = 193
		BEGIN
			--s3<=s4,s3+m3<=s4
			SELECT @ErrType = ''        
			SELECT @ErrType = (
						SELECT b.SportType, b.BetType, b.IsLive, cs.SuperPT as MaxPT,b.ProductID,b.SettingLevel
						FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK)
							INNER JOIN @tblPT b ON cs.sporttype = b.SportType AND cs.bettype = b.BetType AND cs.IsLive = b.IsLive																									
						WHERE custid = @SuperID 
							AND (cs.SuperPT < b.SuperPT OR b.SuperPT + b.MasterPT > cs.SuperPT)
						FOR XML RAW('Row'), TYPE
					)
        
			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20028" Msg="The position taking violates Super Max PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 3                                 
				RETURN
			END
        END
		ELSE IF @ErrCode = 192
		BEGIN
			--s3>=Max(0, N4-M4)        
			SELECT @ErrType = ''
			SELECT @ErrType = (
						SELECT b.SportType, b.BetType, b.IsLive, 
						CASE WHEN cs.MinPT - cs.MasterPT > 0 THEN cs.MinPT - cs.MasterPT ELSE 0 END as MinPT
						,b.ProductID,b.SettingLevel
			FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK)
				INNER JOIN @tblPT b ON cs.sporttype = b.SportType AND cs.bettype = b.BetType AND cs.IsLive = b.IsLive            																						      									
			WHERE cs.custid = @SuperID
				AND (b.IsAutoSuperPT = 0 
					AND b.SuperPT < CASE WHEN cs.MinPT > cs.MasterPT
											THEN cs.MinPT - cs.MasterPT ELSE 0 END)
			FOR XML RAW('Row'), TYPE									
			)										
        
			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20029" Msg="The position taking violates Super Min PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 2                                
				RETURN             
			END 
		END	

		--check agent level
		SELECT @ErrCode = MAX (CASE	WHEN a.MasterPT + a.AgentPT > m.MasterPT THEN 191 --check m2+a2<=m3
									WHEN a.AutoMasterPT > m.MasterPT AND a.IsAutoMasterPT = 1 THEN 190 --Check m3>=u2
									ELSE 0 END)
		FROM #AgentTbl c
			INNER JOIN dbo.CustPTSetting3rd_Agent a WITH(NOLOCK) on c.custid = a.custid
			INNER JOIN @tblPT m ON a.sporttype = m.sporttype AND a.bettype = m.bettype AND a.IsLive = m.IsLive		

		SELECT @ErrCode = ISNULL(@ErrCode,0)

		IF @ErrCode = 191
		BEGIN
			--m2+a2<=m3
			SELECT @ErrType = ''
        
			 SELECT @ErrType =
			(  
				SELECT b.SportType, b.BetType, IsLive, UserName,b.ProductID,b.SettingLevel 
				FROM
				( 
					 SELECT b.SportType, b.BetType, b.IsLive, username,b.ProductID,b.SettingLevel, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 				 				 
					 FROM #AgentTbl c WITH(NOLOCK) 
							INNER JOIN CustPTSetting3rd_Agent acs WITH(NOLOCK) ON c.custid = acs.custid 
							INNER JOIN @tblPT b ON acs.sporttype = b.sporttype 
													AND acs.bettype = b.bettype
													AND acs.IsLive = b.IsLive
					 WHERE acs.MasterPT + acs.AgentPT > b.MasterPT
				)b
				WHERE b.rn<=10
				FOR XML RAW('Row'), TYPE
			)
			
			IF @ErrType IS NOT NULL
			BEGIN        
				SELECT @ErrMsg = '<Root MsgID="20026" Msg="Existing agents exceeded new Master Max PT">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 1                                   
				RETURN   
			END
		END
		ELSE IF @ErrCode = 190
		BEGIN
			--m3>=u2
			SELECT @ErrType = ''        
			SELECT @ErrType =
			(  
				SELECT b.SportType, b.BetType, IsLive, UserName,b.ProductID,b.SettingLevel  
				FROM
				( 
					SELECT b.SportType, b.BetType, b.IsLive, username,b.ProductID,b.SettingLevel , ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 				 				 				
					FROM #AgentTbl ci WITH(NOLOCK)
						INNER JOIN CustPTSetting3rd_Agent cs WITH(NOLOCK) ON ci.custid = cs.custid 
						INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
												AND cs.bettype = b.bettype
												AND cs.IsLive = b.IsLive
					 WHERE cs.AutoMasterPT > b.MasterPT
					   AND cs.IsAutoMasterPT = 1
				)b
				WHERE b.rn<=10
				FOR XML RAW('Row'), TYPE
			)			

			IF @ErrType IS NOT NULL
			BEGIN        
				SELECT @ErrMsg = '<Root MsgID="20026" Msg="Existing agents exceeded new Master Max PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 1                                 
				RETURN  
			END
        END

		--check member level
		--m1+a1<=m3
		SELECT @ErrType = ''
		SELECT @ErrType =
		( 
			SELECT b.SportType, b.BetType, IsLive, UserName,b.ProductID,b.SettingLevel  
			FROM
			( 
					SELECT b.SportType, b.BetType, b.IsLive, username,b.ProductID,b.SettingLevel , ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 				 				 
					FROM custinfo ci WITH(NOLOCK) 
					INNER JOIN CustPTSetting3rd_Member cs WITH(NOLOCK) ON ci.custid = cs.custid
					INNER JOIN @tblPT b ON cs.sporttype = b.sporttype
											AND cs.bettype = b.bettype
											AND cs.IsLive = b.IsLive
					WHERE ci.mrecommend = @MasterID
					AND ci.roleid     = 1
					AND ci.Enabled    = 1
					AND cs.MasterPT + cs.AgentPT > b.MasterPT
			)b
			WHERE b.rn<= 10
			FOR XML RAW('Row'), TYPE
		)
		OPTION( FORCE ORDER)

		IF @ErrType IS NOT NULL
		BEGIN         
			SELECT @ErrMsg = '<Root MsgID="20022" Msg="Existing members exceeded new Master Max PT">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
							, @ErrCode = 189
							, @MsgType = 1                                  
			RETURN                
		END
	
		--check on grouped settings     
		--m1+a1<=m3   
		INSERT INTO @tmpPTGroup(sporttype,bettype,IsLive,custid)
		SELECT b.SportType, b.BetType, IsLive, custid 
		FROM
		(
			SELECT b.SportType, b.BetType, b.IsLive, custid, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn												
			FROM custinfo ci WITH(NOLOCK) 
				INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON ci.custid = cs.AgentID
				INNER JOIN @tblPT b ON cs.sporttype = b.sporttype
										AND cs.bettype = b.bettype
										AND cs.IsLive = b.IsLive
				WHERE ci.mrecommend = @MasterID
				AND ci.roleid     = 2
				AND ci.Enabled    = 1
				AND cs.MasterPT + cs.AgentPT > b.MasterPT
		)b
		WHERE b.rn<= 10      
      
		SELECT @ErrType = ''	 
		SELECT @ErrType =
		(  
			SELECT b.SportType, b.BetType, IsLive, UserName,b.ProductID,b.SettingLevel  
			FROM
			( 
				SELECT b.SportType, b.BetType, b.IsLive, username,t.ProductID,t.SettingLevel , ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 				 				 
				FROM custinfo c WITH(NOLOCK)
					INNER JOIN CustSettingMode3rd cm WITH(NOLOCK) ON c.custid = cm.custid
					INNER JOIN @tmpPTGroup b ON c.recommend = b.custid
					INNER JOIN @tblPT t ON t.sporttype = b.sporttype
										AND t.bettype = b.bettype
										AND t.IsLive = b.IsLive
				WHERE roleid = 1
					AND c.Enabled = 1
					AND IsGrouped = 1
			)b
			WHERE b.rn<=10
			FOR XML RAW('Row'), TYPE
		)

		IF @ErrType IS NOT NULL
		BEGIN      
			SELECT @ErrMsg = '<Root MsgID="20022" Msg="Existing members exceeded new Master Max PT">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
							, @ErrCode = 188
							, @MsgType = 1                                  
			RETURN     
		END	
	END
	SELECT @ErrCode = 0

	DROP TABLE #AgentTbl
	DROP TABLE #ProductSettingDetail_MCheck
END 