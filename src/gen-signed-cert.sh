#!/bin/sh
set -e
CA_FILE_NAME=/certs/ca
CERT_FILE_NAME="/certs/$SSL_SUBJECT"

echo "Starting gen-signed-cert for $SSL_SUBJECT"

# generate CA
if test -f "$CA_FILE_NAME.pem"; then
    echo "Found CA file, reusing: $FILE"
else
    echo "Generating Root Certification Authority: $CA_FILE_NAME.{pem,key}"
    # Generate private key
    openssl genrsa -out "$CA_FILE_NAME".key 2048
    # Generate root certificate
    openssl req -x509 -new -nodes \
        -key "$CA_FILE_NAME".key \
        -sha256 \
        -days 36500 \
        -subj "/CN=$SSL_SUBJECT Fake CA/" \
        -out "$CA_FILE_NAME".pem
fi

# generate PK
if test -f "${CERT_FILE_NAME}.key"; then
    echo "Found Certificate Private Key file, reusing: ${CERT_FILE_NAME}.key"
else
    echo "Generating Certificate Private Key: ${CERT_FILE_NAME}.key"
    openssl genrsa -out "${CERT_FILE_NAME}.key" 2048
fi

# generate CSR
if test -f "${CERT_FILE_NAME}.csr"; then
    echo "Found CSR file, reusing: ${CERT_FILE_NAME}.csr"
else
    echo "Generating Certificate Signing Request: ${CERT_FILE_NAME}.csr"
    openssl req -new -sha256 \
        -key ${CERT_FILE_NAME}.key \
        -subj "CN=${CERT_FILE_NAME}" \
        -addext "subjectAltName = DNS:$SSL_SUBJECT" \
        -subj "/CN=$SSL_SUBJECT/" \
        -out ${CERT_FILE_NAME}.csr
fi

# generate extensions
if test -f "${CERT_FILE_NAME}.ext"; then
    echo "Found extensions file, reusing: ${CERT_FILE_NAME}.ext"
else
    echo "Generating Extensions File: ${CERT_FILE_NAME}.ext"
    cat >${CERT_FILE_NAME}.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $SSL_SUBJECT
EOF
fi

# verify contents
# echo "CSR Contents ${CERT_FILE_NAME}.csr:"
# openssl req -in ${CERT_FILE_NAME}.csr -noout -text

# generate a cert based on the CSR signed by the CA
echo "Generating signed certificate ${CERT_FILE_NAME}.crt"
openssl x509 -req -in ${CERT_FILE_NAME}.csr \
    -CA "$CA_FILE_NAME".pem \
    -CAkey "$CA_FILE_NAME".key \
    -CAcreateserial \
    -out ${CERT_FILE_NAME}.crt \
    -days 36500 -sha256 \
    -extfile ${CERT_FILE_NAME}.ext

echo "Generating PFX file ${CERT_FILE_NAME}.pfx "
# generate PFX
openssl pkcs12 -export -out ${CERT_FILE_NAME}.pfx \
    -passout "pass:" \
    -inkey ${CERT_FILE_NAME}.key -in ${CERT_FILE_NAME}.crt
