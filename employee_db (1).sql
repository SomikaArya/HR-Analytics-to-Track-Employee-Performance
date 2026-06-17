-- ============================================================
--  BRAND INVENT — HR CONSULTING FIRM
--  Employee Management System — Database Setup
--  Created by : Somika Arya | HR Analyst Intern
--  Organization: Brand Invent, New Delhi
--  Tool        : MySQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS brand_invent_hr;
USE brand_invent_hr;

-- ============================================================
-- TABLE: departments
-- Stores all departments in the consulting firm
-- ============================================================
CREATE TABLE IF NOT EXISTS departments (
    dept_id       INT PRIMARY KEY AUTO_INCREMENT,
    dept_name     VARCHAR(100) NOT NULL,
    dept_head     VARCHAR(100),
    location      VARCHAR(100) DEFAULT 'New Delhi'
);

-- ============================================================
-- TABLE: employees
-- Core employee master table — mirrors real HR consulting data
-- ============================================================
CREATE TABLE IF NOT EXISTS employees (
    emp_id              INT PRIMARY KEY,
    emp_name            VARCHAR(100)    NOT NULL,
    gender              ENUM('Male', 'Female', 'Other') NOT NULL,
    date_of_birth       DATE            NOT NULL,
    contact_number      VARCHAR(15)     NOT NULL,
    email               VARCHAR(100)    UNIQUE NOT NULL,
    designation         VARCHAR(100)    NOT NULL,
    dept_id             INT,
    employment_type     ENUM('Full-Time', 'Part-Time', 'Intern', 'Contract') DEFAULT 'Full-Time',
    date_of_joining     DATE            NOT NULL,
    basic_salary        DECIMAL(10,2)   NOT NULL,
    hra                 DECIMAL(10,2)   DEFAULT 0.00,
    allowances          DECIMAL(10,2)   DEFAULT 0.00,
    gross_salary        DECIMAL(10,2)   GENERATED ALWAYS AS (basic_salary + hra + allowances) STORED,
    employment_status   ENUM('Active', 'Resigned', 'Terminated', 'On Leave') DEFAULT 'Active',
    reporting_manager   VARCHAR(100),
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- ============================================================
-- TABLE: salary_revision_log
-- Tracks every salary change — promotion audit trail
-- ============================================================
CREATE TABLE IF NOT EXISTS salary_revision_log (
    log_id          INT PRIMARY KEY AUTO_INCREMENT,
    emp_id          INT NOT NULL,
    emp_name        VARCHAR(100),
    designation     VARCHAR(100),
    old_basic       DECIMAL(10,2),
    increment_amount DECIMAL(10,2),
    new_basic       DECIMAL(10,2),
    revision_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revised_by      VARCHAR(100) DEFAULT 'HR Analyst',
    remarks         VARCHAR(255),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- ============================================================
-- TABLE: exit_log
-- Records every employee removal with reason
-- ============================================================
CREATE TABLE IF NOT EXISTS exit_log (
    exit_id         INT PRIMARY KEY AUTO_INCREMENT,
    emp_id          INT NOT NULL,
    emp_name        VARCHAR(100),
    designation     VARCHAR(100),
    dept_name       VARCHAR(100),
    date_of_joining DATE,
    exit_date       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    exit_reason     ENUM('Resignation', 'Termination', 'Contract End', 'Retirement') DEFAULT 'Resignation',
    exit_processed_by VARCHAR(100) DEFAULT 'HR Analyst'
);

-- ============================================================
-- DROP OLD PROCEDURES (safe re-run)
-- ============================================================
DROP PROCEDURE IF EXISTS check_employee;
DROP PROCEDURE IF EXISTS add_employee;
DROP PROCEDURE IF EXISTS remove_employee;
DROP PROCEDURE IF EXISTS promote_employee;
DROP PROCEDURE IF EXISTS display_all_employees;
DROP PROCEDURE IF EXISTS display_employee_by_id;
DROP PROCEDURE IF EXISTS display_by_department;
DROP PROCEDURE IF EXISTS display_active_employees;
DROP PROCEDURE IF EXISTS hr_dashboard_summary;

DELIMITER $$

-- ============================================================
-- PROCEDURE 1: check_employee
-- Checks if an employee exists by emp_id
-- ============================================================
CREATE PROCEDURE check_employee(
    IN  p_emp_id  INT,
    OUT p_exists  TINYINT
)
BEGIN
    SELECT COUNT(*) INTO p_exists
    FROM employees
    WHERE emp_id = p_emp_id;
END$$

-- ============================================================
-- PROCEDURE 2: add_employee
-- Inserts a full employee record into the system
-- ============================================================
CREATE PROCEDURE add_employee(
    IN p_emp_id           INT,
    IN p_emp_name         VARCHAR(100),
    IN p_gender           VARCHAR(10),
    IN p_dob              DATE,
    IN p_contact          VARCHAR(15),
    IN p_email            VARCHAR(100),
    IN p_designation      VARCHAR(100),
    IN p_dept_id          INT,
    IN p_emp_type         VARCHAR(20),
    IN p_doj              DATE,
    IN p_basic_salary     DECIMAL(10,2),
    IN p_hra              DECIMAL(10,2),
    IN p_allowances       DECIMAL(10,2),
    IN p_reporting_manager VARCHAR(100)
)
BEGIN
    DECLARE v_exists TINYINT;
    CALL check_employee(p_emp_id, v_exists);

    IF v_exists = 1 THEN
        SELECT CONCAT('ERROR: Employee ID ', p_emp_id, ' already exists in the system.') AS status_message;
    ELSE
        INSERT INTO employees (
            emp_id, emp_name, gender, date_of_birth, contact_number,
            email, designation, dept_id, employment_type,
            date_of_joining, basic_salary, hra, allowances,
            employment_status, reporting_manager
        ) VALUES (
            p_emp_id, p_emp_name, p_gender, p_dob, p_contact,
            p_email, p_designation, p_dept_id, p_emp_type,
            p_doj, p_basic_salary, p_hra, p_allowances,
            'Active', p_reporting_manager
        );
        SELECT CONCAT('SUCCESS: Employee ', p_emp_name, ' (ID: ', p_emp_id, ') added successfully.') AS status_message;
    END IF;
END$$

-- ============================================================
-- PROCEDURE 3: remove_employee
-- Marks employee as resigned/terminated and logs exit
-- ============================================================
CREATE PROCEDURE remove_employee(
    IN p_emp_id     INT,
    IN p_exit_reason VARCHAR(50)
)
BEGIN
    DECLARE v_exists      TINYINT;
    DECLARE v_name        VARCHAR(100);
    DECLARE v_designation VARCHAR(100);
    DECLARE v_dept        VARCHAR(100);
    DECLARE v_doj         DATE;

    CALL check_employee(p_emp_id, v_exists);

    IF v_exists = 0 THEN
        SELECT CONCAT('ERROR: Employee ID ', p_emp_id, ' not found in the system.') AS status_message;
    ELSE
        -- Fetch details before removing
        SELECT emp_name, designation, date_of_joining
        INTO v_name, v_designation, v_doj
        FROM employees WHERE emp_id = p_emp_id;

        SELECT dept_name INTO v_dept
        FROM departments d
        JOIN employees e ON e.dept_id = d.dept_id
        WHERE e.emp_id = p_emp_id;

        -- Log exit record
        INSERT INTO exit_log (emp_id, emp_name, designation, dept_name, date_of_joining, exit_reason)
        VALUES (p_emp_id, v_name, v_designation, v_dept, v_doj, p_exit_reason);

        -- Update status instead of hard delete (best HR practice)
        UPDATE employees SET employment_status = p_exit_reason WHERE emp_id = p_emp_id;

        SELECT CONCAT('SUCCESS: Employee ', v_name, ' (ID: ', p_emp_id,
                      ') exit processed. Reason: ', p_exit_reason, '.') AS status_message;
    END IF;
END$$

-- ============================================================
-- PROCEDURE 4: promote_employee
-- Updates designation and increases basic salary; logs revision
-- ============================================================
CREATE PROCEDURE promote_employee(
    IN p_emp_id          INT,
    IN p_new_designation VARCHAR(100),
    IN p_increment_amount DECIMAL(10,2),
    IN p_remarks         VARCHAR(255)
)
BEGIN
    DECLARE v_exists       TINYINT;
    DECLARE v_name         VARCHAR(100);
    DECLARE v_old_basic    DECIMAL(10,2);
    DECLARE v_new_basic    DECIMAL(10,2);
    DECLARE v_old_desig    VARCHAR(100);

    CALL check_employee(p_emp_id, v_exists);

    IF v_exists = 0 THEN
        SELECT CONCAT('ERROR: Employee ID ', p_emp_id, ' not found in the system.') AS status_message;
    ELSE
        SELECT emp_name, basic_salary, designation
        INTO v_name, v_old_basic, v_old_desig
        FROM employees WHERE emp_id = p_emp_id;

        SET v_new_basic = v_old_basic + p_increment_amount;

        -- Update salary and designation
        UPDATE employees
        SET basic_salary  = v_new_basic,
            designation   = p_new_designation
        WHERE emp_id = p_emp_id;

        -- Log the revision
        INSERT INTO salary_revision_log (emp_id, emp_name, designation, old_basic, increment_amount, new_basic, remarks)
        VALUES (p_emp_id, v_name, p_new_designation, v_old_basic, p_increment_amount, v_new_basic, p_remarks);

        SELECT CONCAT(
            'SUCCESS: ', v_name, ' promoted from [', v_old_desig, '] to [', p_new_designation, ']. ',
            'Salary revised from Rs.', v_old_basic, ' to Rs.', v_new_basic, '.'
        ) AS status_message;
    END IF;
END$$

-- ============================================================
-- PROCEDURE 5: display_all_employees
-- Full employee directory — HR master report view
-- ============================================================
CREATE PROCEDURE display_all_employees()
BEGIN
    SELECT
        e.emp_id                            AS 'Emp ID',
        e.emp_name                          AS 'Full Name',
        e.gender                            AS 'Gender',
        e.designation                       AS 'Designation',
        d.dept_name                         AS 'Department',
        e.employment_type                   AS 'Type',
        e.date_of_joining                   AS 'Date of Joining',
        TIMESTAMPDIFF(YEAR, e.date_of_joining, CURDATE())  AS 'Years of Service',
        e.contact_number                    AS 'Contact',
        e.email                             AS 'Email',
        e.basic_salary                      AS 'Basic Salary (Rs.)',
        e.hra                               AS 'HRA (Rs.)',
        e.allowances                        AS 'Allowances (Rs.)',
        e.gross_salary                      AS 'Gross Salary (Rs.)',
        e.employment_status                 AS 'Status',
        e.reporting_manager                 AS 'Reporting Manager'
    FROM employees e
    LEFT JOIN departments d ON e.dept_id = d.dept_id
    ORDER BY e.emp_id;
END$$

-- ============================================================
-- PROCEDURE 6: display_employee_by_id
-- Single employee full profile
-- ============================================================
CREATE PROCEDURE display_employee_by_id(IN p_emp_id INT)
BEGIN
    DECLARE v_exists TINYINT;
    CALL check_employee(p_emp_id, v_exists);

    IF v_exists = 0 THEN
        SELECT CONCAT('ERROR: Employee ID ', p_emp_id, ' not found.') AS status_message;
    ELSE
        SELECT
            e.emp_id                AS 'Emp ID',
            e.emp_name              AS 'Full Name',
            e.gender                AS 'Gender',
            e.date_of_birth         AS 'Date of Birth',
            e.contact_number        AS 'Contact',
            e.email                 AS 'Email ID',
            e.designation           AS 'Designation',
            d.dept_name             AS 'Department',
            e.employment_type       AS 'Employment Type',
            e.date_of_joining       AS 'Date of Joining',
            TIMESTAMPDIFF(YEAR, e.date_of_joining, CURDATE()) AS 'Years of Service',
            e.basic_salary          AS 'Basic Salary (Rs.)',
            e.hra                   AS 'HRA (Rs.)',
            e.allowances            AS 'Allowances (Rs.)',
            e.gross_salary          AS 'Gross Salary (Rs.)',
            e.employment_status     AS 'Status',
            e.reporting_manager     AS 'Reporting Manager'
        FROM employees e
        LEFT JOIN departments d ON e.dept_id = d.dept_id
        WHERE e.emp_id = p_emp_id;
    END IF;
END$$

-- ============================================================
-- PROCEDURE 7: display_by_department
-- Department-wise employee listing
-- ============================================================
CREATE PROCEDURE display_by_department(IN p_dept_name VARCHAR(100))
BEGIN
    SELECT
        e.emp_id            AS 'Emp ID',
        e.emp_name          AS 'Full Name',
        e.designation       AS 'Designation',
        e.employment_type   AS 'Type',
        e.basic_salary      AS 'Basic Salary (Rs.)',
        e.gross_salary      AS 'Gross Salary (Rs.)',
        e.employment_status AS 'Status'
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    WHERE d.dept_name LIKE CONCAT('%', p_dept_name, '%')
    ORDER BY e.emp_id;
END$$

-- ============================================================
-- PROCEDURE 8: hr_dashboard_summary
-- KPI Summary — total headcount, salary, department breakdown
-- ============================================================
CREATE PROCEDURE hr_dashboard_summary()
BEGIN
    -- Overall headcount
    SELECT
        COUNT(*)                                                AS 'Total Employees',
        SUM(CASE WHEN employment_status = 'Active' THEN 1 ELSE 0 END)     AS 'Active',
        SUM(CASE WHEN employment_status = 'Resigned' THEN 1 ELSE 0 END)   AS 'Resigned',
        SUM(CASE WHEN employment_status = 'On Leave' THEN 1 ELSE 0 END)   AS 'On Leave',
        SUM(CASE WHEN employment_type  = 'Intern'    THEN 1 ELSE 0 END)   AS 'Interns',
        ROUND(AVG(basic_salary), 2)                                        AS 'Avg Basic Salary (Rs.)',
        SUM(gross_salary)                                                  AS 'Total Gross Payroll (Rs.)'
    FROM employees;

    -- Department-wise headcount
    SELECT
        d.dept_name         AS 'Department',
        COUNT(e.emp_id)     AS 'Headcount',
        ROUND(AVG(e.basic_salary), 2) AS 'Avg Salary (Rs.)',
        SUM(e.gross_salary) AS 'Dept Payroll (Rs.)'
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    GROUP BY d.dept_name
    ORDER BY Headcount DESC;
END$$

DELIMITER ;

-- ============================================================
-- SEED DATA: Departments
-- ============================================================
INSERT INTO departments (dept_name, dept_head, location) VALUES
('Human Resources',          'Anita Sharma',    'New Delhi'),
('Recruitment & Talent',     'Rajiv Mehra',     'New Delhi'),
('HR Analytics & Data',      'Priya Kapoor',    'New Delhi'),
('Organizational Development','Suresh Nair',    'New Delhi'),
('Finance & Accounts',       'Neha Gupta',      'New Delhi');

-- ============================================================
-- SEED DATA: Employees (realistic HR consulting firm data)
-- ============================================================
CALL add_employee(1001, 'Anita Sharma',   'Female', '1985-03-12', '9810012345', 'anita.sharma@brandinvent.org',   'HR Director',             1, 'Full-Time', '2017-06-01', 95000.00, 28500.00, 12000.00, 'CEO');
CALL add_employee(1002, 'Rajiv Mehra',    'Male',   '1988-07-22', '9820023456', 'rajiv.mehra@brandinvent.org',    'Recruitment Manager',     2, 'Full-Time', '2018-03-15', 72000.00, 21600.00, 9000.00,  'HR Director');
CALL add_employee(1003, 'Priya Kapoor',   'Female', '1990-11-05', '9830034567', 'priya.kapoor@brandinvent.org',   'HR Analytics Lead',       3, 'Full-Time', '2019-08-01', 68000.00, 20400.00, 8500.00,  'HR Director');
CALL add_employee(1004, 'Suresh Nair',    'Male',   '1987-01-30', '9840045678', 'suresh.nair@brandinvent.org',    'OD Consultant',           4, 'Full-Time', '2020-01-10', 65000.00, 19500.00, 8000.00,  'HR Director');
CALL add_employee(1005, 'Neha Gupta',     'Female', '1992-05-18', '9850056789', 'neha.gupta@brandinvent.org',     'Finance Manager',         5, 'Full-Time', '2019-11-20', 60000.00, 18000.00, 7500.00,  'HR Director');
CALL add_employee(1006, 'Arjun Verma',    'Male',   '1994-09-14', '9860067890', 'arjun.verma@brandinvent.org',    'HR Analyst',              3, 'Full-Time', '2021-06-01', 45000.00, 13500.00, 5500.00,  'Priya Kapoor');
CALL add_employee(1007, 'Deepika Singh',  'Female', '1996-02-28', '9870078901', 'deepika.singh@brandinvent.org',  'Recruiter',               2, 'Full-Time', '2022-03-01', 40000.00, 12000.00, 5000.00,  'Rajiv Mehra');
CALL add_employee(1008, 'Karan Malhotra', 'Male',   '1997-12-10', '9880089012', 'karan.malhotra@brandinvent.org', 'Junior HR Analyst',       3, 'Full-Time', '2023-07-15', 35000.00, 10500.00, 4500.00,  'Priya Kapoor');
CALL add_employee(1009, 'Ritika Joshi',   'Female', '1999-08-25', '9890090123', 'ritika.joshi@brandinvent.org',   'HR Executive',            1, 'Full-Time', '2023-09-01', 32000.00, 9600.00,  4000.00,  'Anita Sharma');
CALL add_employee(1010, 'Somika Arya',    'Female', '2003-04-15', '9900101234', 'somika.arya@brandinvent.org',    'HR Analyst Intern',       3, 'Intern',    '2026-05-13', 15000.00, 0.00,     2000.00,  'Priya Kapoor');

-- ============================================================
-- TEST CALLS
-- ============================================================

-- View all employees
CALL display_all_employees();

-- View single employee profile
CALL display_employee_by_id(1010);

-- View HR Analytics department
CALL display_by_department('HR Analytics');

-- Promote an employee
CALL promote_employee(1006, 'Senior HR Analyst', 8000.00, 'Annual appraisal - exceeds expectations');

-- Process an exit
CALL remove_employee(1008, 'Resignation');

-- HR Dashboard KPI Summary
CALL hr_dashboard_summary();

-- View salary revision log
SELECT * FROM salary_revision_log;

-- View exit log
SELECT * FROM exit_log;
