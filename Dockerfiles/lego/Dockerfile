# Lets Encrypt Go (Lego) in a container (ARMified)
#
# Example invocations:
#
# Getting a certificate using the DNS challenge
#
# docker run --rm \
# -v $HOME/.config/lego:/.lego \
# -e CLOUDFLARE_EMAIL="REPLACE_ME@example.com" \
# -e CLOUDFLARE_API_KEY="REPLACE_ME" \
# keyglitch/arm-storage:lego-latest \
# --email="REPLACE_ME@example.com" \
# --domains="REPLACE_ME.example.com" \
# --dns="cloudflare" \
# --dns-resolvers="8.8.8.8" \
# --dns-resolvers="8.8.4.4" \
# -a \
# run \
#
# Renewing a certificate
#
# docker run --rm \
# -v $HOME/.config/lego:/.lego \
# -e CLOUDFLARE_EMAIL="REPLACE_ME@example.com" \
# -e CLOUDFLARE_API_KEY="REPLACE_ME" \
# keyglitch/arm-storage:lego-latest \
# --email="REPLACE_ME@example.com" \
# --domains="REPLACE_ME.example.com" \
# --dns="cloudflare" \
# --dns-resolvers="8.8.8.8" \
# --dns-resolvers="8.8.4.4" \
# renew \
# --days=60

FROM resin/armhf-alpine:latest

ENV GOPATH /go

RUN apk update && apk add ca-certificates go git musl-dev && \
    rm -rf /var/cache/apk/* && \
    go get -u github.com/xenolf/lego && \
    cd /go/src/github.com/xenolf/lego && \
    go build -o /usr/bin/lego . && \
    apk del go git && \
    rm -rf /var/cache/apk/* && \
    rm -rf /go

ENTRYPOINT [ "/usr/bin/lego" ]
