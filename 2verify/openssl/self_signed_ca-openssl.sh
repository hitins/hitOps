#!/bin/bash

echo "Info: create ssl/tls key and certificate with self_signed ca"
echo 'Info: before creating them, edit openssl.conf options - "alt_names" and others !'

# Create and Clean dir "self_signed_ca-openssl"
mkdir -p self_signed_ca-openssl
cd self_signed_ca-openssl && rm -rf ./*
cp ../openssl.conf ./ || exit 1

# Create self_signed ca 
[[ -d "ca" ]] && rm -rf ca || continue
mkdir -p ca && cd ca
mkdir certs && chmod 700 certs
touch index
echo "1000" > serial
# New ca key
PHRASE=$(openssl rand -base64 32)
openssl genrsa -aes256 -passout pass:$PHRASE -out certs/ca.key 4096 && chmod 400 certs/ca.key
# New ca certificate with [openssl.conf, ca key], be trusted on client for using ssl pair
openssl req -passin pass:$PHRASE -config ../openssl.conf -key certs/ca.key -new -x509 -days 3650 -sha512 -extensions v3_ca -out certs/ca.crt  -subj "/C=GB/ST=England/L=London/O=Ltd/OU=Part/CN=Private/emailAddress=\."

# Return to dir "self_signed_ca-openssl"
cd ..

# Create self_signed ca ssl pair
[[ -d "ssl" ]] && rm -rf ssl || continue
mkdir -m 700 ssl
# New ssl ey, ed25519 may not be decoded
openssl genrsa -out ssl/ssl.key 4096
chmod 400 ssl/ssl.key
# New ssl csr with [openssl.conf, ssl key]
openssl req -config openssl.conf -key ssl/ssl.key -new -sha512 -out ssl/ssl.csr -subj "/C=GB/ST=England/L=London/O=Ltd/OU=Part/CN=Private/emailAddress=\."
# New ssl certificate with [openssl.cnf, ssl csr], greater than 825 days may not be trusted on IOS
(echo y;echo y)|openssl ca -passin pass:$PHRASE -config openssl.conf -extensions server_cert -days 825 -notext -md sha512 -in ssl/ssl.csr -out ssl/ssl.cert 
chmod 400 ssl/ssl.cert

# Output
[[ -d "out" ]] && rm -rf out
mkdir -p out
cp ssl/ssl.key ssl/ssl.cert ca/certs/ca.crt out

echo "Phrase for more ssl keys: '$PHRASE' "
