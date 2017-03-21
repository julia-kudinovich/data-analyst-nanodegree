USE Yardi_Stage;

SELECT TOP 100

[Prop ID] = t.sunitcode,
[Prop Status] = u.sstatus,
[Tenant Code] = t.scode,
[Tenant Status] = (SELECT status FROM tenstatus WHERE istatus = t.istatus),
[Tenant Move Out Date] = t.dtmoveout,

[Construction Lifecycle] = (SELECT TOP 1 type FROM crm.dbo.construction WHERE start + 10 >= t.dtmoveout AND type IN ('Initial Rehab', 'Tenant Turn B') AND propid = u.scode ORDER BY start ASC),

[Construction Lifecycle Start] = (SELECT TOP 1 start FROM crm.dbo.construction WHERE start + 10 >= t.dtmoveout AND type IN ('Initial Rehab', 'Tenant Turn B') AND propid = u.scode ORDER BY start ASC),

[Construction Status] = (SELECT TOP 1 constructionstatus FROM crm.dbo.constructionhistory WHERE name LIKE u.scode+'%' AND start > t.dtmoveout AND constructionlifecycleid = (SELECT TOP 1 constructionid FROM crm.dbo.construction WHERE start + 10 >= t.dtmoveout AND type IN ('Initial Rehab', 'Tenant Turn B') AND propid = u.scode ORDER BY start ASC) ORDER BY start DESC),

[Construction Start] = (SELECT TOP 1 start FROM crm.dbo.constructionhistory WHERE name LIKE u.scode+'%' AND start > t.dtmoveout AND constructionlifecycleid = (SELECT TOP 1 constructionid FROM crm.dbo.construction WHERE start + 10 >= t.dtmoveout AND type IN ('Initial Rehab', 'Tenant Turn B') AND propid = u.scode ORDER BY start ASC) ORDER BY start DESC),

[Rent Ready Date] = (SELECT TOP 1 start FROM crm.dbo.constructionhistory WHERE name LIKE u.scode+'%' AND start > t.dtmoveout AND constructionstatus = 'Rent Ready' ORDER BY start ASC),

[Next Lease Sign Date] = (SELECT TOP 1 t2.dtsigndate FROM tenant t2 WHERE t2.dtsigndate > t.dtmoveout AND t2.istatus IN (0,2,3,4) AND u.hproperty = t2.hproperty ORDER BY t2.dtsigndate ASC),

[Next Lease Start Date] = (SELECT TOP 1 t2.dtmovein FROM tenant t2 WHERE t2.dtsigndate > t.dtmoveout AND t2.istatus IN (0,2,3,4) AND u.hproperty = t2.hproperty ORDER BY t2.dtsigndate ASC),

[Construction Cycle Time] = DATEDIFF(DAY, t.dtmoveout,(SELECT TOP 1 start FROM crm.dbo.constructionhistory WHERE name LIKE u.scode+'%' AND start > t.dtmoveout AND constructionstatus = 'Rent Ready' ORDER BY start ASC)),

[Marketing Cycle Time] = DATEDIFF(DAY, (SELECT TOP 1 start FROM crm.dbo.constructionhistory WHERE name LIKE u.scode+'%' AND start > t.dtmoveout AND constructionstatus = 'Rent Ready' ORDER BY start ASC),(SELECT TOP 1 t2.dtsigndate FROM tenant t2 WHERE t2.dtsigndate > t.dtmoveout AND t2.istatus IN (0,2,3,4) AND u.hproperty = t2.hproperty ORDER BY t2.dtsigndate ASC)),

[Sign to Start Time] = DATEDIFF(DAY,(SELECT TOP 1 t2.dtsigndate FROM tenant t2 WHERE t2.dtsigndate > t.dtmoveout AND t2.istatus IN (0,2,3,4) AND u.hproperty = t2.hproperty ORDER BY t2.dtsigndate ASC),(SELECT TOP 1 t2.dtmovein FROM tenant t2 WHERE t2.dtsigndate > t.dtmoveout AND t2.istatus IN (0,2,3,4) AND u.hproperty = t2.hproperty ORDER BY t2.dtsigndate ASC))

FROM tenant t

LEFT JOIN unit u ON u.hproperty = t.hproperty

WHERE t.dtmoveout IS NOT NULL 
AND t.istatus = 1
AND t.dtmoveout >= (SELECT certificationdate FROM crm.dbo.properties WHERE u.scode = propid)

ORDER BY t.dtmoveout DESC