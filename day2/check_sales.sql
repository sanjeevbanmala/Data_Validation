--1. check if the products which are not active have records in sales
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
    SELECT s.product_id
   FROM sales s
   INNER JOIN product p ON p.product_id = s.product_id
   AND p.active ='N'
     )t;
--2 check if the tax percent is 0 even if tax amount is given
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
   SELECT * from sales 
	WHERE CAST(tax_amt as FLOAT) <> 0 and CAST(tax_pc as float) =0
     )t;

--3 select if a bill no consists of different customers
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
   SELECT  DISTINCT a.customer_id, b.customer_id, a.bill_no
   FROM sales a 
   INNER JOIN sales b
   ON a.bill_no =b.bill_no AND
   a.customer_id <> b.customer_id
     )t;
--4 check if the quantity of product is equal to 0
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
   SELECT * FROM sales 
   WHERE CAST(qty as FLOAT) = 0
     )t;