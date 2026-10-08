Uloha 9

CREATE OR REPLACE PROCEDURE get_customer_sales(p_customer_id VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales NUMERIC(10, 2);
BEGIN
    SELECT COALESCE(SUM(sales), 0)
    INTO v_total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Customer: %, Total Sales: %', p_customer_id, v_total_sales;
END;
$$;

CALL get_customer_sales('C001');

----------------------------------------------------

Uloha 10

CREATE OR REPLACE PROCEDURE apply_regional_discount(
    p_region_name VARCHAR,
    p_discount_rate NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders
    SET sales = sales * (1 - p_discount_rate)
    FROM customers
    WHERE orders.customer_id = customers.customer_id
      AND customers.region = p_region_name;

    RAISE NOTICE 'Aplikovaná zľava % pre región %.', p_discount_rate, p_region_name;
END;
$$;

CALL apply_regional_discount('West', 0.10);

----------------------------------------------------------

Uloha 11

CREATE OR REPLACE PROCEDURE get_sales_between(
    p_start_date DATE,
    p_end_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales NUMERIC(10, 2);
BEGIN
    SELECT COALESCE(SUM(sales), 0)
    INTO v_total_sales
    FROM orders
    WHERE order_date BETWEEN p_start_date AND p_end_date;

    RAISE NOTICE 'Od: %, Do: %, Celkový predaj: %', p_start_date, p_end_date, v_total_sales;
END;
$$;

SELECT SUM(sales) FROM orders WHERE order_date BETWEEN '2024-01-01' AND '2024-03-31';