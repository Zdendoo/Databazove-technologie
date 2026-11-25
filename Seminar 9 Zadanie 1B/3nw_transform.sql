-- Active: 1790669352760@@127.0.0.1@5432@northwind_elt
CREATE TABLE gold.sdim_month (
    idsdim_month INT PRIMARY KEY,
    month        INT,
    month_name   VARCHAR(45)
);
CREATE TABLE gold.sdim_quarter (
    idsdim_quarter INT PRIMARY KEY,
    quarter        INT,
    quarter_label  VARCHAR(45)
);
CREATE TABLE gold.dim_date (
    iddim_date INT PRIMARY KEY,                 
    day        INT,
    weekday    INT,
    year       INT,
    week       INT,
    sdim_month_idsdim_month     INT REFERENCES gold.sdim_month,
    sdim_quarter_idsdim_quarter INT REFERENCES gold.sdim_quarter
);
-- čas
CREATE TABLE gold.sdim_day_part (
    idsdim_day_part INT PRIMARY KEY,
    part_of_day     VARCHAR(45)
);
CREATE TABLE gold.sdim_hour (
    idsdim_hour INT PRIMARY KEY,
    hour        INT,
    hour_12     INT,
    am_pm       VARCHAR(45),
    sdim_day_part_idsdim_day_part INT REFERENCES gold.sdim_day_part
);
CREATE TABLE gold.dim_time (
    iddim_time INT PRIMARY KEY,                 
    second     INT,
    minute     INT,
    sdim_hour_idsdim_hour INT REFERENCES gold.sdim_hour
);

CREATE TABLE gold.sdim_country (
    idsdim_country SERIAL PRIMARY KEY,
    country_name   VARCHAR(45)
);
CREATE TABLE gold.sdim_city (
    idsdim_city SERIAL PRIMARY KEY,
    city_name   VARCHAR(45)
);
CREATE TABLE gold.dim_customer (
    iddim_customer INT PRIMARY KEY,
    customer_name  VARCHAR(45),
    contact_name   VARCHAR(45),
    address        VARCHAR(50),
    sdim_country_idsdim_country INT REFERENCES gold.sdim_country,
    sdim_city_idsdim_city       INT REFERENCES gold.sdim_city
);

CREATE TABLE gold.sdim_category (
    idsdim_category SERIAL PRIMARY KEY,
    category_name   VARCHAR(45)
);
CREATE TABLE gold.sdim_supplier (
    idsdim_supplier SERIAL PRIMARY KEY,
    supplier_name   VARCHAR(45),
    contact_name    VARCHAR(45),
    city            VARCHAR(45),
    country         VARCHAR(45)
);
CREATE TABLE gold.dim_product (
    iddim_product INT PRIMARY KEY,
    product_name  VARCHAR(45),
    product_unit  DECIMAL(10,2),                
    sdim_category_idsdim_category INT REFERENCES gold.sdim_category,
    sdim_supplier_idsdim_supplier INT REFERENCES gold.sdim_supplier
);

CREATE TABLE gold.dim_employee (
    iddim_employee INT PRIMARY KEY,
    first_name     VARCHAR(45),
    last_name      VARCHAR(45),
    birthdate      DATE
);
CREATE TABLE gold.dim_shipper (
    iddim_shipper INT PRIMARY KEY,
    shipper_name  VARCHAR(45)
);

CREATE TABLE gold.fact_orders (
    idfact_orders SERIAL PRIMARY KEY,
    quantity      INT,
    product_unit  VARCHAR(45),
    sales_amount  DECIMAL(10,2),
    dim_customer_iddim_customer INT REFERENCES gold.dim_customer,
    dim_time_iddim_time         INT REFERENCES gold.dim_time,
    dim_date_iddim_date         INT REFERENCES gold.dim_date,
    dim_product_iddim_product   INT REFERENCES gold.dim_product,
    dim_employee_iddim_employee INT REFERENCES gold.dim_employee,
    dim_shipper_iddim_shipper   INT REFERENCES gold.dim_shipper
);
 

INSERT INTO gold.sdim_month VALUES
 (1,1,'January'),(2,2,'February'),(3,3,'March'),(4,4,'April'),(5,5,'May'),(6,6,'June'),
 (7,7,'July'),(8,8,'August'),(9,9,'September'),(10,10,'October'),(11,11,'November'),(12,12,'December');
 
INSERT INTO gold.sdim_quarter VALUES (1,1,'Q1'),(2,2,'Q2'),(3,3,'Q3'),(4,4,'Q4');
 
INSERT INTO gold.sdim_day_part VALUES (1,'Night'),(2,'Morning'),(3,'Afternoon'),(4,'Evening');
 
INSERT INTO gold.sdim_hour
SELECT h, h,
       CASE WHEN h % 12 = 0 THEN 12 ELSE h % 12 END,
       CASE WHEN h < 12 THEN 'AM' ELSE 'PM' END,
       CASE WHEN h < 6 THEN 1 WHEN h < 12 THEN 2 WHEN h < 18 THEN 3 ELSE 4 END
FROM generate_series(0, 23) AS h;
 
INSERT INTO gold.sdim_country (country_name)
SELECT DISTINCT country FROM silver.stg_customers ORDER BY country;
 
INSERT INTO gold.sdim_city (city_name)
SELECT DISTINCT city FROM silver.stg_customers ORDER BY city;
 
INSERT INTO gold.sdim_category (category_name)
SELECT categoryname FROM silver.stg_categories ORDER BY categoryid;
 
INSERT INTO gold.sdim_supplier (supplier_name, contact_name, city, country)
SELECT suppliername, contactname, city, country
FROM silver.stg_suppliers ORDER BY supplierid;
 

INSERT INTO gold.dim_date
SELECT to_char(d, 'YYYYMMDD')::int,
       EXTRACT(day FROM d),
       EXTRACT(isodow FROM d),
       EXTRACT(year FROM d),
       EXTRACT(week FROM d),
       EXTRACT(month FROM d),
       EXTRACT(quarter FROM d)
FROM (SELECT DISTINCT order_date AS d FROM silver.stg_orders) x;
 
INSERT INTO gold.dim_time
SELECT EXTRACT(hour FROM t)::int * 10000 + EXTRACT(minute FROM t)::int * 100 + EXTRACT(second FROM t)::int,
       EXTRACT(second FROM t),
       EXTRACT(minute FROM t),
       EXTRACT(hour FROM t)
FROM (SELECT DISTINCT order_time AS t FROM silver.stg_orders) x;
 
INSERT INTO gold.dim_customer
SELECT c.customerid, c.customername, c.contactname, c.address, co.idsdim_country, ci.idsdim_city
FROM silver.stg_customers c
JOIN gold.sdim_country co ON co.country_name = c.country
JOIN gold.sdim_city    ci ON ci.city_name    = c.city;
 
INSERT INTO gold.dim_product
SELECT p.productid, p.productname, p.price, ca.idsdim_category, su.idsdim_supplier
FROM silver.stg_products p
JOIN silver.stg_categories sc ON sc.categoryid = p.categoryid
JOIN gold.sdim_category ca    ON ca.category_name = sc.categoryname
JOIN silver.stg_suppliers ss  ON ss.supplierid = p.supplierid
JOIN gold.sdim_supplier su    ON su.supplier_name = ss.suppliername;
 
INSERT INTO gold.dim_employee
SELECT employeeid, firstname, lastname, birthdate::date
FROM silver.stg_employees;
 
INSERT INTO gold.dim_shipper
SELECT shipperid, shippername FROM silver.stg_shippers;
 

INSERT INTO gold.fact_orders
    (quantity, product_unit, sales_amount,
     dim_customer_iddim_customer, dim_time_iddim_time, dim_date_iddim_date,
     dim_product_iddim_product, dim_employee_iddim_employee, dim_shipper_iddim_shipper)
SELECT od.quantity,
       p.unit,
       od.quantity * p.price,
       o.customerid,
       EXTRACT(hour FROM o.order_time)::int * 10000 + EXTRACT(minute FROM o.order_time)::int * 100 + EXTRACT(second FROM o.order_time)::int,
       to_char(o.order_date, 'YYYYMMDD')::int,
       od.productid,
       o.employeeid,
       o.shipperid
FROM silver.stg_orderdetails od
JOIN silver.stg_orders   o ON o.orderid   = od.orderid
JOIN silver.stg_products p ON p.productid = od.productid;