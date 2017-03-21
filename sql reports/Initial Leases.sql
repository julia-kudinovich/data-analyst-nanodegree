use Yardi_Stage;
SELECT 
  [Tenant ID] = t.scode
, [Tenant Status] = (SELECT status FROM tenstatus where istatus=t.istatus)
, [Property] = t.sunitcode
, [Division] = RTRIM(atr.SUBGROUP10)
, [Region] = RTRIM(atr.SUBGROUP18)
, [District] = RTRIM(atr.SUBGROUP9)
, [Market] = RTRIM(atr.SUBGROUP12)
, [Market Area] = RTRIM(atr.SUBGROUP13)
, [Proforma Rent] = cp.proformaRent
, [Lease Sign Date] = t.dtsigndate
, [Month of Lease Sign Date] = MONTH(t.dtsigndate)
, [Lease From] = t.dtleasefrom
, [Lease To] = t.dtleaseto
, [Lenght of Lease] = DATEDIFF(DAY, t.dtleasefrom, t.dtleaseto)
, [Move In]  = t.dtmovein
, [Move Out] = t.dtmoveout
, [Rent] = t.srent
, [Achieved Rent - Proforma Rent] = t.srent-cp.proformarent
, [Percentage Change] = ROUND((t.srent-cp.proformarent)/cp.proformarent,3)

FROM tenant t
	INNER JOIN attributes atr ON atr.scode=t.sunitcode
	INNER JOIN crm.dbo.properties cp on cp.PropID=t.sunitcode

WHERE DATEDIFF(DAY, t.dtsigndate, t.dtmovein) >= -31
AND t.istatus IN (0,1,2,3,4)
AND t.dtmovein>= cp.CertificationDate
AND (t.dtmovein <= (SELECT TOP 1 start 
										FROM crm.dbo.construction 
										WHERE propid = t.sunitcode 
										AND type = 'Tenant Turn B' 
							ORDER BY start ASC) 
		OR 
			(SELECT TOP 1 start 
						FROM crm.dbo.construction 
						WHERE propid = t.sunitcode 
						AND type = 'Tenant Turn B' 
					ORDER BY start ASC) IS NULL) 
					
AND cp.certificationdate >= '2014-10-01'