USE [PM]
GO

/****** Object:  View [dbo].[uvwRentReady]    Script Date: 6/15/2015 5:05:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER VIEW [dbo].[uvwRentReady]
AS

-- Basic columns pulled from tables - source data in tables. No formulas or manipulation
SELECT DISTINCT 
p.scode AS 'Prop No.', 
u.sstatus AS 'Status', 
[Division] = rtrim(at.subgroup10),
[Region] = rtrim(at.subgroup18),
[District] = rtrim(at.subgroup9),
[Market] = rtrim(at.subgroup12),
[Market Area] = rtrim(at.subgroup13),
[Entity] = rtrim((SELECT at2.spropname FROM yardi_stage.dbo.attributes at2 WHERE at.subgroup14 = at2.scode)),


p.saddr1 AS 'Address',
p.scity AS 'City',
p.sstate AS 'State',
p.szipcode AS 'ZIP',
cp.latitude AS 'Latitude',
cp.longitude AS 'Longitude', 
cp.constructionlifecycle AS 'Lifecycle', 
u.dsqft AS 'SQFT', 
cp.bedrooms AS 'Bedrooms', 
round(cast(cp.baths as float),1) AS 'Baths', 
   
u.srent AS 'Asking Rent', 
cp.askingRentModified 'Asking Rent Modified Date',
cp.proformarent AS 'Proforma Rent', 
 
 -- 3rd party rent value pulled from source table               
(SELECT TOP 1 rentamount 
   FROM   zillow.dbo.zillowdata 
   WHERE  prop_id = p.scode 
   ORDER  BY taxassessmentyear DESC) AS 'Zillow Rent', 

-- Calculates asking rent over square feet where asking rent or sqft info exist                 
(CASE 
   WHEN ( u.dsqft = 0 OR u.srent = 0 ) 
			THEN NULL 
   ELSE u.srent / u.dsqft 
   END) AS 'Asking Rent $/SF', 

-- Days on Market calculated by substracting rent ready date from current date.               
Datediff(day, 
			(SELECT TOP 1 CONVERT(date, start) 
			   FROM   [crm].[dbo].[constructionhistory] 
			   WHERE  name = concat(p.scode,'- Rent Ready') 
			   ORDER  BY start DESC), 
			Getdate()) AS 'DOM', 
 
( case  when Datediff(day, 
			(SELECT TOP 1 CONVERT(date, start) 
			   FROM   [crm].[dbo].[constructionhistory] 
			   WHERE  name = concat(p.scode,'- Rent Ready') 
			   ORDER  BY start DESC), Getdate())	between 0 and 30 then '0-30'
when Datediff(day, 
			(SELECT TOP 1 CONVERT(date, start) 
			   FROM   [crm].[dbo].[constructionhistory] 
			   WHERE  name = concat(p.scode,'- Rent Ready') 
			   ORDER  BY start DESC), Getdate())	between 31 and 60 then '31-60'

when Datediff(day, 
			(SELECT TOP 1 CONVERT(date, start) 
			   FROM   [crm].[dbo].[constructionhistory] 
			   WHERE  name = concat(p.scode,'- Rent Ready') 
			   ORDER  BY start DESC), 	Getdate())	between 61 and 90 then '61-90'
			
	when Datediff(day, 
			(SELECT TOP 1 CONVERT(date, start) 
			   FROM   [crm].[dbo].[constructionhistory] 
			   WHERE  name = concat(p.scode,'- Rent Ready') 
			   ORDER  BY start DESC), Getdate())	> 90 then '90+'		
		
end)   [DOM Category] ,


  case when 
  Datediff(day, 
			(SELECT TOP 1 CONVERT(date, start) 
			   FROM   [crm].[dbo].[constructionhistory] 
			   WHERE  name = concat(p.scode,'- Rent Ready') 
			   ORDER  BY start DESC), 
			Getdate()) >30 then 1
			else 0
			end as '30+',
  
 case when 
  Datediff(day, 
			(SELECT TOP 1 CONVERT(date, start) 
			   FROM   [crm].[dbo].[constructionhistory] 
			   WHERE  name = concat(p.scode,'- Rent Ready') 
			   ORDER  BY start DESC), 
			Getdate()) >60 then 1
			else 0
			end as '60+',
  
 case when 
  Datediff(day, 
			(SELECT TOP 1 CONVERT(date, start) 
			   FROM   [crm].[dbo].[constructionhistory] 
			   WHERE  name = concat(p.scode,'- Rent Ready') 
			   ORDER  BY start DESC), 
			Getdate()) >90 then 1
			else 0
			end as '90+',
  
 -- Counts CRM leads by unique mobile phone numbers and if a mobile phone is missing counts number of unqie last names (for leads created after the last rent ready date).          
(SELECT Count(DISTINCT mobilephone) 
   FROM   [crm].[dbo].[leads] 
   WHERE  primaryproperty = p.scode  AND createdon >= 
																	(SELECT TOP 1 CONVERT(date, start) 
																		   FROM   [crm].[dbo].[constructionhistory] 
																		   WHERE  name = concat(p.scode,'- Rent Ready') 
																		   ORDER  BY start DESC)
																AND mobilephone IS NOT NULL) 
                                          				  
+ 
(SELECT Count(DISTINCT lastname) 
   FROM   [crm].[dbo]. [leads] 
	WHERE  primaryproperty = p.scode AND createdon >= 
																	(SELECT TOP 1 CONVERT(date, start) 
																		   FROM   [crm].[dbo].[constructionhistory] 
																		   WHERE  name = concat(p.scode,'- Rent Ready')
																		   ORDER  BY start DESC)
													 AND mobilephone IS NULL) as 'Leads', 
               
               
                 
               
-- Counts Rently house viewings that happend after the last rent ready date	

				
CASE 
	WHEN
			(SELECT Sum(( CASE 
			               WHEN access IN ( 'self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing' )
								    THEN 1 
			               ELSE 0 
			               END ))  
			  FROM   [rently].[dbo].[lead_activities] rla 
			   WHERE  rla.tag = p.scode AND rla.activity_created_at >= 
			                            												(SELECT TOP 1 CONVERT(date, start) 
																									   FROM   [crm].[dbo].[constructionhistory] 
																									   WHERE  name = concat(p.scode,'- Rent Ready') 
																									   ORDER  BY start DESC)
			) is null 
	THEN  
			(SELECT Sum(( CASE 
			               WHEN access IN ( 'self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing' )
								    THEN 1 
			               ELSE 0 
			               END ))  
			  FROM   [rently].[dbo].[lead_activities] rla 
			  where rla.tag = p.scode AND rla.activity_created_at >= 
			                            												(SELECT TOP 1 CONVERT(date, start) 
																									   FROM   [crm].[dbo].[constructionhistory] 
																									   WHERE  name = concat(p.scode,'- Rent Ready') 
																									   ORDER  BY start DESC)
			)

	ELSE

			(SELECT Sum(( CASE 
			               WHEN access IN ( 'self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing' )
								    THEN 1 
			               ELSE 0 
			               END ))  
			  FROM   [rently].[dbo].[lead_activities] rla 
			   WHERE  rla.tag = p.scode AND rla.activity_created_at >= 
			                            												(SELECT TOP 1 CONVERT(date, start) 
																									   FROM   [crm].[dbo].[constructionhistory] 
																									   WHERE  name = concat(p.scode,'- Rent Ready') 
																									   ORDER  BY start DESC)
			)
END  'Rently_Check-ins', 

                
-- Finds the day of the last rently check in					 

CASE 
	WHEN
		(SELECT TOP 1 activity_created_at 
		   FROM   [rently].[dbo].[lead_activities] rla 
		   WHERE  rla.tag = p.scode AND access IN ( 'self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing' )
													  AND rla.activity_created_at >= 
		                              										(SELECT TOP 1 CONVERT(date, start) 
																							   FROM   [crm].[dbo].[constructionhistory] 
																							   WHERE  name = concat(p.scode,'- Rent Ready') 
																							   ORDER  BY start DESC) 
		ORDER  BY activity_created_at DESC) is null 

	THEN
		(SELECT TOP 1 activity_created_at 
		   FROM   [rently].[dbo].[lead_activities] rla 
		where rla.tag = p.scode  AND access IN ( 'self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing' )
													  AND rla.activity_created_at >= 
		                              										(SELECT TOP 1 CONVERT(date, start) 
																							   FROM   [crm].[dbo].[constructionhistory] 
																							   WHERE  name = concat(p.scode,'- Rent Ready') 
																							   ORDER  BY start DESC) 
		ORDER  BY activity_created_at DESC) 
		
	ELSE
	(SELECT TOP 1 activity_created_at 
		   FROM   [rently].[dbo].[lead_activities] rla 
		   WHERE  rla.tag = p.scode AND access IN ( 'self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing' )
													  AND rla.activity_created_at >= 
		                              										(SELECT TOP 1 CONVERT(date, start) 
																							   FROM   [crm].[dbo].[constructionhistory] 
																							   WHERE  name = concat(p.scode,'- Rent Ready') 
																							   ORDER  BY start DESC) 
		ORDER  BY activity_created_at DESC)
END AS 'Last Rently Check-In', 
                
                
                
-- Calculates the number of days since the last Rently check in				 
Datediff(day, 
			(CASE 
					WHEN
						(SELECT TOP 1 activity_created_at 
						   FROM   [rently].[dbo].[lead_activities] rla 
						   WHERE  rla.tag = p.scode AND access IN ( 'self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing' )
																	  AND rla.activity_created_at >= 
						                              										(SELECT TOP 1 CONVERT(date, start) 
																											   FROM   [crm].[dbo].[constructionhistory] 
																											   WHERE  name = concat(p.scode,'- Rent Ready') 
																											   ORDER  BY start DESC) 
						ORDER  BY activity_created_at DESC) is null 
				
					THEN
						(SELECT TOP 1 activity_created_at 
						   FROM   [rently].[dbo].[lead_activities] rla 
						   WHERE rla.tag = p.scode  AND access IN ( 'self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing' )
																	  AND rla.activity_created_at >= 
						                              										(SELECT TOP 1 CONVERT(date, start) 
																											   FROM   [crm].[dbo].[constructionhistory] 
																											   WHERE  name = concat(p.scode,'- Rent Ready') 
																											   ORDER  BY start DESC) 
						ORDER  BY activity_created_at DESC) 
						
					ELSE
					(SELECT TOP 1 activity_created_at 
						   FROM   [rently].[dbo].[lead_activities] rla 
						   WHERE  rla.tag = p.scode AND access IN ( 'self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing' )
																	  AND rla.activity_created_at >= 
						                              										(SELECT TOP 1 CONVERT(date, start) 
																											   FROM   [crm].[dbo].[constructionhistory] 
																											   WHERE  name = concat(p.scode,'- Rent Ready') 
																											   ORDER  BY start DESC) 
						ORDER  BY activity_created_at DESC)
		END), 
			Getdate()) AS 'Days from the Last Rently Check-in', 
			
-- Counts all yardi applications since the last rent ready date			
(SELECT Count(DISTINCT hmy) 
   FROM   yardi_stage.dbo.prospect 
   WHERE  hproperty = p.hmy AND dtapply >= 
														(SELECT TOP 1 CONVERT(date, start) 
															   FROM   [crm].[dbo].[constructionhistory] 
															   WHERE  name = concat(p.scode,'- Rent Ready') 
															   ORDER  BY start DESC)) AS 'All Yardi Apps', 
                                        		
 -- Counts all screened applications since after the last rent ready date               
(SELECT Count(DISTINCT appid) 
   FROM   [applications].[dbo].[apps] 
   WHERE  property = p.scode AND date >=
 													(SELECT TOP 1 CONVERT(date, start) 
													   FROM   [crm].[dbo].[constructionhistory] 
													   WHERE  name = concat(p.scode,'- Rent Ready') 
													   ORDER  BY start DESC)) AS 'Screened Apps',
														 
 -- Counts all approved applications since after the last rent ready date                                              	
(SELECT Count(DISTINCT appid) 
   FROM   [applications].[dbo].[apps] 
   WHERE  property = p.scode AND final_approved = 1 AND date >= 
																					(SELECT TOP 1 CONVERT(date, start) 
																						   FROM   [crm].[dbo].[constructionhistory] 
																						   WHERE  name = concat(p.scode,'- Rent Ready') 
																						   ORDER  BY start DESC)) AS 'Approved Apps' ,
																						   
																						   
																						   
	(SELECT round(avg(cast(testrating_text as float)),1) as 'rating' from [education.com].[dbo].[schoolsearch] where prop_id=u.scode) 'Avg School Rating'

from yardi_stage.dbo.property p 
INNER JOIN yardi_stage.dbo.unit u ON p.hmy = u.hproperty 
INNER JOIN [crm].[dbo].[properties] cp ON cp.propid = p.scode 
LEFT JOIN yardi_stage.dbo.tenant t ON t.hproperty = u.hproperty AND t.istatus NOT IN ( 5, 6, 7, 8, 9 ) 
INNER JOIN yardi_stage.dbo.attributes at ON at.hprop = p.hmy 
 
--  Filters query to return data only for vacant properties (unrented or rented but a tenant with 'Future' status does not exist)
WHERE  u.sstatus IN ( 'Vacant rented Ready', 'Vacant Unrented Ready' ) 
AND NOT EXISTS (SELECT istatus 
                  FROM   yardi_stage.dbo.tenant 
                  WHERE  sunitcode = u.scode AND istatus = 2) 



GO


