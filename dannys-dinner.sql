SELECT * FROM sales;
SELECT * FROM menu;
SELECT * FROM members;

--count on each customer spend time
WITH spendTime AS(
	SELECT
		customer_id,
		COUNT(customer_id) AS cust_spend_time
	FROM sales GROUP BY customer_id
)
SELECT
	customer_id,
	cust_spend_time
FROM spendTime
ORDER BY customer_id;


--count on how many days each customer come to the resto
WITH spendDays AS(
	SELECT
		customer_id,
		COUNT(DISTINCT(order_date)) AS spend_days
 	FROM sales
		GROUP BY customer_id
) 
SELECT
	customer_id,
	spend_days
FROM spendDays;


--the first item from the menu purchased by each customer
WITH firstItem AS(
	SELECT
		customer_id,
		product_id,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date ASC) AS rank
	FROM sales
)
SELECT
	customer_id,
	product_id
FROM firstItem
WHERE rank = 1;


--the most purchased item on the menu and how many times was it purchased by all cust
SELECT
	product_id,
	COUNT(product_id) AS most_purchased
FROM sales
GROUP BY product_id
ORDER BY most_purchased DESC LIMIT 1;


--item was the most popular for each customer
WITH rankedProducts AS(
	SELECT 
		customer_id,
		product_id,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS rank
	FROM sales
 	GROUP BY customer_id, product_id
)
SELECT
	customer_id,
	product_id,
	count(*) as most_purchased 
FROM rankedProducts
WHERE rank = 1
GROUP BY customer_id, product_id;


-- Item was purchased first by the customer after they became a member
--show all data
WITH firstPurchased AS(
	SELECT
		sales.customer_id,
		sales.order_date,
		members.join_date,
		sales.product_id,
		ROW_NUMBER() OVER (PARTITION BY sales.order_date ORDER BY members.join_date)AS rnk
	FROM sales
	INNER JOIN members
 	ON sales.customer_id = members.customer_id
	WHERE sales.order_date > members.join_date
)
SELECT
	customer_id, order_date, join_date, product_id
FROM firstPurchased WHERE rnk=1;

--counted result
WITH afterPurchase AS(
	SELECT
		sales.customer_id,
		sales.order_date,
		members.join_date,
		sales.product_id
	FROM
		sales INNER JOIN members 
		ON sales.customer_id = members.customer_id
		LEFT JOIN menu ON sales.product_id = menu.product_id
	WHERE order_date > join_date ORDER BY customer_id
)
SELECT
	customer_id,
	COUNT (*) AS total
FROM afterPurchase GROUP BY customer_id ORDER BY customer_id;


--item was purchased just before the customer became a member*/
WITH afterPurchase AS(
	SELECT
		sales.customer_id,
		sales.order_date,
		members.join_date,
		sales.product_id
	FROM
		sales INNER JOIN members 
		ON sales.customer_id = members.customer_id
		LEFT JOIN menu ON sales.product_id = menu.product_id
	WHERE order_date < join_date ORDER BY customer_id
)
SELECT
	customer_id,
	COUNT (*) AS total
FROM afterPurchase
GROUP BY customer_id
ORDER BY customer_id;


--the total items and amount spent for each member before they became a member*/
WITH beforePurchase AS(
	SELECT
		sales.customer_id,
		sales.order_date,
		members.join_date,
		sales.product_id
	FROM
		sales INNER JOIN members 
		ON sales.customer_id = members.customer_id
		LEFT JOIN menu ON sales.product_id = menu.product_id
	WHERE order_date < join_date ORDER BY customer_id
)
SELECT
	customer_id,
	COUNT (*) AS total
FROM beforePurchase GROUP BY customer_id ORDER BY customer_id;
	

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier how many points would each customer have
WITH totalPoints AS(
	SELECT
		sales.customer_id,
		sales.product_id,
		menu.product_name,
		sales.product_id * menu.price as total
	FROM
		sales 
		INNER JOIN menu
		ON sales.product_id = menu.product_id
		ORDER BY sales.customer_id
)
SELECT
	customer_id,
	SUM(CASE WHEN product_name ='sushi' THEN total * 20 ELSE total * 10 END) AS points
FROM totalPoints
GROUP BY customer_id;
