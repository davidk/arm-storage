# Perkeep in a container (ARMified)
#
# docker run -d -p 0.0.0.0:3179:3179 \
#   --name perkeep \
#   -v $HOME/.config/lego/certificates/$HOSTNAME.key:/root/.config/perkeep/certs/private.key \
#   -v $HOME/.config/lego/certificates/$HOSTNAME.crt:/root/.config/perkeep/certs/public.crt \
#   -v $HOME/.config/perkeep:/root/.config/perkeep/ \
#   -v /media/disk/camlistore_files:/root/var/perkeep \
#   --restart unless-stopped \
#   keyglitch/arm-storage:perkeep-latest
# 
# If you need to run perkeep in recovery, change this line to this:
# 	keyglitch/arm-storage:perkeep-latest /usr/bin/perkeepd -recovery=1
#

FROM resin/armhf-alpine:edge
ENV GOPATH /go
ENV PATH $PATH:$GOPATH/bin
ENV CGO_ENABLED 0

WORKDIR /go/src

RUN  apk add --no-cache ca-certificates && \
     apk add --no-cache --virtual .build-deps git go1.10 musl-dev && \
     git clone https://github.com/perkeep/perkeep ./perkeep.org && \
     cd /go/src/perkeep.org/ && \
     go run make.go && \
     cp /go/bin/perkeepd /usr/bin/ && \
     rm -rf /go/src/ && \
     apk del .build-deps

EXPOSE 80 443 3179 8080

# 2018-03-01: perkeep is still building its binary as camlistored,
# when upstream changes the naming this needs to be updated.

CMD [ "/usr/bin/perkeepd" ]

