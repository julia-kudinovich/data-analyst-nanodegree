USE yardi_stage;

SELECT DISTINCT

 [Prop ID] 			= t.sunitcode
,[Tenant Code]		= t.scode
,[Tenant Status] 	= ts.status
,[Tenant Balance] = bal.[Balance]
,[Tenant Rent] 	= t.srent
,[Yardi Decision] = h.sapplicationdecision
,[Tenant Movein] 	= t.dtmovein
,[Tenant Moveout] = t.dtmoveout
,[Lease From] 		= t.dtleasefrom
,[Lease To] 		= t.dtleaseto
,[Income] 			= a.income
,[Debt] 				= a.debt
,[Collections] 	= a.collections
,[Combined FICO] 	= a.score
,[Foreclosure] 	= a.foreclosure
,[Felony] 			= a.felony
,[UW Decision] 	= a.final_approved

FROM creditcheckmitsheader h

INNER JOIN creditcheckmitsmultireps reps ON h.hmy = reps.hmits
INNER JOIN creditcheckmitsdetail d ON d.hmits = reps.hmy
LEFT JOIN tenant t ON h.scode = t.scode
LEFT JOIN tenstatus ts ON ts.istatus = t.istatus
LEFT JOIN applications.dbo.apps a ON a.appid = t.scode
OUTER APPLY
	(SELECT sum(tr.stotalamount)-sum(tr.samountpaid) [Balance] 
	FROM trans tr 
	WHERE tr.hperson = t.hmyperson AND tr.itype = 7
	) bal
	
WHERE h.sapplicationdecision IN ('Denied','Conditional')
AND t.istatus IN (0,1,2,3,4)