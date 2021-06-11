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
