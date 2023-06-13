CREATE TABLE public.outbox (
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

CREATE TABLE stg.bonussystem_ranks (
	id int4 NOT null PRIMARY KEY,
	"name" varchar(2048) NOT NULL,
	bonus_percent numeric(19, 5) NOT NULL,
	min_payment_threshold numeric(19, 5) NOT NULL
);