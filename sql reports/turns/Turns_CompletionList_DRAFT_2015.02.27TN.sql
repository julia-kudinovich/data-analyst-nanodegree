USE Yardi_Stage;

SELECT t.sunitcode,
	a.SUBGROUP10 as 'Division'
	,a.SUBGROUP9 as 'District'
	,a.SUBGROUP18 as 'Region'
	,a.SUBGROUP12 as 'Market',
	t.sCode, 
	t.sRent, 
	t.sFirstName, 
	t.sLastName,
	t.dtMoveOut,
	(SELECT TOP 1 sCode FROM tenant WHERE sunitcode = t.sunitcode AND dtMoveIn > t.dtMoveIn AND dtMoveIn IS NOT NULL AND dtMoveIn BETWEEN '2014-10-01' AND '2014-12-31') NewTenant,
	(SELECT TOP 1 dtMoveIn FROM tenant WHERE sunitcode = t.sunitcode AND dtMoveIn > t.dtMoveIn AND dtMoveIn IS NOT NULL AND dtMoveIn BETWEEN '2014-10-01' AND '2014-12-31') NewMoveIn,
	(SELECT TOP 1 sRent FROM tenant WHERE sunitcode = t.sunitcode AND dtMoveIn > t.dtMoveIn AND dtMoveIn IS NOT NULL AND dtMoveIn BETWEEN '2014-10-01' AND '2014-12-31') NewRent,
	(SELECT TOP 1 dtSigndate FROM tenant WHERE sunitcode = t.sunitcode AND dtMoveIn > t.dtMoveIn AND dtMoveIn IS NOT NULL AND dtMoveIn BETWEEN '2014-10-01' AND '2014-12-31') NewSign,
	(SELECT TOP 1 Start FROM CRM.dbo.constructionhistory WHERE SUBSTRING(name,0, CHARINDEX('-',name)) = t.sUNITCODE AND ConstructionStatus IN ('Rent Ready','Complete') AND Start < '2014-12-31' AND Start > t.dtMoveOut) RentReady,
	u.dtReady,
	u.dsqft,
	(SELECT TOP 1 cDeposit0 FROM tenant_history WHERE hTent = t.HMYPERSON AND sEvent = 'Deposit Change' AND cDeposit0 IS NOT NULL AND cDeposit0 > 1 ORDER BY hMy DESC) as 'Security Deposit',
	(SELECT SUM(SAMOUNTPAID) FROM TRANS WHERE HOFFSETACCT = 1444 AND SUSERDEFINED2 = ':Refund' AND HPERSON = t.HMYPERSON) as 'Refund Paid',

	--HOLDING COSTS
	(SELECT SUM(SMTD) FROM TOTAL WHERE 
	HPPTY = u.HPROPERTY 
	AND HACCT IN (1230, 1232, 1238, 1239, 1244, 1245, 1246, 1247, 1248, 1249, 1250, 1251, 1252, 1253, 1254, 1255, 1256, 1257, 1258) 
	AND DATEPART(mm,UMONTH) >= DATEPART(mm,t.dtMoveOut) 
	AND DATEPART(yy,UMONTH) >= DATEPART(yy,t.dtMoveOut)) as 'Holding Costs',

	--INSIDE & OUTSIDE COMMISSIONS
	(SELECT SUM(SMTD) FROM TOTAL WHERE HACCT IN (1041, 1058, 1939, 1940,1168,1169) 
	AND HPPTY = u.HPROPERTY
	AND DATEPART(mm,UMONTH) >= DATEPART(mm,t.dtMoveOut) 
	AND DATEPART(yy,UMONTH) >= DATEPART(yy,t.dtMoveOut)) as 'Commissions',

	--CONCESSIONS
	(SELECT ABS(SUM(STOTALAMOUNT)) FROM TRANS WHERE HOFFSETACCT = 1319 AND HPROP = u.HPROPERTY AND sDateOccurred > t.dtMoveOut) as 'Concessions'
	
FROM tenant t 
LEFT JOIN UNIT u ON u.HPROPERTY = t.HPROPERTY
LEFT JOIN ATTRIBUTES a ON a.HPROP = u.HPROPERTY
	--WHERE dtMoveOut BETWEEN '2014-10-01' AND '2014-12-31'
		WHERE (SELECT TOP 1 EndDate FROM CRM.dbo.constructionhistory WHERE SUBSTRING(name,0, CHARINDEX('-',name)) = t.sUNITCODE AND ConstructionStatus IN ('Rent Ready','Complete') AND Start < '2014-12-31' AND Start > t.dtMoveOut) BETWEEN '2014-10-01' AND '2014-12-31'