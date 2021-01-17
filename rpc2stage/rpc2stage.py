import fileinput
import os
import snowflake.connector
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization


SFACCOUNT = os.getenv('SFACCOUNT')
SFUSER = os.getenv('SFUSER')
SFPRIVATEKEY = """-----BEGIN ENCRYPTED PRIVATE KEY-----
MIIE6TAbBgkqhkiG9w0BBQMwDgQIjNARwnOPW68CAggABIIEyJkdLH45APXW4OPT
i9izQBiun5/8LuS5QVvjNiN1sCObR1RX5A1Lm2DKEqozLgGT2wYCHLYVOARBFDEb
8Pd1zhQnK/Stw3pyoSC+EcXl9SPTMJoB5p4edfTxyJy2+j5xoOSm+fJhlaYrauud
NA+sCjiWqZW580PWrrd1s/YgiPrnixtY0YgkMym3gtItmzJyTrlWwW3k9Qb9R+Sz
ZMr5wJ2un0pEFMYwQRn9/8w6Qh3bzSNa23o7wXcuBz9yxcYLAeqNYIOmiVXm9vng
IyIKh7CYaxcDlH+lIL1Dd9es1PM19COg9NaKfEFI89er9s1YLuIx6xPPVpWhIP7u
Ewy9EOoeHL43rRjWDjzjURoOSwZYcnQM+KoZkGJPXwElYFIl5WQq4ZgrP+K1T9nc
R3oiQ49PBHKA/4rqHm9SQrPmheshfMvbKMiOfI6X+iOZzHvpFe0ZVtI0VqS9NTy7
CHkNcfnGMoirsfT9AaAkUtQj6MpFnHenkOkCiEQwvE/txb7HWMrmFeIfiLe0d0E8
SBlpy0qpRbhri67jsGGBjIG4vUIh5vGvIN1pUXveFyRC7rJDGNlCn040l5PGmnaA
O8tB89mF+8EAdWEa5yBhXXQsK3CN6suuE2fLIZchqOOXUBAqLijjC0KnXySGP5cg
p3Q2/ztZ3PQ5ZEq40P9rSs1vbV5ZpxzXerN3JDGICnWd4Ic91iOdmSfYWCWl5YmT
oc2J0QZoRLFvFbmBqMnt2TOfbdobuyjzYDmyImdmauVt34QtXZgo7gGm3ZR/ATvD
+IQ7iYhBJojJOh6IiV8LRllvkyJe3r953b1PlMrSCoj351GhNo0jivMPBlG1X64p
ljwWtKcJi2MtNaIwNMvMVgoaFLEIIeaET9nk8IXHcvGG5ExZ7aerEAy4c6L9ZMqi
CgvK6ADH7I44cIXWwLhnXKR+xuclhxEfvGxODdcwTq+lve/6wesaQ1J1CJaOhRxX
lafHIidVrfMhgmvMjJfDCMV2DKyINGgqodwWgSkXCpCUdGceVs27EfO5mDVIVe1Z
UWy4cCmvuP+SNr3M7o8W4HKLARSJjhr5RxwcpUYjnOrGr881BVjSxXRyTGMOQfM7
a6zhTZqlGZKG84sOxiIifYpqINRgqew0uEFRbt+d/Wcldqz6MXH1jtF+GNDRR16n
44O2rUhsvb7cWqLMEvmF/ouwhnpP2mTE1s87vSwjI0B7LJn/FBOBCTtc/sSPVYak
ojksOMgfcDESKxLgDLBAXfGUOwrdpW6Ax88ADZ8n7O5MJzxlE8FHFiY6/qTdybGH
EOt84KCi1D6svj9vzShRjnTQHxLvlmjWFWCQTXHkmbxq2n7gheTYQ5n7+YnT4YVx
rjJUN5RElqPiitJTSUWD4y5hjrHxqgjkloxnLtgyFae+o3fSJGinxnlnApzzotDC
Ff/N+qlhLNCVapliNnwMWfkVFMi3NLZPZCoBJviSBteae7ew+SmJY/vFTrptPngL
aZvq2k/3I0PDZ6JgbronJwdi3IcbJWEZh7gBIke0cs62s6yao0PsxqC+q6/HH/No
YRSr253VkYXEUDv4bO4TnFvT7vhwShaP8atW6r9aojpJzwiLRT/8I0pMo/IEe2fJ
cW1NYsskX8KklmJLWw==
-----END ENCRYPTED PRIVATE KEY-----"""

SFPRIVATEKEYPASSWORD = os.getenv('SFPRIVATEKEYPASSWORD')
FLUSH_SIZE = 100000000

p_key= serialization.load_pem_private_key(SFPRIVATEKEY.encode(), password=SFPRIVATEKEYPASSWORD.encode(), backend=default_backend())
pkb = p_key.private_bytes(
    encoding=serialization.Encoding.DER,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=serialization.NoEncryption())


def get_conn():
    return snowflake.connector.connect(
        user=SFUSER,
        account=SFACCOUNT,
        private_key=pkb,
        session_parameters={
            'QUERY_TAG': 'RPC2STAGE',
        }
    )

def upload_batch(file):
    conn=get_conn()
    print("uploading %s" % file)
    sql = "PUT file:///root/%s % file"
    sql += " @%btc_blockchain_raw"

    conn.cursor().execute(sql)
    os.remove(file)


batch = 0
batch_size = 0
batch_name = "batch_%d.json" % batch

f = open(batch_name, "w")
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
