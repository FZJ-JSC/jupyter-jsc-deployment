#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

INTERNAL_SSL_PATH=${1:-"${SCRIPTDIR}/internal-ssl"}
SECRET_NAME=${2:-"internal-ssl"}


DIRS=("hub-ca" "notebooks-ca" "proxy-api" "proxy-api-ca" "proxy-client" "proxy-client-ca" "services-ca")
FILES=("--from-file=certipy.json=${INTERNAL_SSL_PATH}/certipy.json")

for dir in "${DIRS[@]}"
do
  FILES+=("--from-file=${dir}_${dir}.crt=${INTERNAL_SSL_PATH}/${dir}/${dir}.crt")
  FILES+=("--from-file=${dir}_${dir}.key=${INTERNAL_SSL_PATH}/${dir}/${dir}.key")
  if [[ ! ${dir} =~ ^(hub-internal|proxy-api|proxy-client)$ ]]; then
    FILES+=("--from-file=${dir}_trust.crt=${INTERNAL_SSL_PATH}/${dir}_trust.crt")
  fi
done

kubectl create secret generic --namespace jupyterjsc --dry-run=client -o yaml ${FILES[@]} ${SECRET_NAME}

#echo "---"

#kubectl create secret generic --dry-run=client -o yaml --from-file=tls.crt=${INTERNAL_SSL_PATH}/proxy-client/proxy-client.crt  --from-file=tls.key=${INTERNAL_SSL_PATH}/proxy-client/proxy-client.key  --from-file=ca.crt=${INTERNAL_SSL_PATH}/proxy-client-ca/proxy-client-ca.crt ${SECRET_NAME}-proxy-public
