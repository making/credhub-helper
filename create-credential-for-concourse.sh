#!/bin/bash

if [ $# -lt 3 ];then
  echo "$0 team_name vairable_name value [variable_type] [pipeline_name]"
  exit 1
fi

CLIENT_ID=atc_to_credhub

TEAM_NAME=$1
VARIABLE_NAME=$2
VALUE="$3"
VARIABLE_TYPE=$4
if [ "$VARIABLE_TYPE" == "" ];then
    VARIABLE_TYPE=value
fi
PIPELINE_NAME=$5

NAME=/concourse/${TEAM_NAME}/${VARIABLE_NAME}
if [ "${PIPELINE_NAME}" != "" ];then
    NAME=/concourse/${TEAM_NAME}/${PIPELINE_NAME}/${VARIABLE_NAME}
fi

VALUE_OPT="-v"
if [ "${VARIABLE_TYPE}" == "password" ];then
    VALUE_OPT="-w"
fi

credhub set -n ${NAME} -t ${VARIABLE_TYPE} ${VALUE_OPT} "${VALUE}"
curl -k -H "Authorization: $(credhub --token)" -H "Content-Type: application/json" \
  "$(credhub api)/api/v1/permissions?credential_name=${NAME}" -d "{\"credential_name\": \"${NAME}\",\"permissions\": [{\"actor\": \"uaa-client:${CLIENT_ID}\",\"operations\": [\"read\"]}]}"
curl -k -H "Authorization: $(credhub --token)" "$(credhub api)/api/v1/permissions?credential_name=${NAME}"
