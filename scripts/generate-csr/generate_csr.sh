#!/usr/bin/env bash

WORKDIR="/opt/nuts/temp/"
CORDADIR="/opt/nuts/"
NODEDIR="/opt/nuts/node/"

if ! ls ${NODEDIR} 2>&1 1>/dev/null; then
  echo "node directory not mounted to ${NODEDIR}"
  exit 1
fi

if ! ls ${CORDADIR}corda.jar 2>&1 1>/dev/null; then
  echo "corda.jar not found"
  exit 1
fi

java -jar ${CORDADIR}/corda.jar initial-registration --network-root-truststore-password=changeit --network-root-truststore=${NODEDIR}/certificates/truststore.jks --config-file=${NODEDIR}/node.conf 2>&1 > out.txt

cat out.txt | grep -A 20 BEGIN\ CERTIFICATE\ REQUEST | grep -B 20 END\ CERTIFICATE\ REQUEST > ${NODEDIR}csr.pem
echo "Your CSR has been generated in ${NODEDIR}csr.pem"