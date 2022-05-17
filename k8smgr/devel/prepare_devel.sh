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

SUPERUSER_PASS=$(skj get secret drf-k8smgr-passwds -o jsonpath='{.data.SUPERUSER_PASS}' | base64 -d)
JUPYTERHUB_USER_PASS=$(skj get secret drf-k8smgr-passwds -o jsonpath='{.data.JUPYTERHUB_USER_PASS}' | base64 -d)

SQL_USER=$(skj get secret postgresql-users-jupyterjsc -o jsonpath='{.data.K8SMGR_USER}' | base64 -d)
SQL_DATABASE=$(skj get secret postgresql-users-jupyterjsc -o jsonpath='{.data.K8SMGR_DATABASE}' | base64 -d)
SQL_PASSWORD=$(skj get secret postgresql-users-jupyterjsc -o jsonpath='{.data.K8SMGR_PASSWORD}' | base64 -d)

SQL_HOST=$(skj get secret postgresql-general -o jsonpath='{.data.SQL_HOST}' | base64 -d)
SQL_PORT=$(skj get secret postgresql-general -o jsonpath='{.data.SQL_PORT}' | base64 -d)
SQL_ENGINE=$(skj get secret postgresql-general -o jsonpath='{.data.SQL_ENGINE}' | base64 -d)

sed -e "s@<SUPERUSER_PASS>@${SUPERUSER_PASS}@g" -e "s@<JUPYTERHUB_USER_PASS>@${JUPYTERHUB_USER_PASS}@g" -e "s@<KUBERNETES_SERVICE_HOST>@${KUBERNETES_SERVICE_HOST}@g" -e "s@<KUBERNETES_SERVICE_PORT>@${KUBERNETES_SERVICE_PORT}@g" -e "s@<SQL_ENGINE>@${SQL_ENGINE}@g" -e "s@<SQL_PASSWORD>@${SQL_PASSWORD}@g" -e "s@<SQL_DATABASE>@${SQL_DATABASE}@g" -e "s@<SQL_HOST>@${SQL_HOST}@g" -e "s@<SQL_PORT>@${SQL_PORT}@g" -e "s@<SQL_USER>@${SQL_USER}@g" ${DIR}/launch.json.template > ${DIR}/launch.json

skj cp -c main ${DIR}/devel.pub ${POD_NAME}:/home/k8smgr/.ssh/authorized_keys
skj cp -c main ${DIR}/settings.json ${POD_NAME}:/home/k8smgr/web/.vscode/.
skj cp -c main ${DIR}/launch.json ${POD_NAME}:/home/k8smgr/web/.vscode/.

echo "skj port-forward pod/${POD_NAME} 2223:2222"
