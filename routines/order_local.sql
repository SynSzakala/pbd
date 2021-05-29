create or
alter procedure create_local_takeaway_order(
    @item_ids order_item_ids readonly,
    @employee_id integer,
    @client_id integer = null,
    @order_id integer output
) as
begin
    declare @menu_id integer = dbo.find_active_menu_id(sysdatetime());

    exec dbo.create_order_raw
         @client_id = @client_id,
         @status = 'Accepted',
         @is_takeaway = true,
         @employee_id = @employee_id,
         @channel = 'Local',
         @order_id = @order_id;

    exec dbo.insert_order_positions @order_id, @menu_id, @item_ids;
end
go

create or
alter procedure create_local_order(
    @table_id integer,
    @item_ids order_item_ids readonly,
    @employee_id integer,
    @client_id integer = null,
    @order_id integer output
) as
begin
    declare @menu_id integer = dbo.find_active_menu_id(sysdatetime());

    if (dbo.is_table_booked(@table_id, sysdatetime()))
        throw 1005, 'Table is already booked', 0;

    exec dbo.create_order_raw
         @client_id = @client_id,
         @status = 'Accepted',
         @is_takeaway = false,
         @employee_id = @employee_id,
         @channel = 'Local',
         @order_id = @order_id;

    update [order] set booking_start_time = sysdatetime(), booking_table_id = @table_id where id = @order_id;

    exec dbo.insert_order_positions @order_id, @menu_id, @item_ids;
end