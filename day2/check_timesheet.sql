--1. Check if the attendance is true even if the employee has not worked
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
--2. Check if all the employee id from raw timesheet table are not in transformed timesheet
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

-- 3 CHeck if the employee was on call then the sum of on call hour and hours worked is not equal to 8
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

--4 CHeck if the employee is working on many department on same date
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

--5. Check if the employee has taken break more than 1 hour
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