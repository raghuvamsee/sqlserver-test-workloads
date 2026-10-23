"""End-to-end smoke test for the Snowflake WideWorldImportersDW procedures.

Redeploys 01_schema.sql and 02_procedures.sql first (recreating every table and sequence in
WIDEWORLDIMPORTERSDW), because the expected keys assume freshly created sequences.
Connection settings come from SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PRIVATE_KEY_PATH,
SNOWFLAKE_ROLE and SNOWFLAKE_WAREHOUSE. Requires snowflake-connector-python.
"""
import io
import os
import sys

import snowflake.connector
from cryptography.hazmat.primitives import serialization


def connect(**kw):
    with open(os.path.expanduser(os.environ["SNOWFLAKE_PRIVATE_KEY_PATH"]), "rb") as f:
        key = serialization.load_pem_private_key(f.read(), password=None)
    der = key.private_bytes(serialization.Encoding.DER, serialization.PrivateFormat.PKCS8, serialization.NoEncryption())
    return snowflake.connector.connect(account=os.environ["SNOWFLAKE_ACCOUNT"], user=os.environ["SNOWFLAKE_USER"],
                                       private_key=der, role=os.environ.get("SNOWFLAKE_ROLE"),
                                       warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE"), **kw)

c = connect()
here = os.path.dirname(os.path.abspath(__file__))
for name in ("01_schema.sql", "02_procedures.sql"):
    with open(os.path.join(here, name)) as f:
        n = sum(1 for _ in c.execute_stream(io.StringIO(f.read())))
    print(f"deployed {name}: {n} statements")
cur = c.cursor()
cur.execute("USE DATABASE WIDEWORLDIMPORTERSDW")
fails = 0
def run(sql, show=False, expect_error=None):
    global fails
    try:
        rows = cur.execute(sql).fetchall()
        if expect_error:
            fails += 1; print("FAIL (expected error):", sql[:80]); return
        if show: print(" ", sql.split("\n")[0][:90], "->", rows)
        return rows
    except Exception as e:
        if expect_error and expect_error in str(e):
            print("  expected error OK:", str(e).splitlines()[-1][:100]); return
        fails += 1; print("ERROR:", sql.split("\n")[0][:90], "\n   ", str(e)[:400])
def check(label, sql, expected):
    global fails
    r = run(sql)
    got = [tuple(x) for x in r] if r is not None else None
    ok = got == expected
    if not ok: fails += 1
    print(("ok  " if ok else "FAIL"), label, "" if ok else f"got {got} expected {expected}")

VF, EOT = "'2013-01-01'::TIMESTAMP_NTZ", "'9999-12-31 23:59:59.9999999'::TIMESTAMP_NTZ"
def lineage(t, ts="2013-06-30"): run(f"""CALL "Integration"."GetLineageKey"('{t}', '{ts}'::TIMESTAMP_NTZ)""")

print("== setup")
run('CALL "Application"."Configuration_ReseedETL"()')
check("unknown members", 'SELECT (SELECT COUNT(*) FROM "Dimension"."City" WHERE "City Key"=0)+(SELECT COUNT(*) FROM "Dimension"."Stock Item" WHERE "Stock Item Key"=0)+(SELECT COUNT(*) FROM "Dimension"."Transaction Type")', [(3,)])
run('DELETE FROM "Dimension"."Date"'); run('DELETE FROM "Integration"."ETL Cutoff"')
run("""INSERT INTO "Integration"."ETL Cutoff" SELECT column1, '2012-12-31'::TIMESTAMP_NTZ FROM VALUES ('City'),('Customer'),('Employee'),('Payment Method'),('Stock Item'),('Supplier'),('Transaction Type'),('Movement'),('Order'),('Purchase'),('Sale'),('Stock Holding'),('Transaction')""")
run('CALL "Integration"."PopulateDateDimensionForYear"(2013)')
run('CALL "Integration"."PopulateDateDimensionForYear"(2013)')
check("2013 dates (idempotent)", 'SELECT COUNT(*), MIN("Date"), MAX("Date") FROM "Dimension"."Date"', [(365, __import__("datetime").date(2013,1,1), __import__("datetime").date(2013,12,31))])
check("date row 2013-11-04", 'SELECT "Day Number","Day","Month","Short Month","Calendar Month Label","Calendar Year Label","Fiscal Month Number","Fiscal Month Label","Fiscal Year","Fiscal Year Label","ISO Week Number" FROM "Dimension"."Date" WHERE "Date"=\'2013-11-04\'',
      [(4, '4', 'November', 'Nov', 'CY2013-Nov', 'CY2013', 1, 'FY2014-Nov', 2014, 'FY2014', 45)])
check("ISO week 2013-01-01", 'SELECT "ISO Week Number" FROM "Dimension"."Date" WHERE "Date"=\'2013-01-01\'', [(1,)])
import datetime
check("GetLastETLCutoffTime", """CALL "Integration"."GetLastETLCutoffTime"('Sale')""", [(datetime.datetime(2012,12,31),)])
run("""CALL "Integration"."GetLastETLCutoffTime"('Nope')""", expect_error="Invalid ETL table name")

print("== dimensions")
for t in ["City","Customer","Employee","PaymentMethod","StockItem","Supplier","TransactionType"]: run(f'DELETE FROM "Integration"."{t}_Staging"')
run(f"""INSERT INTO "Integration"."City_Staging" ("WWI City ID","City","State Province","Country","Continent","Sales Territory","Region","Subregion","Location","Latest Recorded Population","Valid From","Valid To")
  SELECT 10,'Seattle','Washington','United States','North America','Far West','Americas','Northern America',TO_GEOGRAPHY('POINT(-122.33 47.61)'),600000,{VF},{EOT}""")
run(f"""INSERT INTO "Integration"."Customer_Staging" ("WWI Customer ID","Customer","Bill To Customer","Category","Buying Group","Primary Contact","Postal Code","Valid From","Valid To") SELECT 20,'Tailspin','Tailspin','Novelty','Tailspin','Kim','98101',{VF},{EOT}""")
run(f"""INSERT INTO "Integration"."Employee_Staging" ("WWI Employee ID","Employee","Preferred Name","Is Salesperson","Photo","Valid From","Valid To") SELECT 30,'Kayla Woodcock','Kayla',TRUE,NULL,{VF},{EOT}""")
run(f"""INSERT INTO "Integration"."PaymentMethod_Staging" ("WWI Payment Method ID","Payment Method","Valid From","Valid To") SELECT 40,'Cash',{VF},{EOT}""")
run(f"""INSERT INTO "Integration"."StockItem_Staging" ("WWI Stock Item ID","Stock Item","Color","Selling Package","Buying Package","Brand","Size","Lead Time Days","Quantity Per Outer","Is Chiller Stock","Barcode","Tax Rate","Unit Price","Recommended Retail Price","Typical Weight Per Unit","Photo","Valid From","Valid To")
  SELECT 50,'USB rocket','Blue','Each','Carton','N/A','N/A',7,10,FALSE,'N/A',15,25,37.5,0.3,NULL,{VF},{EOT}""")
run(f"""INSERT INTO "Integration"."Supplier_Staging" ("WWI Supplier ID","Supplier","Category","Primary Contact","Supplier Reference","Payment Days","Postal Code","Valid From","Valid To") SELECT 60,'Litware','Toys','Bob','LW1',30,'98052',{VF},{EOT}""")
run(f"""INSERT INTO "Integration"."TransactionType_Staging" ("WWI Transaction Type ID","Transaction Type","Valid From","Valid To") SELECT 70,'Stock Issue',{VF},{EOT}""")
for label, p in [("City","City"),("Customer","Customer"),("Employee","Employee"),("Payment Method","PaymentMethod"),("Stock Item","StockItem"),("Supplier","Supplier"),("Transaction Type","TransactionType")]:
    lineage(label); run(f'CALL "Integration"."MigrateStaged{p}Data"()')
check("dims loaded with sequence keys", 'SELECT (SELECT "City Key" FROM "Dimension"."City" WHERE "WWI City ID"=10), (SELECT "Stock Item Key" FROM "Dimension"."Stock Item" WHERE "WWI Stock Item ID"=50), (SELECT ST_X("Location") FROM "Dimension"."City" WHERE "WWI City ID"=10)', [(1, 1, -122.33)])
check("lineage completed + cutoff advanced", """SELECT COUNT(*) FROM "Integration"."Lineage" WHERE "Was Successful" AND "Data Load Completed" IS NOT NULL""", [(7,)])
check("ETL cutoff City", """SELECT "Cutoff Time" FROM "Integration"."ETL Cutoff" WHERE "Table Name"='City'""", [(datetime.datetime(2013,6,30),)])
# SCD2: new version of city 10 from 2013-03-01
run('DELETE FROM "Integration"."City_Staging"')
run(f"""INSERT INTO "Integration"."City_Staging" ("WWI City ID","City","State Province","Country","Continent","Sales Territory","Region","Subregion","Location","Latest Recorded Population","Valid From","Valid To")
  SELECT 10,'Seattle','Washington','United States','North America','Far West','Americas','Northern America',NULL,700000,'2013-03-01'::TIMESTAMP_NTZ,{EOT}""")
lineage("City", "2013-07-31"); run('CALL "Integration"."MigrateStagedCityData"()')
check("SCD2 close-off", 'SELECT "City Key","Valid From","Valid To" FROM "Dimension"."City" WHERE "WWI City ID"=10 ORDER BY 1',
      [(1, datetime.datetime(2013,1,1), datetime.datetime(2013,3,1)), (2, datetime.datetime(2013,3,1), datetime.datetime(9999,12,31,23,59,59,999999))])

print("== facts")
for t in ["Sale","Order","Purchase","Movement","StockHolding","Transaction"]: run(f'DELETE FROM "Integration"."{t}_Staging"')
sale = """INSERT INTO "Integration"."Sale_Staging" ("Invoice Date Key","Delivery Date Key","WWI Invoice ID","Description","Package","Quantity","Unit Price","Tax Rate","Total Excluding Tax","Tax Amount","Profit","Total Including Tax","Total Dry Items","Total Chiller Items","WWI City ID","WWI Customer ID","WWI Bill To Customer ID","WWI Stock Item ID","WWI Salesperson ID","Last Modified When")
  SELECT column1::DATE, column1::DATE + 1, column2, 'USB rocket', 'Each', 2, 25, 15, 50, 7.5, 20, 57.5, 2, 0, column3, 20, 20, 50, 30, column4::TIMESTAMP_NTZ FROM VALUES"""
run(sale + " ('2013-02-01', 1001, 10, '2013-02-01'), ('2013-06-01', 1002, 10, '2013-06-01'), ('2013-06-01', 1003, 999, '2013-06-01')")
lineage("Sale"); run('CALL "Integration"."MigrateStagedSaleData"()')
check("Sale keys: SCD window + unknown member", 'SELECT "WWI Invoice ID","City Key","Customer Key","Bill To Customer Key","Stock Item Key","Salesperson Key" FROM "Fact"."Sale" ORDER BY 1',
      [(1001,1,1,1,1,1),(1002,2,1,1,1,1),(1003,0,1,1,1,1)])
lineage("Sale"); run('CALL "Integration"."MigrateStagedSaleData"()')  # rerun: delete+insert, no dupes
check("Sale rerun idempotent", 'SELECT COUNT(*) FROM "Fact"."Sale"', [(3,)])

run("""INSERT INTO "Integration"."Order_Staging" ("Order Date Key","Picked Date Key","WWI Order ID","WWI Backorder ID","Description","Package","Quantity","Unit Price","Tax Rate","Total Excluding Tax","Tax Amount","Total Including Tax","WWI City ID","WWI Customer ID","WWI Stock Item ID","WWI Salesperson ID","WWI Picker ID","Last Modified When")
  SELECT '2013-06-01','2013-06-02',2001,NULL,'USB rocket','Each',1,25,15,25,3.75,28.75,10,20,50,30,30,'2013-06-01'::TIMESTAMP_NTZ""")
lineage("Order"); run('CALL "Integration"."MigrateStagedOrderData"()')
check("Order keys", 'SELECT "City Key","Customer Key","Stock Item Key","Salesperson Key","Picker Key" FROM "Fact"."Order"', [(2,1,1,1,1)])

run("""INSERT INTO "Integration"."Purchase_Staging" ("Date Key","WWI Purchase Order ID","Ordered Outers","Ordered Quantity","Received Outers","Package","Is Order Finalized","WWI Supplier ID","WWI Stock Item ID","Last Modified When")
  SELECT '2013-06-01',3001,5,50,5,'Carton',TRUE,60,50,'2013-06-01'::TIMESTAMP_NTZ""")
lineage("Purchase"); run('CALL "Integration"."MigrateStagedPurchaseData"()')
check("Purchase keys", 'SELECT "Supplier Key","Stock Item Key","Is Order Finalized" FROM "Fact"."Purchase"', [(1,1,True)])

mv = """INSERT INTO "Integration"."Movement_Staging" ("Date Key","WWI Stock Item Transaction ID","WWI Invoice ID","WWI Purchase Order ID","Quantity","WWI Stock Item ID","WWI Customer ID","WWI Supplier ID","WWI Transaction Type ID","Last Modifed When")
  SELECT '2013-06-01',4001,1002,NULL,{q},50,20,NULL,70,'2013-06-01'::TIMESTAMP_NTZ"""
run(mv.format(q=-2)); lineage("Movement"); run('CALL "Integration"."MigrateStagedMovementData"()')
run('DELETE FROM "Integration"."Movement_Staging"'); run(mv.format(q=-5)); lineage("Movement"); run('CALL "Integration"."MigrateStagedMovementData"()')
check("Movement MERGE updates existing", 'SELECT COUNT(*), MAX("Quantity"), MAX("Stock Item Key"), MAX("Customer Key"), MAX("Supplier Key"), MAX("Transaction Type Key") FROM "Fact"."Movement"', [(1,-5,1,1,0,1)])

run("""INSERT INTO "Integration"."StockHolding_Staging" ("Quantity On Hand","Bin Location","Last Stocktake Quantity","Last Cost Price","Reorder Level","Target Stock Level","WWI Stock Item ID") SELECT 100,'A1',100,12.5,10,200,50""")
lineage("Stock Holding"); run('CALL "Integration"."MigrateStagedStockHoldingData"()')
check("Stock Holding latest item version", 'SELECT "Stock Item Key","Quantity On Hand" FROM "Fact"."Stock Holding"', [(1,100)])

run("""INSERT INTO "Integration"."Transaction_Staging" ("Date Key","WWI Customer Transaction ID","WWI Supplier Transaction ID","WWI Invoice ID","WWI Purchase Order ID","Supplier Invoice Number","Total Excluding Tax","Tax Amount","Total Including Tax","Outstanding Balance","Is Finalized","WWI Customer ID","WWI Bill To Customer ID","WWI Supplier ID","WWI Transaction Type ID","WWI Payment Method ID","Last Modified When")
  SELECT '2013-06-01',5001,NULL,1002,NULL,NULL,50,7.5,57.5,0,TRUE,20,20,NULL,70,40,'2013-06-01'::TIMESTAMP_NTZ""")
lineage("Transaction"); run('CALL "Integration"."MigrateStagedTransactionData"()')
check("Transaction keys", 'SELECT "Customer Key","Bill To Customer Key","Supplier Key","Transaction Type Key","Payment Method Key" FROM "Fact"."Transaction"', [(1,1,0,1,1)])

print("== sequences / large sale")
run("""INSERT INTO "Dimension"."City" ("City Key","WWI City ID","City","State Province","Country","Continent","Sales Territory","Region","Subregion","Latest Recorded Population","Valid From","Valid To","Lineage Key") SELECT 500,11,'x','x','x','x','x','x','x',0,'2013-01-01','2013-01-02',0""")
run('CALL "Sequences"."ReseedAllSequences"()')
check("City sequence moved past max", 'SELECT "Sequences"."CityKey".NEXTVAL', [(501,)])
run('CALL "Application"."Configuration_PopulateLargeSaleTable"(730)')
check("Large sale table: 2 rows/day for 2012-01-01..2012-12-30 (365 days)", """SELECT COUNT(*) FROM "Fact"."Sale" WHERE YEAR("Invoice Date Key")=2012""", [(730,)])
check("2012 dates populated", 'SELECT COUNT(*) FROM "Dimension"."Date" WHERE YEAR("Date")=2012', [(366,)])
print("FAILURES:", fails)
sys.exit(1 if fails else 0)
