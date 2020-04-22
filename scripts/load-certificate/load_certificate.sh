#!/usr/bin/env bash

WORKDIR="/opt/nuts/temp"
NODEDIR="/opt/nuts/node"
PACKAGEDIR="/opt/nuts/dist"
CONFDIR="${PACKAGEDIR}/conf"

if ! ls ${NODEDIR}/certificates 2>&1 1>/dev/null; then
  echo "node directory not mounted to ${NODEDIR}"
  exit 1
fi

if ! ls ${CONFDIR}/sslkeystore.conf 2>&1 1>/dev/null; then
  echo "conf directory not mounted to ${CONFDIR}"
  exit 1
fi

if ! ls ${PACKAGEDIR}/certs 2>&1 1>/dev/null; then
  echo "package directory not mounted to ${PACKAGEDIR}"
  exit 1
fi

mkdir -p $WORKDIR

# export private keys from nodekeystore.jks
echo "Exporting generated private key from ${NODEDIR}/certificates/nodekeystore.jks to pkcs12"
if ! keytool -importkeystore -srckeystore ${NODEDIR}/certificates/nodekeystore.jks -destkeystore ${WORKDIR}/nodekeystore.p12 -deststoretype PKCS12 -srcalias cordaclientca -deststorepass cordacadevpass -destkeypass cordacadevpass; then
  exit 1
fi

# export from pkcs12
echo "Exporting generated private key from pkcs12 to der"
if ! openssl pkcs12 -in ${WORKDIR}/nodekeystore.p12 -nodes -nocerts -out ${WORKDIR}/cordaclientca.key; then
  exit 1
fi

# create chain
echo "Creating cert chain with certs from network operator"
{
  openssl x509 -inform DER -outform PEM -in ${PACKAGEDIR}/certs/cordaclientca.cer;
  openssl x509 -inform DER -outform PEM -in ${PACKAGEDIR}/certs/cordaintermediateca.cer;
  openssl x509 -inform DER -outform PEM -in ${PACKAGEDIR}/certs/cordarootca.cer
} >> ${WORKDIR}/cacerts.pem

# create pkcs12
echo "Creating pkc12 keystore with private key and certificates"
openssl pkcs12 -export -name cordaclientca -in ${WORKDIR}/cacerts.pem -inkey "${WORKDIR}/cordaclientca.key" -out "${WORKDIR}/cordaclientca.p12"

# to jks
echo "Importing pkcs12 into ${NODEDIR}/certificates/nodekeystore.jks"
keytool -importkeystore -destkeystore ${NODEDIR}/certificates/nodekeystore.jks -srckeystore "${WORKDIR}/cordaclientca.p12" -srcstoretype pkcs12 -alias cordaclientca

echo "Generating TLS key and certificate..."
if ! openssl ecparam -genkey -name secp256r1 > ${WORKDIR}/sslkeystore.key
then
  echo "unable to generate ssl.key"
fi

if ! openssl req -new -key "${WORKDIR}/sslkeystore.key" -config "${CONFDIR}/sslkeystore.conf" -out "${WORKDIR}/sslkeystore.csr"
then
  echo "unable to generate sslkeystore.csr"
fi

echo "Signing TLS key with cordaclientca from nodekeystore"
if ! openssl x509 -req -days 730 -in "${WORKDIR}/sslkeystore.csr" -CA "${WORKDIR}/cacerts.pem" -CAkey "${WORKDIR}/cordaclientca.key" -CAcreateserial -out "${WORKDIR}/sslkeystore.crt" -extfile "${CONFDIR}/sslkeystore.conf"
then
  echo "unable to generate sslkeystore.crt"
  exit 1
fi

echo "Creating TLS cert chain with certs from network operator"
cat ${WORKDIR}/sslkeystore.crt >> ${WORKDIR}/sslcacerts.pem
cat ${WORKDIR}/cacerts.pem >> ${WORKDIR}/sslcacerts.pem

echo "Creating pkc12 keystore with TLS private key and TLS certificates"
openssl pkcs12 -export -name cordaclienttls -in ${WORKDIR}/sslcacerts.pem -inkey ${WORKDIR}/sslkeystore.key -out ${WORKDIR}/sslkeystore.p12

echo "Importing pkcs12 into ${NODEDIR}/certificates/sslkeystore.jks"
keytool -importkeystore -destkeystore "${NODEDIR}/certificates/sslkeystore.jks" -srckeystore "${WORKDIR}/sslkeystore.p12" -srcstoretype pkcs12 -alias cordaclienttls

echo "Copying network-parameters to ${NODEDIR}/"
cp "${PACKAGEDIR}/network-parameters" "${NODEDIR}/"

echo "done"