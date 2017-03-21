SELECT distinct t.sunitcode [Property ID], 
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
t.scode [Tenant ID], 
concat(t.slastname, ' ', t.sfirstname) [Tenant Name],
t.sphonenum0 [Phone Number],
t.semail Email,
(select status from yardi_stage.dbo.tenstatus where istatus=t.istatus) [Tenant Status],
t.dtsigndate [Lease Sign Date],
t.dtleasefrom [Lease From],
t.dtleaseto [Lease To],
CASE WHEN t.bMTM=-1 then 'Yes'
Else 'No'
END [Month To Month],
t.dtmovein [Move In],
t.dtmoveout [Move Out]

from Yardi_stage.dbo.tenant t
inner join Yardi_Stage.dbo.UNIT u on t.HPROPERTY = u.HPROPERTY
inner join  Yardi_Stage.dbo.PROPERTY p on p.HMY = u.HPROPERTY
INNER JOIN CRM.dbo.properties AS cp ON cp.PropId = u.SCODE
INNER JOIN Yardi_Stage.dbo.ATTRIBUTES AS at ON at.HPROP = u.hproperty
where t.istatus in (0,1,2,3,4)