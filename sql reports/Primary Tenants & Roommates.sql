-- Primary Tenant
SELECT DISTINCT
 	  [Property ID] = rtrim(t.sunitcode)
	 ,[Tenant ID] =  t.scode
	 ,[Tenant Status] = (SELECT status
	 									FROM yardi_stage.dbo.tenstatus where istatus=t.istatus)
	 ,[Last Name] = t.slastname
	 ,[First Name] =  t.sfirstname
	 ,[Office Phone Number] = t.sphonenum0
	 ,[Home Phone Number] = t.sphonenum1
	 ,[FAX] = t.sphonenum2
	 ,[Mobile Phone Number] = t.sphonenum3
	 ,[Email] = t.semail
	 ,[Total Roommate Count] = (SELECT COUNT(DISTINCT hmyperson) 
	 											FROM yardi_stage.dbo.room 
												WHERE hmytenant=t.hmyperson)
	 ,[Roommate Count With Distinct Lastnames] = (SELECT COUNT(DISTINCT p.ulastname) 
	 																	FROM yardi_stage.dbo.room  
																		LEFT JOIN yardi_stage.dbo.person p ON p.hmy=hmyperson 
																		WHERE hmytenant=t.hmyperson 
																		AND t.slastname!=ulastname)
FROM yardi_stage.dbo.tenant t

	WHERE 1=1
 AND sunitcode IN ('')
 AND istatus IN (0,4)
 ORDER BY 1;


-- Roommates
SELECT DISTINCT
	 [Property ID] = rtrim(pr.scode)
	,[Primary Tenant ID] = t.scode
	,[Roommate ID] = p.ucode
	,[Roommate Last Name] = p.ulastname
	,[Roommate First Name] = p.sfirstname
	,[Email] = p.semail
	,[Lessee?] = (CASE
							WHEN r.boccupant=0 THEN 'Lessee' 
							ELSE NULL
					 END)
FROM yardi_stage.dbo.room r
 	LEFT JOIN yardi_stage.dbo.tenant t ON t.hmyperson=r.hmytenant 
 	LEFT JOIN yardi_stage.dbo.person p ON p.hmy=r.hmyperson
  	LEFT JOIN yardi_stage.dbo.property pr ON pr.hmy=t.hproperty

	WHERE t.istatus IN (0,4) -- current, notice
	AND p.ipersontype=93  -- roommate itype
	AND r.dtmoveout is null -- not a past roommate
 	AND pr.scode IN  ('')
	AND r.boccupant=0 -- only lessees

ORDER BY 1,2;