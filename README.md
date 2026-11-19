# Banking Loan Risk & Performance Analytics

SQL, DAX and Power BI analysis of a retail loan book: where defaults concentrate, how credit score, tenure, loan size and
product drive risk, and whether the interest charged covers the losses.

> **Synthetic data.** All customers, loans and payments were generated with a script (`01. Dataset/generate_dataset.py`) for
> learning. No real bank or customer data is used. Findings describe this dataset, not any real lender.

## Business questions
1. How big is the book and how much of it has defaulted?
2. Which credit-score bands, tenures, loan sizes and products carry the most default risk?
3. Do higher-risk borrowers pay enough interest to cover the credit losses?
4. How much do we recover after a default, and when do loans default?
5. Do late payments warn us before a default?

## Key findings
| # | Finding | Evidence |
|---|---|---|
| 1 | The book is 4,000 loans, ₹7.12 bn disbursed, with an **8.03%** default rate (321 loans) and an average rate of 11.34%. | Script 01 |
| 2 | **Credit score is the strongest driver.** Default rate runs from 23.7% (Poor, 300-579) to 0.6% (Exceptional, 800-850). | Script 02 |
| 3 | Poor and Fair bands are **44% of loans but 80% of defaults** (258 of 321). | Script 02 |
| 4 | Borrowing **4x income or more** defaults at 14.2%, against about 4% for loans under 1x income. | Script 14 |
| 5 | **Business loans default at 17.7%**; Home loans at 3.7%. | Script 05 |
| 6 | Loan-size and tenure patterns are largely **product mix**: the 50 L+ band is all Home loans (4.5%), and the 1-3 year tenure peak (12.2%) comes from Business loans (21.7% in that band). | Scripts 03, 04 |
| 7 | **Riskier bands are priced higher but still earn less.** Poor borrowers pay 14.6% on average, yet credit losses eat 63% of the interest earned. Net return is 7.3% of amount disbursed, against 14.2% for the Good band. | Script 06 |
| 8 | **Secured loans recover more:** Home 53% and Auto 42%, against 17-18% for Business, Personal and Education. | Script 12 |
| 9 | Defaults come early: **48% occur within 12 months** of origination, and a third between months 6 and 11. | Script 15 |
| 10 | Within the Poor band, loans of ₹10-50 L default at 28-30%, the worst segment in the book. | Script 11 |

Read with care: newer vintages look better partly because they have had less time to default (script 09). The repayment-behaviour gap in
script 10 is built into the generator (see the Data Dictionary), so it shows how such a check would work, not a real-world effect size.

## Repository structure
```
banking-loan-risk-performance-analytics/
├── 01. Dataset/
│   ├── Raw Dataset/                 4 CSVs with deliberate data-quality problems
│   ├── Cleaned Dataset/             Clean_Customers / Loans / Payments / Defaults .csv
│   ├── generate_dataset.py          builds the synthetic raw data (seed 42)
│   ├── clean_dataset.py             cleans raw -> cleaned and writes the log
│   ├── Cleaning Log.md
│   └── Data Dictionary.md
├── 02. SQL Scripts/
│   ├── 00_Create_Tables_And_Load.sql
│   ├── 01_Portfolio_KPIs.sql  ...  16_Active_Loans_Watchlist.sql
│   └── Query Results/               CSV output of every script
├── 03. Power BI/
│   ├── Dashboard Images/            5 PNGs (4 report pages + data model)
│   ├── DAX/Measures.dax             calendar table, columns, ~40 measures
│   ├── Build Guide.md               how to rebuild the report in Power BI Desktop
│   └── File/                        place your .pbix here
└── README.md
```

## Data cleaning (summary)
Raw files contain duplicate customers and loans, inconsistent region text, missing incomes, impossible credit scores (0 and 9999) and interest
rates stored as text with a `%`. `clean_dataset.py` fixes each one and flags imputed values; the counts are in `01. Dataset/Cleaning Log.md`.

## SQL scripts
Sixteen numbered scripts, each starting with the business question it answers. They use joins, CTEs, `CASE` banding,
window functions (`SUM() OVER`, `LAG`, `RANK`, `ROW_NUMBER`) and conditional aggregation. Written for **SQLite**; script 00 notes the SQL Server and MySQL equivalents.
All scripts were run against the cleaned data and their output is saved in `Query Results/`.

| Script | Question |
|---|---|
| 01 | Headline portfolio KPIs |
| 02-05 | Default rate by credit band, tenure, loan size, loan type |
| 06 | Interest earned vs credit loss by credit band |
| 07 | Average rate by credit band and tenure (pivot) |
| 08 | Monthly disbursement with running total and month-on-month change |
| 09 | Default rate by origination quarter (vintage) |
| 10 | Payment behaviour of defaulted vs other loans |
| 11 | Credit band x loan size risk hot-spots |
| 12 | Recovery rate and loss given default by product |
| 13 | Region ranking against the portfolio average |
| 14 | Default rate by loan-to-income multiple |
| 15 | Months from origination to default |
| 16 | Watch-list of active loans showing early warning signs |

## Power BI
Dashboard images in `03. Power BI/Dashboard Images/` show the four report pages and the data model. **They are rendered from the cleaned data with
Python as layout mock-ups, not screenshots from Power BI Desktop.** `DAX/Measures.dax` and `Build Guide.md` give everything needed to build the real report.
The DAX was written to match the data model but has not been run here; check it against the reference results in `Query Results/`.

## How to run
```bash
cd "01. Dataset"
python generate_dataset.py     # optional: recreate the raw data
python clean_dataset.py        # raw -> cleaned
```
Then load the cleaned CSVs into SQLite with `02. SQL Scripts/00_Create_Tables_And_Load.sql` and run scripts 01-16. Needs Python 3 with `pandas` and `numpy`.

## Skills shown
SQL (joins, CTEs, window functions), data cleaning and validation, DAX measures and time intelligence, data modelling, KPI design, credit-risk analysis and business storytelling.

## Author
**Balaji R** · Business Analyst | Business Intelligence | Project Coordination
[LinkedIn](https://www.linkedin.com/in/balaji-r-98581b105) · balajidx14@gmail.com

## License
MIT. See [LICENSE](LICENSE).
