# Query 1: CALCULATING THE AMOUNT FOR EACH ORDER
update Orders
join Products on
orders.product_id=Products.product_id
set amount=price*quantity
where amount is null
;

# Query 2:REMOVING REVIEWS FOR ORDERS THAT HAVE NOT BEEN DELIVERED
start transaction;
DELETE FROM Reviews
WHERE (customer_id, product_id) IN (
    SELECT Orders.customer_id, Orders.product_id
    FROM Orders 
    WHERE order_status NOT LIKE 'delivered'
		#Selects the customer_id, product_id pair whose order_status is not delivered
);
select * from Reviews;
commit;

#Query 3: CONVERTING REVIEW_DATE (VARCHAR) TO DATE DATATYPE
		# I initially set the dates as strings to ease data importation
start transaction;
		# I ran the select statemnt first to ensure the function produces accurate results before updating  my table
select str_to_date(review_date, '%m/%d/%Y') from Reviews;
update Reviews
set Review_date=str_to_date(review_date, '%m/%d/%Y')
;
select * from Reviews;
		# Convert the column datatype to date to ensure accuracy for future entries
alter table Reviews
modify column Review_date date;
desc Reviews; # confirms the data type  has been successfully altered
commit;

#QUERY 4: CONVERTING ORDER_DATE (VARCHAR) TO A DATE DATA TYPE
         # I initially set the dates as strings to ease data importation
start transaction;
        # I ran the select statemnt first to ensure the function produces accurate results before updating  my table
select str_to_date(Order_date, '%m/%d/%Y') from Orders;
update Orders
set Order_date=str_to_date(Order_date, '%m/%d/%Y')
;
select * from orders;
		# alter the column data type to ensure accuracy for future entries
alter table Orders
modify column Order_date date;
desc Orders; # confirms successful alteration
commit;

# QUERY 5: CALCULATING AVERAGE RATING FOR EACH PRODUCT
	#I initially set rating in the product table as 1, to ease data importation. 
	#The rating in the Product table should be the average rating given by the customers who ordered the product
 start transaction;
		# Set default Rating to null. products will get an average rating after customer receives order and reviews
 Update Products
 set Rating=null
 where Rating=1;
		# Update avg rating to product table 
update Products
inner join ( select product_id, round(avg(Reviews.Rating), 1)as avg_rating  from Reviews  group by product_id) as R on
Products.product_id = R.product_id
set Products.Rating=R.avg_rating
;
commit;

#QUERY 7: ELIMINATING NULL VALUES. 
		# set Rating at 0 for producs that have not been rated
start transaction;
update Products
set Rating=0
where Rating is null;

select * from Products;
 commit;

# QUERY 8: RENAMING CATEGORY NAMES
		#The current Category data has repetitiv names. i need each category_id to have a unique category_name
start transaction;
update Category
set Category_Name='Accessories' where category_id=4;
Update Category
set Category_Name='Electronics & Appliances' where Category_id=5;      
update Category
set Category_Name='Baby Products' where category_id=6;
update Category
set Category_Name='Gaming Equipment' where category_id=7;
update Category
set Category_Name='Garden & Outdoor' where category_id=10;

select * from Category;
commit;

# QUERY 9: SET STOCK_QUALITY TO D FOR PRODUCTS WITH A RATING OF 1
start transaction;
update Products
set stock_quality='D'
where Rating=1
;
commit;
#QUERY 10: EDIT REVIEW_TEXT FOR LOW RATINGS
		# For Rating 1
start transaction;
Update Reviews
set Review_text='okay product'
where review_id in (1,65,257,273,400,612,649,697,1016,1032,1040,1179,1225,1544,1673,1721,1710,1807)
;
select * from Reviews where Rating=1;
		# Product may be okay, but we need to include a reason for the low rating in the review_text
Update Reviews
set Review_text= concat(Review_text,' ',' item is not as described')
where Rating=1;        
		#For Rating 2
		# Product may be okay, but we need to include a reason for the low rating in the review_text
Update Reviews
set Review_text= concat(Review_text,'. Kindly work on the shipping time')
where Rating=2; 
select * from Reviews where Rating=2;           
commit;
#INCONSISTENT DATES
#QUERY 11: CLEANING ORDER DATES AND REVIEW DATE WHERE REVIEW_DATE CANNOT BE EARLIER THAN ORDER_DATE
		# checking if there are orders whose review dates are before order date
select Review_id,Order_id, Order_date,Review_date
from Reviews
inner join Orders on Orders.Product_id=Reviews.Product_id and Reviews.Customer_id=Orders.customer_id
where Review_date<Order_date
; # 311 rows have inconsistent dates
start transaction;
Update Reviews
inner join Orders on Orders.Product_id=Reviews.Product_id and Reviews.Customer_id=Orders.customer_id
set Review_date=date_sub(Order_date,interval -16 DAY)
where Review_date<Order_date
;
commit;
select DISTINCT Review_id,Order_id, Rating,Order_date,Review_date
from Reviews
inner join Orders on Orders.Product_id=Reviews.Product_id and Reviews.Customer_id=Orders.customer_id
where Review_date>Order_date+16
;        # There are 499 orders that were delivered years later
        #Update Order dates to more recent dates depending on rating given
#QUERY 12: SETTING DELIVERY DATE TO 20 DAYS AFTER ORDER FOR EVERY ORDER WITH A RATING OF 1 AND 2
start transaction;
 set @@autocommit=0;
 update Reviews
 inner join Orders on Orders.Product_id=Reviews.Product_id and Reviews.Customer_id=Orders.customer_id
 set order_date= date_sub(Review_date, interval 20 Day)
 where Review_date>Order_date+16 and rating<=2
 ;
 select DISTINCT Review_id,Order_id, Rating,Order_date,Review_date
from Reviews
inner join Orders on Orders.Product_id=Reviews.Product_id and Reviews.Customer_id=Orders.customer_id
where Rating<=2
;    
#QUERY 13: SETTING DELIVERY DATE TO 3 DAYS AFTER ORDER FOR EVERY ORDER WITH RATING OF GREATER THAN 2
 update Reviews
 inner join Orders on Orders.Product_id=Reviews.Product_id and Reviews.Customer_id=Orders.customer_id
 set order_date= date_sub(Review_date, interval 3 Day)
 where Review_date>Order_date+16 and rating>2
 ;
  select DISTINCT Review_id,Order_id, Rating,Order_date,Review_date
from Reviews
inner join Orders on Orders.Product_id=Reviews.Product_id and Reviews.Customer_id=Orders.customer_id
where Rating>2
;
		#Befoere commit,check for any inconsistency
 select DISTINCT Review_id,Order_id, Rating,Order_date,Review_date
from Reviews
inner join Orders on Orders.Product_id=Reviews.Product_id and Reviews.Customer_id=Orders.customer_id
where Review_date= date_add(Order_date,interval 1 YEAR) 
; 
      select DISTINCT Review_id,Order_id, Rating,Order_date,Review_date
from Reviews
inner join Orders on Orders.Product_id=Reviews.Product_id and Reviews.Customer_id=Orders.customer_id
where Review_date= date_add(Order_date,interval 21 day)   
;
commit;
#QUERY 14: UPDATING THE REVIEW DATE TO 7 DAYS AFTER ORDERING FOR ORDERS THAT WERE REVIEWED 16 DAYS AGO
  # 16days is too long for delivery , i want to reduce it to 7
 start transaction; 
  Update Reviews
inner join Orders on Orders.Product_id=Reviews.Product_id and Reviews.Customer_id=Orders.customer_id
set Review_date=date_add(Order_date,interval +7 DAY)
where Review_date<Order_date or Review_date=date_add(Order_date,interval 16 day)
;
commit;

