# Python Code Description

## File: `employee_management.py`

The main application script. Connects to the MySQL database and provides
a fully menu-driven HR management interface with 9 operational functions.

---

## Database Connection

```python
def create_connection():
    con = mysql.connector.connect(
        host="localhost", user="root",
        password="password", database="brand_invent_hr"
    )
    return con
```

Creates and returns a MySQL connection object using mysql-connector-python.
Called once at program start. If connection fails, the program exits with
a clear error message instead of crashing silently.

---

## Display Helper Functions

Three utility functions used by every menu option for consistent formatting:

| Function | Purpose |
|---|---|
| `print_header(title)` | Prints the Brand Invent header with section title |
| `print_divider()` | Prints a separator line between records |
| `print_row(label, value)` | Prints one field in aligned label: value format |

---

## Core Functions

### `check_employee(cursor, emp_id)`
Calls the SQL stored procedure `check_employee` and returns True if the
employee exists, False if not. Called inside every other function before
any database operation is attempted.

---

### `get_departments(cursor)`
Runs `SELECT dept_id, dept_name FROM departments` and returns the list.
Used in add_employee to show available departments before taking input.

---

### `add_employee(con, cursor)` — Menu Option 1

**What it does:**
1. Displays available departments fetched live from the database
2. Takes 14 inputs from the user covering all HR profile fields
3. Calls check_employee to verify the ID is not already taken
4. Calls SQL stored procedure `add_employee` via cursor.callproc()
5. Commits the transaction to save permanently
6. Prints success or error message returned from SQL
7. Calculates and displays gross salary immediately after adding

**Error handling:**
- ValueError catch prevents crashes if user enters wrong data type
- Rollback on any database error to maintain data integrity

---

### `remove_employee(con, cursor)` — Menu Option 2

**What it does:**
1. Takes emp_id input
2. Verifies employee exists via check_employee
3. Fetches and displays current employee details before proceeding
4. Shows 4 exit reason options: Resignation / Termination / Contract End / Retirement
5. Requires explicit "yes" confirmation before processing
6. Calls SQL stored procedure which logs exit and updates status to resigned/terminated
7. Employee record is NOT deleted — only status is updated (industry standard)

**Key design:** The confirmation step prevents accidental exit processing.

---

### `promote_employee(con, cursor)` — Menu Option 3

**What it does:**
1. Takes emp_id input
2. Fetches and displays current designation and salary on screen
3. Takes new designation, increment amount, and remarks as input
4. Calls SQL stored procedure which updates salary and designation
5. Logs the revision in salary_revision_log automatically
6. Returns confirmation showing old salary and new salary

---

### `display_all_employees(cursor)` — Menu Option 4

Calls `display_all_employees` stored procedure and formats output.
Shows all 16 fields for every employee in the system. Displays
total record count at the top before listing records.

---

### `search_employee(cursor)` — Menu Option 5

Takes one emp_id and displays that employee's complete 17-field
profile using `display_employee_by_id` stored procedure. Used for
quick individual lookups without scrolling through the full directory.

---

### `display_by_department(cursor)` — Menu Option 6

Shows department list first. Takes department name input and fetches
only employees in that department. Displays headcount at the top
followed by each employee's designation, salary, and status.

---

### `hr_dashboard(cursor)` — Menu Option 7

Calls `hr_dashboard_summary` which returns two result sets.
Formats and displays both:

**Block 1 — Overall KPIs:**
- Total employees, Active count, Resigned count, On Leave count
- Intern count, Average basic salary, Total gross payroll

**Block 2 — Department breakdown:**
- Per department: headcount, average salary, total payroll

This is the HR analyst's primary reporting output.

---

### `view_salary_log(cursor)` — Menu Option 8

Queries `salary_revision_log` ordered by most recent first.
Displays every promotion ever processed — employee name, old salary,
increment, new salary, date, and remarks. Full audit trail.

---

### `view_exit_log(cursor)` — Menu Option 9

Queries `exit_log` ordered by most recent first.
Displays every employee exit — name, designation, department,
joining date, exit date, and exit reason. Used for attrition analysis.

---

## Main Menu Loop

```python
def menu():
    con = create_connection()
    cursor = con.cursor()
    while True:
        # display 9 options
        # take choice
        # call matching function
    cursor.close()
    con.close()
```

The while True loop keeps the program running until option 0 is selected.
Connection is created once at start and properly closed at end using
cursor.close() and con.close() to prevent memory leaks.

---

## Menu Options Summary

| Option | Function | Description |
|---|---|---|
| 1 | add_employee() | Add new employee with full HR profile |
| 2 | remove_employee() | Process employee exit with reason |
| 3 | promote_employee() | Salary revision and designation update |
| 4 | display_all_employees() | Full employee master directory |
| 5 | search_employee() | Individual employee profile lookup |
| 6 | display_by_department() | Department-wise employee report |
| 7 | hr_dashboard() | KPI summary — headcount and payroll |
| 8 | view_salary_log() | Salary revision audit trail |
| 9 | view_exit_log() | Employee exit and attrition log |
| 0 | exit | Close system and database connection |

---

## Key Concepts Used

- `mysql.connector` for database connection and query execution
- `cursor.callproc()` to call MySQL stored procedures from Python
- `cursor.stored_results()` to read results returned by stored procedures
- `con.commit()` to permanently save every write operation
- `con.rollback()` to undo changes if any error occurs mid-operation
- `try/except` blocks for ValueError and mysql.connector.Error handling
- `TIMESTAMPDIFF` in SQL called via Python for live years-of-service calculation
- Proper connection lifecycle management with close() calls
