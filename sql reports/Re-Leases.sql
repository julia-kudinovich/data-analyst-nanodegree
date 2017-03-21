SELECT 
  [Tenant ID] = t.scode
, [Tenant Status] = (SELECT status FROM yardi_stage.dbo.tenstatus where istatus=t.istatus)
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
, [Move In] = t.dtmovein
, [Move Out] = t.dtmoveout
, [Rent] = t.srent
, [Prev. LT Rent] = prev_ten.srent
, [New Rent - Last LT Rent] = t.srent-prev_ten.srent 
, [Percentage Change] = (CASE 
									WHEN prev_ten.srent= 0 OR prev_ten.srent IS NULL
										THEN null 
									ELSE round(t.srent-prev_ten.srent /prev_ten.srent,3) 
									END)

FROM yardi_stage.dbo.tenant t
	INNER JOIN yardi_stage.dbo.attributes atr ON atr.scode=t.sunitcode
	INNER JOIN crm.dbo.properties cp ON cp.PropID=t.sunitcode
	OUTER Apply (SELECT TOP 1 srent 
								FROM yardi_stage.dbo.tenant 
								WHERE sunitcode=t.sunitcode
								AND dtmovein<t.dtmovein 
								AND istatus=1
								ORDER BY dtmovein DESC) prev_ten

WHERE DATEDIFF(DAY, t.dtsigndate, t.dtmovein) >= -31
AND t.istatus in (0,1,2,3,4)
AND t.dtmovein >= (SELECT TOP 1 start 
									FROM crm.dbo.construction 
									WHERE propid = t.sunitcode 
									AND type = 'Tenant Turn B' 
									ORDER BY start ASC)
ORDER BY t.sunitcode