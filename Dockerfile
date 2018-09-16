FROM alpine:3.8
MAINTAINER ototadana@gmail.com

ENV NODEJS_VERSION 8.11.4-r0
ENV YARN_VERSION 1.7.0-r0

RUN apk add --no-cache nodejs=${NODEJS_VERSION} yarn=${YARN_VERSION} git openssh-client

COPY ./package.json /clirbeaux/
RUN cd /clirbeaux/ && yarn install

WORKDIR /clirbeaux
CMD ["/bin/sh", "./sh/start.sh"]

COPY ./. /clirbeaux/
