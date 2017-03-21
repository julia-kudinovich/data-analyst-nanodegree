-- Basic columns pulled from tables - source data in tables. No formulas or manipulations
SELECT DISTINCT top 100
 [Prop No.] = p.scode
,[Status] =  u.sstatus
,[Market] =  at.subgroup12
,[Address] =  p.saddr1
,[City] =  p.scity
,[State] =  p.sstate
,[Zip] =  p.szipcode
,[Lifecycle] = cp.constructionlifecycle
,[Construction Status] = cp.constructionstatus
,[SQFT] =  u.dsqft
,[Bedrooms] = cp.bedrooms
,[Baths] = cp.baths
,[Purchase Date] = cp.dateacquired
,[Certification Date] = cp.certificationdate
,[In Service Date] = cp.inservicedate
 
                
-- Selects Last Lease Sign Date For Rented Units			 
,[Lease Sign Date] = (CASE 
							   WHEN u.sstatus IN ('Occupied No Notice', 'Vacant Rented Ready', 'Notice Rented', 'Vacant Rented Not Ready') 
										THEN (SELECT TOP 1 dtsigndate 
							                  FROM yardi_stage.dbo.tenant 
							                  WHERE  sunitcode = u.scode 
							                  ORDER  BY dtsigndate DESC) 
							   ELSE NULL 
							END) 

-- Move Out Date of Previous Tenant                
,[Move Out Date] = (SELECT TOP 1 dtmoveout 
								FROM   yardi_stage.dbo.tenant 
								WHERE  sunitcode = u.scode 
							   ORDER  BY dtsigndate DESC)
                
-- Rent Charge From Tenant lease Page Where Tenant Status Indicates that the Property is leased				 
,[Rent] = (SELECT TOP 1 srent 
			   FROM   yardi_stage.dbo.tenant 
			   WHERE  sunitcode = u.scode 
				AND istatus IN ( 0, 2, 3, 4 ) 
			   ORDER  BY dtsigndate DESC) 
	
   
,[Asking Rent] = u.srent
,[Proforma Rent] = cp.proformarent 
 
 -- 3rd Party Rent Value Pulled From Source T,able               
,[Zillow Rent] = (SELECT TOP 1 rentamount 
						   FROM   zillow.dbo.zillowdata 
						   WHERE  prop_id = p.scode 
						   ORDER  BY taxassessmentyear DESC)
 
-- Rent of Previous Long Term Tenant  
,[Prior Rent] = (SELECT TOP 1 srent 
						   FROM   yardi_stage.dbo.tenant 
						   WHERE  hproperty = p.hmy 
							AND Datediff(day, dtmovein, dtmoveout) > 300 
						   ORDER  BY dtsigndate DESC) 
                
 --  Rent charge of previous tenant pulled form Tenant Directory table               
,[Prior Rent from Tenant Directory Table] = (SELECT TOP 1 rentamount 
																   FROM   [datawarehouse].dbo.tenantdirectory 
																   WHERE  Datediff(day, dtstart, dtend) > 300 
																	AND dtstart <= t.dtmovein 
																	AND property_code = p.scode 
																   ORDER  BY dtstart DESC)

-- Calculates Asking Rent Over Square Feet Where Asking Rent or SQFT Info exist                 
,[Asking Rent $/SF] = (CASE 
								   WHEN ( u.dsqft = 0 OR u.srent = 0 ) 
											THEN NULL 
								   ELSE u.srent / u.dsqft 
							END)
	 

-- Calculates the Difference Between Asking Rent and Proforma Rent   
,[Delta Ask/Proforma] = u.srent - Cast(cp.proformarent AS FLOAT) 

-- Calculates the Difference Between Zillow Rent and Proforma Rent
,[Delta Zillow/Proforma] = (SELECT TOP 1 rentamount 
											FROM   zillow.dbo.zillowdata 
											WHERE  prop_id = p.scode 
										   ORDER  BY taxassessmentyear DESC) 
								- CAST( cp.proformarent AS FLOAT) 
 
-- Calculates the Difference Between Zillow Rent and Asking ent 
,[Delta Zillow/Proforma] = (SELECT TOP 1 rentamount 
											   FROM   zillow.dbo.zillowdata 
											   WHERE  prop_id = p.scode 
											   ORDER  BY taxassessmentyear DESC) 
								- u.srent 
   
   -- Rent Ready Date Pulled from Construction History Table Where Construction Status is 'Rent Ready'   
,[Rent  Ready] = (SELECT TOP 1 CONVERT(date, start) 
							   FROM   [crm].[dbo].[constructionhistory] 
							   WHERE  p.scode LIKE LEFT(NAME, 7) 
								AND constructionstatus = 'Rent Ready' 
							   ORDER  BY start DESC) 
                
-- Days on Market Calculated by Substracting Rent Ready Date From Current Date.               
,[DOM] = Datediff(day, 
						(SELECT TOP 1 CONVERT(date, start) 
								   FROM   [crm].[dbo].[constructionhistory] 
								   WHERE  p.scode LIKE LEFT(NAME, 7) 
									AND constructionstatus = 'Rent Ready' 
								   ORDER  BY start DESC), 
						Getdate()) 
 
 -- Counts CRM Leads by Unique Mobile Phone Numbers and if a Mobile Phone is Missing Counts Number of Unqie Last Names (for Leads Created After The Last Rent Ready Date) 
 ,[Leads] = (SELECT Count(DISTINCT mobilephone) 
					   FROM   [crm].[dbo].[leads] 
					   WHERE  primaryproperty = p.scode
						AND mobilephone IS NOT NULL 
						AND createdon >= 
												(SELECT TOP 1 CONVERT(date, start) 
															FROM   [crm].[dbo].[constructionhistory] 
															WHERE  p.scode LIKE LEFT(NAME, 7) 
															AND constructionstatus = 'Rent Ready' 
															ORDER  BY start DESC)
																								
				) 
					                                          				  
			 + 
				(SELECT Count(DISTINCT lastname) 
				   FROM   [crm].[dbo]. [leads] 
					WHERE  primaryproperty = p.scode 
					AND mobilephone IS NULL		
					AND createdon >= 
											(SELECT TOP 1 CONVERT(date, start) 
														FROM   [crm].[dbo].[constructionhistory] 
														WHERE  p.scode LIKE LEFT(NAME, 7) 
														AND constructionstatus = 'Rent Ready' 
														ORDER  BY start DESC)
					)
               
               
               
               
               
-- Counts Rently House Viewings That Happend After the Last Rent Ready Date	
,[Rently Check-Ins] = (SELECT Sum(CASE 
			               					WHEN access IN ( 'self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing' )
								    					THEN 1 
			               					ELSE 0 
			              				 END)  
									   FROM   [rently].[dbo].[lead_activities] rla 
									   WHERE  rla.tag = p.scode 
										AND rla.activity_created_at >= 
			                            								(SELECT TOP 1 CONVERT(date, start) 
																							FROM   [crm].[dbo].[constructionhistory] 
																							WHERE  p.scode LIKE LEFT(NAME, 7) 
																							AND constructionstatus = 'Rent Ready' 
																							ORDER  BY start DESC)
								) 

                
-- Finds the Day of the Last Rently Check-In					 
,[Last Rently Check-In] = (SELECT TOP 1 activity_created_at 
										   FROM   [rently].[dbo].[lead_activities] rla 
										   WHERE  rla.tag = p.scode 
											AND access IN ( 'self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing' )
											AND rla.activity_created_at >= 
		                              										(SELECT TOP 1 CONVERT(date, start) 
																							   FROM   [crm].[dbo].[constructionhistory] 
																							   WHERE  p.scode LIKE LEFT(NAME, 7) 
																								AND constructionstatus = 'Rent Ready' 
																							   ORDER  BY start DESC) 
									ORDER  BY activity_created_at DESC) 
                
                
                
-- Calculates the Number of Days Since the Last Rently Check-In				 
,[Days From the Last Rently Check-In] = Datediff(day, 
																	(SELECT TOP 1 activity_created_at 
																			   FROM   [rently].[dbo].[lead_activities] rla 
																			   WHERE  rla.tag = p.scode 
																				AND access IN ( 'self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing' )
																				AND rla.activity_created_at >= 
																			                              	(SELECT TOP 1 CONVERT(date, start) 
																																	FROM   [crm].[dbo].[constructionhistory] 
																																	WHERE  p.scode LIKE LEFT(NAME, 7) 
																																	AND constructionstatus = 'Rent Ready' 
																																	ORDER  BY start DESC) 
																			ORDER  BY activity_created_at DESC), 
													Getdate()) 
			
-- Counts all Yardi Applications Since the Last Rent Ready Date			
,[All Yardi Apps] = (SELECT Count(DISTINCT hmy) 
   FROM   yardi_stage.dbo.prospect 
   WHERE  hproperty = p.hmy AND dtapply >= 
														(SELECT TOP 1 CONVERT(date, start) 
															   FROM   [crm].[dbo].[constructionhistory] 
															   WHERE  p.scode LIKE LEFT(NAME, 7) AND constructionstatus = 'Rent Ready' 
															   ORDER  BY start DESC)) 
                                        		
 -- Counts All Screened Applications Since After the Last Rent Ready Date               
,[Screened Apps] = (SELECT Count(DISTINCT appid) 
								   FROM   [applications].[dbo].[apps] 
								   WHERE  property = p.scode 
									AND date >=
 													(SELECT TOP 1 CONVERT(date, start) 
													   FROM   [crm].[dbo].[constructionhistory] 
													   WHERE  p.scode LIKE LEFT(NAME, 7) 
														AND constructionstatus = 'Rent Ready' 
													   ORDER  BY start DESC))
														 
 -- Counts All Approved Applications Since After the Last Rent Ready Date                                              	
,[Approved Apps] = (SELECT Count(DISTINCT appid) 
									   FROM   [applications].[dbo].[apps] 
									   WHERE  property = p.scode 
										AND final_approved = 1 AND date >= 
																					(SELECT TOP 1 CONVERT(date, start) 
																						   FROM   [crm].[dbo].[constructionhistory] 
																						   WHERE  p.scode LIKE LEFT(NAME, 7) 
																							AND constructionstatus = 'Rent Ready' 
																						   ORDER  BY start DESC)) 
-- Selects Income of an Approved Applicant																						
,[Approved App-Income] = (SELECT TOP 1 income 
										   FROM   [applications].[dbo].[apps] 
										   WHERE  property = p.scode 
											AND final_approved = 1 
											AND date >= 
																(SELECT TOP 1 CONVERT(date, start) 
																			FROM   [crm].[dbo].[constructionhistory] 
																			WHERE  p.scode LIKE LEFT(NAME, 7) 
																			AND constructionstatus = 'Rent Ready' 
																			ORDER  BY start DESC)) 
-- Selects Credit Score of an Approved Applicant																					 
,[Approved App-Score] = (SELECT TOP 1 score 
										   FROM   [applications].[dbo].[apps] 
										   WHERE  property = p.scode 
											AND final_approved = 1 
											AND date >= 
															(SELECT TOP 1 CONVERT(date, start) 
																		FROM   [crm].[dbo].[constructionhistory] 
																		WHERE  p.scode LIKE LEFT(NAME, 7) 
																		AND constructionstatus = 'Rent Ready' 
																		ORDER  BY start DESC))

-- Calculates Average Income of Denied Apps                
,[Denied Apps-Avg Income] = (SELECT Avg(income) 
										   FROM   [applications].[dbo].[apps] 
										   WHERE  property = p.scode 
											AND final_approved = 0 
											AND comments NOT LIKE '%approved%' 
      									AND date >= 
															(SELECT TOP 1 CONVERT(date, start) 
																	FROM   [crm].[dbo].[constructionhistory] 
																	WHERE  p.scode LIKE LEFT(NAME, 7) 
																	AND constructionstatus = 'Rent Ready' 
																	ORDER  BY start DESC)) 
																						   
-- Calculates Average Credit Score of Denied Apps                                    										
,[Denied Apps-Avg Score] = (SELECT Avg(score) 
										   FROM   [applications].[dbo].[apps] 
										   WHERE  property = p.scode 
											AND final_approved = 0 
											AND comments NOT LIKE '%approved%' 
                                 AND date >= 
														  (SELECT TOP 1 CONVERT(date, start) 
																		FROM   [crm].[dbo].[constructionhistory] 
																		WHERE  p.scode LIKE LEFT(NAME, 7) 
																		AND constructionstatus = 'Rent Ready' 
																		ORDER  BY start DESC)) 
FROM   yardi_stage.dbo.property p 
LEFT JOIN yardi_stage.dbo.unit u ON p.hmy = u.hproperty 
LEFT JOIN [crm].[dbo].[properties] cp ON cp.propid = p.scode 
LEFT JOIN yardi_stage.dbo.tenant t ON t.hproperty = u.hproperty AND t.istatus NOT IN ( 5, 6, 7, 8, 9 ) 
LEFT JOIN yardi_stage.dbo.attributes at ON at.hprop = p.hmy 
 
--  Filters Query to Return Data Only for Vacant Properties (Unrented or Rented witout a 'Future" Status Tenant)

WHERE  u.sstatus IN ( 'Vacant rented Ready', 'Vacant Unrented Ready' ) 
AND NOT EXISTS (SELECT istatus 
                  FROM   yardi_stage.dbo.tenant 
                  WHERE  sunitcode = u.scode AND istatus = 2) 
                  
 -- Use this WHERE clause for recently leased market report  and change getdate() to lease sign date everywhere              
 /* WHERE p.scode IN (SELECT DISTINCT t.sunitcode 
 									FROM yardi_stage.dbo.tenant t 
									 WHERE DATEDIFF(DAY,t.dtsigndate, t.dtmovein)<30 
									 AND t.dtsigndate>='2015-01-01')                     
 */
  
-- Uncomment for Rent Ready Aging
/*
AND DATEDIFF(DAY, 
				(SELECT TOP 1 dtmoveout 
								FROM yardi_stage.dbo.tenant 
								WHERE sunitcode=u.scode 
								ORDER BY dtsigndate DESC), 
				GETDATE()) > 60

*/  
 
                  
ORDER  BY p.scode 