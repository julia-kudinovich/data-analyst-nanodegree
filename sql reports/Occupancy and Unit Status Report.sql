USE Yardi_Stage;
SELECT 

[Market] = RTRIM(at.SUBGROUP12)

-- Calculates the number of properties in construction
,[In Construction]=SUM(CASE
									WHEN u.sstatus IN ('Vacant Unrented Not Ready','Vacant Rented Not Ready') THEN 1
									ELSE 0
								END)

-- Calculates the number of properties in conversion
,[In Conversion] = SUM(CASE
									WHEN at.SUBGROUP17 LIKE '%conversion%' THEN 1
									ELSE 0
								END)

-- Calculates the number of properties that are leased with no notice
,[Leased: Occupied No Notice] = SUM(CASE
													WHEN u.sstatus='Occupied No Notice' THEN 1
													ELSE 0
												END)

-- Calculates the number of properties that are leased with notice with no future lease on them
,[Leased: Notice Unrented] = SUM(CASE
												WHEN u.sstatus='Notice Unrented' THEN 1
												ELSE 0
											END)

-- Calculates the number of properties that are leased with notice with a future lease on them
,[Leased: Notice Rented] = SUM(CASE
											WHEN u.sstatus='Notice Rented' THEN 1
											ELSE 0
										END)

-- Calculates the number of properties that are leased having a future tenant
,[Leased: Future Tenant] = SUM(CASE
											WHEN (u.sstatus='Vacant Rented Not Ready' OR u.sstatus='Vacant Rented Ready') AND t.istatus = 2 THEN 1
											ELSE 0
										 END)

-- Sums all the leased properties
,[Total Leased] = SUM(CASE
								WHEN (u.sstatus='Occupied No Notice' OR u.sstatus='Notice Unrented' OR u.sstatus = 'Notice Rented' OR ((u.sstatus='Vacant Rented Not Ready' OR u.sstatus='Vacant Rented Ready') AND t.istatus = 2))
								THEN 1
								ELSE 0
							END)

-- Counts the total number of properties owned
,[Total Owned] =  (SELECT TOP 1  COUNT(DISTINCT unit.hproperty) 
									FROM unit 
									LEFT JOIN ATTRIBUTES ON attributes.HPROP = unit.hproperty 
									WHERE attributes.subgroup12=at.SUBGROUP12 
									AND attributes.subgroup17 IN ('Conversions', 'Property Management'))

-- Divides the number of leased properties by the total number of properties owned
,[% Occupied] = (CASE 
							WHEN (SELECT TOP 1 COUNT(DISTINCT unit.hproperty) 
												FROM unit 
												LEFT JOIN ATTRIBUTES ON attributes.HPROP = unit.hproperty 
												WHERE attributes.subgroup12=at.SUBGROUP12 
												AND attributes.subgroup17 IN ('Conversions', 'Property Management'))= 0			
								THEN NULL
							ELSE CONVERT(decimal(10,3), SUM(CASE 
																		WHEN (u.sstatus='Occupied No Notice' OR  u.sstatus='Notice Unrented' OR u.sstatus='Notice Rented' OR ((u.sstatus='Vacant Rented Not Ready' OR u.sstatus='Vacant Rented Ready') AND t.istatus = 2)) 
																		THEN 1 
																		ELSE 0 
																	END)
																	/ CAST((SELECT TOP 1 COUNT(DISTINCT unit.hproperty) 
																							FROM unit 
																							LEFT JOIN ATTRIBUTES ON attributes.HPROP = unit.hproperty 
																							WHERE attributes.subgroup12=at.SUBGROUP12 
																							AND attributes.subgroup17 IN ('Conversions', 'Property Management'))  as float)
											)
						END)


FROM unit u
INNER JOIN [crm].[dbo].[properties] cp ON cp.propid=u.scode
INNER JOIN ATTRIBUTES at ON at.HPROP = u.hproperty
LEFT JOIN tenant t ON (u.hproperty=t.hproperty AND  EXISTS (SELECT istatus 
																						FROM tenant 
																						WHERE  sunitcode = u.scode 
																						AND istatus = 2)
								)
                  

WHERE at.SUBGROUP12!='corp'
group by at.SUBGROUP12
order by at.SUBGROUP12
