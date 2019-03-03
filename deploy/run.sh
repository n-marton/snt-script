#!/bin/bash
read -p "Which version should we go with (default is master)? " VERSION
if [ "$VERSION" == "" ]; then
echo "No version set! Defaulting to master"
VERSION=master
fi
read -p "Under what name shall we deploy this?: " DEPLOYMENT_NAME
if [ "$DEPLOYMENT_NAME" == "" ]; then
echo "Deployment name cannot be empty."
exit 1
fi
read -p "Wish to see the results? (type 'yes' if you want it to be printed) " RESULT_PRINT
read -p "Which variable file should be use? (default is vars.json) " VARS_FILE
if [ "$VARS_FILE" == "" ]; then
echo "No variables file set! Defaulting to vars.json"
VARS_FILE=vars.json
fi
if [ ! -f $PWD/$VARS_FILE ]; then
echo "Variable file does not exist in this folder"
exit 1
fi
echo "Checking docker image"
docker build . -t "snt-rest:latest"
if [ $? != 0 ]; then
echo "Error on docker image check!"
exit 1
fi
echo "Starting docker"
docker run --rm -e REST_ARM_CLIENT_ID=$REST_ARM_CLIENT_ID -e REST_ARM_CLIENT_SECRET=$REST_ARM_CLIENT_SECRET \
-e REST_ARM_SUBSCRIPTION_ID=$REST_ARM_SUBSCRIPTION_ID -e REST_ARM_TENANT_ID=$REST_ARM_TENANT_ID \
-e DEPLOYMENT_NAME=$DEPLOYMENT_NAME -e RESULT_PRINT=$RESULT_PRINT -e VERSION=$VERSION \
-v $PWD/$VARS_FILE:/opt/snt/variables.json snt-rest:latest 