select distinct  t.sunitcode [Property ID], 
u.sStatus [Unit Status],
RTRIM(at.SUBGROUP10) Division,
RTRIM(at.SUBGROUP18) Region,
RTRIM(at.SUBGROUP9) District,
RTRIM(at.SUBGROUP12) Market,
RTRIM(at.SUBGROUP13) [Market Area],
rtrim((SELECT at2.spropname FROM yardi_stage.dbo.attributes at2 WHERE at.subgroup14 = at2.scode)) Entity,
p.SADDR1 Address,
p.SCITY City,
p.SSTATE State,
p.SZIPCODE ZIP,
cp.Latitude,
cp.Longitude,
cp.ConstructionLifeCycle Lifecycle,
u.DSQFT SQFT,
cp.Bedrooms,
ROUND(CAST(cp.Baths AS float), 1) Baths,
u.SRENT [Asking Rent],
cp.AskingRentModified [Asking Rent Modified Date],
cp.ProformaRent [Proforma Rent],
(SELECT  TOP (1) rentamount FROM zillow.dbo.zillowdata WHERE (prop_id = p.SCODE) ORDER BY taxassessmentyear DESC) [Zillow Rent],
(CASE WHEN (u.dsqft = 0 OR u.srent = 0) THEN NULL ELSE u.srent / u.dsqft END) [Asking Rent $/SF],
t.scode [Tenant ID], 
concat(t.slastname, ' ', t.sfirstname) [Tenant Name],
t.sphonenum0 [Phone Number],
t.semail Email,
(select status from yardi_stage.dbo.tenstatus where istatus=t.istatus) [Tenant Status],
t.dtsigndate [Lease Sign Date],
t.dtleasefrom [Lease From],
t.dtleaseto [Lease To],
datediff(day, getdate(), t.dtleaseto) [Days to Expiration], 
CASE WHEN t.bMTM=-1 then 'Yes'
Else 'No'
END [Month To Month],
t.dtmovein [Move In],
t.dtmoveout [Move Out],
t.sdeposit0 [Deposit],
t.srent [Rent from Tenant Table],

isnull((SELECT top 1 destimated FROM Yardi_Stage.dbo.camrule WHERE htenant=t.hmyperson AND hchargecode IN (10) AND dtfrom>=t.dtmovein order by dtfrom asc),0)
+isnull((SELECT top 1 destimated FROM Yardi_Stage.dbo.camrule WHERE htenant=t.hmyperson AND hchargecode IN (11) AND dtfrom>=t.dtmovein order by dtfrom asc),0)
+isnull((SELECT top 1 destimated FROM Yardi_Stage.dbo.camrule WHERE htenant=t.hmyperson AND hchargecode IN (18) AND dtfrom>=t.dtmovein order by dtfrom asc),0)
+isnull((SELECT top 1 destimated FROM Yardi_Stage.dbo.camrule WHERE htenant=t.hmyperson AND hchargecode IN (20) AND dtfrom>=t.dtmovein order by dtfrom asc),0) [Rent from Camrule Table],
t.dtotalcharges [Total Monthly Charges],

(select sum(ROUND(CAST(stotalamount - samountpaid AS FLOAT),2)) from yardi_stage.dbo.trans where t.hmyperson = hperson and itype IN (6,7)) [Ledger Balance],


DATEDIFF(day,(case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end),t.dtsigndate)  DOM,

(CASE WHEN DATEDIFF(day, (case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end),t.dtsigndate )  < 31 THEN '0-30'
WHEN DATEDIFF(day,(case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end),t.dtsigndate )  BETWEEN 31 AND 61  THEN '31-60'
WHEN DATEDIFF(day,(case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end),t.dtsigndate )  BETWEEN 61 AND 91 THEN '61-90'
WHEN DATEDIFF(day,(case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end),t.dtsigndate )  >= 91 THEN '90+'
END)  [DOM Category],

CASE WHEN DATEDIFF(day,(case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end),t.dtsigndate ) > 30 THEN 1 ELSE 0 END [30+],
CASE WHEN DATEDIFF(day,(case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end),t.dtsigndate ) > 60 THEN 1 ELSE 0 END [60+],
CASE WHEN DATEDIFF(day,(case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end),t.dtsigndate ) > 90 THEN 1 ELSE 0 END [90+],

(SELECT COUNT(DISTINCT MobilePhone) AS Expr1 FROM CRM.dbo.leads
WHERE (PrimaryProperty = p.SCODE) AND (CreatedOn between (case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end) and t.dtsigndate) AND (MobilePhone IS NOT NULL))
+
(SELECT COUNT(DISTINCT LastName) AS Expr1 FROM CRM.dbo.leads
WHERE (PrimaryProperty = p.SCODE) AND (CreatedOn between (case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end) and t.dtsigndate) AND (MobilePhone IS NULL)) Leads,

(SELECT SUM((CASE WHEN access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing',                                                                      'callcenter_showing') THEN 1 ELSE 0 END)) FROM  [rently].[dbo].[lead_activities] rla
WHERE rla.tag = p.scode AND rla.activity_created_at between (case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end) and t.dtsigndate) [Rently_Check-ins],

(SELECT   TOP 1 activity_created_at FROM [rently].[dbo].[lead_activities] rla WHERE rla.tag = p.scode AND access IN ('self_registered_viewing', 'open_house_viewing', 'controlled_showing', 'callcenter_showing') AND rla.activity_created_at between (case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end) and t.dtsigndate ORDER BY activity_created_at DESC) [Last Rently Check-In],

(SELECT  COUNT(DISTINCT hMy) FROM Yardi_Stage.dbo.prospect WHERE hProperty = p.HMY AND dtApply between (case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end) and t.dtsigndate) [All Yardi Apps],

(SELECT  COUNT(DISTINCT appid) FROM Applications.dbo.apps WHERE  property = p.SCODE AND date between (case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end) and t.dtsigndate) [Screened Apps],

(SELECT COUNT(DISTINCT appid) FROM  Applications.dbo.apps WHERE property = p.SCODE AND final_approved = 1  AND date between (case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end) and t.dtsigndate) [Approved Apps],

(SELECT  ROUND(AVG(CAST(testrating_text AS float)), 1) AS 'rating' FROM  [education.com].dbo.schoolsearch WHERE (prop_id = u.SCODE)) [Avg School Rating]


from Yardi_stage.dbo.tenant t
inner join Yardi_Stage.dbo.UNIT u on t.HPROPERTY = u.HPROPERTY
inner join  Yardi_Stage.dbo.PROPERTY p on p.HMY = u.HPROPERTY
INNER JOIN CRM.dbo.properties AS cp ON cp.PropId = u.SCODE
INNER JOIN Yardi_Stage.dbo.ATTRIBUTES AS at ON at.HPROP = u.hproperty
outer apply (SELECT TOP 1 *  FROM CRM.dbo.constructionhistory WHERE Name =CONCAT(p.SCODE, '- Rent Ready')   and start<dateadd(day,30,t.dtsigndate) ORDER BY Start DESC) rr
outer apply (SELECT TOP 1 *  FROM CRM.dbo.constructionhistory WHERE Name =CONCAT(p.SCODE, '- Market Ready')   and EndDate<dateadd(day,60,t.dtsigndate) ORDER BY enddate DESC) mr

where t.istatus in (0,2,3,4)
