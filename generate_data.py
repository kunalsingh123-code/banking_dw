import csv
import os
import random
from faker import Faker
from datetime import date, timedelta

fake = Faker("en_IN")

# =========================================
# SETTINGS
# =========================================

OUTPUT_DIR = "datasets"

NUM_BRANCHES = 100
NUM_CUSTOMERS = 200
NUM_ACCOUNTS = 200
NUM_TRANSACTIONS = 500

os.makedirs(OUTPUT_DIR, exist_ok=True)


# =========================================
# HELPER FUNCTION
# =========================================

def write_csv(filename, headers, rows):
    filepath = os.path.join(OUTPUT_DIR, filename)

    with open(filepath, "w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=headers)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Created: {filepath} | Records: {len(rows)}")


# =========================================
# 1. GENERATE BRANCHES
# =========================================

branches = []

states = [
    "Maharashtra",
    "Gujarat",
    "Karnataka",
    "Delhi",
    "Tamil Nadu",
    "Telangana",
    "Rajasthan",
    "Madhya Pradesh"
]

branch_types = [
    "urban",
    "rural",
    "metro"
]

for i in range(1, NUM_BRANCHES + 1):

    branches.append({
        "branch_id": f"BR{i:04d}",
        "branch_name": f"{fake.last_name()} Bank Branch",
        "city": fake.city(),
        "state": random.choice(states),
        "branch_type": random.choice(branch_types)
    })


# =========================================
# 2. GENERATE CUSTOMERS
# =========================================

customers = []

customer_types = [
    "individual",
    "business",
    "premium"
]

start_date = date(1960, 1, 1)
end_date = date(2005, 12, 31)

date_range = (end_date - start_date).days

for i in range(1, NUM_CUSTOMERS + 1):

    dob = start_date + timedelta(
        days=random.randint(0, date_range)
    )

    customers.append({
        "customer_id": f"CUST{i:05d}",
        "customer_name": fake.name(),
        "email": fake.email().lower(),
        "phone": fake.msisdn()[:10],
        "city": fake.city(),
        "state": random.choice(states),
        "date_of_birth": dob.strftime("%Y-%m-%d"),
        "customer_type": random.choice(customer_types)
    })


# =========================================
# 3. GENERATE ACCOUNTS
# =========================================

accounts = []

account_types = [
    "savings",
    "current",
    "salary"
]

account_statuses = [
    "active",
    "inactive",
    "closed"
]

for i in range(1, NUM_ACCOUNTS + 1):

    customer = random.choice(customers)
    branch = random.choice(branches)

    opened_date = fake.date_between(
        start_date="-10y",
        end_date="today"
    )

    accounts.append({
        "account_id": f"ACC{i:06d}",
        "customer_id": customer["customer_id"],
        "branch_id": branch["branch_id"],
        "account_type": random.choice(account_types),
        "account_balance": round(
            random.uniform(500, 500000),
            2
        ),
        "account_status": random.choice(account_statuses),
        "opened_date": opened_date.strftime("%Y-%m-%d")
    })


# =========================================
# 4. GENERATE TRANSACTIONS
# =========================================

transactions = []

transaction_types = [
    "deposit",
    "withdrawal",
    "upi",
    "transfer",
    "payment"
]

transaction_statuses = [
    "success",
    "success",
    "success",
    "failed",
    "pending"
]

for i in range(1, NUM_TRANSACTIONS + 1):

    account = random.choice(accounts)

    transaction_date = fake.date_between(
        start_date="-1y",
        end_date="today"
    )

    transactions.append({
        "transaction_id": f"TXN{i:07d}",
        "account_id": account["account_id"],
        "transaction_date": transaction_date.strftime("%Y-%m-%d"),
        "transaction_type": random.choice(transaction_types),
        "amount": round(
            random.uniform(100, 100000),
            2
        ),
        "transaction_status": random.choice(
            transaction_statuses
        ),
        "merchant_name": fake.company(),
        "city": fake.city()
    })


# =========================================
# WRITE CSV FILES
# =========================================

write_csv(
    "branches.csv",
    [
        "branch_id",
        "branch_name",
        "city",
        "state",
        "branch_type"
    ],
    branches
)


write_csv(
    "customers.csv",
    [
        "customer_id",
        "customer_name",
        "email",
        "phone",
        "city",
        "state",
        "date_of_birth",
        "customer_type"
    ],
    customers
)


write_csv(
    "accounts.csv",
    [
        "account_id",
        "customer_id",
        "branch_id",
        "account_type",
        "account_balance",
        "account_status",
        "opened_date"
    ],
    accounts
)


write_csv(
    "transactions.csv",
    [
        "transaction_id",
        "account_id",
        "transaction_date",
        "transaction_type",
        "amount",
        "transaction_status",
        "merchant_name",
        "city"
    ],
    transactions
)


# =========================================
# FINAL SUMMARY
# =========================================

print("\n=========================================")
print("CSV GENERATION COMPLETED")
print("=========================================")
print(f"Branches      : {len(branches)}")
print(f"Customers     : {len(customers)}")
print(f"Accounts      : {len(accounts)}")
print(f"Transactions  : {len(transactions)}")
print(f"Total Records : {len(branches) + len(customers) + len(accounts) + len(transactions)}")
print(f"\nFiles saved in: {OUTPUT_DIR}/")