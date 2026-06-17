# SQL Code Description

## File: `employee_db.sql`

Complete database setup file for the Brand Invent Employee Management System.
Run this file once in MySQL Workbench or the MySQL CLI before starting the
Python application.

---

## What This File Does (In Order)

1. Creates the database `brand_invent_hr`
2. Creates 4 tables with proper relationships
3. Drops and recreates 8 stored procedures (safe to re-run)
4. Inserts seed data — 5 departments and 10 employees

---

## Database

```sql
CREATE DATABASE IF NOT EXISTS brand_invent_hr;
USE brand_invent_hr;
```

`IF NOT EXISTS` makes the file safe to run multiple times without errors.

---

## Tables

### `departments`
Lookup table for all Brand Invent departments.
`dept_id` auto-increments — you never set it manually.
`location` defaults to New Delhi if not provided.

### `employees`
Core HR master table with 17 fields.
`gross_salary` is a GENERATED column — MySQL always calculates it as
Basic + HRA + Allowances automatically. Never entered manually.
`employment_status` defaults to Active on insert.
`updated_at` auto-updates every time any field in that row changes.
`dept_id` is a foreign key linking to departments — referential integrity enforced.

### `salary_revision_log`
Append-only audit table. A new row is inserted every time promote_employee
is called. Old rows are never modified. This gives a complete, tamper-proof
history of every salary change.

### `exit_log`
Records every employee exit permanently. Employees are never deleted from
the system — only their status in the employees table changes. This table
captures the full exit record at the moment of processing.

---

## Stored Procedures

### `check_employee(IN p_emp_id, OUT p_exists)`

```sql
SELECT COUNT(*) INTO p_exists FROM employees WHERE emp_id = p_emp_id;
```

Uses an OUT parameter — the result is written into p_exists rather than
returned as a result set. Every other procedure calls this first.
Returns 1 if employee exists, 0 if not.

---

### `add_employee(14 IN parameters)`

Accepts all employee fields as input parameters.
Calls check_employee first — if ID exists, returns error message and stops.
If ID is new, runs INSERT with all 14 fields.
Returns a CONCAT success or error message as a single-column result set.

---

### `remove_employee(IN p_emp_id, IN p_exit_reason)`

Order of operations:
1. Calls check_employee — stops if not found
2. Fetches name, designation, joining date using SELECT INTO variables
3. Fetches department name via JOIN
4. Inserts full exit record into exit_log
5. Updates employment_status in employees table to exit reason value

Does NOT use DELETE. Soft delete by status update is the correct
approach in HR systems for legal and audit compliance.

---

### `promote_employee(IN p_emp_id, IN p_new_designation, IN p_increment_amount, IN p_remarks)`

Order of operations:
1. Calls check_employee — stops if not found
2. Fetches current name, salary, designation into DECLARE variables
3. Calculates new salary using SET
4. Updates employees table — both salary and designation in one UPDATE
5. Inserts full revision record into salary_revision_log

Uses DECLARE for local variables — required in MySQL stored procedures
for intermediate calculations.

---

### `display_all_employees()`

JOIN query between employees and departments.
Calculates Years of Service live using:
```sql
TIMESTAMPDIFF(YEAR, date_of_joining, CURDATE())
```
Returns 16 columns ordered by emp_id.

---

### `display_employee_by_id(IN p_emp_id)`

Same JOIN as display_all_employees but filtered by WHERE emp_id = p_emp_id.
Calls check_employee first — returns error message if not found.

---

### `display_by_department(IN p_dept_name)`

Filters using:
```sql
WHERE d.dept_name LIKE CONCAT('%', p_dept_name, '%')
```
Partial match — typing "HR" returns both "Human Resources"
and "HR Analytics & Data".

---

### `hr_dashboard_summary()`

Returns two result sets in one procedure call:

**Result Set 1 — Overall summary:**
```sql
COUNT(*) total,
SUM(CASE WHEN employment_status = 'Active' THEN 1 ELSE 0 END) active,
ROUND(AVG(basic_salary), 2) avg_salary,
SUM(gross_salary) total_payroll
```

**Result Set 2 — Department breakdown:**
```sql
GROUP BY d.dept_name
ORDER BY Headcount DESC
```

Python reads both result sets using cursor.stored_results().

---

## Key SQL Concepts Used

| Concept | Where Used |
|---|---|
| GENERATED ALWAYS AS | gross_salary auto-calculation |
| ENUM | gender, employment_type, employment_status, exit_reason |
| FOREIGN KEY | dept_id in employees, emp_id in logs |
| OUT parameter | check_employee result |
| DECLARE + SET | Local variables in promote and remove procedures |
| SELECT INTO variable | Fetching single values inside procedures |
| TIMESTAMPDIFF | Years of service calculation |
| CASE WHEN | Conditional counts in dashboard |
| LIKE with wildcard | Department name partial search |
| ON UPDATE CURRENT_TIMESTAMP | Auto-timestamp on record change |
| Soft delete | Status update instead of DELETE |
| DELIMITER $$ | Required for multi-statement procedures in CLI |

---

## How to Run

**MySQL Workbench:**
Open employee_db.sql → Run All (Ctrl + Shift + Enter)

**MySQL CLI:**
```bash
mysql -u root -p < employee_db.sql
```

Safe to run multiple times — all CREATE statements use
`IF NOT EXISTS` and all procedures use `DROP IF EXISTS` before recreating.
