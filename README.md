This is a sample solution which with we can deploy some Azure resource via rest api directly (no wrappers like sdks or terraform).

To make it able to run you have to do the following:
1. You need an Azure account. (https://azure.microsoft.com/en-us/free/)
2. You need the Azure cli. (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. You need to create an rbac account:
    1. `az login`
    2. ` az ad sp create-for-rbac -n "rest"  --role="Owner" --scopes="/subscriptions/$YOUR_SUBSCRIPTION_ID"`
4. Set the following environtment variables:
    1. REST_ARM_CLIENT_ID -> 'appId' from rbac creation response
    2. REST_ARM_CLIENT_SECRET -> 'password' from rbac creation response
    3. REST_ARM_TENANT_ID -> 'tenant' from rbac creation response
    4. REST_ARM_SUBSCRIPTION_ID -> your subscription id
5. `git@github.com:n-marton/snt-script.git`
6. `cd snt-scrip/deploy`
7. run ./run.sh (You need docker engine installed)
8. All additional parameters will be handled by the scripts

Reading some azure deployment template documentations the best option to create a modularized solution with linked templates, this way these templates can be modified one a time. Storing these templates in git enables to version them so multiple setups can co exists. A solution like this is only good if it can be reused so it has an option to run it with different variables file (which could come from some secure place in the case of sensitive data, but I haven't implemented this yet).

The deployment workflow:
1. Template and template config files get downloaded
2. Confd renders the template
3. Rest auth
4. Rest request
5. Return state after the deployment finished either successfully or not
