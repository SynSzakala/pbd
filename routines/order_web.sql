create or
alter procedure create_web_order_with_takeaway(
    @item_ids order_item_ids readonly,
    @client_id integer,
    @min_ready_delay_minutes integer = null,
    @order_id integer output
) as
begin
    declare @menu_id integer = dbo.find_active_menu_id(sysdatetime());
    if (@menu_id is null)
        throw 1002, 'No active menu present for given date', 0;

    exec dbo.create_order_raw
         @client_id = @client_id,
         @status = 'Waiting',
         @is_takeaway = 1,
         @channel = 'Web',
         @employee_id = null,
         @order_id = @order_id output;

    if (@min_ready_delay_minutes is not null)
        update [order]
        set min_ready_time = dateadd(minute, @min_ready_delay_minutes, sysdatetime())
        where id = @order_id;

    exec dbo.insert_order_positions @order_id, @menu_id, @item_ids;
end
go;

create or
alter procedure create_web_order_with_booking(
    @item_ids order_item_ids readonly,
    @client_id integer,
    @start_time datetime,
    @end_time datetime,
    @seats_count integer,
    @company_employee_name varchar(256) = null,
    @order_id integer output
) as
begin
    if (dbo.does_contain_seafood(@item_ids) = 1 and dbo.can_contain_seafood(@start_time) = 0)
        throw 1009,'Invalid start_date for order with seafood', 0;

    declare @table_id integer = dbo.find_free_table(@start_time, @end_time, @seats_count);
    if (@table_id is null)
        throw 1010,'Cannot find table to book', 0;

    declare @menu_id integer = dbo.find_active_menu_id(sysdatetime());
    if (@menu_id is null)
        throw 1002, 'No active menu present for given date', 0;

    exec dbo.create_order_raw
         @client_id = @client_id,
         @status = 'Waiting',
         @is_takeaway = 0,
         @channel = 'Web',
         @employee_id = null,
         @order_id = @order_id output;

    update [order] set company_employee_name = @company_employee_name where id = @order_id;

    exec dbo.insert_order_positions @order_id, @menu_id, @item_ids;
end
go;

create or
alter function can_contain_seafood(@start_date datetime) returns bit
begin
    declare @start_day int = datepart(day, @start_date);
    declare @start_week datetime = dateadd(week, datediff(week, 0, @start_date), 0);
    return iif(@start_day in (3, 4, 5) and sysdatetime() <= @start_week, 1, 0)
end
go;


create or
alter procedure accept_web_order(
    @order_id integer,
    @employee_id integer
) as
begin
    update [order] set status = 'Accepted', status_changed_by = @employee_id where id = @order_id;
end
go;

create or
alter procedure reject_web_order(
    @order_id integer,
    @employee_id integer,
    @reason varchar(1000)
) as
begin
    update [order]
    set status            = 'Rejected',
        rejected_reason   = @reason,
        status_changed_by = @employee_id
    where id = @order_id;
end
go;
