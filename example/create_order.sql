declare @ids order_item_ids;

insert into @ids(id, quantity)
values (0, 1), (2, 2), (4, 2), (8, 6);

declare @order_id integer;

exec dbo.create_local_order @table_id = 0, @item_ids = @ids, @employee_id = 0, @client_id = 0, @order_id = @order_id output;