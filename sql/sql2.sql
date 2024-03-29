--COPY dds.dm_restaurants (id, restaurant_id, restaurant_name, active_from, active_to) FROM '/data/dm_restaurants_';
--COPY dds.dm_products (id, restaurant_id, product_id, product_name, product_price, active_from, active_to) FROM '/data/dm_products_';
--COPY dds.dm_timestamps (id, ts, year, month, day, "time", date) FROM '/data/dm_timestamps_';
--COPY dds.dm_users (id, user_id, user_name, user_login) FROM '/data/dm_users_';
--COPY dds.dm_orders (id, order_key, order_status, restaurant_id, timestamp_id, user_id) FROM '/data/dm_orders_';
--COPY dds.fct_product_sales (id, product_id, order_id, count, price, total_sum, bonus_payment, bonus_grant) FROM '/data/fct_product_sales_'; 

insert into cdm.dm_settlement_report (restaurant_id, restaurant_name, settlement_date, orders_count, orders_total_sum, orders_bonus_payment_sum, orders_bonus_granted_sum, order_processing_fee, restaurant_reward_sum)
select  r.id as restaurant_id, 
		r.restaurant_name, 
		d.date as settlement_date, 
		count(distinct s.order_id) as orders_count, 
		sum(s.total_sum) as orders_total_sum, 
		sum(s.bonus_payment) as orders_bonus_payment_sum, 
		sum(s.bonus_grant) as orders_bonus_granted_sum, 
		sum(s.total_sum * 0.25) as order_processing_fee, 
		sum(s.total_sum - s.total_sum * 0.25 - s.bonus_payment) as restaurant_reward_sum
from dds.dm_restaurants r 
	inner join dds.dm_orders o on r.id = o.restaurant_id 
	inner join dds.fct_product_sales s on s.order_id = o.id 
	inner join dds.dm_timestamps d on d.id = o.timestamp_id 
where r.active_to > now() and o.order_status = 'CLOSED'
group by  r.id, r.restaurant_name, d.date
ON CONFLICT (restaurant_id, settlement_date) 
DO UPDATE 
SET
    orders_count = EXCLUDED.orders_count,
    orders_total_sum = EXCLUDED.orders_total_sum,
    orders_bonus_payment_sum = EXCLUDED.orders_bonus_payment_sum,
    orders_bonus_granted_sum = EXCLUDED.orders_bonus_granted_sum,
    order_processing_fee = EXCLUDED.order_processing_fee,
    restaurant_reward_sum = EXCLUDED.restaurant_reward_sum;

   DELETE FROM dds.dm_products;
DELETE FROM dds.dm_orders;
DELETE FROM dds.dm_users;
DELETE FROM dds.dm_timestamps;
DELETE FROM dds.dm_restaurants cascade;
DELETE FROM dds.fct_product_sales;
DELETE FROM cdm.dm_settlement_report; 