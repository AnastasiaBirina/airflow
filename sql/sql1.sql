--SELECT table_name, column_name, data_type, character_maximum_length, column_default, is_nullable
--FROM information_schema.columns
--WHERE table_schema = 'public';


--SELECT DISTINCT json_array_elements(event_value::JSON->'product_payments')->>'product_name' AS product_name  
--from public.outbox
--where event_value::JSON->>'product_payments'  is not null
--;

CREATE TABLE public.bonussystem_users (
	id int4 NOT NULL,
	order_user_id text NOT NULL
);