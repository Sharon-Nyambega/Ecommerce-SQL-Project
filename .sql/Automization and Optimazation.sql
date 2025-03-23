# QUERY 1: CREATING INDEXES
 # Indexing all foreign keys from each table
	# Products table
	create index categorize on Products(Category_id);
    # Orders table
    create index Customer_order on Orders(customer_id);
    create index product_order on Orders(product_id);
     # Reviews table
    create index Customer_review on Reviews(customer_id);
    create index product_review on Reviews(product_id);
      
# QUERY 2: GENERATING INVOINCES UPON REQUEST
  # invoices are not complusory as they are not going to be manipulated in this project, creating an Invoice table will be a waste of space, hence they are going to be generated upon request
delimiter $$
create procedure Invoice(in CustomerId int)
begin
		Declare row_count int;
		select count(*) into row_count from customers where Customer_id=CustomerId;

		if row_count=0 then
		signal sqlstate '45000'
		set message_text="Customer doesn't exist";
		end if ;
        
		 IF EXISTS (
		 select customers.Customer_id 
		from Customers
		left join Orders on
		Customers.Customer_id=Orders.customer_id
		where Orders.Customer_id is null and Customers.Customer_id=CustomerId) then
		signal sqlstate '45001'
		set message_text='Invoice cannot be generated, please make an order first';
		end if;

select Order_date as date, concat('INV',Order_id) as invoice_number,
concat(first_name,' ',last_name) as 'Bill to',
concat(first_name,' ',last_name) as 'Ship to',
Email, Shipping_address,
Product_name as Product, Quantity, Price as Unit_price,
Amount
from Orders
join Customers on 
Orders.Customer_id= Customers.Customer_id
join Products on
Orders.Product_id=Products.product_id
where Orders.customer_id=CustomerId
;
end
$$


#Testing with a non existing customer_id
call Invoice(1702); # Returns Customer does not exist
# Testing with a customer that has never made an order
call Invoice (992); # Returns Invoice cannot be generated, please make an order first
# Testing with a Customer who has made an order
call Invoice(12); # Returns an invoice

# QUERY 3: AWARDING A MEMBERSHIP FOR CUSTOMERS WITH ATLEAST 5 ORDERS, AND AUTO-UPDATING STATUS
delimiter $$
alter table Customers
add column Loyalty_status varchar(20)
;
	#Update existing values
    # Assigning status "gold" to customers with 8 or more orders
    start transaction;    
delimiter $$
Update Customers
join Orders on Customers.customer_id=Orders.Customer_id
set Loyalty_status='Gold' where Orders.Customer_id in (select Orders.Customer_id from Orders group by orders.Customer_id having count(*)>=8)
;    
select Orders.Customer_id,first_name,last_name,loyalty_status
from Customers
join Orders on Customers.Customer_id=Orders.Customer_id
group by Orders.Customer_id,first_name,last_name,loyalty_status
having count(Orders.customer_id)>=8
;
end $$
	# Assigning "platnum" status to customers with 5 to 7 orders
delimiter $$
Update Customers
join Orders on Customers.customer_id=Orders.Customer_id
set Loyalty_status='Platnum' where Orders.Customer_id in (select Orders.Customer_id from Orders group by orders.Customer_id having count(*) between 5 and 7)
;    
select Orders.Customer_id,first_name,last_name,loyalty_status
from Customers
join Orders on Customers.Customer_id=Orders.Customer_id
group by Orders.Customer_id,first_name,last_name,loyalty_status
having count(Orders.customer_id) between 5 and 7
;
end $$
commit;

	#Auto-Updating Loyalty_status for Future values
start transaction;
delimiter $$
create event Membership
on schedule every 12 HOUR
do
begin
	Update Customers
    set Loyalty_status='Gold'
    where Customer_id in(
       select Customer_id from Orders group by Customer_id having count(*)>=8);
 
    update Customers
    set Loyalty_status='platnum'
    where Customer_id  in (
       select Customer_id from Orders group by Customer_id having count(*) between 5 and 7);
   end $$
   
  ## customer_id '9' and '25' has made 4 orders, i will add an extra order to check change in loyalty status after 12 hours
  start transaction;
    insert into Orders(Order_id,Customer_id,product_id,Order_date,quantity,Order_status)
   values
		('2001','9','26','2024-11-12','5','Shipped')
		('2002','25','100','2023-11-03','7','pending')
        ('2003','30','48','2024-06-12','4','delivered'); 
  
  select * from Customers where Customer_id=9; # Loyalty_status updated successfully
  
  commit;
  #QUERY 4: AUTO CALCULATING AMOUNT FOR FUTURE INSERTIONS
           # setting default value for column Alter as 0
           start transaction;
           ALTER TABLE Orders
          ALTER COLUMN Amount SET DEFAULT 0;
          commit;
      
  start transaction;
  DELIMITER $$
  CREATE event total_amount
  on schedule every 1 MINUTE
   do
  begin 
    update Orders
  join products on  Products.Product_id=Orders.product_id
  set Amount=quantity*price
  where Amount=0;
    end $$
           # testing the event
           insert into Orders(Order_id,Customer_id,product_id,Order_date,quantity,Order_status)
		   values
		('2006','130','23','2024-02-16','8','delivered');
        
        select * from Orders where Order_id=2006; # Amount updated successfully
     
#QUERY 5: AUTOMATICALLY CREATING A ROW IN REVIEWS TABLE AS SOON AS ORDER STATUS IS SET AS 'DELIVERED'
		# enabling autoincrement on Review_id
		ALTER TABLE Reviews MODIFY Review_id INT NOT NULL AUTO_INCREMENT;

# trigger on create
delimiter $$
create trigger Review_Row
after insert on Orders
for each row
begin
 declare total_count int;
 
 select count(*) into total_count
 from Reviews
 where Customer_id=new.Customer_id and Product_id=new.Product_id
 ;
 
if total_count>0 then
update Reviews
set Review_text=null,Review_date=null
where Customer_id=new.Customer_id and Product_id=new.Product_id;
else
 insert into Reviews(Customer_id,Product_id,Rating,Review_text,Review_date)
 values(new.Customer_id,new.product_id,'1',null,null);
 end if;
 end $$

	# Testing  the event for  a new review
        insert into Orders(Order_id,Customer_id,product_id,Order_date,quantity,Order_status)
		values
		('2004','87','64','2024-02-21','5','delivered');
		
	# Updating  a review, or a customer who has purchased the same product more than once
		insert into Orders(Order_id,Customer_id,product_id,Order_date,quantity,Order_status)
		values
		('2005','95','28','2023-12-05','5','delivered');
       
      select * from Reviews;
      
#trigger on update
delimiter $$
CREATE TRIGGER Review_Update
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    -- Only trigger if Order_status was changed to "Delivered"
    DECLARE total_count INT;
    IF OLD.Order_status <> 'Delivered' AND NEW.Order_status = 'Delivered' THEN
               
        -- Check if the customer has already reviewed the product
        SELECT COUNT(*) INTO total_count
        FROM Reviews
        WHERE Customer_id = NEW.Customer_id AND Product_id = NEW.Product_id;

        IF total_count > 0 THEN
            UPDATE Reviews
            SET Review_text = NULL, Review_date = NULL
            WHERE Customer_id = NEW.Customer_id AND Product_id = NEW.Product_id;
        ELSE
            INSERT INTO Reviews(Customer_id, Product_id, Rating, Review_text, Review_date)
            VALUES (NEW.Customer_id, NEW.Product_id, 1, NULL, NULL);
        END IF;
    END IF;
END $$
	# Testing the trigger
    Update Orders
    set Order_Status='delivered'
    where Customer_id=130 and Product_id=342;
    
    select* from Reviews where Customer_id=599 and Product_id=342;  # trigger executes correctly
    
    Update Reviews
    set Rating= 3, Review_text='great product',Review_date='2006-04-03';
    

#QUERY 6: UPDATING AVERAGE RATING IN PRODUCTS TABLE FOR EVERY RATED PRODUCT, AS SOON AS A NEW REVIEW IS DONE
delimiter $$
create event Average_Rating
on schedule every 5 minute
do
BEGIN
update Products
set Products.Rating=(select round(avg(Reviews.Rating), 1)as avg_rating  from Reviews  group by product_id)
;
END $$
drop event Average_rating;
--   # Testing the event with Reviews made for product_id 48 and 64. 
	#Product with Id 48 has not been purchased before while product Id 64 has a rating of 2, product Id 23 an 28 have rating of 2
     # i will also test the event  with the 4 rows created by the trigger
	Update reviews
    set Rating=3,Review_text='great product',Review_date='2024-06-15'
    where Customer_id=30 and Product_id=48;
    
    	Update reviews
    set Rating=4,Review_text='i will buy more',Review_date='2024-02-23'
    where Customer_id=87 and Product_id=64;
    
    	Update reviews
    set Rating=3,Review_text='great customer service',Review_date='2023-12-09'
    where Customer_id=95 and Product_id=28;
    
    	Update reviews
    set Rating=5,Review_text='great product',Review_date='2024-02-19'
    where Customer_id=130 and Product_id=23;
   
   select Rating from Products
   where Product_id in (48,64,28,23);  # event executes perfectly
   
# QUERY 7: OFFERING DISCOUNTS TO PLATINUM AND GOLD MEMBERS ON CHRISMAS, BLACK FRIDAY AND NEW YEAR
		# Offering 10% discount for platnum and 20% discount for gold

start transaction;
     # Ensuring discounts for the Platnum and Gold members in November and December for future Orders
      # adding a column to input the discounted amount
      Alter table Orders
      add column Discounted_amount int;
  
  delimiter $$
  create Event Discount
  on schedule every 1 MINUTE
  do
  begin
  
		UPDATE orders
		JOIN (
			   SELECT Customer_id,Order_date
			   from(
			   select Customer_id,Order_date,
				Row_number() over (partition by Customer_id Order by order_date) as rn
				FROM Orders 
			   )X
				where rn between 5 and 7 and MONTH(order_date) in (11,12)
			
		) AS eligible_customers
		ON Orders.customer_id = eligible_customers.customer_id and Orders.Order_date=eligible_customers.Order_date
		SET Discounted_amount= ROUND(0.9 * Orders.amount, 0)
		WHERE Orders.customer_id = eligible_customers.customer_id and Orders.Order_date=eligible_customers.Order_date
        and Discounted_amount is null

        ;

         UPDATE orders
		 JOIN (
				SELECT Customer_id,Order_date
				FROM (
				select Customer_id, Order_date,
				row_number() over (partition by Customer_id Order by Order_date) as rn
				from Orders
				) as X
				where rn>=8 and MONTH(Order_date) IN (11, 12)
	  
		) AS eligible_customers
		ON Orders.customer_id = eligible_customers.customer_id and Orders.Order_date= eligible_customers.Order_date
		SET Discounted_amount = ROUND(0.8 * Orders.amount, 0)
		where  Orders.customer_id = eligible_customers.customer_id and Orders.Order_date= eligible_customers.Order_date
        and Discounted_amount is null
  
      ;
        end $$
        
     # Testing the event
     
     insert into Orders(Order_id,Customer_id,product_id,Order_date,quantity,Order_status)
		   values
		('2007','493','27','2024-11-16','8','shipped');
        
        select * from Orders where customer_id=493 order by order_date;  # event executes successfully
    
    # STOCK MANAGEMENT
