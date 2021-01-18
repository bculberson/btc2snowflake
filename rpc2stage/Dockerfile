FROM python:3.7-buster

RUN python -m pip install --upgrade pip
RUN pip install -Iv bitcoin-etl==1.4.0
RUN pip install -Iv snowflake-connector-python==2.2.9

RUN apt-get update && apt-get install -y vim

COPY rpc2stage.py /root
WORKDIR /root

CMD /usr/local/bin/bitcoinetl stream -p ${CORERPC} -b 1000 -B 10000 -w 10 | python /root/rpc2stage.py