USE Yardi_Stage;

SELECT  top 100 t.sunitcode,
	a.SUBGROUP10 as 'Division'
	,a.SUBGROUP9 as 'District'
	,a.SUBGROUP18 as 'Region'
	,a.SUBGROUP12 as 'Market',
	t.sCode, 
	t.sRent, 
	t.sFirstName, 
	t.sLastName,
	t.dtMoveIn,
	(SELECT TOP 1 Tenant_Code FROM Datawarehouse.dbo.tenantdirectory WHERE Property_Code = t.sunitcode AND dtStart < t.dtMoveIn ORDER BY dtStart DESC) PreviousTenant,
	(SELECT TOP 1 Vacated FROM Datawarehouse.dbo.tenantdirectory WHERE Property_Code = t.sunitcode AND dtStart < t.dtMoveIn ORDER BY dtStart DESC) PreviousMoveOut,
	(SELECT TOP 1 RentAmount FROM Datawarehouse.dbo.tenantdirectory WHERE Property_Code = t.sunitcode AND dtStart < t.dtMoveIn ORDER BY dtStart DESC) PreviousRent,
	

(case 
	when 	(select top 1 srent from tenant where scode=(SELECT TOP 1 Tenant_Code FROM Datawarehouse.dbo.tenantdirectory WHERE Property_Code = t.sunitcode AND dtStart < t.dtMoveIn ORDER BY dtStart DESC)  order by dtsigndate desc ) is null 
then 
(SELECT TOP 1 RentAmount FROM Datawarehouse.dbo.tenantdirectory WHERE Property_Code = t.sunitcode AND dtStart < t.dtMoveIn ORDER BY dtStart DESC)
else
	(select top 1 srent from tenant where scode=(SELECT TOP 1 Tenant_Code FROM Datawarehouse.dbo.tenantdirectory WHERE Property_Code = t.sunitcode AND dtStart < t.dtMoveIn ORDER BY dtStart DESC)  order by dtsigndate desc )

end) ,
	
	u.dtReady,
	u.dsqft,
	
	--SECURITY DEPOSIT DRIVEN FROM TRANS
	(SELECT SUM(sTotalAmount) FROM TRANS WHERE HPERSON = t.HMYPERSON AND HOFFSETACCT IN (1465,1466,1462,1460) AND ITYPE = 7) as 'Security Deposit',
	
	-- (SELECT TOP 1 cDeposit0 FROM tenant_history WHERE hTent = t.HMYPERSON AND sEvent = 'Deposit Change' AND cDeposit0 IS NOT NULL AND cDeposit0 > 1 ORDER BY hMy DESC) as 'Security Deposit',
	
	(SELECT SUM(SAMOUNTPAID) FROM TRANS WHERE HOFFSETACCT = 1444 AND SUSERDEFINED2 = ':Refund' AND HPERSON = (SELECT TOP 1 Tenant_ID FROM Datawarehouse.dbo.tenantdirectory WHERE Property_Code = t.sunitcode AND dtStart < t.dtMoveIn ORDER BY dtStart DESC)) as 'Refund Paid', 

	--HOLDING COSTS 
	(SELECT SUM(SMTD) FROM TOTAL WHERE 
	HPPTY = u.HPROPERTY 
	AND HACCT IN (1230, 1232, 1238, 1239, 1244, 1245, 1246, 1247, 1248, 1249, 1250, 1251, 1252, 1253, 1254, 1255, 1256, 1257, 1258) 
	AND DATEPART(mm,UMONTH) BETWEEN DATEPART(mm,(SELECT TOP 1 Vacated FROM Datawarehouse.dbo.tenantdirectory WHERE Property_Code = t.sunitcode AND dtStart < t.dtMoveIn ORDER BY dtStart DESC)) AND DATEPART(mm,t.dtMoveIn) 
	AND DATEPART(yy,UMONTH) BETWEEN DATEPART(yy,(SELECT TOP 1 Vacated FROM Datawarehouse.dbo.tenantdirectory WHERE Property_Code = t.sunitcode AND dtStart < t.dtMoveIn ORDER BY dtStart DESC)) AND DATEPART(yy,t.dtMoveIn)) as 'Holding Costs',

	--INSIDE & OUTSIDE COMMISSIONS
	(SELECT SUM(SMTD) FROM TOTAL WHERE HACCT IN (1041, 1058, 1939, 1940,1168,1169) 
	AND HPPTY = u.HPROPERTY
	AND DATEPART(mm,UMONTH) BETWEEN DATEPART(mm,(SELECT TOP 1 Vacated FROM Datawarehouse.dbo.tenantdirectory WHERE Property_Code = t.sunitcode AND dtStart < t.dtMoveIn ORDER BY dtStart DESC)) AND DATEPART(mm,t.dtMoveIn)
	AND DATEPART(yy,UMONTH) BETWEEN DATEPART(yy,(SELECT TOP 1 Vacated FROM Datawarehouse.dbo.tenantdirectory WHERE Property_Code = t.sunitcode AND dtStart < t.dtMoveIn ORDER BY dtStart DESC)) AND DATEPART(yy,t.dtMoveIn)) as 'Commissions',

	--CONCESSIONS
	(SELECT ABS(SUM(STOTALAMOUNT)) FROM TRANS WHERE HOFFSETACCT = 1319 AND HPROP = u.HPROPERTY AND sDateOccurred > t.dtMoveIn -30) as 'Concessions',
	
	--SUM OF MAINTENANCE COSTS WITHIN 1st 60 days
	(SELECT SUM(dPayTranTotal) FROM mm2wo WHERE hPROPERTY = t.hPROPERTY AND DTINPROG BETWEEN t.dtMoveIn - 1 AND t.dtMoveIn + 60) as '60 Days Maintenance'
	
	/*,
	--SUM OF TURN COSTS
	(SELECT SUM(dTotal) FROM mm2po po
		LEFT JOIN mm2podet pod ON po.HPO = po.HMY 
		WHERE hProp = t.hPROPERTY AND DTORDEREDDATE BETWEEN (SELECT TOP 1 Vacated FROM Datawarehouse.dbo.tenantdirectory WHERE Property_Code = t.sunitcode AND dtStart < t.dtMoveIn ORDER BY dtStart DESC) - 1 AND t.dtMoveIn + 60) as 'Turn Costs'
	*/
	
	FROM tenant t 
	LEFT JOIN UNIT u ON u.HPROPERTY = t.HPROPERTY
	LEFT JOIN ATTRIBUTES a ON a.HPROP = u.HPROPERTY
	
	--Filter for current, past, eviction, and notice status tenants
		WHERE t.istatus IN (0,1,3,4) 
		AND t.dtMoveIn BETWEEN '2014-10-01' AND '2014-12-31'
	   AND (SELECT count(scode) FROM tenant WHERE sunitcode = t.sunitcode) > 1
		AND t.dtMoveOut IS NULL
		AND t.sunitcode IN 
	
	-- Begin Temporary Table for Unique Tenants post-Certification Date
				(SELECT Property_Code FROM DataWarehouse.dbo.TenantDirectory td
				INNER JOIN CRM.dbo.properties pr ON pr.PropId = td.Property_Code
				WHERE pr.CertificationDate -30 < td.dtStart AND TenantStatus in ('Current','Past','Future','Notice','Eviction','Terminated Early')
				GROUP BY Property_code
				HAVING count(distinct td.Tenant_code) > 1)
	
	
	