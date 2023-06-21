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

CREATE TABLE dds.srv_wf_settings (
	id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	workflow_key varchar NOT NULL,
	workflow_settings json NOT NULL,
	CONSTRAINT srv_wf_settings_pkey PRIMARY KEY (id),
	CONSTRAINT srv_wf_settings_workflow_key_key UNIQUE (workflow_key)
);
