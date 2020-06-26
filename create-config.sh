#!/bin/bash
export REGION=$(./terraform output location)
export CERTIFICATE_CA=$(./terraform output ca_certificate)
export NAME=$(./terraform output cluster_name)
export SERVER=$(./terraform show | grep kubernetes_endpoint | awk '{ print $3 }' | sed 's/"//g')
export PROJECT_ID=$(./terraform output project_id)
echo =======
echo $SERVER
echo $NAME
echo $CERTIFICATE_CA
echo =======
sed 's/%NAME%/'"$NAME"'/g' config.template >config
sed -i 's/%REGION%/'"$REGION"'/g' config
sed -i 's/%CERTIFICATE_CA%/'"$CERTIFICATE_CA"'/g' config
sed -i 's/%SEVER%/'"$SERVER"'/g' config
sed -i 's/%PROJECT_ID%/'"$PROJECT_ID"'/g' config
