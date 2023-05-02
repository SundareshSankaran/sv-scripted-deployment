# Parameters:
# 1 = name of subscription
# 2 = desired name for service principal

SP_Name=$2
az account set -s $1
TF_VAR_tenant_id=$(az account show --query 'tenantId' --output tsv)
TF_VAR_subscription_id=$(az account show --query 'id' --output tsv)

TF_VAR_client_secret=$(az ad sp create-for-rbac --role "Contributor" --scopes="/subscriptions/$TF_VAR_subscription_id" --name $SP_Name --query password --output tsv)
TF_VAR_client_id=$(az ad sp list --display-name $SP_Name --query "[0].appId"|sed -e 's/^"//' -e 's/"$//')

echo "Client ID: $TF_VAR_client_id"
echo "Client Secret: $TF_VAR_client_secret"

echo "TF_VAR_tenant_id=$TF_VAR_tenant_id" > "$HOME/.azure_creds_terraform_test.env"
echo "TF_VAR_subscription_id=$TF_VAR_subscription_id" >> "$HOME/.azure_creds_terraform_test.env"
echo "TF_VAR_client_id=$TF_VAR_client_id" >> "$HOME/.azure_creds_terraform_test.env"
echo "TF_VAR_client_secret=$TF_VAR_client_secret" >> "$HOME/.azure_creds_terraform_test.env"

chmod 0600 "$HOME/.azure_creds_terraform_test.env"
cp $HOME/.azure_creds_terraform_test.env $HOME/.azure_creds_$2.env
