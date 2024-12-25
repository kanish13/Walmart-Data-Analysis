create database if not exists WalmartDataAnalysis;

create table if not exists  sale(

invoice_id varchar(30) not null primary key,
branch varchar(10) not null,
city varchar (30) not null,
curstomer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10,2) not null,
quantity int not null,
vat decimal (6,4) not null,
total decimal(12,4) not null,
date datetime not null,
time time not null,
payment_method varchar(15) not null,
cogs decimal(10,2) not null,
gross_margin_pct decimal(11,9),
gross_income decimal(12,4) not null,
rating decimal(2,1)
);



-- -------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------- FEATURE ENGINEERING --------------------------------------------------------------

-- TIME OF DAY

select time,
case 
when time >='10:00:00' and time<'12:00:00' then 'Morning'
when time>='12:00:00' and time<'17:00:00' then 'Afternoon'
else 'Evening'
end as time_of_day
 from sale;

alter table sale add column time_of_day varchar(20) after time;

SET SQL_SAFE_UPDATES = 0;
update sale
set time_of_day=(select
case 
when time >='10:00:00' and time<'12:00:00' then 'Morning'
when time>='12:00:00' and time<'17:00:00' then 'Afternoon'
else 'Evening'
end
);
SET SQL_SAFE_UPDATES = 1;

-- DAY NAME
select date,dayname(date) as "day name" from sale;

alter table sale
add column day_name varchar(20) after date;

SET SQL_SAFE_UPDATES = 0;
update sale 
set day_name=dayname(date);
SET SQL_SAFE_UPDATES = 1;

-- MONTH NAME

select monthname(date) from sale;

alter table sale
add column month_name varchar(20) after date;

SET SQL_SAFE_UPDATES = 0;
update sale
set month_name=monthname(date);
SET SQL_SAFE_UPDATES = 1;

-- ------------------------------------------------------------------------------------------------------------------------------------------

-- -------------------------------------------------------- EXPLORATORY DATA ANALYSIS --------------------------------------------------------------

-- A) GENERIC QUERIES

-- i) How many unique cities does the data have?

select distinct city from sale;

-- ii) In which city is each branch?

select distinct city, branch from sale ;

-- B) PRODUCT QUERIES

-- i) How many unique product lines does the data have?

select distinct product_line from sale;

-- ii) What is the most common payment method? 

select payment_method, count(payment_method) as no_of_people from sale group by payment_method order by no_of_people desc;

-- iii) What is the most selling product line?

select product_line,count(product_line) as cnt from sale group by product_line order by cnt desc;

-- iv) What is the total revenue by month?

select month_name,sum(total) as revenue from sale group by month_name order by field(month_name,'January','February','March');

-- v) What month had the largest COGS?

select month_name,sum(cogs) as cogs from sale group by month_name order by cogs desc;

-- vi) What product line had the largest revenue?

select product_line,sum(total) as revenue from sale group by product_line order by revenue desc;

-- vii) What is the city with the largest revenue?

select city,sum(total) as revenue from sale group by city order by revenue desc;

-- viii) What product line had the largest VAT?

select product_line,avg(vat) as avg_vat from sale group by product_line order by avg_vat desc;

-- ix) Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

select product_line,
case
when sum(quantity)>(select avg(quantity) from sale) then "Good"
else "Bad"
end as Average_Sale
from sale
group by product_line;

-- x) Which branch sold more products than average product sold?

select branch,sum(quantity) as product_sold from sale group by branch having sum(quantity)>(select avg(quantity) from sale);

-- xi) What is the most common product line by gender?

select product_line,gender,count(gender) as count from sale group by product_line,gender order by count desc;

-- xii) What is the average rating of each product line?

select product_line,avg(rating) as avg_rating from sale group by product_line order by avg_rating desc;

-- C) SALES QUERIES

-- i) Number of sales made in each time of the day per weekday

select time_of_day,count(*) as sale from sale group by time_of_day;

-- ii) Which of the customer types brings the most revenue?

select curstomer_type,sum(total) as revenue from sale group by curstomer_type order by revenue desc;

-- iii) Which city has the largest tax percent/ VAT (Value Added Tax)?

select city , sum(vat) as 'total vat' from sale group by city order by 'total vat' desc;

-- iv) Which customer type pays the most in VAT?

select curstomer_type , avg(vat) as 'total vat' from sale group by curstomer_type order by 'total vat' desc;

-- D) CUSTOMER QUERIES

-- i) How many unique customer types does the data have?

select distinct curstomer_type from sale;

-- ii) How many unique payment methods does the data have?

select distinct payment_method from sale;

-- iii) What is the most common customer type?

select curstomer_type,count(*) as count from sale group by curstomer_type order by count desc;

-- iv) Which customer type buys the most (units bought)?

select curstomer_type,sum(quantity) as units from sale group by curstomer_type order by units desc;

-- v) What is the gender of most of the customers?

select gender,count(*) as count from sale group by gender order by count;

-- vi) What is the gender distribution per branch?

select branch,gender,count(*) as count from sale group by branch,gender order by count;

-- vii) Which time of the day do customers give most ratings?

select time_of_day,avg(rating) as avg_rating from sale group by time_of_day order by avg_rating desc;

-- viii) Which time of the day do customers give most ratings per branch?

select branch,time_of_day,avg(rating) as avg_rating from sale group by branch,time_of_day;

-- ix) Which day fo the week has the best avg ratings?

select day_name,avg(rating) as avg_rating from sale group by day_name order by avg_rating desc;

-- x) Which day of the week has the best average ratings per branch?

select branch,day_name,avg(rating) as avg_rating from sale group by branch,day_name order by avg_rating


-- -------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------- REVENUE AND PROFIT CALCULATION --------------------------------------------------------------

/* COGS (Cost of Goods Sold):
COGS = Unit Price × Quantity

VAT (Value Added Tax):
VAT = 5% × COGS

Total (Gross Sales):
Total (Gross Sales) = VAT + COGS

Gross Profit (Gross Income):
Gross Profit = Total (Gross Sales) – COGS

Gross Margin (Percentage):
Gross Margin = (Gross Profit / Total Revenue) × 100 */;

select ((((0.05*(unit_price*quantity))+(unit_price*quantity))-(unit_price*quantity))/ total)*100 as 'Gross Margin Percentage' from sale where invoice_id='101-17-6199';

