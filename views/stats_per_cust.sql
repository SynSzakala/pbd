CREATE or
alter FUNCTION cust_trx_hist(@ClientID INTEGER)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT "order".*, client.name
                FROM "order"
                         JOIN client ON client.id = "order".client_id
                where [order].client_id = @ClientID
            )
go

select *
from cust_trx_hist(2);