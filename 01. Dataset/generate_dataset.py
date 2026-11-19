"""
Generate the SYNTHETIC raw dataset for the Banking Loan Risk & Performance Analytics project.

All data is randomly generated for learning. No real customer, bank or loan data is used.
Amounts are in INR. Observation (data cut-off) date: 2024-12-31.

Run:  python generate_dataset.py
Output: ./Raw Dataset/{Customers,Loans,Payments,Defaults}.csv
(The raw files deliberately contain data-quality problems that clean_dataset.py fixes.)
"""
import os
import numpy as np
import pandas as pd

SEED = 42
N_CUSTOMERS = 3200
N_LOANS = 4000
OBS_DATE = pd.Timestamp("2024-12-31")
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Raw Dataset")
os.makedirs(OUT, exist_ok=True)
rng = np.random.default_rng(SEED)

# ---------------------------------------------------------------- customers
regions = ["North", "South", "East", "West", "Central"]
emp_types = ["Salaried", "Self-Employed", "Business Owner", "Retired"]
cust = pd.DataFrame({
    "CustomerID": [f"C{i:05d}" for i in range(1, N_CUSTOMERS + 1)],
    "Age": rng.integers(21, 66, N_CUSTOMERS),
    "Region": rng.choice(regions, N_CUSTOMERS, p=[0.22, 0.26, 0.17, 0.25, 0.10]),
    "EmploymentType": rng.choice(emp_types, N_CUSTOMERS, p=[0.58, 0.20, 0.17, 0.05]),
})
income = rng.lognormal(mean=np.log(650_000), sigma=0.55, size=N_CUSTOMERS)
cust["AnnualIncome"] = (np.round(income, -3)).astype(int)
score = rng.normal(685, 85, N_CUSTOMERS) + (np.log(income) - np.log(650_000)) * 25
cust["CreditScore"] = np.clip(np.round(score), 300, 850).astype(int)
cust["JoinDate"] = (pd.Timestamp("2015-01-01") +
                    pd.to_timedelta(rng.integers(0, 365 * 9, N_CUSTOMERS), unit="D")).strftime("%Y-%m-%d")

# -------------------------------------------------------------------- loans
loan_types = ["Personal", "Auto", "Home", "Education", "Business"]
type_p = [0.34, 0.20, 0.16, 0.14, 0.16]
amt_rng = {"Personal": (50_000, 1_500_000), "Auto": (300_000, 1_500_000),
           "Home": (1_500_000, 8_000_000), "Education": (200_000, 2_000_000),
           "Business": (500_000, 5_000_000)}
tenures = {"Personal": [12, 24, 36, 48, 60], "Auto": [24, 36, 48, 60, 84],
           "Home": [120, 180, 240], "Education": [36, 60, 84, 120],
           "Business": [24, 36, 60, 84]}
base_rate = {"Personal": 12.5, "Auto": 9.2, "Home": 8.4, "Education": 9.8, "Business": 11.5}

cust_idx = rng.integers(0, N_CUSTOMERS, N_LOANS)
ltype = rng.choice(loan_types, N_LOANS, p=type_p)
amount = np.array([rng.uniform(*amt_rng[t]) for t in ltype])
amount = np.round(amount, -3)
tenure = np.array([rng.choice(tenures[t]) for t in ltype])
orig = (pd.Timestamp("2021-01-01") +
        pd.to_timedelta(rng.integers(0, (pd.Timestamp("2024-09-30") - pd.Timestamp("2021-01-01")).days, N_LOANS), unit="D"))
cs = cust["CreditScore"].to_numpy()[cust_idx]
inc = cust["AnnualIncome"].to_numpy()[cust_idx]
rate = (np.array([base_rate[t] for t in ltype])
        + (700 - cs) / 100 * 2.3 + (tenure - 36) / 12 * 0.08 + rng.normal(0, 0.45, N_LOANS))
rate = np.round(np.clip(rate, 6.5, 24), 2)

# default model (logistic): lower score, higher loan-to-income, riskier product -> more defaults
lti = amount / inc
type_eff = {"Personal": 0.45, "Auto": 0.0, "Home": -0.55, "Education": 0.15, "Business": 0.35}
logit = (-3.05 - 0.0165 * (cs - 680) + 0.55 * np.clip(lti - 1.5, -1.5, 5)
         + np.array([type_eff[t] for t in ltype]) + 0.004 * (tenure - 36) / 12 * 10)
p_def = 1 / (1 + np.exp(-logit))
will_default = rng.random(N_LOANS) < p_def
# month in which a defaulting loan stops paying (between month 4 and ~85% of tenure)
def_month = np.array([int(rng.integers(4, max(6, int(0.85 * t)))) for t in tenure])


def add_months(d, m):
    return d + pd.DateOffset(months=int(m))


loans_rows, pay_rows, def_rows = [], [], []
pay_id = 1
def_id = 1
for i in range(N_LOANS):
    lid = f"L{i + 1:05d}"
    P, n, r = amount[i], int(tenure[i]), rate[i] / 1200
    emi = P * r / (1 - (1 + r) ** -n)
    bal = P
    status = "Active"
    for m in range(1, n + 1):
        due = add_months(orig[i], m)
        if due > OBS_DATE:
            break
        if will_default[i] and m >= def_month[i]:
            # loan defaults: no further payments; record default at this due date
            rec_rate = {"Home": rng.uniform(0.40, 0.70), "Auto": rng.uniform(0.30, 0.55)}.get(
                ltype[i], rng.uniform(0.05, 0.30))
            def_rows.append({"DefaultID": f"D{def_id:05d}", "LoanID": lid,
                             "DefaultDate": due.strftime("%Y-%m-%d"),
                             "OutstandingAtDefault": round(bal, 2),
                             "RecoveryAmount": round(bal * rec_rate, 2)})
            def_id += 1
            status = "Defaulted"
            break
        interest = bal * r
        principal = emi - interest
        # payment behaviour: defaulters slip late in the 3 months before default
        near_def = will_default[i] and (def_month[i] - m) <= 3
        late_p = 0.65 if near_def else 0.12
        late = rng.random() < late_p
        days_late = int(rng.integers(5, 45)) if (near_def and late) else (int(rng.integers(1, 15)) if late else 0)
        partial = near_def and rng.random() < 0.35
        paid_amt = emi * (rng.uniform(0.4, 0.85) if partial else 1.0)
        pay_rows.append({"PaymentID": f"P{pay_id:07d}", "LoanID": lid,
                         "InstallmentNo": m, "DueDate": due.strftime("%Y-%m-%d"),
                         "PaidDate": (due + pd.Timedelta(days=days_late)).strftime("%Y-%m-%d"),
                         "AmountDue": round(emi, 2), "InterestDue": round(interest, 2),
                         "AmountPaid": round(paid_amt, 2), "DaysLate": days_late})
        pay_id += 1
        bal -= principal
        if m == n:
            status = "Closed"
    loans_rows.append({"LoanID": lid, "CustomerID": cust["CustomerID"].iloc[cust_idx[i]],
                       "LoanType": ltype[i], "LoanAmount": P, "TenureMonths": n,
                       "InterestRate": rate[i], "OriginationDate": orig[i].strftime("%Y-%m-%d"),
                       "Status": status})

loans = pd.DataFrame(loans_rows)
pays = pd.DataFrame(pay_rows)
defs = pd.DataFrame(def_rows)

# ------------------------------------------- inject realistic data-quality issues
raw_c = cust.copy()
# 1) inconsistent region text
idx = rng.choice(raw_c.index, 220, replace=False)
raw_c.loc[idx[:110], "Region"] = raw_c.loc[idx[:110], "Region"].str.upper()
raw_c.loc[idx[110:], "Region"] = " " + raw_c.loc[idx[110:], "Region"].str.lower() + " "
# 2) missing income
raw_c.loc[rng.choice(raw_c.index, 96, replace=False), "AnnualIncome"] = np.nan
# 3) impossible credit scores
bad = rng.choice(raw_c.index, 14, replace=False)
raw_c.loc[bad[:7], "CreditScore"] = 0
raw_c.loc[bad[7:], "CreditScore"] = 9999
# 4) duplicate customer rows
raw_c = pd.concat([raw_c, raw_c.sample(30, random_state=1)], ignore_index=True)

raw_l = loans.copy()
raw_l = pd.concat([raw_l, raw_l.sample(24, random_state=2)], ignore_index=True)  # duplicate loans
# 5) interest rate stored as text with % on some rows
pct = rng.choice(raw_l.index, 60, replace=False)
raw_l["InterestRate"] = raw_l["InterestRate"].astype(object)
raw_l.loc[pct, "InterestRate"] = raw_l.loc[pct, "InterestRate"].map(lambda v: f"{v}%")

raw_c.to_csv(os.path.join(OUT, "Customers.csv"), index=False)
raw_l.to_csv(os.path.join(OUT, "Loans.csv"), index=False)
pays.to_csv(os.path.join(OUT, "Payments.csv"), index=False)
defs.to_csv(os.path.join(OUT, "Defaults.csv"), index=False)
print(f"Customers {len(raw_c)} | Loans {len(raw_l)} | Payments {len(pays)} | Defaults {len(defs)}")
print("Default rate (true):", round(len(defs) / len(loans) * 100, 2), "%")
