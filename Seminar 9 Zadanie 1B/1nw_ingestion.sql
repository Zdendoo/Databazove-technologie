-- Active: 1790669352760@@127.0.0.1@5432@northwind_elt
DROP DATABASE IF EXISTS northwind_elt;
CREATE DATABASE northwind_elt;
\c northwind_elt

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;

CREATE TABLE bronze.categories (
    categoryid   INT PRIMARY KEY,
    categoryname VARCHAR(25),
    description  VARCHAR(255)
);
 
CREATE TABLE bronze.customers (
    customerid   INT PRIMARY KEY,
    customername VARCHAR(50),
    contactname  VARCHAR(50),
    address      VARCHAR(50),
    city         VARCHAR(20),
    postalcode   VARCHAR(10),
    country      VARCHAR(15)
);
 
CREATE TABLE bronze.employees (
    employeeid INT PRIMARY KEY,
    lastname   VARCHAR(15),
    firstname  VARCHAR(15),
    birthdate  TIMESTAMP,
    photo      VARCHAR(25),
    notes      VARCHAR(1024)
);
 
CREATE TABLE bronze.shippers (
    shipperid   INT PRIMARY KEY,
    shippername VARCHAR(25),
    phone       VARCHAR(15)
);
 
CREATE TABLE bronze.suppliers (
    supplierid   INT PRIMARY KEY,
    suppliername VARCHAR(50),
    contactname  VARCHAR(50),
    address      VARCHAR(50),
    city         VARCHAR(20),
    postalcode   VARCHAR(10),
    country      VARCHAR(15),
    phone        VARCHAR(15)
);
 
CREATE TABLE bronze.products (
    productid   INT PRIMARY KEY,
    productname VARCHAR(50),
    supplierid  INT,
    categoryid  INT,
    unit        VARCHAR(25),
    price       DECIMAL(10,2)
);
 
CREATE TABLE bronze.orders (
    orderid    INT PRIMARY KEY,
    customerid INT,
    employeeid INT,
    orderdate  TIMESTAMP,
    shipperid  INT
);
 
CREATE TABLE bronze.orderdetails (
    orderdetailid INT PRIMARY KEY,
    orderid       INT,
    productid     INT,
    quantity      INT
);

\copy bronze.categories   FROM 'C:\Users\Desktop\categories.csv'   WITH (FORMAT csv, DELIMITER ';', HEADER true);
\copy bronze.customers    FROM 'C:\Users\Desktop\customers.csv'    WITH (FORMAT csv, DELIMITER ';', HEADER true);
\copy bronze.employees    FROM 'C:\Users\Desktop\employees.csv'    WITH (FORMAT csv, DELIMITER ';', HEADER true);
\copy bronze.shippers     FROM 'C:\Users\Desktop\shippers.csv'     WITH (FORMAT csv, DELIMITER ';', HEADER true);
\copy bronze.suppliers    FROM 'C:\Users\Desktop\suppliers.csv'    WITH (FORMAT csv, DELIMITER ';', HEADER true);
\copy bronze.products     FROM 'C:\Users\Desktop\products.csv'     WITH (FORMAT csv, DELIMITER ';', HEADER true);
\copy bronze.orders       FROM 'C:\Users\Desktop\orders.csv'       WITH (FORMAT csv, DELIMITER ';', HEADER true);
\copy bronze.orderdetails FROM 'C:\Users\Desktop\orderdetails.csv' WITH (FORMAT csv, DELIMITER ';', HEADER true);