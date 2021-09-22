--1 Check if the manager employee id is not in the employee id.
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

-- 2 Check if the difference between hire date and dob is less than 18
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

--2 checking if the hire_date of the employee is in the future
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

--3 check if the manager has not the role as manager
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



--4 Check if the weekly_hours is les than weekly hours derived from fte
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
