
-- schema
CREATE DATABASE IF NOT EXISTS pizza_runner;
use pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  -- data check
  select * from customer_orders;
  select * from pizza_names;
  select * from pizza_recipes;
  select * from pizza_toppings;
  select * from runner_orders;
  
  -- data cleaning
update customer_orders
set extras=null
where extras='null' or '';

update customer_orders
set exclusions=null
where exclusions='null' or '';

update runner_orders
set pickup_time=null
where pickup_time='null' or '';

update runner_orders
set cancellation=null
where cancellation='null' or '';

update runner_orders
set distance=null
where distance='null' or '';

update runner_orders
set distance = convert(replace(trim(trailing 'km' from distance), ',' , '.'), dec(4,2)) ;

update runner_orders
set duration=null
where duration='null' or '';

update runner_orders
set duration = convert(replace(trim(trailing 'minutes' from duration), ',' , '.'), dec(4,2)) ;

-- Pizza Metrics

-- 1. How many pizzas were ordered?
select count(order_id) as Number_of_Order from customer_orders;

-- 2. How many unique customer orders were made?
select count(distinct order_id) as unique_customer_order from customer_orders;

-- 3. How many successful orders were delivered by each runner?
select runner_id, count(order_id) as successful_order from runner_orders
where distance is not null
group by runner_id;

-- 4. How many of each type of pizza was delivered?
select p.pizza_name, count(co.pizza_id) as pizza_delivered from
customer_orders co join pizza_names p on co.pizza_id = p.pizza_id
join runner_orders ro on co.order_id = ro.order_id
where ro.distance is not null
group by p.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
select co.customer_id, p.pizza_name, count(co.pizza_id) as pizza_delivered from
customer_orders co join pizza_names p on co.pizza_id = p.pizza_id
join runner_orders ro on co.order_id = ro.order_id
where ro.distance is not null
group by co.customer_id, p.pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?
select max(max_number_of_pizza) as pizza_count from(
select co.order_id, count(co.order_id) as max_number_of_pizza from
customer_orders co join runner_orders ro on co.order_id = ro.order_id
where ro.distance is not null
group by order_id) as piz;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select co.customer_id, sum(if (co.exclusions is null and co.extras is null, 1, 0 )) as no_changes, 
sum(if (co.exclusions is not null and co.extras is not null, 1, 0 )) as changes
from customer_orders co join runner_orders ro on co.order_id = ro.order_id
where ro.distance is not null
group by co.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
select co.customer_id, sum(if (co.exclusions is null and co.extras is null, 1, 0 )) as no_changes, 
sum(if (co.exclusions is not null and co.extras is not null, 1, 0 )) as changes
from customer_orders co join runner_orders ro on co.order_id = ro.order_id
where ro.distance is not null
group by co.customer_id
having no_changes > 0 and changes > 0;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
select hour(order_time) as hour_of_day, count(order_id) as number_of_order
from customer_orders
group by hour(order_time);

-- 10. What was the volume of orders for each day of the week?
select dayname(order_time) as day_ordered, count(order_id) as number_of_order
from customer_orders
group by dayname(order_time);

-- RUNNER AND CUSTOMER EXPERIENCE
-- 1. How many runners signed up for each 1 week period?
select week(registration_date) as registration_week, count(runner_id) as runner_signup
from runners
group by week(registration_date);

-- 2. What was the average time in minutes it took for each runner to
-- arrive at the Pizza Runner HQ to pickup the order?
select avg((minute(co.order_time)) - minute((ro.pickup_time))) from
customer_orders co join runner_orders ro on co.order_id = ro.order_id
where ro.distance is not null;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- Time to prepare is proportional with the number of pizzas ordered
select co.order_id, count(co.order_id), timestampdiff(minute, co.order_time, ro.pickup_time) as preparation_time
from customer_orders co join runner_orders ro on co.order_id = ro.order_id
where ro.distance is not null
group by co.order_id;

-- 4. What was the average distance travelled for each customer?
select co.customer_id, avg(ro.distance) as average_distance from
customer_orders co join runner_orders ro on co.order_id = ro.order_id
where ro.distance is not null
group by co.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
select (max(duration) - min(duration)) as delivery_time_diff from runner_orders
where duration is not null;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values
-- no
select runner_id, distance, (distance / duration) as avgspeed from runner_orders
where distance is not null
group by order_id;

-- 7. What is the successful delivery percentage for each runner?
select runner_id, (count(*) - count(cancellation))*100/(count(*)) as successfull_delivery
from runner_orders
group by runner_id; 

  select * from customer_orders;
  select * from pizza_names;
  select * from pizza_recipes;
  select * from pizza_toppings;
  select * from runner_orders;
  select * from runners;
