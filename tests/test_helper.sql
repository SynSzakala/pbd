create or
alter procedure test__create_employee(@id integer) as
begin
    set identity_insert employee on;
    insert into employee(id, name) values (@id, 'test ' + str(@id));
    set identity_insert employee off;
end
go;

create or
alter procedure test__create_menu_items as
begin
    insert into item(is_seafood, price_netto, tax_rate, name)
    output inserted.id
    values (0, 10, 1, 'A'),
           (0, 5, 3, 'B');
end