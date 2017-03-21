USE Yardi_Stage;

SELECT

t.sunitcode, as 'Property'
a.SUBGROUP18 as 'Region',
a.SUBGROUP12 as 'Market',
a.SUBGROUP10 as 'Division',
t.scode as 'Tenant ID',
t.saddr1 as 'Address',
t.scity as 'City',
t.sstate as 'State',
t.szipcode as 'Zip Code',
t.sfirstname as 'First Name',
t.slastname as 'Last Name', 
t.srent as 'Current Rent',
t.dtmovein as 'Move In',
t.dtleasefrom as 'Lease From',
t.dtleaseto as 'Lease To',
t.dtmoveout as 'Move Out',

(SELECT TOP 1 dtOccurred FROM tenant_history th 
	WHERE hUnit = u.HMY  AND hTent = t.HMYPERSON AND sEvent = 'Lease Renewal' AND dtOccurred BETWEEN DATEADD(MONTH,-3,t.dtLeaseTo) AND DATEADD(MONTH,1,t.dtleaseto)) as 'Renewal Date',

(SELECT SUM(cam.destimated) FROM (SELECT DISTINCT hChargecode, dEstimated 
	FROM camrule cr WHERE DTFROM < t.dtLEASEFROM AND cr.hTenant = t.hMyperson AND hchargecode IN (10,20,11)) cam ) as 'Previous Lease Charges'

,(SELECT SUM(destimated) FROM camrule 
	/*Rent, Holdover & Month to Month Charges*/
	WHERE htenant = t.hmyperson AND hchargecode IN (10,20,11)
	AND (DTTO IS NULL OR DTTO > GETDATE()) AND DTFROM < GETDATE()) as 'Current Lease Charges'
	
,(SELECT SUM(cam.destimated) FROM (SELECT DISTINCT hChargecode, dEstimated 
	FROM camrule cr WHERE DTFROM > t.dtLEASETO AND cr.hTenant = t.hMyperson AND hchargecode IN (10,20,11)) cam ) as 'Future Lease Charges'

FROM TENANT t

	INNER JOIN PROPERTY p ON p.HMY = t.HPROPERTY
	LEFT JOIN ATTRIBUTES a ON a.HPROP = p.HMY
	LEFT JOIN UNIT u ON u.HPROPERTY = p.HMY
	WHERE t.istatus = 0;

