SELECT leases.Property_Code PropId, count(distinct leases.Tenant_code) TenantCount FROM 
(SELECT [HMYPERSON] Tenant_ID
      ,[sCode] as Tenant_Code
      ,[Property] Property_Code
      ,[LeaseTerms]
      ,[LeaseType]
      ,[PropertyManagement]
      ,[CurrentRentReady]
      ,[RentAmount]
      ,[Signed]
      ,[dtStart]
      ,[dtEnd]
      ,[Vacated]
      ,[zVacateReason]
      ,[VacateReason]
      ,[TenantStatus]
      ,[UnitStatus]
  FROM  Datawarehouse.dbo.LeaseHistory
  WHERE TenantStatus IN ('Current','Past','Eviction','Notice')
Union ALL  
SELECT [HMYPERSON] Tenant_ID
      ,t.SCODE as Tenant_Code
      ,[Property_Code]
      ,CAST(iLeaseTerm as nvarchar(50)) [LeaseTerms]
      ,CAST(iLeaseType as nvarchar(50))[LeaseType]
      ,[Property_Name] PropertyManagement
      ,u.dtReady [CurrentRentReady]
      , u.SRent[RentAmount]
      , DTSIGNDATE [Signed]
      , DTLEASEFROM[dtStart]
      , DTLEASETO [dtEnd] 
      , u.dtVacant [Vacated]
      ,'' [zVacateReason]
      ,'' [VacateReason] 
      ,ts.[status] [TenantStatus]
      ,u.sStatus [UnitStatus]
  FROM  DataWarehouse.dbo.tenant t, DataWarehouse.dbo.Property p, DataWarehouse.dbo.Unit u , DataWarehouse.dbo.tenantstatus ts
  WHERE t.hProperty = p.[ID]
  AND t.hUnit = u.hMY
  AND ts.istatus = t.istatus
  AND status IN ('Current','Past','Eviction','Notice')) leases
  
GROUP BY Property_code

HAVING count(distinct leases.Tenant_code) > 1


