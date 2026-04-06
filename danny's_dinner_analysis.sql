/*Total amount each customer spent*/
SELECT sales.customer_id,sum(menu.price) AS total_spent 
FROM sales
JOIN  menu ON sales.product_id=menu.product_id
GROUP BY sales.customer_id;

/*Number of days each customer visited*/
SELECT customer_id,count(DISTINCT order_date) AS visit_days 
FROM sales
GROUP BY customer_id;

/*First item purchased by each customer*/
WITH nit AS ( 
SELECT s.customer_id,m.product_name,s.order_date,
row_number() over(partition by s.customer_id order by s.order_date)as rn 
FROM sales s 
JOIN menu m ON s.product_id=m.product_id
) 
SELECT * 
FROM nit WHERE rn=1;

/*Most purschased item overall*/
select m.product_name,count(*) as most_purchased_item 
from sales s 
join menu m on s.product_id=m.product_id 
group by m.product_name
order by count(*) desc
limit 1;

/*Most popular item for each*/
select customer_id,product_name,purchase_count from
(select s.customer_id,m.product_name,
count(*) as purchase_count,rank() over(partition by s.customer_id order by count(*) desc) as rnk
from sales s 
join menu m on s.product_id=m.product_id
 group by s.customer_id,m.product_name) t where rnk=1;
 
 /*First item purchased after becoming a member*/
 select customer_id,product_name from
 (select s.customer_id,m.product_name,s.order_date,rank() over(partition by s.customer_id order by s.order_date)as rnk
 from sales s 
 join menu m on s.product_id=m.product_id join members mem on s.customer_id=mem.customer_id 
 where s.order_date>=mem.join_date) t
 where rnk=1;
 
 /*Item purchased before becoming member*/
select customer_id,product_name from
 (select s.customer_id,m.product_name,s.order_date,row_number() over(partition by s.customer_id order by s.order_date desc)as rnk
 from sales s 
 join menu m on s.product_id=m.product_id join members mem on s.customer_id=mem.customer_id 
 where s.order_date < mem.join_date) t
 where rnk=1;
 
 /*Total items and amount spent before membership*/
 SELECT s.customer_id,
       COUNT(*) AS total_items,
       SUM(m.price) AS total_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;

/*Points calculation*/
SELECT s.customer_id,(select product_name from menu where product_name='sushi'),
Sum(
 CASE 
 WHEN m.product_name = 'sushi' THEN m.price * 20
	ELSE m.price * 10
END) AS points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

/*Points with first week bonus*/
SELECT s.customer_id,mem.join_date,
SUM(
 CASE 
  WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY)
	THEN m.price * 20
   WHEN m.product_name = 'sushi'
	THEN m.price * 20
ELSE m.price * 10
	END) AS points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id,mem.join_date;


 /*if customer ordered sushi increase price by 30% else increase 50% for other items*/
 select customer_id,sum(
 case when product_name='sushi' then price * 1.30 
else price*1.50 end) as points from sales 
 JOIN menu ON sales.product_id = menu.product_id
 group by customer_id;
 
  