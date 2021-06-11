create or
alter function get_discount_type(@client_id integer) returns varchar(2)
begin
    return
        case
            when dbo.has_R2(@client_id) = 1 then 'R2'
            when dbo.has_R1(@client_id) = 1 then 'R1'
            end;
end
go

create or
alter function apply_discount_type(@price_netto decimal(10, 2), @discount_type varchar(2)) returns decimal(10, 2)
begin
    return
        case
            when @discount_type = 'R2' then dbo.apply_R2(@price_netto)
            when @discount_type = 'R1' then dbo.apply_R1(@price_netto)
            else @price_netto
            end;
end
go