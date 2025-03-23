# CANCELLED ORDERS
	# Adding an extra column in the Orders table to mark cancelled Orders
    Alter table Orders
    add column Is_cancelled tinyint default 0;
    
    # Cancelling pending orders made in jan,feb and arch of 2000
    Update Orders
    set Is_cancelled=1
    where year(Order_date)=2000 and month(Order_date) in (01,02,03) and Order_status='pending';
 



#STOCK MANAGEMENT
	# QUERY 1 : CREATING A TABLE TO LOG STOCK ENTRIES
	create table Stock(
	Log_id int auto_increment,
	Product_id int,
	Stock_bought int,
	Restock int default 0,
	Last_Restock_date TIMESTAMP,
	Current_stock int,
	PRIMARY KEY(Log_id),
	FOREIGN KEY(Product_id) REFERENCES Products(Product_id)
	);

	# QUERY 2: INCLUDING A COLUMN  IN PRODUCTS, TO INDICATE THE CURRENT STOCK
	   # Importing  data
	   # Check readme file for importation tutorial
	select * from Stock; # data imported successfully
	  
	  
	# QUERY 3: CALCULATING CURRENT STOCK
		# Current_stock= Stock_bought+restock-quantity
        # quantity from cancelled orders will not be counted as bought 
		start transaction;
		 delimiter $$
		 Create event Current_stock
		 on schedule every 24 HOUR
		 do
		 begin
		 Update Stock
		 join ( select Product_id, sum(case when Is_cancelled=1 then quantity=0 else quantity end)as Product_sold from Orders group by product_id) as Q on
		 Stock.product_id=Q.Product_id
		 set Current_stock=(Stock_bought+restock-Product_sold)
		 where  Stock.product_id=Q.Product_id
		 ;
		 end $$ 
		  select * from Stock; # event executes successully
		  
	commit;

	# QUERY 4: INDICATING PRODUCTS THAT ARE OUT OF STOCK OR RUNNING OUT OF STOCK
		#creating a column in Products table to indicate stock quantity
		
		alter table Products
		add column Capacity varchar(50) default 'IN STOCK'
		;
        
		start transaction;
		delimiter $$
		create event Stock_Capacity
		on schedule every 24 HOUR
		do
		begin
		 Update Products
		join Stock on
		Stock.Product_id=Products.Product_id
		set Capacity='RUNNING OUT OF STOCK'
		where Current_stock between 1 and 15
		;
		 Update Products
		join Stock on
		Stock.Product_id=Products.Product_id
		set Capacity='OUT OF STOCK'
		where Current_stock=0
		;
		end $$
		  
		  # Testing the event
		  select Products.Product_id,Capacity,Current_stock
		  from Products
		  join Stock on Stock.product_id=Products.Product_id;   # event exexutes successfully
	commit;    


# QUERY 5: RESTOCKING
		# Stock management is  broad, therefore we are only going to store the sum of restocks and the latest day of restocking
start transaction;
delimiter $$
create Procedure Restock(in R_Product_id int,inout New_Restock int)
begin
Update Stock
set Restock= Restock+New_restock , Last_restock_date=now()
where Product_id=R_Product_id
;
select Product_id,Restock into New_restock from Stock
;
end $$

set @New_restock=20;
call Restock(15,@New_restock);
select @New_restock

# Procedure executes successfully
  
set @New_restock=40;
call Restock(15,@New_restock);
select @New_restock   

select * from Stock where product_id=15;   # The last Restock date is updated successfully

Update stock
set Last_restock_date= null,Restock=0
where Product_id=15
;