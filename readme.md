# 🛒 E-commerce Database Project

## 📌 Overview
This project simulates an **e-commerce database** using MySQL, including data generation, database creation, and SQL operations. The dataset consists of **five key tables**:  
- **Customers** – Stores customer details.  
- **Categories** – Groups products into different categories.  
- **Products** – Lists items available for purchase.  
- **Orders** – Tracks customer purchases.  
- **Reviews** – Stores customer feedback on products hey have purchased

The project includes **SQL scripts** for database setup, CRUD operations, and advanced queries.  


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

# 📌 SQL Features
✔ Primary & Foreign Keys for data integrity
✔ Indexes for optimized queries
✔ Aggregations & Joins for reporting
✔ CRUD operations for data management

# 📌 Future Improvements
🚀 Optimize indexing for large datasets
🚀 Improve faker-generated data realism
🚀 Add stored procedures for better query performance

👤 Author
Sharon Nyambega|nyambegasharon001@gmail.com