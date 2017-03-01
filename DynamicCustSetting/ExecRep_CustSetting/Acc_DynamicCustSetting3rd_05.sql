SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_05]
    @SuperID			INT	= 0,
    @MasterID			INT = 0,
    @AgentID			INT = 0,
    @RoleID				INT	= 0,
    @AutoPT				NVARCHAR(MAX) = ''
AS
/*
    Created: Dominic
    Date: 20150901
    Task: Use Execrep to correct member PT setting values WHEN updating auto pt on master , agent(Dynamic Customer Setting)
    DB: DBCUST/CustDB
    Original versions: Acc_CustSetting3rd_05                
    Revision:

    Parameter's Explanation:
		- @AutoPT
			<ROOT>
				<PT SportType="180" BetType="1201" IsLive="0" IsAuto_New="0" IsAuto_Old="1" IsUpdAllMems="1" UpdAllMems_Value="10"/>
				<PT SportType="180" BetType="1201" IsLive="1" IsAuto_New="0" IsAuto_Old="1" IsUpdAllMems="1" UpdAllMems_Value="10"/>
			</ROOT>
*/ 
BEGIN
    SET NOCOUNT ON
    
--******************************************CHECK EXISTING TABLES*****************************************************    
    IF dbo.f_CheckRepTable('custinfo') = 0 RETURN  
    IF dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 0 RETURN  
    IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 0 RETURN  
    IF dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 0 RETURN   
    
    --Check Invalid RoleID				            
	IF @RoleID NOT IN (2,3) RETURN
--******************************************VARIABLE DECLARATION****************************************************** 
	--Line info 
	DECLARE @_SuperID INT, @_MasterID INT, @_AgentID INT, @_RoleID  INT
	
	--Affected sport/BetType/islive
	DECLARE @_SportBetTypeAutoPTTbl TABLE (
					SportType			SMALLINT,
					BetType				SMALLINT,
					IsLive				BIT,
					IsAuto_New			BIT,
					IsAuto_Old			BIT,
					IsUpdAllMems		BIT,
					UpdAllMems_Value	TINYINT
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
				
	--Super PT Setting Values		
	DECLARE @_SuperPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S4				TINYINT
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
	DECLARE @_MasterPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S3				TINYINT,
					M3				TINYINT,
					IS3				BIT,
					US3				TINYINT
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
	DECLARE @_AgentPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					M2				TINYINT,
					IM2				BIT,
					UM2				TINYINT
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
				
	DECLARE @_S1 SMALLMONEY, @_S1_auto SMALLMONEY, @_S1_notauto SMALLMONEY,
			@_M1 SMALLMONEY, @_M1_auto SMALLMONEY, @_M1_notauto SMALLMONEY,
			@_A1 SMALLMONEY, @_IS1	BIT
--******************************************VARIABLE INITITATES****************************************************** 
	--Get SMA Info
	SELECT @_SuperID = @SuperID, @_MasterID = @MasterID, @_AgentID = @AgentID , @_RoleID = @RoleID
	
	--Parse affected SportType/BetType/islive
	INSERT @_SportBetTypeAutoPTTbl(
				SportType,
				BetType,
				IsLive,
				IsAuto_New,
				IsAuto_Old,
				IsUpdAllMems,
				UpdAllMems_Value
			)
	SELECT SportType,
			BetType,
			IsLive,
			IsAuto_New,
			IsAuto_Old,
			IsUpdAllMems,
			UpdAllMems_Value
	FROM dbo.f_DCS_PT_XMLParse(@AutoPT)  
	
	IF @_RoleID = 3
	BEGIN
		--Get Super PT Setting Values
		INSERT @_SuperPTTbl(SportType,BetType,IsLive,S4)	
		SELECT cs.SportType,cs.BetType,cs.IsLive,SuperPT
		FROM dbo.CustPTSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN @_SportBetTypeAutoPTTbl mt 
			ON mt.SportType = cs.SportType
				AND mt.BetType = cs.BetType
				AND mt.IsLive = cs.IsLive
		WHERE CustID = @_SuperID
	END
	ELSE
	BEGIN
		--Get Master PT Setting Values
		INSERT @_AgentPTTbl(SportType,BetType,IsLive,M2,IM2,UM2)	
		SELECT cs.SportType,cs.BetType,cs.IsLive,MasterPT,IsAutoMasterPT,AutoMasterPT
		FROM dbo.CustPTSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN @_SportBetTypeAutoPTTbl mt 
			ON mt.SportType = cs.SportType
				AND mt.BetType = cs.BetType
				AND mt.IsLive = cs.IsLive
		WHERE CustID = @_AgentID
	END

	--Get Master PT Setting Values
	INSERT @_MasterPTTbl(SportType,BetType,IsLive,S3,M3,IS3,US3)	
	SELECT cs.SportType,cs.BetType,cs.IsLive,SuperPT,MasterPT,IsAutoSuperPT,AutoSuperPT
	FROM dbo.CustPTSetting3rd_Agent cs WITH(NOLOCK)
	INNER JOIN @_SportBetTypeAutoPTTbl mt 
		ON mt.SportType = cs.SportType
			AND mt.BetType = cs.BetType
			AND mt.IsLive = cs.IsLive
	WHERE CustID = @_MasterID



--******************************************START CORRECTING AUTO PT SETTING VALUES***************************************  								
    --UPDATE min/max pt ON master
    IF @_RoleID = 3
    BEGIN
		--Update Individual Settings
		UPDATE cs
		SET
			--Get S1, M1, A1
			@_S1 = cs.SuperPT,
			@_M1 = cs.MasterPT,
			@_A1 = cs.AgentPT,
			@_IS1 = cs.IsAutoSuperPT,
			
			--Calculate SuperAuto PT : min(s4-m1-a1,us3)
			@_S1_auto = CASE WHEN S4 - @_M1 - @_A1 > US3 THEN US3 ELSE S4 - @_M1 - @_A1 END,
			--Calculate Non Auto PT: min(s3,newspt)
			@_S1_notauto = CASE WHEN S3 > UpdAllMems_Value THEN UpdAllMems_Value ELSE S3 END,
			--if is3>0 and is1=0 s1 = @_S1_auto
			@_S1 = CASE WHEN IsAuto_New = 1 AND @_IS1 = 0 THEN @_S1_auto ELSE @_S1 END,
			--if is3 is updated from 1 to 0 AND updateallmember=1  then s1 = @_S1_notauto
			@_S1 = CASE WHEN IsAuto_Old = 1 
								AND IsAuto_New = 0 
								AND IsUpdAllMems = 1 THEN @_S1_notauto ELSE @_S1 END,
			--PT values must be in [0,100]
			@_S1 = CASE WHEN @_S1 < 0 THEN 0 ELSE @_S1 END,
			@_S1 = CASE WHEN @_S1 > 100 THEN 100 ELSE @_S1 END,
			--Aplly changes
			cs.SuperPT = @_S1
		FROM CustInfo ci WITH(NOLOCK)
            INNER JOIN CustPTSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK) 
					ON ci.CustID = cs.CustID
            INNER JOIN @_SuperPTTbl scs 
					ON scs.SportType = cs.SportType 
						AND scs.BetType = cs.BetType 
						AND scs.IsLive = cs.IsLive
			INNER JOIN @_MasterPTTbl mcs
					ON mcs.SportType = cs.SportType 
						AND mcs.BetType = cs.BetType 
						AND mcs.IsLive = cs.IsLive
			INNER JOIN @_SportBetTypeAutoPTTbl autopt
					ON autopt.SportType = cs.SportType 
						AND autopt.BetType = cs.BetType 
						AND autopt.IsLive = cs.IsLive
        WHERE ci.mrecommend = @_MasterID 
			AND ci.Roleid = 1
            AND ci.Enabled = 1 
            AND cs.IsAutoSuperPT = 0
            
		
		--Update Grouped Settings
		UPDATE cs
		SET
			--Get S1, M1, A1
			@_S1 = cs.SuperPT,
			@_M1 = cs.MasterPT,
			@_A1 = cs.AgentPT,
			@_IS1 = cs.IsAutoSuperPT,
			
			--Calculate SuperAuto PT : min(s4-m1-a1,us3)
			@_S1_auto = CASE WHEN S4 - @_M1 - @_A1 > US3 THEN US3 ELSE S4 - @_M1 - @_A1 END,
			--Calculate Non Auto PT: min(s3,newspt)
			@_S1_notauto = CASE WHEN S3 > UpdAllMems_Value THEN UpdAllMems_Value ELSE S3 END,
			--if is3>0 and is1=0 s1 = @_S1_auto
			@_S1 = CASE WHEN IsAuto_New = 1 AND @_IS1 = 0 THEN @_S1_auto ELSE @_S1 END,
			--if is3 is updated from 1 to 0 AND updateallmember=1  then s1 = @_S1_notauto
			@_S1 = CASE WHEN IsAuto_Old = 1 
								AND IsAuto_New = 0 
								AND IsUpdAllMems = 1 THEN @_S1_notauto ELSE @_S1 END,
			--PT values must be in [0,100]
			@_S1 = CASE WHEN @_S1 < 0 THEN 0 ELSE @_S1 END,
			@_S1 = CASE WHEN @_S1 > 100 THEN 100 ELSE @_S1 END,
			--Aplly changes
			cs.SuperPT = @_S1
		FROM CustInfo ci WITH(NOLOCK)
            INNER JOIN CustPTGroupSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK) 
					ON ci.CustID = cs.AgentID
            INNER JOIN @_SuperPTTbl scs 
					ON scs.SportType = cs.SportType 
						AND scs.BetType = cs.BetType 
						AND scs.IsLive = cs.IsLive
			INNER JOIN @_MasterPTTbl mcs
					ON mcs.SportType = cs.SportType 
						AND mcs.BetType = cs.BetType 
						AND mcs.IsLive = cs.IsLive
			INNER JOIN @_SportBetTypeAutoPTTbl autopt
					ON autopt.SportType = cs.SportType 
						AND autopt.BetType = cs.BetType 
						AND autopt.IsLive = cs.IsLive
        WHERE ci.mrecommend = @_MasterID 
			AND ci.Roleid = 2
            AND ci.Enabled = 1 
            AND cs.IsAutoSuperPT = 0
    END--end roleid = 3  
    ELSE
    BEGIN
		--Update Individual Settings
		UPDATE cs
		SET
			--Get S1, M1, A1
			@_S1 = cs.SuperPT,
			@_M1 = cs.MasterPT,
			@_A1 = cs.AgentPT,
			
			--Calculate SuperAuto PT : min(m3-a1,um2)
			@_M1_auto = CASE WHEN M3 - @_A1 > UM2 THEN UM2 ELSE M3 - @_A1 END,
			--Calculate Non Auto PT: m1=min(m2,@newmpositiontaking)
			@_M1_notauto = CASE WHEN M2 > UpdAllMems_Value THEN UpdAllMems_Value ELSE M2 END,
			--if im2>0 m1 = @_M1_auto
			@_M1 = CASE WHEN IsAuto_New = 1 THEN @_M1_auto ELSE @_M1 END,
			--if im2 is updated from 1 to 0 AND updateallmember=1 then s1 = @_M1_notauto
			@_M1 = CASE WHEN IsAuto_Old = 1 
								AND IsAuto_New = 0 
								AND IsUpdAllMems = 1 THEN @_M1_notauto ELSE @_M1 END,
			--PT values must be in [0,100]
			@_M1 = CASE WHEN @_M1 < 0 THEN 0 ELSE @_M1 END,
			@_M1 = CASE WHEN @_M1 > 100 THEN 100 ELSE @_M1 END,
			--Aplly changes
			cs.MasterPT = @_M1
		FROM CustInfo ci WITH(NOLOCK)
            INNER JOIN CustPTSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK) 
					ON ci.CustID = cs.CustID
			INNER JOIN @_MasterPTTbl mcs
					ON mcs.SportType = cs.SportType 
						AND mcs.BetType = cs.BetType 
						AND mcs.IsLive = cs.IsLive
			INNER JOIN @_AgentPTTbl acs 
					ON acs.SportType = cs.SportType 
						AND acs.BetType = cs.BetType 
						AND acs.IsLive = cs.IsLive
			INNER JOIN @_SportBetTypeAutoPTTbl autopt
					ON autopt.SportType = cs.SportType 
						AND autopt.BetType = cs.BetType 
						AND autopt.IsLive = cs.IsLive
        WHERE ci.recommend = @_AgentID 
			AND ci.Roleid = 1
            AND ci.Enabled = 1 
            AND cs.IsAutoMasterPT = 0
            
        --Update Grouped Settings
		UPDATE cs
		SET
			--Get S1, M1, A1
			@_S1 = cs.SuperPT,
			@_M1 = cs.MasterPT,
			@_A1 = cs.AgentPT,
			
			--Calculate SuperAuto PT : min(m3-a1,um2)
			@_M1_auto = CASE WHEN M3 - @_A1 > UM2 THEN UM2 ELSE M3 - @_A1 END,
			--Calculate Non Auto PT: m1=min(m2,@newmpositiontaking)
			@_M1_notauto = CASE WHEN M2 > UpdAllMems_Value THEN UpdAllMems_Value ELSE M2 END,
			--if im2>0 m1 = @_M1_auto
			@_M1 = CASE WHEN IsAuto_New = 1 THEN @_M1_auto ELSE @_M1 END,
			--if im2 is updated from 1 to 0 AND updateallmember=1 then s1 = @_M1_notauto
			@_M1 = CASE WHEN IsAuto_Old = 1 
								AND IsAuto_New = 0 
								AND IsUpdAllMems = 1 THEN @_M1_notauto ELSE @_M1 END,
			--PT values must be in [0,100]
			@_M1 = CASE WHEN @_M1 < 0 THEN 0 ELSE @_M1 END,
			@_M1 = CASE WHEN @_M1 > 100 THEN 100 ELSE @_M1 END,
			--Aplly changes
			cs.MasterPT = @_M1
		FROM CustPTGroupSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK) 
			INNER JOIN @_MasterPTTbl mcs
					ON mcs.SportType = cs.SportType 
						AND mcs.BetType = cs.BetType 
						AND mcs.IsLive = cs.IsLive
			INNER JOIN @_AgentPTTbl acs 
					ON acs.SportType = cs.SportType 
						AND acs.BetType = cs.BetType 
						AND acs.IsLive = cs.IsLive
			INNER JOIN @_SportBetTypeAutoPTTbl autopt
					ON autopt.SportType = cs.SportType 
						AND autopt.BetType = cs.BetType 
						AND autopt.IsLive = cs.IsLive
        WHERE cs.AgentID = @_AgentID 
            AND cs.IsAutoMasterPT = 0
	END
END


