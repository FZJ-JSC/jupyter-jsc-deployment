#!/bin/bash

POD_NAME=$(skj get pods --selector app=jupyterhub --selector component=hub -o jsonpath='{.items..metadata.name}')

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ ! -f ${DIR}/devel ]]; then
  ssh-keygen -f ${DIR}/devel -t ed25519 
fi

PROXY_API_SERVICE_HOST=$(skj get svc proxy-api -o jsonpath='{.spec.clusterIP}')
PROXY_API_SERVICE_PORT=$(skj get svc proxy-api -o jsonpath='{.spec.ports..port}')
HUB_SERVICE_PORT=$(skj get svc hub -o jsonpath='{.spec.ports..port}')
JUPYTERHUB_USER_PASS=$(skj get secret drf-k8smgr-passwds -o jsonpath='{.data.JUPYTERHUB_USER_PASS}' | base64 -d)
K8SMGR_JHUB_BASIC=$(echo -n "jupyterhub:${JUPYTERHUB_USER_PASS}" | base64 -w 0)

JUPYTERHUB_USER_PASS=$(skj get secret drf-unicoremgr-passwds -o jsonpath='{.data.JUPYTERHUB_USER_PASS}' | base64 -d)
UNICOREMGR_JHUB_BASIC=$(echo -n "jupyterhub:${JUPYTERHUB_USER_PASS}" | base64 -w 0)

JUPYTERHUB_USER_PASS=$(skj get secret drf-tunnel-passwds -o jsonpath='{.data.JUPYTERHUB_USER_PASS}' | base64 -d)
TUNNEL_JHUB_BASIC=$(echo -n "jupyterhub:${JUPYTERHUB_USER_PASS}" | base64 -w 0)

OAUTH_CLIENT_ID=$(skj get secret hub-custom -o jsonpath='{.data.oauth_client_id_password}' | base64 -d)
OAUTH_CLIENT_SECRET=$(skj get secret hub-custom -o jsonpath='{.data.oauth_client_secret_password}' | base64 -d)
OAUTH_CLIENT_SECRET=${OAUTH_CLIENT_SECRET//\"/\\\"}
OAUTH_CLIENT_SECRET=${OAUTH_CLIENT_SECRET//\\/\\\\\\}
echo ${OAUTH_CLIENT_SECRET}

SQL_USER=$(skj get secret postgresql-users-jupyterjsc -o jsonpath='{.data.JUPYTERHUB_USER}' | base64 -d)
SQL_DATABASE=$(skj get secret postgresql-users-jupyterjsc -o jsonpath='{.data.JUPYTERHUB_DATABASE}' | base64 -d)
SQL_PASSWORD=$(skj get secret postgresql-users-jupyterjsc -o jsonpath='{.data.JUPYTERHUB_PASSWORD}' | base64 -d)

SQL_HOST=$(skj get secret postgresql-general -o jsonpath='{.data.SQL_HOST}' | base64 -d)
SQL_PORT=$(skj get secret postgresql-general -o jsonpath='{.data.SQL_PORT}' | base64 -d)

CONFIGPROXY_AUTH_TOKEN=$(skj get secret hub -o 'go-template={{index .data "hub.config.ConfigurableHTTPProxy.auth_token"}}' | base64 -d)


sed -e 's@<OAUTH_CLIENT_SECRET>@'"${OAUTH_CLIENT_SECRET}"'@g' -e "s@<OAUTH_CLIENT_ID>@${OAUTH_CLIENT_ID}@g" -e "s@<SQL_PASSWORD>@${SQL_PASSWORD}@g" -e "s@<SQL_DATABASE>@${SQL_DATABASE}@g" -e "s@<SQL_HOST>@${SQL_HOST}@g" -e "s@<SQL_PORT>@${SQL_PORT}@g" -e "s@<SQL_USER>@${SQL_USER}@g" -e "s@<CONFIGPROXY_AUTH_TOKEN>@${CONFIGPROXY_AUTH_TOKEN}@g" -e "s@<TUNNEL_JHUB_BASIC>@${TUNNEL_JHUB_BASIC}@g" -e "s@<K8SMGR_JHUB_BASIC>@${K8SMGR_JHUB_BASIC}@g" -e "s@<UNICOREMGR_JHUB_BASIC>@${UNICOREMGR_JHUB_BASIC}@g" -e "s@<PROXY_API_SERVICE_HOST>@${PROXY_API_SERVICE_HOST}@g" -e "s@<PROXY_API_SERVICE_PORT>@${PROXY_API_SERVICE_PORT}@g" -e "s@<HUB_SERVICE_PORT>@${HUB_SERVICE_PORT}@g" ${DIR}/launch.json.template > ${DIR}/launch.json

skj cp ${DIR}/devel.pub ${POD_NAME}:/home/jovyan/.ssh/authorized_keys
skj cp ${DIR}/settings.json ${POD_NAME}:/home/jovyan/.vscode/.
skj cp ${DIR}/launch.json ${POD_NAME}:/home/jovyan/.vscode/.
skj cp ${DIR}/tasks.json ${POD_NAME}:/home/jovyan/.vscode/.

echo "skj port-forward pod/${POD_NAME} 2222:2222"
