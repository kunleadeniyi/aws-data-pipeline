CREATE table IF NOT EXISTS hr.employees  
( 
    employee_id    INTEGER CONSTRAINT emp_emp_id_pk PRIMARY KEY, 
    first_name     VARCHAR(20),
    last_name      VARCHAR(25)  CONSTRAINT emp_last_name_nn NOT NULL, 
    email          VARCHAR(25)  CONSTRAINT emp_email_nn NOT NULL, CONSTRAINT emp_email_uk UNIQUE (email),  
    phone_number   VARCHAR(20),
    hire_date      DATE  CONSTRAINT emp_hire_date_nn NOT NULL,
    job_id         VARCHAR(10)  CONSTRAINT emp_job_nn NOT NULL,  
    salary         NUMERIC(8,2)  CONSTRAINT emp_salary_min CHECK (salary > 0),
    commission_pct NUMERIC(4,2),
    manager_id     INTEGER CONSTRAINT emp_manager_fk REFERENCES employees(employee_id),
    department_id  INTEGER
);

CREATE table IF NOT EXISTS hr.employees_audit
( 
    employee_id    integer,
    first_name     VARCHAR(20),  
    last_name      VARCHAR(25),  
    email          VARCHAR(25),
    phone_number   VARCHAR(20),  
    hire_date      DATE,
    job_id         VARCHAR(10),
    salary         NUMERIC(8,2),  
    commission_pct NUMERIC(4,2),  
    manager_id     INTEGER,  
    department_id  integer, 
    date_changed   DATE constraint emp_aud_date_change not null,
    client_ip 	 VARCHAR(25),
    client_host_name VARCHAR(25),
    client_db_username VARCHAR(30),
    client_application varchar(80)
);