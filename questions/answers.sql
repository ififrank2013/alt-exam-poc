
-- ANSWERS TO QUESTION PART 2a

--- 1. The most ordered item based on the number of times it appears in an order cart that checked out successfully:
--  Creating a CTE table to filter and temporarily store successful checkouts so as to ensure that only successful orders are considered subsequently. 
WITH successful_orders AS (
  SELECT o.order_id, o.customer_id
  FROM ALT_SCHOOL.ORDERS o
  WHERE o.status = 'success' -- Filtering order status to identify successful orders
)
SELECT
  p.id AS product_id, -- Getting product_id
  p.name AS product_name, -- Getting product_name
  COUNT(*) AS num_times_in_successful_orders -- Evaluating the number of times each product appeared in the ALT_SCHOOL.PRODUCTS table in order to compare it with the successful orders
FROM ALT_SCHOOL.EVENTS e
INNER JOIN successful_orders s ON e.customer_id = s.customer_id -- Applying successful checkout filter to customers table in order to identify customers who had successful checkouts and payment.
INNER JOIN ALT_SCHOOL.ORDERS o ON s.order_id = o.order_id
INNER JOIN ALT_SCHOOL.LINE_ITEMS l ON o.order_id = l.order_id
INNER JOIN ALT_SCHOOL.PRODUCTS p ON l.item_id = p.id
WHERE e.event_data->>'event_type' = 'add_to_cart' -- Filtering by event_type in ALT_SCHOOL.EVENTS table in order to ensure that only items added to cart and successfully checkedout are considered.
GROUP BY p.id, p.name -- Grouping by product id and name in order to get unique rows for each product.
ORDER BY num_times_in_successful_orders DESC
LIMIT 1;



-- 2. Top 5 spenders without considering currency, and without using the line_item table:

-- Created a CTE table to filter and temporarily store successful order amounts so as to ensure that only the amounts spent on completed orders are calculated. 
WITH order_amounts AS (
  SELECT o.customer_id, o.status, SUM(p.price) AS order_amount
  FROM ALT_SCHOOL.ORDERS o
  -- Creating a join between orders, events and prodcuts table in order to establish the link between completed orders and prices of items
  INNER JOIN ALT_SCHOOL.EVENTS e ON o.customer_id = e.customer_id
  INNER JOIN ALT_SCHOOL.PRODUCTS p ON cast(e.event_data->>'item_id' as bigint) = p.id  -- Cast item_id to bigit to enable comparison of prodcut_id from the products table and item_id from the events table.
 -- Creating a filter to ensure that only completed (successful) orders are considered.
  WHERE o.status = 'success'
  GROUP BY o.customer_id, o.status
)
-- Now selecting the customer_ids, customer location and total amount spent based on the filtered successful orders.
SELECT
  c.customer_id,
  c.location,
  SUM(oa.order_amount) AS total_spend
FROM ALT_SCHOOL.CUSTOMERS c
INNER JOIN order_amounts oa ON c.customer_id = oa.customer_id
GROUP BY c.customer_id, c.location
ORDER BY total_spend DESC
LIMIT 5;





-- ANSWERS TO QUESTION PART 2b

-- 1. The most common location (country) where successful checkouts occurred:
-- Creating a CTE table to filter and temporarily store locations of the successful checkouts in order to ensure that only the locations of customers with successful checkouts are considered. 
with successful_locations AS (
SELECT
	c.location AS location,
	COUNT(*) AS checkout_count
	FROM ALT_SCHOOL.EVENTS e
	-- Joining the events and customers tables based on their common fields (customer_id) in order to get the location of customers with successful transactions
	INNER JOIN ALT_SCHOOL.CUSTOMERS c ON e.customer_id = c.customer_id
	WHERE e.event_data ->> 'event_type' = 'checkout' AND e.event_data ->> 'status' = 'success'
	GROUP BY c.location
)

select sl.location,
sl.checkout_count
from successful_locations sl
-- Applying a subquery to the where clause to filter for the location with the maximum successful checkout events.
where sl.checkout_count = (SELECT MAX(checkout_count) FROM successful_locations);




-- 2. Customers who abandoned their carts and number of events (excluding visits) that occurred before the abandonment:
-- Creating a CTE table to filter and temporarily store customers who abandoned their carts in order to ensure that only the carts abandoned  of customers with successful checkouts are considered. 
WITH abandoned_carts AS (
  SELECT
    customer_id,
    cast(event_data ->> 'timestamp' as timestamp) AS abandonment_timestamp
  FROM ALT_SCHOOL.EVENTS

  -- Ensuring that there are no checkout events subsequenty for the customer and validating that the events happened before the time of abandoning an event.
  WHERE  NOT EXISTS (
    SELECT 1
    FROM ALT_SCHOOL.EVENTS e2
    WHERE e2.customer_id = ALT_SCHOOL.EVENTS.customer_id
    AND e2.event_timestamp > ALT_SCHOOL.EVENTS.event_timestamp
    AND e2.event_data->>'event_type' = 'checkout'
  )
)

SELECT
  ac.customer_id,
  COUNT(*) AS num_events
FROM abandoned_carts ac
INNER JOIN ALT_SCHOOL.EVENTS e ON ac.customer_id = e.customer_id
WHERE e.event_data->>'event_type' <> 'visit'
  AND e.event_timestamp < ac.abandonment_timestamp -- Filtering by visits and timestamps to ensure that visits made before the abandondonement of order events are excluded. 
GROUP BY ac.customer_id
ORDER BY num_events desc;



-- 3. Average number of visits per customer, considering only customers who completed a checkout

-- Creating a CTE table to temporarily store total number of visits made by each customer. This was necessary in order to take into account all visits made by all customers before going further to select only those with successful checkouts. 
WITH all_visits AS (  
SELECT e.customer_id,
	count(*) as num_of_orders
  FROM ALT_SCHOOL.EVENTS e
	group by e.customer_id
)

SELECT a.customer_id,
		round(avg(a.num_of_orders), 2) as average_visits  -- Calculating average number of visits made by customers and rounding the result to 2 decimal places using the ROUND() function.
	from all_visits a
	inner join ALT_SCHOOL.EVENTS e on e.customer_id = a.customer_id
	where e.event_data ->>'status' = 'success' -- Limiting the average number of visits to only those who had successful checkouts from the events table. The events table was used here because it contains all user activities on the platform which shows user interaction on the applicstion.
	GROUP BY a.customer_id;












-- 



