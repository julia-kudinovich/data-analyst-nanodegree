SELECT 
[Property ID] = u.scode
,u.sstatus
,[Market] =  RTRIM(a.subgroup12)
,[Property Status]  = RTRIM(a.subgroup17)
,[Purchase Date] = p.dateacquired
,[Conversion Date] = p.conversiondate

-- Counts for how many days the property is in conversion by susbtracting acquisition date from the current date.
,[Days Since Acquisition - Not Converted] = DATEDIFF(DAY,p.dateacquired,GETDATE())

FROM yardi_stage.dbo.unit u

LEFT JOIN yardi_stage.dbo.attributes a ON a.hprop = u.hproperty
LEFT JOIN crm.dbo.properties p ON p.propid = u.scode

-- Filters the query to return only the properties with conversion status.
WHERE 
a.subgroup17 LIKE '%Conversion%' 
AND
-- Filters to return data for properties that are in conversion for at least 60 days.
DATEDIFF(DAY,p.dateacquired,GETDATE()) >= 60

ORDER BY DATEDIFF(DAY,p.dateacquired,GETDATE()) DESC