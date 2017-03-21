SELECT

[Property] = t.sunitcode,
[Division] = rtrim(at.subgroup10),
[Region] = rtrim(at.subgroup18),
[District] = rtrim(at.subgroup9),
[Market] = rtrim(at.subgroup12),
[Market Area] = rtrim(at.subgroup13),
[Entity] = rtrim((SELECT at2.spropname FROM attributes at2 WHERE at.subgroup14 = at2.scode)), 
[Tenant Status] = (SELECT TOP 1 ts.status FROM tenant t 
	LEFT JOIN tenstatus ts ON ts.istatus = t.istatus
		WHERE t.hmyperson = tr.hperson AND t.istatus IN (0,1,2,3,4) 
			ORDER BY t.dtsigndate DESC), 
[Date Occurred] = tr.sdateoccurred, 
[GL Code] = (SELECT scode FROM acct WHERE tr.hoffsetacct = hmy), 
[Charge Description] = (select sdesc FROM acct WHERE tr.hoffsetacct = hmy), 

[Amount Charged] = tr.stotalamount, 
[Tenant Payment] = tr.samountpaid, 
[Charge Balance] = ROUND(CAST(tr.stotalamount - tr.samountpaid AS FLOAT),2),

[Age Category] = (CASE 
	WHEN DATEDIFF(DAY,tr.sdateoccurred,getdate()) <31
		THEN '0-30'
	WHEN DATEDIFF(DAY,tr.sdateoccurred,getdate()) <61
		THEN '31-60'
	WHEN DATEDIFF(DAY,tr.sdateoccurred,getdate()) <91
		THEN '61-90'
	ELSE '90+'
END)
	
FROM trans tr

LEFT JOIN tenant t ON t.hmyperson = tr.hperson
LEFT JOIN attributes at on at.hprop = t.hproperty

WHERE tr.itype = 7 AND
ROUND(CAST(tr.stotalamount - tr.samountpaid AS FLOAT),2) > 0

ORDER BY t.sunitcode ASC, tr.sdateoccurred asc, hoffsetacct asc
