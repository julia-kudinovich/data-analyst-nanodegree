-- Selects Property ID, Status the Property Was In, Start and End Days of the Status
SELECT 
[Property ID] = u.scode
,[Unit Status] =  us.sstatus
,[Start] = us.dtstart
,[End] =  us.dtend

FROM unit_status us
LEFT JOIN unit u ON us.hUnit=u.hmy

WHERE us.sstatus NOT IN ('Down','Excluded')

ORDER BY u.scode