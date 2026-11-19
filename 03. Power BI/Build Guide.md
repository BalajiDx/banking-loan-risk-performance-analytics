# Power BI Build Guide

Steps to rebuild the report in Power BI Desktop from this repo. The `.pbix` itself is not included; save yours as
`03. Power BI/File/Banking Loan Risk Analytics.pbix` once built. The images in `Dashboard Images/` show the target layout.

## 1. Load the data
1. **Home > Get data > Text/CSV**, and load the four files from `01. Dataset/Cleaned Dataset/`:
   `Clean_Customers.csv`, `Clean_Loans.csv`, `Clean_Payments.csv`, `Clean_Defaults.csv`.
2. Rename the queries to `Customers`, `Loans`, `Payments`, `Defaults`.
3. In Power Query set types: dates to **Date** (`OriginationDate`, `JoinDate`, `DueDate`, `PaidDate`, `DefaultDate`),
   money and rates to **Decimal number**, counts and scores to **Whole number**, IDs to **Text**.
4. Optional: remove the `CreditScoreImputed` / `AnnualIncomeImputed` columns from visuals (keep them in the model for a data-quality page).

## 2. Model
Create these relationships (single direction, filter flows from the "1" side):

| From (1) | To (*) |
|---|---|
| `Customers[CustomerID]` | `Loans[CustomerID]` |
| `Loans[LoanID]` | `Payments[LoanID]` |
| `Loans[LoanID]` | `Defaults[LoanID]` |
| `Calendar[Date]` | `Loans[OriginationDate]` |

`Defaults` is one-to-one with `Loans`, but a one-to-many from Loans keeps filtering simple. Mark `Calendar` as the date table.

## 3. Add DAX
From `DAX/Measures.dax`, in this order:
1. the `Calendar` table
2. calculated columns (bands and their sort columns); set **Sort by column** on each band
3. measures. Put them in a dedicated `_Measures` table and use display folders: Portfolio, Default & Loss, Interest, Repayment, Time.

Format: rates and percentages as **%**, money as **#,0**.

## 4. Pages
| Page | Image | Visuals |
|---|---|---|
| Portfolio Overview | `1.Portfolio_Overview.png` | 6 KPI cards; monthly disbursement column chart (Calendar[Month] sorted by Month Sort); disbursed and default rate by Loan Type |
| Default Risk | `2.Default_Risk_Analysis.png` | Default Rate by Credit Band / Tenure Band / Loan Size Band / LTI Band; matrix Credit Band x Loan Size Band with conditional formatting |
| Interest & Return | `3.Interest_Analysis.png` | Avg Interest Rate and Net Return % by Credit Band; clustered column Interest Earned vs Credit Loss; matrix Credit Band x Tenure Band (Avg Interest Rate) |
| Vintage & Recovery | `4.Vintage_Repayment_Recovery.png` | Default Rate by Year-Quarter; Late Payment % by loan status; Recovery Rate by Loan Type |

Slicers on every page: **Loan Type, Region, Credit Band, Calendar[Year]**. Use Sync slicers so they carry across pages.

## 5. Check your numbers
With no slicers applied the report should show: 4,000 loans, 321 defaulted, 8.03% default rate, 11.34% average rate,
Poor band 23.74% and Exceptional band 0.55% default rate. Anything else means a relationship or type is wrong.
The full set of reference results is in `02. SQL Scripts/Query Results/`.

## 6. Optional: service features
Publish to Power BI Service and set up scheduled refresh with a gateway if the CSVs are replaced with a database source.
Row-level security (for example by `Customers[Region]`) can be added under **Modeling > Manage roles**.
