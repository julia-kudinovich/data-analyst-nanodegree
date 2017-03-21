SELECT DISTINCT 
      [Prop ID] = p.SCODE
	 ,[Status] =  u.sStatus
	 ,[Division] = RTRIM(at.subgroup10)
	 ,[Region] = RTRIM(at.subgroup18)
	 ,[District] = RTRIM(at.subgroup9)
	 ,[Market] = RTRIM(at.subgroup12) 
	 ,[Market Area] = RTRIM(at.SUBGROUP13)
	 ,[Entity] =  RTRIM((SELECT SPROPNAME FROM Yardi_Stage.dbo.ATTRIBUTES AS at2 WHERE at.SUBGROUP14 = SCODE))
	 ,[Address] = p.SADDR1
	 ,[City] =  p.SCITY
	 ,[State] =  p.SSTATE
	 ,[Zip] =  p.SZIPCODE
	 ,[Latitude] =  cp.Latitude
	 ,[Longitude] = cp.Longitude
	 ,[Lifecycle] = cp.ConstructionLifeCycle
	 ,[SQFT] =  u.DSQFT
	 ,[Bedrooms] = cp.Bedrooms
	 ,[Baths] =  ROUND(CAST(cp.Baths AS float), 1)
	 ,[Asking Rent] =  u.SRENT
	 ,[Asking Rent Modified Date] =  CAST(cp.AskingRentModified AS DATETIME)
	 ,[Proforma Rent] = cp.ProformaRent
	 ,[Zillow Rent] = (SELECT TOP 1 rentamount FROM  zillow.dbo.zillowdata WHERE prop_id = p.SCODE ORDER BY taxassessmentyear DESC)
	 ,[Asking Rent $/SF]	= (CASE 
	 									WHEN (u.dsqft = 0 OR u.srent = 0) THEN NULL 
										ELSE u.srent / u.dsqft 
									END) 
	 ,[Delta Ask/Proforma] = u.srent - CAST(cp.proformarent AS FLOAT)
	 ,[Delta Zillow/Proforma] = (SELECT TOP 1 rentamount FROM zillow.dbo.zillowdata WHERE prop_id = p.scode ORDER BY taxassessmentyear DESC) 
	 								  - CAST(cp.proformarent AS FLOAT)
	 ,[Market Ready Date] = CAST(mr.start AS DATETIME)
	 ,[Rent Ready Date] = CAST(rr.start AS DATETIME)
	 ,[DOM] = DATEDIFF(DAY,
	 						(CASE 
	 								WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate 
									ELSE rr.start 
							END), 
							GETDATE())
	 ,[DOM Category] = (CASE 
									WHEN Datediff(day,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), Getdate()) <31 THEN '0-30' 
									WHEN Datediff(day,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), Getdate()) BETWEEN 31 AND 61 THEN '31-60' 
									WHEN Datediff(day,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), Getdate()) BETWEEN 61 AND 91 THEN '61-90' 
									WHEN Datediff(day,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), Getdate()) >= 90 THEN '90+' 
							 END)
									
	 ,[30+] = (CASE WHEN Datediff(day,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), Getdate()) > 30 THEN 1 
	 					ELSE 0 
				  END)
	 ,[60+] = (CASE WHEN Datediff(day,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), Getdate()) > 60 THEN 1 
	 					ELSE 0 
				  END)
    ,[90+] = (CASE WHEN Datediff(day,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), Getdate()) > 60 THEN 1 
	 					ELSE 0 
				  END)	
	 ,[Leads] = (SELECT COUNT(DISTINCT MobilePhone) 
	 							FROM CRM.dbo.leads 
								WHERE PrimaryProperty = p.SCODE 
								AND CreatedOn >=(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) 
								AND MobilePhone IS NOT NULl)
								
				 + (SELECT COUNT(DISTINCT LastName) 
				 			FROM  CRM.dbo.leads 
							WHERE PrimaryProperty = p.SCODE 
							AND CreatedOn >=(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) 
							AND MobilePhone IS NULL)
				 
	 ,[Rently Showings] = (SELECT SUM(CASE WHEN access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') THEN 1 ELSE 0 END)
                               FROM [rently].[dbo].[lead_activities] rla
                               WHERE rla.tag = p.scode
										 AND rla.activity_created_at >=(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END))
										 
	 ,[Unique Rently Showings] = (SELECT COUNT(DISTINCT lead_id) 
												FROM [rently].[dbo].[lead_activities] 
												WHERE access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') 
												AND activity_created_at >=(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND tag = p.scode)
											
	 ,[Rently Showings Since Last Rent Modified Date] = (SELECT SUM((CASE WHEN access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') THEN 1 ELSE 0 END))
									                               FROM [rently].[dbo].[lead_activities] rla
									                               WHERE rla.tag = p.scode
																			 AND rla.activity_created_at >=cp.askingrentmodified)
																			 
	,[Unique Rently Showings Since Last Rent Modified Date] = (SELECT COUNT(DISTINCT lead_id) 
																						FROM  [rently].[dbo].[lead_activities] 
																						WHERE access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') 
																						AND activity_created_at >=cp.askingrentmodified AND tag = p.scode) 
																						
	,[Last Rently Showing] = 	(SELECT TOP 1 cast(activity_created_at as datetime)
		                               FROM [rently].[dbo].[lead_activities] rla
		                               WHERE  rla.tag = p.scode AND access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') 
												 AND rla.activity_created_at >= (CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END)
		                               ORDER BY activity_created_at DESC) 
		
	,[Days from the Last Rently Showing] =  DATEDIFF(day, 
																		(SELECT TOP 1 activity_created_at 
																				FROM [rently].[dbo].[lead_activities] rla
								                               		WHERE rla.tag = p.scode 
																				AND access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') 
																		 		AND rla.activity_created_at >=(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END)
								                               		ORDER BY activity_created_at DESC) ,
																		GETDATE())
																		  
	,[All Yardi Apps] = (SELECT COUNT(DISTINCT hMy) 
                               FROM  Yardi_Stage.dbo.prospect
                               WHERE  hProperty = p.HMY 
										 AND dtApply >=(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END))
										 
   ,[Screened Apps] = (SELECT COUNT(DISTINCT appid) 
                               FROM   Applications.dbo.apps
                               WHERE  property = p.SCODE 
										 AND date >=(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END))
										 
	,[Approved Apps] = (SELECT COUNT(DISTINCT appid)
                               FROM  Applications.dbo.apps
                               WHERE property = p.SCODE 
										 AND final_approved = 1 
										 AND date >=(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END))
										 
	,[Avg School Rating] = (SELECT ROUND(AVG(CAST(testrating_text AS float)), 1)
                               FROM  [education.com].dbo.schoolsearch
                               WHERE prop_id = u.SCODE) 
                               
	,[Last Visited] = cp.lastvisited                                 
                               
                               
FROM   Yardi_Stage.dbo.PROPERTY p 
		INNER JOIN Yardi_Stage.dbo.UNIT u ON p.HMY = u.HPROPERTY 
		INNER JOIN CRM.dbo.properties cp ON cp.PropId = p.SCODE 
		LEFT OUTER JOIN Yardi_Stage.dbo.TENANT t ON t.HPROPERTY = u.HPROPERTY AND t.ISTATUS NOT IN (5, 6, 7, 8, 9) 
		INNER JOIN Yardi_Stage.dbo.ATTRIBUTES at ON at.HPROP = p.HMY
		OUTER APPLY (SELECT TOP 1 *  FROM CRM.dbo.constructionhistory WHERE Name =CONCAT(p.SCODE, '- Rent Ready')  ORDER BY Start DESC) rr
		OUTER APPLY (SELECT TOP 1 *  FROM CRM.dbo.constructionhistory WHERE Name =CONCAT(p.SCODE, '- Market Ready') ORDER BY enddate DESC) mr
                         
WHERE 1=1
-- AND u.sStatus IN ('Vacant rented Ready', 'Vacant Unrented Ready') 
AND NOT EXISTS (SELECT ISTATUS FROM Yardi_Stage.dbo.TENANT WHERE (SUNITCODE = u.SCODE) AND ISTATUS = 2)

AND p.scode='nc00008'

-- Uncomment for Aged Rent Ready Report with DOM>=30 days
/*
and DATEDIFF(DAY,
	 					(CASE 
	 							WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate 
								ELSE rr.start 
						END), 
					GETDATE()) >=30
*/
