# ARMified Minio in a container

FROM resin/armhf-alpine:edge

ENV GOPATH /go
ENV PATH $PATH:$GOPATH/bin
ENV CGO_ENABLED 0

WORKDIR /go

RUN  apk add --no-cache ca-certificates && \
     apk add --no-cache git go musl-dev && \
     go get github.com/minio/minio && \
     rm -rf /go/src/

EXPOSE 9000

CMD $GOPATH/bin/minio
