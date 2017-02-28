ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentPTCheck]
	@custid			INT,
	@srecommend		INT,
	@mrecommend		INT,
	
	@PT				VARCHAR(MAX)='',
	@UpdateMinPT	INT = 0,
	@UpdatePresetPT INT = 0,
		
	@ErrCode		INT = 0 OUTPUT,
	@MsgType		INT = 0 OUTPUT,
	@ErrMsg			VARCHAR(4000)='' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-12-16
		Task:check input parameters for updating pt on Agent
		DB: DBCUST/CustDB
		
		Revisions:
		
		Parameter's Explanations:
		
	*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @SuperID INT, @MasterID INT, @AgentID INT 
	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				MasterPT		SMALLINT,
				IsAutoMasterPT	BIT,
				AutoMasterPT	SMALLINT,
				AgentPT			SMALLINT,				
				AgentMinPT		SMALLINT,
				AgentMaxPT		SMALLINT
				)	
	
	DECLARE @ErrType XML
	
	SELECT @SuperID = @srecommend, @MasterID = @mrecommend, @AgentID = @custid
						
	-- For read xml	
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				MasterPT,
				IsAutoMasterPT,
				AutoMasterPT,
				AgentPT,								
				AgentMinPT,
				AgentMaxPT
			)
	SELECT
		b.SportType,
		b.BetType,
		b.IsLive,
		b.MasterPT,
		b.IsAutoMasterPT,
		b.AutoMasterPT,	
		b.AgentPT,			
		b.MinPT,
		acs.MaxPT
	FROM dbo.f_DCS_PT_XMLParse(@PT) b
		INNER JOIN CustPTSetting3rd_Agent AS acs WITH (NOLOCK) ON acs.sporttype = b.sporttype AND acs.bettype = b.bettype AND acs.isLive = b.IsLive					
	WHERE acs.custid = @AgentID
	
	-- end read xml	
	
	select @ErrType = '' 
	
	SET @ErrType =
		( 			
			SELECT t.SportType, t.BetType, t.IsLive
			FROM @tblPT t
				INNER JOIN ProductSettingDetail ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																	AND t.BetType = ps.bettype 
																	AND t.IsLive = ps.IsLive		
			WHERE ps.SettingType = 1--PT
				AND (t.AgentPT < 0 OR t.MasterPT < 0 
					OR t.AgentPT + t.MasterPT > ps.MaxPT
					OR t.MasterPT > ps.MaxPT			
					OR t.AutoMasterPT < 0 
					OR t.AutoMasterPT > ps.MaxPT
					)
			FOR XML RAW('Row'), TYPE													
		)
	
	IF @ErrType IS NOT NULL
    BEGIN       
		SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
						+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                , @ErrCode = 200
                , @MsgType = 5                                    
        RETURN
    END
    
	SELECT @ErrCode = MAX (CASE	WHEN m.MaxPT < a.AgentMinPT THEN 199 --check l3 >= n2 
								WHEN a.AgentPT < a.AgentMinPT THEN 198 --check a2 >= n2     
								WHEN a.IsAutoMasterPT = 0 AND a.MasterPT > m.MasterPT  THEN 197 --check m2 > m3
								WHEN (a.IsAutoMasterPT = 0 AND (a.MasterPT + a.AgentPT > m.MaxPT OR a.MasterPT + a.AgentPT  < m.MinPT))
									OR (a.IsAutoMasterPT = 1 AND (a.AgentPT > m.MaxPT OR a.AgentPT + a.AutoMasterPT < m.MinPT)) THEN 196 --check n3<=m2+a2<=l3 if im2 = 0, a2<=l3 and um2+a2>=n3 if im2 = 1           
								WHEN a.AgentPT > a.AgentMaxPT OR a.AgentPT < a.AgentMinPT THEN 195 --n2<=a2<=l2   
								WHEN (a.IsAutoMasterPT=0 AND (a.AgentPT > CASE WHEN s.AgentPT<= CASE WHEN m.MasterPT < s.MasterPT THEN m.MasterPT ELSE s.MasterPT END - a.MasterPT THEN s.AgentPT 
																			ELSE CASE WHEN m.MasterPT < s.MasterPT THEN m.MasterPT ELSE s.MasterPT END - a.MasterPT END)) 
									OR (a.IsAutoMasterPT>0 AND (a.AgentPT > CASE WHEN s.AgentPT<= CASE WHEN m.MasterPT < s.MasterPT THEN m.MasterPT ELSE s.MasterPT END THEN s.AgentPT 
																			ELSE CASE WHEN m.MasterPT < s.MasterPT THEN m.MasterPT ELSE s.MasterPT END END)) THEN 194 --check a2<= Min(A4, Min(m3,m4)-M2) if im2 =0, a2<= Min(A4, Min(m3,m4)) if im2 =1  
								WHEN a.AgentPT + a.MasterPT > (CASE WHEN m.MasterPT < s.MasterPT THEN m.MasterPT ELSE s.MasterPT END) THEN 193 --check m2+a2<=min(m3,m4)
								WHEN a.IsAutoMasterPT = 1 AND a.AutoMasterPT > (CASE WHEN m.MasterPT < m.MaxPT THEN CASE WHEN m.MasterPT < s.MasterPT THEN m.MasterPT ELSE s.MasterPT END 
																				ELSE CASE WHEN m.MaxPT < s.MasterPT THEN m.MaxPT ELSE s.MasterPT END END) THEN 192 --check u2<=min(m3,m4,l3)
								WHEN a.IsAutoMasterPT = 1 AND a.AutoMasterPT < (CASE WHEN m.MinPT > s.AgentPT THEN m.MinPT - s.AgentPT ELSE 0 END) THEN 191 --check u2>= Max(0, N3-A4)        
								WHEN a.IsAutoMasterPT = 0 AND a.MasterPT > (CASE WHEN m.MasterPT < m.MaxPT THEN CASE WHEN m.MasterPT < s.MasterPT THEN m.MasterPT ELSE s.MasterPT END
																			ELSE CASE WHEN m.MaxPT < s.MasterPT THEN m.MaxPT ELSE s.MasterPT END END) THEN 190 --check m2<=min(m3,m4,l3) 
								WHEN a.IsAutoMasterPT = 0 AND a.MasterPT < (CASE WHEN m.MinPT > s.AgentPT THEN m.MinPT - s.AgentPT ELSE 0 END) THEN 189 --check m2>= Max(0, N3-A4) 
								ELSE 0 END)
	FROM dbo.CustPTSetting3rd_Agent m WITH(NOLOCK) 
		INNER JOIN dbo.CustPTSetting3rd_Agent s ON m.sporttype = s.sporttype AND m.bettype = s.bettype AND m.IsLive = s.IsLive
		INNER JOIN @tblPT a ON s.sporttype = a.sporttype AND s.bettype = a.bettype AND s.IsLive = a.IsLive
	WHERE m.custid = @MasterID AND s.custid = @SuperID
	  
	SELECT @ErrCode = ISNULL(@ErrCode,0)
	  	    
    --Update Min PT        
	IF @UpdateMinPT = 1        
	BEGIN        
		IF @ErrCode = 199
		BEGIN
			--check l3 >= n2    
			SELECT @ErrType = ''  	
				
			SELECT @ErrType = 
			(
				SELECT b.SportType, b.BetType,b.IsLive 
				FROM CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) 
				  INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
											AND mcs.bettype = b.bettype        
											AND mcs.isLive = b.isLive			  
				WHERE mcs.custid = @MasterID
					AND mcs.MaxPT < b.AgentMinPT
				FOR XML RAW('Row'), TYPE
			)    		
		
			IF @ErrType IS NOT NULL
			BEGIN       
				SELECT @ErrMsg = '<Root MsgID="20030" Msg="The Agent Min PT violates Master Max PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 5                                    
				RETURN
			END   
		END
		ELSE IF @ErrCode = 198
		BEGIN
			--check a2 >= n2       
			SELECT @ErrType = ''  	
				
			SELECT @ErrType = 
			(
				SELECT b.SportType, b.BetType,b.IsLive 
				FROM @tblPT b				
				WHERE b.AgentPT < b.AgentMinPT
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
	 END  
	 
	 IF @UpdatePresetPT = 1
	 BEGIN
		IF @ErrCode = 197
		BEGIN
			--check m2 > m3   
			SELECT @ErrType = ''  			
		  
			SELECT @ErrType =
			(			 
				SELECT b.SportType, b.BetType, b.IsLive, mcs.MasterPT as MaxPT											
				FROM         
					CustPTSetting3rd_Agent AS mcs WITH (NOLOCK)     
					INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
											AND mcs.bettype = b.bettype        
											AND mcs.isLive = b.isLive			
				WHERE mcs.custid = @MasterID
					AND b.IsAutoMasterPT = 0
					AND b.MasterPT > mcs.MasterPT
				FOR XML RAW('Row'), TYPE
			)
		
			IF @ErrType IS NOT NULL
			BEGIN       
				SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 3                                    
				RETURN
			END    
		END
		ELSE IF @ErrCode = 196
		BEGIN
			--check n3<=m2+a2<=MIN(l3,M3) if im2 = 0,         
			--a2<=MIN(l3,M3) and um2+a2>=n3 if im2 = 1        
			SELECT @ErrType = ''        
		
			SELECT @ErrType =
			(
				SELECT b.SportType, b.BetType, b.IsLive, mcs.MinPT
							, CASE WHEN mcs.MaxPT	> mcs.MasterPT THEN mcs.MasterPT ELSE  mcs.MaxPT END	MaxPT			
				FROM 
					CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) 
					INNER JOIN @tblPT b ON mcs.sporttype=b.sporttype 
											AND mcs.bettype = b.bettype        
											AND mcs.isLive = b.isLive       			
				WHERE mcs.custid = @MasterID 
					AND (         
							(b.IsAutoMasterPT=0
							AND (b.MasterPT + b.AgentPT > CASE WHEN mcs.MaxPT	> mcs.MasterPT THEN mcs.MasterPT ELSE  mcs.MaxPT END OR b.MasterPT + b.AgentPT  < mcs.MinPT)
							)
							OR         
							(b.IsAutoMasterPT>0 
							AND (b.AgentPT > CASE WHEN mcs.MaxPT	> mcs.MasterPT THEN mcs.MasterPT ELSE  mcs.MaxPT END OR b.AgentPT + b.AutoMasterPT < mcs.MinPT)
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
		ELSE IF @ErrCode = 195
		BEGIN	
			--n2<=a2<=l2        
			SELECT @ErrType = ''        
		
			SELECT @ErrType=
			(
				SELECT b.SportType, b.BetType, b.IsLive, cs.MinPT, cs.MaxPT				
				FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK) 
					INNER JOIN @tblPT b ON cs.sporttype=b.sporttype 
											AND cs.bettype = b.bettype        
											AND cs.isLive = b.isLive			
				WHERE cs.custid = @AgentID 
					AND (b.AgentPT > cs.MaxPT OR b.AgentPT < cs.MinPT)
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
		ELSE IF @ErrCode = 194
		BEGIN	
			--check a2<= Min(A4, Min(m3,m4)-M2) if im2 =0        
			--check a2<= Min(A4, Min(m3,m4)) if im2 =1        
			SELECT @ErrType = ''        
			SELECT @ErrType =
			(
				SELECT b.SportType, b.BetType, b.IsLive,						     
						CASE WHEN b.IsAutoMasterPT=0        
							THEN (CASE WHEN scs.AgentPT<= CASE WHEN mcs.MasterPT < scs.MasterPT 
																THEN mcs.MasterPT ELSE scs.MasterPT 
															END - b.MasterPT 
										THEN scs.AgentPT 
										ELSE CASE WHEN mcs.MasterPT < scs.MasterPT 
																THEN mcs.MasterPT ELSE scs.MasterPT 
															END - b.MasterPT 
										END
								)        
							ELSE (CASE WHEN scs.AgentPT<= CASE WHEN mcs.MasterPT < scs.MasterPT 
																THEN mcs.MasterPT ELSE scs.MasterPT 
															END 
										THEN scs.AgentPT 
										ELSE CASE WHEN mcs.MasterPT < scs.MasterPT 
														THEN mcs.MasterPT ELSE scs.MasterPT 
													END
										END
								)        
							END as MaxPT						
				FROM CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) 
					INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
												AND mcs.bettype = b.bettype        
												AND mcs.isLive = b.IsLive 	
					INNER JOIN CustPTSetting3rd_Agent AS scs WITH (NOLOCK) ON scs.sporttype=b.sporttype AND scs.bettype = b.bettype AND scs.isLive = b.IsLive        			
				WHERE mcs.custid = @MasterID AND scs.custid = @SuperID 
					AND (         
							(b.IsAutoMasterPT=0
							AND (b.AgentPT > CASE WHEN scs.AgentPT<= CASE WHEN mcs.MasterPT < scs.MasterPT 
																		THEN mcs.MasterPT ELSE scs.MasterPT 
																	END - b.MasterPT 
													THEN scs.AgentPT 
													ELSE CASE WHEN mcs.MasterPT < scs.MasterPT 
																		THEN mcs.MasterPT ELSE scs.MasterPT 
																	END - b.MasterPT 
												END
								)
							) 
							OR 
							(b.IsAutoMasterPT>0 
							AND (b.AgentPT > CASE WHEN scs.AgentPT<= CASE WHEN mcs.MasterPT < scs.MasterPT 
																		THEN mcs.MasterPT ELSE scs.MasterPT 
																	END 
													THEN scs.AgentPT 
													ELSE CASE WHEN mcs.MasterPT < scs.MasterPT 
																THEN mcs.MasterPT ELSE scs.MasterPT 
															END
											END
								)
							)        
						)
			FOR XML RAW('Row'), TYPE
			)
		         
			IF @ErrType IS NOT NULL
			BEGIN       
				SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 3                                   
				RETURN
			END
		END  
		ELSE IF @ErrCode = 193
		BEGIN
			--check m2+a2<=min(m3,m4) - Vinh        
			SELECT @ErrType = ''        
			SELECT @ErrType = 
			(
				SELECT b.SportType, b.BetType, b.IsLive,
						CASE WHEN mcs.MasterPT < scs.MasterPT 
								THEN mcs.MasterPT 
								ELSE scs.MasterPT 
						END as MaxPT						
				FROM @tblPT b
					INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @SuperID 
																			AND scs.sporttype=b.sporttype 
																			AND scs.bettype = b.bettype        
																			AND scs.isLive = b.IsLive
					INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @MasterID 
																			AND mcs.sporttype=b.sporttype 
																			AND mcs.bettype = b.bettype        
																			AND mcs.isLive = b.IsLive															        			
				WHERE b.AgentPT + b.MasterPT > (CASE WHEN mcs.MasterPT < scs.MasterPT 
														THEN mcs.MasterPT 
														ELSE scs.MasterPT 
												END)
				FOR XML RAW('Row'), TYPE											
			)											
		
			IF @ErrType IS NOT NULL
			BEGIN       
				SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 3                                   
				RETURN
			END  
		END		
		ELSE IF @ErrCode = 192
		BEGIN
			--check u2<=min(m3,m4,l3) - Phuc@20081209        
			SELECT @ErrType = ''    
			SELECT @ErrType =
			(
			SELECT b.SportType, b.BetType, b.IsLive,			
				CASE WHEN mcs.MasterPT < mcs.MaxPT
						 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
						ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
					END as MaxPT		        
			FROM @tblPT b
				INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @SuperID 
																		AND scs.sporttype=b.sporttype 
																		AND scs.bettype = b.bettype        
																		AND scs.isLive = b.IsLive
				INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @MasterID 
																		AND mcs.sporttype=b.sporttype 
																		AND mcs.bettype = b.bettype        
																		AND mcs.isLive = b.IsLive															        			
			WHERE b.IsAutoMasterPT = 1
				AND b.AutoMasterPT > (CASE WHEN mcs.MasterPT < mcs.MaxPT
											 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
											ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
										END)
			FOR XML RAW('Row'), TYPE								
			)
		
			IF @ErrType IS NOT NULL
			BEGIN       
				SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 3                                   
				RETURN
			END  
		END	
		ELSE IF @ErrCode = 191
		BEGIN
			--check u2>= Max(0, N3-A4)        
			SELECT @ErrType = ''        
			SELECT @ErrType =
			(
				SELECT b.SportType, b.BetType, b.IsLive,	
						CASE WHEN mcs.MinPT - scs.AgentPT > 0 
								THEN mcs.MinPT - scs.AgentPT 
							ELSE 0 END as MinPT
				FROM CustPTSetting3rd_Agent mcs WITH (NOLOCK)         
					INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK) ON scs.custid=@SuperID 
																			AND mcs.sporttype=scs.sporttype 
																			AND mcs.bettype=scs.bettype        
																			AND mcs.isLive = scs.isLive
					INNER JOIN @tblPT b ON b.sporttype = mcs.sporttype 
											AND b.bettype = mcs.bettype        
											AND b.IsLive = mcs.isLive			
				WHERE mcs.custid = @MasterID 
					AND b.IsAutoMasterPT = 1         
					AND b.AutoMasterPT < (CASE WHEN mcs.MinPT > scs.AgentPT
												THEN mcs.MinPT - scs.AgentPT ELSE 0 END)        
				FOR XML RAW('Row'), TYPE	
			)										
		
			IF @ErrType IS NOT NULL
			BEGIN       
				SELECT @ErrMsg = '<Root MsgID="20032" Msg="The position taking violates Master Min PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 2                                   
				RETURN
			END  
		END
		ELSE IF @ErrCode = 190
		BEGIN
			--check m2<=min(m3,m4,l3)         
			SELECT @ErrType = '' 
			SELECT @ErrType =
			(
				SELECT b.SportType, b.BetType, b.IsLive,	
						CASE WHEN mcs.MasterPT < mcs.MaxPT
							 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
							ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
						END as MaxPT				        
				FROM @tblPT b
					INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @SuperID 
																			AND scs.sporttype=b.sporttype 
																			AND scs.bettype = b.bettype        
																			AND scs.isLive = b.IsLive
					INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @MasterID 
																			AND mcs.sporttype=b.sporttype 
																			AND mcs.bettype = b.bettype        
																			AND mcs.isLive = b.IsLive		
				WHERE b.IsAutoMasterPT = 0
					AND b.MasterPT > (CASE WHEN mcs.MasterPT < mcs.MaxPT
												 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
												ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
											END)
				FOR XML RAW('Row'), TYPE									
			)
		
			IF @ErrType IS NOT NULL
			BEGIN       
				SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 3                                  
				RETURN
			END  
		END		
		ELSE IF @ErrCode = 189
		BEGIN
			--check m2>= Max(0, N3-A4) 
			SELECT @ErrType = ''        		
			SELECT @ErrType =
			(
				SELECT b.SportType, b.BetType, b.IsLive,								      
						CASE WHEN mcs.MinPT - scs.AgentPT > 0 
							THEN mcs.MinPT - scs.AgentPT ELSE 0 END as MinPT
				FROM CustPTSetting3rd_Agent mcs WITH (NOLOCK)         
					INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK) ON scs.custid=@SuperID 
																			AND mcs.sporttype=scs.sporttype 
																			AND mcs.bettype=scs.bettype        
																			AND mcs.isLive = scs.isLive
					INNER JOIN @tblPT b ON b.sporttype = mcs.sporttype 
											AND b.bettype = mcs.bettype        
											AND b.IsLive = mcs.isLive				
				WHERE mcs.custid = @MasterID 
					AND b.IsAutoMasterPT = 0         
					AND b.MasterPT < (CASE WHEN mcs.MinPT > scs.AgentPT
												THEN mcs.MinPT - scs.AgentPT ELSE 0 END)        
				FOR XML RAW('Row'), TYPE											
			)
		
			IF @ErrType IS NOT NULL
			BEGIN       
				SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @MsgType = 2                                  
				RETURN
			END  
		END
	 END-- end check      	 
END