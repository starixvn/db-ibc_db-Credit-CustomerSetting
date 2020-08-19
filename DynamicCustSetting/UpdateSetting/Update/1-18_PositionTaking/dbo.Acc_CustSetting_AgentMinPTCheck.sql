/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE dbo.Acc_CustSetting_AgentMinPTCheck
	@custid			INT,
	@srecommend		INT,
	@mrecommend		INT,
	@PT				VARCHAR(MAX)='',
	@ErrCode		INT = 0 OUTPUT,
	@MsgType		INT = 0 OUTPUT,
	@ErrMsg			VARCHAR(4000)='' OUTPUT
AS
/*
	Created: Elodie
	Date: 20200626
	Task:check input parameters for updating min pt on Agent
	DB: DBCUST/CustDB
		
	Revisions:
		- 20200615@Elodie: Initial SP [Redmine: #135363]
	Parameter's Explanations:
		
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @SuperID INT, @MasterID INT, @AgentID INT 
	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				AgentPT			SMALLINT,	
				AgentMinPT		SMALLINT
				)	
	
	DECLARE @ErrType XML
	
	SELECT @SuperID = @srecommend, @MasterID = @mrecommend, @AgentID = @custid
						
	-- For read xml	
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,	
				AgentPT,							
				AgentMinPT
			)
	SELECT
		b.SportType,
		b.BetType,
		b.IsLive,
		acs.AgentPT, 
		b.MinPT
	FROM dbo.f_DCS_PT_XMLParse(@PT) b
		INNER JOIN CustPTSetting3rd_Agent AS acs WITH (NOLOCK) ON acs.sporttype = b.sporttype AND acs.bettype = b.bettype AND acs.isLive = b.IsLive					
	WHERE acs.custid = @AgentID
	-- end read xml	
	
	select @ErrType = '' 	
    
	SELECT @ErrCode = MAX (CASE	WHEN m.MaxPT < a.AgentMinPT THEN 199 --check l3 >= n2 
								WHEN a.AgentPT < a.AgentMinPT THEN 198 --check a2 >= n2     
								ELSE 0 END)
	FROM dbo.CustPTSetting3rd_Agent m WITH(NOLOCK) 
		INNER JOIN @tblPT a ON m.sporttype = a.sporttype AND m.bettype = a.bettype AND m.IsLive = a.IsLive
	WHERE m.custid = @MasterID
	  
	SELECT @ErrCode = ISNULL(@ErrCode,0)
	  	    
  
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