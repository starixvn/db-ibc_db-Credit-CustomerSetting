ALTER PROCEDURE [dbo].[Acc_CustSetting_SuperPTCheck]
	@custid		INT,
	@PT			VARCHAR(MAX),	
	@UpdatePresetPT INT = 0,	
	@ErrCode	INT = 0 OUTPUT,
	@MsgType	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(4000)='' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-12-16
		Task: check input parameters for updating pt on super
		DB: DBCUST/CustDB
		
		Revisions:
		
		Parameter's Explanations:
			- @PT = <ROOT>
						<PT SportType="1" BetType="1" IsLive="0" SuperPT="90" MasterPT ="90" AgentPT = "90" MinPT="0"/>
						<PT SportType="1" BetType="1" IsLive="1" SuperPT="90" MasterPT ="90" AgentPT = "90" MinPT="0"/>
				</ROOT>
			- @MsgType : xml format of error message return						
			
	*/
BEGIN
	SET NOCOUNT ON
	
	 --Check Param
    DECLARE @ErrType XML, @ErrCodeGroup INT
	CREATE TABLE #MasterTbl (CustID INT, UserName NVARCHAR(50))
	CREATE TABLE #AgentTbl 	(CustID INT, UserName NVARCHAR(50))
	DECLARE @SuperID INT
						
	DECLARE @tblPT TABLE (
				SportType	SMALLINT,
				BetType		SMALLINT,
				IsLive		BIT,
				SuperPT		SMALLINT,
				MasterPT	SMALLINT,
				AgentPT		SMALLINT,
				SuperMinPT	SMALLINT
				)
	DECLARE @tmpPTGroup TABLE(custid INT
							,sporttype INT
							,bettype INT
							,islive BIT
							)
				
	-- For read xml
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				SuperPT,
				MasterPT,
				AgentPT,
				SuperMinPT
			)
	SELECT
		SportType,
		BetType,
		IsLive,
		SuperPT,
		MasterPT,
		AgentPT,
		MinPT
	FROM dbo.f_DCS_PT_XMLParse(@PT)	
	-- end read xml				
	
	SELECT @SuperID = @custid

	INSERT INTO #MasterTbl(CustID, UserName)
	SELECT CustID, username FROM CustInfo WITH (NOLOCK) WHERE srecommend = @SuperID AND roleid = 3	

	INSERT INTO #AgentTbl(CustID, UserName)
	SELECT CustID, username FROM CustInfo WITH (NOLOCK) WHERE srecommend = @SuperID AND roleid = 2 AND Enabled = 1

	SELECT @ErrCode = MAX (CASE	WHEN s.SuperPT < 0 OR s.SuperPT > ps.MaxPT OR s.MasterPT < 0 OR s.MasterPT > ps.MaxPT OR s.AgentPT < 0 OR s.AgentPT > ps.MaxPT
									OR s.SuperMinPT < 0 OR s.SuperPT < s.MasterPT OR s.MasterPT < s.AgentPT THEN 200 
								WHEN s.SuperPT < s.SuperMinPT THEN 199 --check n4<=s4								
								ELSE 0 END)
	FROM @tblPT s
		INNER JOIN ProductSettingDetail ps WITH(NOLOCK) ON s.SportType = ps.Sporttype AND s.BetType = ps.bettype AND s.IsLive = ps.IsLive
	WHERE ps.SettingType = 1

	SELECT @ErrCode = ISNULL(@ErrCode,0)

	IF @ErrCode = 200
	BEGIN
		SET @ErrType =
			(
				SELECT t.SportType, t.BetType, t.IsLive
					FROM @tblPT t
						INNER JOIN ProductSettingDetail ps WITH(NOLOCK) ON t.SportType = ps.Sporttype AND t.BetType = ps.bettype AND t.IsLive = ps.IsLive
				WHERE ps.SettingType = 1--PT
					AND (t.SuperPT < 0 OR t.SuperPT > ps.MaxPT
						OR t.MasterPT < 0 OR t.MasterPT > ps.MaxPT
						OR t.AgentPT < 0 OR t.AgentPT > ps.MaxPT
						OR t.SuperMinPT < 0
						OR t.SuperPT < t.MasterPT 
						OR t.MasterPT < t.AgentPT				
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

    IF @UpdatePresetPT = 1
	BEGIN		
		-- check super level		
		IF @ErrCode = 199
		BEGIN
			--check n4<=s4
			 SELECT @ErrType = ''
	     
			 SELECT @ErrType = 
			 (
				 SELECT t.SportType, t.BetType, t.IsLive
				 FROM @tblPT t			
				WHERE SuperPT < SuperMinPT	
				ORDER BY t.SportType, t.BetType, t.IsLive
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

		-- check master level
		SELECT @ErrCode = MAX (CASE	WHEN ((m.IsAutoSuperPT=0) AND (m.SuperPT+m.MasterPT>s.SuperPT)) OR 
											((m.IsAutoSuperPT=1) AND (m.MasterPT>s.SuperPT)) OR 
											((m.IsAutoSuperPT=1) AND (m.AutoSuperPT>s.SuperPT)) THEN 198 --check s3+m3<=s4 if i3 = 0, m3<=s4 and u3<=s4 if i3=1
									WHEN m.MasterPT > s.MasterPT THEN 197 --Check m3<=m4
									ELSE 0 END)
		FROM #MasterTbl c 
			INNER JOIN dbo.CustPTSetting3rd_Agent m WITH (NOLOCK) ON m.CustID = c.CustID
			INNER JOIN @tblPT s ON m.sporttype = s.sporttype AND m.bettype = s.bettype AND m.IsLive = s.IsLive
		
		SELECT @ErrCode = ISNULL(@ErrCode,0)

		IF @ErrCode = 198
		BEGIN
			--check all s3+m3<=s4 if i3 = 0,
			--m3<=s4 and u3<=s4 if i3=1
			SELECT @ErrType = ''
		
			SET @ErrType =
			(
				SELECT b.SportType, b.BetType, Islive, UserName
				FROM
				(
					SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn
					FROM #MasterTbl c 
						INNER JOIN CustPTSetting3rd_Agent AS cs WITH (NOLOCK) ON cs.CustID = c.CustID
						INNER JOIN @tblPT AS b ON cs.sporttype=b.sporttype AND cs.bettype = b.BetType AND cs.isLive = b.IsLive
					WHERE (cs.IsAutoSuperPT=0 AND cs.SuperPT+cs.MasterPT>b.SuperPT)
						OR (cs.IsAutoSuperPT=1 AND cs.MasterPT>b.SuperPT) 
						OR (cs.IsAutoSuperPT=1 AND cs.AutoSuperPT>b.SuperPT)
										
				) b
				WHERE b.rn <= 10
				FOR XML RAW('Row'), TYPE
			)
	    
			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20019" Msg="Existing masters exceeded new Super Max PT">' 
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
							, @MsgType = 1
				RETURN      
			END
		END
		ELSE IF @ErrCode = 197
		BEGIN
			--Check all m3<=m4
			SELECT @ErrType = ''
		
			SELECT @ErrType =(
				SELECT b.SportType, b.BetType, IsLive, UserName
				FROM
				(
					SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn
					FROM #MasterTbl c 
						INNER JOIN CustPTSetting3rd_Agent AS cs WITH (NOLOCK) ON cs.CustID = c.CustID
						INNER JOIN @tblPT AS b ON cs.sporttype=b.sporttype AND cs.bettype = b.BetType AND cs.isLive = b.IsLive					
					WHERE cs.MasterPT > b.MasterPT
				)b	
				WHERE b.rn<= 10
				FOR XML RAW('Row'), TYPE
			)

			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20021" Msg="Existing masters exceeded new Master Max PT">' 
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
							, @MsgType = 1			        
				RETURN		
			END
		END

		--check agent level
		--Check all a2<=a4
		SELECT @ErrType = ''

		SELECT @ErrType =
		(  
			SELECT b.SportType, b.BetType, IsLive, UserName
			FROM
			( 
					SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 
					FROM #AgentTbl c
						INNER JOIN CustPTSetting3rd_Agent cs WITH(NOLOCK) ON c.CustID = cs.CustID
						INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
											AND cs.bettype = b.bettype 
											AND cs.IsLive = b.IsLive
					WHERE cs.AgentPT > b.AgentPT 
			)b
			WHERE b.rn<=10
			FOR XML RAW('Row'), TYPE
		)

		IF @ErrType IS NOT NULL
		BEGIN
			SELECT @ErrMsg = '<Root MsgID="20023" Msg="Existing agents exceeded new Agent Max PT">' 
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @ErrCode = 196
						, @MsgType = 1				
			RETURN			
		END		

		SELECT @ErrCode = MAX (CASE	WHEN 1*cs.SuperPT+cs.MasterPT+cs.AgentPT>s.SuperPT 
										OR (cs.IsAutoSuperPT = 1 AND cs.AutoSuperPT > s.SuperPT)  THEN 195 --check s1+m1+a1 <= s4, check u1<=s4 if i1=1
									WHEN cs.MasterPT + cs.AgentPT > s.MasterPT THEN 193 --Check m1+a1<=m4
									WHEN cs.AgentPT > s.AgentPT THEN 191 --Check a1<=a4
									ELSE 0 END)
		FROM #AgentTbl a
			INNER JOIN CustInfo c WITH (NOLOCK) ON c.recommend = a.CustID
			INNER JOIN dbo.CustPTSetting3rd_Member cs WITH(NOLOCK) ON cs.custid = c.custid
			INNER  JOIN @tblPT s ON cs.sporttype = s.sporttype AND cs.bettype = s.bettype AND cs.IsLive = s.IsLive
		WHERE c.Enabled = 1 and c.roleid = 1 AND c.srecommend = @SuperID

		SELECT @ErrCodeGroup = MAX(CASE WHEN 1*cs.SuperPT+cs.MasterPT+cs.AgentPT>s.SuperPT 
											OR (cs.IsAutoSuperPT = 1 AND cs.AutoSuperPT > s.SuperPT)  THEN 194 --check s1+m1+a1 <= s4, check u1<=s4 if i1=1
										WHEN cs.MasterPT + cs.AgentPT > s.MasterPT THEN 192 --Check m1+a1<=m4
										WHEN cs.AgentPT > s.AgentPT THEN 190 --Check a1<=a4
										ELSE 0 END)
		FROM #AgentTbl c
			INNER JOIN dbo.CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON c.custid = cs.AgentID
			INNER JOIN @tblPT s ON cs.sporttype = s.sporttype AND cs.bettype = s.bettype AND cs.IsLive = s.IsLive
		
		SELECT @ErrCode = ISNULL(@ErrCode,0)
		SELECT @ErrCodeGroup = ISNULL(@ErrCodeGroup,0)

		SELECT @ErrCode = CASE WHEN @ErrCode < @ErrCodeGroup THEN @ErrCodeGroup ELSE @ErrCode END -- get max ErrCode to return first error

		IF @ErrCode = 195
		BEGIN
			--check all s1+m1+a1 <= s4
			--check all u1<=s4 if i1=1
			SELECT @ErrType = ''
		
			SELECT @ErrType =(
				SELECT b.SportType, b.BetType, IsLive, UserName 
				FROM
				(
					SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn
					FROM CustPTSetting3rd_Member cs WITH(NOLOCK) 
						INNER JOIN @tblPT b ON cs.sporttype = b.sporttype AND cs.bettype = b.bettype AND cs.IsLive = b.IsLive
						INNER JOIN custinfo c WITH(NOLOCK) ON c.custid = cs.custid					
					WHERE c.custid IN (SELECT custid FROM CustInfo WITH (NOLOCK) WHERE recommend IN (SELECT CustID FROM #AgentTbl))
						AND c.roleid     = 1
						AND c.Enabled    = 1
						AND (1*cs.SuperPT+cs.MasterPT+cs.AgentPT>b.SuperPT--convert datatype to ignore sql exception
							OR (cs.IsAutoSuperPT = 1 AND cs.AutoSuperPT > b.SuperPT)  
						   )
				)b 
				WHERE b.rn<= 10
				FOR XML RAW('Row'), TYPE
			)
	    
			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20020" Msg="Existing members exceeded new Super Max PT">' 
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
							, @MsgType = 1			        
				RETURN
			END
		END
		ELSE IF @ErrCode = 194
		BEGIN
			--check pt on grouped settings
			--check s1+m1+a1 <= s4, check u1<=s4 if i1=1
		
			INSERT INTO @tmpPTGroup(sporttype,bettype,islive,custid)
			SELECT b.SportType, b.BetType, islive, custid 
			FROM
			(
				SELECT b.SportType, b.BetType, b.islive, custid, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn
				FROM #AgentTbl c
					INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON c.CustID = cs.AgentID
					INNER JOIN @tblPT b ON cs.sporttype = b.sporttype AND cs.bettype = b.bettype AND cs.IsLive = b.IsLive	
				WHERE (1*cs.SuperPT+cs.MasterPT+cs.AgentPT>b.SuperPT
						OR (cs.IsAutoSuperPT = 1 AND cs.AutoSuperPT > b.SuperPT)  
					   )
			)b
			WHERE b.rn<= 10
					
			SELECT @ErrType = ''	 
			SELECT @ErrType =
			(  
				SELECT b.SportType, b.BetType, IsLive, UserName 
				FROM
				( 
					 SELECT b.SportType, b.BetType, islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn
					 FROM custinfo c WITH(NOLOCK)
						INNER JOIN CustSettingMode3rd cm WITH(NOLOCK) ON c.custid = cm.custid
						INNER JOIN @tmpPTGroup b ON c.recommend = b.custid
					WHERE roleid = 1
						AND c.Enabled = 1
						AND IsGrouped = 1
				)b
				WHERE b.rn<= 10
				FOR XML RAW('Row'), TYPE
			)

			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20020" Msg="Existing members exceeded new Super Max PT">' 
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
							, @MsgType = 1			        
				RETURN						
			END
		END		
		ELSE IF @ErrCode = 193
		BEGIN
			--Check all m1+a1<=m4
			SELECT @ErrType = ''
		
			SELECT @ErrType =(
				SELECT b.SportType, b.BetType, IsLive, UserName
				FROM
				(
					SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn
					FROM CustPTSetting3rd_Member cs WITH(NOLOCK) 
						INNER JOIN @tblPT b ON cs.sporttype = b.sporttype AND cs.bettype = b.bettype AND cs.IsLive = b.IsLive
						INNER JOIN custinfo c WITH(NOLOCK) ON c.custid = cs.custid					
					WHERE c.custid IN (SELECT custid FROM CustInfo WITH (NOLOCK) WHERE recommend IN (SELECT CustID FROM #AgentTbl))
						   AND c.roleid     = 1
						   AND c.Enabled    = 1
						   AND cs.MasterPT + cs.AgentPT > b.MasterPT
				)b
				WHERE b.rn<=10
				FOR XML RAW('Row'), TYPE
			)

			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20022" Msg=" Existing members exceeded new Master Max PT">' 
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
							, @MsgType = 1	
				RETURN
			END
		END
		ELSE IF @ErrCode = 192
		BEGIN
			--check PT on grouped settings
			--Check all m1+a1<=m4
			INSERT INTO @tmpPTGroup(sporttype,bettype,islive,custid)
			SELECT b.SportType, b.BetType, islive, custid 
			FROM
			(
				SELECT b.SportType, b.BetType, b.islive, custid, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn						
				FROM #AgentTbl c
					INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON c.CustID = cs.AgentID
					INNER JOIN @tblPT b ON cs.sporttype = b.sporttype AND cs.bettype = b.bettype AND cs.IsLive = b.IsLive				
				WHERE cs.MasterPT + cs.AgentPT > b.MasterPT
			)b
			WHERE b.rn <= 10
		
		
			SELECT @ErrType = ''	 
			SELECT @ErrType =
			(  
				SELECT b.SportType, b.BetType, IsLive, UserName
				FROM
				( 
					 SELECT b.SportType, b.BetType, islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 
					 FROM custinfo c WITH(NOLOCK)
						INNER JOIN CustSettingMode3rd cm WITH(NOLOCK) ON c.custid = cm.custid
						INNER JOIN @tmpPTGroup b ON c.recommend = b.custid
					WHERE roleid = 1
						AND c.Enabled    = 1
						AND IsGrouped = 1
				)b
				WHERE b.rn <= 10
				FOR XML RAW('Row'), TYPE
			)
			
			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20022" Msg=" Existing members exceeded new Master Max PT">' 
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
							, @MsgType = 1				
				RETURN
			END     
		END		
		ELSE IF @ErrCode = 191
		BEGIN
			--Check all a1<=a4
			SELECT @ErrType = ''

			SELECT @ErrType =
			(  
				SELECT b.SportType, b.BetType, IsLive, UserName
				FROM
				( 
					 SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 
					 FROM CustPTSetting3rd_Member cs WITH(NOLOCK) 
						INNER JOIN @tblPT b ON cs.sporttype = b.sporttype AND cs.bettype = b.bettype AND cs.IsLive = b.IsLive
						INNER JOIN custinfo c WITH(NOLOCK) ON c.custid = cs.custid					
					WHERE c.custid IN (SELECT custid FROM CustInfo WITH (NOLOCK) WHERE recommend IN (SELECT CustID FROM #AgentTbl))
					   AND c.roleid     = 1
					   AND c.Enabled    = 1
					   AND cs.AgentPT > b.AgentPT
				)b
				WHERE b.rn<=10
				FOR XML RAW('Row'), TYPE
			)

			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20024" Msg="Existing members exceeded new Agent Max PT">' 
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
							, @MsgType = 1						
				RETURN
			END
	    END
		ELSE IF @ErrCode = 190
		BEGIN
			--check PT on grouped settings
			--Check all a1<=a4
			 SELECT @ErrType = ''
		
			INSERT INTO @tmpPTGroup(sporttype,bettype,islive,custid)
			SELECT b.SportType, b.BetType, islive, custid 
			FROM
			(
				SELECT b.SportType, b.BetType, b.islive, custid, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn									
				FROM #AgentTbl c
					INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON c.CustID = cs.AgentID
					INNER JOIN @tblPT b ON cs.sporttype = b.sporttype AND cs.bettype = b.bettype AND cs.IsLive = b.IsLive	
				 WHERE cs.AgentPT > b.AgentPT
			)b 
			WHERE b.rn<=10
		
		
			SELECT @ErrType = ''	 
			SELECT @ErrType =
			(  
				SELECT b.SportType, b.BetType, IsLive, UserName 
				FROM
				( 
					 SELECT b.SportType, b.BetType, islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 				 
					 FROM custinfo c WITH(NOLOCK)
						INNER JOIN CustSettingMode3rd cm WITH(NOLOCK) ON c.custid = cm.custid
						INNER JOIN @tmpPTGroup b ON c.recommend = b.custid
					WHERE roleid = 1
						AND c.Enabled = 1
						AND IsGrouped = 1
				)b
				WHERE b.rn<=10
				FOR XML RAW('Row'), TYPE
			)			
				
			IF @ErrType IS NOT NULL
			BEGIN
				SELECT @ErrMsg = '<Root MsgID="20024" Msg="Existing members exceeded new Agent Max PT">' 
								+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
							, @MsgType = 1									
				RETURN
			END
		END
	END	
	
	SELECT @ErrCode = 0
END	 