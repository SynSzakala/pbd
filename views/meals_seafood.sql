CREATE or alter VIEW pending_seafood AS
SELECT order_position.order_id, item.name, [order].ready_time
FROM order_position
         INNER JOIN item ON item.id = order_position.item_id
         INNER JOIN [order] ON [order].id = order_position.order_id
WHERE [order].status = 'Accepted'
  AND item.is_seafood = 1;
