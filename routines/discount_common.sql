create or
alter function apply_discount(@price_netto decimal(10, 2), @discount decimal(5, 2)) returns decimal(10, 2)
begin
    return @price_netto * (100 - @discount) / 100;
end
go
