CREATE or alter FUNCTION order_total(@OrderID INTEGER)
    RETURNS TABLE
    AS
RETURN
(
    SELECT [order].id, price_netto, price_brutto, created_time, ready_time
    FROM [order]
    WHERE [order].id = @OrderID
)

CREATE or alter FUNCTION disc_orders_lastmonth(@OrderID INTEGER)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT [order].id, price_netto, price_brutto, created_time, ready_time
                FROM [order]
                WHERE [order].id = @OrderID AND [order].discount_type IS NOT NULL AND MONTH([order].created_time) = MONTH(GETDATE()) - 1
            )
GO

-- to check after generating data
CREATE
    OR ALTER
    VIEW disc_given ("Znizka", "Udzielono razy")
AS SELECT [order].discount_type, count(discount_type)
   FROM [order]
   GROUP BY [order].discount_type
