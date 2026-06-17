**Departments covered:**
- HR Analytics & Data — 6 employees — Priya Kapoor
- Recruitment & Talent — 5 employees — Rajiv Mehra
- Human Resources — 5 employees — Anita Sharma
- Organizational Development — 4 employees — Suresh Nair
- Finance & Accounts — 4 employees — Neha Gupta
- Client Relations — 3 employees — Vikram Bhatia

---

### Sheet 6 — Salary Analysis (6_Salary_Analysis)

Three-part salary analysis sheet used for compensation benchmarking.

**Part 1 — Key Salary Metrics:**

| Metric | Formula Used |
|---|---|
| Total Employees | `COUNTA` |
| Total Gross Payroll | `SUMPRODUCT` with Active status condition |
| Average Basic Salary | `AVERAGEIF` filtering Active employees only |
| Highest Basic Salary | `MAX` |
| Lowest Basic Salary | `MIN` |
| Median Basic Salary | `MEDIAN` |
| Active Employee Payroll % | `COUNTIF / COUNTA` |

**Part 2 — Salary Band Analysis:**

| Band | Formula |
|---|---|
| Less than Rs. 30,000 | `COUNTIFS` with upper bound |
| Rs. 30,000 – 50,000 | `COUNTIFS` with lower and upper bound |
| Rs. 50,000 – 75,000 | `COUNTIFS` with lower and upper bound |
| Rs. 75,000 and above | `COUNTIFS` with lower bound |

Includes count, percentage of workforce, and cumulative percentage per band.

**Part 3 — Individual Salary Breakdown:**
All 32 employees with Basic, HRA, Allowances, and Gross Salary
(Gross calculated live using `=Basic+HRA+Allowances`).

---

### Sheet 7 — Attrition Analysis (7_Attrition_Analysis)

Full attrition and exit analysis built using COUNTIF formulas
pulling live from the Cleaned Data sheet.

**Attrition KPIs:**

| Metric | Formula | Result |
|---|---|---|
| Total Headcount | `COUNTA` | 32 |
| Currently Active | `COUNTIF` status = Active | 27 |
| Total Exits | `COUNTIF` status ≠ Active | 5 |
| Resigned | `COUNTIF` status = Resigned | 3 |
| Contract Ended | `COUNTIF` status = Contract End | 1 |
| Terminated | `COUNTIF` status = Terminated | 1 |
| Attrition Rate | Exits / Total Headcount | 15.6% |
| Retention Rate | 1 − Attrition Rate | 84.4% |

**Exit Log table:**
All 5 departed employees with Emp ID, Name, Last Designation,
Department, Exit Reason (colour-coded), and Date of Exit.

---

### Sheet 8 — Salary Revision Log (8_Salary_Revision_Log)

Complete audit trail of all 10 salary revisions and promotions
processed during FY 2024–26.

**Columns:**
Log #, Emp ID, Employee Name, New Designation, Old Basic Salary,
Increment Amount, New Basic Salary (formula), Increment % (formula), Remarks

**Formulas used:**
- New Basic = `=Old Basic + Increment`
- Increment % = `=Increment / Old Basic`
- Total row: `=SUM` for total increment payout and average increment rate

**Sample entries:**
- Arjun Verma — Rs. 9,000 increment — promoted for leading dashboard project
- Ishaan Malhotra — Rs. 7,500 increment — retained 3 key client accounts
- Deepika Singh — Rs. 7,000 increment — client feedback and target achievement

---

### Sheet 9 — HR Dashboard (9_HR_Dashboard)

Executive summary dashboard — the final output of the entire analytics workflow.
All values pull live from Sheet 3 using formulas, so the dashboard updates
automatically when the source data changes.

**KPI Summary Row (5 metrics):**

| KPI | Formula |
|---|---|
| Total Employees | `COUNTA` on Cleaned Data |
| Active Staff | `COUNTIF` status = Active |
| Total Exits | `COUNTIF` status ≠ Active |
| Attrition Rate | Exits / Total via `COUNTIF / COUNTA` |
| Promotions FY24 | Hardcoded from Revision Log (10) |

**Department Overview Table (live formulas):**
Each department row uses `COUNTIF`, `AVERAGEIF`, and `SUMIF`
to pull headcount, average salary, and total payroll directly
from the cleaned dataset.

---

## Excel Functions Used

| Function | Where Used | Purpose |
|---|---|---|
| `DATEDIF` | Sheet 4 | Years of service and age calculation |
| `IF` (nested) | Sheet 4 | Salary grade classification |
| `COUNTIF` | Sheets 7, 9 | Headcount by status |
| `COUNTIFS` | Sheet 6 | Salary band filtering |
| `AVERAGEIF` | Sheets 6, 9 | Average salary for active employees |
| `SUMIF` | Sheet 9 | Department payroll totals |
| `SUMPRODUCT` | Sheet 6 | Conditional payroll sum |
| `COUNTA` | Sheets 6, 7, 9 | Total record count |
| `MAX / MIN` | Sheet 6 | Salary range boundaries |
| `MEDIAN` | Sheet 6 | Median salary calculation |
| `SUM` | Sheets 5, 8 | Payroll and increment totals |

---

## Key Design Decisions

**No hardcoded calculations** — every number in summary sheets
is driven by a formula referencing Sheet 3. Updating any employee
record automatically cascades through all 9 sheets.

**Soft delete approach** — exited employees remain in the dataset
with their status updated to Resigned / Terminated / Contract End,
matching real HR system design where records are never deleted.

**Salary grade classification** — implemented using nested IF formula
without VBA, making the logic transparent and auditable.

**Data cleaning documented** — Sheet 2 logs every transformation
applied to the raw data, providing a reproducible audit trail
exactly as required in professional HR analytics practice.

---

## Tools & Technologies

- Microsoft Excel 
