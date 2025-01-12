use walmart_db;
show tables;

select count(*) from walmarts;
select * from walmarts;
select distinct payment_method from walmarts;

# which pyament method is mostly used
select 
     payment_method , 
     count(*)
from walmarts
group by payment_method;


select branch, count(distinct Branch)
 from walmarts 
 group by branch;
 
select max(quantity) from walmarts; 

select min(quantity) from walmarts; 

# Main business problems
# 1 Find out the differenr payment methods and number of transaction, number of quantity sold

select 
     payment_method , 
     sum(quantity) as quantityPerPaymentMethod,
     count(*) as noOfPayment
from walmarts
group by payment_method;

#2 Which category received the highest average rating in each branch?

SELECT branch,
       category,
       avg(rating) as avg_rating
from walmarts 
group by branch,category 
order by  avg_rating desc;

#--- 2 query
SELECT branch,
       category,
       avg(rating) as avg_rating
from walmarts
group by branch,category 
order by branch, avg_rating desc;
       
 #--to get know top category of each branch in 2 query
 
SELECT branch,
       category,
       avg(rating) as avg_rating,
       rank() over (partition by branch order by avg(rating) desc) as ranks
from walmarts
group by branch,category 
order by branch, avg_rating desc;

#-- to get only data of category with rank 1 in each branch

select * from(

select branch, 
	   category, 
       avg(rating) as avg_rating,
       rank() over (partition by branch order by avg(rating) desc) as ranks
from walmarts
group by branch, category
) AS ranked
where ranks =1;


#3  What is the busiest day of the week for each branch based on transaction volume?
select dates from walmarts ;

SELECT dates,
      STR_TO_DATE(dates, '%d/%m/%y') AS formatted_date
FROM walmarts;

SELECT * 
FROM (
    SELECT branch,
           DAYNAME(STR_TO_DATE(dates, '%d/%m/%y')) AS day,
           COUNT(*) AS noOfTransaction,
           RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranks
    FROM walmarts
    GROUP BY branch, day
    ORDER BY branch, noOfTransaction
) AS rankss
WHERE ranks = 1;

#4 : How many items were sold through each payment method?
select payment_method,
       sum(quantity)
from walmarts group by payment_method;

#5What are the average, minimum, and maximum ratings for each category in each city? 
select category, city,
       avg(rating) as avg_rating,
       max(rating) as maximunRating,
       min(rating) as minimumRating,
       rank() over (partition by category order by city) as ranks
from walmarts
group by category, city;       
       

#6 What is the total profit for each category, ranked from highest to lowest?

select category,
       sum(profit_margin) as totalProfit
from walmarts
group by category
order by totalProfit desc;

#7 What is the most frequently used payment method in each branch?
select * from (
select payment_method,
       branch,
       count(payment_method) as pay,
       rank() over (partition by branch order by count(payment_method) desc) as ranks
from walmarts
group by branch, payment_method
order by branch ) as rankss
where ranks = 1;     


#or you can do like
with cte as(
select payment_method,
       branch,
       count(payment_method) as pay,
       rank() over (partition by branch order by count(payment_method) desc) as ranks
from walmarts
group by branch, payment_method
order by branch )

select * from cte where ranks =1;

#8 How many transactions occur in each shift (Morning, Afternoon, Evening)across branches?
ALTER TABLE walmarts
CHANGE COLUMN time times TIME;

select * from walmarts;

#Add the new column (for example, new_time of type TIME):
ALTER TABLE walmarts
ADD COLUMN new_time TIME;

#Copy the data from the existing time column into the new column new_time:
SET SQL_SAFE_UPDATES = 0;
UPDATE walmarts
SET new_time = times;

SET sql_mode = '';

select times,branch,
      CASE
      WHEN HOUR(times) >=6 AND HOUR(times)< 12 THEN 'Morning'
      WHEN HOUR(times) >= 12 AND HOUR(times) <18 THEN 'Afternoon'
      Else 'Evening'
 END AS new_time
FROM walmarts
GROUP BY branch, new_time;

#9  Which 5 branches experienced the largest decrease in ratio in revenue compared to he previous year?( current yr 2023 last yr 22)
WITH rec2022 AS (
    SELECT branch,
           ROUND(SUM(total),2) AS revenue
    FROM walmarts
    WHERE EXTRACT(YEAR FROM STR_TO_DATE(dates, '%d/%m/%y')) = 2022
    GROUP BY branch
),
rev2023 as (SELECT branch,
           ROUND(SUM(total),2) AS revenue
    FROM walmarts
    WHERE EXTRACT(YEAR FROM STR_TO_DATE(dates, '%d/%m/%y')) = 2023
    GROUP BY branch)
select ls.branch,
       ls.revenue as lsyrRev,
       cr.revenue as curryrRev,
       round(((ls.revenue - cr.revenue) / ls.revenue),2) * 100 AS revDecRatio
FROM rec2022 as ls
join 
rev2023 as cr
on ls.branch = cr.branch
where ls.revenue > cr.revenue
order by revDecRatio desc
limit 5;





       

