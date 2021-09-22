--1. check if the same brand have different category
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
   SELECT  DISTINCT INITCAP(a.category), INITCAP(b.category), a.brand
FROM product b 
INNER JOIN product a
ON a.brand =b.brand and
INITCAP(a.category) <> INITCAP(b.category)
) t;

-- 2. Check if mrp is less than price
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
    SELECT * FROM product 
	WHERE CAST(mrp AS FLOAT) < CAST(price AS FLOAT)
     )t;
-- 3. Check if the updated date time and created date time are same
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
    SELECT * FROM product 
	WHERE updated_date :: TIMESTAMP <= created_date :: TIMESTAMP
     )t;
	 
--4. check if the products which are not active have no updated date
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
    SELECT * FROM product 
	WHERE active ='N' AND updated_date IS NULL
     )t;
