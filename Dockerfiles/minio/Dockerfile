# ARMified Minio in a container
# An example minio run, with four disks and an Lets Encrypt certificate 
# provisioned with Lego
#
# docker run -d -p 0.0.0.0:9000:9000 \
# --name minio \
# -v /media/disk/minio-storage:/export \
# -v /media/disk2/minio-storage:/export2 \
# -v /media/disk3/minio-storage:/export3 \
# -v /media/disk4/minio-storage:/export4 \
# -v $HOME/.config/minio/:/root/.minio/ \
# -v $HOME/.config/lego/certificates/$HOSTNAME.key:/root/.minio/certs/private.key \
# -v $HOME/.config/lego/certificates/$HOSTNAME.crt:/root/.minio/certs/public.crt \
# --restart unless-stopped \
# --memory=1GB \
# --cpuset-cpus 4-7 \
# keyglitch/arm-storage:minio-latest server /export /export2 /export3 /export4

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
