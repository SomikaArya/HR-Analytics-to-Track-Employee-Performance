# Data Description

## Overview

The Employee Management System uses a MySQL relational database named
`brand_invent_hr` containing 4 tables that together replicate the complete
HR data infrastructure of a consulting firm.

---

## Table 1 - `departments`

Stores all departments of Brand Invent.

| Column | Type | Description |
|---|---|---|
| `dept_id` | INT, AUTO_INCREMENT, PK | Unique department identifier |
| `dept_name` | VARCHAR(100) | Name of the department |
| `dept_head` | VARCHAR(100) | Name of the department head |
| `location` | VARCHAR(100) | Office location (default: New Delhi) |

**Departments in the system:**
- Human Resources
- Recruitment & Talent
- HR Analytics & Data
- Organizational Development
- Finance & Accounts

---

## Table 2 - `employees`

Core HR master record. Every employee in Brand Invent has one row here.

| Column | Type | Description |
|---|---|---|
| `emp_id` | INT, PK | Unique employee ID (e.g. 1001) |
| `emp_name` | VARCHAR(100) | Full name |
| `gender` | ENUM | Male / Female / Other |
| `date_of_birth` | DATE | Used for age and compliance tracking |
| `contact_number` | VARCHAR(15) | Mobile number |
| `email` | VARCHAR(100), UNIQUE | Official company email |
| `designation` | VARCHAR(100) | Job title |
| `dept_id` | INT, FK | Links to departments table |
| `employment_type` | ENUM | Full-Time / Part-Time / Intern / Contract |
| `date_of_joining` | DATE | Joining date |
| `basic_salary` | DECIMAL(10,2) | Base pay component |
| `hra` | DECIMAL(10,2) | House Rent Allowance |
| `allowances` | DECIMAL(10,2) | Other allowances (travel, food, etc.) |
| `gross_salary` | DECIMAL(10,2), GENERATED | Auto-calculated: Basic + HRA + Allowances |
| `employment_status` | ENUM | Active / Resigned / Terminated / On Leave |
| `reporting_manager` | VARCHAR(100) | Direct reporting manager's name |
| `created_at` | TIMESTAMP | Auto-recorded on insert |
| `updated_at` | TIMESTAMP | Auto-updated on every change |

**Key design decision:**
`gross_salary` is a GENERATED column - MySQL calculates it automatically
whenever basic salary, HRA, or allowances change. It is never entered manually.

---

## Table 3 - `salary_revision_log`

Audit trail for every salary revision and promotion.

| Column | Type | Description |
|---|---|---|
| `log_id` | INT, AUTO_INCREMENT, PK | Unique log entry ID |
| `emp_id` | INT, FK | Employee whose salary changed |
| `emp_name` | VARCHAR(100) | Captured at time of revision |
| `designation` | VARCHAR(100) | New designation after promotion |
| `old_basic` | DECIMAL(10,2) | Salary before revision |
| `increment_amount` | DECIMAL(10,2) | Amount of raise given |
| `new_basic` | DECIMAL(10,2) | Salary after revision |
| `revision_date` | TIMESTAMP | Auto-recorded date and time |
| `revised_by` | VARCHAR(100) | Who processed the revision |
| `remarks` | VARCHAR(255) | Reason or notes for revision |

---

## Table 4 — `exit_log`

Permanent record of every employee who has left the organization.

| Column | Type | Description |
|---|---|---|
| `exit_id` | INT, AUTO_INCREMENT, PK | Unique exit record ID |
| `emp_id` | INT, FK | Employee who exited |
| `emp_name` | VARCHAR(100) | Name at time of exit |
| `designation` | VARCHAR(100) | Last held designation |
| `dept_name` | VARCHAR(100) | Department at time of exit |
| `date_of_joining` | DATE | Original joining date |
| `exit_date` | TIMESTAMP | Auto-recorded exit date and time |
| `exit_reason` | ENUM | Resignation / Termination / Contract End / Retirement |
| `exit_processed_by` | VARCHAR(100) | HR analyst who processed it |

---

## Sample Data

10 employees are pre-loaded to reflect a realistic Brand Invent org chart:

| Emp ID | Name | Designation | Department | Type |
|---|---|---|---|---|
| 1001 | Anita Sharma | HR Director | Human Resources | Full-Time |
| 1002 | Rajiv Mehra | Recruitment Manager | Recruitment & Talent | Full-Time |
| 1003 | Priya Kapoor | HR Analytics Lead | HR Analytics & Data | Full-Time |
| 1004 | Suresh Nair | OD Consultant | Organizational Development | Full-Time |
| 1005 | Neha Gupta | Finance Manager | Finance & Accounts | Full-Time |
| 1006 | Arjun Verma | HR Analyst | HR Analytics & Data | Full-Time |
| 1007 | Deepika Singh | Recruiter | Recruitment & Talent | Full-Time |
| 1008 | Karan Malhotra | Junior HR Analyst | HR Analytics & Data | Full-Time |
| 1009 | Ritika Joshi | HR Executive | Human Resources | Full-Time |
| 1010 | Somika Arya | HR Analyst Intern | HR Analytics & Data | Intern |

---

## Relationships
departments (dept_id)

|

|----< employees (dept_id FK)

|

|----< salary_revision_log (emp_id FK)

|

|----< exit_log (emp_id FK)

All foreign key relationships ensure referential integrity -
you cannot add an employee to a department that does not exist,
and all logs remain linked to their source employee record.
