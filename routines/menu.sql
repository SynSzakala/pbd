drop type if exists menu_item_ids;
go;

create type menu_item_ids as table
(
    id integer unique
);
go;

-- checks whether there's already a menu defined for this period
create or
alter function does_menu_overlap(@start_date datetime, @end_date datetime) returns bit
begin
    if exists(
            select id
            from menu
            where dbo.inline_max_date(start_date, @start_date) < dbo.inline_min_date(end_date, @end_date)
        )
        return 1;
    return 0;
end
go

-- checks the "at least half of positions is changed in two weeks' period" requirement
create or
alter function is_menu_valid(@start_date datetime, @item_ids menu_item_ids readonly) returns bit
begin
    declare @menu_period_days integer = 14;
    declare @start_date_minus_period datetime = dateadd(day, @menu_period_days, @start_date);
    declare @item_ids_size integer = (select count(*) from @item_ids);

    declare @new_item_ids_size integer = (
        select count(*)
        from @item_ids
        where id not in (
            select menu_position.item_id
            from menu
                     right join menu_position on menu.id = menu_position.menu_id
            where menu.start_date >= @start_date_minus_period
              and menu.end_date <= @start_date
        )
    );

    return iif(@new_item_ids_size >= @item_ids_size / 2, 1, 0);
end
go;

create or
alter procedure create_menu(
    @start_date datetime,
    @end_date datetime,
    @item_ids menu_item_ids readonly,
    @employee_id integer,
    @override_valid_check bit = 0
) as
begin
    if (dbo.does_menu_overlap(@start_date, @end_date) = 1)
        throw 50000, 'Menu overlaps with other menu', 0;

    if (@override_valid_check = 0)
        if (dbo.is_menu_valid(@start_date, @item_ids) = 0)
            throw 50001, 'Menu is not valid, use @override_valid_check = 1 to disable this error', 0;

    declare @menu_id_table table
                           (
                               id integer
                           );

    insert into menu(start_date, end_date, created_date, created_by_employee_id)
    output inserted.id into @menu_id_table
    values (@start_date, @end_date, sysdatetime(), @employee_id);

    declare @menu_id integer;
    select @menu_id = id from @menu_id_table;

    insert into menu_position(item_id, menu_id) select id, @menu_id from @item_ids;
end
go