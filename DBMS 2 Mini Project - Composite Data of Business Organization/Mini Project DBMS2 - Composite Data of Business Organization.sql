############################## SQL II - Mini Project ##############################
/*
Composite data of a business organisation, confined to ‘sales and delivery’ domain is given for the period of last decade. From the given data retrieve solutions for the given scenario.*/

-- 1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

/* create table combined_table as (select * from market_fact join cust_dimen using(cust_id) join orders_dimen using(ord_id) join prod_dimen using(prod_id) join (select Ship_Mode,Ship_Date , Ship_id from shipping_dimen) t using (ship_id));

drop table combined_table;

select * from market_fact join orders_dimen using (ord_id) join cust; */


create table combined_table as select mf.*,cd.Customer_Name,cd.Province,cd.Region,cd.Customer_segment,od.Order_ID Order_ID_od,od.Order_Date,od.Order_Priority,pd.product_Category,pd.Product_Sub_category,sd.Order_ID Order_ID_sd,sd.Ship_Mode,sd.Ship_Date from market_fact mf inner join cust_dimen cd on mf.Cust_id=cd.Cust_id inner join orders_dimen od on mf.Ord_id=od.Ord_id inner join prod_dimen pd on mf.Prod_id=pd.Prod_id inner join shipping_dimen sd on mf.Ship_id=sd.Ship_id order by mf.order_quantity desc;


-- 2. Find the top 3 customers who have the maximum number of orders

select customer_name , sum(order_quantity) as orders from combined_table group by cust_id order by orders desc limit 3;

select customer_name , sum(order_quantity) as orders from market_fact a join cust_dimen using(cust_id) group by cust_id order by orders desc limit 3;

-- 3. Create a new column DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.

select * from combined_table;
alter table combined_table add column DaysTakenForDelivery int ;
update combined_table set Daystakenfordelivery = str_to_date(ship_date, '%d-%m-%YYYY') - str_to_date(order_date, '%d-%m-%YYYY'); 

-- 4. Find the customer whose order took the maximum time to get delivered.

select customer_name , daystakenfordelivery from combined_table where DaysTakenForDelivery = (select max(DaysTakenForDelivery) from combined_table);


-- 5. Retrieve total sales made by each product from the data (use Windows function)
select prod_id , round(sum(sales) over(order by sales desc),2) total_sales from market_fact group by prod_id;


-- 6. Retrieve total profit made from each product from the data (use windows function)
select prod_id , round(avg(profit) over(order by profit desc),2) profit_prod from market_fact group by prod_id;


-- 7. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

select count( distinct customer_name) from combined_table where month(str_to_date(order_date, "%d-%m-%YYYY")) = 1;

select count( distinct customer_name) from combined_table where year(str_to_date(order_date, "%d-%m-%YYYY")) = 2011 and month(str_to_date(order_date, "%d-%m-%YYYY")) <> 1  and customer_name in (select distinct customer_name from combined_table where month(str_to_date(order_date, "%d-%m-%YYYY")) = 1);


-- 8. Retrieve month-by-month customer retention rate since the start of the business.(using views)
/*
Tips:
# 1: Create a view where each user’s visits are logged by month, allowing for the possibility that these will have occurred over multiple years since whenever
	business started operations
# 2: Identify the time lapse between each visit. So, for each person and for each month, we see when the next visit is.
# 3: Calculate the time gaps between visits
# 4: categorise the customer with time gap 1 as retained, >1 as irregular and NULL as churned
# 5: calculate the retention month wise*/

select cust_id , date_format(str_to_date(order_date, '%d-%m-%YYYY'), '%d-%m-%Y') visit_date , str_to_date(order_date, '%d-%m-%YYYY') - lag(str_to_date(order_date, '%d-%m-%YYYY')) over(partition by cust_id) as diff_btwn_visits  from orders_dimen a join market_fact b using(ord_id) order by cust_id,visit_date;

select * from orders_dimen;
select * from cust_dimen;
select * from market_fact;
select * from combined_table;

/*
select * , visit_date - lag(visit_date) over(partition by cust_id) from

(select cust_id , date_format(str_to_date(order_date, '%d-%m-%YYYY'), '%d-%m-%Y') visit_date  from orders_dimen a join market_fact b using(ord_id) order by cust_id,visit_date) t; 


select *,floor((visit_date - lag_date)/24) from (select * , lag(visit_date) over(partition by Cust_id order by visit_date) lag_date from

(select cust_id , str_to_date(order_date, '%d-%m-%YYYY') visit_date from orders_dimen a join market_fact b using(ord_id) order by cust_id,visit_date) t)tt; 



select *,period_diff(visit_date,lag_date) Period_diff_ from (select * , lag(visit_date) over(partition by Cust_id order by visit_date) lag_date from

(select cust_id , date_format(str_to_date(order_date, '%d-%m-%YYYY'),"%Y%M") visit_date from orders_dimen a join market_fact b using(ord_id) order by cust_id,visit_date) t)tt; */
/*
select * , if( period_diff_ = 1 , "Retained" , if( period_diff_ is null , "Churned" , "Irregular" )) from
(select *,period_diff(visit_date,lag_date) Period_diff_ from (select * , lag(visit_date) over(partition by Cust_id order by visit_date) lag_date from

(select cust_id , date_format(str_to_date(order_date, '%d-%m-%YYYY'),"%Y%M") visit_date from orders_dimen a join market_fact b using(ord_id) order by cust_id,visit_date) t)tt)ttt; 




select count(distinct cust_id) , date_format(str_to_date(order_date, '%d-%m-%YYYY'),"%Y-%m") month_year from orders_dimen  a join market_fact b using(ord_id) group by month_year order by month_year;
#(select distinct cust_id from orders_dimen  a join market_fact b using(ord_id) where month(str_to_date(order_date, '%d-%m-%YYYY') < month(str_to_date(order_date, '%d-%m-%YYYY');

select distinct cust_id , month(order_date) from temp */