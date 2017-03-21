SELECT DISTINCT 
	 [Prop No.] = p.SCODE 
	,[Tenant ID] = t.scode 
	,[Original Sign Date] = (CASE 
  										WHEN cl.sign_date IS NULL THEN t.dtsigndate
  										ELSE cl.sign_date
									END)
	,[Move in Date] = cl.move_in
	,[Month of Sign Date] = MONTH(CASE 
  												WHEN cl.sign_date IS NULL THEN t.dtsigndate
  												ELSE cl.sign_date
											END) 
	,[Year of Sign Date] = YEAR(CASE 
  												WHEN cl.sign_date IS NULL THEN t.dtsigndate
  												ELSE cl.sign_date
										END) 

	,[Renewal Date] = (CASE 
								WHEN cl.lease_type='Renewal' THEN t.dtrenewdate
								ELSE NUll
							END)
	,[Lease From] = cl.lease_start
	,[Lease To] = cl.lease_end
	,[Move Out] = cl.move_out
	,[Lease Type] = cl.lease_type
	,[Tenant Status] = cl.tenant_status 
	,[Lease Rent] = cl.lease_rent
	,[Rent from Camrule Table] = ISNULL((SELECT TOP 1 destimated 
															FROM Yardi_Stage.dbo.camrule 
															WHERE htenant=t.hmyperson 
															AND hchargecode IN (10) 
															AND dtfrom>=t.dtmovein 
															ORDER BY dtfrom ASC),0)
										+ISNULL((SELECT TOP 1 destimated 
															FROM Yardi_Stage.dbo.camrule 
															WHERE htenant=t.hmyperson 
															AND hchargecode IN (11) 
															AND dtfrom>=t.dtmovein 
															ORDER BY dtfrom ASC),0)
										+ISNULL((SELECT TOP 1 destimated 
															FROM Yardi_Stage.dbo.camrule 
															WHERE htenant=t.hmyperson 
															AND hchargecode IN (18) 
															AND dtfrom>=t.dtmovein 
															ORDER BY dtfrom asc),0)
										+ISNULL((SELECT TOP 1 destimated 
															FROM Yardi_Stage.dbo.camrule 
															WHERE htenant=t.hmyperson 
															AND hchargecode IN (20) 
															AND dtfrom>=t.dtmovein 
															ORDER BY dtfrom ASC),0) 
										

	,[Unit Status] = u.sStatus 
	,[Division] = RTRIM(at.subgroup10)
	,[Region] = RTRIM(at.subgroup18)
	,[District] = RTRIM(at.subgroup9)
	,[Market] = RTRIM(at.subgroup12)
	,[Market Area] = RTRIM(at.SUBGROUP13)
	,[Entity] = RTRIM((SELECT at2.spropname 
								FROM yardi_stage.dbo.attributes at2 
								WHERE at.subgroup14 = at2.scode))
								
	,[Address] = p.SADDR1
	,[City] = p.SCITY
	,[State] = p.SSTATE
	,[ZIP] = p.SZIPCODE
	,[Latitude] = cp.Latitude
	,[Longitude] = cp.Longitude
	,[Lifecycle] = cp.ConstructionLifeCycle
	,[SQFT] = u.DSQFT
	,[Bedrooms] = cp.Bedrooms
	,[Baths] = ROUND(CAST(cp.Baths AS float), 1)
	,[Asking Rent] = u.SRENT
	,[Asking Rent Modified Date] = cp.AskingRentModified
	,[Proforma Rent] = cp.ProformaRent
	,[Zillow Rent] = (SELECT TOP 1 rentamount 
									FROM zillow.dbo.zillowdata 
									WHERE (prop_id = p.SCODE) 
									ORDER BY taxassessmentyear DESC)
	,[Asking Rent $/SF] = (CASE 
										WHEN (u.dsqft = 0 OR u.srent = 0) THEN NULL 
										ELSE u.srent / u.dsqft 
									END) 
	,[DOM] = DATEDIFF(DAY,
							(CASE WHEN(mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate 
										 ELSE rr.start 
							END) ,
					t.dtsigndate)

	,[DOM Category] = (CASE 
									WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), t.dtsigndate) <31 THEN '0-30' 
									WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), t.dtsigndate) BETWEEN 31 AND 61 THEN '31-60' 
									WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), t.dtsigndate) BETWEEN 61 AND 91 THEN '61-90' 
									WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), t.dtsigndate) >= 90 THEN '90+' 
							 END)
									
	 ,[30+] = (CASE WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), t.dtsigndate) > 30 THEN 1 
	 					ELSE 0 
				  END)
	 ,[60+] = (CASE WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), t.dtsigndate) > 60 THEN 1 
	 					ELSE 0 
				  END)
    ,[90+] = (CASE WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), t.dtsigndate) > 60 THEN 1 
	 					ELSE 0 
				  END)	

	 ,[Leads] = (SELECT COUNT(DISTINCT MobilePhone) 
	 							FROM CRM.dbo.leads 
								WHERE PrimaryProperty = p.SCODE 
								AND CreatedOn BETWEEN (CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND t .dtsigndate
								AND MobilePhone IS NOT NULl)
								
				 + (SELECT COUNT(DISTINCT LastName) 
				 			FROM  CRM.dbo.leads 
							WHERE PrimaryProperty = p.SCODE 
							AND CreatedOn BETWEEN (CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND t .dtsigndate
							AND MobilePhone IS NULL)
				 
	 ,[Rently Showings] = (SELECT SUM(CASE WHEN access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') THEN 1 ELSE 0 END)
                               FROM [rently].[dbo].[lead_activities] rla
                               WHERE rla.tag = p.scode
										 AND rla.activity_created_at BETWEEN (CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND t .dtsigndate)
										 
	 ,[Unique Rently Showings] = (SELECT COUNT(DISTINCT lead_id) 
												FROM [rently].[dbo].[lead_activities] 
												WHERE access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') 
												AND activity_created_at BETWEEN (CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND t .dtsigndate 
												AND tag = p.scode)
												
	,[Last Rently Showing] = 	(SELECT TOP 1 cast(activity_created_at as datetime)
		                               FROM [rently].[dbo].[lead_activities] rla
		                               WHERE  rla.tag = p.scode AND access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') 
												 AND rla.activity_created_at BETWEEN (CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND t .dtsigndate
		                               ORDER BY activity_created_at DESC) 
		
	,[All Yardi Apps] = (SELECT COUNT(DISTINCT hMy) 
                               FROM  Yardi_Stage.dbo.prospect
                               WHERE  hProperty = p.HMY 
										 AND dtApply >=(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END))
										 
   ,[Screened Apps] = (SELECT COUNT(DISTINCT appid) 
                               FROM   Applications.dbo.apps
                               WHERE  property = p.SCODE 
										 AND date BETWEEN (CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND t .dtsigndate)
										 
	,[Approved Apps] = (SELECT COUNT(DISTINCT appid)
                               FROM  Applications.dbo.apps
                               WHERE property = p.SCODE 
										 AND final_approved = 1 
										 AND date BETWEEN (CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND t .dtsigndate)
										 
	,[Avg School Rating] = (SELECT ROUND(AVG(CAST(testrating_text AS float)), 1)
                               FROM  [education.com].dbo.schoolsearch
                               WHERE prop_id = u.SCODE) 
                               

FROM  Yardi_Stage.dbo.tenant t 
	LEFT JOIN yardi_stage.dbo.comparable_leases cl ON cl.tenant_id=t.scode
   INNER JOIN Yardi_Stage.dbo.UNIT u ON t.HPROPERTY = u.HPROPERTY
	INNER JOIN Yardi_Stage.dbo.PROPERTY p ON p.HMY = u.HPROPERTY
	INNER JOIN CRM.dbo.properties cp ON cp.PropId = u.SCODE
	INNER JOIN Yardi_Stage.dbo.ATTRIBUTES at ON at.HPROP = u.hproperty
	OUTER APPLY (SELECT TOP 1 * 
							FROM CRM.dbo.constructionhistory 
							WHERE Name=CONCAT(p.SCODE, '- Rent Ready') 
							AND start<DATEADD(day,30,t.dtsigndate) 
							ORDER BY Start DESC) rr
	OUTER APPLY (SELECT TOP 1 * 
							FROM CRM.dbo.constructionhistory 
							WHERE Name=CONCAT(p.SCODE, '- Market Ready') 
							AND EndDate<DATEADD(day,60,t.dtsigndate) 
							ORDER BY enddate DESC) mr

WHERE u.scode IN (SELECT DISTINCT t.sunitcode 
							FROM Yardi_Stage.dbo.tenant t 
							WHERE DATEDIFF(DAY,t.dtsigndate, t.dtmovein)<30)  
AND t.ISTATUS NOT IN (5, 6, 7, 8, 9)
-- and t.DTSIGNDATE>= '2014-10-01'

UNION ALL 

SELECT DISTINCT 
	 lh.property
	,lh.scode
	,lh.originalsign
	,lh.movein
	,MONTH(lh.originalsign)
	,YEAR(lh.originalsign)
	, (CASE 
			WHEN lh.leasetype='Renewal' THEN lh.signed
			ELSE NULL
		END)
	,lh.dtstart
	,lh.dtend
	,lh.vacated
	,lh.leasetype
	,lh.tenantstatus
	,lh.rentamount
	,NULL
	,[Unit Status] = u.sStatus 
	,[Division] = RTRIM(at.subgroup10)
	,[Region] = RTRIM(at.subgroup18)
	,[District] = RTRIM(at.subgroup9)
	,[Market] = RTRIM(at.subgroup12)
	,[Market Area] = RTRIM(at.SUBGROUP13)
	,[Entity] = RTRIM((SELECT at2.spropname 
								FROM yardi_stage.dbo.attributes at2 
								WHERE at.subgroup14 = at2.scode))
			
							
	,[Address] = p.SADDR1
	,[City] = p.SCITY
	,[State] = p.SSTATE
	,[ZIP] = p.SZIPCODE
	,[Latitude] = cp.Latitude
	,[Longitude] = cp.Longitude
	,[Lifecycle] = cp.ConstructionLifeCycle
	,[SQFT] = u.DSQFT
	,[Bedrooms] = cp.Bedrooms
	,[Baths] = ROUND(CAST(cp.Baths AS float), 1)
	,[Asking Rent] = u.SRENT
	,[Asking Rent Modified Date] = cp.AskingRentModified
	,[Proforma Rent] = cp.ProformaRent
	,[Zillow Rent] = (SELECT TOP 1 rentamount 
									FROM zillow.dbo.zillowdata 
									WHERE (prop_id = p.SCODE) 
									ORDER BY taxassessmentyear DESC)
							
	,[Asking Rent $/SF] = (CASE 
										WHEN (u.dsqft = 0 OR u.srent = 0) THEN NULL 
										ELSE u.srent / u.dsqft
								END) 
									
	,[DOM] = DATEDIFF(DAY,
							(CASE WHEN(mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate 
										 ELSE rr.start 
							END) ,
					lh.originalsign)

	,[DOM Category] = (CASE 
									WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), lh.originalsign) <31 THEN '0-30' 
									WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), lh.originalsign) BETWEEN 31 AND 61 THEN '31-60' 
									WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), lh.originalsign) BETWEEN 61 AND 91 THEN '61-90' 
									WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), lh.originalsign) >= 90 THEN '90+' 
							 END)
									
	 ,[30+] = (CASE WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), lh.originalsign) > 30 THEN 1 
	 					ELSE 0 
				  END)
	 ,[60+] = (CASE WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END),lh.originalsign) > 60 THEN 1 
	 					ELSE 0 
				  END)
    ,[90+] = (CASE WHEN DATEDIFF(DAY,(CASE WHEN (mr.enddate>rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END), lh.originalsign) > 60 THEN 1 
	 					ELSE 0 
				  END)	

	,[Leads] = (SELECT COUNT(DISTINCT MobilePhone) 
	 							FROM CRM.dbo.leads 
								WHERE PrimaryProperty = p.SCODE 
								AND CreatedOn BETWEEN (CASE WHEN (mr.enddate > rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND lh.originalsign
								AND MobilePhone IS NOT NULl)
								
				 + (SELECT COUNT(DISTINCT LastName) 
				 			FROM  CRM.dbo.leads 
							WHERE PrimaryProperty = p.SCODE 
							AND CreatedOn BETWEEN (CASE WHEN (mr.enddate > rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND lh.originalsign 
							AND MobilePhone IS NULL)
				 
	 ,[Rently Showings] = (SELECT SUM(CASE WHEN access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') THEN 1 ELSE 0 END)
                               FROM [rently].[dbo].[lead_activities] rla
                               WHERE rla.tag = p.scode
										 AND rla.activity_created_at BETWEEN (CASE WHEN (mr.enddate > rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND lh.originalsign)
										 
	 ,[Unique Rently Showings] = (SELECT COUNT(DISTINCT lead_id) 
												FROM [rently].[dbo].[lead_activities] 
												WHERE access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') 
												AND activity_created_at BETWEEN (CASE WHEN (mr.enddate > rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND lh.originalsign
											   AND tag = p.scode)
	
	,[Last Rently Showing] = 	(SELECT TOP 1 cast(activity_created_at as datetime)
		                               FROM [rently].[dbo].[lead_activities] rla
		                               WHERE  rla.tag = p.scode AND access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') 
												 AND rla.activity_created_at BETWEEN (CASE WHEN (mr.enddate > rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND lh.originalsign
		                               ORDER BY activity_created_at DESC) 
		
	,[All Yardi Apps] = (SELECT COUNT(DISTINCT hMy) 
                               FROM  Yardi_Stage.dbo.prospect
                               WHERE  hProperty = p.HMY 
										 AND dtApply BETWEEN (CASE WHEN (mr.enddate > rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND lh.originalsign)
										 
   ,[Screened Apps] = (SELECT COUNT(DISTINCT appid) 
                               FROM   Applications.dbo.apps
                               WHERE  property = p.SCODE 
										 AND date BETWEEN (CASE WHEN (mr.enddate > rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND lh.originalsign)
										 
	,[Approved Apps] = (SELECT COUNT(DISTINCT appid)
                               FROM  Applications.dbo.apps
                               WHERE property = p.SCODE 
										 AND final_approved = 1 
										 AND date BETWEEN (CASE WHEN (mr.enddate > rr.start OR rr.start IS NULL) THEN mr.enddate ELSE rr.start END) AND lh.originalsign)
										 
	,[Avg School Rating] = (SELECT ROUND(AVG(CAST(testrating_text AS float)), 1)
                               FROM  [education.com].dbo.schoolsearch
                               WHERE prop_id = u.SCODE) 
                            
FROM datawarehouse.dbo.leasehistory lh
	INNER JOIN yardi_stage.dbo.unit u ON lh.property=u.scode
   INNER JOIN Yardi_Stage.dbo.PROPERTY p ON p.HMY = u.HPROPERTY
	INNER JOIN CRM.dbo.properties cp ON cp.PropId = u.SCODE
	INNER JOIN Yardi_Stage.dbo.ATTRIBUTES at ON at.HPROP = u.hproperty
	OUTER APPLY (SELECT TOP 1 * 
							FROM CRM.dbo.constructionhistory 
							WHERE Name=CONCAT(p.SCODE, '- Rent Ready') 
							AND start<DATEADD(day,30,lh.originalsign) 
							ORDER BY Start DESC) rr
	OUTER APPLY (SELECT TOP 1 * 
							FROM CRM.dbo.constructionhistory 
							WHERE Name=CONCAT(p.SCODE, '- Market Ready') 
							AND EndDate<DATEADD(day,60,lh.originalsign) 
							ORDER BY enddate DESC) mr
 
ORDER BY [Prop No.], [Tenant ID] 
