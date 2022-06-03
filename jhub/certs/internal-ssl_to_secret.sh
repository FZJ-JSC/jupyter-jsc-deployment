#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

INTERNAL_SSL_PATH=${1:-"${SCRIPTDIR}/internal-ssl"}
CA_CERTS_PATH=${1:-"${SCRIPTDIR}/ca_certs"}
SECRET_NAME=${2:-"internal-ssl"}


DIRS=("proxy-api" "proxy-client")
DIRS_CA=("hub-ca" "notebooks-ca" "proxy-api-ca" "proxy-client-ca" "services-ca")
FILES=("--from-file=certipy.json=${INTERNAL_SSL_PATH}/certipy.json")

for dir in "${DIRS[@]}"
do
  FILES+=("--from-file=${dir}_${dir}.crt=${INTERNAL_SSL_PATH}/${dir}/${dir}.crt")
  FILES+=("--from-file=${dir}_${dir}.key=${INTERNAL_SSL_PATH}/${dir}/${dir}.key")
  #FILES+=("--from-file=${dir}_trust.crt=${INTERNAL_SSL_PATH}/${dir}_trust.crt")
done

for dir in "${DIRS_CA[@]}"
do
  FILES+=("--from-file=${dir}_${dir}.crt=${CA_CERTS_PATH}/${dir}/${dir}.crt")
  FILES+=("--from-file=${dir}_${dir}.key=${CA_CERTS_PATH}/${dir}/${dir}.key")
  FILES+=("--from-file=${dir}_trust.crt=${CA_CERTS_PATH}/${dir}_trust.crt")
done

kubectl create secret generic --namespace jupyterjsc --dry-run=client -o yaml ${FILES[@]} ${SECRET_NAME}

#echo "---"

#kubectl create secret generic --dry-run=client -o yaml --from-file=tls.crt=${INTERNAL_SSL_PATH}/proxy-client/proxy-client.crt  --from-file=tls.key=${INTERNAL_SSL_PATH}/proxy-client/proxy-client.key  --from-file=ca.crt=${INTERNAL_SSL_PATH}/proxy-client-ca/proxy-client-ca.crt ${SECRET_NAME}-proxy-public
