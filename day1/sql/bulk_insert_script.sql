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