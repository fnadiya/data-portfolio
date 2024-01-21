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
select distinct order_date, product_id, customer_id from sales order by customer_id;

select * from sales inner join members
on sales.customer_id = members.customer_id;

select product_id, order_date, join_date from sales inner join members
on sales.customer_id = members.customer_id;

select sales.order_date, members.join_date, sales.customer_id, sales.product_id,
from sales inner join members
on sales.customer_id = members.customer_id;

select sales.customer_id, sales.order_date, members.join_date, sales.product_id
from sales inner join members
on sales.customer_id = members.customer_id
where order_date > join_date and first;

/* this one*/
with firstPurchased as(
 select sales.customer_id, sales.order_date, members.join_date, sales.product_id,
	row_number() over (partition by sales.order_date order by members.join_date) as rnk
 from sales inner join members
 on sales.customer_id = members.customer_id
 where sales.order_date > members.join_date
)

select customer_id, order_date, join_date, product_id
from firstPurchased where rnk=1;

---count table
with afterPurchase as(
	select
		sales.customer_id,
		sales.order_date,
		members.join_date,
		sales.product_id
	from
		sales inner join members 
		on sales.customer_id = members.customer_id
		left join menu on sales.product_id = menu.product_id
	where order_date > join_date order by customer_id
)
select
	customer_id,
	count (*) as total
from afterPurchase group by customer_id order by customer_id;

---------------------------this one
select sales.customer_id, sales.order_date, members.join_date, sales.product_id
from sales inner join members
on sales.customer_id = members.customer_id
where order_date > join_date;

/*item was purchased just before the customer became a member*/

select sales.customer_id, sales.order_date, members.join_date, sales.product_id
from sales inner join members
on sales.customer_id = members.customer_id
where sales.order_date < members.join_date;

with afterPurchase as(
	select
		sales.customer_id,
		sales.order_date,
		members.join_date,
		sales.product_id
	from
		sales inner join members 
		on sales.customer_id = members.customer_id
		left join menu on sales.product_id = menu.product_id
	where order_date < join_date order by customer_id
)
select
	customer_id,
	count (*) as total
from afterPurchase group by customer_id order by customer_id;


/*the total items and amount spent for each member before they became a member*/
select sales.customer_id, sales.order_date, members.join_date, sales.product_id
from sales inner join members 
on sales.customer_id = members.customer_id
left join menu on sales.product_id = menu.product_id
where order_date < join_date order by customer_id;

------------------------this one
with beforePurchase as(
	select
		sales.customer_id,
		sales.order_date,
		members.join_date,
		sales.product_id
	from
		sales inner join members 
		on sales.customer_id = members.customer_id
		left join menu on sales.product_id = menu.product_id
	where order_date < join_date order by customer_id
)
select
	customer_id,
	count (*) as total
from beforePurchase group by customer_id order by customer_id;
	

/*If each $1 spent equates to 10 points and sushi has a 2x points multiplier
how many points would each customer have*/
select
	sales.customer_id,
	sales.product_id,
	menu.price, 
	count(sales.product_id*menu.price) as total
from
	sales left join menu
	on sales.product_id = menu.product_id;
	
--------------------------------this one

with totalPoints as(
	select
		sales.customer_id,
		sales.product_id,
		menu.product_name,
		sales.product_id * menu.price as total
	from
		sales 
		inner join menu
		on sales.product_id = menu.product_id
		order by sales.customer_id
)
select
	customer_id,
	sum(case when product_name ='sushi' then total * 20 else total * 10 end) as points
from totalPoints group by customer_id;
