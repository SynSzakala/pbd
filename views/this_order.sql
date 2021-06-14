CREATE or alter FUNCTION this_order (@OrderID INTEGER)
    RETURNS TABLE
    AS
RETURN
(
    SELECT item.name, order_position.saved_price_netto, order_position.saved_price_brutto, order_position.quantity
    FROM order_position
    LEFT JOIN item ON item.id = order_position.item_id
    WHERE order_id = @OrderID
)
GO

select * from this_order(013);