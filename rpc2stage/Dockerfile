FROM python:3.7

RUN python -m pip install --upgrade pip
RUN pip install -Iv bitcoin-etl==1.4.0
RUN pip install -Iv snowflake-connector-python==2.2.9

COPY rpc2stage.py /root
WORKDIR /root

CMD /usr/local/bin/bitcoinetl stream -p ${CORERPC} -b 20 -B 100 -w 5 | python /root/rpc2stage.py