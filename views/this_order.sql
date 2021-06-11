CREATE FUNCTION this_order (@OrderID INTEGER)
    RETURNS TABLE
    AS
RETURN
(
    SELECT item.name, order_position.saved_price, order_position.quantity
    FROM order_position
    LEFT JOIN item ON item.id = order_position.item_id
    WHERE order_id = @OrderID
)
select * from this_order(013);