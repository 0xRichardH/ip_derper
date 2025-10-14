#!/bin/sh

CERT_HOST=$1
CERT_DIR=$2
CONF_FILE=$3

if echo "$CERT_HOST" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
    SAN_ENTRY="IP.1 = $CERT_HOST"
else
    SAN_ENTRY="DNS.1 = $CERT_HOST"
fi

echo "[req]
default_bits  = 256
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
countryName = XX
stateOrProvinceName = N/A
localityName = N/A
organizationName = Self-signed certificate
commonName = $CERT_HOST: Self-signed certificate

[req_ext]
subjectAltName = @alt_names

[v3_req]
subjectAltName = @alt_names

[alt_names]
$SAN_ENTRY
" > "$CONF_FILE"

mkdir -p "$CERT_DIR"
openssl req -x509 -nodes -days 7300 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -keyout "$CERT_DIR/$CERT_HOST.key" -out "$CERT_DIR/$CERT_HOST.crt" -config "$CONF_FILE"
