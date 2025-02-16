create database Ecommerce;
use Ecommerce;
# create table Category
create table Category(
Category_id int,
Category_name varchar(255),
primary key (Category_id)
);
 # create table Customers
create table Customers(
Customer_id int,
First_name varchar(255),
Last_name varchar(255),
Email varchar(320),
Phone_number varchar(50),
Shipping_address varchar(255),
PRIMARY KEY(Customer_id),
CONSTRAINT Customer unique (Email,Phone_number)
);
# create table Products
create table Products(
Product_id int,
Product_name varchar(255),
Price decimal,
Stock_Quality varchar(255),
Category_id int,
Rating tinyint,
PRIMARY KEY(Product_id),
FOREIGN KEY (Category_id) REFERENCES Category(Category_id)
);
# Create table Reviews
create table Reviews(
Review_id int,
Product_id int,
Customer_id int,
Rating tinyint not null check(rating between 1 and 5),
Review_text text,
Review_date datetime default current_timestamp,
PRIMARY KEY(Review_id),
FOREIGN KEY(Product_id) REFERENCES Products(Product_id),
FOREIGN KEY(Customer_id) REFERENCES Customers(Customer_id)
);
# Create table Orders
Create table Orders(
Order_id int,
Customer_id int,
Order_date datetime,
Amount int,
Order_status varchar(50) not null,
quantity int,
PRIMARY KEY(Order_id),
FOREIGN KEY(Customer_id) REFERENCES Customers(Customer_id)
);

# Ordering columns in the table
 alter table orders
 modify column quantity int after Order_date;
 alter table Orders
 modify column Product_id int after Customer_id;
 
 # Altering the review_date and Order_date datatype to varchar to enable data importation as the data format for the dates in csv file is dd/mm/yyyy
alter table Reviews
modify Review_date varchar(50);
alter table Orders
modify order_date varchar(50);

