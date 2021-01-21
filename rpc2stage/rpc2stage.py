import fileinput
import os
import snowflake.connector
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization


SFACCOUNT = os.getenv('SFACCOUNT')
SFUSER = os.getenv('SFUSER')
SFPRIVATEKEY = os.getenv('SFPRIVATEKEY')
FLUSH_SIZE = int(os.getenv('FLUSH_SIZE'))

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
    sql += " @btc_stage auto_compress=true"
    conn.cursor().execute(sql)
    os.remove(file)


batch = 0
batch_size = 0
batch_name = "batch_%d.json" % batch

f = open(batch_name, "a+")
for line in fileinput.input():
    f.write(line)
    batch_size += len(line)
    if batch_size > FLUSH_SIZE:
        f.close()
        upload_batch(batch_name)
        batch+=1
        batch_size = 0
        batch_name = "batch_%d.json" % batch
        f = open(batch_name, "w")

f.close()
upload_batch(batch_name)
