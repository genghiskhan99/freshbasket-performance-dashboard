
SELECT 
    *
FROM
    freshbasket_inventory_messy;

CREATE TABLE freshbasket_cleaned AS SELECT * FROM
    freshbasket_inventory_messy;
    
SELECT 
    *
FROM
    freshbasket_cleaned;
    
-- Cleaning date columns

Alter table freshbasket_cleaned
add column final_sale_date date;

alter table freshbasket_cleaned
change formatted_sale_date final_sale_date date;

alter table freshbasket_cleaned
drop column final_sale_date;

UPDATE freshbasket_cleaned
SET final_sale_date = CASE
    WHEN DATE REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
        THEN STR_TO_DATE(DATE, '%Y/%m/%d')
    WHEN DATE REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
        THEN STR_TO_DATE(DATE, '%d-%m-%Y')
    WHEN DATE REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        THEN STR_TO_DATE(DATE, '%Y-%m-%d')
    WHEN DATE REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
        THEN STR_TO_DATE(DATE, '%m/%d/%Y')
    ELSE NULL
END;

ALTER TABLE freshbasket_cleaned
add column formatted_delivery_date date;

UPDATE freshbasket_cleaned
SET formatted_delivery_date = CASE
    WHEN delivery_DATE REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
        THEN STR_TO_DATE(delivery_DATE, '%Y/%m/%d')
    WHEN delivery_DATE REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
        THEN STR_TO_DATE(delivery_DATE, '%d-%m-%Y')
    WHEN delivery_DATE REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        THEN STR_TO_DATE(delivery_DATE, '%Y-%m-%d')
    WHEN delivery_DATE REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
        THEN STR_TO_DATE(delivery_DATE, '%m/%d/%Y')
    ELSE NULL
END;

SELECT 
    *
FROM
    freshbasket_cleaned;
    
alter table freshbasket_cleaned
drop column delivery_date;

alter table freshbasket_cleaned
change formatted_delivery_date delivery_date DATE;


-- Validating Name fields

SELECT
    product_ID, Product_Name
FROM
    freshbasket_cleaned;
    
Update freshbasket_cleaned
set product_name = "Tomatoes"
where product_name like "%tom%";

Update freshbasket_cleaned
set product_name = "Bananas"
where product_name like "%B@n%";

Update freshbasket_cleaned
set product_name = "Lettuce"
where product_name like "%L3%";


SELECT distinct supplier
FROM
    freshbasket_cleaned;
    
update freshbasket_cleaned
set supplier = "GreenLeaf Inc."
where supplier like "%Gre%";
    
update freshbasket_cleaned
set supplier = "Meats-R-Us"
where supplier like "%Mea%";

SELECT 
    *
FROM
    freshbasket_cleaned;



create table products as
SELECT 
    Product_ID, Product_Name, Category, Avg(Unit_Price) as Avg_Unit_Price
FROM
    freshbasket_cleaned
    group by product_ID, Product_Name, Category;
    
alter table products
modify column avg_unit_price DECIMAL(5,1);
    
select * from products;

CREATE TABLE suppliers AS
SELECT DISTINCT supplier AS supplier_name
FROM freshbasket_cleaned;

ALTER TABLE suppliers
ADD COLUMN supplier_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

select * from suppliers;

UPDATE freshbasket_cleaned fc
JOIN suppliers s ON fc.supplier = s.supplier_name
SET fc.supplier_id = s.supplier_id;

alter table freshbasket_cleaned 
add column supplier_ID int;

CREATE TABLE sales AS
SELECT 
    product_ID,
    final_sale_date AS sale_date,
    units_sold,
    unit_price
FROM freshbasket_cleaned
WHERE final_sale_date IS NOT NULL;

select * from sales;

alter table Sales
add column revenue dec(10,2);

update sales
set revenue = unit_price * units_sold;

CREATE TABLE deliveries AS
SELECT 
    product_ID,
    supplier_id,
    delivery_date 
FROM freshbasket_cleaned
WHERE delivery_date IS NOT NULL;


select * from waste;

CREATE TABLE waste AS
SELECT 
    product_ID,
    waste_units,
    notes
FROM freshbasket_cleaned
WHERE waste_units IS NOT NULL;


drop table suppliers;


CREATE TABLE agg_sales AS
SELECT 
    product_ID,
    MAX(sale_date) AS last_sale_date,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(unit_price), 2) AS avg_unit_price,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM sales
GROUP BY product_ID;

CREATE TABLE agg_deliveries AS
SELECT 
    product_ID,
    MAX(delivery_date) AS last_delivery_date,
    COUNT(*) AS total_deliveries
FROM deliveries
GROUP BY product_ID;

CREATE TABLE agg_waste AS
SELECT 
    product_ID,
    SUM(waste_units) AS total_waste_units
FROM waste
GROUP BY product_ID;

CREATE TABLE freshbasket_final AS
SELECT 
    p.product_ID,
    p.product_name,
    p.category,
    p.avg_unit_price,

    s.last_sale_date,
    s.total_units_sold,
    s.total_revenue,

    d.last_delivery_date,
    d.total_deliveries,

    w.total_waste_units

FROM products p
LEFT JOIN agg_sales s ON p.product_ID = s.product_ID
LEFT JOIN agg_deliveries d ON p.product_ID = d.product_ID
LEFT JOIN agg_waste w ON p.product_ID = w.product_ID;


SELECT 
    product_ID, product_name
FROM
    freshbasket_final
    where product_id like "p004";
    
UPDATE freshbasket_final
set category = 'bakery' where product_name = 'bread';

SELECT 
    *
FROM
    freshbasket_final;
    
SELECT 
    *
FROM
    freshbasket_CLEANED;
    
update freshbasket_final
set category = "Meat" where PRODUCT_NAME = "Chicken Breast";

alter table freshbasket_final
drop column supplier_ID ;



UPDATE FRESHBASKET_FINAL
SET SUPPLIER_ID = "03" WHERE PRODUCT_ID = "P004";

SELECT DISTINCT
PRODUCT_ID, SUPPLIER_ID
FROM
    DELIVERIES;
    
SELECT 
    *
FROM
    FRESHBASKET_CLEANED;
    
UPDATE freshbasket_final f
JOIN (
    SELECT fc.product_ID, fc.supplier
    FROM freshbasket_cleaned fc
    JOIN (
        SELECT product_ID, MAX(delivery_date) AS latest_delivery
        FROM freshbasket_cleaned
        WHERE delivery_date IS NOT NULL
        GROUP BY product_ID
    ) latest ON fc.product_ID = latest.product_ID 
            AND fc.delivery_date = latest.latest_delivery
) latest_supplier ON f.product_ID = latest_supplier.product_ID
SET f.supplier_name = latest_supplier.supplier;








    

