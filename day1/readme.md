# DATA VALIDATION
First of all, the data to be extracted are in data folder.

Then, all tables were created to extract the data from csv file.
The create table script are located in schema folder.
```
CREATE TABLE customer(
	customer_id VARCHAR(500),
	username VARCHAR(500),
	first_name VARCHAR(500),
	last_name VARCHAR(500),
	country VARCHAR(500),
	town VARCHAR(500),
	is_active VARCHAR(500)
);
```
```
CREATE TABLE product(
	product_id VARCHAR(500),
	product_name VARCHAR(500),
	description VARCHAR(500),
	price VARCHAR(500),
	mrp VARCHAR(500),
	pieces_per_case VARCHAR(500),
	weight_per_piece VARCHAR(500),
	uom VARCHAR(500),
	brand VARCHAR(500),
	category VARCHAR(500),
	tax_percent VARCHAR(500),
	active VARCHAR(500),
	created_by VARCHAR(500),
	created_date VARCHAR(500),
	updated_by VARCHAR(500),
	updated_date VARCHAR(500)
);
```
```
CREATE TABLE sales(
	id VARCHAR(500),
	transaction_id VARCHAR(500),
	bill_no VARCHAR(500),
	bill_date VARCHAR(500),
	bill_location VARCHAR(500),
	customer_id VARCHAR(500),
	product_id VARCHAR(500),
	qty VARCHAR(500),
	uom VARCHAR(500),
	price VARCHAR(500),
	gross_price VARCHAR(500),
	tax_pc VARCHAR(500),
	tax_amt VARCHAR(500),
	discount_pc VARCHAR(500),
	discount_amt VARCHAR(500),
	net_bill_amt VARCHAR(500),
	created_by VARCHAR(500),
	updated_by VARCHAR(500),
	created_date VARCHAR(500),
	updated_date VARCHAR(500)
);
```

```
CREATE TABLE employee_raw(
	employee_id VARCHAR(500),
	first_name VARCHAR(500),
	last_name VARCHAR(500),
	department_id VARCHAR(500),
	department_name VARCHAR(500),
	manager_employee_id VARCHAR(500),
	employee_role VARCHAR(500),
	salary VARCHAR(500),
	hire_date VARCHAR(500),
	terminated_date VARCHAR(500),
	terminated_reason VARCHAR(500),
	dob VARCHAR(500),
	fte VARCHAR(500),
	location VARCHAR(500)
);
```
```
CREATE TABLE employee(
	client_employee_id VARCHAR(500),
	department_id VARCHAR(500),
	first_name VARCHAR(500),
	last_name VARCHAR(500),
	manager_employee_id VARCHAR(500),
	salary VARCHAR(500),
	hire_date VARCHAR(500),
	term_date VARCHAR(500),
	term_reason VARCHAR(500),
	dob VARCHAR(500),
	fte VARCHAR(500),
	fte_status VARCHAR(500),
	weekly_hours VARCHAR(500),
	role VARCHAR(500),
	is_active VARCHAR(500)
);
```
```
CREATE TABLE timesheet_raw(
	employee_id VARCHAR(500),
	cost_center VARCHAR(500),
	punch_in_time VARCHAR(500),
	punch_out_time VARCHAR(500),
	punch_apply_date VARCHAR(500),
	hours_worked VARCHAR(500),
	paycode VARCHAR(500)
);
```
```
CREATE TABLE timesheet(
	employee_id VARCHAR(500),
	department_id VARCHAR(500),
	shift_start_time VARCHAR(500),
	shift_end_time VARCHAR(500),
	shift_date VARCHAR(500),
	shift_type VARCHAR(500),
	hours_worked VARCHAR(500),
	attendance VARCHAR(500),
	has_taken_break VARCHAR(500),
	break_hour VARCHAR(500),
	was_charge VARCHAR(500),
	charge_hour VARCHAR(500),
	was_on_call VARCHAR(500),
	on_call_hour VARCHAR(500),
	num_teammates_absent VARCHAR(500)
);
```

For bulk import there are scripts in sql/bulk_insert_script.sql
```
COPY customer(customer_id,username,first_name,last_name,country,town,is_active) 
FROM 'E:\Data_validation\customer.csv'
WITH CSV HEADER;

COPY product
FROM 'E:\Data_validation\product.csv'
WITH CSV HEADER;

COPY sales
FROM 'E:\Data_validation\sales.csv'
WITH CSV HEADER;

COPY employee_raw
FROM 'E:\Data_validation\employee_raw.csv'
WITH CSV HEADER;

COPY employee
FROM 'E:\Data_validation\employee.csv'
WITH CSV HEADER;

COPY timesheet_raw
FROM 'E:\Data_validation\timesheet_raw.csv'
WITH CSV HEADER;

COPY timesheet
FROM 'E:\Data_validation\timesheet.csv'
WITH CSV HEADER;
```

NOw, the data validation part.
1. Check if a single employee is listed twice with multiple ids.

Here, I have groupped client employee id and checked if there are more than one records
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
   SELECT COUNT(client_employee_id) FROM employee
   GROUP BY client_employee_id
   HAVING COUNT(client_employee_id)>1
   ) result;
```

2. Check if part time employees are assigned other fte_status.

I have used logic where part time employees can work 20 hours a week only.
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM employee
WHERE fte_status = 'Part Time' AND CAST(weekly_hours as FLOAT) > 20;
```

3. Check if termed employees are marked as active.

Employees who have been terminated will not have term_date as null.
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM employee
WHERE term_date IS NOT NULL AND is_active='TRUE';
```

4. Check if the same product is listed more than once in a single bill.

I have groupped bill no and product id and checked if in a bill no there are count for a particular product id >1
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM (
	SELECT COUNT(product_id)
    FROM sales
    GROUP BY bill_no, product_id
    HAVING COUNT(product_id)>1
    )result;
```

5. Check if the customer_id in the sales table does not exist in the customer table.

I have used except to see if it gives unmatching results
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_result
FROM (
    SELECT DISTINCT customer_id FROM sales
    EXCEPT
    SELECT customer_id FROM customer
) result;
```

6. Check if there are any records where updated_by is not empty but updated_date is empty.

There were many cases where updated_date was null.
```
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_result
FROM sales
WHERE updated_by IS NOT NULL AND updated_date IS NULL;
```

7. Check if there are any hours worked that are greater than 24 hours.

It was not mentioned in the question that hours worked was for employee i.e. weekly_hours or
   timesheet hours_worked which maximum value is 8 so i checked for both employee and timesheet

For timesheet
```
SELECT COUNT(*) AS impacted_record_count,
       CASE
           WHEN COUNT(*) > 0 THEN 'failed'
           ELSE 'passed'
       END  AS test_status
FROM timesheet
WHERE CAST(hours_worked AS FLOAT) > 24;
```
for employee sheet
```
SELECT COUNT(*) AS impacted_record_count,
       CASE
           WHEN COUNT(*) > 0 THEN 'failed'
           ELSE 'passed'
       END  AS test_status
FROM employee
WHERE CAST(weekly_hours AS FLOAT) > 24;
```

8. Check if non on-call employees are set as on-call.

Those who have on_call_hour as 0 must have was_on_call as true to meet this condition.
```
SELECT COUNT(*) AS impacted_record_count,
       CASE
           WHEN COUNT(*) > 0 THEN 'failed'
           ELSE 'passed'
       END  AS test_status
FROM timesheet
WHERE CAST(on_call_hour AS FLOAT) = 0 AND was_on_call = 'true';
```

9. Check if the break is true for employees who have not taken a break at all.

Those who have break_hour as 0 must have has_taken_break as true to meet this condition.

```
SELECT COUNT(*) AS impacted_record_count,
       CASE
           WHEN COUNT(*) > 0 THEN 'failed'
           ELSE 'passed'
       END  AS test_status
FROM timesheet
WHERE CAST(break_hour AS FLOAT) = 0 AND has_taken_break = 'true';
```

10. Check if the night shift is not assigned to the employees working on the night shift.

There is no night shift in the data so i have used day shift.
if the start time is greater than 14:00:00 it's evening shift and if the condition matches there is error in shift day.
```
SELECT COUNT(*) AS impacted_record_count,
       CASE
           WHEN COUNT(*) > 0 THEN 'failed'
           ELSE 'passed'
       END  AS test_status
FROM timesheet
WHERE shift_type = 'Day' AND shift_start_time :: time >'14:00:00';
```