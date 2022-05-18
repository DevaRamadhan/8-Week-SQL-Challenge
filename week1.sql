-- Schema
CREATE DATABASE IF NOT EXISTS dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  -- query
  
  select * from members;
  select * from menu;
  select * from sales;
  -- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(m.price) as total_sales
from sales as s join menu as m on s.product_id = m.product_id
group by s.customer_id; 

-- 2. How many days has each customer visited the restaurant?
  select customer_id, count(distinct order_date) as visit_count from sales
  group by customer_id;
  
-- 3. What was the first item from the menu purchased by each customer?  
select s.customer_id, min(s.order_date) as first_order_date, m.product_name
from menu m
join sales s
on m.product_id = s.product_id
group by s.customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name, count(s.product_id) as most_purchased from
menu m join sales s on m.product_id = s.product_id
group by m.product_name
order by most_purchased desc
limit 1;
  
 -- 5. Which item was the most popular for each customer? 

select fav.customer_id, fav.product_name, fav.CO
from (
select s.customer_id, m.product_name, COUNT(m.product_id) as CO,
dense_rank() over(partition by s.customer_id order by count(s.customer_id) desc) as D_rank
from menu m join sales s on m.product_id = s.product_id
group by s.customer_id, m.product_name
) as fav
where D_rank = 1;

  -- 6. Which item was purchased first by the customer after they became a member?
select me.customer_id, m.product_name
from sales s join members me on s.customer_id = me.customer_id
join menu m on m.product_id = s.product_id
where s.order_date >= me.join_date
group by s.customer_id
order by s.customer_id;

-- 7. Which item was purchased just before the customer became a member?
select me.customer_id, m.product_name
from sales s join members me on s.customer_id = me.customer_id
join menu m on m.product_id = s.product_id
where s.order_date <= me.join_date
group by s.customer_id
order by s.customer_id; 

-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id, sum(m.price) as total_sales, count(distinct s.product_id) as total_product
from sales as s join menu as m
on s.product_id = m.product_id
join members me on s.customer_id = me.customer_id
where s.order_date < me.join_date
group by s.customer_id; 
  
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- how many points would each customer have?  
select s.customer_id, sum(Price_point.points) as total_point from
(select *, 
 case
  when product_id = 1 then price * 20
  else price * 10
  end as points
 from menu) as Price_point 
 join sales s on Price_point.product_id = s.product_id
 group by s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date)they earn 2x points
-- on all items, not just sushi - how many points do customer A and B have at the end of January?
select s.customer_id, sum(
if( s.order_date >= ms.join_date and s.order_date <= date_add(ms.join_date, interval 7 day), m.price*20, m.price*10)) as new_points 
from menu m join sales s on m.product_id = s.product_id
join members me on me.customer_id = s.customer_id
where order_date <= '2021-01-31'
group by customer_id;
  
  
  