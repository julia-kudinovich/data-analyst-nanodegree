
USE Conservice;


;with cteConserviceCharges as 
(
SELECT 
[Detail ID] = d.hmy
,[Prop Code] = p.scode
,[GL Code] = a.scode
,[GL Desc] = a.sdesc
--,[Trans ID] = d.hinvorrec
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
LEFT JOIN dbo.uvwbillprocessingtimeline bpt ON tr.uref = bpt.[ControlNumber] 
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

/* and CAST(tr.sdatecreated AS DATE)>= 
          DATEFROMPARTS(
                YEAR(       DATEADD(mm,-4,CAST(GETDATE() AS DATE)))
          ,     MONTH(      DATEADD(mm,-4,CAST(GETDATE() AS DATE)))
          ,1
          ) */
          
          and bpt.startdate is not null

) -- select top 10 * from cteConserviceCharges


/*
    Instant Numbers Table 
*/
	,cteL0 AS (
		SELECT 1 AS C
		
		UNION ALL
		
		SELECT 1 AS O
		) -- 2 rows
	,cteL1 AS (
		SELECT 1 AS C
		FROM cteL0 AS A
		CROSS JOIN cteL0 AS B
		) -- 4 rows
	,cteL2 AS (
		SELECT 1 AS C
		FROM cteL1 AS A
		CROSS JOIN cteL1 AS B
		) -- 16 rows
	,cteL3 AS (
		SELECT 1 AS C
		FROM cteL2 AS A
		CROSS JOIN cteL2 AS B
		) -- 256 rows
	,cteL4 AS (
		SELECT 1 AS C
		FROM cteL3 AS A
		CROSS JOIN cteL3 AS B
		) -- 65,536 rows
	,cteL5 AS (
		SELECT 1 AS C
		FROM cteL4 AS A
		CROSS JOIN cteL4 AS B
		) -- 4,294,967,296 rows
	,cteNumberTable AS (
		SELECT TOP 10000 (
				ROW_NUMBER() OVER (
					ORDER BY (
							SELECT NULL
							)
					)
				) - 1 AS num
		FROM cteL5
		)
 --	SELECT * FROM cteNumberTable

, cteDailyConserviceCharges as 
(SELECT 
[Prop Code]
,[Detail ID]
,[GL Code]
,[Date]=dateadd(day, num,[Start Date])
,[Control #]
,[Amount]=[Average Per Day rate]
,[Gl Desc]
,[Utility Company]
FROM cteConserviceCharges
CROSS JOIN cteNumberTable 
WHERE dateadd(day, num,[Start Date])<=[End date]
)

/*
select * from cteDailyConserviceCharges
where [Prop Code]='az00274' and [Trans ID]='301285956' and [Date]='2015-08-01'
*/

MERGE dbo.ConserviceDailyCharges as t
USING  cteDailyConserviceCharges as s
ON (t.[Prop Code]=s.[Prop Code] AND t.[detail ID] =s.[detail ID] and t.[GL Code]=s.[GL Code] and t.[Date]=s.[Date] 
and t.[Control #]=s.[Control #] and t.[Utility Company]=s.[Utility Company])

WHEN Not MATCHED by TARGET

THEN INSERT ([Prop Code],[detail ID],[GL Code],[Date],[Control #],[Amount],[Gl Desc],[Utility Company]) 
VALUES (s.[Prop Code],s.[detail ID],s.[GL Code], s.[Date], s.[Control #], s.[Amount], s.[Gl Desc], s.[Utility Company])
WHEN MATCHED AND (t.[Amount]!=s.[Amount] OR t.[Gl Desc]!=s.[Gl Desc])
THEN UPDATE SET [Amount]=s.[Amount], [Gl Desc]=s.[Gl Desc]
WHEN NOT MATCHED BY SOURCE
THEN DELETE;
