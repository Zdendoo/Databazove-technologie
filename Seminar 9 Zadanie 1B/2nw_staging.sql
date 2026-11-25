-- Active: 1790669352760@@127.0.0.1@5432@northwind_elt
CREATE OR REPLACE VIEW silver.stg_categories AS
SELECT categoryid, categoryname
FROM bronze.categories;
 
CREATE OR REPLACE VIEW silver.stg_customers AS
SELECT customerid, customername, contactname, address, city, country
FROM bronze.customers;
 
CREATE OR REPLACE VIEW silver.stg_employees AS
SELECT employeeid, firstname, lastname, birthdate
FROM bronze.employees;
 
CREATE OR REPLACE VIEW silver.stg_shippers AS
SELECT shipperid, shippername
FROM bronze.shippers;
 
CREATE OR REPLACE VIEW silver.stg_suppliers AS
SELECT supplierid, suppliername, contactname, city, country
FROM bronze.suppliers;
 
CREATE OR REPLACE VIEW silver.stg_products AS
SELECT productid, productname, supplierid, categoryid, unit, price
FROM bronze.products;
 
CREATE OR REPLACE VIEW silver.stg_orders AS
SELECT orderid, customerid, employeeid, shipperid,
       orderdate,
       orderdate::date AS order_date,
       orderdate::time AS order_time
FROM bronze.orders;
 
CREATE OR REPLACE VIEW silver.stg_orderdetails AS
SELECT orderdetailid, orderid, productid, quantity
FROM bronze.orderdetails;