CREATE TABLE  IF NOT exists public.outbox (
	id int not null,
	object_id int not null,
	record_ts timestamp not null,
	type varchar not null,
	payload text not null

);

CREATE TABLE IF NOT EXISTS stg.srv_wf_settings (
    id int NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    workflow_key varchar NOT NULL UNIQUE,
    workflow_settings JSON NOT NULL
);

CREATE TABLE IF NOT EXISTS stg.bonussystem_users (
    id INTEGER NOT NULL PRIMARY KEY,
    order_user_id VARCHAR NOT NULL
);

--CREATE TABLE stg.bonussystem_ranks (
--	id int4 NOT null PRIMARY KEY,
--	"name" varchar(2048) NOT NULL,
--	bonus_percent numeric(19, 5) NOT NULL,
--	min_payment_threshold numeric(19, 5) NOT NULL
--);

CREATE TABLE IF NOT EXISTS stg.bonussystem_ranks (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR NOT NULL,
    bonus_percent NUMERIC(19, 5) DEFAULT 0 NOT NULL CHECK (bonus_percent >= 0),
    min_payment_threshold NUMERIC(19, 5) DEFAULT 0 NOT NULL CHECK (min_payment_threshold >= 0)
);

CREATE TABLE stg.bonussystem_events (
	id int4 NOT NULL ,
	event_ts timestamp NOT NULL,
	event_type varchar NOT NULL,
	event_value text NOT NULL,
	CONSTRAINT event_pkey PRIMARY KEY (id)
);


CREATE TABLE IF NOT EXISTS stg.ordersystem_restaurants (
    id int NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    object_id varchar NOT NULL UNIQUE,
    object_value text NOT NULL,
    update_ts timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS stg.ordersystem_users (
    id int NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    object_id varchar NOT NULL UNIQUE,
    object_value text NOT NULL,
    update_ts timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS stg.ordersystem_orders (
    id int NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    object_id varchar NOT NULL UNIQUE,
    object_value text NOT NULL,
    update_ts timestamp NOT NULL
);






--------------------------------------------------

--dds 1
CREATE TABLE IF NOT EXISTS dds.dm_users (
	id serial NOT null primary key,
	user_id varchar NOT NULL,
	user_name  varchar NOT NULL,
	user_login varchar NOT NULL
);
CREATE TABLE dds.srv_wf_settings (
	id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	workflow_key varchar NOT NULL,
	workflow_settings json NOT NULL,
	CONSTRAINT srv_wf_settings_pkey PRIMARY KEY (id),
	CONSTRAINT srv_wf_settings_workflow_key_key UNIQUE (workflow_key)
);
CREATE TABLE IF NOT EXISTS dds.dm_restaurants (
	id serial NOT null primary key,
	restaurant_id varchar NOT NULL,
	restaurant_name  varchar NOT NULL,
	active_from timestamp NOT null,
	active_to timestamp not null
);

--CREATE TABLE stg.bonussystem_users (
--	id int4 NOT NULL,
--	order_user_id text NOT NULL,
--	CONSTRAINT users_pkey PRIMARY KEY (id)
--);
--
-- 
--CREATE TABLE stg.bonussystem_ranks (
--	id int4 NOT NULL,
--	"name" varchar(2048) NOT NULL,
--	bonus_percent numeric(19, 5) NOT NULL,
--	min_payment_threshold numeric(19, 5) NOT NULL
--);
--
--CREATE TABLE stg.bonussystem_events (
--	id int4 NOT NULL,
--	event_ts timestamp NOT NULL,
--	event_type varchar NOT NULL,
--	event_value text NOT NULL
--);
--CREATE INDEX idx_bonussystem_events__event_ts ON stg.bonussystem_events USING btree (event_ts);



--drop table cdm.dm_settlement_report

-- cdm.dm_settlement_report definition

-- Drop table

-- DROP TABLE cdm.dm_settlement_report;

CREATE TABLE cdm.dm_settlement_report (
	id serial4 NOT NULL,
	restaurant_id varchar(100) NOT NULL,
	restaurant_name varchar(100) NOT NULL,
	settlement_date date NOT NULL,
	orders_count int4 NOT NULL,
	orders_total_sum numeric(14, 2) NOT NULL,
	orders_bonus_payment_sum numeric(14, 2) NOT NULL,
	orders_bonus_granted_sum numeric(14, 2) NOT NULL,
	order_processing_fee numeric(14, 2) NOT NULL,
	restaurant_reward_sum numeric(14, 2) NOT NULL,
	CONSTRAINT dm_settlement_report_order_processing_fee_check CHECK ((order_processing_fee >= (0)::numeric)),
	CONSTRAINT dm_settlement_report_orders_bonus_granted_sum_check CHECK ((orders_bonus_granted_sum >= (0)::numeric)),
	CONSTRAINT dm_settlement_report_orders_bonus_payment_sum_check CHECK ((orders_bonus_payment_sum >= (0)::numeric)),
	CONSTRAINT dm_settlement_report_orders_count_check CHECK ((orders_count >= 0)),
	CONSTRAINT dm_settlement_report_orders_total_sumcheck CHECK ((orders_total_sum >= (0)::numeric)),
	CONSTRAINT dm_settlement_report_restaurant_reward_sum_check CHECK ((restaurant_reward_sum >= (0)::numeric)),
	CONSTRAINT pk_dm_settlement_report PRIMARY KEY (id),
	CONSTRAINT unique_restaurant_id UNIQUE (restaurant_id, settlement_date)
);



CREATE TABLE dds.dm_products (
	id serial NOT null primary key,
	restaurant_id integer NOT NULL,
	product_id varchar NOT NULL,
	product_name  varchar NOT NULL,
	product_price  NUMERIC(14,2) DEFAULT 0.00 CHECK(product_price >= 0) NOT null,
	active_from  timestamp NOT null,
	active_to timestamp NOT null
);

ALTER TABLE dds.dm_products
ADD CONSTRAINT dm_products_restaurant_id_fkey
FOREIGN KEY (restaurant_id)
REFERENCES dds.dm_restaurants(id);

CREATE TABLE dds.dm_timestamps (
	id serial NOT null primary key,
	ts timestamp NOT null,
	year smallint CHECK(year >= 2022 and year < 2500) NOT null,
	month smallint CHECK(month >= 1 and month <= 12) NOT null,
	day smallint CHECK(day >= 1 and day <= 31) NOT null,
	time  time NOT null,
	date date NOT null
);
CREATE TABLE dds.dm_orders (
	id serial NOT null primary key,
	restaurant_id integer NOT NULL,
	user_id  integer NOT NULL,
	timestamp_id  integer  NOT NULL,
	order_key  varchar NOT null,
	order_status  varchar NOT null
); 


ALTER TABLE dds.dm_orders
ADD CONSTRAINT dm_orders_restaurant_id_fkey
FOREIGN KEY (restaurant_id)
REFERENCES dds.dm_restaurants(id);

ALTER TABLE dds.dm_orders
ADD CONSTRAINT dm_orders_timestamp_id_fkey
FOREIGN KEY (timestamp_id)
REFERENCES dds.dm_timestamps(id);

ALTER TABLE dds.dm_orders
ADD CONSTRAINT dm_orders_user_id_fkey
FOREIGN KEY (user_id)
REFERENCES dds.dm_users(id);


CREATE TABLE dds.fct_product_sales (
	id serial NOT null primary key,
	product_id integer NOT NULL,
	order_id integer NOT NULL,
	count integer DEFAULT 0 NOT NULL,
	price numeric(14, 2) DEFAULT 0 NOT NULL,
	total_sum numeric(14, 2) DEFAULT 0 NOT NULL,
	bonus_payment numeric(14, 2) DEFAULT 0 NOT NULL,
	bonus_grant numeric(14, 2) DEFAULT 0 NOT NULL,
	CONSTRAINT fct_product_sales_count_check CHECK (count >= 0),
	CONSTRAINT fct_product_sales_price_check CHECK (price >= (0)::numeric),
	CONSTRAINT fct_product_sales_total_sum_check CHECK (total_sum >= (0)::numeric),
	CONSTRAINT fct_product_sales_bonus_payment_check CHECK (bonus_payment >= (0)::numeric),
	CONSTRAINT fct_product_sales_bonus_grant_check CHECK (bonus_grant >= (0)::numeric)
); 


ALTER TABLE dds.fct_product_sales
ADD CONSTRAINT fct_product_sales_product_id_fkey
FOREIGN KEY (product_id)
REFERENCES dds.dm_products(id);

ALTER TABLE dds.fct_product_sales
ADD CONSTRAINT fct_product_sales_order_id_fkey
FOREIGN KEY (order_id)
REFERENCES dds.dm_orders(id);

--CREATE TABLE stg.ordersystem_orders (
--	id serial NOT NULL,
--	object_id varchar NOT NULL,
--	object_value text NOT NULL,
--	update_ts timestamp NOT NULL
--);
--CREATE TABLE stg.ordersystem_restaurants (
--	id serial NOT NULL,
--	object_id varchar NOT NULL,
--	object_value text NOT NULL,
--	update_ts timestamp NOT NULL
--);
--
--ALTER TABLE stg.ordersystem_users ADD CONSTRAINT ordersystem_users_object_id_uindex UNIQUE (object_id);
--ALTER TABLE stg.ordersystem_orders ADD CONSTRAINT ordersystem_orders_object_id_uindex UNIQUE (object_id);
--ALTER TABLE stg.ordersystem_restaurants ADD CONSTRAINT ordersystem_restaurants_object_id_uindex UNIQUE (object_id);

