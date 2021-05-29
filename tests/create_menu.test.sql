begin transaction;

-- given
declare @start_date datetime = dateadd(day, 2, sysdatetime());
declare @end_date datetime = dateadd(day, 5, sysdatetime());

declare @item_ids menu_item_ids;

insert into item(is_seafood, price_netto, tax_rate, name)
output inserted.id into @item_ids
values (0, 10, 1, 'A'),
       (0, 5, 3, 'B');

set identity_insert employee on;
insert into employee(id, name) values (999, 'test');
set identity_insert employee off;

-- when
exec dbo.create_menu @start_date, @end_date, @item_ids, @employee_id = 999, @override_valid_check = 0;

-- then
select * from menu;
select * from menu_position;

rollback transaction;