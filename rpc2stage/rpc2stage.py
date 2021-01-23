import fileinput
import os
import snowflake.connector
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization


SFACCOUNT = os.getenv('SFACCOUNT')
SFUSER = os.getenv('SFUSER')
SFPRIVATEKEY = os.getenv('SFPRIVATEKEY')

p_key = serialization.load_pem_private_key(SFPRIVATEKEY.encode('utf-8'), password=None, backend=default_backend())
pkb = p_key.private_bytes(
    encoding=serialization.Encoding.DER,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=serialization.NoEncryption())


def get_conn():
    global conn
    conn = snowflake.connector.connect(
        user=SFUSER,
        account=SFACCOUNT,
        database='BTC',
        schema='BTC',
        private_key=pkb,
        session_parameters={
            'QUERY_TAG': 'RPC2STAGE',
        }
    )
    return conn


conn = get_conn()


def upload_batch(file):
    print("uploading %s" % file)

    sql = "PUT file:///root/%s" % file
    sql += " @BTC.BTC.\"btc_stage\" OVERWRITE=TRUE;"
    conn.cursor().execute(sql)
    os.remove(file)


for line in fileinput.input():
    upload_batch(line.rstrip())
