declare @ids menu_item_ids;

insert into @ids (id)
values (0), (1), (2), (3), (4);

declare @start_date datetime = datefromparts(2021, 06, 13);
declare @end_date datetime = datefromparts(2021, 06, 16);


exec dbo.create_menu @start_date, @end_date, @ids, 0, 1;