#!/usr/bin/env bash

WORKDIR="/opt/nuts/temp/"
OUTDIR="/opt/nuts/keys/"
CONFDIR="/opt/nuts/conf/"

if [ -z "$1" ]; then
  echo "no network name given"
  exit 1
fi
if [ -z "$2" ]; then
  echo "no value for C given"
  exit 1
fi
if [ -z "$3" ]; then
  echo "no value for L given"
  exit 1
fi
NETWORK_NAME=$1
C=$2
L=$3

echo "generating ${NETWORK_NAME} network"

if ! hash openssl 2>&1 1>/dev/null; then
  echo "openssl not found"
  exit 1
fi

if ! hash keytool 2>&1 1>/dev/null; then
  echo "keytool not found"
  exit 1
fi

if ! ls ${OUTDIR} 2>&1 1>/dev/null; then
  echo "keys directory not mounted"
  exit 1
fi

mkdir -p ${WORKDIR}

echo "Setting certificate values"
cp ${CONFDIR}root.conf ${WORKDIR}root.conf
cp ${CONFDIR}doorman.conf ${WORKDIR}doorman.conf
cp ${CONFDIR}network_map.conf ${WORKDIR}network_map.conf
sed -i "s/NETWORK_NAME/${NETWORK_NAME}/g" ${WORKDIR}root.conf
sed -i "s/NETWORK_C/${C}/g" ${WORKDIR}root.conf
sed -i "s/NETWORK_L/${L}/g" ${WORKDIR}root.conf
sed -i "s/NETWORK_NAME/${NETWORK_NAME}/g" ${WORKDIR}doorman.conf
sed -i "s/NETWORK_C/${C}/g" ${WORKDIR}doorman.conf
sed -i "s/NETWORK_L/${L}/g" ${WORKDIR}doorman.conf
sed -i "s/NETWORK_NAME/${NETWORK_NAME}/g" ${WORKDIR}network_map.conf
sed -i "s/NETWORK_C/${C}/g" ${WORKDIR}network_map.conf
sed -i "s/NETWORK_L/${L}/g" ${WORKDIR}network_map.conf

echo "Generating root key and certificate..."
if ! openssl req -new -nodes -keyout ${OUTDIR}root.key -config ${WORKDIR}root.conf -days 1825 -out ${WORKDIR}root.csr -subj "/C=${C}/L=${L}/O=${NETWORK_NAME}/CN=${NETWORK_NAME} Corda root"
then
  echo "unable to generate root.csr"
  exit 1
fi

if ! openssl x509 -req -days 1825 -in ${WORKDIR}root.csr -signkey ${OUTDIR}root.key -out ${OUTDIR}root.crt -extfile ${WORKDIR}root.conf
then
  echo "unable to generate root.crt"
  exit 1
fi

echo "Generating Doorman key and certificate..."
if ! openssl req -new -nodes -keyout ${OUTDIR}doorman.key -config ${WORKDIR}doorman.conf -days 1825 -out ${WORKDIR}doorman.csr
then
  echo "unable to generate doorman.csr"
fi

if ! openssl x509 -req -days 1825 -in ${WORKDIR}doorman.csr -CA ${OUTDIR}root.crt -CAkey ${OUTDIR}root.key -CAcreateserial -out ${OUTDIR}doorman.crt -extfile ${WORKDIR}doorman.conf
then
  echo "unable to generate doorman.crt"
  exit 1
fi

echo "Generating NetworkMap key and certificate..."

if ! openssl req -new -nodes -keyout ${OUTDIR}network_map.key -config ${WORKDIR}network_map.conf -days 730 -out ${WORKDIR}network_map.csr
then
  echo "unable to generate network_map.csr"
  exit 1
fi

if ! openssl x509 -req -days 730 -in ${WORKDIR}network_map.csr -CA ${OUTDIR}root.crt -CAkey ${OUTDIR}root.key -CAcreateserial -out ${OUTDIR}network_map.crt -extfile ${WORKDIR}network_map.conf
then
  echo "unable to generate network_map.crt"
  exit 1
fi

echo "Creating root truststore..."
if ! keytool -import -file ${OUTDIR}root.crt -alias cordarootca -keystore ${OUTDIR}truststore.jks
then
  echo "could not create root truststore"
  exit 1
fi

echo "done"
