USE Yardi_Stage;

SELECT TOP 10
[Prop Code] = p.scode
,[GL Code] = a.scode
,[GL Desc] = a.sdesc
,d.hinvorrec
,[Date Uploaded] = CAST(tr.sdatecreated as date)
,[Bill Date] = CAST(tr.sdateoccurred AS DATE)
,[Cash Post Month] = CAST(d.CashPost AS DATE)
,[Control #] = tr.uref
,[Utility Amount] = CAST(d.samount AS money)
,[Utility Company] =  REPLACE(REPLACE(tr.snotes, CHAR(13), ' '), CHAR(10), ' ')
,[Start Date] = bpt.startdate
,[End Date] = bpt.enddate
,[Service Period Lenght] =datediff(day,bpt.startdate,bpt.enddate)+1
,[Average Per Day Rate] = CAST(d.samount AS money)/(datediff(day,bpt.startdate,bpt.enddate)+1)
,[Detail Notes] =
CAST(
CASE 
       WHEN u.hmy is null then p.scode 
       ELSE REPLACE(REPLACE(d.snotes, CHAR(13), ' '), CHAR(10), ' ')
END
AS VARCHAR(200))

FROM   Yardi_stage.dbo.detail d   
INNER JOIN Yardi_stage.dbo.trans tr on d.hinvorrec = tr.hmy
INNER JOIN Yardi_stage.dbo.property p ON d.hprop = p.hmy
INNER JOIN Yardi_stage.dbo.acct a ON a.hmy = d.hacct
LEFT JOIN conservice.dbo.billprocessingtimeline bpt ON tr.uref = bpt.[ControlNumber] 
AND 
       CASE
              WHEN bpt.[utilityname2] LIKE '%trash%' AND a.sdesc like '%trash%'
                           AND bpt.Expense = CAST(d.samount AS money)
                     THEN 1
              WHEN bpt.[utilityname2] LIKE '%Electric%' AND a.sdesc like '%Electric%'
                           AND bpt.Expense = CAST(d.samount AS money)
                     THEN 1
              WHEN bpt.[utilityname2] LIKE '%Sewer%' AND a.sdesc like '%Sewer%'
                           AND bpt.Expense = CAST(d.samount AS money)
                     THEN 1
              WHEN bpt.Expense = CAST(d.samount AS money)
                     THEN 1
       END = 1

LEFT JOIN Yardi_stage.dbo.unit u ON p.hmy = u.hproperty


WHERE 1=1


and tr.hperson = 31452 -- conservice
-- and tr.uref = 'SF0058098'

and
a.scode IN
(5302400
,5302100
,5302200
,5302300
,5302500
--,1200815 -- utility deposits
)

and CAST(tr.sdatecreated AS DATE)>= 
          DATEFROMPARTS(
                YEAR(       DATEADD(mm,-4,CAST(GETDATE() AS DATE)))
          ,     MONTH(      DATEADD(mm,-4,CAST(GETDATE() AS DATE)))
          ,1
          )
          
          and bpt.startdate is not null

ORDER BY CAST(tr.sdatecreated AS DATE)
