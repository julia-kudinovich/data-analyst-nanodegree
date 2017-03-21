select  h.propertyid [Property ID], 
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

t.scode [Tenant in time of violation],
t.dtmovein [Move in],
t.dtmoveout [Move Out],
t.dtleasefrom [Lease From],
t.dtleaseto [Lease To],
(select status from yardi_stage.dbo.tenstatus where istatus=t.istatus) [Tenant Status],
h.violationno [Violation No],
h.hoapropertyaccount [HOA Account],
h.createdon [Created On],
h.noticedate [Notice Date],
h.noticetype [Notice Type],
h.violationamount [Violation Amount],
h.paidamount [Paid Amount],
h.incurredamount [Incurred Amount],
h.responsibleparty [Responsible Party],
h.tenantassessedamount [Amount Charged Back to Tenant],
h.violationtype [Violation Type],
h.violationcategory [Violation Category],
h.violationstatus [Violation Status],
h.datenoticesenttotenant [Date Notice sent to Tenant],
h.duedate [Due Date],
h.fieldcomments [Field Comments],
h.comment [Comments],
h.finenumber [Fine Number],
h.vendorname [Vendor Name],
h.vendorcost [Vendor Cost]






 from crm.dbo.hoaviolation h
 inner join Yardi_Stage.dbo.UNIT u on h.propertyid = u.scode
inner join  Yardi_Stage.dbo.PROPERTY p on p.HMY = u.HPROPERTY
INNER JOIN CRM.dbo.properties AS cp ON cp.PropId = u.SCODE
INNER JOIN Yardi_Stage.dbo.ATTRIBUTES AS at ON at.HPROP = u.hproperty
outer apply (select top 1 * from yardi_stage.dbo.tenant where sunitcode=h.propertyid and h.createdon>=dtleasefrom and  h.createdon<=dtleaseto and istatus in (0,1,3,4) ) t

where h.noticetype='Violation Fine'