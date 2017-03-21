USE Yardi_Stage;

SELECT

[Prop ID] = u.scode,
[Prop Status] = u.sstatus,
[Division] = rtrim(at.subgroup10),
[Region] = rtrim(at.subgroup18),
[District] = rtrim(at.subgroup9),
[Market] = rtrim(at.subgroup12),
[Market Area] = rtrim(at.subgroup13),
[Entity] = rtrim((SELECT at2.spropname FROM attributes at2 WHERE at.subgroup14 = at2.scode)),
[Occupied] = (CASE
					WHEN u.sstatus IN ('Occupied No Notice', 'Notice Unrented', 'Notice Rented')
						THEN 'Yes'
					ELSE 'No'
				  END),
-- [Certification Date] = (SELECT certificationdate FROM crm.dbo.properties WHERE propid = u.scode),

-- [Move In Date] = (SELECT TOP 1 dtmovein FROM tenant WHERE hproperty = u.hproperty ORDER BY dtmovein DESC)

[Stabilized Population] = (CASE
						WHEN getdate()-60 >= (SELECT certificationdate FROM crm.dbo.properties WHERE propid = u.scode)
							THEN 'Yes'
						WHEN (SELECT TOP 1 dtmovein FROM tenant WHERE hproperty = u.hproperty ORDER BY dtmovein DESC) >= (SELECT certificationdate FROM crm.dbo.properties WHERE propid = u.scode)
							THEN 'Yes'
						ELSE 'No'
					END),	
-- [Most Recent FUTURE tenant Code] = (SELECT TOP 1 scode FROM tenant WHERE hproperty = u.hproperty AND istatus = 2 ORDER BY dtsigndate DESC)

[Inventory Occupancy Population] = (CASE
									WHEN u.sstatus IN ('Occupied No Notice', 'Notice Unrented', 'Notice Rented', 'Vacant Unrented Ready', 'Vacant Rented Ready')
										THEN 'Yes'
									WHEN (u.sstatus = 'Vacant Rented Not Ready' AND (SELECT TOP 1 istatus FROM tenant where hproperty = u.hproperty ORDER BY dtsigndate DESC) = 2)
										THEN 'Yes'
									Else 'No'
								END)							
									
FROM unit u

LEFT JOIN attributes at ON at.hprop = u.hproperty

WHERE at.subgroup17 IN ('Property Management', 'Conversions')