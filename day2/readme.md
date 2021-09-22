# DATA VALIDATION DAY 2

# Product

1.  Check if the same brand have different category

A brand like DEBE was in category Hair care as well as skin care. Taking business logic as a brand can be specific to one categiry only the test case will be like:
```
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
```
2. Check if mrp is less than price

MRP should not be less than the price of product.
```
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
```
3. Check if the updated date time and created date time are same

The updated date and created date can be same but the time should be different
```
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
```
--4. Check if the products which are not active have no updated date

Products which were active at first but later inactive must have an updated date.

```
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
```
# Sales

--1. check if the products which are not active have records in sales
```
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
```

--2 check if the tax percent is 0 even if tax amount is given
```
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
```

--3 select if a bill no. consists of different customers
```
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
```

--4 check if the quantity of product is equal to 0
```
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
```

# Timesheet

--1. Check if the attendance is true even if the employee has not worked
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
   SELECT * FROM timesheet 
	WHERE hours_worked ='0' AND CAST(attendance AS BOOL) =TRUE
     )t;
```

--2. Check if all the employee id from raw timesheet table are not in transformed timesheet
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
    SELECT employee_id FROM timesheet_raw
    EXCEPT
    SELECT employee_id FROM timesheet
) t;
```
-- 3 CHeck if the employee was on call then the sum of on call hour and hours worked is not equal to 8
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
    SELECT * FROM timesheet 
	WHERE CAST(was_on_call AS BOOL) = TRUE 
	AND (CAST(on_call_hour AS FLOAT) + CAST(hours_worked AS FLOAT)) <> 8
) t;
```

--4 CHeck if the employee is working on many department on same date
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
    SELECT employee_id, shift_date, COUNT(department_id) FROM timesheet
    GROUP BY employee_id, shift_date 
    HAVING COUNT(department_id)>1
) t;
```

--5. Check if the employee has taken break more than 1 hour
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
   SELECT * FROM timesheet 
	WHERE CAST(break_hour AS FLOAT) >1
     )t;
```

# Employee

--1 Check if the manager employee id is not in the employee id.
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
   SELECT DISTINCT(manager_employee_id) 
   FROM employee WHERE manager_employee_id <>''
   EXCEPT
   SELECT client_employee_id FROM employee
     )t;
```

-- 2 Check if the difference between hire date and dob is less than 18
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
   SELECT * FROM employee
	WHERE EXTRACT(YEAR FROM age(CAST(dob AS date))) -EXTRACT(YEAR FROM age(CAST(hire_date AS date))) <18
     )t;
```

--3 checking if the hire_date of the employee is in the future
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
   SELECT hire_date FROM employee e
   WHERE hire_date::TIMESTAMP > LOCALTIMESTAMP
     )t;
```

--4 check if the manager has not the role as manager
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
   SELECT e.client_employee_id 
	FROM employee e
	INNER JOIN employee_raw er ON e.client_employee_id=er.employee_id
	AND e.role<>'Manager'
	WHERE er.employee_role LIKE '%Mgr%' or er.employee_role LIKE '%Supv'
     )t;
```

--5 Check if the weekly_hours is les than weekly hours derived from fte
```
 WITH cte_check_fte AS (
 SELECT CAST(fte AS FLOAT)*40 AS fte_hours_weekly,weekly_hours
 FROM employee
 )
 SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM 
cte_check_fte
WHERE
fte_hours_weekly < CAST(weekly_hours as FLOAT);
```