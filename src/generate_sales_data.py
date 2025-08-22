import boto3
import json
import uuid
import random
from faker import Faker
from datetime import datetime
from io import BytesIO
import os

# ---------- CONFIG ----------
FALLBACK_BUCKET = "sales-etl-pipeline-dev-datalake"   # <-- your actual bucket in AWS Console
PREFIX = "raw/sales"        # Base folder in S3
TARGET_FILE_SIZE_MB = 50    # ~50 MB file
# ----------------------------------------------------

# ---------- LOAD CONFIG FROM TERRAFORM OUTPUTS ----------
TF_OUTPUTS_PATH = os.path.join(os.path.dirname(__file__), "..", "terraform_outputs.json")

BUCKET_NAME = None
if os.path.exists(TF_OUTPUTS_PATH) and os.path.getsize(TF_OUTPUTS_PATH) > 0:
    try:
        with open(TF_OUTPUTS_PATH) as f:
            tf_outputs = json.load(f)

        # Auto-detect the first key that contains "bucket"
        bucket_keys = [k for k in tf_outputs.keys() if "bucket" in k.lower()]
        if bucket_keys:
            bucket_key = bucket_keys[0]
            BUCKET_NAME = tf_outputs[bucket_key]["value"]
            print(f"✅ Using bucket from terraform_outputs.json: {BUCKET_NAME}")
    except Exception as e:
        print("⚠️ Could not parse terraform_outputs.json, falling back to default bucket.")
        BUCKET_NAME = FALLBACK_BUCKET
else:
    print("⚠️ terraform_outputs.json not found or empty, using fallback bucket.")
    BUCKET_NAME = FALLBACK_BUCKET

# ---------- AWS CLIENT ----------
fake = Faker()
s3 = boto3.client("s3")

# Sample reference data
CATEGORIES = ["Liquor", "Grocery", "Clothing", "Electronics", "Furniture"]
PAYMENT_METHODS = ["Credit Card", "Cash", "Debit Card", "Mobile Pay", "PayPal"]
STORES = [
    ("S101", "Rockville LC", "Rockville"),
    ("S102", "Bethesda LC", "Bethesda"),
    ("S103", "Silver LC", "Silver Spring"),
    ("S104", "Gaithersburg LC", "Gaithersburg"),
    ("S105", "Germantown LC", "Germantown"),
]

def generate_record():
    store_id, store_name, city = random.choice(STORES)
    quantity = random.randint(1, 5)
    unit_price = round(random.uniform(1, 500), 2)

    return {
        "transaction_id": str(uuid.uuid4())[:8],
        "date": str(fake.date_between(start_date="-365d", end_date="today")),
        "store_id": store_id,
        "store_name": store_name,
        "city": city,
        "product_id": f"P{random.randint(1000,9999)}",
        "product_name": fake.word().title(),
        "category": random.choice(CATEGORIES),
        "customer_id": f"C{random.randint(1000,9999)}",
        "customer_name": fake.name(),
        "quantity_sold": quantity,
        "unit_price": unit_price,
        "total_amount": round(quantity * unit_price, 2),
        "payment_method": random.choice(PAYMENT_METHODS)
    }

def generate_sales_data():
    today = datetime.today()
    partition_prefix = f"{PREFIX}/year={today.year}/month={today.month:02}/day={today.day:02}/"
    key = f"{partition_prefix}sales_{today.strftime('%Y%m%d_%H%M%S')}.json"

    records = []
    file_size_bytes = 0
    target_bytes = TARGET_FILE_SIZE_MB * 1024 * 1024

    # keep adding records until ~target MB is reached
    while file_size_bytes < target_bytes:
        record = generate_record()
        line = json.dumps(record) + "\n"
        records.append(line)
        file_size_bytes += len(line.encode("utf-8"))

    # upload to S3
    json_data = "".join(records).encode("utf-8")
    s3.upload_fileobj(BytesIO(json_data), BUCKET_NAME, key)

    print(f"✅ Uploaded ~{TARGET_FILE_SIZE_MB}MB to s3://{BUCKET_NAME}/{key}")

if __name__ == "__main__":
    generate_sales_data()
