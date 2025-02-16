# QUERY 1: CALCULATING THE TOTAL SALES BY PRODUCT CATEGORY
with Sales as(
select Orders.Product_id, Category_id,sum(amount) as Total_sales
from Orders
join Products on
Products.Product_id=Orders.Product_id
group by Orders.Product_id
)
select Sales.Category_Id, Category_name,sum(Total_sales) as Sum_of_sales_per_category
from Sales
join Category on
Sales.Category_id=Category.Category_id
group by Sales.Category_id
order by Sum_of_sales_per_category desc
;
# QUERY 2: LIST TOP 50 CUSTOMERS BY ORDER VALUE FILTER OUT CUSTOMERS WITH NO ORDERS
select Orders.Customer_id, First_name,Last_name, 
sum(amount)
from Orders
inner join Customers on
Orders.Customer_id=Customers.Customer_id
group by Orders.Customer_id
order by sum(amount) desc
; # Returns 864 rows implying 864/1000 customers have made Orders
# to obtain top 50, limit to the first 50 rows
select Orders.Customer_id, First_name,Last_name, 
sum(amount) as Customer_Order_Value
from Orders
inner join Customers on
Orders.Customer_id=Customers.Customer_id
group by Orders.Customer_id
order by sum(amount) desc
limit 50
;
# QUERY 3: MOST POPULAR PRODUCT BY SALES VOLUME
select Product_id, Product_name, max(Total_sales) as Most_Popular
from (
select Orders.Product_id, Product_name,sum(amount) as Total_sales
from Orders
join Products on
Products.Product_id=Orders.Product_id
group by Orders.Product_id,Product_name
)P
;