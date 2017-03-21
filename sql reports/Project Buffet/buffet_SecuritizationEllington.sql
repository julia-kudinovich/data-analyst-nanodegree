
select distinct 
p.scode 'Property ID',
rtrim(at.subgroup18) 'Region',
'AH4R' 'Property Manager ID',
concat(p.saddr1,', ', p.scity,', ', p.sstate) 'Property Name',
cp.acquiredtype 'Acquisition Type',
month(cp.dateacquired) 'Acquisition Month',
year(cp.dateacquired) 'Acquisition Year',
datediff(month, cp.dateacquired, getdate()) 'Months Since Acquisition',
p.saddr1 'Address',
p.scity 'City',
p.sstate 'State',
cp.county2 'County',
p.szipcode 'Zip Code',
rtrim(at.subgroup11) 'Property Type',
'No' 'Condo',
cp.yearbuilt 'Year Built',
u.dsqft 'Total Sqft',
cp.bedrooms 'Number of Bedrooms', 
round(cp.baths,1) 'Number of Bathrooms',
(case when cp.pool='False' then 'No'  when cp.pool='True' then 'Yes' end) 'Pool?',
CONVERT(varchar, CAST(cp.purchaseprice AS money), 1)'Purchase Price',
/* (select sum(d.dtotalcost) from yardi_stage.dbo.mm2po p
			left join yardi_stage.dbo.mm2podet d on d.hpo=p.hmy
			left join yardi_stage.dbo.property pr on pr.hmy=d.hprop
			INNER JOIN yardi_stage.dbo.wf_tran_header wfth ON  (p.hmy = wfth.hrecord and wfth.iType=26)
			where pr.scode=p.scode 
			and  wfth.istatus  not in (2,3) -- not cancelled or rejected
			and p.sexptype='Rehab') 'Actual Rehab Spend' */ -- gives all nulls

prev_ten.dtleaseto 'Previous Lease End Date',
(case when prev_ten.bmtm=-1 then 'Yes' when prev_ten.bmtm=0 then 'No' end) 'Previous Lease Month-to-Month',
ten.dtleasefrom 'Date of Lease Start',
ten.dtleaseto 'Date of Lease End',
(case when ten.bmtm=-1 then 'Yes' when ten.bmtm=0 then 'No' end) 'MTM',
round(datediff(day,ten.dtleasefrom,ten.dtleaseto)/30.42,1) 'Original Length of Lease (months)',
(case when  ten.dtleaseto<getdate() then null else round(datediff(day,getdate(),ten.dtleaseto)/30.42,1) end) 'Remaining Lease Term (Months)',
ten.srent '$ Rent (Per Month)',
(case when ten.ileasetype=8 then 'Yes' else 'No' end) 'Section 8?',
-- (select stotalamount from yardi_stage.dbo.trans where hperson=ten.hmyperson and snotes='Prepaid Rent') 'Prepaid Rent', -----???????/
(select sum(case when floor(datediff(day, sDateOccurred ,getdate())/30) > 0 and hoffsetacct=1335 then ROUND(CAST(stotalamount - samountpaid AS FLOAT),2) end )  from yardi_stage.dbo.trans where hperson=ten.hmyperson and itype in (6,7) and hoffsetacct=1335) 'Total Rent Receivable',
(SELECT 
	sum(CASE 
		WHEN floor(datediff(day, trx.sDateOccurred ,getdate())) > 30 and  floor(datediff(day, trx.sDateOccurred ,getdate())) <=60   THEN
		ROUND(CAST(trx.stotalamount - trx.samountpaid AS FLOAT),2)
		ELSE 0 END) 

FROM yardi_stage.dbo.TRANS trx 
WHERE trx.hperson = ten.hmyperson
and ROUND(CAST(trx.stotalamount - trx.samountpaid AS FLOAT),2) > 0
and trx.itype in (6,7)
and trx.hoffsetacct=1335) '30+ Rent Receivable',

(SELECT 
	sum(CASE 
		WHEN floor(datediff(day, trx.sDateOccurred ,getdate())) > 60 and  floor(datediff(day, trx.sDateOccurred ,getdate())) <=90   THEN
		ROUND(CAST(trx.stotalamount - trx.samountpaid AS FLOAT),2)
		ELSE 0 END) 

FROM yardi_stage.dbo.TRANS trx 
WHERE trx.hperson = ten.hmyperson
and ROUND(CAST(trx.stotalamount - trx.samountpaid AS FLOAT),2) > 0
and trx.itype in (6,7)
and trx.hoffsetacct=1335) '61-90 Rent Receivable',

(SELECT 
	sum(CASE 
		WHEN floor(datediff(day, trx.sDateOccurred ,getdate())) > 90   THEN
		ROUND(CAST(trx.stotalamount - trx.samountpaid AS FLOAT),2)
		ELSE 0 END) 

FROM yardi_stage.dbo.TRANS trx 
WHERE trx.hperson = ten.hmyperson
and ROUND(CAST(trx.stotalamount - trx.samountpaid AS FLOAT),2) > 0
and trx.itype in (6,7)
and trx.hoffsetacct=1335) '91+ Rent Receivable', 

(select top 1 lease_type from yardi_stage.dbo.comparable_leases where tenant_id=ten.scode order by lease_start desc)	'Renewal/New Lease?',
'N/A' 'Third Party Property Manager',
ten.srent*12 'Contractual Rent (Annual)',
prev_ten.srent*12 'Previous Contractual Rent (Annual)',
(case when ten.srent*12>0 then ten.srent*12 else  prev_ten.srent*12 end) 'Gross Potential Rent (Annual)',
cp.parcelno 'Tax Parcel',
(case when rtrim(hoa.paymentterm)='Annually' then hoa.paymentamount
		when rtrim(hoa.paymentterm)='Semi-Annual' then hoa.paymentamount*2
		when rtrim(hoa.paymentterm)='Quarterly' then hoa.paymentamount*4
		when rtrim(hoa.paymentterm)='Monthly' then hoa.paymentamount*12
end) 'Annual HOA Dues',

(case when rtrim(hoa.paymentterm)='Annually' then convert(date,DATEADD(year, DATEDIFF(year, -1, GETDATE()), 0))
		when rtrim(hoa.paymentterm)='Semi-Annual' then  convert(date,DATEADD(year, DATEDIFF(year, -0.5, GETDATE()), 0))
		when rtrim(hoa.paymentterm)='Quarterly' then convert(date,DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) + 1, 0))
		when rtrim(hoa.paymentterm)='Monthly' then convert(date,DATEADD(d, 1, EOMONTH(getdate())))
end) 'Next HOA Due Date',
hoa.hoaname 'HOA Contact',
rtrim(hoa.paymentterm)	'HOA Payment Frequency',
(case when month(prev_ten.dtmoveout)=month(getdate()) and  year(prev_ten.dtmoveout)=year(getdate()) then 'Yes'
		else 'No'
end) 'Did Property Become Vacant in Calendar Month?',

(case when month(prev_ten.dtmoveout)=month(getdate()) and  year(prev_ten.dtmoveout)=year(getdate()) then prev_ten.dtmoveout
		else null
end) 'Move Out Date', 

(case when u.sstatus in ('Occupied No Notice','Notice Rented', 'Notice Unrented', 'Vacant Rented Not Ready') then 'Occupied'
		when u.sstatus in ('Vacant Unrented Not Ready','Vacant Rented Ready','Vacant Unrented Ready') then 'Vacant'
end)  'Current Month Occupancy Status',

(case when month(prev_ten.dtmoveout)=month(DATEADD(month, -1, GETDATE())) and  year(prev_ten.dtmoveout)=year(getdate()) then prev_ten.dtmoveout
		else null
end) 'Previous Month Move Out Date',
ten.srent 'In-Place Rent',
ten.sdeposit0 'Security Deposit'


/*,u.sstatus,
ten.scode,
ten.hmyperson */

			

from yardi_stage.dbo.property p
left join   yardi_stage.dbo.tenant t on p.hmy=t.hproperty
inner JOIN yardi_stage.dbo.attributes at ON at.hprop = p.hmy
inner join yardi_stage.dbo.unit u on u.hproperty=p.hmy
outer apply (select top 1 * from yardi_stage.dbo.tenant where sunitcode=t.sunitcode  and istatus in (0,1,3,4) order by dtsigndate desc) ten
outer apply (select top 1 * from yardi_stage.dbo.tenant where sunitcode=t.sunitcode  and istatus in (1) order by dtsigndate desc) prev_ten
outer apply (select top 1 * from crm.dbo.hoapropertyaccounts where propertyid=p.scode) hoa

outer apply (select top 1 * from crm.dbo.properties where propid=p.scode) cp

where at.subgroup12 is not null
and at.subgroup12!='Corp'
and rtrim((SELECT at2.spropname FROM yardi_stage.dbo.attributes at2 WHERE at.subgroup14 = at2.scode)) in ('4RAMHB1', '4RAMHB2','4RAMHB3','4RAMHB4')

