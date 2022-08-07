FROM alpine:3.10.3
MAINTAINER hamshif

## alpine curl and wget aren't fully compatible, so we install them
## here. gnupg is needed for Module::Signature.
RUN apk update && apk upgrade
RUN apk add --no-cache curl tar make gcc build-base wget gnupg ca-certificates g++ git gd-dev
RUN apk add --no-cache zlib zlib-dev
RUN apk add --no-cache perl perl-dev
RUN apk add --no-cache librdkafka-dev

RUN apk add --no-cache perl-app-cpanminus
RUN cpanm App::cpm

COPY . /usr/src/myapp

WORKDIR /usr

RUN cpm install Try::Tiny
RUN cpm install Net::Kafka

ENV PERL5LIB=/usr/local/lib/perl5
ENV PATH=/usr/local/bin:$PATH

COPY . /usr/src/myapp
WORKDIR /usr/src/myapp

## RUN apk add --no-cache musl-obstack-dev --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main
