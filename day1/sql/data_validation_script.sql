--Check if a single employee is listed twice with multiple ids.
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

--Check if part time employees are assigned other fte_status.
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM employee
WHERE fte_status = 'Full Time' AND CAST(fte AS FLOAT) <= 0.6;

--Check if termed employees are marked as active.
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_status
FROM employee
WHERE term_date IS NOT NULL AND CAST(is_active as BOOL)=TRUE;
   
--Check if the same product is listed more than once in a single bill.
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

--Check if the customer_id in the sales table does not exist in the customer table.
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

--Check if there are any records where updated_by is not empty but updated_date is empty.
SELECT
    COUNT(*) AS impacted_record_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'failed'
        ELSE 'passed'
    END AS test_result
FROM sales
WHERE updated_by IS NOT NULL AND updated_date IS NULL;

-- Check if there are any hours worked that are greater than 24 hours.
/* It was not mentioned in the question that hours worked was for employee i.e. weekly_hours or
   timesheet hours_worked which maximum value is 8 so i checked for both employee and timesheet
 */
 -- for timesheet
SELECT COUNT(*) AS impacted_record_count,
       CASE
           WHEN COUNT(*) > 0 THEN 'failed'
           ELSE 'passed'
       END  AS test_status
FROM timesheet
WHERE CAST(hours_worked AS FLOAT) > 24;

--for employee sheet
SELECT COUNT(*) AS impacted_record_count,
       CASE
           WHEN COUNT(*) > 0 THEN 'failed'
           ELSE 'passed'
       END  AS test_status
FROM employee
WHERE CAST(weekly_hours AS FLOAT) > 24;

--Check if non on-call employees are set as on-call.
SELECT
	COUNT(*) as impacted_record_count,
	CASE
		WHEN COUNT(*)>0 THEN 'failed'
		ELSE 'passed'
	END AS test_status
FROM
	timesheet t
INNER JOIN timesheet_raw tr 
    ON t.employee_id = tr.employee_id
	AND t.shift_date = tr.punch_apply_date
	AND tr.paycode <> 'ON_CALL'
	AND CAST(t.was_on_call as BOOL) = TRUE;

--Check if the break is true for employees who have not taken a break at all.
SELECT
	COUNT(*) as impacted_record_count,
	CASE
		WHEN COUNT(*)>0 THEN 'failed'
		ELSE 'passed'
	END AS test_status
FROM
	timesheet t
INNER JOIN timesheet_raw tr 
    ON t.employee_id = tr.employee_id
	AND t.shift_date = tr.punch_apply_date
	AND tr.paycode != 'BREAK'
	AND CAST(t.has_taken_break AS BOOL) = TRUE;

--Check if the night shift is not assigned to the employees working on the night shift.
SELECT COUNT(*) AS impacted_record_count,
       CASE
           WHEN COUNT(*) > 0 THEN 'failed'
           ELSE 'passed'
       END  AS test_status
FROM timesheet
WHERE shift_type <> 'Night' AND shift_end_time :: time >= '20:00:00';


