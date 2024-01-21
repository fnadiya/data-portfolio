select * from sales;
select * from menu;
select * from members;

/*count on each customer spend time*/
select count(customer_id) as cust_spend_time
from sales where customer_id='A';

select count(customer_id) as cust_spend_time
from sales where customer_id='B';

select count(customer_id) as cust_spend_time
from sales where customer_id='C';
---------------------------------------------
with spendTime as(
 select customer_id,
	count(customer_id) as cust_spend_time
 from sales group by customer_id)
 
select customer_id, cust_spend_time
from spendTime order by customer_id;


/*count on how many days each customer come to the resto*/
select count(distinct date(order_date)) as count_days
from sales where customer_id='A';

select count(distinct date(order_date)) as count_days
from sales where customer_id='B';

select count(distinct date(order_date)) as count_days
from sales where customer_id='C';
------------------------------------------------------
with spendDays as(
 select customer_id,
	count(distinct(order_date)) as spend_days
 from sales group by customer_id)
 
select customer_id, spend_days
from spendDays;


/*the first item from the menu purchased by each customer*/
select * from sales where customer_id='A' 
order by order_date asc limit 1;

select * from sales where customer_id='B' 
order by order_date asc limit 1;

select * from sales where customer_id='C' 
order by order_date asc limit 1;
------------------------------------------
with firstItem as(
 select customer_id, product_id,
	row_number() over(partition by customer_id order by order_date asc) as rank
 from sales)
 
select customer_id, product_id
from firstItem where rank = 1;


/*the most purchased item on the menu and how many times was it purchased by all cust*/
select product_id, count(product_id) as most_purchased from sales
group by product_id order by most_purchased desc limit 1;


/*item was the most popular for each customer*/
with rankedProducts as(
 select customer_id, product_id,
	row_number() over(partition by customer_id order by count(*) desc) as rank
 from sales
 group by customer_id, product_id)

select customer_id, product_id, count(*) as most_purchased 
from rankedProducts where rank = 1 group by customer_id, product_id;


/*item was purchased first by the customer after they became a member*/
