# Employee Management System — Python + MySQL + Excel
### Brand Invent HR Consulting Firm | New Delhi

A complete, database-driven Employee Management System built during my internship
as an HR Analyst Intern at Brand Invent. The project covers the full HR analytics
workflow — from raw dirty data and SQL database management, to Python automation,
Excel-based data cleaning and analysis, and an executive HR dashboard.

Every component mirrors real HR consulting firm operations: managing employee
records, processing exits with audit trails, handling salary revisions, generating
department-wise reports, and producing KPI dashboards — all backed by a live
MySQL database so no data is ever lost between sessions.

---

## Project Structure
employee-management-system/

│

├── employee_management.py        # Python — menu-driven HR management interface

├── employee_db.sql               # MySQL — database schema and stored procedures

├── extended_dataset.sql          # MySQL — 32 employee seed data + exits + promotions

├── Brand_Invent_HR_Analytics.xlsx  # Excel — 9-sheet HR analytics workbook

├── Brand_Invent_HR_Dashboard.pdf   # PDF  — executive HR dashboard report

│

├── README.md                     # Project overview (this file)

├── data_description.md           # Database tables and dataset explanation

├── python_description.md         # Python functions and logic explanation

├── sql_description.md            # SQL procedures and schema explanation

└── excel_description.md          # Excel sheets and formulas explanation

---

## What This Project Covers

### Python
- Menu-driven interface with 9 operations
- Connects live to MySQL database using mysql-connector-python
- Add employee, process exit with reason, promote with salary revision
- Display full employee directory, search by ID, department-wise report
- HR Dashboard KPI summary, salary revision audit log, exit log
- Transaction management with commit() and rollback() for data integrity

### MySQL
- 4 relational tables: employees, departments, salary_revision_log, exit_log
- 8 stored procedures handling all HR operations
- Gross salary auto-calculated as a GENERATED column (Basic + HRA + Allowances)
- Soft delete on exit — records never hard deleted (industry standard)
- Full audit trail: every promotion and exit permanently logged

### Excel
- 9-sheet workbook covering the complete data analytics pipeline
- Sheet 1: Raw dirty data with intentional errors for cleaning demonstration
- Sheet 2: 14-step data cleaning log documenting every transformation
- Sheet 3: Cleaned master dataset — 32 employees, zero errors
- Sheet 4: Employee master with computed fields (age, years of service, salary grade)
- Sheet 5: Department-wise workforce summary
- Sheet 6: Salary analysis using AVERAGEIF, SUMPRODUCT, COUNTIFS, MEDIAN
- Sheet 7: Attrition analysis — 15.6% attrition rate, exit log, retention rate
- Sheet 8: Salary revision audit log — 10 promotions with increment percentages
- Sheet 9: Executive HR dashboard — all values driven by live formulas

---

## Key HR Metrics (from the dataset)

| Metric | Value |
|---|---|
| Total Employees | 32 |
| Active Staff | 27 |
| Attrition Rate | 15.6% |
| Retention Rate | 84.4% |
| Total Departments | 6 |
| Average Basic Salary | Rs. 48,200/month |
| Total Gross Payroll | Rs. 18,40,000/month |
| Total Promotions (FY24–26) | 10 |
| Total Exits | 5 |

---

## Database Structure

| Table | Purpose |
|---|---|
| `employees` | Core HR master record — 17 fields per employee |
| `departments` | Department directory with head and location |
| `salary_revision_log` | Audit trail of every promotion and salary change |
| `exit_log` | Permanent record of every employee exit with reason |

---

## Excel Functions Used

`DATEDIF` `IF (nested)` `COUNTIF` `COUNTIFS` `AVERAGEIF`
`SUMIF` `SUMPRODUCT` `COUNTA` `MAX` `MIN` `MEDIAN` `SUM`

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Python 3 | Application logic, menu interface, DB connection |
| MySQL | Relational database with stored procedures |
| mysql-connector-python | Python to MySQL bridge |
| Excel / openpyxl | HR analytics workbook with 9 sheets |
| ReportLab + Matplotlib | PDF dashboard generation |

---

## Prerequisites

- Python 3.x
- MySQL Server
- mysql-connector-python

```bash
pip install mysql-connector-python
```

---

## Setup & Run

**Step 1 — Set up the database:**
```bash
mysql -u root -p < employee_db.sql
```

**Step 2 — Load the full 32-employee dataset:**
```bash
mysql -u root -p < extended_dataset.sql
```

**Step 3 — Run the Python interface:**
```bash
python employee_management.py
```

**Step 4 — Open the Excel file:**
Open `Brand_Invent_HR_Analytics.xlsx` in Microsoft Excel or LibreOffice Calc.
All formulas calculate automatically — no manual input needed.

---

## Python Menu Options
[1]  Add New Employee

[2]  Process Employee Exit (Remove)

[3]  Promote Employee / Salary Revision

[4]  Display All Employees

[5]  Search Employee by ID

[6]  Department-Wise Employee Report

[7]  HR Dashboard — KPI Summary

[8]  Salary Revision Audit Log

[9]  Employee Exit Log

[0]  Exit System

---

## Key Concepts Demonstrated

- End-to-end HR data pipeline from raw data to executive dashboard
- Relational database design with foreign keys and referential integrity
- Stored procedures for encapsulated, reusable database logic
- Data cleaning documentation with before/after audit trail
- Soft delete pattern — exited employees retained for compliance
- Salary grade classification using nested IF without VBA
- Live formula-driven dashboard — updates automatically with source data
- Transaction management (commit / rollback) for safe DB writes
- GENERATED columns in MySQL for auto-computed gross salary
- Cross-sheet formula referencing in Excel for single-source-of-truth design

---

## Context

This project was built as a technical extension of my NTCC internship report
at Brand Invent, where I worked as an HR Analyst Intern (May–July 2026).
The system operationalises the four core HR analyst functions documented in
the report — employee record management, exit processing, salary revision,
and workforce reporting — through Python automation, a MySQL backend, and
an Excel analytics workbook.

It directly reflects the HR data management, employee record validation,
and analytics maturity progression (Level 1 → Level 2) discussed in the
internship report, and demonstrates applied database-driven HR analytics
using industry-standard tools.

---

## Files at a Glance

| File | Type | Description |
|---|---|---|
| `employee_management.py` | Python | 9-function HR management application |
| `employee_db.sql` | SQL | Database schema + 8 stored procedures |
| `extended_dataset.sql` | SQL | 32 employees + exits + promotions seed data |
| `Brand_Invent_HR_Analytics.xlsx` | Excel | 9-sheet HR analytics workbook |
| `Brand_Invent_HR_Dashboard.pdf` | PDF | 4-page executive dashboard report |
| `data_description.md` | Docs | Dataset and table structure explanation |
| `python_description.md` | Docs | Python functions and logic explanation |
| `sql_description.md` | Docs | SQL procedures and schema explanation |
| `excel_description.md` | Docs | Excel sheets and formulas explanation |
