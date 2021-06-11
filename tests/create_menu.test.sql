begin transaction;

-- given --
declare @start_date datetime = dateadd(day, 2, sysdatetime());
declare @end_date datetime = dateadd(day, 5, sysdatetime());

declare @item_ids menu_item_ids;
insert @item_ids exec dbo.test__create_menu_items;

exec dbo.test__create_employee @id = 999;

-- when --
exec dbo.create_menu @start_date, @end_date, @item_ids, @employee_id = 999, @override_valid_check = 0;

-- then --
-- menu
select * from menu;
-- menu_position
select * from menu_position;

rollback transaction;