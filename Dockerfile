FROM golang:1.26-alpine AS builder

RUN apk add --no-cache curl git make bash
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community hugo

ENV DART_SASS_VERSION=1.101.0
RUN curl -sLO "https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-arm-musl.tar.gz" \
  && tar xf "dart-sass-${DART_SASS_VERSION}-linux-arm-musl.tar.gz" -C /usr/local \
  && rm "dart-sass-${DART_SASS_VERSION}-linux-arm-musl.tar.gz"

ENV PATH="/usr/local/dart-sass/bin:${PATH}"

WORKDIR /src
COPY . .

RUN make build
