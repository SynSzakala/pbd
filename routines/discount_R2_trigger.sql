create or
alter function should_start_R2(@client_id integer) returns bit
begin
    declare @R2_threshold_netto decimal(10, 2) = 1000;
    declare @sum_netto decimal(10, 2);
    if ((select discount_R2_start_date from client where id = @client_id) is not null)
        return 0;
    else
        begin
            select @sum_netto = sum(price_netto) from [order] where client_id = @client_id;
            return iif(@sum_netto >= @R2_threshold_netto, 1, 0);
        end
    -- noinspection SqlUnreachable
    return 0
end
go;

create or alter trigger maybe_start_R2
    on [order]
    after insert, update as
begin
    update client
    set discount_R2_start_date = sysdatetime()
    where id in (select distinct client_id from inserted where dbo.should_start_R2(client_id) = 1);
end
go;