select distinct  t.scode 'Tenant Code',(select status from yardi_stage.dbo.tenstatus where istatus=t.istatus) 'Tenant Status' ,t.slastname 'Last Name', t.sfirstname 'First Name', 
t.sunitcode 'Property', p.saddr1 'Address', p.scity 'City', p.sstate 'State', p.szipcode 'Zip',
rtrim(at.subgroup10)'Division', 
rtrim(at.subgroup18) 'Region', 
rtrim(at.subgroup9) 'District', 
rtrim(at.subgroup12) 'Market',
rtrim((SELECT at2.spropname FROM yardi_stage.dbo.attributes at2 WHERE at.subgroup14 = at2.scode)) 'Entity',
CAST(rtrim(ltrim(cp.Latitude)) as DECIMAL(14,10)) Latitude,
CAST(rtrim(ltrim(cp.Longitude)) as DECIMAL(14,10)) Longitude,
app.date 'Application Date',
app.income 'Income',
app.debt Debt,
app.collections Collections,
app.score 'FICO Score',
app.eviction 'Pre AH4R Evictions',
app.foreclosure 'Foreclosure',
app.felony 'Felony',
app.adult_occupants '# of Adults',
app.children '# of Children',
app.total_occupants 'Total Occupants',
app.pets '# of Pets',

(select count(distinct hmy) from yardi_stage.dbo.tenant_history where htent=t.hmyperson and sevent='Eviction') 'Times Went Into Evictions',
(select count(sevent) from yardi_stage.dbo.tenant_history where sevent='Lease Renewal' and htent=t.hmyperson)-(select count(sevent) from yardi_stage.dbo.tenant_history where sevent='Lease Renewal Canceled' and htent=t.hmyperson) '# of Renewals',
t.srent 'Rent',
t.dtsigndate 'Sign Date',
t.dtmovein 'Move In Date',
t.dtmoveout 'Move Out Date',
t.dtleasefrom 'Lease From',
t.dtleaseto 'Lease To',
t.dtrenewdate 'Renew Date',
CASE WHEN t .dtmoveout IS NOT NULL AND year(t .dtmoveout) != 2099 THEN datediff(day, t .dtmovein, t .dtmoveout) 
		WHEN t .dtmoveout IS NULL THEN datediff(day, t .dtmovein, getdate()) 
      WHEN t .istatus = 3 AND year(t .dtmoveout) = 2099 THEN datediff(day, t .dtmovein, getdate()) 
END 'Length of Stay'

from  yardi_stage.dbo.tenant t
inner join yardi_stage.dbo.prospect pr on pr.hmy=t.hprospect
inner join applications.dbo.apps app on (t.scode=app.appid or (app.appid=pr.scode and pr.sstatus='Resident'))
inner join yardi_stage.dbo.property p on t.hproperty = p.hmy
inner  JOIN yardi_stage.dbo.attributes at ON at.hprop = p.hmy 
inner  join yardi_stage.dbo.unit u on p.hmy = u.hproperty
outer apply (select top 1 * from crm.dbo.properties where propid=t.sunitcode) cp
where t.istatus in (0,1,2,3,4)
