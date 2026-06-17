# ================================================================
#  BRAND INVENT — HR CONSULTING FIRM
#  Employee Management System
#  Created by : Somika Arya | HR Analyst Intern
#  Organization: Brand Invent, New Delhi
#  Tool        : Python 3 + MySQL
# ================================================================

import mysql.connector
from mysql.connector import Error
from datetime import datetime

# ----------------------------------------------------------------
# DATABASE CONNECTION
# ----------------------------------------------------------------
def create_connection():
    try:
        con = mysql.connector.connect(
            host     = "localhost",
            user     = "root",
            password = "password",
            database = "brand_invent_hr"
        )
        if con.is_connected():
            return con
    except Error as e:
        print(f"\n  [CONNECTION ERROR] Could not connect to database: {e}")
        return None

# ----------------------------------------------------------------
# DISPLAY HELPERS
# ----------------------------------------------------------------
def print_header(title):
    print("\n" + "=" * 65)
    print(f"   BRAND INVENT — HR CONSULTING FIRM")
    print(f"   {title}")
    print("=" * 65)

def print_divider():
    print("-" * 65)

def print_row(label, value):
    print(f"  {label:<28}: {value}")

# ----------------------------------------------------------------
# UTILITY: Check if employee exists
# ----------------------------------------------------------------
def check_employee(cursor, emp_id):
    cursor.callproc('check_employee', [emp_id, 0])
    for result in cursor.stored_results():
        row = result.fetchone()
        if row:
            return row[0] == 1
    return False

# ----------------------------------------------------------------
# UTILITY: Get all departments
# ----------------------------------------------------------------
def get_departments(cursor):
    cursor.execute("SELECT dept_id, dept_name FROM departments ORDER BY dept_id")
    return cursor.fetchall()

# ----------------------------------------------------------------
# FUNCTION 1: ADD EMPLOYEE
# ----------------------------------------------------------------
def add_employee(con, cursor):
    print_header("ADD NEW EMPLOYEE")

    # Show available departments
    depts = get_departments(cursor)
    print("\n  Available Departments:")
    print_divider()
    for d in depts:
        print(f"    [{d[0]}] {d[1]}")
    print_divider()

    try:
        emp_id   = int(input("\n  Employee ID          : "))
        if check_employee(cursor, emp_id):
            print(f"\n  [ERROR] Employee ID {emp_id} already exists in the system.")
            return

        emp_name  = input("  Full Name            : ").strip()
        gender    = input("  Gender (Male/Female/Other): ").strip().capitalize()
        dob       = input("  Date of Birth (YYYY-MM-DD): ").strip()
        contact   = input("  Contact Number       : ").strip()
        email     = input("  Email Address        : ").strip()
        designation = input("  Designation          : ").strip()
        dept_id   = int(input("  Department ID        : "))
        emp_type  = input("  Employment Type (Full-Time/Part-Time/Intern/Contract): ").strip()
        doj       = input("  Date of Joining (YYYY-MM-DD): ").strip()
        basic     = float(input("  Basic Salary (Rs.)   : "))
        hra       = float(input("  HRA (Rs.)            : "))
        allowances = float(input("  Other Allowances (Rs.): "))
        manager   = input("  Reporting Manager    : ").strip()

        cursor.callproc('add_employee', [
            emp_id, emp_name, gender, dob, contact, email,
            designation, dept_id, emp_type, doj,
            basic, hra, allowances, manager
        ])
        con.commit()

        for result in cursor.stored_results():
            msg = result.fetchone()
            if msg:
                print(f"\n  {msg[0]}")

        # Show gross salary
        gross = basic + hra + allowances
        print(f"\n  Gross Salary         : Rs. {gross:,.2f}")
        print_divider()

    except ValueError:
        print("\n  [ERROR] Invalid input. Please enter correct data types.")
    except Error as e:
        print(f"\n  [DB ERROR] {e}")
        con.rollback()

# ----------------------------------------------------------------
# FUNCTION 2: REMOVE EMPLOYEE (Exit Processing)
# ----------------------------------------------------------------
def remove_employee(con, cursor):
    print_header("EMPLOYEE EXIT PROCESSING")

    try:
        emp_id = int(input("\n  Enter Employee ID    : "))
        if not check_employee(cursor, emp_id):
            print(f"\n  [ERROR] Employee ID {emp_id} not found in the system.")
            return

        # Show employee details before exit
        cursor.execute("""
            SELECT e.emp_name, e.designation, d.dept_name, e.date_of_joining, e.employment_status
            FROM employees e
            LEFT JOIN departments d ON e.dept_id = d.dept_id
            WHERE e.emp_id = %s
        """, (emp_id,))
        emp = cursor.fetchone()
        if emp:
            print_divider()
            print_row("Employee Name",   emp[0])
            print_row("Designation",     emp[1])
            print_row("Department",      emp[2])
            print_row("Date of Joining", str(emp[3]))
            print_row("Current Status",  emp[4])
            print_divider()

        print("\n  Exit Reasons:")
        print("    [1] Resignation")
        print("    [2] Termination")
        print("    [3] Contract End")
        print("    [4] Retirement")
        reason_map = {
            '1': 'Resignation', '2': 'Termination',
            '3': 'Contract End', '4': 'Retirement'
        }
        choice = input("\n  Select Exit Reason   : ").strip()
        exit_reason = reason_map.get(choice, 'Resignation')

        confirm = input(f"\n  Confirm exit for Employee ID {emp_id}? (yes/no): ").strip().lower()
        if confirm != 'yes':
            print("\n  [CANCELLED] Exit process cancelled.")
            return

        cursor.callproc('remove_employee', [emp_id, exit_reason])
        con.commit()

        for result in cursor.stored_results():
            msg = result.fetchone()
            if msg:
                print(f"\n  {msg[0]}")
        print_divider()

    except ValueError:
        print("\n  [ERROR] Invalid Employee ID.")
    except Error as e:
        print(f"\n  [DB ERROR] {e}")
        con.rollback()

# ----------------------------------------------------------------
# FUNCTION 3: PROMOTE EMPLOYEE
# ----------------------------------------------------------------
def promote_employee(con, cursor):
    print_header("EMPLOYEE PROMOTION / SALARY REVISION")

    try:
        emp_id = int(input("\n  Enter Employee ID    : "))
        if not check_employee(cursor, emp_id):
            print(f"\n  [ERROR] Employee ID {emp_id} not found in the system.")
            return

        # Show current details
        cursor.execute("""
            SELECT emp_name, designation, basic_salary, gross_salary
            FROM employees WHERE emp_id = %s
        """, (emp_id,))
        emp = cursor.fetchone()
        if emp:
            print_divider()
            print_row("Employee Name",     emp[0])
            print_row("Current Designation", emp[1])
            print_row("Current Basic Salary", f"Rs. {emp[2]:,.2f}")
            print_row("Current Gross Salary", f"Rs. {emp[3]:,.2f}")
            print_divider()

        new_desig   = input("\n  New Designation      : ").strip()
        increment   = float(input("  Increment Amount (Rs.): "))
        remarks     = input("  Remarks              : ").strip()

        cursor.callproc('promote_employee', [emp_id, new_desig, increment, remarks])
        con.commit()

        for result in cursor.stored_results():
            msg = result.fetchone()
            if msg:
                print(f"\n  {msg[0]}")
        print_divider()

    except ValueError:
        print("\n  [ERROR] Invalid input. Please enter correct values.")
    except Error as e:
        print(f"\n  [DB ERROR] {e}")
        con.rollback()

# ----------------------------------------------------------------
# FUNCTION 4: DISPLAY ALL EMPLOYEES
# ----------------------------------------------------------------
def display_all_employees(cursor):
    print_header("EMPLOYEE MASTER DIRECTORY")

    cursor.callproc('display_all_employees')
    for result in cursor.stored_results():
        rows = result.fetchall()
        if not rows:
            print("\n  No employee records found.")
            return

        print(f"\n  Total Records Found : {len(rows)}\n")
        print_divider()

        for emp in rows:
            print_row("Emp ID",           emp[0])
            print_row("Full Name",        emp[1])
            print_row("Gender",           emp[2])
            print_row("Designation",      emp[3])
            print_row("Department",       emp[4])
            print_row("Employment Type",  emp[5])
            print_row("Date of Joining",  str(emp[6]))
            print_row("Years of Service", f"{emp[7]} year(s)")
            print_row("Contact",          emp[8])
            print_row("Email",            emp[9])
            print_row("Basic Salary",     f"Rs. {emp[10]:,.2f}")
            print_row("HRA",              f"Rs. {emp[11]:,.2f}")
            print_row("Allowances",       f"Rs. {emp[12]:,.2f}")
            print_row("Gross Salary",     f"Rs. {emp[13]:,.2f}")
            print_row("Status",           emp[14])
            print_row("Reporting Manager",emp[15])
            print_divider()

# ----------------------------------------------------------------
# FUNCTION 5: SEARCH EMPLOYEE BY ID
# ----------------------------------------------------------------
def search_employee(cursor):
    print_header("EMPLOYEE PROFILE SEARCH")

    try:
        emp_id = int(input("\n  Enter Employee ID    : "))
        cursor.callproc('display_employee_by_id', [emp_id])
        found = False
        for result in cursor.stored_results():
            rows = result.fetchall()
            for emp in rows:
                if isinstance(emp[0], int):
                    found = True
                    print_divider()
                    labels = [
                        "Emp ID", "Full Name", "Gender", "Date of Birth",
                        "Contact", "Email", "Designation", "Department",
                        "Employment Type", "Date of Joining", "Years of Service",
                        "Basic Salary", "HRA", "Allowances", "Gross Salary",
                        "Status", "Reporting Manager"
                    ]
                    for i, label in enumerate(labels):
                        val = emp[i]
                        if label in ("Basic Salary", "HRA", "Allowances", "Gross Salary"):
                            val = f"Rs. {float(val):,.2f}"
                        print_row(label, val)
                    print_divider()
                else:
                    print(f"\n  {emp[0]}")
        if not found:
            pass
    except ValueError:
        print("\n  [ERROR] Invalid Employee ID.")

# ----------------------------------------------------------------
# FUNCTION 6: DEPARTMENT-WISE VIEW
# ----------------------------------------------------------------
def display_by_department(cursor):
    print_header("DEPARTMENT-WISE EMPLOYEE REPORT")

    depts = get_departments(cursor)
    print("\n  Available Departments:")
    print_divider()
    for d in depts:
        print(f"    {d[1]}")
    print_divider()

    dept_name = input("\n  Enter Department Name: ").strip()
    cursor.callproc('display_by_department', [dept_name])

    for result in cursor.stored_results():
        rows = result.fetchall()
        if not rows:
            print(f"\n  No employees found in '{dept_name}' department.")
            return

        print(f"\n  Department : {dept_name}")
        print(f"  Headcount  : {len(rows)}\n")
        print_divider()
        for emp in rows:
            print_row("Emp ID",         emp[0])
            print_row("Full Name",      emp[1])
            print_row("Designation",    emp[2])
            print_row("Type",           emp[3])
            print_row("Basic Salary",   f"Rs. {emp[4]:,.2f}")
            print_row("Gross Salary",   f"Rs. {emp[5]:,.2f}")
            print_row("Status",         emp[6])
            print_divider()

# ----------------------------------------------------------------
# FUNCTION 7: HR DASHBOARD — KPI SUMMARY
# ----------------------------------------------------------------
def hr_dashboard(cursor):
    print_header("HR DASHBOARD — KEY METRICS SUMMARY")
    print(f"\n  Generated On : {datetime.now().strftime('%d %B %Y, %I:%M %p')}")
    print_divider()

    cursor.callproc('hr_dashboard_summary')
    results = list(cursor.stored_results())

    if results:
        # Overall summary
        summary = results[0].fetchone()
        if summary:
            print("\n  OVERALL HEADCOUNT SUMMARY")
            print_divider()
            print_row("Total Employees",       summary[0])
            print_row("Active",                summary[1])
            print_row("Resigned",              summary[2])
            print_row("On Leave",              summary[3])
            print_row("Interns",               summary[4])
            print_row("Avg Basic Salary",      f"Rs. {float(summary[5]):,.2f}")
            print_row("Total Gross Payroll",   f"Rs. {float(summary[6]):,.2f}")
            print_divider()

    if len(results) > 1:
        # Department breakdown
        dept_rows = results[1].fetchall()
        print("\n  DEPARTMENT-WISE BREAKDOWN")
        print_divider()
        for row in dept_rows:
            print_row(f"  {row[0]}",  f"Headcount: {row[1]}  |  Avg Salary: Rs. {float(row[2]):,.2f}  |  Payroll: Rs. {float(row[3]):,.2f}")
        print_divider()

# ----------------------------------------------------------------
# FUNCTION 8: SALARY REVISION LOG
# ----------------------------------------------------------------
def view_salary_log(cursor):
    print_header("SALARY REVISION AUDIT LOG")

    cursor.execute("""
        SELECT log_id, emp_id, emp_name, designation,
               old_basic, increment_amount, new_basic,
               revision_date, remarks
        FROM salary_revision_log
        ORDER BY revision_date DESC
    """)
    rows = cursor.fetchall()

    if not rows:
        print("\n  No salary revisions recorded yet.")
        return

    print(f"\n  Total Revisions : {len(rows)}\n")
    print_divider()
    for row in rows:
        print_row("Log ID",         row[0])
        print_row("Emp ID",         row[1])
        print_row("Employee Name",  row[2])
        print_row("Designation",    row[3])
        print_row("Old Basic",      f"Rs. {float(row[4]):,.2f}")
        print_row("Increment",      f"Rs. {float(row[5]):,.2f}")
        print_row("New Basic",      f"Rs. {float(row[6]):,.2f}")
        print_row("Revised On",     str(row[7]))
        print_row("Remarks",        row[8])
        print_divider()

# ----------------------------------------------------------------
# FUNCTION 9: EXIT LOG
# ----------------------------------------------------------------
def view_exit_log(cursor):
    print_header("EMPLOYEE EXIT LOG")

    cursor.execute("""
        SELECT exit_id, emp_id, emp_name, designation,
               dept_name, date_of_joining, exit_date, exit_reason
        FROM exit_log
        ORDER BY exit_date DESC
    """)
    rows = cursor.fetchall()

    if not rows:
        print("\n  No exit records found.")
        return

    print(f"\n  Total Exits : {len(rows)}\n")
    print_divider()
    for row in rows:
        print_row("Exit ID",        row[0])
        print_row("Emp ID",         row[1])
        print_row("Employee Name",  row[2])
        print_row("Designation",    row[3])
        print_row("Department",     row[4])
        print_row("Date of Joining",str(row[5]))
        print_row("Exit Date",      str(row[6]))
        print_row("Exit Reason",    row[7])
        print_divider()

# ----------------------------------------------------------------
# MAIN MENU
# ----------------------------------------------------------------
def menu():
    con = create_connection()
    if not con:
        print("\n  [FATAL] Database connection failed. Exiting.")
        return

    cursor = con.cursor()

    while True:
        print("\n")
        print("=" * 65)
        print("        BRAND INVENT — EMPLOYEE MANAGEMENT SYSTEM")
        print("        HR Consulting Firm | New Delhi")
        print("=" * 65)
        print("  [1]  Add New Employee")
        print("  [2]  Process Employee Exit (Remove)")
        print("  [3]  Promote Employee / Salary Revision")
        print("  [4]  Display All Employees")
        print("  [5]  Search Employee by ID")
        print("  [6]  Department-Wise Employee Report")
        print("  [7]  HR Dashboard — KPI Summary")
        print("  [8]  Salary Revision Audit Log")
        print("  [9]  Employee Exit Log")
        print("  [0]  Exit System")
        print("=" * 65)

        choice = input("\n  Enter your choice: ").strip()

        if   choice == '1': add_employee(con, cursor)
        elif choice == '2': remove_employee(con, cursor)
        elif choice == '3': promote_employee(con, cursor)
        elif choice == '4': display_all_employees(cursor)
        elif choice == '5': search_employee(cursor)
        elif choice == '6': display_by_department(cursor)
        elif choice == '7': hr_dashboard(cursor)
        elif choice == '8': view_salary_log(cursor)
        elif choice == '9': view_exit_log(cursor)
        elif choice == '0':
            print("\n  Closing system. Goodbye!")
            print("  Brand Invent HR System — Session Ended\n")
            break
        else:
            print("\n  [ERROR] Invalid choice. Please select a valid option.")

    cursor.close()
    con.close()

# ----------------------------------------------------------------
if __name__ == "__main__":
    menu()
