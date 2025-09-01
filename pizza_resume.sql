CREATE database pizza_sales;


CREATE TABLE order_details(
       order_details_id	 INT	PRIMARY KEY,
       order_id	 INT,	
       pizza_id	 VARCHAR(50),	
       quantity	 INT	
)


CREATE TABLE orders(
       order_id	INT	PRIMARY KEY,
       date	 DATE,	
       time	 TIME	
)


CREATE TABLE pizza_types(
       	pizza_type_id	VARCHAR(25),
        name	VARCHAR(50),
        category	VARCHAR(20),
        ingredients	VARCHAR(100)	
)


CREATE TABLE pizzas(
       pizza_id	 VARCHAR(20),
       pizza_type_id	VARCHAR(20),
       size 	VARCHAR(20),
       price	NUMERIC(5,2)	
)


SELECT * FROM order_details;

SELECT * FROM orders;

SELECT * FROM pizza_types;

SELECT * FROM pizzas;


-- 1.	Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS Total_orders
FROM orders;


-- 2.	Calculate the total revenue generated from pizza sales.

SELECT SUM(o.quantity * p.price) AS total_revenue
FROM order_details  o
JOIN pizzas p
ON o.pizza_id = p.pizza_id;


-- 3.	Identify the highest-priced pizza.

SELECT p.name , pi.price 
FROM pizza_types p
JOIN pizzas pi
ON p.pizza_type_id = pi.pizza_type_id
ORDER BY pi.price DESC LIMIT 1;


-- 4.	Identify the most common pizza size ordered.

SELECT p.size, COUNT(o.quantity) AS order_pizza
FROM pizzas p
JOIN order_details o
ON p.pizza_id = o.pizza_id
GROUP BY p.size 
order by order_pizza DESC
LIMIT 1;


-- 5.	List the top 5 most ordered pizza types along with their quantities.

SELECT p.name, SUM(o.quantity) AS order_quantity
FROM pizza_types p
JOIN pizzas pi
ON p.pizza_type_id = pi.pizza_type_id
JOIN order_details o
ON pi.pizza_id = o.pizza_id
GROUP BY p.name 
order by order_quantity DESC
LIMIT 5;


-- 6.	Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT p.category, SUM(o.quantity)  AS total_quantity
FROM pizza_types  p
JOIN pizzas a 
ON p.pizza_type_id = a.pizza_type_id
JOIN order_details o 
ON a.pizza_id = o.pizza_id
GROUP BY p.category;


-- 7.	Determine the distribution of orders by hour of the day.

SELECT EXTRACT(HOUR FROM time) AS HOURS, COUNT(order_id) AS orders
FROM orders 
GROUP BY HOURS
ORDER BY HOURS;


-- 8.	Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, COUNT(name) AS variety_of_pizzas
FROM pizza_types
GROUP BY category
ORDER BY category;

-- 9.	Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(per_day_order),2)  AS PerDayOrder FROM
(SELECT o.date, SUM(od.quantity) AS per_day_order
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
GROUP BY o.date
ORDER BY o.date);


-- 10.	Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name, SUM(od.quantity * p.price ) AS revenue
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name 
ORDER BY revenue DESC 
LIMIT 3;


-- 11.	Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.name, CONCAT(ROUND(SUM(od.quantity * p.price ) * 100/
                       (SELECT  SUM(od.quantity * p.price ) AS total_revenue 
					            FROM order_details od
                                JOIN pizzas p
                                ON od.pizza_id = p.pizza_id),2), '%') AS revenue
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC;

-- 12.	Analyze the cumulative revenue generated over time.

SELECT date, SUM(revenue) OVER(ORDER BY date) AS cumulative_revenue
FROM
(SELECT o.date, SUM(od.quantity * p.price) AS revenue
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
JOIN pizzas p
ON p.pizza_id = od.pizza_id
GROUP BY o.date);


-- 13.	Determine the top 3 most ordered pizza types based on revenue for each pizza category

SELECT category , name , revenue , RANK
FROM
(SELECT category , name , revenue , 
RANK() OVER(PARTITION BY category ORDER BY revenue)
FROM
(SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
FROM pizza_types pt
JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON p.pizza_id = od.pizza_id
GROUP BY pt.category, pt.name))
WHERE RANK <= 3;
