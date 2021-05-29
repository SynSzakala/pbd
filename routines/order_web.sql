create or
alter procedure create_web_order_with_takeaway(
    @item_ids order_item_ids readonly,
    @client_id integer,
    @min_ready_delay_minutes integer = null,
    @order_id integer output
) as
begin
    declare @menu_id integer = dbo.find_active_menu_id(sysdatetime());

    exec dbo.create_order_raw
         @client_id = @client_id,
         @status = 'Waiting',
         @is_takeaway = 1,
         @channel = 'Web',
         @employee_id = null,
         @order_id = @order_id;

    if (@min_ready_delay_minutes is not null)
        update [order]
        set min_ready_time = dateadd(minute, @min_ready_delay_minutes, sysdatetime())
        where id = @order_id;

    exec dbo.insert_order_positions @order_id, @menu_id, @item_ids;
end

create or alter procedure accept_web_order(

)