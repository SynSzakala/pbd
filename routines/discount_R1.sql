create or
alter function has_R1(@client_id integer) returns bit
begin
    declare @R1_min_order_count integer = 10;
    declare @R1_min_order_price_netto decimal(10, 2) = 30;
    declare @count integer;
    select @count = count(*)
    from [order]
    where client_id = @client_id
      and price_netto >= @R1_min_order_price_netto;
    return iif(@count >= @R1_min_order_count, 1, 0);
end;
go;

create or
alter function apply_R1(@price_netto decimal(10, 2)) returns decimal(10, 2)
begin
    declare @R1_discount_percent decimal(5, 2) = 5;
    return dbo.apply_discount(@price_netto, @R1_discount_percent);
end;
go;