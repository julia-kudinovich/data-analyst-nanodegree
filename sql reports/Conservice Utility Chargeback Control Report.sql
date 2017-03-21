SELECT 
d.[Property]
,d.[Utility]
,d.[Utility Company]
,d.[Notes]
,[Service Period Start] = CASE 
										WHEN year(d.[Service Period End])=2014 AND year(d.[Service Period Start])=2015 
											   THEN DATEADD(YEAR, -1, [Service Period Start] )
										WHEN year(d.[Service Period End])=2014 AND month(d.[Service Period Start])>month(d.[Service Period End])	
											THEN DATEADD(YEAR, -1, [Service Period Start] )
								   	WHEN year(d.[Service Period End])=2015 AND year(d.[Service Period Start])=2015 AND month(d.[Service Period Start])>month(d.[Service Period End])	
											   THEN DATEADD(YEAR, -1, [Service Period Start] )
									ELSE d.[Service Period Start] 
									END	
										
										
,d.[Service Period End] 
,[Service Period Lenght] = datediff(day,
												(CASE 
										WHEN year(d.[Service Period End])=2014 AND year(d.[Service Period Start])=2015 
											   THEN DATEADD(YEAR, -1, [Service Period Start] )
										WHEN year(d.[Service Period End])=2014 AND month(d.[Service Period Start])>month(d.[Service Period End])	
											THEN DATEADD(YEAR, -1, [Service Period Start] )
								   	WHEN year(d.[Service Period End])=2015 AND year(d.[Service Period Start])=2015 AND month(d.[Service Period Start])>month(d.[Service Period End])	
											   THEN DATEADD(YEAR, -1, [Service Period Start] )
									ELSE d.[Service Period Start] 
									END)
													,d.[Service Period End] )+1
													
,d.[Amount Paid]
,[Average Per Day Rate] = d.[Amount Paid]/(datediff(day,
												(CASE 
										WHEN year(d.[Service Period End])=2014 AND year(d.[Service Period Start])=2015 
											   THEN DATEADD(YEAR, -1, [Service Period Start] )
										WHEN year(d.[Service Period End])=2014 AND month(d.[Service Period Start])>month(d.[Service Period End])	
											THEN DATEADD(YEAR, -1, [Service Period Start] )
								   	WHEN year(d.[Service Period End])=2015 AND year(d.[Service Period Start])=2015 AND month(d.[Service Period Start])>month(d.[Service Period End])	
											   THEN DATEADD(YEAR, -1, [Service Period Start] )
									ELSE d.[Service Period Start] 
									END)	
													,d.[Service Period End] )+1
													)


 FROM

(SELECT Distinct top 2000
-- t.hmy,
[Property] = p.scode
,[Utility] = a.sdesc
,[Utility Company] = t.snotes
,[Notes] = d.snotes 
,[Service Period Start] = (case when isdate(CASE WHEN LEN(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/' ))= 7

AND substring(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/' ),1,3)>=10 

THEN rtrim(ltrim(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/2014' )))

WHEN LEN(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/' ))= 7

AND substring(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/' ),1,3)<10 

THEN rtrim(ltrim(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/2015' )))

ELSE ltrim(rtrim(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/20' )))

 END 
)=0 then null

else cast(CASE WHEN LEN(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/' ))= 7

AND substring(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/' ),1,3)>=10 

THEN rtrim(ltrim(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/2014' )))

WHEN LEN(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/' ))= 7

AND substring(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/' ),1,3)<10 

THEN rtrim(ltrim(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/2015' )))

ELSE ltrim(rtrim(stuff(stuff(
CASE WHEN LEN(ltrim(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) )), ' ')
else REVERSE(SUBSTRING(reverse(d.snotes),CHARINDEX ('-',REVERSE(d.snotes))+1,CHARINDEX (' ',REVERSE(d.snotes))-CHARINDEX ('-',REVERSE(d.snotes)) ))
end,4,0,'/'),7,0,'/20' )))

 END as date)
end)


,[Service Period End] = (case when isdate(CASE WHEN LEN(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/'))=6 

AND substring(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/'),1,2)>=10

THEN ltrim(rtrim(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/2014')))

WHEN LEN(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/'))=6

AND substring(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/'),1,2)<10

THEN ltrim(rtrim(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/2015')))

ELSE ltrim(rtrim(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/20')))

END)=0 then null
else cast(CASE WHEN LEN(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/'))=6 

AND substring(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/'),1,2)>=10

THEN ltrim(rtrim(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/2014')))

WHEN LEN(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/'))=6

AND substring(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/'),1,2)<10

THEN ltrim(rtrim(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/2015')))

ELSE ltrim(rtrim(STUFF(stuff(
CASE WHEN LEN(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))))=4 then concat(REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes)))),' ') else REVERSE(SUBSTRING(reverse(d.snotes),0,CHARINDEX ('-',REVERSE(d.snotes))))
end,3,0,'/'),6,0,'/20')))

END as date)
end)

,[Amount Paid] = d.samount
/*
,[Vacancy Period] =
,[Tenant Code 1] =
,[T1 Move In] =
,[T1 Move Out] =
,[T1 Days In Home] =
,[T1 Pro Rate] =
,[Tenant Code 2] =
,[T2 Move In] =
,[T2 Move Out] =
,[T2 Days In Home] =
,[T2 Pro Rate] = */


FROM Yardi_Stage.dbo.trans t
LEFT JOIN yardi_stage.dbo.person mv ON mv.hmy = t.hperson
left join yardi_stage.dbo.detail d on t.hmy=d.hInvOrRec
left join yardi_stage.dbo.property p on p.hmy=d.hprop
left join yardi_stage.dbo.acct a on a.hmy=d.hacct
where mv.ulastname like '%conservice%'
and d.hacct in (1252,1254,1257,1255,1250)
and t.snotes not like '%revers%'
and t.snotes not like '%refund%'
and d.snotes not like '%post%'
and d.snotes not like '%deposit%'
and CHARINDEX (' ',d.snotes)<=CHARINDEX ('-',d.snotes) -- otherwise throws errors when notes don't obey a common pattern
and substring(reverse(d.snotes),0,12)  like '%-%'  -- otherwise throws errors when notes don't obey a common pattern
 ) d

order by [Service Period Lenght] 
