declare @ids order_item_ids;

insert into @ids(id, quantity)
select top (4) item_id, floor(rand() * 5) + 1
from menu_position join item on item.id = menu_position.item_id
where menu_id = dbo.find_active_menu_id(sysdatetime()) and item.is_seafood = 0

declare @order_id integer;

-- Local --
exec dbo.create_local_order @table_id = 0, @item_ids = @ids, @employee_id = 0, @client_id = 0,
     @order_id = @order_id output;

-- LocalTakeaway --
exec dbo.create_local_takeaway_order @item_ids = @ids, @employee_id = 0, @client_id = 0, @order_id = @order_id output;

-- WebTakeaway --
declare @mrt datetime = dateadd(minute, 20, sysdatetime())

exec dbo.create_web_order_with_takeaway @item_ids = @ids, @client_id = 0, @min_ready_time = @mrt,
     @order_id = @order_id output;

declare @prt datetime = dateadd(minute, 30, sysdatetime())

exec dbo.accept_web_order @order_id = @order_id, @employee_id = 0, @predicted_ready_time = @prt;

-- WebWithBooking --

declare @start_time datetime = dateadd(day, 1, sysdatetime())
declare @end_time   datetime = dateadd(hour, 1, @start_time)
exec dbo.create_web_order_with_booking
    @item_ids = @ids,
    @client_id = 0,
    @start_time = @start_time,
    @end_time = @end_time,
    @seats_count = 8,
    @company_employee_name = default,
    @order_id = @order_id output

exec dbo.accept_web_order @order_id = @order_id, @employee_id = 0, @predicted_ready_time = default;
