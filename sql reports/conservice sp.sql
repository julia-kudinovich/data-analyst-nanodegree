declare @prop varchar(10)
declare @gl varchar(25)
declare @notes varchar(50)

declare data_cursor cursor FAST_FORWARD for
select distinct rtrim(ltrim([Prop Code])), [Gl Code],[Detail Notes] from conservice.dbo.test_view

open data_cursor
fetch next from  data_cursor  into @prop, @gl, @notes

while @@FETCH_STATUS = 0
begin

declare @cnt int = 0
declare @days int

select top 1 @days=tv.[Service Period Lenght]
  from  conservice.dbo.test_view tv
  where rtrim(ltrim(tv.[Prop Code])) = @prop
  			and tv.[Gl Code] = @gl
		   and tv.[detail Notes] = @notes


WHILE @cnt< @days 
          
Begin

Insert Into conservice.dbo.test 
select t.[Prop Code], t.[GL Code], t.[GL Desc] , dateadd(day,@cnt,t.[Start Date]) date, t.[Average Per Day Rate], t.[Utility Company], t.[Control #] 

from  conservice.dbo.test_view t
where rtrim(ltrim(t.[prop Code])) = @prop
		and t.[Gl Code] = @gl
		and t.[Detail Notes] = @notes
 
SET @cnt=@cnt+1
END;

fetch next from data_cursor into @prop, @gl, @notes
end
close data_cursor
deallocate data_cursor

