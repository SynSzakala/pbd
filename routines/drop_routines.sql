-- drop only problem-causing routines --
drop procedure if exists dbo.create_menu;
drop function if exists dbo.is_menu_valid;
drop function if exists dbo.does_contain_seafood;
drop procedure if exists dbo.insert_order_positions;
drop procedure if exists dbo.create_local_takeaway_order;
drop procedure if exists dbo.create_local_order;
drop procedure if exists dbo.create_web_order_with_booking;
drop procedure if exists dbo.create_web_order_with_takeaway;