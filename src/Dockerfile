FROM alpine:3 

RUN apk add openssl --no-cache

COPY gen-signed-cert.sh /bin/gen-signed-cert
RUN chmod +x /bin/gen-signed-cert

WORKDIR /certs

ENTRYPOINT [ "gen-signed-cert" ]