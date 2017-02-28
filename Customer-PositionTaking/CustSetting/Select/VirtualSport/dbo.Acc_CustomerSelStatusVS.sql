ALTER PROCEDURE [dbo].[Acc_CustomerSelStatusVS]
	@username	VARCHAR(50),
	@ErrCode	INT				= 0		OUTPUT,
	@ErrMsg		VARCHAR(500)	= ''	OUTPUT
AS
/*
	Created: Johnson
	Date: 2012-09-04
	Task: Get status virtual sports of customer
	DB: DBCUST.CustDB

	Revisions:
		- 20121210@Scott : add more sporttype (virtual tennis : 186)
		- 20130220@Johnson: get virtual horse racing setting (sporttype : 181)
		- 20131121@Kathy: Add Virtual Greyhounds (182), Virtual Motor Racing (184) [Redmine:#7234]
		- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Parameter's Explanation:
 */
 
       
SET NOCOUNT ON           
 DECLARE @custid   INT,          
   @srecommend  INT,          
   @mrecommend  INT,          
   @recommend  INT,               
   @roleid   TINYINT,          
                
   @maxpermatchv180 MONEY,   
   @maxpermatchv181 MONEY, 
   @maxpermatchv182 MONEY,
   @maxpermatchv183 MONEY, 
   @maxpermatchv184 MONEY,    
   @maxpermatchv185 MONEY,
   @maxpermatchv186 money,         
   @DisableVS  BIT,          
   @UplineHideVS BIT        
             
 DECLARE @UplineSetting TABLE(          
         sporttype INT,           
         bettype INT,           
         minbet MONEY,           
         maxbet MONEY,           
         maxpermatch MONEY          
        )          
           
 SELECT @custid = custid , @roleid = roleid FROM customer WITH(NOLOCK) WHERE username = @username          
           
 IF @roleid NOT IN (1,2,3,4)            
 BEGIN          
  SELECT @ErrMsg = 'Invalid user.',          
    @ErrCode = 100          
  RETURN          
 END            
           
 SELECT @DisableVS = DisableVirtualSports,           
   @maxpermatchv180 = maxpermatch180,  
   @maxpermatchv181 = maxpermatch181,      
   @maxpermatchv182 = maxpermatch182,    
   @maxpermatchv183 = maxpermatch183,    
   @maxpermatchv184 = maxpermatch184,      
   @maxpermatchv185 = maxpermatch185,    
   @maxpermatchv186 = maxpermatch186,          
   @recommend = recommend,          
   @mrecommend = mrecommend,          
   @srecommend = srecommend          
 FROM custinfo WITH(NOLOCK)          
 WHERE custid = @custid          
 
 IF @roleid = 1          
  SELECT @UplineHideVS = HideVirtualSports FROM custinfo WITH(NOLOCK) WHERE custid = @recommend          
 ELSE IF @roleid = 2          
  SELECT @UplineHideVS = HideVirtualSports FROM custinfo WITH(NOLOCK) WHERE custid = @mrecommend          
 ELSE IF @roleid = 3          
  SELECT @UplineHideVS = HideVirtualSports FROM custinfo WITH(NOLOCK) WHERE custid = @srecommend          
           
 IF ISNULL(@UplineHideVS,0) = 1           
 BEGIN          
  SELECT @ErrMsg = 'The upline is not offered Virtual sports.',          
    @ErrCode = 101          
  RETURN          
 END          
           
 SELECT @custid as custid,          
  @roleid as roleid,          
  @DisableVS as DisableVirtualSports           
            
 IF @roleid = 4          
 BEGIN          
        
  SELECT sporttype, bettype, minbet, maxbet,           
  CASE WHEN sporttype = 180 THEN @maxpermatchv180   
		WHEN sporttype = 181 THEN @maxpermatchv181    
		WHEN sporttype = 182 THEN @maxpermatchv182 
		WHEN sporttype = 183 THEN @maxpermatchv183 
		WHEN sporttype = 184 THEN @maxpermatchv184 
		WHEN sporttype = 185 THEN @maxpermatchv185 
		WHEN sporttype = 186 THEN @maxpermatchv186 ELSE 0 END as maxpermatch,           
  0 as minbet_min, 0 as maxbet_max, 0 as maxpermatch_max          
  FROM custsetting3rd WITH(NOLOCK)          
  WHERE custid = @custid AND sporttype in (180,181,182,183,184,185,186) AND bettype in(1201,1231,1220)      
        
 END          
 ELSE IF @roleid = 3          
 BEGIN          
        
  INSERT INTO @UplineSetting (sporttype, bettype, minbet, maxbet, maxpermatch)          
  SELECT sporttype, bettype, minbet, maxbet,       
  case when sporttype = 180 THEN ci.maxpermatch180
		when sporttype = 181 THEN ci.maxpermatch181     
		when sporttype = 182 THEN ci.maxpermatch182     
		when sporttype = 183 THEN ci.maxpermatch183     
		when sporttype = 184 THEN ci.maxpermatch184       
		when sporttype = 185 THEN ci.maxpermatch185     
		when sporttype = 186 THEN ci.maxpermatch186 else 0 END as maxpermatch            
  FROM custsetting3rd cs WITH(NOLOCK)          
   INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid          
  WHERE cs.custid = @srecommend AND cs.sporttype in(180,181,182,183,184,185,186) AND cs.bettype in (1201,1231,1220)      
            
  SELECT cs.sporttype , cs.bettype, cs.minbet, cs.maxbet,       
 CASE WHEN cs.sporttype = 180 THEN @maxpermatchv180   
		WHEN cs.sporttype = 181 THEN @maxpermatchv181    
		WHEN cs.sporttype = 182 THEN @maxpermatchv182    
		WHEN cs.sporttype = 183 THEN @maxpermatchv183    
		WHEN cs.sporttype = 184 THEN @maxpermatchv184     
		WHEN cs.sporttype = 185 THEN @maxpermatchv185    
		WHEN cs.sporttype = 186 THEN @maxpermatchv186 else 0 END as maxpermatch,           
    us.minbet as minbet_min, us.maxbet as maxbet_max, us.maxpermatch as maxpermatch_max          
  FROM custsetting3rd cs WITH(NOLOCK)             
   JOIN @UplineSetting us ON cs.sporttype = us.sporttype and cs.bettype = us.bettype          
  WHERE cs.custid = @custid AND cs.sporttype  in(180,181,182,183,184,185,186) AND cs.bettype in(1201,1231,1220)      
        
        
 END           
ELSE IF @roleid = 2          
BEGIN         
        
	INSERT INTO @UplineSetting (sporttype, bettype, minbet, maxbet, maxpermatch)          
	SELECT sporttype, bettype, MAX(minbet) as minbet, min(case when maxbet=0 then null else maxbet end) as maxbet,       
		MIN(case	when sporttype = 180 THEN (case when ci.maxpermatch180= 0 then null else ci.maxpermatch180 end)
					when sporttype = 181 THEN (case when ci.maxpermatch181= 0 then null else ci.maxpermatch181 end)
					when sporttype = 182 THEN (case when ci.maxpermatch182= 0 then null else ci.maxpermatch182 end)
					when sporttype = 183 THEN (case when ci.maxpermatch183= 0 then null else ci.maxpermatch183 end)
					when sporttype = 184 THEN (case when ci.maxpermatch184= 0 then null else ci.maxpermatch184 end)
					when sporttype = 185 THEN (case when ci.maxpermatch185= 0 then null else ci.maxpermatch185 end)
					when sporttype = 186 THEN (case when ci.maxpermatch186= 0 then null else ci.maxpermatch186 end)  else 0 END) as maxpermatch          
	FROM custsetting3rd cs WITH(NOLOCK)          
		INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid          
	WHERE cs.custid IN (@srecommend, @mrecommend) AND cs.sporttype in(180,181,182,183,184,185,186) AND cs.bettype in(1201,1231,1220) 
	GROUP BY sporttype, bettype          
        
  SELECT cs.sporttype , cs.bettype, cs.minbet, cs.maxbet,       
  CASE WHEN cs.sporttype = 180 THEN @maxpermatchv180  
		WHEN cs.sporttype = 181 THEN @maxpermatchv181  
		WHEN cs.sporttype = 182 THEN @maxpermatchv182  
		WHEN cs.sporttype = 183 THEN @maxpermatchv183  
		WHEN cs.sporttype = 184 THEN @maxpermatchv184     
		WHEN cs.sporttype = 185 THEN @maxpermatchv185  
		WHEN cs.sporttype = 186 THEN @maxpermatchv186 ELSE 0 END as maxpermatch, us.minbet as minbet_min, us.maxbet as maxbet_max, us.maxpermatch as maxpermatch_max          
  FROM custsetting3rd cs WITH(NOLOCK)             
   JOIN @UplineSetting us ON cs.sporttype = us.sporttype and cs.bettype = us.bettype          
  WHERE cs.custid = @custid AND cs.sporttype in(180,181,182,183,184,185,186) AND cs.bettype in(1201,1231,1220)    
    
 END          
 ELSE          
 BEGIN          
  INSERT INTO @UplineSetting (sporttype, bettype, minbet, maxbet, maxpermatch)          
  SELECT sporttype, bettype, MAX(minbet) as minbet, MIN(case when maxbet=0 then null else maxbet end) as maxbet,       
 MIN(case	when sporttype = 180 THEN (case when ci.maxpermatch180= 0 then null else ci.maxpermatch180 end)
			when sporttype = 181 THEN (case when ci.maxpermatch181= 0 then null else ci.maxpermatch181 end)
			when sporttype = 182 THEN (case when ci.maxpermatch182= 0 then null else ci.maxpermatch182 end)
			when sporttype = 183 THEN (case when ci.maxpermatch183= 0 then null else ci.maxpermatch183 end)
			when sporttype = 184 THEN (case when ci.maxpermatch184= 0 then null else ci.maxpermatch184 end)
			when sporttype = 185 THEN (case when ci.maxpermatch185= 0 then null else ci.maxpermatch185 end)
			when sporttype = 186 THEN (case when ci.maxpermatch186= 0 then null else ci.maxpermatch186 end)  else 0 END) as maxpermatch          
  FROM custsetting3rd cs WITH(NOLOCK)          
   INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid          
  WHERE cs.custid IN (@srecommend, @mrecommend, @recommend) AND cs.sporttype in(180,181,182,183,184,185,186) AND cs.bettype in(1201,1231,1220)      
  GROUP BY sporttype, bettype          
            
  SELECT cs.sporttype , cs.bettype, cs.minbet, cs.maxbet,       
  CASE WHEN cs.sporttype = 180 THEN @maxpermatchv180 
		WHEN cs.sporttype = 181 THEN @maxpermatchv181      
		WHEN cs.sporttype = 182 THEN @maxpermatchv182
		WHEN cs.sporttype = 183 THEN @maxpermatchv183
		WHEN cs.sporttype = 184 THEN @maxpermatchv184 
		WHEN cs.sporttype = 185 THEN @maxpermatchv185
		WHEN cs.sporttype = 186 THEN @maxpermatchv186  ELSE 0 END as maxpermatch, us.minbet as minbet_min, us.maxbet as maxbet_max, us.maxpermatch as maxpermatch_max          
  FROM custsetting3rd cs WITH(NOLOCK)             
   JOIN @UplineSetting us ON cs.sporttype = us.sporttype and cs.bettype = us.bettype          
  WHERE cs.custid = @custid AND cs.sporttype in(180,181,182,183,184,185,186) AND cs.bettype in(1201,1231,1220)      
 END
     
	

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelStatusVS] TO [bodbAdminNet]
GO

