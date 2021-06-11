create or
alter function has_R2(@client_id integer) returns bit
begin
    declare @R2_days integer = 7;
    declare @start_date datetime;
    select @start_date = discount_R2_start_date from client where id = @client_id;
    return case
               when @start_date is null then 0
               when datediff(day, @start_date, sysdatetime()) <= @R2_days then 1
               else 0
        end;
end
go;

create or
alter function apply_R2(@price_netto decimal(10, 2)) returns decimal(10, 2)
begin
    declare @R2_discount_percent decimal(5, 2) = 10;
    return dbo.apply_discount(@price_netto, @R2_discount_percent);
end
go;
