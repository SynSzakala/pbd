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

CREATE TABLE "order"
(
    -- keys --
    id                      integer primary key identity,
    client_id               integer references client (id),

    -- order fulfillment --
    is_takeaway             bit            not null,
    channel                 varchar(10)    not null check (channel in ('Web', 'Local')),

    -- booking and timing --
    -- minimum time when client can arrive to pick up the order, applies only for web-takeaway orders
    min_ready_time          datetime,
    -- predicted time when order will be ready for pick-up, set when order is accepted,
    -- applies only for web-takeway orders
    predicted_ready_time    datetime,
    ready_time              datetime,                                         -- actual time of transition from 'Accepted' to 'Ready' state
    booking_start_time      datetime,
    booking_end_time        datetime,
    booking_table_id        integer references bookable_table (id),
    company_employee_name   varchar(256),
    check (company_employee_name is null or dbo.is_client_company(client_id) = 1),

    -- price --
    discount_type           varchar(2) check (discount_type in ('R1', 'R2')), -- null -> no discount
    price_netto             decimal(10, 2) not null default 0,
    tax_value               decimal(10, 2) not null default 0,

    -- price-based computed data --
    price_brutto            as price_netto + tax_value,
    price_netto_discounted  as dbo.apply_discount_type(price_netto, discount_type),
    price_brutto_discounted as dbo.apply_discount_type(price_netto, discount_type) + tax_value,

    -- misc state --
    status                  varchar(10)    not null default 'Waiting',
    check (status in ('Waiting', 'Accepted', 'Ready', 'Rejected')),
    rejected_reason         varchar(1000),
    check (status <> 'Rejected' or rejected_reason is not null),
    created_time            datetime       not null default sysdatetime(),
    status_changed_by       integer references employee (id),
);

CREATE TABLE order_position
(
    order_id           integer        not null references "order" (id),
    item_id            integer        not null references item (id),
    menu_id            integer        not null references menu (id),
    saved_price_netto  decimal(10, 2) not null,
    saved_price_brutto as saved_price_netto * (1 + saved_tax_rate),
    saved_tax_rate     decimal(5, 2)  not null,
    quantity           integer        not null,
    primary key (order_id, item_id, menu_id),
    foreign key (item_id, menu_id) references menu_position (item_id, menu_id)
);
go
