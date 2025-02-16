#CREATE OPERATIONS
# Query 1: creating a new customer
insert into Customers(Customer_id,First_name,Last_name,Email,Phone_number,Shipping_address)
values ('1001','Ann','Mame','mameanne@gmail.com','093-98-768','762 Palm Tree, Santa Anna');

#Query 2: Adding a new product
insert into Products(Product_id,Product_name,Price,Stock_quality,Category_id,Rating)
values('4001','Amazing Shoes','500.00','A','7','0');

#Query 3:  Adding column Product_id to table Orders as a foreign key
alter table Orders
add column Product_id int;

alter table Orders
add FOREIGN KEY(Product_id) REFERENCES Products(Product_id);

# READ OPERATIONS
# SIMPLE READ QUESRIES
#Query 4: Viewing all the orders made by a certain customer whose id is 250
select order_id,order_status
from Orders
where customer_id =250;
# Query 5: All products with stock_quality A
select product_name
from Products
where stock_quality='A';
 # Query6: Delivered products
 select order_id
 from Orders
 where order_status='delivered'
 ;
#Multi joins read operations
#Query 7: list of customer emails whose orders have been shipped
   select Email
   from Customers
   join Orders on
   Customers.customer_id=Orders.customer_id
   where order_status='shipped'
   ;
#Query 8: find the category  with the most orders
with OrderedProducts as(
select product_id
from Orders
group by Product_id
)
 select  OrderedProducts.product_id,Products.Category_id, category_name,
 count(Products.category_id)  over (partition by Products.category_id) as counnt
 from OrderedProducts
 join Products on
 Products.product_id=OrderedProducts.product_id
 join Category on
 Category.category_id=Products.category_id
 order by counnt desc
 ;
#UPDATE OPERATIONS
#Query 9: Customer who wants to change their address
update Customers
set shipping_address='906 E Parallel Rd, Pretty Prairie, KS'
where customer_id=235
;
#Query 10: Set review text to do not recommend if the rating is 1
update Reviews
set review_text='Do not recommend this product'
where rating=1
;
#DELETE OPERATIONS
#Query 11: Delete customer records, customer wants to delete their account
delete from Customers
where customer_id=1001
;
