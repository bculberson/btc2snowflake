FROM node:alpine

RUN apk add --no-cache vim git

RUN git clone https://github.com/janoside/btc-rpc-explorer.git
RUN cd btc-rpc-explorer && npm install && npm run

WORKDIR /btc-rpc-explorer

CMD npm start