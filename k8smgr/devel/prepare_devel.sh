#!/bin/bash

POD_NAME=$(skj get pods --selector app=drf-k8smgr -o jsonpath='{.items..metadata.name}')

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ ! -f ${DIR}/devel ]]; then
    ssh-keygen -f ${DIR}/devel -t ed25519
fi

KUBERNETES_SERVICE_HOST=$(skj exec ${POD_NAME} -c main -- env | grep KUBERNETES_SERVICE_HOST)
KUBERNETES_SERVICE_HOST=${KUBERNETES_SERVICE_HOST##*=}

KUBERNETES_SERVICE_PORT=$(skj exec ${POD_NAME} -c main -- env | grep KUBERNETES_SERVICE_PORT)
KUBERNETES_SERVICE_PORT=${KUBERNETES_SERVICE_PORT##*=}

sed -e "s@<KUBERNETES_SERVICE_HOST>@${KUBERNETES_SERVICE_HOST}@g" -e "s@<KUBERNETES_SERVICE_PORT>@${KUBERNETES_SERVICE_PORT}@g" ${DIR}/launch.json.template > ${DIR}/launch.json

skj cp ${DIR}/devel.pub ${POD_NAME}:/home/k8smgr/.ssh/authorized_keys
skj cp ${DIR}/settings.json ${POD_NAME}:/home/k8smgr/web/.vscode/.
skj cp ${DIR}/launch.json ${POD_NAME}:/home/k8smgr/web/.vscode/.

echo "skj port-forward pod/${PODNAME} 2223:2222"
