#!/bin/sh

echo "Getting template"
curl -s -o /etc/confd/templates/template.tmpl https://raw.githubusercontent.com/n-marton/snt-script/$VERSION/skeleton.json
echo "Getting confd config"
curl -s -o /etc/confd/conf.d/deploy.toml https://raw.githubusercontent.com/n-marton/snt-script/$VERSION/deploy.toml


confd -onetime -backend=file -file=variables.json
if [ $? != 0 ]; then
echo "Error while rendering!"
exit 1
fi
cat rendered.json  | jq '.' > validated.json
if [ $? != 0 ]; then
echo "Json validation failed!"
exit 1
fi

echo "Getting oauth token!"
TOKEN=$(curl -s -X POST -d "grant_type=client_credentials&client_id=$REST_ARM_CLIENT_ID&client_secret=$REST_ARM_CLIENT_SECRET&resource=https%3A%2F%2Fmanagement.azure.com%2F" https://login.microsoftonline.com/$REST_ARM_TENANT_ID/oauth2/token | jq -r .access_token)
if [ $TOKEN == "" ]; then
echo "Error on token request!"
exit 1
fi
echo "Starting deployment $DEPLOYMENT_NAME!"
curl -s -o /dev/null -d "@validated.json" -X PUT -H 'Content-type: application/json' -H "Authorization: Bearer $TOKEN" \
https://management.azure.com/subscriptions/$REST_ARM_SUBSCRIPTION_ID/providers/Microsoft.Resources/deployments/$DEPLOYMENT_NAME?api-version=2018-05-01 
if [ $? != 0 ]; then
echo "Error on deployment request!"
exit 1
fi
while true; do
RESULT=$(curl -s -X GET -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
"https://management.azure.com/subscriptions/$REST_ARM_SUBSCRIPTION_ID/providers/Microsoft.Resources/deployments/$DEPLOYMENT_NAME?api-version=2018-05-01 " \
| jq -r .properties.provisioningState)
if [ "$RESULT" == "Accepted" ] || [ "$RESULT" == "Running" ]; then
echo "Waiting for provisioning state!"
sleep 30
else
break
fi
done
echo "Provisioning state: $RESULT"
if [ "$RESULT_PRINT" == "yes" ]; then
curl -X GET -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
"https://management.azure.com/subscriptions/$REST_ARM_SUBSCRIPTION_ID/providers/Microsoft.Resources/deployments/$DEPLOYMENT_NAME?api-version=2018-05-01 " \
| jq  
fi