# E-COMMERCE MYSQL RELATIONAL DATABASE PROJECT

 # 1.  OVERVIEW
This project is a comprehensive SQL-based relational database system designed to demonstrate proficiency in database design, optimization, and automation. The database simulates an order management system with a focus on:

•	Data Cleanup and Integrity
•	Automated Processes (Triggers, Events, Stored Procedures)
•	Search Functionality for Products
•	Order and Stock Management
•	Revenue Reporting & Tracking
The project  also employs advanced MySQL features to ensure efficiency, scalability, and maintainability.

The project includes **SQL scripts** for database setup, CRUD operations,automation processes: triggers and events, stored-procedures, multi-aggregates and multi-joins

---

## 🛠️ Setup Instructions
### **1️⃣ Install Dependencies**
Ensure you have MySQL installed. 
For python Dependencies: pip install faker pandas numpy

# A. Create Database & Tables
Open MySQL and execute: create database and tables file
 
# B. Generate Data
Open Data Import.ipynb in Jupyter Notebook.
Run all cells to generate synthetic data.
CSV files will be saved in the /data folder.

# C. Data Importation
__
    **Step 1: Open MySQL Workbench**  
1. Launch **MySQL Workbench** and connect to your MySQL server.  
2. In the left panel, select your database (e.g., `ecommerce`). 

    **Step 2: Start the Import Wizard**  
1. Click on your database schema in the **Navigator** panel.  
2. Right-click on the **Tables** section.  
3. Select **Table Data Import Wizard**.  

    **Step 3: Select the File**  
1. Click **Browse** and select your **CSV** or **Excel** file.  
2. Click **Next** to proceed.  

     **Step 4: Choose the Destination Table**  
   - Select the table you want to import data into.  
   - Click **Next**.  

     **Step 5: Configure Column Mappings**  
1. **MySQL Workbench** will detect column names automatically.  
2. If needed, manually map columns from your file to the database table.  
3. Click **Next** when mappings are correct.  

    **Step 6: Execute the Import**  
1. Review the summary.  
2. Click **Next** to start the import process.  
3. Once completed, click **Finish**.  

    **Step 7: Verify the Import**  
1. Run the following query to check if data was imported successfully:  
   ```sql
   SELECT * FROM your_table ;



# 2. DATABASE STRUCTURE
        Core Tables:   
•	Customers:  Contains customer information (Primary Key: Customer_id).
•	Products:   Holds product details (Primary Key: Product_ID, Foreign key: Category_id).
•	Orders:     Manages order transactions (Primary Key: Order_ID, Foreign Keys: Customer_id, Product_id).
•	Stock:      Manages stock quantities, restocks, and current stock levels (Primary Key: Log_id,Foreign key: Product_id).
•	Reviews:    Tracks customer product reviews and ratings.
•	Categories: Contains product categories (Primary Key: Category_id).
________________________________________

# 3. DATABASE RELATIONSHIPS

Relationship Type	Tables Involved
One-to-One	  Orders →Reviews	          Each delivered order results in one review per product-customer pair
One-to-Many	  Products →Reviews	          One product can have many reviews. But a product can be reviewed by a customer once
One-to-Many	  Customers →Reviews	      One Customer can make many reviews. However they can only review a product once.
One-to-Many   Customers →Orders	          A customer can make many Orders
One-to-Many	  Products →Orders	          A product can be ordered many times
One-to-Many	  Categories →Products	      A category can have multiple products
One-to-One	  Products →Stock	          A product can have one stock log

________________________________________
# 4. KEY FEATURES
    Feature	Description
Data Integrity:         	Enforced via Primary Keys, Foreign Keys, NOT NULL, UNIQUE, and CHECK constraints.
CRUD Operations:        	Standard Create, Read, Update, Delete operations on all core tables.
Automation:             	Triggers, Events, and Stored Procedures to handle stock updates, loyalty discounts, invoices and Order amounts.
Optimization:               Indexed every foreign key in each table to optimize table persormance
Stock Management:       	Automatically adjusts current stock based on restocks, order cancellations, and purchases.
Revenue Reporting:      	Views  to calculate annual, monthly, per-customer, and per-product revenue.
Search Functionality:	    Product name search using LIKE operator and concatenation for flexible matching.
Data Cleanup:            	Dedicated scripts to remove duplicates and standardize imported data.

________________________________________

# 5. IMPLEMENTATION DETAILS
Automization & Optimization
•	Triggers: To create a new row when an Order is ‘delivered’
•	Events: Automate loyalty discounts and memberships based on order history, Average Product rating, calculating total amount for an order, and calculating stock for each product based on Items bought, restocks and quantity sold 
•	Stored Procedures: For restocking products and generating invoices
Stock Management & Cancelled Orders
•	Stock levels auto-update based on orders and restock actions.
•	Cancelled orders return the product quantity back to stock.
Revenue Reporting
•	Views and procedures calculate: 
o	Annual revenue
o	Monthly revenue (parameterized)
o	Revenue generated by each customer
o	Revenue generated by each product
o	Gross revenue
Search Functionality
•	Product search feature using LIKE CONCAT('%', search_term, '%') to allow flexible partial matching.
________________________________________

# 6. Limitations
•	MySQL Limitations: Certain advanced functionalities, such as detailed audit logs, advanced recommendation systems, and real-time complex analytics, were not implemented due to MySQL's inherent limitations.
   These typically require integration with external application logic, APIs, or analytics platforms.

•	Generated Data Shortcomings: The Faker-generated data provided practical sample data, but constrained the implementation in a few areas:
        o  	Limited flexibility to implement multiple products per single order.
        o	Limited ability to perform complex date-based analysis due to uniform/randomized date distributions.
        o	Faker-generated customers lack purchasing behavior trends, repeat purchase patterns, or loyalty behaviors, limiting the ability to perform behavior-based analytics.
        o	Faker generates dates randomly without real-world seasonality or temporal trends, making accurate monthly, quarterly, or promotional period analysis less meaningful.
        o	Product categories, reviews, and ratings are randomly assigned, not reflecting realistic customer preferences, satisfaction patterns, or product-category relations.
        o	Limited ability to assign unique names to products and match a product name to its appropriate category names

•	Strict SQL-Only Scope: The project intentionally avoids external scripting, BI tools, or programming languages, limiting functionality to MySQL-native features.
    Some advanced business logic (such as user behavior tracking, detailed event logging) would require application-level logic outside SQL.
________________________________________

# 7. FUTURE IMPROVEMENTS
🚀 	Implement audit logs to track all row-level changes.
🚀	Add user permissions and roles for secure data handling.
🚀	Integrate with BI tools or Python for real-time dashboards and advanced analytics.
🚀	Expand data generation to include more realistic, complex order-product relationships.



👤 Author
Sharon Nyambega|nyambegasharon001@gmail.com