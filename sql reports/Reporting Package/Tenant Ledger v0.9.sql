USE [PM]
GO

/****** Object:  View [dbo].[uvwTenantLedger]    Script Date: 6/15/2015 7:20:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[uvwTenantLedger]
AS

SELECT 

[Property] = t.sunitcode,
[Division] = rtrim(at.subgroup10),
[Region] = rtrim(at.subgroup18),
[District] = rtrim(at.subgroup9),
[Market] = rtrim(at.subgroup12),
[Market Area] = rtrim(at.subgroup13),
[Entity] = rtrim((SELECT at2.spropname FROM Yardi_stage.dbo.attributes at2 WHERE at.subgroup14 = at2.scode)),
[Tenant Status] = (SELECT TOP 1 ts.status FROM Yardi_stage.dbo.tenant t 
	LEFT JOIN Yardi_stage.dbo.tenstatus ts ON ts.istatus = t.istatus
		WHERE t.hmyperson = tr.hperson AND t.istatus IN (0,1,2,3,4) 
			ORDER BY t.dtsigndate DESC), 
[Date Posted] = tr.upostdate, 
[Date Occurred] = tr.sdateoccurred, 
[Charge Hmy] = tr.hoffsetacct, 
[Charge Description] = (select sdesc FROM  Yardi_stage.dbo.acct 
	WHERE tr.hoffsetacct = hmy), 
[Charge Notes] = tr.snotes, 
[Pmt or Charge] = (CASE 
							WHEN tr.itype = 6 
								THEN 'Tenant Payment' 
							ELSE 'Tenant Charge' 
						END), 
[Amount Charged or Applied] = tr.stotalamount, 
[Tenant Payment] = tr.samountpaid, 
[Charge Balance] = ROUND(CAST(tr.stotalamount - tr.samountpaid AS FLOAT),2),
[Age Category] = 
	(CASE
		WHEN
			DATEDIFF(DAY,tr.sdateoccurred,GETDATE()) < 31
				THEN '0-30'
		
		WHEN
			DATEDIFF(DAY,tr.sdateoccurred,GETDATE()) >= 31 AND DATEDIFF(DAY,tr.sdateoccurred,GETDATE()) < 61
 				THEN '31-60'
 				
 		WHEN
			DATEDIFF(DAY,tr.sdateoccurred,GETDATE()) >= 61 AND DATEDIFF(DAY,tr.sdateoccurred,GETDATE()) < 91
 				THEN '61-90'
 				
		ELSE '90+'		
	END),

[30+] = 
	(CASE
		WHEN
			DATEDIFF(DAY,tr.sdateoccurred,GETDATE()) >= 31
				THEN 1
		ELSE 0
	END),

[60+] = 
	(CASE
		WHEN
			DATEDIFF(DAY,tr.sdateoccurred,GETDATE()) >= 61
				THEN 1
		ELSE 0
	END),

[90+] = 
	(CASE
		WHEN
			DATEDIFF(DAY,tr.sdateoccurred,GETDATE()) >= 91
				THEN 1
		ELSE 0
	END)

	
FROM Yardi_stage.dbo.trans tr

LEFT JOIN Yardi_stage.dbo.tenant t ON t.hmyperson = tr.hperson
LEFT JOIN Yardi_stage.dbo.attributes at ON t.hproperty = at.hprop

WHERE tr.itype IN (6,7)



GO


