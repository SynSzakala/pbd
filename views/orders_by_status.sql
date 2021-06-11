CREATE or alter FUNCTION orders_by_status (@Status VARCHAR(10))
RETURNS TABLE
AS
RETURN
(
    SELECT "order".id, price_netto, client.name
    FROM "order"
    INNER JOIN client ON client.id = "order".client_id
    WHERE "order".status = @Status
)
go;

select * from orders_by_status('Waiting');