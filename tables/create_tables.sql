CREATE TABLE client
(
    id                           integer primary key identity,
    client_type                  varchar(10)   not null check (client_type in ('Private', 'Company')),
    name                         varchar(2000) not null,
    email                        varchar(255)  not null check (email like '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%'),
    phone_number                 varchar(9),
    nip                          varchar(9),
    company_address_street       varchar(255),
    company_address_house_number varchar(10),
    company_address_flat_number  varchar(10),
    company_address_zip_code     varchar(10) check (company_address_zip_code like '[0-9][0-9]-[0-9][0-9][0-9]'),
    company_address_city         varchar(255),
    discount_R2_start_date       datetime
);

CREATE TABLE employee
(
    id   integer primary key identity,
    name varchar(255) not null
);

CREATE TABLE menu
(
    id                     integer primary key identity,
    start_date             datetime not null,
    end_date               datetime not null,
    created_date           datetime not null,
    created_by_employee_id integer  not null foreign key REFERENCES employee (id),
    check (datediff(day, created_date, start_date) >= 1),
    check (end_date > start_date)
);

CREATE TABLE item
(
    id          integer primary key identity,
    is_seafood  bit            not null,
    price_netto decimal(10, 2) not null,
    tax_rate    decimal(5, 2)  not null check (tax_rate >= 0 and tax_rate <= 100),
    name        varchar(255)   not null
);

CREATE TABLE menu_position
(
    item_id integer not null references item (id),
    menu_id integer not null references menu (id),
    primary key (item_id, menu_id)
);

CREATE TABLE bookable_table
(
    id          integer primary key identity,
    seats_count integer not null
);
