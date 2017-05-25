# Camlistore in a container (ARMified)
#
#  docker run -d -p 0.0.0.0:3179:3179 \
#    --name camlistore \
#    -v $HOME/.config/lego/certificates/$HOSTNAME.key:/root/.config/camlistore/certs/private.key \
#    -v $HOME/.config/lego/certificates/$HOSTNAME.crt:/root/.config/camlistore/certs/public.crt \
#    -v $HOME/.config/camlistore:/root/.config/camlistore/ \
#    -v /media/disk/camlistore_files:/root/var/camlistore \
#    --restart unless-stopped \
#    keyglitch/camlistore-arm

FROM resin/armhf-alpine:edge

ENV GOPATH /go
ENV PATH $PATH:$GOPATH/bin
ENV CGO_ENABLED 0

WORKDIR /go/src/github.com/camlistore/

RUN  apk add --no-cache ca-certificates && \
     apk add --no-cache --virtual .build-deps git go musl-dev && \
     git clone https://github.com/camlistore/camlistore && \
     cd /go/src/github.com/camlistore/camlistore && \
     go run make.go -arch arm && \
     mkdir -p /go/bin && \
     cp /go/src/github.com/camlistore/camlistore/bin/* /go/bin/ && \
     rm -rf /go/src/ && \
     apk del .build-deps

EXPOSE 80 443 3179 8080

CMD $GOPATH/bin/camlistored
