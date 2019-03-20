/*<info serverAlias="DBCUST-CUSTDB,DBACC-bodb02" selecters="bodbAdminNet,bodbDownlineNet,vnteam" viewers="" isFunction="1"></info>*/
ALTER FUNCTION [dbo].[f_SetBinaryValues] (@binStr VARBINARY(256), @xmlStr XML)   
RETURNS TABLE  
AS  
/*
	Created: Viet @ 14.DEC.2018
	DB: DBCust/custDB

	Revision:     
		- 20181212@Viet: Initial SP [Redmine: #105338]
	Param's Explanation:   
		@xmlStr:   
			+ FORMAT: <root><r pos="" val="" /></root>  
			+ r: row  
			+ pos: Byte's position  
			+ val: new value
	Example: 
		SELECT a.custid, a.discount, b.binaryStr_new
		FROM CS_CustDiscount_Agent a WITH(NOLOCK)
			CROSS APPLY dbo.f_SetBinaryValues(a.discount, '<root><r pos="1" val="111"/><r pos="2" val="222"/></root>') as b
		WHERE a.custid in (19235084, 19235094)
*/ 
RETURN  (   
	WITH PosValCTE AS (  
		SELECT T.C.value('./@pos', 'tinyint') AS Pos,   
			CAST(T.C.value('./@val', 'tinyint') AS BINARY(1)) AS Val
		FROM @XmlStr.nodes('/root/r') as [T](C) --T: table, C: column  
	),  
	BitmapCTE AS(  
		SELECT CONVERT(BINARY(256), STUFF(CONVERT(BINARY(256), '0x00', 1), Pos, 1, Val)) AS UpdateBitmap,  
			CONVERT(BINARY(256), STUFF(CONVERT(BINARY(256), '0x00', 1), Pos, 1, CONVERT(BINARY(1), '0xFF', 1))) AS MaskBitmap  
		FROM PosValCTE  
	),  
	SplitCTE AS (  
		SELECT ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 1, 8) AS BIGINT)), 0) AS ub_1to8,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 9, 8) AS BIGINT)), 0) AS ub_9to16,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 17, 8) AS BIGINT)), 0) AS ub_17to24,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 25, 8) AS BIGINT)), 0) AS ub_25to32,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 33, 8) AS BIGINT)), 0) AS ub_33to40,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 41, 8) AS BIGINT)), 0) AS ub_41to48,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 49, 8) AS BIGINT)), 0) AS ub_49to56,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 57, 8) AS BIGINT)), 0) AS ub_57to64,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 65, 8) AS BIGINT)), 0) AS ub_65to72,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 73, 8) AS BIGINT)), 0) AS ub_73to80,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 81, 8) AS BIGINT)), 0) AS ub_81to88,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 89, 8) AS BIGINT)), 0) AS ub_89to96,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 97, 8) AS BIGINT)), 0) AS ub_97to104,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 105, 8) AS BIGINT)), 0) AS ub_105to112,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 113, 8) AS BIGINT)), 0) AS ub_113to120,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 121, 8) AS BIGINT)), 0) AS ub_121to128,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 129, 8) AS BIGINT)), 0) AS ub_129to136,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 137, 8) AS BIGINT)), 0) AS ub_137to144,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 145, 8) AS BIGINT)), 0) AS ub_145to152,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 153, 8) AS BIGINT)), 0) AS ub_153to160,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 161, 8) AS BIGINT)), 0) AS ub_161to168,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 169, 8) AS BIGINT)), 0) AS ub_169to176,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 177, 8) AS BIGINT)), 0) AS ub_177to184,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 185, 8) AS BIGINT)), 0) AS ub_185to192,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 193, 8) AS BIGINT)), 0) AS ub_193to200,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 201, 8) AS BIGINT)), 0) AS ub_201to208,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 209, 8) AS BIGINT)), 0) AS ub_209to216,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 217, 8) AS BIGINT)), 0) AS ub_217to224,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 225, 8) AS BIGINT)), 0) AS ub_225to232,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 233, 8) AS BIGINT)), 0) AS ub_233to240,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 241, 8) AS BIGINT)), 0) AS ub_241to248,
			ISNULL(SUM(CAST(SUBSTRING(UpdateBitmap, 249, 8) AS BIGINT)), 0) AS ub_249to256,  

			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 1, 8) AS BIGINT)), 0) AS mb_1to8,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 9, 8) AS BIGINT)), 0) AS mb_9to16,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 17, 8) AS BIGINT)), 0) AS mb_17to24,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 25, 8) AS BIGINT)), 0) AS mb_25to32,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 33, 8) AS BIGINT)), 0) AS mb_33to40,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 41, 8) AS BIGINT)), 0) AS mb_41to48,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 49, 8) AS BIGINT)), 0) AS mb_49to56,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 57, 8) AS BIGINT)), 0) AS mb_57to64,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 65, 8) AS BIGINT)), 0) AS mb_65to72,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 73, 8) AS BIGINT)), 0) AS mb_73to80,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 81, 8) AS BIGINT)), 0) AS mb_81to88,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 89, 8) AS BIGINT)), 0) AS mb_89to96,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 97, 8) AS BIGINT)), 0) AS mb_97to104,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 105, 8) AS BIGINT)), 0) AS mb_105to112,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 113, 8) AS BIGINT)), 0) AS mb_113to120,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 121, 8) AS BIGINT)), 0) AS mb_121to128,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 129, 8) AS BIGINT)), 0) AS mb_129to136,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 137, 8) AS BIGINT)), 0) AS mb_137to144,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 145, 8) AS BIGINT)), 0) AS mb_145to152,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 153, 8) AS BIGINT)), 0) AS mb_153to160,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 161, 8) AS BIGINT)), 0) AS mb_161to168,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 169, 8) AS BIGINT)), 0) AS mb_169to176,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 177, 8) AS BIGINT)), 0) AS mb_177to184,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 185, 8) AS BIGINT)), 0) AS mb_185to192,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 193, 8) AS BIGINT)), 0) AS mb_193to200,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 201, 8) AS BIGINT)), 0) AS mb_201to208,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 209, 8) AS BIGINT)), 0) AS mb_209to216,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 217, 8) AS BIGINT)), 0) AS mb_217to224,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 225, 8) AS BIGINT)), 0) AS mb_225to232,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 233, 8) AS BIGINT)), 0) AS mb_233to240,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 241, 8) AS BIGINT)), 0) AS mb_241to248,
			ISNULL(SUM(CAST(SUBSTRING(MaskBitmap, 249, 8) AS BIGINT)), 0) AS mb_249to256     
		FROM BitmapCTE  
	),  
	SplitOrigBitmap AS (  
		SELECT CAST(SUBSTRING(@binStr, 1, 8) AS BIGINT) AS bm_1to8,
			CAST(SUBSTRING(@binStr, 9, 8) AS BIGINT) AS bm_9to16,
			CAST(SUBSTRING(@binStr, 17, 8) AS BIGINT) AS bm_17to24,
			CAST(SUBSTRING(@binStr, 25, 8) AS BIGINT) AS bm_25to32,
			CAST(SUBSTRING(@binStr, 33, 8) AS BIGINT) AS bm_33to40,
			CAST(SUBSTRING(@binStr, 41, 8) AS BIGINT) AS bm_41to48,
			CAST(SUBSTRING(@binStr, 49, 8) AS BIGINT) AS bm_49to56,
			CAST(SUBSTRING(@binStr, 57, 8) AS BIGINT) AS bm_57to64,
			CAST(SUBSTRING(@binStr, 65, 8) AS BIGINT) AS bm_65to72,
			CAST(SUBSTRING(@binStr, 73, 8) AS BIGINT) AS bm_73to80,
			CAST(SUBSTRING(@binStr, 81, 8) AS BIGINT) AS bm_81to88,
			CAST(SUBSTRING(@binStr, 89, 8) AS BIGINT) AS bm_89to96,
			CAST(SUBSTRING(@binStr, 97, 8) AS BIGINT) AS bm_97to104,
			CAST(SUBSTRING(@binStr, 105, 8) AS BIGINT) AS bm_105to112,
			CAST(SUBSTRING(@binStr, 113, 8) AS BIGINT) AS bm_113to120,
			CAST(SUBSTRING(@binStr, 121, 8) AS BIGINT) AS bm_121to128,
			CAST(SUBSTRING(@binStr, 129, 8) AS BIGINT) AS bm_129to136,
			CAST(SUBSTRING(@binStr, 137, 8) AS BIGINT) AS bm_137to144,
			CAST(SUBSTRING(@binStr, 145, 8) AS BIGINT) AS bm_145to152,
			CAST(SUBSTRING(@binStr, 153, 8) AS BIGINT) AS bm_153to160,
			CAST(SUBSTRING(@binStr, 161, 8) AS BIGINT) AS bm_161to168,
			CAST(SUBSTRING(@binStr, 169, 8) AS BIGINT) AS bm_169to176,
			CAST(SUBSTRING(@binStr, 177, 8) AS BIGINT) AS bm_177to184,
			CAST(SUBSTRING(@binStr, 185, 8) AS BIGINT) AS bm_185to192,
			CAST(SUBSTRING(@binStr, 193, 8) AS BIGINT) AS bm_193to200,
			CAST(SUBSTRING(@binStr, 201, 8) AS BIGINT) AS bm_201to208,
			CAST(SUBSTRING(@binStr, 209, 8) AS BIGINT) AS bm_209to216,
			CAST(SUBSTRING(@binStr, 217, 8) AS BIGINT) AS bm_217to224,
			CAST(SUBSTRING(@binStr, 225, 8) AS BIGINT) AS bm_225to232,
			CAST(SUBSTRING(@binStr, 233, 8) AS BIGINT) AS bm_233to240,
			CAST(SUBSTRING(@binStr, 241, 8) AS BIGINT) AS bm_241to248,
			CAST(SUBSTRING(@binStr, 249, 8) AS BIGINT) AS bm_249to256  
	)  
	SELECT SUBSTRING(CAST((bm_1to8 & ~mb_1to8) | ub_1to8 AS BINARY(8)) +
		CAST((bm_9to16 & ~mb_9to16) | ub_9to16 AS BINARY(8)) +
		CAST((bm_17to24 & ~mb_17to24) | ub_17to24 AS BINARY(8)) +
		CAST((bm_25to32 & ~mb_25to32) | ub_25to32 AS BINARY(8)) +
		CAST((bm_33to40 & ~mb_33to40) | ub_33to40 AS BINARY(8)) +
		CAST((bm_41to48 & ~mb_41to48) | ub_41to48 AS BINARY(8)) +
		CAST((bm_49to56 & ~mb_49to56) | ub_49to56 AS BINARY(8)) +
		CAST((bm_57to64 & ~mb_57to64) | ub_57to64 AS BINARY(8)) +
		CAST((bm_65to72 & ~mb_65to72) | ub_65to72 AS BINARY(8)) +
		CAST((bm_73to80 & ~mb_73to80) | ub_73to80 AS BINARY(8)) +
		CAST((bm_81to88 & ~mb_81to88) | ub_81to88 AS BINARY(8)) +
		CAST((bm_89to96 & ~mb_89to96) | ub_89to96 AS BINARY(8)) +
		CAST((bm_97to104 & ~mb_97to104) | ub_97to104 AS BINARY(8)) +
		CAST((bm_105to112 & ~mb_105to112) | ub_105to112 AS BINARY(8)) +
		CAST((bm_113to120 & ~mb_113to120) | ub_113to120 AS BINARY(8)) +
		CAST((bm_121to128 & ~mb_121to128) | ub_121to128 AS BINARY(8)) +
		CAST((bm_129to136 & ~mb_129to136) | ub_129to136 AS BINARY(8)) +
		CAST((bm_137to144 & ~mb_137to144) | ub_137to144 AS BINARY(8)) +
		CAST((bm_145to152 & ~mb_145to152) | ub_145to152 AS BINARY(8)) +
		CAST((bm_153to160 & ~mb_153to160) | ub_153to160 AS BINARY(8)) +
		CAST((bm_161to168 & ~mb_161to168) | ub_161to168 AS BINARY(8)) +
		CAST((bm_169to176 & ~mb_169to176) | ub_169to176 AS BINARY(8)) +
		CAST((bm_177to184 & ~mb_177to184) | ub_177to184 AS BINARY(8)) +
		CAST((bm_185to192 & ~mb_185to192) | ub_185to192 AS BINARY(8)) +
		CAST((bm_193to200 & ~mb_193to200) | ub_193to200 AS BINARY(8)) +
		CAST((bm_201to208 & ~mb_201to208) | ub_201to208 AS BINARY(8)) +
		CAST((bm_209to216 & ~mb_209to216) | ub_209to216 AS BINARY(8)) +
		CAST((bm_217to224 & ~mb_217to224) | ub_217to224 AS BINARY(8)) +
		CAST((bm_225to232 & ~mb_225to232) | ub_225to232 AS BINARY(8)) +
		CAST((bm_233to240 & ~mb_233to240) | ub_233to240 AS BINARY(8)) +
		CAST((bm_241to248 & ~mb_241to248) | ub_241to248 AS BINARY(8)) +
		CAST((bm_249to256 & ~mb_249to256) | ub_249to256 AS BINARY(8)), 1, LEN(@binStr)) AS binaryStr_new  
	FROM SplitCTE  
		CROSS JOIN SplitOrigBitmap  
)
GO