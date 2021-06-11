CREATE FUNCTION order_total(@OrderID INTEGER)
    RETURNS TABLE
    AS
RETURN
(
    SELECT "order".id, price_netto, price_brutto, created_time, ready_time
    FROM "order"
    WHERE "order".id = @OrderID
)