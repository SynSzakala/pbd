drop type order_item_ids
create type order_item_ids as table
(
    id       integer unique references item (id),
    quantity integer,
)
go

create or
alter function find_active_menu_id(@date datetime) returns integer
begin
    declare @menu_id integer;
    select @menu_id = id from menu where @date >= start_date and @date <= end_date;
    if (@menu_id is null)
        throw 1002, 'No active menu present for given date', 0;
    return @menu_id;
end
go

create or alter trigger update_price_and_tax
    on order_position
    after insert as
begin
    update [order]
    set price_netto = [order].price_netto + order_ids_and_values.price_netto,
        tax_value   = [order].tax_value + order_ids_and_values.tax_value
    from (select order_id, sum(saved_price_netto) as price_netto, sum(saved_price_netto * saved_tax_rate) as tax_value
          from inserted
          group by order_id) as order_ids_and_values
    where [order].id = order_ids_and_values.order_id;
end
go;

create or
alter function does_contain_seafood(@item_ids order_item_ids readonly) returns bit
begin
    return iif(
            exists(
                    select *
                    from @item_ids as item_ids
                             join item on item.id = item_ids.id
                    where is_seafood = 1
                ),
            1,
            0
        );
end
go;

create or
alter procedure insert_order_positions(@order_id integer, @menu_id integer, @item_ids order_item_ids readonly) as
begin
    insert into order_position(order_id, menu_id, item_id, saved_price_netto, saved_tax_rate, quantity)
    select @order_id, @menu_id, item_ids.id, item.price_netto, item.tax_rate, item_ids.quantity
    from @item_ids as item_ids
             join item on item.id = item_ids.id;
end
go

create or
alter procedure create_order_raw(
    @client_id integer,
    @status varchar(10),
    @is_takeaway bit,
    @channel varchar(10),
    @employee_id integer,
    @order_id integer output
) as
begin
    declare @order_id_table table
                            (
                                id integer references [order] (id)
                            );
    insert into [order](client_id, discount_type, channel, status, is_takeaway, status_changed_by)
    output inserted.id into @order_id_table
    values (@client_id, dbo.get_discount_type(@client_id), @channel, @status, @is_takeaway, @employee_id);

    select @order_id = id from @order_id_table;
end