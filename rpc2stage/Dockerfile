FROM golang:latest

RUN git clone https://gitlab.com/iMil/goxplorer.git
RUN cd goxplorer && go install ./...


FROM python:3.7

RUN python -m pip install --upgrade pip
RUN pip install -Iv snowflake-connector-python==2.2.9

COPY --from=0 /go/bin/goxplorer /root
COPY rpc2stage.py /root
COPY stream.sh /root

RUN chmod 755 /root/goxplorer
RUN chmod 755 /root/stream.sh
WORKDIR /root

CMD /root/stream.sh | python /root/rpc2stage.py