
-- Create schema
CREATE SCHEMA IF NOT EXISTS ALT_SCHOOL;


-- create and populate tables

-- Create table ALT_SCHOOL.PRODUCTS
create table if not exists ALT_SCHOOL.PRODUCTS
(
    id  serial primary key,
    name varchar not null,
    price numeric(10, 2) not null
);

-- populating table ALT_SCHOOL.PRODUCTS with products data
COPY ALT_SCHOOL.PRODUCTS (id, name, price)
FROM '/data/products.csv' DELIMITER ',' CSV HEADER;



-- DDL statement to create table ALT_SCHOOL.CUSTOMERS
create table if not exists ALT_SCHOOL.CUSTOMERS
(
    customer_id uuid not null primary key,
    device_id uuid not null,
    location varchar not null,
    currency varchar not null
);

-- populating table ALT_SCHOOL.CUSTOMERS with customers data
COPY ALT_SCHOOL.CUSTOMERS (customer_id, device_id, location, currency)
FROM '/data/customers.csv' DELIMITER ',' CSV HEADER;



-- DDL statement to create table ALT_SCHOOL.ORDERS
create table if not exists ALT_SCHOOL.ORDERS
(
    order_id uuid not null primary key,
    customer_id uuid not null,
    status varchar not null,
    checked_out_at timestamp
);

-- populating table ALT_SCHOOL.ORDERS with orders data
COPY ALT_SCHOOL.ORDERS (order_id, customer_id, status, checked_out_at)
FROM '/data/orders.csv' DELIMITER ',' CSV HEADER;


-- DDL statement to create table ALT_SCHOOL.LINE_ITEMS
create table if not exists ALT_SCHOOL.LINE_ITEMS
(
    line_item_id serial primary key,
    order_id uuid not null,
    item_id bigint not null,
    quantity bigint not null
);

-- populating table ALT_SCHOOL.LINE_ITEMS with line_items data
COPY ALT_SCHOOL.LINE_ITEMS (line_item_id, order_id, item_id, quantity)
FROM '/data/line_items.csv' DELIMITER ',' CSV HEADER;


-- DDL statement to create table ALT_SCHOOL.EVENTS
create table if not exists ALT_SCHOOL.EVENTS
(
    event_id  serial primary key,
    customer_id uuid not null,
    event_data jsonb,
    event_timestamp timestamp
);

-- populating table ALT_SCHOOL.EVENTS with events data
COPY ALT_SCHOOL.EVENTS (event_id, customer_id, event_data, event_timestamp)
FROM '/data/events.csv' DELIMITER ',' CSV HEADER;







